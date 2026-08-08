import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../datasources/market_local_db.dart';
import '../models/market_facility_model.dart';

class MarketDataUnavailableException implements Exception {}

/// Turkish day names as they appear in the municipality's bazaar schedule
/// text, mapped to ISO weekday numbers (1 = Monday ... 7 = Sunday).
const Map<String, int> _turkishDayToIso = {
  'Pazartesi': 1,
  'Salı': 2,
  'Çarşamba': 3,
  'Perşembe': 4,
  'Cuma': 5, // must be checked before "Cumartesi" — see _parseScheduleDays
  'Cumartesi': 6,
  'Pazar': 7,
};

class MarketRepository {
  static const String _bazaarsUrl =
      'https://openapi.izmir.bel.tr/api/ibb/cbs/pazaryerleri';
  static const List<String> _overpassMirrors = [
    'https://overpass-api.de/api/interpreter',
    'https://overpass.kumi.systems/api/interpreter',
  ];
  static const List<String> _shopTags = [
    'supermarket',
    'convenience',
    'grocery',
    'bakery',
    'butcher',
    'greengrocer',
  ];

  final MarketLocalDb _localDb = MarketLocalDb.instance;

  /// Weekly bazaars, city-wide, cached ~24h — same pattern as Bus
  /// Stops/Healthcare since this is a small, static official dataset.
  Future<List<MarketFacilityModel>> getBazaars({
    bool forceRefresh = false,
  }) async {
    final lastSynced = await _localDb.getLastSyncedAt('bazaars_last_synced');
    final isStale = lastSynced == null ||
        DateTime.now().difference(lastSynced) > const Duration(hours: 24);

    if (!forceRefresh && !isStale) {
      final cached = await _localDb.getBazaars();
      if (cached.isNotEmpty) return cached;
    }

    try {
      final bazaars = await _fetchBazaars();
      debugPrint('[MarketRepository] Fetched ${bazaars.length} bazaars.');
      if (bazaars.isNotEmpty) {
        await _localDb.replaceBazaars(bazaars);
        return bazaars;
      }
    } catch (e) {
      debugPrint('[MarketRepository] Bazaar fetch FAILED: $e');
    }

    final cached = await _localDb.getBazaars();
    if (cached.isEmpty) throw MarketDataUnavailableException();
    return cached;
  }

  /// Supermarkets/grocery/bakery/butcher/greengrocer, queried live from
  /// OpenStreetMap centered on the user's current location. Not cached
  /// city-wide (that would be a huge, slow query) — only the most recent
  /// successful result is kept as an offline fallback.
  Future<List<MarketFacilityModel>> getNearbyShops({
    required double latitude,
    required double longitude,
    int radiusMeters = 3000,
  }) async {
    try {
      final shops =
          await _fetchShopsFromOverpass(latitude, longitude, radiusMeters);
      debugPrint('[MarketRepository] Fetched ${shops.length} shops from OSM.');
      if (shops.isNotEmpty) {
        await _localDb.replaceShops(shops);
        return shops;
      }
    } catch (e) {
      debugPrint('[MarketRepository] Shop fetch FAILED: $e');
    }

    final cached = await _localDb.getShops();
    if (cached.isEmpty) throw MarketDataUnavailableException();
    return cached;
  }

  Future<List<MarketFacilityModel>> _fetchBazaars() async {
    final response = await http
        .get(Uri.parse(_bazaarsUrl))
        .timeout(const Duration(seconds: 25));
    if (response.statusCode != 200) {
      throw Exception('Failed to load bazaar data (${response.statusCode})');
    }

    final decoded =
        jsonDecode(utf8.decode(response.bodyBytes, allowMalformed: true))
            as Map<String, dynamic>;
    final items =
        (decoded['onemliyer'] as List? ?? []).cast<Map<String, dynamic>>();

    final bazaars = <MarketFacilityModel>[];
    for (final item in items) {
      final name = (item['ADI'] as String?)?.trim();
      final lat = (item['ENLEM'] as num?)?.toDouble();
      final lon = (item['BOYLAM'] as num?)?.toDouble();
      if (name == null || name.isEmpty || lat == null || lon == null) {
        continue;
      }
      if (lat < 34 || lat > 43 || lon < 24 || lon > 46) continue;

      final aciklama = (item['ACIKLAMA'] as String?)?.trim() ?? '';
      bazaars.add(MarketFacilityModel(
        id: _makeId(MarketCategory.weeklyBazaar, name, lat, lon),
        category: MarketCategory.weeklyBazaar,
        name: name,
        district: (item['ILCE'] as String?)?.trim() ?? '',
        neighborhood: (item['MAHALLE'] as String?)?.trim() ?? '',
        street: (item['YOL'] as String?)?.trim(),
        buildingNo: (item['KAPINO'] as String?)?.trim(),
        latitude: lat,
        longitude: lon,
        notes: aciklama.isNotEmpty ? aciklama : null,
        scheduleDays: _parseScheduleDays(aciklama),
      ));
    }
    return bazaars;
  }

  /// Extracts which day(s) of the week a bazaar runs on from its free-text
  /// municipal description (e.g. "Cumartesi günü kurulmaktadır").
  List<int> _parseScheduleDays(String text) {
    final found = <int>{};
    // Check "Cumartesi" (Saturday) before "Cuma" (Friday) since "Cuma" is
    // a prefix of "Cumartesi" and would otherwise false-match.
    final orderedEntries = _turkishDayToIso.entries.toList()
      ..sort((a, b) => b.key.length.compareTo(a.key.length));
    for (final entry in orderedEntries) {
      final pattern = RegExp('\\b${entry.key}\\b', caseSensitive: false);
      if (pattern.hasMatch(text)) {
        found.add(entry.value);
      }
    }
    final result = found.toList()..sort();
    return result;
  }

  Future<List<MarketFacilityModel>> _fetchShopsFromOverpass(
      double lat, double lon, int radiusMeters) async {
    // A single regex-based filter is dramatically cheaper for Overpass's
    // free public server than 6 separate around() filters (one per shop
    // type) — the previous approach was timing out under normal load.
    final tagPattern = _shopTags.join('|');
    final query = '[out:json][timeout:25];'
        '(node["shop"~"^($tagPattern)\$"](around:$radiusMeters,$lat,$lon);'
        ');out body;';

    Exception? lastError;
    for (final baseUrl in _overpassMirrors) {
      try {
        // POST (not GET) — overpass-api.de's server applies Apache content
        // negotiation to GET requests on this path and can return 406.
        // POST with the query as a form field is Overpass's documented,
        // recommended method and avoids that entirely.
        final response = await http.post(
          Uri.parse(baseUrl),
          headers: {
            'User-Agent':
                'HealthCarePlusApp/1.0 (Flutter; Izmir Guzelbahce elderly-assistance thesis app)',
            'Accept': 'application/json',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {'data': query},
        ).timeout(const Duration(seconds: 30));
        debugPrint('[MarketRepository] Overpass ($baseUrl) status: '
            '${response.statusCode}, body length: ${response.bodyBytes.length}');
        if (response.statusCode != 200) {
          debugPrint('[MarketRepository] Response body: ${response.body}');
          throw Exception(
              'Overpass returned ${response.statusCode} from $baseUrl');
        }
        return _parseOverpassResponse(response.bodyBytes);
      } catch (e) {
        debugPrint('[MarketRepository] Overpass mirror $baseUrl FAILED: $e');
        lastError = e is Exception ? e : Exception(e.toString());
        // Try the next mirror.
      }
    }
    throw lastError ?? Exception('All Overpass mirrors failed');
  }

  List<MarketFacilityModel> _parseOverpassResponse(List<int> bodyBytes) {
    final decoded = jsonDecode(utf8.decode(bodyBytes, allowMalformed: true))
        as Map<String, dynamic>;
    final elements =
        (decoded['elements'] as List? ?? []).cast<Map<String, dynamic>>();
    debugPrint(
        '[MarketRepository] Overpass returned ${elements.length} raw elements.');

    final shops = <MarketFacilityModel>[];
    for (final element in elements) {
      final tags = (element['tags'] as Map?)?.cast<String, dynamic>() ?? {};
      final name = (tags['name'] as String?)?.trim();
      final shopType = tags['shop'] as String?;
      final elementLat = (element['lat'] as num?)?.toDouble();
      final elementLon = (element['lon'] as num?)?.toDouble();
      if (name == null ||
          name.isEmpty ||
          shopType == null ||
          elementLat == null ||
          elementLon == null) {
        continue;
      }

      final category = _mapShopType(shopType);
      if (category == null) continue;

      final street = (tags['addr:street'] as String?)?.trim();
      final houseNo = (tags['addr:housenumber'] as String?)?.trim();
      final neighborhood = (tags['addr:suburb'] as String?)?.trim() ??
          (tags['addr:neighbourhood'] as String?)?.trim() ??
          '';

      shops.add(MarketFacilityModel(
        id: 'osm_${element['id']}',
        category: category,
        name: name,
        street: (street != null && street.isNotEmpty) ? street : null,
        buildingNo: (houseNo != null && houseNo.isNotEmpty) ? houseNo : null,
        neighborhood: neighborhood,
        latitude: elementLat,
        longitude: elementLon,
      ));
    }
    return shops;
  }

  MarketCategory? _mapShopType(String shopType) {
    switch (shopType) {
      case 'supermarket':
        return MarketCategory.supermarket;
      case 'convenience':
      case 'grocery':
        return MarketCategory.groceryConvenience;
      case 'bakery':
        return MarketCategory.bakery;
      case 'butcher':
        return MarketCategory.butcher;
      case 'greengrocer':
        return MarketCategory.greengrocer;
      default:
        return null;
    }
  }

  String _makeId(MarketCategory category, String name, double lat, double lon) {
    final key =
        '${category.name}_${name}_${lat.toStringAsFixed(5)}_${lon.toStringAsFixed(5)}';
    return key.replaceAll(RegExp(r'\s+'), '_');
  }
}

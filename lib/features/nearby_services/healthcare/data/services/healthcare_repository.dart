import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../datasources/healthcare_local_db.dart';
import '../models/healthcare_facility_model.dart';

/// Thrown when neither category (general facilities or pharmacies) could be
/// fetched or loaded from cache. Distinct from "genuinely nothing nearby".
class HealthcareDataUnavailableException implements Exception {}

/// Source: İzmir Metropolitan Municipality Open Data API
/// (openapi.izmir.bel.tr) — free, no API key required.
class HealthcareRepository {
  static const String _hospitalsUrl =
      'https://openapi.izmir.bel.tr/api/ibb/cbs/hastaneler';
  static const String _familyHealthCentersUrl =
      'https://openapi.izmir.bel.tr/api/ibb/cbs/ailesagligimerkezleri';
  static const String _pharmaciesUrl =
      'https://openapi.izmir.bel.tr/api/ibb/nobetcieczaneler';

  final HealthcareLocalDb _localDb = HealthcareLocalDb.instance;

  /// Hospitals + family health centers. Cached ~24h — this data changes
  /// rarely.
  Future<List<HealthcareFacilityModel>> getFacilities(
      {bool forceRefresh = false}) async {
    final lastSynced = await _localDb.getLastSyncedAt('facilities_last_synced');
    final isStale = lastSynced == null ||
        DateTime.now().difference(lastSynced) > const Duration(hours: 24);

    if (!forceRefresh && !isStale) {
      final cached = await _localDb.getFacilities();
      if (cached.isNotEmpty) return cached;
    }

    try {
      final hospitals =
          await _fetchCategory(_hospitalsUrl, HealthcareCategory.hospital);
      final familyHealthCenters = await _fetchCategory(
          _familyHealthCentersUrl, HealthcareCategory.familyHealthCenter);
      final combined = [...hospitals, ...familyHealthCenters];
      debugPrint('[HealthcareRepository] Fetched ${hospitals.length} '
          'hospitals + ${familyHealthCenters.length} family health centers.');
      if (combined.isNotEmpty) {
        await _localDb.replaceFacilities(combined);
        return combined;
      }
    } catch (e) {
      debugPrint('[HealthcareRepository] Facility fetch FAILED: $e');
    }

    final cached = await _localDb.getFacilities();
    if (cached.isEmpty) {
      throw HealthcareDataUnavailableException();
    }
    return cached;
  }

  /// On-duty pharmacies. The duty roster rotates daily, so we treat any
  /// cache from a previous calendar day as stale regardless of hours passed.
  Future<List<HealthcareFacilityModel>> getOnDutyPharmacies(
      {bool forceRefresh = false}) async {
    final lastSynced = await _localDb.getLastSyncedAt('pharmacies_last_synced');
    final isSameDay = lastSynced != null &&
        lastSynced.year == DateTime.now().year &&
        lastSynced.month == DateTime.now().month &&
        lastSynced.day == DateTime.now().day;

    if (!forceRefresh && isSameDay) {
      final cached = await _localDb.getPharmacies();
      if (cached.isNotEmpty) return cached;
    }

    try {
      final pharmacies = await _fetchPharmacies();
      debugPrint(
          '[HealthcareRepository] Fetched ${pharmacies.length} on-duty pharmacies.');
      if (pharmacies.isNotEmpty) {
        await _localDb.replacePharmacies(pharmacies);
        return pharmacies;
      }
    } catch (e) {
      debugPrint('[HealthcareRepository] Pharmacy fetch FAILED: $e');
    }

    final cached = await _localDb.getPharmacies();
    if (cached.isEmpty) {
      throw HealthcareDataUnavailableException();
    }
    return cached;
  }

  Future<List<HealthcareFacilityModel>> _fetchCategory(
      String url, HealthcareCategory category) async {
    final response =
        await http.get(Uri.parse(url)).timeout(const Duration(seconds: 25));
    if (response.statusCode != 200) {
      throw Exception('Failed to load $category data (${response.statusCode})');
    }

    final decoded =
        jsonDecode(utf8.decode(response.bodyBytes, allowMalformed: true))
            as Map<String, dynamic>;
    final items =
        (decoded['onemliyer'] as List? ?? []).cast<Map<String, dynamic>>();

    final facilities = <HealthcareFacilityModel>[];
    for (final item in items) {
      final name = (item['ADI'] as String?)?.trim();
      final lat = (item['ENLEM'] as num?)?.toDouble();
      final lon = (item['BOYLAM'] as num?)?.toDouble();
      if (name == null || name.isEmpty || lat == null || lon == null) {
        continue;
      }
      // Sanity check: skip coordinates clearly outside Turkey.
      if (lat < 34 || lat > 43 || lon < 24 || lon > 46) continue;

      final notesRaw = (item['ACIKLAMA'] as String?)?.trim();
      facilities.add(HealthcareFacilityModel(
        id: _makeId(category, name, lat, lon),
        category: category,
        name: name,
        district: (item['ILCE'] as String?)?.trim() ?? '',
        neighborhood: (item['MAHALLE'] as String?)?.trim() ?? '',
        street: (item['YOL'] as String?)?.trim(),
        buildingNo: (item['KAPINO'] as String?)?.trim(),
        latitude: lat,
        longitude: lon,
        notes: (notesRaw != null && notesRaw.isNotEmpty) ? notesRaw : null,
      ));
    }
    return facilities;
  }

  Future<List<HealthcareFacilityModel>> _fetchPharmacies() async {
    final response = await http
        .get(Uri.parse(_pharmaciesUrl))
        .timeout(const Duration(seconds: 25));
    if (response.statusCode != 200) {
      throw Exception('Failed to load pharmacy data (${response.statusCode})');
    }

    final decoded =
        jsonDecode(utf8.decode(response.bodyBytes, allowMalformed: true))
            as List<dynamic>;

    final facilities = <HealthcareFacilityModel>[];
    for (final raw in decoded) {
      final item = raw as Map<String, dynamic>;
      final name = (item['Adi'] as String?)?.trim();
      // Note: the API's field names are misleading — LokasyonX is actually
      // latitude (~38) and LokasyonY is actually longitude (~27) for İzmir.
      final lat = double.tryParse(item['LokasyonX']?.toString() ?? '');
      final lon = double.tryParse(item['LokasyonY']?.toString() ?? '');
      if (name == null || name.isEmpty || lat == null || lon == null) {
        continue;
      }
      if (lat < 34 || lat > 43 || lon < 24 || lon > 46) continue;

      final notesRaw = (item['BolgeAciklama'] as String?)?.trim();
      facilities.add(HealthcareFacilityModel(
        id: _makeId(HealthcareCategory.pharmacy, name, lat, lon),
        category: HealthcareCategory.pharmacy,
        name: name,
        district: (item['Bolge'] as String?)?.trim() ?? '',
        neighborhood: '',
        latitude: lat,
        longitude: lon,
        phone: (item['Telefon'] as String?)?.trim(),
        address: (item['Adres'] as String?)?.trim(),
        notes: (notesRaw != null && notesRaw.isNotEmpty) ? notesRaw : null,
        isOnDuty: true,
      ));
    }
    return facilities;
  }

  /// The municipality's API does not provide a stable numeric ID for
  /// hospitals/family health centers, so we derive one deterministically
  /// from category + name + coordinates for caching and favoriting.
  String _makeId(
      HealthcareCategory category, String name, double lat, double lon) {
    final key =
        '${category.name}_${name}_${lat.toStringAsFixed(5)}_${lon.toStringAsFixed(5)}';
    return key.replaceAll(RegExp(r'\s+'), '_');
  }
}

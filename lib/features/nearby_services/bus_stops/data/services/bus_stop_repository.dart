import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../datasources/bus_stop_local_db.dart';
import '../models/bus_stop_model.dart';

/// Thrown when we could not fetch fresh bus stop data from the network AND
/// there is no local cache to fall back to. Distinct from "genuinely no
/// stops nearby" — the UI should show a retry/connection message, not an
/// empty-results message, when this happens.
class BusStopDataUnavailableException implements Exception {}

/// Source: İzmir Metropolitan Municipality Open Data Portal (acikveri.bizizmir.com),
/// dataset "eshot-otobus-duraklari" — official, free, no API key required.
/// Refreshed by the municipality roughly twice a day.
class BusStopRepository {
  static const String _csvUrl =
      'https://openfiles.izmir.bel.tr/211488/docs/eshot-otobus-duraklari.csv';

  final BusStopLocalDb _localDb = BusStopLocalDb.instance;

  /// Returns bus stops, preferring a fresh local cache (< 24h old) to avoid
  /// unnecessary network calls. Falls back to whatever is cached if the
  /// network call fails, so the feature still works offline once synced once.
  Future<List<BusStopModel>> getStops({bool forceRefresh = false}) async {
    final lastSynced = await _localDb.getLastSyncedAt();
    final isStale = lastSynced == null ||
        DateTime.now().difference(lastSynced) > const Duration(hours: 24);

    if (!forceRefresh && !isStale) {
      final cached = await _localDb.getAllStops();
      if (cached.isNotEmpty) return cached;
    }

    try {
      final freshStops = await _fetchFromNetwork();
      if (freshStops.isNotEmpty) {
        await _localDb.replaceAllStops(freshStops);
        return freshStops;
      }
    } catch (_) {
      // Network or parsing failed — fall through to cache below.
    }

    final cached = await _localDb.getAllStops();
    if (cached.isEmpty) {
      // Nothing fresh, nothing cached — this is a real failure, not "no
      // stops nearby". Let the caller show a proper retry/connection message.
      throw BusStopDataUnavailableException();
    }
    return cached;
  }

  Future<List<BusStopModel>> _fetchFromNetwork() async {
    final response =
        await http.get(Uri.parse(_csvUrl)).timeout(const Duration(seconds: 25));

    if (response.statusCode != 200) {
      throw Exception('Failed to load bus stop data');
    }

    // Decode explicitly as UTF-8 so Turkish characters (ç, ğ, ı, ö, ş, ü)
    // in stop names come through correctly.
    final csvText = utf8.decode(response.bodyBytes, allowMalformed: true);

    var rows = const CsvToListConverter(fieldDelimiter: ',').convert(csvText);
    if (rows.isNotEmpty && rows.first.length < 3) {
      // Some municipal exports use semicolons instead of commas.
      rows = const CsvToListConverter(fieldDelimiter: ';').convert(csvText);
    }
    if (rows.isEmpty) return [];

    final header =
        rows.first.map((e) => e.toString().trim().toUpperCase()).toList();
    final idIndex = header.indexOf('DURAK_ID');
    final nameIndex = header.indexOf('DURAK_ADI');
    final latIndex = header.indexOf('ENLEM');
    final lonIndex = header.indexOf('BOYLAM');
    final linesIndex = header.indexOf('DURAKTAN_GECEN_HATLAR');

    if (idIndex == -1 || nameIndex == -1 || latIndex == -1 || lonIndex == -1) {
      throw Exception('Unexpected bus stop data format');
    }

    final stops = <BusStopModel>[];
    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length <= latIndex || row.length <= lonIndex) continue;

      final id = int.tryParse(row[idIndex].toString());
      final lat =
          double.tryParse(row[latIndex].toString().replaceAll(',', '.'));
      final lon =
          double.tryParse(row[lonIndex].toString().replaceAll(',', '.'));
      final name = row[nameIndex].toString().trim();

      if (id == null || lat == null || lon == null || name.isEmpty) continue;

      // Sanity check: skip any row with coordinates clearly outside Turkey.
      // Protects against occasional malformed rows in the open-data feed.
      if (lat < 34 || lat > 43 || lon < 24 || lon > 46) continue;

      final linesRaw = (linesIndex != -1 && row.length > linesIndex)
          ? row[linesIndex].toString()
          : '';
      final lines = linesRaw
          .split(RegExp(r'[,;/]'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      stops.add(BusStopModel(
        id: id,
        name: name,
        latitude: lat,
        longitude: lon,
        lines: lines,
      ));
    }

    return stops;
  }
}

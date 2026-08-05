import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:elderly_prototype_app/core/constants.dart';
import 'package:elderly_prototype_app/core/services/location_service.dart';
import 'package:elderly_prototype_app/core/widgets/nearby_place_card.dart';
import '../data/models/bus_stop_model.dart';
import '../providers/bus_stop_provider.dart';

class BusStopsScreen extends ConsumerStatefulWidget {
  const BusStopsScreen({super.key});

  @override
  ConsumerState<BusStopsScreen> createState() => _BusStopsScreenState();
}

class _BusStopsScreenState extends ConsumerState<BusStopsScreen> {
  static const Color _primary = Color(0xFF2196F3);
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(busStopsProvider.notifier).loadNearbyStops();
    });
  }

  Future<void> _openDirections(BusStopWithDistance item) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${item.stop.latitude},${item.stop.longitude}',
    );
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.directionsErrorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(busStopsProvider);
    final notifier = ref.read(busStopsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.nearbyBusStopsTitle),
      ),
      body: RefreshIndicator(
        onRefresh: () => notifier.loadNearbyStops(forceRefresh: true),
        child: _buildBody(state, notifier),
      ),
    );
  }

  Widget _buildBody(BusStopsState state, BusStopsNotifier notifier) {
    if (state.isLoading && state.stops.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          const Center(child: CircularProgressIndicator()),
          const SizedBox(height: 20),
          Center(
            child: Text(
              AppStrings.locatingMessage,
              style: const TextStyle(fontSize: 18, color: Colors.black54),
            ),
          ),
        ],
      );
    }

    if (state.errorMessage != null && state.stops.isEmpty) {
      final isPermissionIssue =
          state.errorMessage == AppStrings.locationPermissionDeniedMessage ||
              state.errorMessage ==
                  AppStrings.locationPermissionDeniedForeverMessage;

      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 60),
          const Icon(Icons.location_off_rounded, size: 64, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            state.errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, color: Colors.black87),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => notifier.loadNearbyStops(),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                AppStrings.retryButton,
                style: const TextStyle(fontSize: 17),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => isPermissionIssue
                  ? Geolocator.openAppSettings()
                  : Geolocator.openLocationSettings(),
              icon: const Icon(Icons.settings_rounded),
              label: Text(
                isPermissionIssue
                    ? AppStrings.openAppSettingsButton
                    : AppStrings.openLocationSettingsButton,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      );
    }

    if (state.stops.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 60),
          const Icon(Icons.directions_bus_filled_rounded,
              size: 64, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            AppStrings.noBusStopsFound,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, color: Colors.black87),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.stops.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              '${state.stops.length} ${AppStrings.busStopsFoundLabel}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }
        final item = state.stops[index - 1];
        return NearbyPlaceCard(
          icon: Icons.directions_bus_filled_rounded,
          iconBackgroundColor: _primary.withOpacity(0.15),
          iconColor: _primary,
          title: item.stop.name,
          tags: item.stop.lines,
          distanceLabel: _locationService.formatDistance(item.distanceMeters),
          walkingTimeLabel:
              _locationService.formatWalkingTime(item.distanceMeters),
          isFavorite: notifier.isFavorite(item.stop.id),
          onFavoriteToggle: () => notifier.toggleFavorite(item.stop.id),
          onDirectionsPressed: () => _openDirections(item),
        );
      },
    );
  }
}

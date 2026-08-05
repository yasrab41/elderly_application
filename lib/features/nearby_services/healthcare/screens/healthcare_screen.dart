import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:elderly_prototype_app/core/constants.dart';
import 'package:elderly_prototype_app/core/services/location_service.dart';
import 'package:elderly_prototype_app/core/widgets/nearby_place_card.dart';
import '../data/models/healthcare_facility_model.dart';
import '../providers/healthcare_provider.dart';

class HealthcareScreen extends ConsumerStatefulWidget {
  const HealthcareScreen({super.key});

  @override
  ConsumerState<HealthcareScreen> createState() => _HealthcareScreenState();
}

class _HealthcareScreenState extends ConsumerState<HealthcareScreen> {
  final LocationService _locationService = LocationService();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(healthcareProvider.notifier).loadNearby();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _colorFor(HealthcareCategory category) {
    switch (category) {
      case HealthcareCategory.hospital:
        return const Color(0xFFE53935);
      case HealthcareCategory.familyHealthCenter:
        return const Color(0xFF43A047);
      case HealthcareCategory.pharmacy:
        return const Color.fromARGB(255, 0, 57, 137);
    }
  }

  IconData _iconFor(HealthcareCategory category) {
    switch (category) {
      case HealthcareCategory.hospital:
        return Icons.local_hospital_rounded;
      case HealthcareCategory.familyHealthCenter:
        return Icons.health_and_safety_rounded;
      case HealthcareCategory.pharmacy:
        return Icons.local_pharmacy_rounded;
    }
  }

  Future<void> _openDirections(HealthcareFacilityModel facility) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${facility.latitude},${facility.longitude}',
    );
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.directionsErrorMessage)),
      );
    }
  }

  Future<void> _callNumber(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    final launched = await launchUrl(uri);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.callErrorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(healthcareProvider);
    final notifier = ref.read(healthcareProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.nearbyHealthcareTitle)),
      body: RefreshIndicator(
        onRefresh: () => notifier.loadNearby(forceRefresh: true),
        child: Column(
          children: [
            _buildEmergencyBanner(),
            if (state.facilities.isNotEmpty || state.isLoading == false)
              _buildFilters(state, notifier),
            Expanded(child: _buildBody(state, notifier)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE53935), width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.emergency_rounded, color: Color(0xFFE53935)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppStrings.emergencyBannerText,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFFB71C1C),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => _callNumber('112'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              AppStrings.emergencyCallButton,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(HealthcareState state, HealthcareNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: notifier.setSearchQuery,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: AppStrings.searchHealthcareHint,
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _categoryChip(AppStrings.categoryAll, null, state, notifier),
                _categoryChip(AppStrings.categoryHospitals,
                    HealthcareCategory.hospital, state, notifier),
                _categoryChip(AppStrings.categoryFamilyHealthCenters,
                    HealthcareCategory.familyHealthCenter, state, notifier),
                _categoryChip(AppStrings.categoryPharmacies,
                    HealthcareCategory.pharmacy, state, notifier),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _categoryChip(String label, HealthcareCategory? category,
      HealthcareState state, HealthcareNotifier notifier) {
    final isSelected = state.selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black87)),
        selected: isSelected,
        onSelected: (_) => notifier.setCategory(category),
        selectedColor:
            category != null ? _colorFor(category) : const Color(0xFF48352A),
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
              color: isSelected ? Colors.transparent : Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _buildBody(HealthcareState state, HealthcareNotifier notifier) {
    if (state.isLoading && state.facilities.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 100),
          const Center(child: CircularProgressIndicator()),
          const SizedBox(height: 20),
          Center(
            child: Text(
              AppStrings.locatingHealthcareMessage,
              style: const TextStyle(fontSize: 18, color: Colors.black54),
            ),
          ),
        ],
      );
    }

    if (state.errorMessage != null && state.facilities.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 40),
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
              onPressed: () => notifier.loadNearby(),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(AppStrings.retryButton,
                  style: const TextStyle(fontSize: 17)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF48352A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      );
    }

    final visible = notifier.visibleFacilities;

    if (visible.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.search_off_rounded, size: 64, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            AppStrings.noHealthcareResultsFound,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, color: Colors.black87),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: visible.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              '${visible.length} ${AppStrings.healthcareResultsFoundLabel}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }
        final item = visible[index - 1];
        final facility = item.facility;
        final color = _colorFor(facility.category);

        return NearbyPlaceCard(
          icon: _iconFor(facility.category),
          iconBackgroundColor: color.withOpacity(0.15),
          iconColor: color,
          title: facility.name,
          subtitle: facility.displayAddress(),
          statusBadgeText: facility.isOnDuty ? AppStrings.openNowBadge : null,
          statusBadgeColor: const Color(0xFF43A047),
          tags: null,
          distanceLabel: _locationService.formatDistance(item.distanceMeters),
          walkingTimeLabel:
              _locationService.formatWalkingTime(item.distanceMeters),
          isFavorite: notifier.isFavorite(facility.id),
          onFavoriteToggle: () => notifier.toggleFavorite(facility.id),
          onDirectionsPressed: () => _openDirections(facility),
          onCallPressed: (facility.phone != null && facility.phone!.isNotEmpty)
              ? () => _callNumber(facility.phone!)
              : null,
        );
      },
    );
  }
}

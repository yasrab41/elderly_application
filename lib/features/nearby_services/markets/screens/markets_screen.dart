import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:elderly_prototype_app/core/constants.dart';
import 'package:elderly_prototype_app/core/services/location_service.dart';
import 'package:elderly_prototype_app/core/widgets/nearby_place_card.dart';
import '../data/models/market_facility_model.dart';
import '../providers/market_provider.dart';

class MarketsScreen extends ConsumerStatefulWidget {
  const MarketsScreen({super.key});

  @override
  ConsumerState<MarketsScreen> createState() => _MarketsScreenState();
}

class _MarketsScreenState extends ConsumerState<MarketsScreen> {
  final LocationService _locationService = LocationService();
  final TextEditingController _searchController = TextEditingController();

  static Map<int, String> _dayShortLabels = {
    1: AppStrings.dayMonShort,
    2: AppStrings.dayTueShort,
    3: AppStrings.dayWedShort,
    4: AppStrings.dayThuShort,
    5: AppStrings.dayFriShort,
    6: AppStrings.daySatShort,
    7: AppStrings.daySunShort,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(marketProvider.notifier).loadNearby();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _colorFor(MarketCategory category) {
    switch (category) {
      case MarketCategory.supermarket:
        return const Color(0xFF1E88E5);
      case MarketCategory.groceryConvenience:
        return const Color(0xFF00ACC1);
      case MarketCategory.bakery:
        return const Color(0xFF8D6E63);
      case MarketCategory.butcher:
        return const Color(0xFFC2185B);
      case MarketCategory.greengrocer:
        return const Color(0xFF43A047);
      case MarketCategory.weeklyBazaar:
        return const Color(0xFF5E35B1);
    }
  }

  IconData _iconFor(MarketCategory category) {
    switch (category) {
      case MarketCategory.supermarket:
        return Icons.local_grocery_store_rounded;
      case MarketCategory.groceryConvenience:
        return Icons.storefront_rounded;
      case MarketCategory.bakery:
        return Icons.bakery_dining_rounded;
      case MarketCategory.butcher:
        return Icons.kebab_dining_rounded;
      case MarketCategory.greengrocer:
        return Icons.eco_rounded;
      case MarketCategory.weeklyBazaar:
        return Icons.event_rounded;
    }
  }

  String _categoryLabel(MarketCategory category) {
    switch (category) {
      case MarketCategory.supermarket:
        return AppStrings.categorySupermarkets;
      case MarketCategory.groceryConvenience:
        return AppStrings.categoryGroceryConvenience;
      case MarketCategory.bakery:
        return AppStrings.categoryBakeries;
      case MarketCategory.butcher:
        return AppStrings.categoryButchers;
      case MarketCategory.greengrocer:
        return AppStrings.categoryGreengrocers;
      case MarketCategory.weeklyBazaar:
        return AppStrings.categoryWeeklyBazaars;
    }
  }

  String? _scheduleBadge(MarketFacilityModel facility) {
    if (facility.category != MarketCategory.weeklyBazaar) return null;
    if (facility.scheduleDays.isEmpty) {
      return AppStrings.weeklyBazaarFallbackBadge;
    }
    return facility.scheduleDays
        .map((d) => _dayShortLabels[d] ?? '')
        .where((s) => s.isNotEmpty)
        .join(', ');
  }

  Future<void> _openDirections(MarketFacilityModel facility) async {
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(marketProvider);
    final notifier = ref.read(marketProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.nearbyMarketsTitle)),
      body: RefreshIndicator(
        onRefresh: () => notifier.loadNearby(forceRefresh: true),
        child: Column(
          children: [
            _buildFilters(state, notifier),
            if (state.shopsFetchFailed) _buildShopsFailedBanner(),
            Expanded(child: _buildBody(state, notifier)),
          ],
        ),
      ),
    );
  }

  Widget _buildShopsFailedBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFB74D)),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded,
              color: Color(0xFFE65100), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppStrings.shopsPartialFailureMessage,
              style: const TextStyle(fontSize: 14, color: Color(0xFF8D4E00)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(MarketState state, MarketNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: notifier.setSearchQuery,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: AppStrings.searchMarketsHint,
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
                for (final category in MarketCategory.values)
                  _categoryChip(
                      _categoryLabel(category), category, state, notifier),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryChip(String label, MarketCategory? category,
      MarketState state, MarketNotifier notifier) {
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

  Widget _buildBody(MarketState state, MarketNotifier notifier) {
    if (state.isLoading && state.facilities.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 100),
          const Center(child: CircularProgressIndicator()),
          const SizedBox(height: 20),
          Center(
            child: Text(
              AppStrings.locatingMarketsMessage,
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
            AppStrings.noMarketsResultsFound,
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
              '${visible.length} ${AppStrings.marketsResultsFoundLabel}',
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
        final schedule = _scheduleBadge(facility);

        return NearbyPlaceCard(
          icon: _iconFor(facility.category),
          iconBackgroundColor: color.withOpacity(0.15),
          iconColor: color,
          title: facility.name,
          subtitle: facility.displayAddress(),
          statusBadgeText: schedule,
          statusBadgeColor: color,
          distanceLabel: _locationService.formatDistance(item.distanceMeters),
          walkingTimeLabel:
              _locationService.formatWalkingTime(item.distanceMeters),
          isFavorite: notifier.isFavorite(facility.id),
          onFavoriteToggle: () => notifier.toggleFavorite(facility.id),
          onDirectionsPressed: () => _openDirections(facility),
        );
      },
    );
  }
}

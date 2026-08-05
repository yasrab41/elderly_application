import 'package:flutter/material.dart';

import 'package:elderly_prototype_app/core/constants.dart';
import '../bus_stops/screens/bus_stops_screen.dart';

class NearbyServicesHubScreen extends StatelessWidget {
  const NearbyServicesHubScreen({super.key});

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.comingSoonMessage)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.nearbyServicesTitle)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.nearbyServicesHubSubtitle,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            _NearbyServiceButton(
              icon: Icons.directions_bus_filled_rounded,
              label: AppStrings.nearbyBusStopsTitle,
              color: const Color(0xFF2196F3),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BusStopsScreen()),
              ),
            ),
            const SizedBox(height: 18),
            _NearbyServiceButton(
              icon: Icons.local_hospital_rounded,
              label: AppStrings.nearbyHospitalsTitle,
              color: const Color(0xFFE53935),
              enabled: false,
              onTap: () => _showComingSoon(context),
            ),
            const SizedBox(height: 18),
            _NearbyServiceButton(
              icon: Icons.shopping_cart_rounded,
              label: AppStrings.nearbyMarketsTitle,
              color: const Color(0xFF43A047),
              enabled: false,
              onTap: () => _showComingSoon(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _NearbyServiceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool enabled;

  const _NearbyServiceButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? color.withOpacity(0.12) : Colors.grey.shade200,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: enabled ? color : Colors.grey,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: enabled ? Colors.black87 : Colors.black45,
                  ),
                ),
              ),
              if (!enabled)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    AppStrings.comingSoonLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                const Icon(Icons.chevron_right_rounded,
                    color: Colors.black38, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}

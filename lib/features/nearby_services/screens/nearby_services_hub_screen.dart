import 'package:flutter/material.dart';

import 'package:elderly_prototype_app/core/constants.dart';
import '../bus_stops/screens/bus_stops_screen.dart';
import '../healthcare/screens/healthcare_screen.dart';
import '../markets/screens/markets_screen.dart';

class NearbyServicesHubScreen extends StatelessWidget {
  const NearbyServicesHubScreen({super.key});

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
              label: AppStrings.nearbyHealthcareTitle,
              color: const Color(0xFFE53935),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HealthcareScreen()),
              ),
            ),
            const SizedBox(height: 18),
            _NearbyServiceButton(
              icon: Icons.shopping_cart_rounded,
              label: AppStrings.nearbyMarketsTitle,
              color: const Color(0xFF43A047),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MarketsScreen()),
              ),
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

  const _NearbyServiceButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.12),
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
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: Colors.black38, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CampOwnerDashboardScreen extends StatelessWidget {
  const CampOwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Camp Owner Dashboard')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.holiday_village,
                  size: 48,
                  color: isDark ? AppColors.brandDark : AppColors.brand,
                ),
                const SizedBox(height: 16),
                Text(
                  'Welcome, camp owner!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tools for managing your listings, bookings, and guests '
                  'are coming soon.',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

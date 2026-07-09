import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Camper',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.brand,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Discover camps, share your trips, plan your next adventure.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'The camping community app for the Philippines.',
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pushNamed('/register'),
                      child: const Text('Create your account'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                        InkWell(
                          onTap: () => Navigator.of(context).pushNamed('/login'),
                          child: Text(
                            'Log in',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.brand,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: TextButton.icon(
                      key: const Key('previewCampOwnerButton'),
                      onPressed: () =>
                          Navigator.of(context).pushNamed('/owner-home'),
                      icon: const Icon(Icons.construction, size: 16),
                      label: const Text('Preview Camp Owner View (test)'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey,
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

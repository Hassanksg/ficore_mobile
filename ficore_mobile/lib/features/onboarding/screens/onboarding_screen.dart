import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/l10n/app_localizations.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_balance_wallet,
              size: 100,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome to Ficore Africa',
              style: AppTheme.headingLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Your personal finance companion',
              style: AppTheme.bodyLarge.copyWith(
                color: AppTheme.mutedTextColor,
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                // Navigate to login or complete onboarding
              },
              child: Text(l10n.getStarted),
            ),
          ],
        ),
      ),
    );
  }
}
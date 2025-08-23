import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/l10n/app_localizations.dart';

class SetupWizardScreen extends StatelessWidget {
  const SetupWizardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.setupWizard),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppTheme.whiteColor,
      ),
      body: const Center(
        child: Text('Setup Wizard Screen - Coming Soon'),
      ),
    );
  }
}
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/l10n/app_localizations.dart';

class BudgetCreateScreen extends StatelessWidget {
  const BudgetCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createBudget),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppTheme.whiteColor,
      ),
      body: const Center(
        child: Text('Budget Create Screen - Coming Soon'),
      ),
    );
  }
}
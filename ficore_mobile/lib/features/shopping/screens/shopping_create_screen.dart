import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/l10n/app_localizations.dart';

class ShoppingCreateScreen extends StatelessWidget {
  const ShoppingCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createList),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppTheme.whiteColor,
      ),
      body: const Center(
        child: Text('Shopping Create Screen - Coming Soon'),
      ),
    );
  }
}
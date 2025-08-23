import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class BudgetDetailScreen extends StatelessWidget {
  final String budgetId;
  
  const BudgetDetailScreen({
    super.key,
    required this.budgetId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Details'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppTheme.whiteColor,
      ),
      body: Center(
        child: Text('Budget Detail Screen - ID: $budgetId'),
      ),
    );
  }
}
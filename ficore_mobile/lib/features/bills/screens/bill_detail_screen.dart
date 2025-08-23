import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class BillDetailScreen extends StatelessWidget {
  final String billId;
  
  const BillDetailScreen({
    super.key,
    required this.billId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Details'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppTheme.whiteColor,
      ),
      body: Center(
        child: Text('Bill Detail Screen - ID: $billId'),
      ),
    );
  }
}
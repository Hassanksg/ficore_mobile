import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class ShoppingDetailScreen extends StatelessWidget {
  final String listId;
  
  const ShoppingDetailScreen({
    super.key,
    required this.listId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List Details'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppTheme.whiteColor,
      ),
      body: Center(
        child: Text('Shopping Detail Screen - ID: $listId'),
      ),
    );
  }
}
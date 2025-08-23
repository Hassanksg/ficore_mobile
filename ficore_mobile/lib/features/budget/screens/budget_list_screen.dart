import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../providers/budget_provider.dart';

class BudgetListScreen extends StatefulWidget {
  const BudgetListScreen({super.key});

  @override
  State<BudgetListScreen> createState() => _BudgetListScreenState();
}

class _BudgetListScreenState extends State<BudgetListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BudgetProvider>().loadBudgets();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(l10n.budgets),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppTheme.whiteColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Implement filter
            },
          ),
        ],
      ),
      body: Consumer<BudgetProvider>(
        builder: (context, budgetProvider, child) {
          if (budgetProvider.state == BudgetState.loading) {
            return const LoadingWidget(text: 'Loading budgets...');
          }

          if (budgetProvider.state == BudgetState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.dangerColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    budgetProvider.errorMessage ?? 'An error occurred',
                    style: AppTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => budgetProvider.loadBudgets(),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          if (!budgetProvider.hasBudgets) {
            return _buildEmptyState(l10n);
          }

          return RefreshIndicator(
            onRefresh: () => budgetProvider.refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: budgetProvider.budgets.length,
              itemBuilder: (context, index) {
                final budget = budgetProvider.budgets[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: budget.hasSurplus 
                          ? AppTheme.successColor.withOpacity(0.1)
                          : AppTheme.dangerColor.withOpacity(0.1),
                      child: Icon(
                        budget.hasSurplus 
                            ? Icons.trending_up 
                            : Icons.trending_down,
                        color: budget.hasSurplus 
                            ? AppTheme.successColor 
                            : AppTheme.dangerColor,
                      ),
                    ),
                    title: Text(
                      'Budget - ${budget.createdAt.day}/${budget.createdAt.month}/${budget.createdAt.year}',
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Income: ₦${budget.income.toStringAsFixed(2)}'),
                        Text('Expenses: ₦${budget.totalExpenses.toStringAsFixed(2)}'),
                        Text(
                          '${budget.hasSurplus ? 'Surplus' : 'Deficit'}: ₦${budget.surplusDeficit.abs().toStringAsFixed(2)}',
                          style: TextStyle(
                            color: budget.hasSurplus 
                                ? AppTheme.successColor 
                                : AppTheme.dangerColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go('/budgets/${budget.id}'),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                size: 64,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Budgets Yet',
              style: AppTheme.headingMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first budget to start managing your finances effectively.',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.mutedTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go('/budgets/create'),
              icon: const Icon(Icons.add),
              label: Text(l10n.createBudget),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: AppTheme.whiteColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
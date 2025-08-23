import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/l10n/app_localizations.dart';

class MainNavigationScreen extends StatefulWidget {
  final Widget child;

  const MainNavigationScreen({
    super.key,
    required this.child,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  // Navigation items
  static const List<NavigationItem> _navigationItems = [
    NavigationItem(
      route: '/dashboard',
      icon: Icons.dashboard,
      labelKey: 'dashboard',
    ),
    NavigationItem(
      route: '/budgets',
      icon: Icons.account_balance_wallet,
      labelKey: 'budgets',
    ),
    NavigationItem(
      route: '/bills',
      icon: Icons.receipt_long,
      labelKey: 'bills',
    ),
    NavigationItem(
      route: '/shopping',
      icon: Icons.shopping_cart,
      labelKey: 'shopping',
    ),
    NavigationItem(
      route: '/profile',
      icon: Icons.person,
      labelKey: 'profile',
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateSelectedIndex();
  }

  void _updateSelectedIndex() {
    final location = GoRouterState.of(context).uri.path;
    
    for (int i = 0; i < _navigationItems.length; i++) {
      if (location.startsWith(_navigationItems[i].route)) {
        if (_selectedIndex != i) {
          setState(() {
            _selectedIndex = i;
          });
        }
        break;
      }
    }
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });
      context.go(_navigationItems[index].route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: AppTheme.whiteColor,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: AppTheme.mutedTextColor,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 0,
          items: _navigationItems.map((item) {
            return BottomNavigationBarItem(
              icon: Icon(item.icon),
              activeIcon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.icon,
                  color: AppTheme.primaryColor,
                ),
              ),
              label: _getLocalizedLabel(l10n, item.labelKey),
            );
          }).toList(),
        ),
      ),
      floatingActionButton: _shouldShowFAB() ? _buildFloatingActionButton(context) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  bool _shouldShowFAB() {
    // Show FAB on specific screens where quick actions are useful
    return _selectedIndex == 1 || _selectedIndex == 2 || _selectedIndex == 3; // Budgets, Bills, Shopping
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    IconData icon;
    String tooltip;
    VoidCallback onPressed;

    switch (_selectedIndex) {
      case 1: // Budgets
        icon = Icons.add_chart;
        tooltip = l10n.createBudget;
        onPressed = () => context.go('/budgets/create');
        break;
      case 2: // Bills
        icon = Icons.add_box;
        tooltip = l10n.createBill;
        onPressed = () => context.go('/bills/create');
        break;
      case 3: // Shopping
        icon = Icons.add_shopping_cart;
        tooltip = l10n.createList;
        onPressed = () => context.go('/shopping/create');
        break;
      default:
        icon = Icons.add;
        tooltip = l10n.add;
        onPressed = () {};
    }

    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: AppTheme.accentColor,
      foregroundColor: AppTheme.whiteColor,
      elevation: 4,
      child: Icon(icon),
    );
  }

  String _getLocalizedLabel(AppLocalizations l10n, String labelKey) {
    switch (labelKey) {
      case 'dashboard':
        return l10n.dashboard;
      case 'budgets':
        return l10n.budgets;
      case 'bills':
        return l10n.bills;
      case 'shopping':
        return l10n.shopping;
      case 'profile':
        return l10n.profile;
      default:
        return labelKey;
    }
  }
}

class NavigationItem {
  final String route;
  final IconData icon;
  final String labelKey;

  const NavigationItem({
    required this.route,
    required this.icon,
    required this.labelKey,
  });
}
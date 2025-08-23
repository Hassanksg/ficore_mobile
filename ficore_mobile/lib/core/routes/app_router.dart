import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/setup_wizard_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/budget/screens/budget_list_screen.dart';
import '../../features/budget/screens/budget_create_screen.dart';
import '../../features/budget/screens/budget_detail_screen.dart';
import '../../features/bills/screens/bill_list_screen.dart';
import '../../features/bills/screens/bill_create_screen.dart';
import '../../features/bills/screens/bill_detail_screen.dart';
import '../../features/shopping/screens/shopping_list_screen.dart';
import '../../features/shopping/screens/shopping_create_screen.dart';
import '../../features/shopping/screens/shopping_detail_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/settings_screen.dart';
import '../../features/credits/screens/credits_screen.dart';
import '../../shared/screens/splash_screen.dart';
import '../../shared/screens/main_navigation_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    redirect: _redirect,
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Authentication Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/setup',
        name: 'setup',
        builder: (context, state) => const SetupWizardScreen(),
      ),

      // Main App Shell with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) {
          return MainNavigationScreen(child: child);
        },
        routes: [
          // Dashboard
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),

          // Budget Routes
          GoRoute(
            path: '/budgets',
            name: 'budgets',
            builder: (context, state) => const BudgetListScreen(),
            routes: [
              GoRoute(
                path: '/create',
                name: 'budget-create',
                builder: (context, state) => const BudgetCreateScreen(),
              ),
              GoRoute(
                path: '/:id',
                name: 'budget-detail',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return BudgetDetailScreen(budgetId: id);
                },
              ),
            ],
          ),

          // Bills Routes
          GoRoute(
            path: '/bills',
            name: 'bills',
            builder: (context, state) => const BillListScreen(),
            routes: [
              GoRoute(
                path: '/create',
                name: 'bill-create',
                builder: (context, state) => const BillCreateScreen(),
              ),
              GoRoute(
                path: '/:id',
                name: 'bill-detail',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return BillDetailScreen(billId: id);
                },
              ),
            ],
          ),

          // Shopping Routes
          GoRoute(
            path: '/shopping',
            name: 'shopping',
            builder: (context, state) => const ShoppingListScreen(),
            routes: [
              GoRoute(
                path: '/create',
                name: 'shopping-create',
                builder: (context, state) => const ShoppingCreateScreen(),
              ),
              GoRoute(
                path: '/:id',
                name: 'shopping-detail',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return ShoppingDetailScreen(listId: id);
                },
              ),
            ],
          ),

          // Profile Routes
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: '/settings',
                name: 'settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),

          // Credits
          GoRoute(
            path: '/credits',
            name: 'credits',
            builder: (context, state) => const CreditsScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.error?.toString() ?? 'Unknown error',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    ),
  );

  // Route redirection logic
  static String? _redirect(BuildContext context, GoRouterState state) {
    final authProvider = context.read<AuthProvider>();
    final location = state.uri.path;

    // Handle splash screen
    if (location == '/splash') {
      return null; // Allow splash screen
    }

    // Check authentication state
    switch (authProvider.state) {
      case AuthState.initial:
      case AuthState.loading:
        // Still loading, stay on splash
        if (location != '/splash') {
          return '/splash';
        }
        return null;

      case AuthState.unauthenticated:
        // Not authenticated, redirect to auth flow
        if (_isAuthRoute(location)) {
          return null; // Allow auth routes
        }
        return '/login';

      case AuthState.authenticated:
        // Authenticated user
        final user = authProvider.user;
        if (user == null) {
          return '/login';
        }

        // Check if user needs to complete setup
        if (!user.setupComplete) {
          if (location != '/setup') {
            return '/setup';
          }
          return null;
        }

        // Redirect from auth routes to dashboard
        if (_isAuthRoute(location) || location == '/splash') {
          return '/dashboard';
        }

        return null; // Allow all other routes

      case AuthState.error:
        // Error state, redirect to login
        if (!_isAuthRoute(location)) {
          return '/login';
        }
        return null;
    }
  }

  // Check if the route is an authentication route
  static bool _isAuthRoute(String location) {
    return location.startsWith('/login') ||
           location.startsWith('/register') ||
           location.startsWith('/forgot-password') ||
           location.startsWith('/onboarding');
  }

  // Navigation helpers
  static void goToLogin(BuildContext context) {
    context.go('/login');
  }

  static void goToRegister(BuildContext context) {
    context.go('/register');
  }

  static void goToDashboard(BuildContext context) {
    context.go('/dashboard');
  }

  static void goToBudgets(BuildContext context) {
    context.go('/budgets');
  }

  static void goToBills(BuildContext context) {
    context.go('/bills');
  }

  static void goToShopping(BuildContext context) {
    context.go('/shopping');
  }

  static void goToProfile(BuildContext context) {
    context.go('/profile');
  }

  static void goToSettings(BuildContext context) {
    context.go('/profile/settings');
  }

  static void goToCredits(BuildContext context) {
    context.go('/credits');
  }

  // Create new item routes
  static void goToCreateBudget(BuildContext context) {
    context.go('/budgets/create');
  }

  static void goToCreateBill(BuildContext context) {
    context.go('/bills/create');
  }

  static void goToCreateShopping(BuildContext context) {
    context.go('/shopping/create');
  }

  // Detail routes
  static void goToBudgetDetail(BuildContext context, String budgetId) {
    context.go('/budgets/$budgetId');
  }

  static void goToBillDetail(BuildContext context, String billId) {
    context.go('/bills/$billId');
  }

  static void goToShoppingDetail(BuildContext context, String listId) {
    context.go('/shopping/$listId');
  }

  // Back navigation
  static void goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/dashboard');
    }
  }

  // Replace current route
  static void replace(BuildContext context, String location) {
    context.pushReplacement(location);
  }

  // Push new route
  static void push(BuildContext context, String location) {
    context.push(location);
  }
}
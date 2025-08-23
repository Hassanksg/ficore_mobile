import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'core/services/api_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/storage_service.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/language_provider.dart';
import 'core/providers/theme_provider.dart';
import 'features/budget/providers/budget_provider.dart';
import 'features/bills/providers/bill_provider.dart';
import 'features/shopping/providers/shopping_provider.dart';
import 'core/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await StorageService.init();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(const FicoreApp());
}

class FicoreApp extends StatelessWidget {
  const FicoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Core providers
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        
        // Service providers
        Provider<ApiService>(create: (_) => ApiService()),
        Provider<AuthService>(
          create: (context) => AuthService(
            apiService: context.read<ApiService>(),
          ),
        ),
        
        // Feature providers
        ChangeNotifierProxyProvider<AuthService, AuthProvider>(
          create: (context) => AuthProvider(context.read<AuthService>()),
          update: (context, authService, previous) =>
              previous ?? AuthProvider(authService),
        ),
        
        ChangeNotifierProxyProvider<ApiService, BudgetProvider>(
          create: (context) => BudgetProvider(context.read<ApiService>()),
          update: (context, apiService, previous) =>
              previous ?? BudgetProvider(apiService),
        ),
        
        ChangeNotifierProxyProvider<ApiService, BillProvider>(
          create: (context) => BillProvider(context.read<ApiService>()),
          update: (context, apiService, previous) =>
              previous ?? BillProvider(apiService),
        ),
        
        ChangeNotifierProxyProvider<ApiService, ShoppingProvider>(
          create: (context) => ShoppingProvider(context.read<ApiService>()),
          update: (context, apiService, previous) =>
              previous ?? ShoppingProvider(apiService),
        ),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, child) {
          return MaterialApp.router(
            title: AppConfig.appName,
            debugShowCheckedModeBanner: false,
            
            // Theme configuration
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            
            // Localization
            locale: languageProvider.currentLocale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            
            // Routing
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
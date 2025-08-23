class AppConfig {
  static const String appName = 'Ficore Africa';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String baseUrl = 'https://ficore-mobile-app.onrender.com'; // Replace with your actual Render URL
  static const String apiVersion = 'v1';
  
  // Ficore Brand Colors
  static const int primaryColorValue = 0xFF1E3A8A; // Deep Blue
  static const int accentColorValue = 0xFFD4AF37;  // Rich Gold
  static const int backgroundColorValue = 0xFFFFF8F0; // Soft Cream
  static const int cardBackgroundColorValue = 0xFFB0DAFF; // Muted Blue
  static const int textColorValue = 0xFF2E2E2E; // Dark Gray
  static const int mutedTextColorValue = 0xFF6B7280; // Gray
  static const int dangerColorValue = 0xFFDC2626; // Red
  static const int successColorValue = 0xFF16A34A; // Green
  static const int warningColorValue = 0xFFF97316; // Orange
  
  // Session Configuration
  static const Duration sessionTimeout = Duration(minutes: 30);
  static const String sessionKey = 'ficore_session';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String languageKey = 'selected_language';
  static const String themeKey = 'theme_mode';
  static const String creditsKey = 'ficore_credits';
  
  // Default Values
  static const String defaultLanguage = 'en';
  static const int defaultCredits = 10;
  
  // API Endpoints
  static const String loginEndpoint = '/users/login';
  static const String signupEndpoint = '/users/signup';
  static const String logoutEndpoint = '/users/logout';
  static const String profileEndpoint = '/users/profile';
  
  // Budget Endpoints
  static const String budgetEndpoint = '/budget';
  static const String budgetNewEndpoint = '/budget/new';
  static const String budgetDashboardEndpoint = '/budget/dashboard';
  
  // Bill Endpoints
  static const String billEndpoint = '/bills';
  static const String billNewEndpoint = '/bills/new';
  static const String billDashboardEndpoint = '/bills/dashboard';
  
  // Shopping Endpoints
  static const String shoppingEndpoint = '/shopping';
  static const String shoppingNewEndpoint = '/shopping/new';
  static const String shoppingDashboardEndpoint = '/shopping/dashboard';
  
  // Credits Endpoints
  static const String creditsEndpoint = '/credits';
  static const String creditsTransactionsEndpoint = '/credits/transactions';
  
  // Reports Endpoints
  static const String reportsEndpoint = '/reports';
  static const String exportPdfEndpoint = '/reports/export/pdf';
  
  // Validation Rules
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 50;
  static const double maxBudgetAmount = 10000000000;
  static const double minBudgetAmount = 0.01;
  static const int maxCustomCategories = 20;
  
  // Network Configuration
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Cache Configuration
  static const Duration cacheExpiry = Duration(hours: 1);
  static const int maxCacheSize = 100;
  
  // Feature Flags
  static const bool enableBiometrics = true;
  static const bool enablePushNotifications = true;
  static const bool enableOfflineMode = true;
  static const bool enableAnalytics = false; // Set to false for privacy
  
  // Environment
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
  static const bool enableLogging = !isProduction;
}
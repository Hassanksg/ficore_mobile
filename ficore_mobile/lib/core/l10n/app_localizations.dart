import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ha'),
  ];

  // Common/General translations
  String get appName => _getValue('app_name');
  String get welcome => _getValue('welcome');
  String get login => _getValue('login');
  String get register => _getValue('register');
  String get logout => _getValue('logout');
  String get email => _getValue('email');
  String get password => _getValue('password');
  String get confirmPassword => _getValue('confirm_password');
  String get username => _getValue('username');
  String get firstName => _getValue('first_name');
  String get lastName => _getValue('last_name');
  String get phoneNumber => _getValue('phone_number');
  String get address => _getValue('address');
  String get save => _getValue('save');
  String get cancel => _getValue('cancel');
  String get delete => _getValue('delete');
  String get edit => _getValue('edit');
  String get add => _getValue('add');
  String get create => _getValue('create');
  String get update => _getValue('update');
  String get submit => _getValue('submit');
  String get loading => _getValue('loading');
  String get error => _getValue('error');
  String get success => _getValue('success');
  String get warning => _getValue('warning');
  String get info => _getValue('info');
  String get ok => _getValue('ok');
  String get yes => _getValue('yes');
  String get no => _getValue('no');
  String get back => _getValue('back');
  String get next => _getValue('next');
  String get previous => _getValue('previous');
  String get finish => _getValue('finish');
  String get skip => _getValue('skip');
  String get retry => _getValue('retry');
  String get refresh => _getValue('refresh');
  String get search => _getValue('search');
  String get filter => _getValue('filter');
  String get sort => _getValue('sort');
  String get settings => _getValue('settings');
  String get profile => _getValue('profile');
  String get dashboard => _getValue('dashboard');
  String get home => _getValue('home');
  String get language => _getValue('language');
  String get theme => _getValue('theme');
  String get darkMode => _getValue('dark_mode');
  String get lightMode => _getValue('light_mode');
  String get systemMode => _getValue('system_mode');

  // Navigation
  String get budgets => _getValue('budgets');
  String get bills => _getValue('bills');
  String get shopping => _getValue('shopping');
  String get credits => _getValue('credits');

  // Budget translations
  String get budgetPlanner => _getValue('budget_planner');
  String get monthlyIncome => _getValue('monthly_income');
  String get totalExpenses => _getValue('total_expenses');
  String get savingsGoal => _getValue('savings_goal');
  String get surplus => _getValue('surplus');
  String get deficit => _getValue('deficit');
  String get housing => _getValue('housing');
  String get food => _getValue('food');
  String get transport => _getValue('transport');
  String get miscellaneous => _getValue('miscellaneous');
  String get others => _getValue('others');
  String get customCategories => _getValue('custom_categories');
  String get categoryName => _getValue('category_name');
  String get amount => _getValue('amount');
  String get createBudget => _getValue('create_budget');
  String get editBudget => _getValue('edit_budget');
  String get deleteBudget => _getValue('delete_budget');
  String get budgetCreated => _getValue('budget_created');
  String get budgetUpdated => _getValue('budget_updated');
  String get budgetDeleted => _getValue('budget_deleted');

  // Bill translations
  String get billTracker => _getValue('bill_tracker');
  String get billName => _getValue('bill_name');
  String get dueDate => _getValue('due_date');
  String get frequency => _getValue('frequency');
  String get category => _getValue('category');
  String get status => _getValue('status');
  String get pending => _getValue('pending');
  String get paid => _getValue('paid');
  String get overdue => _getValue('overdue');
  String get oneTime => _getValue('one_time');
  String get weekly => _getValue('weekly');
  String get monthly => _getValue('monthly');
  String get quarterly => _getValue('quarterly');
  String get utilities => _getValue('utilities');
  String get rent => _getValue('rent');
  String get dataInternet => _getValue('data_internet');
  String get ajoEsusuAdashe => _getValue('ajo_esusu_adashe');
  String get clothing => _getValue('clothing');
  String get education => _getValue('education');
  String get healthcare => _getValue('healthcare');
  String get entertainment => _getValue('entertainment');
  String get airtime => _getValue('airtime');
  String get schoolFees => _getValue('school_fees');
  String get savingsInvestments => _getValue('savings_investments');
  String get createBill => _getValue('create_bill');
  String get editBill => _getValue('edit_bill');
  String get deleteBill => _getValue('delete_bill');
  String get billCreated => _getValue('bill_created');
  String get billUpdated => _getValue('bill_updated');
  String get billDeleted => _getValue('bill_deleted');
  String get markAsPaid => _getValue('mark_as_paid');
  String get markAsPending => _getValue('mark_as_pending');

  // Shopping translations
  String get shoppingLists => _getValue('shopping_lists');
  String get listName => _getValue('list_name');
  String get budget => _getValue('budget');
  String get totalSpent => _getValue('total_spent');
  String get remaining => _getValue('remaining');
  String get itemName => _getValue('item_name');
  String get quantity => _getValue('quantity');
  String get price => _getValue('price');
  String get unit => _getValue('unit');
  String get store => _getValue('store');
  String get toBuy => _getValue('to_buy');
  String get bought => _getValue('bought');
  String get fruits => _getValue('fruits');
  String get vegetables => _getValue('vegetables');
  String get dairy => _getValue('dairy');
  String get meat => _getValue('meat');
  String get grains => _getValue('grains');
  String get beverages => _getValue('beverages');
  String get household => _getValue('household');
  String get piece => _getValue('piece');
  String get carton => _getValue('carton');
  String get kilogram => _getValue('kilogram');
  String get liter => _getValue('liter');
  String get pack => _getValue('pack');
  String get other => _getValue('other');
  String get createList => _getValue('create_list');
  String get editList => _getValue('edit_list');
  String get deleteList => _getValue('delete_list');
  String get addItem => _getValue('add_item');
  String get editItem => _getValue('edit_item');
  String get deleteItem => _getValue('delete_item');
  String get listCreated => _getValue('list_created');
  String get listUpdated => _getValue('list_updated');
  String get listDeleted => _getValue('list_deleted');
  String get itemAdded => _getValue('item_added');
  String get itemUpdated => _getValue('item_updated');
  String get itemDeleted => _getValue('item_deleted');

  // Credits translations
  String get ficoreCredits => _getValue('ficore_credits');
  String get currentBalance => _getValue('current_balance');
  String get transactionHistory => _getValue('transaction_history');
  String get topUp => _getValue('top_up');
  String get insufficientCredits => _getValue('insufficient_credits');
  String get creditsDeducted => _getValue('credits_deducted');
  String get creditsAdded => _getValue('credits_added');

  // Error messages
  String get networkError => _getValue('network_error');
  String get serverError => _getValue('server_error');
  String get unknownError => _getValue('unknown_error');
  String get validationError => _getValue('validation_error');
  String get authenticationError => _getValue('authentication_error');
  String get permissionDenied => _getValue('permission_denied');
  String get notFound => _getValue('not_found');
  String get timeout => _getValue('timeout');

  // Validation messages
  String get fieldRequired => _getValue('field_required');
  String get invalidEmail => _getValue('invalid_email');
  String get passwordTooShort => _getValue('password_too_short');
  String get passwordsDoNotMatch => _getValue('passwords_do_not_match');
  String get invalidPhoneNumber => _getValue('invalid_phone_number');
  String get invalidAmount => _getValue('invalid_amount');
  String get amountTooLarge => _getValue('amount_too_large');
  String get amountTooSmall => _getValue('amount_too_small');

  // Success messages
  String get loginSuccessful => _getValue('login_successful');
  String get registrationSuccessful => _getValue('registration_successful');
  String get profileUpdated => _getValue('profile_updated');
  String get passwordChanged => _getValue('password_changed');
  String get settingsSaved => _getValue('settings_saved');

  // Onboarding
  String get getStarted => _getValue('get_started');
  String get onboardingTitle1 => _getValue('onboarding_title_1');
  String get onboardingDesc1 => _getValue('onboarding_desc_1');
  String get onboardingTitle2 => _getValue('onboarding_title_2');
  String get onboardingDesc2 => _getValue('onboarding_desc_2');
  String get onboardingTitle3 => _getValue('onboarding_title_3');
  String get onboardingDesc3 => _getValue('onboarding_desc_3');

  // Setup wizard
  String get setupWizard => _getValue('setup_wizard');
  String get personalInformation => _getValue('personal_information');
  String get preferences => _getValue('preferences');
  String get termsAndConditions => _getValue('terms_and_conditions');
  String get acceptTerms => _getValue('accept_terms');
  String get setupComplete => _getValue('setup_complete');

  // Get translation value based on locale
  String _getValue(String key) {
    final translations = _getTranslations();
    return translations[key] ?? key;
  }

  // Get translations map based on current locale
  Map<String, String> _getTranslations() {
    switch (locale.languageCode) {
      case 'ha':
        return _hausaTranslations;
      case 'en':
      default:
        return _englishTranslations;
    }
  }

  // English translations
  static const Map<String, String> _englishTranslations = {
    // Common/General
    'app_name': 'Ficore Africa',
    'welcome': 'Welcome',
    'login': 'Login',
    'register': 'Register',
    'logout': 'Logout',
    'email': 'Email',
    'password': 'Password',
    'confirm_password': 'Confirm Password',
    'username': 'Username',
    'first_name': 'First Name',
    'last_name': 'Last Name',
    'phone_number': 'Phone Number',
    'address': 'Address',
    'save': 'Save',
    'cancel': 'Cancel',
    'delete': 'Delete',
    'edit': 'Edit',
    'add': 'Add',
    'create': 'Create',
    'update': 'Update',
    'submit': 'Submit',
    'loading': 'Loading...',
    'error': 'Error',
    'success': 'Success',
    'warning': 'Warning',
    'info': 'Info',
    'ok': 'OK',
    'yes': 'Yes',
    'no': 'No',
    'back': 'Back',
    'next': 'Next',
    'previous': 'Previous',
    'finish': 'Finish',
    'skip': 'Skip',
    'retry': 'Retry',
    'refresh': 'Refresh',
    'search': 'Search',
    'filter': 'Filter',
    'sort': 'Sort',
    'settings': 'Settings',
    'profile': 'Profile',
    'dashboard': 'Dashboard',
    'home': 'Home',
    'language': 'Language',
    'theme': 'Theme',
    'dark_mode': 'Dark Mode',
    'light_mode': 'Light Mode',
    'system_mode': 'System Mode',

    // Navigation
    'budgets': 'Budgets',
    'bills': 'Bills',
    'shopping': 'Shopping',
    'credits': 'Credits',

    // Budget
    'budget_planner': 'Budget Planner',
    'monthly_income': 'Monthly Income',
    'total_expenses': 'Total Expenses',
    'savings_goal': 'Savings Goal',
    'surplus': 'Surplus',
    'deficit': 'Deficit',
    'housing': 'Housing/Rent',
    'food': 'Food',
    'transport': 'Transport',
    'miscellaneous': 'Miscellaneous',
    'others': 'Others',
    'custom_categories': 'Custom Categories',
    'category_name': 'Category Name',
    'amount': 'Amount',
    'create_budget': 'Create Budget',
    'edit_budget': 'Edit Budget',
    'delete_budget': 'Delete Budget',
    'budget_created': 'Budget created successfully',
    'budget_updated': 'Budget updated successfully',
    'budget_deleted': 'Budget deleted successfully',

    // Bills
    'bill_tracker': 'Bill Tracker',
    'bill_name': 'Bill Name',
    'due_date': 'Due Date',
    'frequency': 'Frequency',
    'category': 'Category',
    'status': 'Status',
    'pending': 'Pending',
    'paid': 'Paid',
    'overdue': 'Overdue',
    'one_time': 'One Time',
    'weekly': 'Weekly',
    'monthly': 'Monthly',
    'quarterly': 'Quarterly',
    'utilities': 'Utilities',
    'rent': 'Rent',
    'data_internet': 'Data/Internet',
    'ajo_esusu_adashe': 'Ajo/Esusu/Adashe',
    'clothing': 'Clothing',
    'education': 'Education',
    'healthcare': 'Healthcare',
    'entertainment': 'Entertainment',
    'airtime': 'Airtime',
    'school_fees': 'School Fees',
    'savings_investments': 'Savings/Investments',
    'create_bill': 'Create Bill',
    'edit_bill': 'Edit Bill',
    'delete_bill': 'Delete Bill',
    'bill_created': 'Bill created successfully',
    'bill_updated': 'Bill updated successfully',
    'bill_deleted': 'Bill deleted successfully',
    'mark_as_paid': 'Mark as Paid',
    'mark_as_pending': 'Mark as Pending',

    // Shopping
    'shopping_lists': 'Shopping Lists',
    'list_name': 'List Name',
    'budget': 'Budget',
    'total_spent': 'Total Spent',
    'remaining': 'Remaining',
    'item_name': 'Item Name',
    'quantity': 'Quantity',
    'price': 'Price',
    'unit': 'Unit',
    'store': 'Store',
    'to_buy': 'To Buy',
    'bought': 'Bought',
    'fruits': 'Fruits',
    'vegetables': 'Vegetables',
    'dairy': 'Dairy',
    'meat': 'Meat',
    'grains': 'Grains',
    'beverages': 'Beverages',
    'household': 'Household',
    'piece': 'Piece',
    'carton': 'Carton',
    'kilogram': 'Kilogram',
    'liter': 'Liter',
    'pack': 'Pack',
    'other': 'Other',
    'create_list': 'Create List',
    'edit_list': 'Edit List',
    'delete_list': 'Delete List',
    'add_item': 'Add Item',
    'edit_item': 'Edit Item',
    'delete_item': 'Delete Item',
    'list_created': 'List created successfully',
    'list_updated': 'List updated successfully',
    'list_deleted': 'List deleted successfully',
    'item_added': 'Item added successfully',
    'item_updated': 'Item updated successfully',
    'item_deleted': 'Item deleted successfully',

    // Credits
    'ficore_credits': 'Ficore Credits',
    'current_balance': 'Current Balance',
    'transaction_history': 'Transaction History',
    'top_up': 'Top Up',
    'insufficient_credits': 'Insufficient credits',
    'credits_deducted': 'Credits deducted',
    'credits_added': 'Credits added',

    // Errors
    'network_error': 'Network error. Please check your connection.',
    'server_error': 'Server error. Please try again later.',
    'unknown_error': 'An unknown error occurred.',
    'validation_error': 'Please check your input.',
    'authentication_error': 'Authentication failed.',
    'permission_denied': 'Permission denied.',
    'not_found': 'Resource not found.',
    'timeout': 'Request timeout.',

    // Validation
    'field_required': 'This field is required',
    'invalid_email': 'Please enter a valid email',
    'password_too_short': 'Password must be at least 6 characters',
    'passwords_do_not_match': 'Passwords do not match',
    'invalid_phone_number': 'Please enter a valid phone number',
    'invalid_amount': 'Please enter a valid amount',
    'amount_too_large': 'Amount is too large',
    'amount_too_small': 'Amount is too small',

    // Success
    'login_successful': 'Login successful',
    'registration_successful': 'Registration successful',
    'profile_updated': 'Profile updated successfully',
    'password_changed': 'Password changed successfully',
    'settings_saved': 'Settings saved successfully',

    // Onboarding
    'get_started': 'Get Started',
    'onboarding_title_1': 'Manage Your Budget',
    'onboarding_desc_1': 'Create and track your monthly budgets with custom categories.',
    'onboarding_title_2': 'Track Your Bills',
    'onboarding_desc_2': 'Never miss a payment with our bill reminder system.',
    'onboarding_title_3': 'Plan Your Shopping',
    'onboarding_desc_3': 'Create shopping lists and track your spending.',

    // Setup
    'setup_wizard': 'Setup Wizard',
    'personal_information': 'Personal Information',
    'preferences': 'Preferences',
    'terms_and_conditions': 'Terms and Conditions',
    'accept_terms': 'I accept the terms and conditions',
    'setup_complete': 'Setup Complete',
  };

  // Hausa translations
  static const Map<String, String> _hausaTranslations = {
    // Common/General
    'app_name': 'Ficore Africa',
    'welcome': 'Maraba',
    'login': 'Shiga',
    'register': 'Yi Rajista',
    'logout': 'Fita',
    'email': 'Imel',
    'password': 'Kalmar Sirri',
    'confirm_password': 'Tabbatar da Kalmar Sirri',
    'username': 'Sunan Mai Amfani',
    'first_name': 'Suna na Farko',
    'last_name': 'Suna na Ƙarshe',
    'phone_number': 'Lambar Waya',
    'address': 'Adireshi',
    'save': 'Ajiye',
    'cancel': 'Soke',
    'delete': 'Share',
    'edit': 'Gyara',
    'add': 'Ƙara',
    'create': 'Ƙirƙira',
    'update': 'Sabunta',
    'submit': 'Aika',
    'loading': 'Ana Loda...',
    'error': 'Kuskure',
    'success': 'Nasara',
    'warning': 'Gargaɗi',
    'info': 'Bayani',
    'ok': 'To',
    'yes': 'Eh',
    'no': 'A\'a',
    'back': 'Komawa',
    'next': 'Na Gaba',
    'previous': 'Na Baya',
    'finish': 'Gama',
    'skip': 'Tsallake',
    'retry': 'Sake Gwadawa',
    'refresh': 'Sabunta',
    'search': 'Nema',
    'filter': 'Tace',
    'sort': 'Jera',
    'settings': 'Saitunan',
    'profile': 'Bayanan Sirri',
    'dashboard': 'Allon Baya',
    'home': 'Gida',
    'language': 'Harshe',
    'theme': 'Kalar App',
    'dark_mode': 'Yanayin Duhu',
    'light_mode': 'Yanayin Haske',
    'system_mode': 'Yanayin Tsarin',

    // Navigation
    'budgets': 'Kasafin Kuɗi',
    'bills': 'Lissafin Kuɗi',
    'shopping': 'Siyayya',
    'credits': 'Ficore Credits',

    // Budget
    'budget_planner': 'Tsarin Kasafin Kuɗi',
    'monthly_income': 'Kuɗin Shiga na Wata',
    'total_expenses': 'Jimlar Kashe Kuɗi',
    'savings_goal': 'Manufar Ajiya',
    'surplus': 'Ragi',
    'deficit': 'Rashi',
    'housing': 'Gida/Haya',
    'food': 'Abinci',
    'transport': 'Sufuri',
    'miscellaneous': 'Daban-daban',
    'others': 'Wasu',
    'custom_categories': 'Nau\'ikan da Ka Ƙirƙira',
    'category_name': 'Sunan Nau\'i',
    'amount': 'Adadi',
    'create_budget': 'Ƙirƙiri Kasafin Kuɗi',
    'edit_budget': 'Gyara Kasafin Kuɗi',
    'delete_budget': 'Share Kasafin Kuɗi',
    'budget_created': 'An ƙirƙiri kasafin kuɗi da nasara',
    'budget_updated': 'An sabunta kasafin kuɗi da nasara',
    'budget_deleted': 'An share kasafin kuɗi da nasara',

    // Bills
    'bill_tracker': 'Bin Lissafin Kuɗi',
    'bill_name': 'Sunan Lissafi',
    'due_date': 'Ranar Biya',
    'frequency': 'Yawan Biya',
    'category': 'Nau\'i',
    'status': 'Matsayi',
    'pending': 'Ana Jira',
    'paid': 'An Biya',
    'overdue': 'Ya Wuce Lokaci',
    'one_time': 'Sau Ɗaya',
    'weekly': 'Mako-mako',
    'monthly': 'Wata-wata',
    'quarterly': 'Kwata-kwata',
    'utilities': 'Ayyukan Jama\'a',
    'rent': 'Haya',
    'data_internet': 'Data/Intanet',
    'ajo_esusu_adashe': 'Ajo/Esusu/Adashe',
    'clothing': 'Tufafi',
    'education': 'Ilimi',
    'healthcare': 'Lafiya',
    'entertainment': 'Nishaɗi',
    'airtime': 'Katin Waya',
    'school_fees': 'Kuɗin Makaranta',
    'savings_investments': 'Ajiya/Saka Hannun Jari',
    'create_bill': 'Ƙirƙiri Lissafi',
    'edit_bill': 'Gyara Lissafi',
    'delete_bill': 'Share Lissafi',
    'bill_created': 'An ƙirƙiri lissafi da nasara',
    'bill_updated': 'An sabunta lissafi da nasara',
    'bill_deleted': 'An share lissafi da nasara',
    'mark_as_paid': 'Yi Alama da An Biya',
    'mark_as_pending': 'Yi Alama da Ana Jira',

    // Shopping
    'shopping_lists': 'Lissafin Siyayya',
    'list_name': 'Sunan Lissafi',
    'budget': 'Kasafin Kuɗi',
    'total_spent': 'Jimlar Abin da Aka Kashe',
    'remaining': 'Abin da Ya Rage',
    'item_name': 'Sunan Abu',
    'quantity': 'Yawan',
    'price': 'Farashi',
    'unit': 'Naúrar',
    'store': 'Shago',
    'to_buy': 'Za a Saya',
    'bought': 'An Saya',
    'fruits': 'Ƴan Itace',
    'vegetables': 'Kayan Lambu',
    'dairy': 'Kayan Madara',
    'meat': 'Nama',
    'grains': 'Hatsi',
    'beverages': 'Abubuwan Sha',
    'household': 'Kayan Gida',
    'piece': 'Guda',
    'carton': 'Akwati',
    'kilogram': 'Kilo',
    'liter': 'Lita',
    'pack': 'Fakiti',
    'other': 'Wani',
    'create_list': 'Ƙirƙiri Lissafi',
    'edit_list': 'Gyara Lissafi',
    'delete_list': 'Share Lissafi',
    'add_item': 'Ƙara Abu',
    'edit_item': 'Gyara Abu',
    'delete_item': 'Share Abu',
    'list_created': 'An ƙirƙiri lissafi da nasara',
    'list_updated': 'An sabunta lissafi da nasara',
    'list_deleted': 'An share lissafi da nasara',
    'item_added': 'An ƙara abu da nasara',
    'item_updated': 'An sabunta abu da nasara',
    'item_deleted': 'An share abu da nasara',

    // Credits
    'ficore_credits': 'Ficore Credits',
    'current_balance': 'Ma\'auni na Yanzu',
    'transaction_history': 'Tarihin Ciniki',
    'top_up': 'Ƙara Kuɗi',
    'insufficient_credits': 'Credits ba su isa ba',
    'credits_deducted': 'An cire credits',
    'credits_added': 'An ƙara credits',

    // Errors
    'network_error': 'Kuskuren hanyar sadarwa. Ka duba haɗin ka.',
    'server_error': 'Kuskuren sabar. Ka sake gwadawa daga baya.',
    'unknown_error': 'Kuskure da ba a sani ba ya faru.',
    'validation_error': 'Ka duba abin da ka shigar.',
    'authentication_error': 'Shiga ya kasa.',
    'permission_denied': 'An hana izini.',
    'not_found': 'Ba a sami abin da ake nema ba.',
    'timeout': 'Lokacin buƙata ya ƙare.',

    // Validation
    'field_required': 'Ana buƙatar wannan fili',
    'invalid_email': 'Ka shigar da ingantaccen imel',
    'password_too_short': 'Kalmar sirri ta kasance aƙalla haruffa 6',
    'passwords_do_not_match': 'Kalmomin sirri ba su dace ba',
    'invalid_phone_number': 'Ka shigar da ingantacciyar lambar waya',
    'invalid_amount': 'Ka shigar da ingantaccen adadi',
    'amount_too_large': 'Adadin ya yi yawa',
    'amount_too_small': 'Adadin ya yi ƙanƙanta',

    // Success
    'login_successful': 'Shiga ya yi nasara',
    'registration_successful': 'Rajista ya yi nasara',
    'profile_updated': 'An sabunta bayanan sirri da nasara',
    'password_changed': 'An canza kalmar sirri da nasara',
    'settings_saved': 'An ajiye saitunan da nasara',

    // Onboarding
    'get_started': 'Fara',
    'onboarding_title_1': 'Sarrafa Kasafin Kuɗinka',
    'onboarding_desc_1': 'Ƙirƙiri kuma ka bi kasafin kuɗin wata tare da nau\'ikan da ka ƙirƙira.',
    'onboarding_title_2': 'Bi Lissafin Kuɗinka',
    'onboarding_desc_2': 'Kada ka manta da biya tare da tsarin tunatarwa.',
    'onboarding_title_3': 'Tsara Siyayyarka',
    'onboarding_desc_3': 'Ƙirƙiri lissafin siyayya kuma ka bi kashe kuɗinka.',

    // Setup
    'setup_wizard': 'Jagoran Saiti',
    'personal_information': 'Bayanan Sirri',
    'preferences': 'Abubuwan da Ka Fi So',
    'terms_and_conditions': 'Sharuɗɗa da Yanayi',
    'accept_terms': 'Na yarda da sharuɗɗa da yanayi',
    'setup_complete': 'Saiti Ya Gama',
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ha'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/config/app_config.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/loading_overlay.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    
    final success = await authProvider.login(
      identifier: _identifierController.text.trim(),
      password: _passwordController.text,
      rememberMe: _rememberMe,
    );

    if (mounted) {
      if (success) {
        // Navigation is handled by the router based on auth state
        context.go('/dashboard');
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Login failed'),
            backgroundColor: AppTheme.dangerColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return LoadingOverlay(
            isLoading: authProvider.isLoading,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 60),
                      
                      // App Logo and Title
                      _buildHeader(l10n),
                      
                      const SizedBox(height: 48),
                      
                      // Login Form
                      _buildLoginForm(l10n),
                      
                      const SizedBox(height: 24),
                      
                      // Login Button
                      CustomButton(
                        text: l10n.login,
                        onPressed: _handleLogin,
                        isLoading: authProvider.isLoading,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Remember Me
                      _buildRememberMe(l10n),
                      
                      const SizedBox(height: 24),
                      
                      // Forgot Password
                      _buildForgotPassword(l10n),
                      
                      const SizedBox(height: 32),
                      
                      // Register Link
                      _buildRegisterLink(l10n),
                      
                      const SizedBox(height: 24),
                      
                      // Language Toggle
                      _buildLanguageToggle(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Column(
      children: [
        // App Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.account_balance_wallet,
            size: 40,
            color: AppTheme.whiteColor,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // App Name
        Text(
          AppConfig.appName,
          style: AppTheme.headingLarge.copyWith(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Welcome Message
        Text(
          '${l10n.welcome} back!',
          style: AppTheme.bodyLarge.copyWith(
            color: AppTheme.mutedTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(AppLocalizations l10n) {
    return Column(
      children: [
        // Username/Email Field
        CustomTextField(
          controller: _identifierController,
          labelText: '${l10n.username} or ${l10n.email}',
          hintText: 'Enter your username or email',
          prefixIcon: Icons.person_outline,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return l10n.fieldRequired;
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Password Field
        CustomTextField(
          controller: _passwordController,
          labelText: l10n.password,
          hintText: 'Enter your password',
          prefixIcon: Icons.lock_outline,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: AppTheme.mutedTextColor,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _handleLogin(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.fieldRequired;
            }
            if (value.length < AppConfig.minPasswordLength) {
              return l10n.passwordTooShort;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildRememberMe(AppLocalizations l10n) {
    return Row(
      children: [
        Checkbox(
          value: _rememberMe,
          onChanged: (value) {
            setState(() {
              _rememberMe = value ?? false;
            });
          },
          activeColor: AppTheme.primaryColor,
        ),
        Text(
          'Remember me',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPassword(AppLocalizations l10n) {
    return Center(
      child: TextButton(
        onPressed: () => context.go('/forgot-password'),
        child: Text(
          'Forgot Password?',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterLink(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Don\'t have an account? ',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.mutedTextColor,
          ),
        ),
        TextButton(
          onPressed: () => context.go('/register'),
          child: Text(
            l10n.register,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageToggle() {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Language: ',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.mutedTextColor,
              ),
            ),
            TextButton(
              onPressed: () => languageProvider.toggleLanguage(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    languageProvider.currentLanguageFlag,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    languageProvider.currentLanguageDisplayName,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
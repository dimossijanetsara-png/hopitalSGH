import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sghl_mobile/core/constants/app_colors.dart';
import 'package:sghl_mobile/core/widgets/primary_button.dart';
import 'package:sghl_mobile/features/auth/auth_models.dart';
import 'package:sghl_mobile/features/auth/auth_notifier.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _hasNavigated = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authNotifierProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.status == AuthStatus.loading;

    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (_hasNavigated) return;
      if (next.status == AuthStatus.authenticated) {
        _hasNavigated = true;
        context.go('/');
      } else if (next.status == AuthStatus.mfaRequired) {
        _hasNavigated = true;
        context.go('/mfa');
      } else if (next.status == AuthStatus.error && next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    });

    // Reset navigation flag when returning to unauthenticated
    if (authState.status == AuthStatus.unauthenticated ||
        authState.status == AuthStatus.error) {
      _hasNavigated = false;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background gradient header
          Container(
            height: 260,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryDark, AppColors.primaryLight],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // Logo + title
                  _buildHeader(),
                  const SizedBox(height: 40),
                  // Login card
                  _buildLoginCard(isLoading),
                ],
              ),
            ),
          ),
          // Loading overlay
          if (isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.local_hospital_rounded,
            color: AppColors.primary,
            size: 44,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'SGHL',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Système de Gestion Hospitalière\net de Laboratoire',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white70,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(bool isLoading) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Connexion',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Entrez vos identifiants pour accéder à votre espace',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 28),
              // Email field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                enabled: !isLoading,
                decoration: _inputDecoration(
                  label: 'Adresse e-mail',
                  hint: 'exemple@hopital.fr',
                  prefixIcon: Icons.email_outlined,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez saisir votre e-mail';
                  }
                  if (!value.contains('@')) {
                    return 'Adresse e-mail invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Password field
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                enabled: !isLoading,
                onFieldSubmitted: (_) => _handleLogin(),
                decoration: _inputDecoration(
                  label: 'Mot de passe',
                  hint: '••••••••',
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir votre mot de passe';
                  }
                  if (value.length < 4) {
                    return 'Mot de passe trop court';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),
              PrimaryButton(
                label: 'Se connecter',
                onPressed: isLoading ? null : _handleLogin,
                isLoading: isLoading,
                icon: Icons.login_rounded,
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/register'),
                  child: const Text.rich(
                    TextSpan(
                      text: 'Pas encore de compte ? ',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      children: [
                        TextSpan(
                          text: 'S\'inscrire',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(prefixIcon, color: AppColors.primary, size: 20),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

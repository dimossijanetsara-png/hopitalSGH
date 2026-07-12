import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sghl_mobile/core/constants/app_colors.dart';
import 'package:sghl_mobile/core/widgets/primary_button.dart';
import 'package:sghl_mobile/features/auth/auth_models.dart';
import 'package:sghl_mobile/features/auth/auth_notifier.dart';

class MFAScreen extends ConsumerStatefulWidget {
  const MFAScreen({super.key});

  @override
  ConsumerState<MFAScreen> createState() => _MFAScreenState();
}

class _MFAScreenState extends ConsumerState<MFAScreen> {
  final _tokenController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _hasNavigated = false;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  void _handleVerify() {
    if (_formKey.currentState?.validate() ?? false) {
      ref
          .read(authNotifierProvider.notifier)
          .verifyMfa(_tokenController.text.trim());
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
      } else if (next.status == AuthStatus.unauthenticated) {
        _hasNavigated = true;
        context.go('/login');
      } else if (next.status == AuthStatus.mfaRequired &&
          next.error != null) {
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Container(
            height: 200,
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
                  const SizedBox(height: 32),
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildCard(isLoading, authState),
                ],
              ),
            ),
          ),
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
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.shield_outlined,
            color: AppColors.primary,
            size: 38,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'SGHL',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(bool isLoading, AuthState authState) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_clock_outlined,
                color: AppColors.primary,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Vérification en deux étapes',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Entrez le code de votre application d\'authentification',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _tokenController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                enabled: !isLoading,
                autofocus: true,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 10,
                  color: AppColors.textPrimary,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '------',
                  hintStyle: TextStyle(
                    fontSize: 28,
                    letterSpacing: 10,
                    color: AppColors.border,
                    fontWeight: FontWeight.bold,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.error),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.error, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 18),
                ),
                onChanged: (value) {
                  if (value.length == 6) {
                    _handleVerify();
                  }
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez saisir le code';
                  }
                  if (value.trim().length != 6) {
                    return 'Le code doit contenir 6 chiffres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Vérifier',
                onPressed: isLoading ? null : _handleVerify,
                isLoading: isLoading,
                icon: Icons.verified_user_outlined,
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: isLoading
                    ? null
                    : () {
                        ref.read(authNotifierProvider.notifier).logout();
                        context.go('/login');
                      },
                icon: const Icon(Icons.arrow_back, size: 16),
                label: const Text('Retour à la connexion'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

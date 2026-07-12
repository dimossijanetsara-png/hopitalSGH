import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sghl_mobile/core/constants/app_colors.dart';
import 'package:sghl_mobile/core/widgets/primary_button.dart';
import 'package:sghl_mobile/features/auth/auth_repository.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_passwordCtrl.text != _confirmCtrl.text) {
      setState(() => _error = 'Les mots de passe ne correspondent pas');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = ref.read(authRepositoryProvider);
      final result = await repo.registerPatient(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['detail'] ?? 'Inscription réussie ! Vérifiez votre email.'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 4),
          ),
        );
        // Naviguer vers l'écran OTP
        context.go('/otp?email=${Uri.encodeComponent(_emailCtrl.text.trim())}');
      }
    } catch (e) {
      setState(() => _error = _parseError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _parseError(Object e) {
    final msg = e.toString();
    if (msg.contains('409') || msg.contains('déjà utilisé')) {
      return 'Cet email est déjà utilisé. Connectez-vous ou utilisez un autre email.';
    }
    if (msg.contains('password') || msg.contains('mot de passe')) {
      return 'Mot de passe invalide : 10 caractères minimum, 1 majuscule, 1 chiffre.';
    }
    return 'Erreur lors de l\'inscription. Vérifiez votre connexion.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.go('/login'),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryDark, AppColors.primaryLight],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    const Icon(Icons.person_add_alt_1_rounded,
                        color: Colors.white, size: 48),
                    const SizedBox(height: 8),
                    Text(
                      'Créer un compte patient',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Informations personnelles'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildField(_firstNameCtrl, 'Prénom', Icons.person_outline, required: true)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildField(_lastNameCtrl, 'Nom', Icons.person_outline, required: true)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildField(_phoneCtrl, 'Téléphone (optionnel)', Icons.phone_outlined,
                        keyboardType: TextInputType.phone),
                    const SizedBox(height: 20),
                    _sectionTitle('Accès au compte'),
                    const SizedBox(height: 12),
                    _buildField(
                      _emailCtrl,
                      'Adresse e-mail',
                      Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      required: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Email requis';
                        if (!v.contains('@')) return 'Email invalide';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildPasswordField(_passwordCtrl, 'Mot de passe', _obscurePassword,
                        () => setState(() => _obscurePassword = !_obscurePassword),
                        hint: '10+ car., 1 majuscule, 1 chiffre'),
                    const SizedBox(height: 12),
                    _buildPasswordField(_confirmCtrl, 'Confirmer le mot de passe',
                        _obscureConfirm,
                        () => setState(() => _obscureConfirm = !_obscureConfirm)),
                    const SizedBox(height: 16),

                    // Info OTP
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, color: AppColors.primary, size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Un code OTP sera envoyé à votre email pour activer votre compte.',
                              style: TextStyle(color: AppColors.primary, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(_error!,
                                  style: const TextStyle(color: AppColors.error, fontSize: 13)),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: 'S\'inscrire',
                      onPressed: _isLoading ? null : _register,
                      isLoading: _isLoading,
                      icon: Icons.how_to_reg_rounded,
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () => context.go('/login'),
                        child: const Text(
                          'Déjà un compte ? Se connecter',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        fontSize: 15,
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
    bool required = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      validator: validator ??
          (required
              ? (v) => (v == null || v.trim().isEmpty) ? '$label requis' : null
              : null),
    );
  }

  Widget _buildPasswordField(
    TextEditingController ctrl,
    String label,
    bool obscure,
    VoidCallback toggle, {
    String? hint,
  }) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary, size: 20),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: AppColors.textSecondary),
          onPressed: toggle,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Champ requis';
        if (v.length < 10) return '10 caractères minimum';
        if (!v.contains(RegExp(r'[A-Z]'))) return 'Au moins une majuscule';
        if (!v.contains(RegExp(r'[0-9]'))) return 'Au moins un chiffre';
        return null;
      },
    );
  }
}

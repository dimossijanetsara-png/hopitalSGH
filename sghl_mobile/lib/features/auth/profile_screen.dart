import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sghl_mobile/core/constants/app_colors.dart';
import 'package:sghl_mobile/core/widgets/loading_widget.dart';
import 'package:sghl_mobile/core/widgets/primary_button.dart';
import 'package:sghl_mobile/features/auth/auth_models.dart';
import 'package:sghl_mobile/features/auth/auth_notifier.dart';
import 'package:sghl_mobile/features/auth/auth_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    if (authState.status == AuthStatus.loading ||
        authState.status == AuthStatus.initial) {
      return const Scaffold(
        body: LoadingWidget(message: 'Chargement du profil...'),
      );
    }

    final user = authState.user;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Utilisateur non trouvé')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, ref, user),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPersonalInfoSection(context, user),
                  const SizedBox(height: 16),
                  _buildSecuritySection(context, ref, user),
                  const SizedBox(height: 24),
                  _buildLogoutButton(context, ref),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(
      BuildContext context, WidgetRef ref, AuthUser user) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryDark, AppColors.primaryLight],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Text(
                    _initials(user.fullName),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  user.fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user.roleLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          tooltip: 'Actualiser',
          onPressed: () =>
              ref.read(authNotifierProvider.notifier).refreshUser(),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoSection(BuildContext context, AuthUser user) {
    return _SectionCard(
      title: 'Informations personnelles',
      icon: Icons.person_outline,
      children: [
        _InfoTile(
          icon: Icons.badge_outlined,
          label: 'Nom complet',
          value: user.fullName,
        ),
        _InfoTile(
          icon: Icons.email_outlined,
          label: 'Adresse e-mail',
          value: user.email,
        ),
        _InfoTile(
          icon: Icons.work_outline,
          label: 'Rôle',
          value: user.roleLabel,
        ),
        _InfoTile(
          icon: Icons.phone_outlined,
          label: 'Téléphone',
          value: user.phone?.isNotEmpty == true
              ? user.phone!
              : 'Non renseigné',
          valueColor: user.phone?.isNotEmpty == true
              ? null
              : AppColors.textSecondary,
        ),
      ],
    );
  }

  Widget _buildSecuritySection(
      BuildContext context, WidgetRef ref, AuthUser user) {
    return _SectionCard(
      title: 'Sécurité',
      icon: Icons.security_outlined,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const CircleAvatar(
            backgroundColor: AppColors.background,
            radius: 20,
            child: Icon(Icons.lock_outline, color: AppColors.primary, size: 20),
          ),
          title: const Text(
            'Changer le mot de passe',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: const Text(
            'Modifier votre mot de passe actuel',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          onTap: () => _showChangePasswordSheet(context, ref),
        ),
        const Divider(height: 1),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: AppColors.background,
            radius: 20,
            child: Icon(
              user.mfaEnabled
                  ? Icons.verified_user
                  : Icons.shield_outlined,
              color: user.mfaEnabled ? AppColors.success : AppColors.primary,
              size: 20,
            ),
          ),
          title: Text(
            user.mfaEnabled
                ? 'Double authentification activée'
                : 'Activer la double authentification',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Text(
            user.mfaEnabled
                ? 'Désactiver la vérification en deux étapes'
                : 'Sécuriser votre compte avec un code OTP',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          trailing: Switch(
            value: user.mfaEnabled,
            activeThumbColor: AppColors.primary,
            onChanged: (_) {
              if (user.mfaEnabled) {
                _showDisableMfaDialog(context, ref);
              } else {
                _showSetupMfaSheet(context, ref);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.logout_rounded, color: AppColors.error),
        label: const Text(
          'Se déconnecter',
          style: TextStyle(
            color: AppColors.error,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.error),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () => _showLogoutDialog(context, ref),
      ),
    );
  }

  // ── Dialogs & Bottom Sheets ──────────────────────────────────────────────

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text(
            'Êtes-vous sûr(e) de vouloir vous déconnecter de votre compte ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(authNotifierProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _ChangePasswordSheet(ref: ref),
    );
  }

  void _showSetupMfaSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _SetupMfaSheet(ref: ref),
    );
  }

  void _showDisableMfaDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _DisableMfaSheet(ref: ref),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }
}

// ── Helper Widgets ──────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: valueColor ?? AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Change Password Bottom Sheet ────────────────────────────────────────────

class _ChangePasswordSheet extends StatefulWidget {
  final WidgetRef ref;

  const _ChangePasswordSheet({required this.ref});

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);
    try {
      await widget.ref.read(authRepositoryProvider).changePassword(
            _oldPasswordController.text,
            _newPasswordController.text,
          );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mot de passe modifié avec succès'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Erreur : vérifiez votre ancien mot de passe et réessayez.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Changer le mot de passe',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            _PasswordField(
              controller: _oldPasswordController,
              label: 'Ancien mot de passe',
              obscure: _obscureOld,
              onToggle: () => setState(() => _obscureOld = !_obscureOld),
              enabled: !_isLoading,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Champ requis' : null,
            ),
            const SizedBox(height: 12),
            _PasswordField(
              controller: _newPasswordController,
              label: 'Nouveau mot de passe',
              obscure: _obscureNew,
              onToggle: () => setState(() => _obscureNew = !_obscureNew),
              enabled: !_isLoading,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Champ requis';
                if (v.length < 8) return 'Minimum 8 caractères';
                return null;
              },
            ),
            const SizedBox(height: 12),
            _PasswordField(
              controller: _confirmPasswordController,
              label: 'Confirmer le nouveau mot de passe',
              obscure: _obscureConfirm,
              onToggle: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
              enabled: !_isLoading,
              validator: (v) {
                if (v != _newPasswordController.text) {
                  return 'Les mots de passe ne correspondent pas';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Enregistrer',
              onPressed: _isLoading ? null : _submit,
              isLoading: _isLoading,
              icon: Icons.save_outlined,
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final VoidCallback onToggle;
  final bool enabled;
  final String? Function(String?)? validator;

  const _PasswordField({
    required this.controller,
    required this.label,
    required this.obscure,
    required this.onToggle,
    required this.enabled,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      enabled: enabled,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon:
            const Icon(Icons.lock_outline, color: AppColors.primary, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: AppColors.textSecondary,
            size: 20,
          ),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

// ── Setup MFA Bottom Sheet ──────────────────────────────────────────────────

class _SetupMfaSheet extends StatefulWidget {
  final WidgetRef ref;

  const _SetupMfaSheet({required this.ref});

  @override
  State<_SetupMfaSheet> createState() => _SetupMfaSheetState();
}

class _SetupMfaSheetState extends State<_SetupMfaSheet> {
  bool _isLoading = true;
  bool _isVerifying = false;
  String? _secret;
  String? _qrImageBase64;
  String? _errorMessage;
  final _tokenController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _setupMfa();
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _setupMfa() async {
    try {
      final data = await widget.ref.read(authRepositoryProvider).setupMfa();
      setState(() {
        _secret = data['secret'] as String?;
        _qrImageBase64 = data['qr_image_base64'] as String?;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la configuration de la 2FA.';
        _isLoading = false;
      });
    }
  }

  Future<void> _verify() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isVerifying = true);
    try {
      await widget.ref
          .read(authRepositoryProvider)
          .verifyMfa(_tokenController.text.trim());
      await widget.ref.read(authNotifierProvider.notifier).refreshUser();
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Double authentification activée avec succès'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Code invalide. Veuillez réessayer.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Configurer la double authentification',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(32),
                child: LoadingWidget(message: 'Configuration en cours...'),
              )
            else if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: AppColors.error),
                textAlign: TextAlign.center,
              )
            else ...[
              const Text(
                'Scannez ce QR code avec votre application d\'authentification (Google Authenticator, Authy…)',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              if (_qrImageBase64 != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    base64Decode(_qrImageBase64!),
                    width: 180,
                    height: 180,
                  ),
                ),
              if (_secret != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Clé manuelle : $_secret',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _tokenController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  enabled: !_isVerifying,
                  style: const TextStyle(
                    fontSize: 22,
                    letterSpacing: 8,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    labelText: 'Code de vérification',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().length != 6) {
                      return 'Saisissez le code à 6 chiffres';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Activer la 2FA',
                onPressed: _isVerifying ? null : _verify,
                isLoading: _isVerifying,
                icon: Icons.verified_user_outlined,
              ),
            ],
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Disable MFA Bottom Sheet ────────────────────────────────────────────────

class _DisableMfaSheet extends StatefulWidget {
  final WidgetRef ref;

  const _DisableMfaSheet({required this.ref});

  @override
  State<_DisableMfaSheet> createState() => _DisableMfaSheetState();
}

class _DisableMfaSheetState extends State<_DisableMfaSheet> {
  final _tokenController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _disable() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);
    try {
      await widget.ref
          .read(authRepositoryProvider)
          .disableMfa(token: _tokenController.text.trim());
      await widget.ref.read(authNotifierProvider.notifier).refreshUser();
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Double authentification désactivée'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Code invalide. Vérifiez votre application d\'authentification.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Icon(Icons.shield_outlined, color: AppColors.error, size: 40),
            const SizedBox(height: 12),
            const Text(
              'Désactiver la double authentification',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Entrez le code de votre application d\'authentification pour confirmer.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _tokenController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              autofocus: true,
              enabled: !_isLoading,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
              ),
              decoration: InputDecoration(
                counterText: '',
                hintText: '------',
                hintStyle: TextStyle(
                  fontSize: 24,
                  letterSpacing: 8,
                  color: Colors.grey.shade300,
                  fontWeight: FontWeight.bold,
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.error, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              validator: (v) {
                if (v == null || v.trim().length != 6) {
                  return 'Saisissez le code à 6 chiffres';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.shield_outlined, size: 18),
                label: const Text('Désactiver la 2FA'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _isLoading ? null : _disable,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }
}

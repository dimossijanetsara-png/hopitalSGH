import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sghl_mobile/core/constants/app_colors.dart';
import 'package:sghl_mobile/core/widgets/primary_button.dart';
import 'package:sghl_mobile/features/auth/auth_notifier.dart';
import 'package:sghl_mobile/features/auth/auth_repository.dart';

class OTPScreen extends ConsumerStatefulWidget {
  final String email;
  final bool fromRegistration;

  const OTPScreen({
    super.key,
    required this.email,
    this.fromRegistration = true,
  });

  @override
  ConsumerState<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends ConsumerState<OTPScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _isResending = false;
  String? _error;
  int _resendCooldown = 0;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  Future<void> _verifyOtp() async {
    if (_otpCode.length != 6) {
      setState(() => _error = 'Entrez les 6 chiffres du code OTP');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.verifyOtp(email: widget.email, otpCode: _otpCode);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compte activé avec succès ! Connectez-vous.'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/login');
      }
    } catch (e) {
      setState(() => _error = _parseError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOtp() async {
    setState(() {
      _isResending = true;
      _error = null;
    });
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.resendOtp(email: widget.email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nouveau code envoyé à ${widget.email}'),
            backgroundColor: AppColors.success,
          ),
        );
        setState(() => _resendCooldown = 120);
        _startCooldown();
      }
    } catch (e) {
      setState(() => _error = _parseError(e));
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  void _startCooldown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendCooldown > 0) {
        setState(() => _resendCooldown--);
        _startCooldown();
      }
    });
  }

  String _parseError(Object e) {
    final msg = e.toString();
    if (msg.contains('expiré')) return 'Code OTP expiré. Demandez un nouveau code.';
    if (msg.contains('invalide')) return 'Code OTP incorrect. Vérifiez votre email.';
    if (msg.contains('429')) return 'Trop de tentatives. Attendez 2 minutes.';
    return 'Erreur : $msg';
  }

  void _onDigitEntered(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    if (_otpCode.length == 6) {
      _verifyOtp();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Icône
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_read_rounded,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Vérification OTP',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Un code à 6 chiffres a été envoyé à',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                widget.email,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Champs OTP (6 cases)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) => _buildOtpField(index)),
              ),

              if (_error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(color: AppColors.error, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),
              PrimaryButton(
                label: 'Vérifier le code',
                onPressed: _isLoading ? null : _verifyOtp,
                isLoading: _isLoading,
                icon: Icons.check_circle_outline,
              ),
              const SizedBox(height: 24),

              // Renvoyer OTP
              if (_resendCooldown > 0)
                Text(
                  'Renvoyer le code dans $_resendCooldown s',
                  style: const TextStyle(color: AppColors.textSecondary),
                )
              else
                TextButton.icon(
                  onPressed: _isResending ? null : _resendOtp,
                  icon: _isResending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh, size: 18),
                  label: const Text('Renvoyer le code OTP'),
                ),

              const SizedBox(height: 16),
              Text(
                'Vérifiez votre dossier spam si vous ne trouvez pas l\'email.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpField(int index) {
    return SizedBox(
      width: 48,
      height: 56,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          filled: true,
          fillColor: AppColors.surface,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) => _onDigitEntered(index, value),
      ),
    );
  }
}

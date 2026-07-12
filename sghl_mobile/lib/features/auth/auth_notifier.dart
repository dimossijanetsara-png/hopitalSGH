import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sghl_mobile/core/network/api_client.dart';
import 'package:sghl_mobile/core/storage/token_storage.dart';
import 'package:sghl_mobile/features/auth/auth_models.dart';
import 'package:sghl_mobile/features/auth/auth_repository.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  final TokenStorage _storage;

  AuthNotifier(this._repo, this._storage)
      : super(const AuthState(status: AuthStatus.initial)) {
    _init();
  }

  Future<void> _init() async {
    try {
      final hasTokens = await _storage.hasTokens();
      if (hasTokens) {
        final user = await _repo.getMe();
        state = AuthState(status: AuthStatus.authenticated, user: user);
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } catch (_) {
      await _storage.clear();
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      final data = await _repo.login(email, password);
      final mfaRequired = data['mfa_required'] as bool? ?? false;

      if (mfaRequired) {
        // Don't save the empty access/refresh tokens the backend returns here —
        // they would overwrite real tokens and corrupt the refresh interceptor.
        state = AuthState(
          status: AuthStatus.mfaRequired,
          pendingEmail: email,
          pendingPassword: password,
        );
      } else {
        await _saveTokensFromResponse(data);
        final user = await _repo.getMe();
        state = AuthState(status: AuthStatus.authenticated, user: user);
      }
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        error: _parseError(e),
      );
    }
  }

  Future<void> verifyMfa(String mfaToken) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      final email = state.pendingEmail ?? '';
      final password = state.pendingPassword ?? '';
      final data = await _repo.login(email, password, mfaToken: mfaToken);
      await _saveTokensFromResponse(data);
      final user = await _repo.getMe();
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.mfaRequired,
        error: _parseError(e),
      );
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> refreshUser() async {
    try {
      final user = await _repo.getMe();
      state = state.copyWith(user: user);
    } catch (_) {
      // Silently ignore refresh errors
    }
  }

  Future<void> _saveTokensFromResponse(Map<String, dynamic> data) async {
    final access = data['access'] as String? ?? data['access_token'] as String?;
    final refresh =
        data['refresh'] as String? ?? data['refresh_token'] as String?;
    final userId = data['user_id']?.toString();
    final role = data['role'] as String?;

    if (access != null && refresh != null) {
      await _storage.saveTokens(access: access, refresh: refresh);
    }
    if (userId != null) await _storage.saveUserId(userId);
    if (role != null) await _storage.saveUserRole(role);
  }

  String _parseError(Object e) {
    if (e is DioException) {
      final status = e.response?.statusCode;
      final data = e.response?.data;
      // Extract backend detail message if present
      final detail = (data is Map) ? data['detail'] as String? : null;

      if (detail != null && detail.isNotEmpty) {
        // MFA-specific errors
        if (detail.toLowerCase().contains('mfa') ||
            detail.toLowerCase().contains('code mfa') ||
            detail.toLowerCase().contains('authenticat')) {
          return 'Code d\'authentification invalide. Vérifiez votre application.';
        }
        // Locked account
        if (detail.toLowerCase().contains('verrouillé') ||
            detail.toLowerCase().contains('locked')) {
          return detail;
        }
        // Inactive account
        if (detail.toLowerCase().contains('activé') ||
            detail.toLowerCase().contains('otp')) {
          return detail;
        }
        return detail;
      }

      if (status == 401) return 'Email ou mot de passe incorrect.';
      if (status == 403) return 'Compte non activé. Vérifiez votre email.';
      if (status == 423) {
        return 'Compte temporairement verrouillé. Réessayez dans 30 minutes.';
      }
      if (status != null && status >= 500) {
        return 'Erreur serveur. Réessayez plus tard.';
      }

      // Network/connectivity errors
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return 'Impossible de se connecter au serveur. Vérifiez votre connexion réseau.';
      }
    }

    final msg = e.toString();
    if (msg.contains('SocketException') ||
        msg.contains('connection') ||
        msg.contains('Failed host')) {
      return 'Impossible de se connecter au serveur. Vérifiez votre connexion réseau.';
    }
    return 'Une erreur est survenue. Veuillez réessayer.';
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(authRepositoryProvider),
    ref.watch(tokenStorageProvider),
  );
});

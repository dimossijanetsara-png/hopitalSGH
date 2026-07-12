import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sghl_mobile/core/constants/api_constants.dart';
import 'package:sghl_mobile/core/network/api_client.dart';
import 'package:sghl_mobile/core/storage/token_storage.dart';
import 'package:sghl_mobile/features/auth/auth_models.dart';

class AuthRepository {
  final ApiClient _client;
  final TokenStorage _storage;

  AuthRepository(this._client, this._storage);

  Future<Map<String, dynamic>> login(
    String email,
    String password, {
    String? mfaToken,
  }) async {
    final body = <String, dynamic>{
      'email': email,
      'password': password,
    };
    if (mfaToken != null && mfaToken.isNotEmpty) {
      body['mfa_token'] = mfaToken;
    }
    final response = await _client.post(ApiConstants.authLogin, data: body);
    return response.data as Map<String, dynamic>;
  }

  Future<void> refreshToken() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      throw Exception('No refresh token available');
    }
    final response = await _client.post(
      ApiConstants.authRefresh,
      data: {'refresh': refreshToken},
    );
    final data = response.data as Map<String, dynamic>;
    final newAccess = data['access'] as String? ?? data['access_token'] as String?;
    final newRefresh = data['refresh'] as String? ?? data['refresh_token'] as String?;
    if (newAccess != null) {
      await _storage.saveTokens(
        access: newAccess,
        refresh: newRefresh ?? refreshToken,
      );
    }
  }

  Future<void> logout() async {
    try {
      await _client.post(ApiConstants.authLogout);
    } catch (_) {
      // Ignore errors on logout
    } finally {
      await _storage.clear();
    }
  }

  Future<AuthUser> getMe() async {
    final response = await _client.get(ApiConstants.authMe);
    return AuthUser.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    await _client.post(
      ApiConstants.authChangePassword,
      data: {
        'old_password': oldPassword,
        'new_password': newPassword,
      },
    );
  }

  Future<Map<String, dynamic>> setupMfa() async {
    final response = await _client.post(ApiConstants.authMfaSetup);
    return response.data as Map<String, dynamic>;
  }

  Future<void> verifyMfa(String token) async {
    await _client.post(
      ApiConstants.authMfaVerify,
      data: {'token': token},
    );
  }

  Future<void> disableMfa({required String token}) async {
    await _client.delete(ApiConstants.authMfaDisable, data: {'token': token});
  }

  /// Auto-inscription publique (rôle PATIENT) — retourne {detail, email, user_id}
  Future<Map<String, dynamic>> registerPatient({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    final body = <String, dynamic>{
      'email': email,
      'password': password,
      'first_name': firstName,
      'last_name': lastName,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
    };
    final response = await _client.post('/auth/register/patient', data: body);
    return response.data as Map<String, dynamic>;
  }

  /// Vérifie le code OTP et active le compte
  Future<void> verifyOtp({required String email, required String otpCode}) async {
    await _client.post('/auth/verify-otp', data: {
      'email': email,
      'otp_code': otpCode,
    });
  }

  /// Renvoi d'un nouveau code OTP
  Future<void> resendOtp({required String email}) async {
    await _client.post('/auth/resend-otp', data: {'email': email});
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(tokenStorageProvider),
  );
});

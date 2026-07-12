enum AuthStatus { initial, authenticated, unauthenticated, loading, mfaRequired, error }

class AuthUser {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String? phone;
  final bool mfaEnabled;

  const AuthUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.phone,
    required this.mfaEnabled,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id']?.toString() ?? '',
      email: json['email'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      role: json['role'] as String? ?? '',
      phone: json['phone'] as String?,
      mfaEnabled: json['mfa_enabled'] as bool? ?? false,
    );
  }

  String get fullName => '$firstName $lastName';

  String get roleLabel {
    switch (role.toUpperCase()) {
      case 'PATIENT':
        return 'Patient';
      case 'DOCTOR':
        return 'Médecin';
      case 'NURSE':
        return 'Infirmier(ère)';
      case 'ADMIN':
        return 'Administrateur';
      case 'LAB_TECHNICIAN':
        return 'Technicien de laboratoire';
      case 'PHARMACIST':
        return 'Pharmacien(ne)';
      case 'RECEPTIONIST':
        return 'Réceptionniste';
      default:
        return role;
    }
  }

  AuthUser copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? role,
    String? phone,
    bool? mfaEnabled,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      mfaEnabled: mfaEnabled ?? this.mfaEnabled,
    );
  }
}

class AuthState {
  final AuthStatus status;
  final AuthUser? user;
  final String? error;
  final String? pendingEmail;
  final String? pendingPassword;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
    this.pendingEmail,
    this.pendingPassword,
  });

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    String? error,
    String? pendingEmail,
    String? pendingPassword,
    bool clearUser = false,
    bool clearError = false,
    bool clearPending = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      error: clearError ? null : (error ?? this.error),
      pendingEmail: clearPending ? null : (pendingEmail ?? this.pendingEmail),
      pendingPassword:
          clearPending ? null : (pendingPassword ?? this.pendingPassword),
    );
  }
}

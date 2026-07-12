import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;

class ApiConstants {
  ApiConstants._();

  /// Résout automatiquement l'URL selon la plateforme :
  /// - Flutter Web → localhost (navigateur)
  /// - Émulateur Android → 10.0.2.2 (alias de la machine hôte)
  /// - iOS Simulator / Desktop → localhost
  // URL de production Render — à mettre à jour après déploiement
  static const String _productionUrl = 'https://REMPLACER-PAR-VOTRE-URL-RENDER.onrender.com/api/v1';

  // Passer à true après déploiement sur Render
  static const bool _useProduction = false;

  static String get baseUrl {
    if (_useProduction) return _productionUrl;
    if (kIsWeb) return 'http://localhost:8000/api/v1';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api/v1';
    }
    return 'http://localhost:8000/api/v1';
  }

  // Auth endpoints
  static const String authLogin = '/auth/login';
  static const String authRefresh = '/auth/refresh';
  static const String authLogout = '/auth/logout';
  static const String authMe = '/auth/me';
  static const String authChangePassword = '/auth/change-password';
  static const String authMfaSetup = '/auth/mfa/setup';
  static const String authMfaVerify = '/auth/mfa/verify';
  static const String authMfaDisable = '/auth/mfa/disable';

  // Resource endpoints
  static const String patients = '/patients';
  static const String appointments = '/rendez-vous';
  static const String doctorAvailability = '/rendez-vous/disponibilites';
  static const String conversations = '/messagerie/conversations';
  static const String messages = '/messagerie/messages';
  static const String consultations = '/clinique/consultations';
  static const String labOrders = '/laboratoire/commandes';
  static const String carePlans = '/soins/plans';
  static const String nursingVitalSigns = '/soins/hospitalisations';
}

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sghl_mobile/core/constants/app_colors.dart';
import 'package:sghl_mobile/features/auth/auth_notifier.dart';
import 'package:sghl_mobile/features/auth/auth_models.dart';
import 'package:sghl_mobile/features/auth/login_screen.dart';
import 'package:sghl_mobile/features/auth/mfa_screen.dart';
import 'package:sghl_mobile/features/auth/otp_screen.dart';
import 'package:sghl_mobile/features/auth/profile_screen.dart';
import 'package:sghl_mobile/features/auth/register_screen.dart';
import 'package:sghl_mobile/features/dashboard/dashboard_screen.dart';
import 'package:sghl_mobile/features/appointments/appointments_screen.dart';
import 'package:sghl_mobile/features/appointments/book_appointment_screen.dart';
import 'package:sghl_mobile/features/messaging/conversations_screen.dart';
import 'package:sghl_mobile/features/messaging/chat_screen.dart';
import 'package:sghl_mobile/features/medical_records/records_screen.dart';
import 'package:sghl_mobile/features/medical_records/consultation_detail_screen.dart';
import 'package:sghl_mobile/features/lab_results/lab_results_screen.dart';
import 'package:sghl_mobile/features/care_plan/care_plan_screen.dart';

// Shell scaffold widget that wraps screens with a bottom navigation bar
class _ShellScaffold extends ConsumerWidget {
  final Widget child;

  const _ShellScaffold({required this.child});

  static const List<_NavItem> _navItems = [
    _NavItem(label: 'Accueil', icon: Icons.home, route: '/'),
    _NavItem(label: 'Rendez-vous', icon: Icons.calendar_today, route: '/appointments'),
    _NavItem(label: 'Messages', icon: Icons.chat_bubble, route: '/messages'),
    _NavItem(label: 'Dossier', icon: Icons.folder_shared, route: '/records'),
    _NavItem(label: 'Profil', icon: Icons.person, route: '/profile'),
  ];

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/appointments')) return 1;
    if (location.startsWith('/messages')) return 2;
    if (location.startsWith('/records')) return 3;
    if (location.startsWith('/labs')) return 3;
    if (location.startsWith('/care')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = _selectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        backgroundColor: AppColors.surface,
        elevation: 8,
        onTap: (index) {
          context.go(_navItems[index].route);
        },
        items: _navItems
            .map(
              (item) => BottomNavigationBarItem(
                icon: Icon(item.icon),
                label: item.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final String route;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.route,
  });
}

// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final status = authState.status;
      final location = state.uri.toString();

      // While initializing, show a loading screen (no redirect needed — handled below)
      if (status == AuthStatus.initial) {
        return null;
      }

      // MFA required → redirect to /mfa (unless already there)
      if (status == AuthStatus.mfaRequired) {
        if (location != '/mfa') return '/mfa';
        return null;
      }

      // Not authenticated → redirect to /login (unless already there)
      if (status == AuthStatus.unauthenticated || status == AuthStatus.error) {
        if (location != '/login') return '/login';
        return null;
      }

      // Authenticated → if on login or mfa, redirect to home
      if (status == AuthStatus.authenticated) {
        if (location == '/login' || location == '/mfa') return '/';
        return null;
      }

      return null;
    },
    routes: [
      // Login route (outside shell)
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Inscription patient (publique)
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Vérification OTP après inscription
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return OTPScreen(email: email);
        },
      ),

      // MFA route (outside shell)
      GoRoute(
        path: '/mfa',
        builder: (context, state) => const MFAScreen(),
      ),

      // Shell route with bottom navigation
      ShellRoute(
        builder: (context, state, child) => _ShellScaffold(child: child),
        routes: [
          // Dashboard (home)
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardScreen(),
          ),

          // Appointments
          GoRoute(
            path: '/appointments',
            builder: (context, state) => const AppointmentsScreen(),
            routes: [
              GoRoute(
                path: 'book',
                builder: (context, state) => const BookAppointmentScreen(),
              ),
            ],
          ),

          // Messages / conversations
          GoRoute(
            path: '/messages',
            builder: (context, state) => const ConversationsScreen(),
            routes: [
              GoRoute(
                path: ':conversationId',
                builder: (context, state) => ChatScreen(
                  conversationId: state.pathParameters['conversationId']!,
                ),
              ),
            ],
          ),

          // Medical records
          GoRoute(
            path: '/records',
            builder: (context, state) => const RecordsScreen(),
            routes: [
              GoRoute(
                path: ':consultationId',
                builder: (context, state) => ConsultationDetailScreen(
                  consultationId: state.pathParameters['consultationId']!,
                ),
              ),
            ],
          ),

          // Lab results
          GoRoute(
            path: '/labs',
            builder: (context, state) => const LabResultsScreen(),
          ),

          // Care plan
          GoRoute(
            path: '/care',
            builder: (context, state) => const CarePlanScreen(),
          ),

          // Profile
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],

    // Loading page while auth status is initial
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page introuvable: ${state.uri}'),
      ),
    ),
  );
});

class SGHLApp extends ConsumerWidget {
  const SGHLApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStatus = ref.watch(authNotifierProvider).status;
    final router = ref.watch(routerProvider);

    const localizationsDelegates = [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ];
    const supportedLocales = [
      Locale('fr', 'FR'),
      Locale('en', 'US'),
    ];

    // Show a full-screen loading indicator while the auth state is being
    // determined (e.g., checking stored tokens on startup).
    if (authStatus == AuthStatus.initial) {
      return MaterialApp(
        title: 'SGHL Mobile',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        localizationsDelegates: localizationsDelegates,
        supportedLocales: supportedLocales,
        locale: const Locale('fr', 'FR'),
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp.router(
      title: 'SGHL Mobile',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      localizationsDelegates: localizationsDelegates,
      supportedLocales: supportedLocales,
      locale: const Locale('fr', 'FR'),
      routerConfig: router,
    );
  }

  ThemeData _buildTheme() {
    final colorScheme = ColorScheme.fromSeed(seedColor: AppColors.primary);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.primary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: AppColors.primary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surface,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}

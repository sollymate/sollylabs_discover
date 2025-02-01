import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sollylabs_discover/src/core/authentication/services/auth_service.dart';
import 'package:sollylabs_discover/src/core/authentication/views/auth_gate.dart';
import 'package:sollylabs_discover/src/core/authentication/views/login_page.dart';
import 'package:sollylabs_discover/src/core/authentication/views/otp_page.dart';
import 'package:sollylabs_discover/src/core/authentication/views/reset_password_page.dart';
import 'package:sollylabs_discover/src/core/authentication/views/update_password_after_reset_page.dart';
import 'package:sollylabs_discover/src/core/authentication/views/update_password_page.dart';
import 'package:sollylabs_discover/src/core/navigation/route_names.dart'; // ✅ Import route names
import 'package:sollylabs_discover/src/core/views/dashboard_page.dart';
import 'package:sollylabs_discover/src/features/network/views/network_page.dart';
import 'package:sollylabs_discover/src/features/people/views/people_page.dart';
import 'package:sollylabs_discover/src/features/profile/views/user_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.authGate, // ✅ Use route name variable
    routes: [
      GoRoute(
        path: RouteNames.authGate, // ✅ Updated
        builder: (context, state) => const AuthGate(),
      ),
      GoRoute(
        path: RouteNames.loginPage, // ✅ Updated
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RouteNames.updatePasswordAfterReset, // ✅ Updated
        builder: (context, state) => const UpdatePasswordAfterResetPage(),
      ),
      GoRoute(
        path: RouteNames.updatePasswordPage, // ✅ Updated
        builder: (context, state) => const UpdatePasswordPage(),
      ),
      GoRoute(
        path: RouteNames.dashboardPage, // ✅ Updated
        builder: (context, state) => const DashboardPage(),
        redirect: (context, state) => _authRedirect(context),
      ),
      GoRoute(
        path: RouteNames.userPage, // ✅ Updated
        builder: (context, state) => const UserPage(),
        redirect: (context, state) => _authRedirect(context),
      ),
      GoRoute(
        path: RouteNames.peoplePage, // ✅ Updated
        builder: (context, state) => const PeoplePage(),
        redirect: (context, state) => _authRedirect(context),
      ),
      GoRoute(
        path: RouteNames.networkPage, // ✅ Updated
        builder: (context, state) => const NetworkPage(),
        redirect: (context, state) => _authRedirect(context),
      ),
      GoRoute(
        path: RouteNames.otpPage,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return OtpPage(
            email: extra['email'] ?? '',
            isResetPassword: extra['isResetPassword'] ?? false,
          );
        },
      ),
      GoRoute(
        path: RouteNames.resetPasswordPage,
        builder: (context, state) => const ResetPasswordPage(),
      ),
    ],
  );

  /// ✅ Auth Guard: Redirects users who are not logged in
  static String? _authRedirect(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    return authService.currentUser == null ? RouteNames.loginPage : null;
  }
}

// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import 'package:sollylabs_discover/src/core/authentication/services/auth_service.dart';
// import 'package:sollylabs_discover/src/core/authentication/views/auth_gate.dart';
// import 'package:sollylabs_discover/src/core/authentication/views/login_page.dart';
// import 'package:sollylabs_discover/src/core/authentication/views/update_password_after_reset_page.dart';
// import 'package:sollylabs_discover/src/core/authentication/views/update_password_page.dart';
// import 'package:sollylabs_discover/src/core/views/dashboard_page.dart';
// import 'package:sollylabs_discover/src/features/network/views/network_page.dart';
// import 'package:sollylabs_discover/src/features/people/views/people_page.dart';
// import 'package:sollylabs_discover/src/features/profile/views/user_page.dart';
//
// class AppRouter {
//   static final GoRouter router = GoRouter(
//     initialLocation: '/',
//     routes: [
//       GoRoute(
//         path: '/',
//         builder: (context, state) => const AuthGate(),
//       ),
//       GoRoute(
//         path: '/login',
//         builder: (context, state) => const LoginPage(),
//       ),
//       GoRoute(
//         path: '/update-password',
//         builder: (context, state) => const UpdatePasswordAfterResetPage(),
//       ),
//       GoRoute(
//         path: '/update-password-in-app',
//         builder: (context, state) => const UpdatePasswordPage(),
//       ),
//       GoRoute(
//         path: '/dashboard',
//         builder: (context, state) => const DashboardPage(),
//         redirect: (context, state) => _authRedirect(context),
//       ),
//       GoRoute(
//         path: '/account',
//         builder: (context, state) => const UserPage(),
//         redirect: (context, state) => _authRedirect(context),
//       ),
//       GoRoute(
//         path: '/community',
//         builder: (context, state) => const PeoplePage(),
//         redirect: (context, state) => _authRedirect(context),
//       ),
//       GoRoute(
//         path: '/network',
//         builder: (context, state) => const NetworkPage(),
//         redirect: (context, state) => _authRedirect(context),
//       ),
//     ],
//   );
//
//   /// ✅ Auth Guard: Redirects users who are not logged in
//   static String? _authRedirect(BuildContext context) {
//     final authService = Provider.of<AuthService>(context, listen: false);
//     return authService.currentUser == null ? '/login' : null;
//   }
// }

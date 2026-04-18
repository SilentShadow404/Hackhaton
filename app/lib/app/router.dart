import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/application/auth_controller.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/reset_password_page.dart';
import '../features/auth/presentation/signup_page.dart';
import '../features/dashboard/presentation/dashboard_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/signup', builder: (context, state) => const SignupPage()),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordPage(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
    ],
    redirect: (context, state) {
      final user = authState.value;
      final isAuthRoute =
          state.uri.path == '/login' ||
          state.uri.path == '/signup' ||
          state.uri.path == '/reset-password';

      if (user == null && !isAuthRoute) {
        return '/login';
      }

      if (user != null && isAuthRoute) {
        return '/dashboard';
      }

      return null;
    },
  );
});

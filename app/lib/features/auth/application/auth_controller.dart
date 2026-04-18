import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/auth_user.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<AuthUser?>>(
      (ref) => AuthController(),
    );

class AuthController extends StateNotifier<AsyncValue<AuthUser?>> {
  AuthController()
    : _auth = FirebaseAuth.instance,
      super(const AsyncValue.loading()) {
    _sub = _auth.authStateChanges().listen((firebaseUser) {
      if (firebaseUser == null) {
        state = const AsyncValue.data(null);
      } else {
        state = AsyncValue.data(
          AuthUser(
            uid: firebaseUser.uid,
            email: firebaseUser.email ?? 'no-email@user.local',
          ),
        );
      }
    });
  }

  final FirebaseAuth _auth;
  late final StreamSubscription<User?> _sub;

  Future<void> signIn({required String email, required String password}) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      state = AsyncValue.error(
        'Email and password are required.',
        StackTrace.current,
      );
      return;
    }

    try {
      state = const AsyncValue.loading();
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      state = AsyncValue.error(
        error.message ?? 'Sign in failed',
        StackTrace.current,
      );
    }
  }

  Future<void> signUp({required String email, required String password}) async {
    if (!email.contains('@') || password.length < 6) {
      state = AsyncValue.error(
        'Use a valid email and password with 6+ chars.',
        StackTrace.current,
      );
      return;
    }

    try {
      state = const AsyncValue.loading();
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      state = AsyncValue.error(
        error.message ?? 'Sign up failed',
        StackTrace.current,
      );
    }
  }

  Future<void> sendPasswordReset(String email) async {
    if (!email.contains('@')) {
      throw Exception('Please enter a valid email.');
    }
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

// providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

// Service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(apiBaseUrl);
});

// Main auth state (user info)
final authProvider = StateNotifierProvider<AuthNotifier, UserModel?>((ref) {
  return AuthNotifier(ref);
});

// Auth loading state
final authLoadingProvider = StateProvider<bool>((ref) => false);

// Auth error message state
final authErrorProvider = StateProvider<String?>((ref) => null);

class AuthNotifier extends StateNotifier<UserModel?> {
  final Ref ref;

  AuthNotifier(this.ref) : super(null);

  Future<void> login(String email, String password) async {
    ref.read(authLoadingProvider.notifier).state = true;
    ref.read(authErrorProvider.notifier).state = null;

    try {
      final user = await ref.read(authServiceProvider).login(email, password);
      state = user;
    } catch (e) {
      state = null;
      ref.read(authErrorProvider.notifier).state = 'Login failed. Please try again.';
      print('Login error: $e');
    } finally {
      ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  Future<void> register(UserModel user) async {
    ref.read(authLoadingProvider.notifier).state = true;
    ref.read(authErrorProvider.notifier).state = null;

    try {
      final newUser = await ref.read(authServiceProvider).register(user);
      state = newUser;
    } catch (e) {
      state = null;
      ref.read(authErrorProvider.notifier).state = 'Registration failed.';
      print('Registration error: $e');
    } finally {
      ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  Future<void> logout() async {
    await ref.read(authServiceProvider).logout();
    state = null;
  }

  bool get isAuthenticated => state != null;
}

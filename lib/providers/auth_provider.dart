import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

final authServiceProvider = Provider((ref) => AuthService());

class AuthState {
  final AppUser? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({AppUser? user, bool? isLoading, String? error, bool clearUser = false}) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState()) {
    tryAutoLogin();
  }

  Future<void> tryAutoLogin() async {
    state = state.copyWith(isLoading: true);
    try {
      final data = await _authService.getCurrentUser();
      if (data.containsKey('user')) {
        final user = AppUser.fromJson(data['user']);
        state = state.copyWith(user: user, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null, clearUser: true);
    try {
      final data = await _authService.login(email, password);
      final user = AppUser.fromJson(data['user']);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false, clearUser: true);
    }
  }

  Future<void> register(String name, String email, String password, String role) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Assuming AuthService will have a register method or I'll add it
      // Actually, I'll update AuthService to include register too
      final response = await _authService.register(name, email, password, role);
      final user = AppUser.fromJson(response['user']);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});

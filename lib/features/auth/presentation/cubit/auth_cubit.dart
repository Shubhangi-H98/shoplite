import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {}
class AuthUnauthenticated extends AuthState {}
class AuthError extends AuthState { final String message; AuthError(this.message); }

class AuthCubit extends Cubit<AuthState> {
  final FlutterSecureStorage _storage;

  AuthCubit(this._storage) : super(AuthInitial()) {
    debugPrint("🧠 [AuthCubit] Instance created via DI.");
  }

  Future<void> login(String email, String password) async {
    debugPrint("🔵 [AuthCubit] Attempting login for: $email");
    emit(AuthLoading());

    try {
      await Future.delayed(const Duration(seconds: 2)); // Mock delay

      if (email == "test@test.com" && password == "123456") {
        debugPrint("🟢 [AuthCubit] Auth Success. Storing token...");

        await _storage.write(key: 'auth_token', value: 'mock_jwt_token_123');
        debugPrint("✅ [AuthCubit] Token saved. Moving to Authenticated state.");
        emit(AuthAuthenticated());
      } else {
        debugPrint("🔴 [AuthCubit] Auth Failed: Invalid Credentials.");
        emit(AuthError("Invalid email or password. Hint: test@test.com / 123456"));
      }
    } catch (e, stack) {
      debugPrint("❌ [AuthCubit] Login Crash: $e");
      emit(AuthError("Unexpected error occurred."));
    }
  }

  Future<void> checkAuthStatus() async {
    debugPrint("🔍 [AuthCubit] Checking persistent token...");
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token != null) {
        debugPrint("🔑 [AuthCubit] Active token found. Auto-login success.");
        emit(AuthAuthenticated());
      } else {
        debugPrint("🚫 [AuthCubit] No token found. Redirecting to Login.");
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      debugPrint("⚠️ [AuthCubit] SecureStorage Error: $e");
      emit(AuthUnauthenticated());
    }
  }

  Future<void> logout() async {
    try {
      debugPrint("🚪 [AuthCubit] Initiation Logout Sequence...");

      await _storage.delete(key: 'auth_token');
      debugPrint("🗑️ [AuthCubit] Persistent token cleared from secure storage.");

      emit(AuthUnauthenticated());
      debugPrint("✅ [AuthCubit] State changed to Unauthenticated.");
    } catch (e) {
      debugPrint("❌ [AuthCubit] Logout failed: $e");
    }
  }
}
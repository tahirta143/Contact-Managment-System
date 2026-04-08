import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants/api_constants.dart';
import '../models/user_model.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.authLogin),
        body: jsonEncode({"email": email, "password": password}),
        headers: {"Content-Type": "application/json"},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _storage.write(key: 'auth_token', value: data['token']);
        // data['user'] contains the user info returned by backend
        return data;
      } else {
        throw Exception(data['message'] ?? "Login failed");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password, String role) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.authRegister),
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
          "role": role.toLowerCase(),
        }),
        headers: {"Content-Type": "application/json"},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        await _storage.write(key: 'auth_token', value: data['token']);
        return data;
      } else {
        throw Exception(data['message'] ?? "Registration failed");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final token = await getToken();
      if (token == null) return {}; // return empty to trigger LoginScreen

      final response = await http.get(
        Uri.parse(ApiConstants.authMe),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data; // contains { user: { ... } }
      } else {
        // Token might be expired, clear it
        await logout();
        return {};
      }
    } catch (e) {
      return {};
    }
  }

  // Optional: Check if token exists to auto-login
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null;
  }

  Future<void> updateFcmToken(String fcmToken) async {
    try {
      final token = await getToken();
      if (token == null) return;

      await http.post(
        Uri.parse("${ApiConstants.baseUrl}/auth/fcm-token"),
        body: jsonEncode({"fcmToken": fcmToken}),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
    } catch (e) {
      // Slient failure for FCM token sync
      print("Error updating FCM token: $e");
    }
  }
}

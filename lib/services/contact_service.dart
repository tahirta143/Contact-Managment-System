import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/contact_model.dart';
import 'auth_service.dart';

class ContactService {
  final String baseUrl = "https://your-api.com/api";
  final AuthService _authService = AuthService();

  Future<List<Contact>> getContacts({String? search, String? filter}) async {
    final token = await _authService.getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/contacts?search=${search ?? ''}&filter=${filter ?? ''}"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Contact.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load contacts");
    }
  }

  Future<Contact> addContact(Map<String, dynamic> contactData) async {
    final token = await _authService.getToken();
    // For multipart/photo, we would use http.MultipartRequest
    final response = await http.post(
      Uri.parse("$baseUrl/contacts"),
      body: jsonEncode(contactData),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Contact.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to add contact");
    }
  }
}

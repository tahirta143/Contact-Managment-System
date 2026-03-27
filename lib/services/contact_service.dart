import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import '../models/contact_model.dart';
import 'auth_service.dart';

class ContactService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  Future<List<Contact>> getContacts({String? search, String? filter}) async {
    final queryParams = {
      if (search != null && search.isNotEmpty) 'search': search,
      if (filter != null && filter.isNotEmpty) 'filter': filter,
    };
    
    final uri = Uri.parse(ApiConstants.contacts).replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Contact.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load contacts: ${response.statusCode}");
    }
  }

  Future<Contact> addContact(Map<String, dynamic> contactData, {String? imagePath}) async {
    final token = await _authService.getToken();
    final uri = Uri.parse(ApiConstants.contacts);
    
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';

    // Add fields
    contactData.forEach((key, value) {
      if (value != null) {
        if (key == 'events') {
          request.fields[key] = jsonEncode(value);
        } else {
          request.fields[key] = value.toString();
        }
      }
    });

    // Add image
    if (imagePath != null) {
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return Contact.fromJson(jsonDecode(response.body));
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? "Failed to add contact");
    }
  }

  Future<Contact> updateContact(String id, Map<String, dynamic> contactData, {String? imagePath}) async {
    final token = await _authService.getToken();
    final uri = Uri.parse("${ApiConstants.contacts}/$id");
    
    final request = http.MultipartRequest('PUT', uri);
    request.headers['Authorization'] = 'Bearer $token';

    // Add fields
    contactData.forEach((key, value) {
      if (value != null) {
        if (key == 'events') {
          request.fields[key] = jsonEncode(value);
        } else {
          request.fields[key] = value.toString();
        }
      }
    });

    // Add image
    if (imagePath != null) {
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return Contact.fromJson(jsonDecode(response.body));
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? "Failed to update contact");
    }
  }

  Future<void> deleteContact(String id) async {
    final response = await http.delete(
      Uri.parse("${ApiConstants.contacts}/$id"),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? "Failed to delete contact");
    }
  }
}

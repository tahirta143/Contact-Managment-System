import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../core/constants/api_constants.dart';
import '../models/contact_model.dart';
import 'auth_service.dart';

class ContactService {
  final AuthService _authService = AuthService();

  static const int _maxImageBytes = 5 * 1024 * 1024;
  static const Map<String, String> _allowedImageMimes = {
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'webp': 'image/webp',
    'jfif': 'image/jpeg',
    'heic': 'image/heic',
    'heif': 'image/heif',
  };

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

  Future<http.MultipartFile?> _buildImagePart(String? imagePath) async {
    final path = imagePath?.trim();
    if (path == null || path.isEmpty) return null;

    final file = File(path);
    if (!await file.exists()) {
      throw Exception("Selected image file was not found.");
    }

    final fileSize = await file.length();
    if (fileSize > _maxImageBytes) {
      throw Exception("Image is too large. Please select an image under 5MB.");
    }

    final ext = p.extension(path).toLowerCase().replaceFirst('.', '');
    final mimeType = _allowedImageMimes[ext] ?? 'image/jpeg';

    return http.MultipartFile.fromPath(
      'image',
      path,
      contentType: MediaType.parse(mimeType),
    );
  }

  String _extractErrorMessage(http.Response response, {required String fallback}) {
    try {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        if (data['debug'] != null) {
          print("BACKEND DEBUG: ${data['debug']}");
        }
        return data['message']?.toString() ?? fallback;
      }
    } catch (_) {
      // Non-JSON error response from server/proxy
    }
    return "$fallback (HTTP ${response.statusCode})";
  }

  Future<Contact> addContact(Map<String, dynamic> contactData, {String? imagePath}) async {
    final token = await _authService.getToken();
    final uri = Uri.parse(ApiConstants.contacts);

    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';

    contactData.forEach((key, value) {
      if (value != null) {
        if (key == 'events') {
          request.fields[key] = jsonEncode(value);
        } else {
          request.fields[key] = value.toString();
        }
      }
    });

    final imagePart = await _buildImagePart(imagePath);
    if (imagePart != null) {
      request.files.add(imagePart);
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return Contact.fromJson(jsonDecode(response.body));
    }

    throw Exception(
      _extractErrorMessage(response, fallback: "Failed to add contact"),
    );
  }

  Future<Contact> updateContact(String id, Map<String, dynamic> contactData, {String? imagePath}) async {
    final token = await _authService.getToken();
    final uri = Uri.parse("${ApiConstants.contacts}/$id");

    final request = http.MultipartRequest('PUT', uri);
    request.headers['Authorization'] = 'Bearer $token';

    contactData.forEach((key, value) {
      if (value != null) {
        if (key == 'events') {
          request.fields[key] = jsonEncode(value);
        } else {
          request.fields[key] = value.toString();
        }
      }
    });

    final imagePart = await _buildImagePart(imagePath);
    if (imagePart != null) {
      request.files.add(imagePart);
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return Contact.fromJson(jsonDecode(response.body));
    }

    throw Exception(
      _extractErrorMessage(response, fallback: "Failed to update contact"),
    );
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

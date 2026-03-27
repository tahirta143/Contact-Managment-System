import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import 'auth_service.dart';

class EventService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  Future<List<Map<String, dynamic>>> getUpcomingEvents({int days = 30}) async {
    final uri = Uri.parse(ApiConstants.eventsUpcoming).replace(queryParameters: {'days': days.toString()});
    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception("Failed to load upcoming events");
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import '../models/reminder_model.dart';
import 'auth_service.dart';

class ReminderService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  Future<List<Reminder>> getReminders({
    String? contactId,
    String? status,
    String? from,
    String? to,
  }) async {
    final queryParams = {
      if (contactId != null) 'contact_id': contactId,
      if (status != null) 'status': status,
      if (from != null) 'from': from,
      if (to != null) 'to': to,
    };
    
    final uri = Uri.parse(ApiConstants.reminders).replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Reminder.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load reminders");
    }
  }

  Future<Reminder> addReminder(Map<String, dynamic> reminderData) async {
    final response = await http.post(
      Uri.parse(ApiConstants.reminders),
      body: jsonEncode(reminderData),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 201) {
      return Reminder.fromJson(jsonDecode(response.body));
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? "Failed to add reminder");
    }
  }

  Future<Reminder> updateReminder(String id, Map<String, dynamic> reminderData) async {
    final response = await http.put(
      Uri.parse("${ApiConstants.reminders}/$id"),
      body: jsonEncode(reminderData),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return Reminder.fromJson(jsonDecode(response.body));
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? "Failed to update reminder");
    }
  }

  Future<void> deleteReminder(String id) async {
    final response = await http.delete(
      Uri.parse("${ApiConstants.reminders}/$id"),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? "Failed to delete reminder");
    }
  }
}

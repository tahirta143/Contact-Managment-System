import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import '../core/constants/api_constants.dart';

class VersionService {
  /// Checks if the current app version is allowed to run.
  /// Returns 'true' if update is required, 'false' if app is up to date.
  static Future<bool> isUpdateRequired() async {
    try {
      // 1. Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version; // e.g. "1.0.0"

      // 2. Fetch minimum version from backend
      final response = await http.get(Uri.parse(ApiConstants.appConfig));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final minVersion = data['data']['min_version'] as String;

        // 3. Compare versions
        return _isVersionLower(currentVersion, minVersion);
      }
      
      // If server is down, we allow the user in to prevent lockout
      return false;
    } catch (e) {
      print("Error checking version: $e");
      return false;
    }
  }

  /// Helper to compare semantic versions (e.g. 1.0.2 vs 1.0.5)
  static bool _isVersionLower(String current, String required) {
    if (current == required) return false;

    List<int> currentParts = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    List<int> requiredParts = required.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    for (int i = 0; i < requiredParts.length; i++) {
      int currentVal = i < currentParts.length ? currentParts[i] : 0;
      int requiredVal = requiredParts[i];

      if (currentVal < requiredVal) return true;
      if (currentVal > requiredVal) return false;
    }

    return false;
  }
}

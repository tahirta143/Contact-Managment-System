class ApiConstants {
  // Use http://10.0.2.2:3000/api for Android emulator
  // Use http://localhost:3000/api for iOS simulator
  // Use your computer's IP address (e.g., http://192.168.1.100:3000/api) for physical devices
  static const String baseUrl = "https://api.contact.afaqmis.com/api";
  static const String baseImageUrl = "https://api.contact.afaqmis.com";
  static const String authLogin = "$baseUrl/auth/login";
  static const String authRegister = "$baseUrl/auth/register";
  static const String authMe = "$baseUrl/auth/me";
  static const String contacts = "$baseUrl/contacts";
  static const String reminders = "$baseUrl/reminders";
  static const String eventsUpcoming = "$baseUrl/events/upcoming";
  static const String appConfig = "$baseUrl/app-config";

  static String? resolveImageUrl(String? photoUrl) {
    if (photoUrl == null) return null;

    var cleaned = photoUrl.trim();
    if (cleaned.isEmpty || cleaned.toLowerCase() == "null") {
      return null;
    }

    // Normalize legacy/backslash paths from some environments.
    cleaned = cleaned.replaceAll('\\', '/');
    cleaned = cleaned.replaceAll(RegExp(r'^\.\/+'), '');

    if (cleaned.startsWith("http://") || cleaned.startsWith("https://")) {
      return Uri.encodeFull(cleaned);
    }

    if (cleaned.startsWith("/")) {
      return Uri.encodeFull("$baseImageUrl$cleaned");
    }

    return Uri.encodeFull("$baseImageUrl/$cleaned");
  }
}

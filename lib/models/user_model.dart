class AppUser {
  final String id;
  final String name;
  final String email;
  final String role; // 'admin' or 'user'
  final String? photoUrl;
  final bool isActive;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.photoUrl,
    required this.isActive,
  });

  bool get isAdmin => true; // Everyone has admin visibility now

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'admin',
      photoUrl: json['photoUrl'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'photoUrl': photoUrl,
      'isActive': isActive,
    };
  }
}

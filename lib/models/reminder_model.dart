class Reminder {
  final String id;
  final String title;
  final String? description;
  final String reminderDate; // YYYY-MM-DD
  final String? contactId;
  final String? status;
  final bool isCompleted;
  final DateTime createdAt;

  Reminder({
    required this.id,
    required this.title,
    this.description,
    required this.reminderDate,
    this.contactId,
    this.status,
    this.isCompleted = false,
    required this.createdAt,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id']?.toString() ?? "",
      title: json['title'] ?? "",
      description: json['description'],
      reminderDate: json['reminder_date'] ?? json['reminderDate'] ?? "",
      contactId: json['contact_id']?.toString() ?? json['contactId']?.toString(),
      status: json['status'],
      isCompleted: json['isCompleted'] ?? json['is_completed'] ?? false,
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'reminder_date': reminderDate,
      'contact_id': contactId,
      'status': status,
      'isCompleted': isCompleted,
    };
  }
}

class ContactEvent {
  final String? id;
  final String type; // e.g., 'Birthday', 'Anniversary', 'Work', 'Custom'
  final DateTime date;
  final String? label;

  ContactEvent({
    this.id,
    required this.type,
    required this.date,
    this.label,
  });

  factory ContactEvent.fromJson(Map<String, dynamic> json) {
    return ContactEvent(
      id: json['id'],
      type: json['type'] ?? 'Custom',
      date: DateTime.parse(json['date']),
      label: json['label'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'type': type,
      'date': date.toIso8601String().split('T')[0],
      'label': label,
    };
  }
}

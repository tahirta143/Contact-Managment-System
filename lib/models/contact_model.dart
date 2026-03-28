import '../core/utils/date_helper.dart';
import 'contact_event_model.dart';

class Contact {
  final String id;
  final String name;               // required
  final String? designation;
  final String? reference;
  final String? photoUrl;
  final String? profession;
  final String? speciality;
  final String? company;
  final String? phone;
  final String? mobile;
  final String? whatsapp;
  final String? address;
  final String? permanentAddress;
  final String? city;
  final DateTime? birthday;        // stored as date only (no time)
  final DateTime? anniversary;     // stored as date only (no time)
  final int? reminderDaysBefore;   // days before to send notification (default: 1)
  final List<ContactEvent> events;
  final List<String> groups;       // group/category tags for the contact
  final DateTime createdAt;

  Contact({
    required this.id,
    required this.name,
    this.designation,
    this.reference,
    this.photoUrl,
    this.profession,
    this.speciality,
    this.company,
    this.phone,
    this.mobile,
    this.whatsapp,
    this.address,
    this.permanentAddress,
    this.city,
    this.birthday,
    this.anniversary,
    this.reminderDaysBefore,
    this.events = const [],
    this.groups = const [],
    required this.createdAt,
  });

  // computed getters (use in UI):
  int? get age => birthday != null ? DateHelper.calculateAge(birthday!) : null;
  int? get marriageYears => anniversary != null ? DateHelper.calculateYears(anniversary!) : null;
  int? get daysUntilBirthday => birthday != null ? DateHelper.daysUntilNextOccurrence(birthday!) : null;
  int? get daysUntilAnniversary => anniversary != null ? DateHelper.daysUntilNextOccurrence(anniversary!) : null;

  factory Contact.fromJson(Map<String, dynamic> json) {
    // Parse groups - backend returns a List (already parsed in mapContactRow)
    final rawGroups = json['groups'];
    List<String> parsedGroups = [];
    if (rawGroups is List) {
      parsedGroups = rawGroups.map((g) => g.toString()).toList();
    } else if (rawGroups is String && rawGroups.isNotEmpty) {
      parsedGroups = rawGroups.split(',').map((g) => g.trim()).where((g) => g.isNotEmpty).toList();
    }

    return Contact(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      designation: json['designation'],
      reference: json['reference'],
      photoUrl: json['photoUrl'],
      profession: json['profession'],
      speciality: json['speciality'],
      company: json['company'],
      phone: json['phone'],
      mobile: json['mobile'],
      whatsapp: json['whatsapp'],
      address: json['address'],
      permanentAddress: json['permanentAddress'],
      city: json['city'],
      birthday: json['birthday'] != null ? DateTime.parse(json['birthday']) : null,
      anniversary: json['anniversary'] != null ? DateTime.parse(json['anniversary']) : null,
      reminderDaysBefore: json['reminderDaysBefore'],
      events: (json['events'] as List<dynamic>?)
              ?.map((e) => ContactEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      groups: parsedGroups,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'designation': designation,
      'reference': reference,
      'photoUrl': photoUrl,
      'profession': profession,
      'speciality': speciality,
      'company': company,
      'phone': phone,
      'mobile': mobile,
      'whatsapp': whatsapp,
      'address': address,
      'permanentAddress': permanentAddress,
      'city': city,
      'birthday': birthday?.toIso8601String(),
      'anniversary': anniversary?.toIso8601String(),
      'reminderDaysBefore': reminderDaysBefore,
      'events': events.map((e) => e.toJson()).toList(),
      'groups': groups.join(','),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

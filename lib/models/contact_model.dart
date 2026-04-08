import 'package:flutter/cupertino.dart';

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

  Map<String, dynamic>? get upcomingEvent {
    List<Map<String, dynamic>> allEvents = [];
    
    if (birthday != null) {
      allEvents.add({
        'name': 'Birthday',
        'days': daysUntilBirthday,
        'date': birthday,
      });
    }
    
    if (anniversary != null) {
      allEvents.add({
        'name': 'Anniversary',
        'days': daysUntilAnniversary,
        'date': anniversary,
      });
    }
    
    for (var e in events) {
      // For custom events, use the label if type is 'Other'
      String displayName = e.type;
      if (e.type == 'Other' && e.label != null && e.label!.isNotEmpty) {
        displayName = e.label!;
      }
      
      allEvents.add({
        'name': displayName,
        'days': DateHelper.daysUntilNextOccurrence(e.date),
        'date': e.date,
      });
    }

    if (allEvents.isEmpty) return null;

    // Sort by days until occurrence
    allEvents.sort((a, b) => (a['days'] as int).compareTo(b['days'] as int));

    return allEvents.first;
  }

  factory Contact.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse dates
    DateTime? parseDate(dynamic value) {
      if (value == null || value.toString().isEmpty) return null;
      try {
        return DateTime.parse(value.toString());
      } catch (e) {
        debugPrint("Error parsing date: $value, error: $e");
        return null;
      }
    }

    // Parse groups - handle both List and comma-separated String
    final rawGroups = json['groups'];
    List<String> parsedGroups = [];
    if (rawGroups is List) {
      parsedGroups = rawGroups.map((g) => g.toString()).toList();
    } else if (rawGroups is String && rawGroups.isNotEmpty) {
      parsedGroups = rawGroups.split(',').map((g) => g.trim()).where((g) => g.isNotEmpty).toList();
    }

    return Contact(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unnamed Contact',
      designation: json['designation']?.toString(),
      reference: json['reference']?.toString(),
      photoUrl: json['photoUrl']?.toString(),
      profession: json['profession']?.toString(),
      speciality: json['speciality']?.toString(),
      company: json['company']?.toString(),
      phone: json['phone']?.toString(),
      mobile: json['mobile']?.toString(),
      whatsapp: json['whatsapp']?.toString(),
      address: json['address']?.toString(),
      permanentAddress: json['permanentAddress']?.toString(),
      city: json['city']?.toString(),
      birthday: parseDate(json['birthday']),
      anniversary: parseDate(json['anniversary']),
      reminderDaysBefore: json['reminderDaysBefore'] is int ? json['reminderDaysBefore'] : null,
      events: (json['events'] as List<dynamic>?)
              ?.map((e) => ContactEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      groups: parsedGroups,
      createdAt: parseDate(json['createdAt']) ?? DateTime.now(),
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

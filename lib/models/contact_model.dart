import '../core/utils/date_helper.dart';

class Contact {
  final String id;
  final String name;               // required
  final String? designation;
  final String? reference;
  final String? photoUrl;
  final String? profession;
  final String? speciality;
  final String? phone;
  final String? mobile;
  final String? whatsapp;
  final String? address;
  final String? permanentAddress;
  final String? city;
  final DateTime? birthday;        // stored as date only (no time)
  final DateTime? anniversary;     // stored as date only (no time)
  final int? reminderDaysBefore;   // days before to send notification (default: 1)
  final DateTime createdAt;

  Contact({
    required this.id,
    required this.name,
    this.designation,
    this.reference,
    this.photoUrl,
    this.profession,
    this.speciality,
    this.phone,
    this.mobile,
    this.whatsapp,
    this.address,
    this.permanentAddress,
    this.city,
    this.birthday,
    this.anniversary,
    this.reminderDaysBefore,
    required this.createdAt,
  });

  // computed getters (use in UI):
  int? get age => birthday != null ? DateHelper.calculateAge(birthday!) : null;
  int? get marriageYears => anniversary != null ? DateHelper.calculateYears(anniversary!) : null;
  int? get daysUntilBirthday => birthday != null ? DateHelper.daysUntilNextOccurrence(birthday!) : null;
  int? get daysUntilAnniversary => anniversary != null ? DateHelper.daysUntilNextOccurrence(anniversary!) : null;

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      designation: json['designation'],
      reference: json['reference'],
      photoUrl: json['photoUrl'],
      profession: json['profession'],
      speciality: json['speciality'],
      phone: json['phone'],
      mobile: json['mobile'],
      whatsapp: json['whatsapp'],
      address: json['address'],
      permanentAddress: json['permanentAddress'],
      city: json['city'],
      birthday: json['birthday'] != null ? DateTime.parse(json['birthday']) : null,
      anniversary: json['anniversary'] != null ? DateTime.parse(json['anniversary']) : null,
      reminderDaysBefore: json['reminderDaysBefore'],
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
      'phone': phone,
      'mobile': mobile,
      'whatsapp': whatsapp,
      'address': address,
      'permanentAddress': permanentAddress,
      'city': city,
      'birthday': birthday?.toIso8601String(),
      'anniversary': anniversary?.toIso8601String(),
      'reminderDaysBefore': reminderDaysBefore,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

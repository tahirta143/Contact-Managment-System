import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/contact_service.dart';
import '../models/contact_model.dart';

final contactServiceProvider = Provider((ref) => ContactService());

class ContactsState {
  final List<Contact> contacts;
  final bool isLoading;
  final String? error;

  ContactsState({this.contacts = const [], this.isLoading = false, this.error});

  ContactsState copyWith({List<Contact>? contacts, bool? isLoading, String? error}) {
    return ContactsState(
      contacts: contacts ?? this.contacts,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ContactsNotifier extends StateNotifier<ContactsState> {
  final ContactService _contactService;

  ContactsNotifier(this._contactService) : super(ContactsState());

  Future<void> loadContacts({String? search, String? filter}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final contacts = await _contactService.getContacts(search: search, filter: filter);
      state = state.copyWith(contacts: contacts, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> addContact(Map<String, dynamic> contactData, {String? imagePath}) async {
    try {
      final newContact = await _contactService.addContact(contactData, imagePath: imagePath);
      state = state.copyWith(contacts: [newContact, ...state.contacts]);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateContact(String id, Map<String, dynamic> contactData, {String? imagePath}) async {
    try {
      final updatedContact = await _contactService.updateContact(id, contactData, imagePath: imagePath);
      state = state.copyWith(
        contacts: state.contacts.map((c) => c.id == id ? updatedContact : c).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteContact(String id) async {
    try {
      await _contactService.deleteContact(id);
      state = state.copyWith(
        contacts: state.contacts.where((c) => c.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final contactsProvider = StateNotifierProvider<ContactsNotifier, ContactsState>((ref) {
  return ContactsNotifier(ref.watch(contactServiceProvider));
});

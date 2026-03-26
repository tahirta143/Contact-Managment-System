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
}

final contactsProvider = StateNotifierProvider<ContactsNotifier, ContactsState>((ref) {
  return ContactsNotifier(ref.watch(contactServiceProvider));
});

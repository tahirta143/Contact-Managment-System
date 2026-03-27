import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/reminder_service.dart';
import '../models/reminder_model.dart';

final reminderServiceProvider = Provider((ref) => ReminderService());

class RemindersState {
  final List<Reminder> reminders;
  final bool isLoading;
  final String? error;

  RemindersState({this.reminders = const [], this.isLoading = false, this.error});

  RemindersState copyWith({List<Reminder>? reminders, bool? isLoading, String? error}) {
    return RemindersState(
      reminders: reminders ?? this.reminders,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class RemindersNotifier extends StateNotifier<RemindersState> {
  final ReminderService _reminderService;

  RemindersNotifier(this._reminderService) : super(RemindersState());

  Future<void> loadReminders({String? contactId, String? status}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final reminders = await _reminderService.getReminders(contactId: contactId, status: status);
      state = state.copyWith(reminders: reminders, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> addReminder(Map<String, dynamic> reminderData) async {
    try {
      final newReminder = await _reminderService.addReminder(reminderData);
      state = state.copyWith(reminders: [newReminder, ...state.reminders]);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateReminder(String id, Map<String, dynamic> reminderData) async {
    try {
      final updated = await _reminderService.updateReminder(id, reminderData);
      state = state.copyWith(
        reminders: state.reminders.map((r) => r.id == id ? updated : r).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteReminder(String id) async {
    try {
      await _reminderService.deleteReminder(id);
      state = state.copyWith(
        reminders: state.reminders.where((r) => r.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final remindersProvider = StateNotifierProvider<RemindersNotifier, RemindersState>((ref) {
  return RemindersNotifier(ref.watch(reminderServiceProvider));
});

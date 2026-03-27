import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/event_service.dart';

final eventServiceProvider = Provider((ref) => EventService());

final upcomingEventsProvider = FutureProvider.autoDispose.family<List<Map<String, dynamic>>, int>((ref, days) async {
  final eventService = ref.watch(eventServiceProvider);
  return await eventService.getUpcomingEvents(days: days);
});

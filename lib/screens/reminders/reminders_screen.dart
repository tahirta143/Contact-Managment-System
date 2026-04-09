import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/common_widgets.dart';
import '../../providers/events_provider.dart';
import '../../providers/reminders_provider.dart';
import '../../models/reminder_model.dart';
import 'add_reminder_screen.dart';
import '../../core/widgets/custom_loader.dart';
import '../../core/utils/date_helper.dart';
import '../../providers/theme_provider.dart';

// Same event colors as DatesHomeScreen & HomeScreen
const Color kBirthdayColor    = Color(0xFFFF6B9D);
const Color kAnniversaryColor = Color(0xFFFF9500);

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersState = ref.watch(remindersProvider);
    final eventsAsync = ref.watch(upcomingEventsProvider(30)); // next 30 days

    final size   = MediaQuery.of(context).size;
    final sw     = size.width;
    final sh     = size.height;
    final hPad   = sw * 0.045;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context, ref, sw),
      floatingActionButton: FloatingActionButton(
        heroTag: 'reminders_fab',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddReminderScreen()),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add_alert, color: Colors.white),
      ),
      body: (remindersState.isLoading || eventsAsync.isLoading)
          ? const Center(child: CustomLoader(message: "Loading..."))
          : RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(upcomingEventsProvider(30));
          await ref.read(remindersProvider.notifier).loadReminders();
        },
        color: kPrimaryColor,
        child: ListView(
          padding: EdgeInsets.only(bottom: sh * 0.16),
          children: [
            SizedBox(height: sh * 0.016),
            _buildInfoBanner(context, hPad, sw),
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, sh * 0.024, hPad, sh * 0.014),
              child: Text(
                "Upcoming Events",
                style: TextStyle(
                  color: Theme.of(context).textTheme.titleLarge?.color,
                  fontSize: sw * 0.048,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            eventsAsync.when(
              data: (events) {
                if (events.isEmpty) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("No upcoming birthdays or anniversaries"),
                  ));
                }
                return Column(
                  children: List.generate(events.length, (index) {
                    final e = events[index];
                    final int days = e['daysUntil'] ?? 0;
                    return _buildReminderCard(
                      name: e['contactName'] ?? "Unknown",
                      type: e['type'] ?? "Event",
                      label: e['label'],
                      daysUntil: days < 0 ? 0 : days,
                      hPad: hPad, sw: sw, sh: sh,
                      context: context,
                      index: index,
                    );
                  }),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (err, _) => Center(child: Text("Error: $err")),
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(hPad, sh * 0.024, hPad, sh * 0.014),
              child: Text(
                "Custom Reminders",
                style: TextStyle(
                  color: Theme.of(context).textTheme.titleLarge?.color,
                  fontSize: sw * 0.048,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (remindersState.isLoading)
              const SizedBox.shrink()
            else if (remindersState.error != null)
              Center(child: Text(remindersState.error!))
            else if (remindersState.reminders.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.all(20),
                child: Text("No custom reminders set"),
              ))
            else
              Column(
                children: List.generate(remindersState.reminders.length, (index) {
                  final r = remindersState.reminders[index];
                  final date = DateTime.tryParse(r.reminderDate);
                  final int days = date != null ? DateHelper.daysUntilNextOccurrence(date) : 0;
                  return _buildDynamicReminderCard(
                    context: context,
                    ref: ref,
                    id: r.id,
                    title: r.title,
                    description: r.description ?? "",
                    date: r.reminderDate,
                    daysUntil: days < 0 ? 0 : days,
                    isCompleted: r.isCompleted,
                    hPad: hPad, sw: sw, sh: sh,
                    index: index,
                  );
                }),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicReminderCard({
    required BuildContext context,
    required WidgetRef ref,
    required String id,
    required String title,
    required String description,
    required String date,
    required int daysUntil,
    required bool isCompleted,
    required double hPad,
    required double sw,
    required double sh,
    required int index,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 0, hPad, sh * 0.012),
      child: AppCard(
        padding: EdgeInsets.all(sw * 0.038),
        delay: (50 * index).ms,
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                ref.read(remindersProvider.notifier).updateReminder(id, {
                  'isCompleted': !isCompleted,
                  'title': title,
                  'reminderDate': date,
                });
              },
              child: Container(
                width:  sw * 0.12,
                height: sw * 0.12,
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.grey.withOpacity(0.12) : Theme.of(context).primaryColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCompleted ? Icons.check_circle : Icons.notifications_active_outlined,
                  color: isCompleted ? Colors.grey : Theme.of(context).primaryColor,
                  size: sw * 0.058,
                ),
              ),
            ),
            SizedBox(width: sw * 0.035),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isCompleted ? Theme.of(context).textTheme.labelSmall?.color : Theme.of(context).textTheme.titleLarge?.color,
                      fontSize: sw * 0.04,
                      fontWeight: FontWeight.bold,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (description.isNotEmpty)
                    Text(description, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: sw * 0.029)),
                  SizedBox(height: sh * 0.004),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: sw * 0.02, vertical: sh * 0.004),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(sw * 0.015),
                    ),
                    child: Text(date, style: TextStyle(color: Theme.of(context).primaryColor, fontSize: sw * 0.028, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: kError, size: 22),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Delete Reminder"),
                    content: const Text("Are you sure you want to delete this reminder?"),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("CANCEL")),
                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("DELETE", style: TextStyle(color: kError))),
                    ],
                  ),
                );
                if (confirm == true) {
                  await ref.read(remindersProvider.notifier).deleteReminder(id);
                }
              },
            ),
            if (daysUntil == 0)
              Text("Today!", style: TextStyle(color: kError, fontWeight: FontWeight.bold, fontSize: sw * 0.032))
            else
              Column(
                children: [
                  Text("$daysUntil", style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color, fontSize: sw * 0.05, fontWeight: FontWeight.bold)),
                  Text("days", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: sw * 0.024)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref, double sw) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.menu, size: sw * 0.06),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
      title: Text(
        "Reminders",
        style: TextStyle(
          fontSize: sw * 0.048, 
          fontWeight: FontWeight.bold,
          color: Theme.of(context).appBarTheme.titleTextStyle?.color,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            ref.watch(themeProvider) == ThemeMode.dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            size: sw * 0.055,
          ),
          onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
        ),
        SizedBox(width: sw * 0.02),
      ],
    );
  }

  Widget _buildInfoBanner(BuildContext context, double hPad, double sw) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: AppCard(
        padding: EdgeInsets.all(sw * 0.04),
        child: Row(
          children: [
            Container(
              width:  sw * 0.11,
              height: sw * 0.11,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_active,
                color: Theme.of(context).primaryColor,
                size: sw * 0.055,
              ),
            ),
            SizedBox(width: sw * 0.03),
            Expanded(
              child: Text(
                "You'll be notified before each birthday and anniversary",
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: sw * 0.032),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderCard({
    required String name,
    required String type,
    String? label,
    required int daysUntil,
    required double hPad,
    required double sw,
    required double sh,
    required BuildContext context,
    required int index,
  }) {
    final isBirthday = type == "Birthday";
    final isToday    = daysUntil == 0;
    final color      = isBirthday ? kBirthdayColor : kAnniversaryColor;
    final icon       = isBirthday ? Icons.cake : Icons.favorite;

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 0, hPad, sh * 0.012),
      child: AppCard(
        padding: EdgeInsets.all(sw * 0.038),
        delay: (50 * index).ms,
        child: Row(
          children: [
            Container(
              width:  sw * 0.12,
              height: sw * 0.12,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: sw * 0.058),
            ),
            SizedBox(width: sw * 0.035),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.titleLarge?.color,
                      fontSize: sw * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: sh * 0.004),
                  Text(
                    label != null && label.isNotEmpty ? "$type: $label" : type,
                    style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: sw * 0.029),
                  ),
                ],
              ),
            ),

            if (isToday)
              Text("Today!", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: sw * 0.032))
            else
              Column(
                children: [
                  Text(
                    "$daysUntil",
                    style: TextStyle(
                      color: Theme.of(context).textTheme.titleLarge?.color,
                      fontSize: sw * 0.058,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "days",
                    style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: sw * 0.026),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

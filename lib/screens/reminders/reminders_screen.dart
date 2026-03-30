import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/common_widgets.dart';
import '../../providers/events_provider.dart';
import '../../providers/reminders_provider.dart';
import '../../models/reminder_model.dart';
import 'add_reminder_screen.dart';
import '../../core/widgets/custom_loader.dart';
import '../../core/utils/date_helper.dart';

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
      backgroundColor: kScaffoldBg,
      appBar: _buildAppBar(context, sw),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddReminderScreen()),
        ),
        backgroundColor: kPrimaryColor,
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
            _buildInfoBanner(hPad, sw),
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, sh * 0.024, hPad, sh * 0.014),
              child: Text(
                "Upcoming Events",
                style: TextStyle(
                  color: kTextPrimary,
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
                  children: events.map((e) {
                    final int days = e['daysUntil'] ?? 0;
                    return _buildReminderCard(
                      name: e['contactName'] ?? "Unknown",
                      type: e['type'] ?? "Event",
                      label: e['label'],
                      // date: e['date'] ?? "",
                      daysUntil: days < 0 ? 0 : days,
                      hPad: hPad, sw: sw, sh: sh,
                    );
                  }).toList(),
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
                  color: kTextPrimary,
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
                children: remindersState.reminders.map((r) {
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
                  );
                }).toList(),
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
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 0, hPad, sh * 0.012),
      child: AppCard(
        borderRadius: sw * 0.04,
        padding: EdgeInsets.all(sw * 0.038),
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
                  color: isCompleted ? Colors.grey.withOpacity(0.12) : kPrimaryColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCompleted ? Icons.check_circle : Icons.notifications_active_outlined,
                  color: isCompleted ? Colors.grey : kPrimaryColor,
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
                      color: isCompleted ? kTextTertiary : kTextPrimary,
                      fontSize: sw * 0.04,
                      fontWeight: FontWeight.bold,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (description.isNotEmpty)
                    Text(description, style: TextStyle(color: kTextSecondary, fontSize: sw * 0.029)),
                  SizedBox(height: sh * 0.004),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: sw * 0.02, vertical: sh * 0.004),
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(sw * 0.015),
                    ),
                    child: Text(date, style: TextStyle(color: kPrimaryColor, fontSize: sw * 0.028, fontWeight: FontWeight.bold)),
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
                  Text("$daysUntil", style: TextStyle(color: kTextPrimary, fontSize: sw * 0.05, fontWeight: FontWeight.bold)),
                  Text("days", style: TextStyle(color: kTextSecondary, fontSize: sw * 0.024)),
                ],
              ),
          ],
        ),
      ),
    );
  }


  // ── AppBar ────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context, double sw) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.menu, size: sw * 0.06),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
      title: Text(
        "Reminders",
        style: TextStyle(fontSize: sw * 0.048, fontWeight: FontWeight.bold),
      ),
      actions: [SizedBox(width: sw * 0.12)],
    );
  }

  // ── Info banner ───────────────────────────────────────────────────────────
  Widget _buildInfoBanner(double hPad, double sw) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: AppCard(
        borderRadius: sw * 0.04,
        padding: EdgeInsets.all(sw * 0.04),
        child: Row(
          children: [
            Container(
              width:  sw * 0.11,
              height: sw * 0.11,
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_active,
                color: kPrimaryColor,
                size: sw * 0.055,
              ),
            ),
            SizedBox(width: sw * 0.03),
            Expanded(
              child: Text(
                "You'll be notified before each birthday and anniversary",
                style: TextStyle(color: kTextSecondary, fontSize: sw * 0.032),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section pill — matches DatesHomeScreen section badges ─────────────────
  Widget _buildSectionPill(
      String title,
      Color color,
      double hPad,
      double sw,
      double sh,
      ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 0, hPad, sh * 0.012),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: sw * 0.04,
              vertical:   sh * 0.009,
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(sw * 0.03),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: sw * 0.016, height: sw * 0.016,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                SizedBox(width: sw * 0.015),
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: sw * 0.034,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Reminder card — mirrors DatesHomeScreen _buildEventCard ───────────────
  Widget _buildReminderCard({
    required String name,
    required String type,
    String? label,
    // required String date,
    required int daysUntil,
    required double hPad,
    required double sw,
    required double sh,
  }) {
    final isBirthday = type == "Birthday";
    final isToday    = daysUntil == 0;
    final color      = isBirthday ? kBirthdayColor : kAnniversaryColor;
    final icon       = isBirthday ? Icons.cake : Icons.favorite;

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 0, hPad, sh * 0.012),
      child: AppCard(
        borderRadius: sw * 0.04,
        padding: EdgeInsets.all(sw * 0.038),
        child: Row(
          children: [
            // Themed icon circle — same as DatesHomeScreen
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

            // Name + type + date badge
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: kTextPrimary,
                      fontSize: sw * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: sh * 0.004),
                  Text(
                    label != null && label.isNotEmpty ? "$type: $label" : type,
                    style: TextStyle(color: kTextSecondary, fontSize: sw * 0.029),
                  ),
                  SizedBox(height: sh * 0.004),
                  // Colored date badge — same pattern as DatesHomeScreen
                  // Container(
                  //   padding: EdgeInsets.symmetric(
                  //     horizontal: sw * 0.02,
                  //     vertical:   sh * 0.004,
                  //   ),
                  //   decoration: BoxDecoration(
                  //     color: color.withOpacity(0.12),
                  //     borderRadius: BorderRadius.circular(sw * 0.015),
                  //   ),
                  //   // child: Text(
                  //   //   // date,
                  //   //   style: TextStyle(
                  //   //     color: color,
                  //   //     fontSize: sw * 0.028,
                  //   //     fontWeight: FontWeight.bold,
                  //   //   ),
                  //   // ),
                  // ),
                ],
              ),
            ),

            // Right side: "Today!" badge or days counter
            if (isToday)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.03,
                  vertical:   sh * 0.008,
                ),
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.circular(sw * 0.05),
                ),
                child: Text(
                  "Today!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: sw * 0.03,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              Column(
                children: [
                  Text(
                    "$daysUntil",
                    style: TextStyle(
                      color: kTextPrimary,
                      fontSize: sw * 0.058,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "days",
                    style: TextStyle(color: kTextSecondary, fontSize: sw * 0.026),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/common_widgets.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final horizontalPadding = size.width * 0.05;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(context),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          const SizedBox(height: 16),
          _buildInfoBanner(horizontalPadding),
          Padding(
            padding: EdgeInsets.fromLTRB(horizontalPadding, 24, horizontalPadding, 12),
            child: const Text(
              "Upcoming Reminders",
              style: TextStyle(color: kTextPrimary, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ..._buildRemindersListItems(horizontalPadding),
        ],
      ),
    );
  }

  List<Widget> _buildRemindersListItems(double horizontalPadding) {
    return [
      _buildSectionHeader("Today", horizontalPadding),
      _buildReminderCard(
        name: "Ali Raza",
        type: "Birthday",
        date: "26 March",
        daysUntil: 0,
        padding: horizontalPadding,
      ),
      
      const SizedBox(height: 16),
      _buildSectionHeader("This Week", horizontalPadding),
      _buildReminderCard(
        name: "Sara & Usman",
        type: "Anniversary",
        date: "29 March",
        daysUntil: 3,
        padding: horizontalPadding,
      ),
      _buildReminderCard(
        name: "Zainab",
        type: "Birthday",
        date: "1 April",
        daysUntil: 6,
        padding: horizontalPadding,
      ),
      
      const SizedBox(height: 16),
      _buildSectionHeader("This Month", horizontalPadding),
      _buildReminderCard(
        name: "Hassan Ali",
        type: "Birthday",
        date: "15 April",
        daysUntil: 20,
        padding: horizontalPadding,
      ),
    ];
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
      title: const Text("Reminders"),
      actions: const [SizedBox(width: 48)],
    );
  }

  Widget _buildInfoBanner(double horizontalPadding) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: AppCard(
        borderRadius: 16,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.notifications_active, color: kPrimaryColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "You'll be notified before each birthday and anniversary",
                style: TextStyle(color: kTextSecondary, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildSectionHeader(String title, double horizontalPadding) {
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: kPrimaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          title,
          style: const TextStyle(color: kPrimaryColor, fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildReminderCard({
    required String name,
    required String type,
    required String date,
    required int daysUntil,
    required double padding,
  }) {
    final isBirthday = type == "Birthday";
    final isToday = daysUntil == 0;
    final color = isBirthday ? kPrimaryColor : Colors.purple;
    final icon = isBirthday ? Icons.cake : Icons.favorite;

    return Padding(
      padding: EdgeInsets.fromLTRB(padding, 0, padding, 12),
      child: AppCard(
        borderRadius: 16,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(color: kTextPrimary, fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(type, style: TextStyle(color: kTextSecondary, fontSize: 12)),
                  Text(date, style: TextStyle(color: kTextTertiary, fontSize: 12)),
                ],
              ),
            ),
            if (isToday)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                margin: const EdgeInsets.only(left: 16),
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text("Today!", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              )
            else
              Column(
                children: [
                  Text(daysUntil.toString(), style: const TextStyle(color: kTextPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
                  const Text("days", style: TextStyle(color: kTextSecondary, fontSize: 11)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off, size: 64, color: Colors.white.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(
            "No upcoming reminders",
            style: TextStyle(color: kTextTertiary, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

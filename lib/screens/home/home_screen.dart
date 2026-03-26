import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/common_widgets.dart';
import '../../providers/auth_provider.dart';
import '../../providers/contacts_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final size = MediaQuery.of(context).size;
    final horizontalPadding = size.width * 0.045;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildGreetingCard(user?.name ?? "User", horizontalPadding),
            const SizedBox(height: 24),
            _buildSummaryCards(horizontalPadding),
            const SizedBox(height: 24),
            _buildSectionHeader(AppStrings.todayBirthdays, horizontalPadding),
            _buildBirthdayRow(horizontalPadding),
            const SizedBox(height: 24),
            _buildSectionHeader(AppStrings.todayAnniversaries, horizontalPadding),
            _buildAnniversaryRow(horizontalPadding),
            const SizedBox(height: 24),
            _buildSectionHeader("Upcoming Reminders", horizontalPadding),
            _buildUpcomingList(horizontalPadding),
          ],
            ),
          ),
        );
  }

  Widget _buildGreetingCard(String name, double horizontalPadding) {
    final now = DateTime.now();
    final formattedDate = DateFormat('EEEE, d MMMM yyyy').format(now);
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: AppCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Good afternoon, $name!",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              formattedDate,
              style: const TextStyle(fontSize: 13, color: kTextSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(double horizontalPadding) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.9,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      children: [
        _buildCountCard("Total Contacts", 128, Icons.people_outline),
        _buildCountCard("Today's Events", 02, Icons.event_available),
        _buildCountCard("Upcoming", 15, Icons.upcoming),
        _buildCountCard("Groups", 08, Icons.group_work_outlined),
      ],
    );
  }

  Widget _buildCountCard(String title, int count, IconData icon) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: kPrimaryColor, size: 20),
              AnimatedCountText(
                count: count,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: kTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
      title: const Text(AppStrings.appName),
      actions: [
        const Padding(
          padding: EdgeInsets.only(right: 16),
          child: GradientAvatar(radius: 18, initials: "AD"),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, double horizontalPadding) {
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 16),
      child: Row(
        children: [
          Container(width: 4, height: 20, color: kPrimaryColor),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kTextPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildBirthdayRow(double horizontalPadding) {
    // Mock data for now
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 130,
            margin: const EdgeInsets.only(right: 12),
            child: AppCard(
              borderRadius: 16,
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  const GradientAvatar(radius: 20, initials: "K"),
                  const SizedBox(height: 8),
                  const Text("Kashif", style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w600, fontSize: 13), overflow: TextOverflow.ellipsis),
                  Text("Birthday Today!", style: TextStyle(color: kTextSecondary, fontSize: 10)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnniversaryRow(double horizontalPadding) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: const Text("No anniversaries today 🍰", style: TextStyle(color: kTextTertiary, fontSize: 13)),
    );
  }

  Widget _buildUpcomingList(double horizontalPadding) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      itemCount: 2,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AppCard(
            borderRadius: 16,
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    index == 0 ? Icons.cake : Icons.favorite,
                    color: kPrimaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Ali Ahmed", style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(
                        index == 0 ? "Birthday · 28 March" : "Anniversary · 30 March",
                        style: const TextStyle(color: kTextSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: kInputBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "in ${index + 2} days",
                    style: const TextStyle(color: kTextSecondary, fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }




  Widget _buildFAB() {
    return FloatingActionButton(
      backgroundColor: kButtonColor,
      onPressed: () {},
      shape: const CircleBorder(),
      child: const Icon(Icons.add, color: Colors.white),
    );
  }
}

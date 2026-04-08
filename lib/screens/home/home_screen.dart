import 'package:contacts_management/screens/contacts/add_contact_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/api_constants.dart';
import '../../core/utils/common_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/auth_provider.dart';
import '../../providers/contacts_provider.dart';
import '../../providers/events_provider.dart';
import '../../providers/reminders_provider.dart';
import '../dates/dates_home_screen.dart';
import '../../core/utils/date_helper.dart';
import '../../core/widgets/custom_loader.dart';

// ─── Themed colors for icons (independent of AppBar/primary color) ───────────
const Color kBirthdayColor    = Color(0xFFFF6B9D); // pink
const Color kAnniversaryColor = Color(0xFFFF9500); // amber/gold
const Color kContactsColor    = Color(0xFF4C9EFF); // blue
const Color kEventsColor      = Color(0xFF34C759); // green
const Color kUpcomingColor    = Color(0xFFAF52DE); // purple
const Color kGroupsColor      = Color(0xFFFF6B6B); // coral-red


// ─── HomeScreen ───────────────────────────────────────────────────────────────
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  DateTime _selectedHomeDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(contactsProvider.notifier).loadContacts();
      ref.read(remindersProvider.notifier).loadReminders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final size = MediaQuery.of(context).size;
    final sw   = size.width;
    final sh   = size.height;
    final hPad = sw * 0.045;

    // ── Must match the height of your bottom nav bar ──────────────────────
    const double bottomNavHeight = 90.0;
    const double fabMargin       = 32.0;

    // Scroll content clears both the nav bar and the FAB above it
    final double scrollBottomPad = bottomNavHeight + 80 + fabMargin;

    final contactsState = ref.watch(contactsProvider);
    final upcomingEvents = ref.watch(upcomingEventsProvider(30));
    final remindersState = ref.watch(remindersProvider);

    // Filter events based on _selectedHomeDate
    final dateStr = DateFormat('MM-dd').format(_selectedHomeDate);
    final isToday = DateFormat('yyyy-MM-dd').format(_selectedHomeDate) == DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    List<Map<String, dynamic>> selectedDateBirthdays = [];
    List<Map<String, dynamic>> selectedDateAnniversaries = [];
    List<Map<String, dynamic>> selectedDateCustomEvents = [];
    List<Map<String, dynamic>> upcomingReminders = [];

    upcomingEvents.whenData((events) {
      for (var e in events) {
        final eventDate = e['date'] != null ? DateTime.parse(e['date']) : null;
        if (eventDate != null) {
          final eventDateStr = DateFormat('MM-dd').format(eventDate);
          if (eventDateStr == dateStr) {
            if (e['type'] == 'Birthday') {
              selectedDateBirthdays.add(e);
            } else if (e['type'] == 'Anniversary') {
              selectedDateAnniversaries.add(e);
            } else {
              // Custom events happening on this date
              selectedDateCustomEvents.add(e);
            }
          } else {
            upcomingReminders.add(e);
          }
        }
      }
    });

    final Set<String> uniqueGroups = {};
    for (var c in contactsState.contacts) {
      if (c.groups != null) {
        uniqueGroups.addAll(c.groups!.map((g) => g.toString()));
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(sw),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: bottomNavHeight + fabMargin),
        child: _buildFAB(sw),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: (contactsState.isLoading || remindersState.isLoading)
          ? const Center(child: CustomLoader(message: "Loading..."))
          : RefreshIndicator(
        onRefresh: () async {
          ref.read(contactsProvider.notifier).loadContacts();
          ref.read(remindersProvider.notifier).loadReminders();
          ref.invalidate(upcomingEventsProvider(30));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(bottom: scrollBottomPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: sh * 0.02),
              _buildGreetingCard(user?.name ?? "User", hPad, sw, sh),
              SizedBox(height: sh * 0.02),
              
              // Date picker row
              Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                child: GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedHomeDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      builder: (ctx, child) => Theme(
                        data: Theme.of(ctx).copyWith(
                          colorScheme: const ColorScheme.light(primary: kPrimaryColor),
                        ),
                        child: child!,
                      ),
                    );
                    if (date != null) {
                      setState(() => _selectedHomeDate = date);
                      // Trigger a fresh data load when date changes
                      ref.read(contactsProvider.notifier).loadContacts();
                      ref.read(remindersProvider.notifier).loadReminders();
                      ref.invalidate(upcomingEventsProvider(30));
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sh * 0.016),
                    decoration: BoxDecoration(
                      color: Theme.of(context).inputDecorationTheme.fillColor ?? const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(sw * 0.05),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_month, color: kPrimaryColor, size: sw * 0.05),
                        SizedBox(width: sw * 0.02),
                        Text(
                          isToday ? "Today, " + DateFormat('dd MMM yyyy').format(_selectedHomeDate) : DateFormat('dd MMMM yyyy').format(_selectedHomeDate),
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color ?? kTextPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: sw * 0.04,
                          ),
                        ),
                        SizedBox(width: sw * 0.02),
                        Icon(Icons.arrow_drop_down, color: Theme.of(context).textTheme.bodyMedium?.color ?? kTextSecondary, size: sw * 0.055),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: sh * 0.028),

              _buildSummaryCards(
                contactsCount: contactsState.contacts.length,
                todayEventsCount: selectedDateBirthdays.length + selectedDateAnniversaries.length + selectedDateCustomEvents.length,
                upcomingCount: upcomingReminders.length,
                groupsCount: uniqueGroups.length,
                hPad: hPad, sw: sw, sh: sh,
              ),
              SizedBox(height: sh * 0.028),
              if (selectedDateBirthdays.isNotEmpty) ...[
                _buildSectionHeader(isToday ? AppStrings.todayBirthdays : "Birthdays (${DateFormat('dd MMM').format(_selectedHomeDate)})", hPad, kBirthdayColor, sw, sh),
                _buildBirthdayRow(selectedDateBirthdays, hPad, sw, sh),
                SizedBox(height: sh * 0.028),
              ],
              if (selectedDateAnniversaries.isNotEmpty) ...[
                _buildSectionHeader(isToday ? AppStrings.todayAnniversaries : "Anniversaries (${DateFormat('dd MMM').format(_selectedHomeDate)})", hPad, kAnniversaryColor, sw, sh),
                _buildAnniversaryRow(selectedDateAnniversaries, hPad, sw),
                SizedBox(height: sh * 0.028),
              ],
              if (selectedDateCustomEvents.isNotEmpty) ...[
                _buildSectionHeader(isToday ? "Today's Events" : "Events (${DateFormat('dd MMM').format(_selectedHomeDate)})", hPad, kCustomEventColor, sw, sh),
                _buildCustomEventRow(selectedDateCustomEvents, hPad, sw, sh),
                SizedBox(height: sh * 0.028),
              ],
              _buildSectionHeader("Upcoming Events", hPad, kUpcomingColor, sw, sh),
              upcomingEvents.when(
                data: (events) => _buildUpcomingList(upcomingReminders, hPad, sw, sh),
                loading: () => const SizedBox.shrink(), // Already handled by full screen loader
                error: (e, __) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  child: Text("Error: $e", style: const TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }

  // ── AppBar ───────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(double sw) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.menu, size: sw * 0.06),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
      title: Text(
        AppStrings.appName,
        style: TextStyle(fontSize: sw * 0.048, fontWeight: FontWeight.bold),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: sw * 0.04),
          child: ref.watch(authProvider).user?.photoUrl != null
              ? CircleAvatar(
                  radius: sw * 0.045,
                  backgroundImage: CachedNetworkImageProvider(
                    ref.watch(authProvider).user!.photoUrl!.startsWith('http')
                        ? ref.watch(authProvider).user!.photoUrl!
                        : "${ApiConstants.baseImageUrl}${ref.watch(authProvider).user!.photoUrl}",
                  ),
                )
              : GradientAvatar(
                  radius: sw * 0.045,
                  initials: ref.watch(authProvider).user?.name.isNotEmpty == true
                      ? ref.watch(authProvider).user!.name[0].toUpperCase()
                      : "U",
                ),
        ),
      ],
    );
  }

  // ── Greeting card ────────────────────────────────────────────────────────
  Widget _buildGreetingCard(String name, double hPad, double sw, double sh) {
    final now  = DateTime.now();
    final date = DateFormat('EEEE, d MMMM yyyy').format(now);
    final hour = now.hour;
    
    String greeting;
    IconData timeIcon;
    List<Color> gradientColors;

    if (hour < 12) {
      greeting = "Good morning";
      timeIcon = Icons.wb_sunny_rounded;
      gradientColors = [const Color(0xFFF7971E), const Color(0xFFFFD200)]; // Vibrant sunrise
    } else if (hour < 17) {
      greeting = "Good afternoon";
      timeIcon = Icons.cloud_rounded;
      gradientColors = [const Color(0xff21b2d5), const Color(0xff29b3d5)]; // Bright afternoon
    } else {
      greeting = "Good evening";
      timeIcon = Icons.nights_stay_rounded;
      gradientColors = [const Color(0xFF2C3E50), const Color(0xFF3498DB)]; // Evening dusk
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(sw * 0.06),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(sw * 0.05),
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date.toUpperCase(),
                    style: TextStyle(
                      fontSize: sw * 0.028,
                      color: Colors.white.withOpacity(0.85),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: sh * 0.006),
                  Text(
                    "$greeting,\n$name!",
                    style: TextStyle(
                      fontSize: sw * 0.052,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(sw * 0.035),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: Icon(timeIcon, color: Colors.white, size: sw * 0.08),
            ),
          ],
        ),
      ),
    );
  }

  // ── Summary cards ────────────────────────────────────────────────────────
  Widget _buildSummaryCards({
    required int contactsCount,
    required int todayEventsCount,
    required int upcomingCount,
    required int groupsCount,
    required double hPad,
    required double sw,
    required double sh,
  }) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: sw * 0.03,
      crossAxisSpacing: sw * 0.03,
      childAspectRatio: 1.9,
      padding: EdgeInsets.symmetric(horizontal: hPad),
      children: [
        _buildCountCard("Total Contacts", contactsCount, Icons.people_outline,      kContactsColor, sw, sh),
        _buildCountCard("Today's Events", todayEventsCount,   Icons.event_available,     kEventsColor,   sw, sh),
        _buildCountCard("Upcoming",       upcomingCount,  Icons.upcoming,            kUpcomingColor, sw, sh),
        _buildCountCard("Groups",         groupsCount,    Icons.group_work_outlined, kGroupsColor,   sw, sh),
      ],
    );
  }

  Widget _buildCountCard(String title, int count, IconData icon, Color iconColor, double sw, double sh) {
    return AppCard(
      padding: EdgeInsets.all(sw * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: iconColor, size: sw * 0.05),
              Text(
                count.toString(),
                style: TextStyle(fontSize: sw * 0.045, fontWeight: FontWeight.bold, color: kTextPrimary),
              ),
            ],
          ),
          SizedBox(height: sh * 0.008),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: sw * 0.028, color: kTextSecondary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // ── Section header ───────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title, double hPad, Color accentColor, double sw, double sh) {
    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 0, hPad, sh * 0.018),
      child: Row(
        children: [
          Container(width: sw * 0.01, height: sh * 0.028, color: accentColor),
          SizedBox(width: sw * 0.025),
          Text(
            title,
            style: TextStyle(fontSize: sw * 0.04, fontWeight: FontWeight.bold, color: kTextPrimary),
          ),
        ],
      ),
    );
  }

  // ── Birthday row ─────────────────────────────────────────────────────────
  Widget _buildBirthdayRow(List<Map<String, dynamic>> items, double hPad, double sw, double sh) {
    return SizedBox(
      height: sh * 0.15,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: hPad),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            width: sw * 0.32,
            margin: EdgeInsets.only(right: sw * 0.03),
            child: AppCard(
              borderRadius: sw * 0.04,
              padding: EdgeInsets.all(sw * 0.03),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  item['photoUrl'] != null
                      ? CircleAvatar(
                          radius: sw * 0.05,
                          backgroundImage: CachedNetworkImageProvider(
                            item['photoUrl'].startsWith('http')
                                ? item['photoUrl']
                                : "${ApiConstants.baseImageUrl}${item['photoUrl']}",
                          ),
                        )
                      : GradientAvatar(
                          radius: sw * 0.05,
                          initials: item['contactName']?[0] ?? item['name']?[0] ?? "U",
                        ),
                  SizedBox(height: sh * 0.008),
                  Text(
                    item['contactName'] ?? item['name'] ?? "Contact",
                    style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w600, fontSize: sw * 0.032),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: sh * 0.003),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cake, color: kBirthdayColor, size: sw * 0.028),
                      SizedBox(width: sw * 0.008),
                      Flexible(
                        child: Text(
                          item['type'] ?? "Today!",
                          style: TextStyle(color: kBirthdayColor, fontSize: sw * 0.024),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnniversaryRow(List<Map<String, dynamic>> items, double hPad, double sw) {
    if (items.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: hPad),
        child: Row(
          children: [
            Icon(Icons.favorite, color: kAnniversaryColor, size: sw * 0.04),
            SizedBox(width: sw * 0.015),
            Text(
              "No anniversaries today 🍰",
              style: TextStyle(color: kTextTertiary, fontSize: sw * 0.032),
            ),
          ],
        ),
      );
    }
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: hPad),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                Icon(Icons.favorite, color: kAnniversaryColor, size: sw * 0.04),
                SizedBox(width: sw * 0.015),
                Text(
                  "${item['name']}'s Anniversary!",
                  style: TextStyle(color: kTextPrimary, fontSize: sw * 0.032, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Custom Event row ─────────────────────────────────────────────────────
  Widget _buildCustomEventRow(List<Map<String, dynamic>> items, double hPad, double sw, double sh) {
    return SizedBox(
      height: sh * 0.15,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: hPad),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            width: sw * 0.32,
            margin: EdgeInsets.only(right: sw * 0.03),
            child: AppCard(
              borderRadius: sw * 0.04,
              padding: EdgeInsets.all(sw * 0.03),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  item['photoUrl'] != null
                      ? CircleAvatar(
                          radius: sw * 0.05,
                          backgroundImage: CachedNetworkImageProvider(
                            item['photoUrl'].startsWith('http')
                                ? item['photoUrl']
                                : "${ApiConstants.baseImageUrl}${item['photoUrl']}",
                          ),
                        )
                      : GradientAvatar(
                          radius: sw * 0.05,
                          initials: item['contactName']?[0] ?? item['name']?[0] ?? "U",
                        ),
                  SizedBox(height: sh * 0.008),
                  Text(
                    item['contactName'] ?? item['name'] ?? "Contact",
                    style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w600, fontSize: sw * 0.032),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: sh * 0.003),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event, color: kCustomEventColor, size: sw * 0.028),
                      SizedBox(width: sw * 0.008),
                      Flexible(
                        child: Text(
                          item['label'] != null && item['label'].isNotEmpty
                              ? item['label']
                              : (item['type'] ?? "Event"),
                          style: TextStyle(color: kCustomEventColor, fontSize: sw * 0.024),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Upcoming reminders list ──────────────────────────────────────────────
  Widget _buildUpcomingList(List<Map<String, dynamic>> items, double hPad, double sw, double sh) {
    if (items.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: hPad),
        child: Text("No upcoming events in next 30 days", style: TextStyle(color: kTextTertiary, fontSize: sw * 0.032)),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: hPad),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final eventDate = item['date'] != null ? DateTime.parse(item['date']) : null;
        final int difference = item['daysUntil'] ?? 0;
        final formattedDate = eventDate != null ? DateFormat('d MMMM').format(eventDate) : "";

        return Padding(
          padding: EdgeInsets.only(bottom: sh * 0.014),
          child: AppCard(
            borderRadius: sw * 0.04,
            padding: EdgeInsets.all(sw * 0.035),
            child: Row(
              children: [
                Container(
                  width: sw * 0.1,
                  height: sw * 0.1,
                  decoration: BoxDecoration(
                    color: (item['type'] == 'Birthday' ? kBirthdayColor : kAnniversaryColor).withOpacity(0.10),
                    shape: BoxShape.circle
                  ),
                  child: item['photoUrl'] != null
                      ? CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(
                            item['photoUrl'].startsWith('http')
                                ? item['photoUrl']
                                : "${ApiConstants.baseImageUrl}${item['photoUrl']}",
                          ),
                        )
                      : Icon(
                          item['type'] == 'Birthday' ? Icons.cake : Icons.favorite,
                          color: item['type'] == 'Birthday' ? kBirthdayColor : kAnniversaryColor,
                          size: sw * 0.05
                        ),
                ),
                SizedBox(width: sw * 0.035),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['contactName'] ?? item['name'] ?? "Contact",
                        style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold, fontSize: sw * 0.038),
                      ),
                      SizedBox(height: sh * 0.003),
                      Text(
                        "${item['type']}${item['label'] != null && item['label'].isNotEmpty ? ' (${item['label']})' : ''} · $formattedDate",
                        style: TextStyle(color: kTextSecondary, fontSize: sw * 0.029),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: sw * 0.025, vertical: sh * 0.005),
                  decoration: BoxDecoration(
                    color: (item['type'] == 'Birthday' ? kBirthdayColor : kAnniversaryColor).withOpacity(0.10),
                    borderRadius: BorderRadius.circular(sw * 0.03),
                  ),
                  child: Text(
                    DateHelper.countdownText(difference),
                    style: TextStyle(
                      color: item['type'] == 'Birthday' ? kBirthdayColor : kAnniversaryColor,
                      fontSize: sw * 0.027,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── FAB ──────────────────────────────────────────────────────────────────
  Widget _buildFAB(double sw) {
    return SizedBox(
      width: sw * 0.14,
      height: sw * 0.14,
      child: FloatingActionButton(
        backgroundColor: kButtonColor,
        onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context)=>AddContactScreen()));},
        shape: const CircleBorder(),
        child: Icon(Icons.add, color: Colors.white, size: sw * 0.07),
      ),
    );
  }
}

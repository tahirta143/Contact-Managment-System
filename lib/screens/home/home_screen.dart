import 'package:contacts_management/screens/contacts/add_contact_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
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
import '../../providers/theme_provider.dart';

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
    final selMonth = _selectedHomeDate.month;
    final selDay   = _selectedHomeDate.day;
    final isToday = DateFormat('yyyy-MM-dd').format(_selectedHomeDate) == DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    List<Map<String, dynamic>> selectedDateBirthdays = [];
    List<Map<String, dynamic>> selectedDateAnniversaries = [];
    List<Map<String, dynamic>> selectedDateCustomEvents = [];
    List<Map<String, dynamic>> upcomingReminders = [];

    final contacts = contactsState.contacts;
    for (var c in contacts) {
      if (c.birthday != null) {
        if (c.birthday!.month == selMonth && c.birthday!.day == selDay) {
          selectedDateBirthdays.add({
            'contactId': c.id,
            'contactName': c.name,
            'name': c.name,
            'photoUrl': c.photoUrl,
            'type': 'Birthday',
            'date': c.birthday!.toIso8601String(),
          });
        }
      }
      if (c.anniversary != null) {
        if (c.anniversary!.month == selMonth && c.anniversary!.day == selDay) {
          selectedDateAnniversaries.add({
            'contactId': c.id,
            'contactName': c.name,
            'name': c.name,
            'photoUrl': c.photoUrl,
            'type': 'Anniversary',
            'date': c.anniversary!.toIso8601String(),
          });
        }
      }
      for (var e in c.events) {
        if (e.date.month == selMonth && e.date.day == selDay) {
          selectedDateCustomEvents.add({
            'contactId': c.id,
            'contactName': c.name,
            'name': c.name,
            'photoUrl': c.photoUrl,
            'type': e.type,
            'label': e.label,
            'date': e.date.toIso8601String(),
          });
        }
      }
    }

    upcomingEvents.whenData((events) {
      for (var e in events) {
        final eventDateStr = e['date'] as String?;
        if (eventDateStr != null) {
          final eventDate = DateTime.tryParse(eventDateStr);
          if (eventDate != null) {
            final isSameDay = eventDate.month == selMonth && eventDate.day == selDay;
            if (isSameDay) {
              // Add to selected lists if not already added from contacts
              final contactId = e['contactId'];
              final type = e['type'];
              
              if (type == 'Birthday') {
                if (!selectedDateBirthdays.any((b) => b['contactId'] == contactId)) {
                  selectedDateBirthdays.add(e);
                }
              } else if (type == 'Anniversary') {
                if (!selectedDateAnniversaries.any((a) => a['contactId'] == contactId)) {
                  selectedDateAnniversaries.add(e);
                }
              } else {
                // For custom events, check by contact and type/label
                if (!selectedDateCustomEvents.any((ce) => ce['contactId'] == contactId && ce['type'] == type)) {
                  selectedDateCustomEvents.add(e);
                }
              }
            } else {
              upcomingReminders.add(e);
            }
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
                      // Only invalidate upcomingEvents as contacts are already loaded
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
                _buildAnniversaryRow(selectedDateAnniversaries, hPad, sw, sh),
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
        Padding(
          padding: EdgeInsets.only(right: sw * 0.04),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
            ),
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
                    backgroundColor: Colors.white,
                    textColor: Theme.of(context).primaryColor,
                    initials: ref.watch(authProvider).user?.name.isNotEmpty == true
                        ? ref.watch(authProvider).user!.name[0].toUpperCase()
                        : "U",
                  ),
          ),
        ),
      ],
    );
  }

  // ── Greeting card ────────────────────────────────────────────────────────
  Widget _buildGreetingCard(String name, double hPad, double sw, double sh) {
    final user = ref.watch(authProvider).user;
    final theme = Theme.of(context);
    final accent = theme.primaryColor;
    final textPri = theme.textTheme.titleLarge?.color;
    final textSec = theme.textTheme.bodyMedium?.color;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: AppCard(
        padding: EdgeInsets.all(sw * 0.05),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome back,",
                    style: TextStyle(
                      fontSize: sw * 0.035,
                      color: textSec,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: sh * 0.002),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: sw * 0.055,
                      fontWeight: FontWeight.bold,
                      color: textPri,
                    ),
                  ),
                  SizedBox(height: sh * 0.004),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user?.isAdmin == true ? "Administrator" : "User",
                      style: TextStyle(
                        fontSize: sw * 0.026,
                        color: accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: sw * 0.03),
            // Profile photo on the right
            Container(
              width: sw * 0.16,
              height: sw * 0.16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: accent.withOpacity(0.2), width: 1.5),
                image: user?.photoUrl != null
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(
                          user!.photoUrl!.startsWith('http')
                              ? user!.photoUrl!
                              : "${ApiConstants.baseImageUrl}${user.photoUrl}",
                        ),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: theme.colorScheme.surfaceContainerHighest,
              ),
              child: user?.photoUrl == null
                  ? Icon(Icons.person, size: sw * 0.08, color: accent)
                  : null,
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
      childAspectRatio: 2.0,
      padding: EdgeInsets.symmetric(horizontal: hPad),
      children: [
        _buildCountCard("Total Contacts", contactsCount, Icons.people_outline,      kContactsColor, sw, sh).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),
        _buildCountCard("Today's Events", todayEventsCount,   Icons.event_available,     kEventsColor,   sw, sh).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
        _buildCountCard("Upcoming",       upcomingCount,  Icons.upcoming,            kUpcomingColor, sw, sh).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
        _buildCountCard("Groups",         groupsCount,    Icons.group_work_outlined, kGroupsColor,   sw, sh).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
      ],
    );
  }

  Widget _buildCountCard(String title, int count, IconData icon, Color iconColor, double sw, double sh) {
    final theme = Theme.of(context);
    
    return AppCard(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sh * 0.004),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: sw * 0.06,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
          ),
          SizedBox(height: sh * 0.003),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: sw * 0.032,
              color: theme.textTheme.bodyMedium?.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── Section header ───────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title, double hPad, Color accentColor, double sw, double sh) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 0, hPad, sh * 0.018),
      child: Text(
        title,
        style: TextStyle(
          fontSize: sw * 0.038,
          fontWeight: FontWeight.bold,
          color: theme.textTheme.titleLarge?.color,
        ),
      ),
    );
  }

  // ── Birthday row ─────────────────────────────────────────────────────────
  Widget _buildBirthdayRow(List<Map<String, dynamic>> items, double hPad, double sw, double sh) {
    return SizedBox(
      height: sh * 0.13,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: hPad),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            width: sw * 0.35,
            margin: EdgeInsets.only(right: sw * 0.03),
            child: AppCard(
              delay: (100 * index).ms,
              padding: EdgeInsets.all(sw * 0.035),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  item['photoUrl'] != null
                      ? CircleAvatar(
                          radius: sw * 0.04,
                          backgroundImage: CachedNetworkImageProvider(
                            item['photoUrl'].startsWith('http')
                                ? item['photoUrl']
                                : "${ApiConstants.baseImageUrl}${item['photoUrl']}",
                          ),
                        )
                      : GradientAvatar(
                          radius: sw * 0.04,
                          initials: item['contactName']?[0] ?? item['name']?[0] ?? "U",
                        ),
                  SizedBox(height: sh * 0.008),
                  Text(
                    item['contactName'] ?? item['name'] ?? "Contact",
                    maxLines: 1,
                    style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color, fontWeight: FontWeight.bold, fontSize: sw * 0.03),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: sh * 0.003),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: kBirthdayColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.cake, color: kBirthdayColor, size: sw * 0.026),
                        SizedBox(width: sw * 0.008),
                        Text(
                          "Today!",
                          style: TextStyle(color: kBirthdayColor, fontSize: sw * 0.024, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnniversaryRow(List<Map<String, dynamic>> items, double hPad, double sw, double sh) {
    if (items.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: hPad),
        child: Row(
          children: [
            Icon(Icons.favorite, color: kAnniversaryColor, size: sw * 0.04),
            SizedBox(width: sw * 0.015),
            Text(
              "No anniversaries today 🍰",
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: sw * 0.032),
            ),
          ],
        ),
      );
    }
    return SizedBox(
      height: sh * 0.13,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: hPad),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            width: sw * 0.35,
            margin: EdgeInsets.only(right: sw * 0.03),
            child: AppCard(
              delay: (100 * index).ms,
              padding: EdgeInsets.all(sw * 0.035),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  item['photoUrl'] != null
                      ? CircleAvatar(
                          radius: sw * 0.04,
                          backgroundImage: CachedNetworkImageProvider(
                            item['photoUrl'].startsWith('http')
                                ? item['photoUrl']
                                : "${ApiConstants.baseImageUrl}${item['photoUrl']}",
                          ),
                        )
                      : GradientAvatar(
                          radius: sw * 0.04,
                          initials: item['contactName']?[0] ?? item['name']?[0] ?? "U",
                        ),
                  SizedBox(height: sh * 0.008),
                  Text(
                    item['contactName'] ?? item['name'] ?? "Contact",
                    maxLines: 1,
                    style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color, fontWeight: FontWeight.bold, fontSize: sw * 0.03),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: sh * 0.003),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: kAnniversaryColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.favorite, color: kAnniversaryColor, size: sw * 0.026),
                        SizedBox(width: sw * 0.008),
                        Text(
                          "Today!",
                          style: TextStyle(color: kAnniversaryColor, fontSize: sw * 0.024, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Custom Event row ─────────────────────────────────────────────────────
  Widget _buildCustomEventRow(List<Map<String, dynamic>> items, double hPad, double sw, double sh) {
    return SizedBox(
      height: sh * 0.13,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: hPad),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            width: sw * 0.35,
            margin: EdgeInsets.only(right: sw * 0.03),
            child: AppCard(
              delay: (100 * index).ms,
              padding: EdgeInsets.all(sw * 0.035),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  item['photoUrl'] != null
                      ? CircleAvatar(
                          radius: sw * 0.04,
                          backgroundImage: CachedNetworkImageProvider(
                            item['photoUrl'].startsWith('http')
                                ? item['photoUrl']
                                : "${ApiConstants.baseImageUrl}${item['photoUrl']}",
                          ),
                        )
                      : GradientAvatar(
                          radius: sw * 0.04,
                          initials: item['contactName']?[0] ?? item['name']?[0] ?? "U",
                        ),
                  SizedBox(height: sh * 0.008),
                  Text(
                    item['contactName'] ?? item['name'] ?? "Contact",
                    maxLines: 1,
                    style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color, fontWeight: FontWeight.bold, fontSize: sw * 0.03),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: sh * 0.003),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: kCustomEventColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.event, color: kCustomEventColor, size: sw * 0.026),
                        SizedBox(width: sw * 0.008),
                        Text(
                          (item['type'] == 'Other' || item['type'] == 'Custom')
                              ? (item['label'] != null && item['label'].toString().isNotEmpty ? item['label'] : "Special Day")
                              : (item['label'] != null && item['label'].toString().isNotEmpty ? item['label'] : item['type']),
                          style: TextStyle(color: kCustomEventColor, fontSize: sw * 0.024, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
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
            padding: EdgeInsets.all(sw * 0.035),
            delay: (50 * index).ms,
            child: Row(
              children: [
                Container(
                  width: sw * 0.11,
                  height: sw * 0.11,
                  decoration: BoxDecoration(
                    color: (item['type'] == 'Birthday' ? kBirthdayColor : kAnniversaryColor).withOpacity(0.12),
                    shape: BoxShape.circle
                  ),
                  child: item['photoUrl'] != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: CachedNetworkImage(
                            imageUrl: item['photoUrl'].startsWith('http')
                                ? item['photoUrl']
                                : "${ApiConstants.baseImageUrl}${item['photoUrl']}",
                            fit: BoxFit.cover,
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
                        style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color, fontWeight: FontWeight.bold, fontSize: sw * 0.04),
                      ),
                      SizedBox(height: sh * 0.003),
                      Text(
                        "${(item['type'] == 'Other' || item['type'] == 'Custom') ? (item['label'] != null && item['label'].toString().isNotEmpty ? item['label'] : "Special Event") : "${item['type']}${item['label'] != null && item['label'].toString().isNotEmpty ? ' (${item['label']})' : ''}"} · $formattedDate",
                        style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: sw * 0.029),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: sw * 0.025, vertical: sh * 0.005),
                  decoration: BoxDecoration(
                    color: (item['type'] == 'Birthday' ? kBirthdayColor : kAnniversaryColor).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    DateHelper.countdownText(difference),
                    style: TextStyle(
                      color: item['type'] == 'Birthday' ? kBirthdayColor : kAnniversaryColor,
                      fontSize: sw * 0.027,
                      fontWeight: FontWeight.bold,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return SizedBox(
      width: sw * 0.14,
      height: sw * 0.14,
      child: FloatingActionButton(
        heroTag: 'home_fab',
        backgroundColor: theme.primaryColor,
        onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context)=>AddContactScreen()));},
        shape: const CircleBorder(),
        child: Icon(Icons.add, color: isDark ? Colors.black : Colors.white, size: sw * 0.07),
      ),
    );
  }
}

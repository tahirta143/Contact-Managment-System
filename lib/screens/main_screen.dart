import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/contacts_provider.dart';
import '../../providers/events_provider.dart';
import '../../providers/reminders_provider.dart';
import 'contacts/contacts_list_screen.dart';
import 'dates/dates_home_screen.dart';
import 'home/home_screen.dart';
import 'auth/login_screen.dart';
import 'reminders/reminders_screen.dart';
import 'settings/settings_screen.dart';
import 'settings/admin_profile_screen.dart';
import 'settings/change_password_screen.dart';
import 'settings/user_management_screen.dart';



class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const ContactsListScreen(),
    const DatesHomeScreen(),
    const RemindersScreen(),
    const AdminProfileScreen(), // Index 4 now maps to Profile directly
    const SettingsScreen(),     // Index 5 (currently unused/hidden by user)
    const ChangePasswordScreen(),
    const UserManagementScreen(),
  ];

  void _onTabTapped(int index) {
    if (_selectedIndex != index) {
      setState(() => _selectedIndex = index);
    }
    
    // Auto-refresh data for the selected screen
    switch (index) {
      case 0:
        ref.read(contactsProvider.notifier).loadContacts();
        ref.read(remindersProvider.notifier).loadReminders();
        ref.invalidate(upcomingEventsProvider(30));
        break;
      case 1:
      case 2:
        ref.read(contactsProvider.notifier).loadContacts();
        break;
      case 3:
        ref.read(remindersProvider.notifier).loadReminders();
        ref.invalidate(upcomingEventsProvider(30));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(authProvider).user?.isAdmin ?? false;
    // Map indices 5, 6, 7 (sub-settings) to index 4 (Settings tab) for the bottom nav
    int bottomNavIndex = _selectedIndex;
    if (bottomNavIndex > 4) bottomNavIndex = 4;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBody: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: _buildDrawer(isAdmin),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNav(isAdmin, bottomNavIndex),
    );
  }

  Widget _buildDrawer(bool isAdmin) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      width: sw * 0.78,                          // responsive drawer width
      child: Column(
        children: [
          _buildDrawerHeader(sw, sh),
          SizedBox(height: sh * 0.008),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // ── Main nav ──────────────────────────────────────
                  _buildDrawerItem(Icons.home_filled,     "Home",            0, sw, sh),
                  _buildDrawerItem(Icons.contacts,        "Contacts",        1, sw, sh),
                  _buildDrawerItem(Icons.calendar_month,  "Dates & Events",  2, sw, sh),
                  _buildDrawerItem(Icons.notifications,   "Reminders",       3, sw, sh),

                  Divider(
                    color: Theme.of(context).dividerColor,
                    indent: sw * 0.05,
                    endIndent: sw * 0.05,
                    height: sh * 0.025,
                  ),

                  // ── Settings nav ──────────────────────────────────
                  _buildDrawerItem(Icons.person,          "Profile",         4, sw, sh),
                  _buildDrawerItem(Icons.lock_reset,      "Change Password", 6, sw, sh),

                  Divider(
                    color: Theme.of(context).dividerColor,
                    indent: sw * 0.05,
                    endIndent: sw * 0.05,
                    height: sh * 0.025,
                  ),

                  // ── Dark Mode Toggle ───────────────────────────────
                  _buildThemeToggle(sw, sh),
                ],
              ),
            ),
          ),

          Divider(
            color: Theme.of(context).dividerColor,
            indent: sw * 0.05,
            endIndent: sw * 0.05,
          ),
          _buildLogoutTile(sw, sh),
          SizedBox(height: sh * 0.035),
        ],
      ),
    );
  }

// ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildDrawerHeader(double sw, double sh) {
    final user       = ref.watch(authProvider).user;
    final topPadding = MediaQuery.of(context).padding.top;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        sw * 0.055,
        topPadding + sh * 0.025,
        sw * 0.055,
        sh * 0.032,
      ),
      color: isDark ? theme.cardTheme.color : theme.primaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar circle
          Container(
            width:  sw * 0.15,
            height: sw * 0.15,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : "U",
                style: TextStyle(
                  color: theme.primaryColor,
                  fontSize: sw * 0.06,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: sh * 0.018),
          Text(
            user?.name ?? "User",
            style: TextStyle(
              color: Colors.white,
              fontSize: sw * 0.048,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: sh * 0.004),
          Text(
            user?.email ?? "Welcome back",
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: sw * 0.032,
            ),
          ),
        ],
      ),
    );
  }

// ── Nav item ─────────────────────────────────────────────────────────────────
  Widget _buildDrawerItem(
      IconData icon,
      String   title,
      int      index,
      double   sw,
      double   sh,
      ) {
    final theme = Theme.of(context);
    final isSelected = _selectedIndex == index;
    final textColor = theme.textTheme.titleLarge?.color;
    final accent = theme.primaryColor;

    return InkWell(
      onTap: () {
        _onTabTapped(index);
        Navigator.pop(context);
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: sw * 0.03,
          vertical:   sh * 0.003,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: sw * 0.03,
          vertical:   sh * 0.014,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? accent.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            // Icon container — rounded square
            Container(
              width:  sw * 0.1,
              height: sw * 0.1,
              decoration: BoxDecoration(
                color: isSelected
                    ? accent.withOpacity(0.15)
                    : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(sw * 0.025),
              ),
              child: Icon(
                icon,
                color: isSelected ? accent : textColor?.withOpacity(0.6),
                size: sw * 0.052,
              ),
            ),
            SizedBox(width: sw * 0.035),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? accent : textColor?.withOpacity(isSelected ? 1.0 : 0.7),
                fontSize: sw * 0.038,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

// ── Dark mode toggle tile ─────────────────────────────────────────────────────
  Widget _buildThemeToggle(double sw, double sh) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: sw * 0.06,
        vertical: sh * 0.003,
      ),
      child: Row(
        children: [
          // Icon box
          Container(
            width:  sw * 0.1,
            height: sw * 0.1,
            decoration: BoxDecoration(
              color: isDark
                  ? theme.primaryColor.withOpacity(0.15)
                  : theme.textTheme.labelSmall?.color?.withOpacity(0.08),
              borderRadius: BorderRadius.circular(sw * 0.025),
            ),
            child: Icon(
              isDark ? Icons.dark_mode : Icons.light_mode,
              color: isDark ? theme.primaryColor : theme.textTheme.bodyMedium?.color,
              size: sw * 0.052,
            ),
          ),
          SizedBox(width: sw * 0.035),
          Expanded(
            child: Text(
              isDark ? "Dark Mode" : "Light Mode",
              style: TextStyle(
                color: textColor,
                fontSize: sw * 0.038,
              ),
            ),
          ),
          // ── Toggle switch ──
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: isDark,
              onChanged: (_) {
                ref.read(themeProvider.notifier).toggleTheme();
              },
              activeColor: theme.primaryColor,
              activeTrackColor: theme.primaryColor.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

// ── Logout tile ───────────────────────────────────────────────────────────────
  Widget _buildLogoutTile(double sw, double sh) {
    return InkWell(
      onTap: () async {
        await ref.read(authProvider.notifier).logout();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: sw * 0.03),
        padding: EdgeInsets.symmetric(
          horizontal: sw * 0.03,
          vertical:   sh * 0.014,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(sw * 0.03),
        ),
        child: Row(
          children: [
            Container(
              width:  sw * 0.1,
              height: sw * 0.1,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(sw * 0.025),
              ),
              child: Icon(
                Icons.logout,
                color: Colors.red.shade400,
                size: sw * 0.052,
              ),
            ),
            SizedBox(width: sw * 0.035),
            Text(
              "Logout",
              style: TextStyle(
                color: Colors.red.shade400,
                fontSize: sw * 0.038,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(bool isAdmin, int currentIndex) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final bottomMargin = size.height * 0.035;
    final isDark = theme.brightness == Brightness.dark;

    final navBg   = isDark ? theme.cardTheme.color : theme.primaryColor;
    final selColor = isDark ? theme.primaryColor : Colors.white;
    final unselColor = isDark ? theme.textTheme.bodySmall?.color : Colors.white60;

    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, bottomMargin),
      decoration: BoxDecoration(
        color: navBg,
        borderRadius: BorderRadius.circular(30),
        border: isDark
            ? Border.all(color: theme.dividerColor, width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          showSelectedLabels: true,
          showUnselectedLabels: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: selColor,
          unselectedItemColor: unselColor,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
          onTap: _onTabTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.contacts), label: "Contacts"),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "D/P/E"),
            BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Reminders"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }
}

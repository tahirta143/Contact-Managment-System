import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../core/utils/common_widgets.dart';
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
    const SettingsScreen(),
    const AdminProfileScreen(),
    const ChangePasswordScreen(),
    const UserManagementScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(authProvider).user?.isAdmin ?? false;
    // Map indices 5, 6, 7 (sub-settings) to index 4 (Settings tab) for the bottom nav
    int bottomNavIndex = _selectedIndex;
    if (bottomNavIndex > 4) bottomNavIndex = 4;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBody: true,
      backgroundColor: kScaffoldBg,
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

    return Drawer(
      backgroundColor: Colors.white,
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
                    color: kTextTertiary.withOpacity(0.1),
                    indent: sw * 0.05,
                    endIndent: sw * 0.05,
                    height: sh * 0.025,
                  ),

                  // ── Settings nav ──────────────────────────────────
                  _buildDrawerItem(Icons.settings,        "Settings",        4, sw, sh),
                  _buildDrawerItem(Icons.person,          "Profile",         5, sw, sh),
                  _buildDrawerItem(Icons.lock_reset,      "Change Password", 6, sw, sh),
                  if (isAdmin)
                    _buildDrawerItem(Icons.manage_accounts, "User Management", 7, sw, sh),
                ],
              ),
            ),
          ),

          Divider(
            color: kTextTertiary.withOpacity(0.1),
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

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        sw * 0.055,
        topPadding + sh * 0.025,
        sw * 0.055,
        sh * 0.032,
      ),
      color: kPrimaryColor,
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
                  color: kPrimaryColor,
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
    final isSelected = _selectedIndex == index;

    return InkWell(
      onTap: () {
        setState(() => _selectedIndex = index);
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
              ? kPrimaryColor.withOpacity(0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(sw * 0.03),
        ),
        child: Row(
          children: [
            // Icon container — rounded square
            Container(
              width:  sw * 0.1,
              height: sw * 0.1,
              decoration: BoxDecoration(
                color: isSelected
                    ? kPrimaryColor.withOpacity(0.12)
                    : kTextTertiary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(sw * 0.025),
              ),
              child: Icon(
                icon,
                color: isSelected ? kPrimaryColor : kTextSecondary,
                size: sw * 0.052,
              ),
            ),
            SizedBox(width: sw * 0.035),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? kPrimaryColor : kTextSecondary,
                fontSize: sw * 0.038,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
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
    final size = MediaQuery.of(context).size;
    final bottomMargin = size.height * 0.035;

    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, bottomMargin),
      decoration: BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
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
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white54,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
            const BottomNavigationBarItem(icon: Icon(Icons.contacts), label: "Contacts"),
            const BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "D/P/E"),
            const BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Reminders"),
            const BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
          ],
        ),
      ),
    );
  }
}

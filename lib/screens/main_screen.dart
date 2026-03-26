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
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          _buildDrawerHeader(),
            _buildDrawerItem(Icons.home_filled, "Home", 0),
            _buildDrawerItem(Icons.contacts, "Contacts", 1),
            _buildDrawerItem(Icons.calendar_month, "Dates & Events", 2),
            _buildDrawerItem(Icons.notifications, "Reminders", 3),
            Divider(color: kTextTertiary.withValues(alpha: 0.1), indent: 20, endIndent: 20),
            _buildDrawerItem(Icons.settings, "Settings", 4),
            _buildDrawerItem(Icons.person, "Admin Profile", 5),
            _buildDrawerItem(Icons.lock_reset, "Change Password", 6),
            _buildDrawerItem(Icons.manage_accounts, "User Management", 7),
            const Spacer(),
            Divider(color: kTextTertiary.withValues(alpha: 0.1), indent: 20, endIndent: 20),
            ListTile(
              leading: Icon(Icons.logout, color: kTextSecondary),
              title: const Text("Logout", style: TextStyle(color: kTextSecondary)),
              onTap: () {
                // Implement logout logic
                Navigator.pushAndRemoveUntil(
                  context, 
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      );
  }

  Widget _buildDrawerHeader() {
    final user = ref.watch(authProvider).user;
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPadding + 20, 20, 30),
      decoration: const BoxDecoration(
        color: kPrimaryColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GradientAvatar(
            radius: 30, 
            initials: user?.name.isNotEmpty == true ? user!.name[0] : "U",
            backgroundColor: Colors.white,
            textColor: kPrimaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            user?.name ?? "User",
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            user?.email ?? "Welcome back",
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    bool isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? kPrimaryColor : kTextSecondary),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? kPrimaryColor : kTextSecondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onTap: () {
        setState(() => _selectedIndex = index);
        Navigator.pop(context); // Close drawer
      },
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
            color: Colors.black.withValues(alpha: 0.3),
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
            const BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "Dates"),
            const BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Reminders"),
            const BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
          ],
        ),
      ),
    );
  }
}

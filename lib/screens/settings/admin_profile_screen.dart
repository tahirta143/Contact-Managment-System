import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_constants.dart';
import '../../core/utils/common_widgets.dart';
import '../../providers/auth_provider.dart';
import '../../core/widgets/custom_loader.dart';

class AdminProfileScreen extends ConsumerStatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  ConsumerState<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends ConsumerState<AdminProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh user data on entry
    Future.microtask(() => ref.read(authProvider.notifier).tryAutoLogin());
  }

  void _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: kError),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authProvider.notifier).logout();
      if (mounted) {
        // Navigate to login or home (AuthProvider should handle redirection if handled at top level)
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final size = MediaQuery.of(context).size;
    final sw = size.width;
    final sh = size.height;

    if (authState.isLoading && user == null) {
      return const Scaffold(body: CustomLoader(message: "Loading Profile..."));
    }

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Profile")),
        body: const Center(child: Text("No user data found. Please login again.")),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(authProvider.notifier).tryAutoLogin();
        },
        color: Theme.of(context).primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
          children: [
            // --- HEADER SECTION ---
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  height: sh * 0.25,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Theme.of(context).cardTheme.color 
                        : Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 10,
                  child: IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                Positioned(
                  bottom: -sh * 0.08,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: sh * 0.08,
                      backgroundColor: Theme.of(context).inputDecorationTheme.fillColor ?? const Color(0xFFF3F4F6),
                      backgroundImage: user.photoUrl != null
                          ? CachedNetworkImageProvider(
                              user.photoUrl!.startsWith('http')
                                  ? user.photoUrl!
                                  : "${ApiConstants.baseImageUrl}${user.photoUrl}",
                            )
                          : null,
                      child: user.photoUrl == null
                          ? Icon(Icons.person, size: sh * 0.08, color: Theme.of(context).textTheme.bodyMedium?.color)
                          : null,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: sh * 0.1),

            // --- USER INFO ---
            Text(
              user.name,
              style: TextStyle(
                fontSize: sw * 0.065,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            Text(
              user.role.toUpperCase(),
              style: TextStyle(
                fontSize: sw * 0.035,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
                letterSpacing: 1.2,
              ),
            ),

            SizedBox(height: sh * 0.03),

            // --- DETAILS CARDS ---
            Padding(
              padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
              child: Column(
                children: [
                  _buildInfoCard(
                    context,
                    icon: Icons.email_outlined,
                    title: "Email Address",
                    value: user.email,
                    index: 0,
                  ),
                  _buildInfoCard(
                    context,
                    icon: Icons.verified_user_outlined,
                    title: "Account Status",
                    value: user.isActive ? "Active" : "Inactive",
                    valueColor: user.isActive ? Colors.green : Colors.red,
                    index: 1,
                  ),
                  _buildInfoCard(
                    context,
                    icon: Icons.security_outlined,
                    title: "User Role",
                    value: user.isAdmin ? "Administrator" : "Standard User",
                    index: 2,
                  ),
                ],
              ),
            ),

            SizedBox(height: sh * 0.04),

            // --- ACTIONS ---
            Padding(
              padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Edit Profile feature coming soon!")),
                      );
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text("Edit Profile"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, sh * 0.06),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                  SizedBox(height: sh * 0.015),
                  OutlinedButton.icon(
                    onPressed: _handleLogout,
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(double.infinity, sh * 0.06),
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: sh * 0.12), // Added padding for floating bottom nav
          ],
        ),
      ),
    ));
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required int index,
    Color? valueColor,
  }) {
    final sw = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        delay: (100 * index).ms,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Theme.of(context).primaryColor, size: sw * 0.055),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: sw * 0.03),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      color: valueColor ?? Theme.of(context).textTheme.titleLarge?.color,
                      fontSize: sw * 0.038,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

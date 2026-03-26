import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/common_widgets.dart';
import 'edit_contact_screen.dart';

class ContactDetailScreen extends StatelessWidget {
  final String contactId;
  const ContactDetailScreen({super.key, required this.contactId});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final horizontalPadding = size.width * 0.05;

    return Scaffold(
      backgroundColor: kScaffoldBg,
      body: CustomScrollView(
          slivers: [
            _buildSliverAppBar(context, size),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildSection("Personal Info", [
                    _buildInfoTile(Icons.work_outline, "Profession", "Software Engineer"),
                    _buildInfoTile(Icons.star_outline, "Speciality", "Flutter/Dart"),
                    _buildInfoTile(Icons.people_outline, "Reference", "Self"),
                  ]),
                  const SizedBox(height: 16),
                  _buildSection("Contact Numbers", [
                    _buildInfoTile(Icons.phone_outlined, "Phone", "+92 300 1234567", trailing: _buildActionButtons()),
                    _buildInfoTile(Icons.smartphone, "Mobile", "+92 321 7654321", trailing: _buildActionButtons()),
                    _buildInfoTile(Icons.chat_outlined, "WhatsApp", "+92 300 1234567", isWhatsApp: true),
                  ]),
                  const SizedBox(height: 16),
                  _buildSection("Address", [
                    _buildInfoTile(Icons.location_on_outlined, "Address", "Street 12, Model Town"),
                    _buildInfoTile(Icons.location_city, "City", "Lahore"),
                  ]),
                  const SizedBox(height: 16),
                  _buildSection("Important Dates", [
                    _buildDateCard("Birthday", "10 September 1998", Icons.cake, kButtonColor, "Age: 27", "in 23 days"),
                    const SizedBox(height: 12),
                    _buildDateCard("Anniversary", "15 January 2013", Icons.favorite, Colors.purple, "13 years", "Today! 💕"),
                  ]),
                  const SizedBox(height: 50),
                ]),
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildSliverAppBar(BuildContext context, Size size) {
    return SliverAppBar(
      expandedHeight: size.height * 0.35,
      pinned: true,
      backgroundColor: kPrimaryColor,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + 20),
            GradientAvatar(radius: size.width * 0.15, initials: "TA"),
            const SizedBox(height: 16),
            const Text(
              "Tahir Ahmed",
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              "Senior Software Engineer",
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.white),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditContactScreen(contactId: contactId))),
        ),
        IconButton(
          icon: const Icon(Icons.share_outlined, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: kPrimaryColor, size: 18),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: const TextStyle(color: kTextPrimary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
            ],
          ),
          Divider(color: kTextTertiary.withValues(alpha: 0.1), height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value, {Widget? trailing, bool isWhatsApp = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: kTextTertiary, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: kTextSecondary, fontSize: 11)),
              Text(value, style: const TextStyle(color: kTextPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
          const Spacer(),
          if (trailing != null) trailing,
          if (isWhatsApp) Icon(Icons.chat_bubble_outline, color: Colors.greenAccent.withOpacity(0.8), size: 20),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.phone_callback, color: kTextTertiary, size: 18),
      ],
    );
  }

  Widget _buildDateCard(String title, String date, IconData icon, Color accent, String subValue, String countdown) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kInputBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: accent.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: kTextSecondary, fontSize: 12)),
                Text(date, style: const TextStyle(color: kTextPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: kPrimaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(subValue, style: const TextStyle(color: kPrimaryColor, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 4),
              Text(countdown, style: const TextStyle(color: kTextSecondary, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_constants.dart';
import '../../core/utils/common_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/contact_model.dart';
import '../../providers/contacts_provider.dart';
import 'edit_contact_screen.dart';

// Event-specific theme colors (same as HomeScreen)
const Color kBirthdayColor    = Color(0xFFFF6B9D);
const Color kAnniversaryColor = Color(0xFFFF9500);


class ContactDetailScreen extends ConsumerWidget {
  final String contactId;
  const ContactDetailScreen({super.key, required this.contactId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsState = ref.watch(contactsProvider);
    final contact = contactsState.contacts.cast<Contact?>().firstWhere(
      (c) => c?.id == contactId,
      orElse: () => null,
    );

    if (contactsState.isLoading && contact == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (contact == null) {
      return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text("Not Found"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: kError),
              const SizedBox(height: 16),
              const Text(
                "Contact not found",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextPrimary),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Go Back", style: TextStyle(color: kPrimaryColor)),
              ),
            ],
          ),
        ),
      );
    }

    // ── MediaQuery values ────────────────────────────────────────────────
    final size          = MediaQuery.of(context).size;
    final sw            = size.width;
    final sh            = size.height;
    final hPad          = sw * 0.05;
    final avatarRadius  = sw * 0.15;
    final sliverHeight  = sh * 0.35;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, contact, sw, sh, avatarRadius, sliverHeight),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: sh * 0.02),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSection(
                  context,
                  "Personal Info",
                  Icons.person_outline,
                  [
                    _buildInfoTile(context, Icons.work_outline,    "Profession", contact.profession ?? "N/A"),
                    _buildInfoTile(context, Icons.star_outline,    "Speciality", contact.speciality ?? "N/A"),
                    _buildInfoTile(context, Icons.people_outline,  "Reference",  contact.reference ?? "N/A"),
                  ],
                ),
                SizedBox(height: sh * 0.018),
                _buildSection(
                  context,
                  "Contact Numbers",
                  Icons.phone_outlined,
                  [
                    _buildInfoTile(context, Icons.phone_outlined, "Phone",    contact.phone ?? "N/A", trailing: contact.phone != null ? _buildCallButton(context) : null),
                    _buildInfoTile(context, Icons.smartphone,     "Mobile",   contact.mobile ?? "N/A", trailing: contact.mobile != null ? _buildCallButton(context) : null),
                    _buildInfoTile(context, Icons.chat_outlined,  "WhatsApp", contact.whatsapp ?? "N/A", isWhatsApp: contact.whatsapp != null),
                  ],
                ),
                SizedBox(height: sh * 0.018),
                _buildSection(
                  context,
                  "Address",
                  Icons.location_on_outlined,
                  [
                    _buildInfoTile(context, Icons.location_on_outlined, "Address", contact.address ?? "N/A"),
                    _buildInfoTile(context, Icons.location_city,        "City",    contact.city ?? "N/A"),
                  ],
                ),
                SizedBox(height: sh * 0.018),
                _buildSection(
                  context,
                  "Custom Events & Dates",
                  Icons.event_outlined,
                  [
                    if (contact.birthday != null)
                      _buildDateCard(context, "Birthday", DateFormat('dd MMMM yyyy').format(contact.birthday!), Icons.cake, kBirthdayColor, contact.age != null ? "${contact.age} years" : "", contact.daysUntilBirthday != null ? "${contact.daysUntilBirthday} days left" : ""),
                    if (contact.anniversary != null)
                      _buildDateCard(context, "Anniversary", DateFormat('dd MMMM yyyy').format(contact.anniversary!), Icons.favorite, kAnniversaryColor, contact.marriageYears != null ? "${contact.marriageYears} years" : "", contact.daysUntilAnniversary != null ? "${contact.daysUntilAnniversary} days left" : ""),
                    ...contact.events.map((e) {
                      final diff = e.date.difference(DateTime.now()).inDays;
                      return _buildDateCard(
                        context,
                        e.label != null && e.label!.isNotEmpty ? "${e.type}: ${e.label}" : e.type,
                        DateFormat('dd MMMM yyyy').format(e.date),
                        Icons.event,
                        kPrimaryColor,
                        e.label ?? "",
                        diff > 0 ? "$diff days left" : (diff == 0 ? "Today!" : "Past"),
                      );
                    }),
                    if (contact.birthday == null && contact.anniversary == null && contact.events.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text("No important dates recorded", style: TextStyle(color: kTextSecondary)),
                      ),
                  ],
                ),
                SizedBox(height: sh * 0.06),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── Sliver app bar ───────────────────────────────────────────────────────
  Widget _buildSliverAppBar(
      BuildContext context,
      Contact contact,
      double sw,
      double sh,
      double avatarRadius,
      double sliverHeight,
      ) {
    return SliverAppBar(
      expandedHeight: sliverHeight,
      pinned: true,
      backgroundColor: kPrimaryColor,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + sh * 0.02),
            contact.photoUrl != null
                ? CircleAvatar(
                    radius: avatarRadius,
                    backgroundImage: CachedNetworkImageProvider(
                      contact.photoUrl!.startsWith('http')
                          ? contact.photoUrl!
                          : "${ApiConstants.baseImageUrl}${contact.photoUrl}",
                    ),
                  )
                : GradientAvatar(
                    radius: avatarRadius,
                    initials: contact.name.isNotEmpty ? contact.name[0].toUpperCase() : "?",
                  ),
            SizedBox(height: sh * 0.018),
            Text(
              contact.name,
              style: TextStyle(
                color: Colors.white,
                fontSize: sw * 0.058,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: sh * 0.005),
            Text(
              contact.designation ?? "",
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: sw * 0.034,
              ),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white, size: sw * 0.06),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.edit, color: Colors.white, size: sw * 0.058),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EditContactScreen(contactId: contact.id)),
          ),
        ),
        IconButton(
          icon: Icon(Icons.share_outlined, color: Colors.white, size: sw * 0.058),
          onPressed: () {},
        ),
      ],
    );
  }

  // ── Section card ─────────────────────────────────────────────────────────
  Widget _buildSection(
      BuildContext context,
      String title,
      IconData sectionIcon,
      List<Widget> children,
      ) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return AppCard(
      padding: EdgeInsets.all(sw * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(sectionIcon, color: kPrimaryColor, size: sw * 0.045),
              SizedBox(width: sw * 0.02),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  color: kTextPrimary,
                  fontSize: sw * 0.028,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          Divider(color: kTextTertiary.withOpacity(0.1), height: sh * 0.03),
          ...children,
        ],
      ),
    );
  }

  // ── Info tile ────────────────────────────────────────────────────────────
  Widget _buildInfoTile(
      BuildContext context,
      IconData icon,
      String label,
      String value, {
        Widget? trailing,
        bool isWhatsApp = false,
      }) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.only(bottom: sh * 0.014),
      child: Row(
        children: [
          Icon(icon, color: kTextTertiary, size: sw * 0.05),
          SizedBox(width: sw * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: kTextSecondary, fontSize: sw * 0.028),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: kTextPrimary,
                    fontSize: sw * 0.036,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
          if (isWhatsApp)
            Icon(
              Icons.chat_bubble_outline,
              color: Colors.green.withOpacity(0.8),
              size: sw * 0.05,
            ),
        ],
      ),
    );
  }

  // ── Call button ──────────────────────────────────────────────────────────
  Widget _buildCallButton(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return Icon(Icons.phone_callback, color: kPrimaryColor, size: sw * 0.048);
  }

  // ── Date card ────────────────────────────────────────────────────────────
  Widget _buildDateCard(
      BuildContext context,
      String title,
      String date,
      IconData icon,
      Color accent,
      String subValue,
      String countdown,
      ) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        color: Theme.of(context).inputDecorationTheme.fillColor ?? const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(sw * 0.04),
      ),
      child: Row(
        children: [
          // Themed icon circle
          Container(
            width: sw * 0.11,
            height: sw * 0.11,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accent, size: sw * 0.05),
          ),
          SizedBox(width: sw * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: kTextSecondary, fontSize: sw * 0.03),
                ),
                SizedBox(height: sh * 0.004),
                Text(
                  date,
                  style: TextStyle(
                    color: kTextPrimary,
                    fontSize: sw * 0.038,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.025,
                  vertical: sh * 0.005,
                ),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(sw * 0.02),
                ),
                child: Text(
                  subValue,
                  style: TextStyle(
                    color: accent,
                    fontSize: sw * 0.028,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: sh * 0.005),
              Text(
                countdown,
                style: TextStyle(color: kTextSecondary, fontSize: sw * 0.028),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/common_widgets.dart';
import '../../providers/contacts_provider.dart';
import '../../core/widgets/custom_loader.dart';
import '../../models/contact_model.dart';

// ─── Event theme colors (consistent with HomeScreen & ContactDetailScreen) ────
const Color kBirthdayColor    = Color(0xFFFF6B9D); // pink
const Color kAnniversaryColor = Color(0xFFFF9500); // amber/gold
const Color kCustomEventColor = Color(0xFF4C9EFF); // blue

class DatesHomeScreen extends ConsumerStatefulWidget {
  const DatesHomeScreen({super.key});

  @override
  ConsumerState<DatesHomeScreen> createState() => _DatesHomeScreenState();
}

class _DatesHomeScreenState extends ConsumerState<DatesHomeScreen> {
  // 0: By Date, 1: By Person, 2: By Event
  int _selectedFilterType = 0;

  // Date-wise state
  DateTime _selectedDate = DateTime.now();

  // Event-wise state
  String _selectedEventType = 'All';

  // Person-wise state
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sw   = size.width;
    final sh   = size.height;
    final hPad = sw * 0.045;

    final contactsState = ref.watch(contactsProvider);
    final contacts = contactsState.contacts;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(sw),
      body: Column(
        children: [
          SizedBox(height: sh * 0.012),
          _buildTopFilterToggle(hPad, sw, sh),
          SizedBox(height: sh * 0.008),
          Expanded(
            child: contactsState.isLoading
                ? const Center(child: CustomLoader(message: "Loading..."))
                : contactsState.error != null
                    ? Center(child: Text(contactsState.error!))
                    : _buildBodyForFilter(contacts, hPad, sw, sh),
          ),
        ],
      ),
    );
  }

  // ── AppBar — consistent with all other screens ───────────────────────────
  PreferredSizeWidget _buildAppBar(double sw) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.menu, size: sw * 0.06),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
      title: Text(
        "Dates & Events",
        style: TextStyle(
          fontSize: sw * 0.048, 
          fontWeight: FontWeight.bold,
          color: Theme.of(context).appBarTheme.titleTextStyle?.color,
        ),
      ),
      actions: [SizedBox(width: sw * 0.12)],
    );
  }

  // ── Top 3-way toggle ─────────────────────────────────────────────────────
  Widget _buildTopFilterToggle(double hPad, double sw, double sh) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Container(
        height: sh * 0.058,
        padding: EdgeInsets.all(sw * 0.01),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(sw * 0.08),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildToggleOption("Date",   0, sw),
            _buildToggleOption("Person", 1, sw),
            _buildToggleOption("Event",  2, sw),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleOption(String label, int index, double sw) {
    final isSelected = _selectedFilterType == index;

    // Each tab has its own accent color when active
    final Color activeColor = index == 0
        ? Theme.of(context).primaryColor
        : index == 1
        ? kBirthdayColor
        : kAnniversaryColor;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilterType = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? (Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.1) : Colors.white) : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            boxShadow: isSelected && Theme.of(context).brightness == Brightness.light
                ? [BoxShadow(color: activeColor.withOpacity(0.15), blurRadius: 6, offset: const Offset(0, 2))]
                : [],
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Small color dot indicator when selected
                if (isSelected) ...[
                  Container(
                    width: sw * 0.018,
                    height: sw * 0.018,
                    decoration: BoxDecoration(color: activeColor, shape: BoxShape.circle),
                  ),
                  SizedBox(width: sw * 0.015),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? activeColor : Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: sw * 0.034,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBodyForFilter(List<Contact> contacts, double hPad, double sw, double sh) {
    switch (_selectedFilterType) {
      case 0: return _buildDateWiseView(contacts, hPad, sw, sh);
      case 1: return _buildPersonWiseView(contacts, hPad, sw, sh);
      case 2: return _buildEventWiseView(contacts, hPad, sw, sh);
      default: return const SizedBox();
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DATE-WISE VIEW
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildDateWiseView(List<Contact> contacts, double hPad, double sw, double sh) {
    final selMonth = _selectedDate.month;
    final selDay   = _selectedDate.day;

    List<Map<String, dynamic>> flatEvents = [];

    for (var c in contacts) {
      if (c.birthday != null && c.birthday!.month == selMonth && c.birthday!.day == selDay) {
        flatEvents.add({
          'name': c.name,
          'type': "Birthday",
          'subtitle': c.designation ?? "",
          'icon': Icons.cake,
          'color': kBirthdayColor,
        });
      }
      if (c.anniversary != null && c.anniversary!.month == selMonth && c.anniversary!.day == selDay) {
        flatEvents.add({
          'name': c.name,
          'type': "Anniversary",
          'subtitle': "Celebration",
          'icon': Icons.favorite,
          'color': kAnniversaryColor,
        });
      }
      for (var e in c.events) {
        if (e.date.month == selMonth && e.date.day == selDay) {
          flatEvents.add({
            'name': c.name,
            'type': e.type,
            'subtitle': "Custom Event",
            'icon': Icons.event,
            'color': kCustomEventColor,
          });
        }
      }
    }

    return Column(
      children: [
        // Date picker row
        Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                builder: (ctx, child) => Theme(
                  data: Theme.of(ctx).copyWith(
                    colorScheme: ColorScheme.light(primary: Theme.of(context).primaryColor),
                  ),
                  child: child!,
                ),
              );
              if (date != null) setState(() => _selectedDate = date);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sh * 0.016),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(sw * 0.05),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_month, color: Theme.of(context).primaryColor, size: sw * 0.05),
                  SizedBox(width: sw * 0.02),
                  Text(
                    DateFormat('dd MMMM yyyy').format(_selectedDate),
                    style: TextStyle(
                      color: Theme.of(context).textTheme.titleLarge?.color,
                      fontWeight: FontWeight.bold,
                      fontSize: sw * 0.04,
                    ),
                  ),
                  SizedBox(width: sw * 0.02),
                  Icon(Icons.arrow_drop_down, color: Theme.of(context).textTheme.bodyMedium?.color, size: sw * 0.055),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: sh * 0.012),
        // Results
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await ref.read(contactsProvider.notifier).loadContacts();
            },
            color: Theme.of(context).primaryColor,
            child: flatEvents.isEmpty
                ? Center(child: Text("No events on this date", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)))
                : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: sh * 0.008).copyWith(bottom: sh * 0.16),
              itemCount: flatEvents.length,
              itemBuilder: (context, index) {
                final ev = flatEvents[index];
                return _buildEventCard(
                  ev['name'],
                  ev['type'],
                  ev['subtitle'],
                  ev['icon'],
                  ev['color'],
                  sw, sh,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PERSON-WISE VIEW
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildPersonWiseView(List<Contact> contacts, double hPad, double sw, double sh) {
    final filtered = contacts.where((c) {
      if (c.birthday == null && c.anniversary == null && c.events.isEmpty) return false;
      if (_searchQuery.isEmpty) return true;
      return c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (c.city != null && c.city!.toLowerCase().contains(_searchQuery.toLowerCase()));
    }).toList();

    return Column(
      children: [
        // Search bar
        Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: AppCard(
            borderRadius: 30,
            height: sh * 0.058,
            padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: sw * 0.036),
              decoration: InputDecoration(
                hintText: "Search person...",
                hintStyle: TextStyle(fontSize: sw * 0.034),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                prefixIcon: Icon(Icons.search, color: Theme.of(context).textTheme.bodyMedium?.color, size: sw * 0.055),
              ),
            ),
          ),
        ),
        SizedBox(height: sh * 0.012),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await ref.read(contactsProvider.notifier).loadContacts();
            },
            color: Theme.of(context).primaryColor,
            child: filtered.isEmpty
                ? Center(child: Text("No persons with events found", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)))
                : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: sh * 0.008).copyWith(bottom: sh * 0.16),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final c = filtered[index];
                return _buildPersonBlock(c, sw, sh);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonBlock(Contact c, double sw, double sh) {
    final bdayStr = c.birthday != null ? DateFormat('dd MMM').format(c.birthday!) : null;
    final anniStr = c.anniversary != null ? DateFormat('dd MMM').format(c.anniversary!) : null;

    return Padding(
      padding: EdgeInsets.only(bottom: sh * 0.014),
      child: AppCard(
        padding: EdgeInsets.all(sw * 0.045),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name row
            Row(
              children: [
                GradientAvatar(radius: sw * 0.05, initials: c.name.isNotEmpty ? c.name[0].toUpperCase() : "?"),
                SizedBox(width: sw * 0.03),
                Text(
                  c.name,
                  style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color, fontSize: sw * 0.045, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: sh * 0.012),
            Wrap(
              spacing: sw * 0.02,
              runSpacing: sh * 0.01,
              children: [
                if (bdayStr != null)
                  _buildSmallDetailChip(Icons.cake, "Birthday: $bdayStr", kBirthdayColor, sw),
                if (anniStr != null)
                  _buildSmallDetailChip(Icons.favorite, "Anniversary: $anniStr", kAnniversaryColor, sw),
                ...c.events.map((e) {
                  final evStr = DateFormat('dd MMM yyyy').format(e.date);
                  return _buildSmallDetailChip(Icons.event, "${e.type}: $evStr", kCustomEventColor, sw);
                }).toList(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallDetailChip(IconData icon, String text, Color color, double sw) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.025, vertical: sw * 0.015),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(sw * 0.02),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: sw * 0.035),
          SizedBox(width: sw * 0.015),
          Text(
            text,
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: sw * 0.03, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }



  // ══════════════════════════════════════════════════════════════════════════
  // EVENT-WISE VIEW
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildEventWiseView(List<Contact> contacts, double hPad, double sw, double sh) {
    final isAll = _selectedEventType == 'All';
    final isBirthday = _selectedEventType == 'Birthday' || isAll;
    final isAnniversary = _selectedEventType == 'Anniversary' || isAll;
    final isCustom = _selectedEventType == 'Custom' || isAll;

    // Build a flattened list of items to display
    List<Map<String, dynamic>> flatEvents = [];

    for (var c in contacts) {
      if (isBirthday && c.birthday != null) {
        flatEvents.add({
          'name': c.name,
          'dateStr': DateFormat('dd MMM').format(c.birthday!),
          'subtitle': "Birthday",
          'icon': Icons.cake,
          'color': kBirthdayColor,
          'sortDate': DateTime(0, c.birthday!.month, c.birthday!.day),
        });
      }
      if (isAnniversary && c.anniversary != null) {
        flatEvents.add({
          'name': c.name,
          'dateStr': DateFormat('dd MMM').format(c.anniversary!),
          'subtitle': "Anniversary",
          'icon': Icons.favorite,
          'color': kAnniversaryColor,
          'sortDate': DateTime(0, c.anniversary!.month, c.anniversary!.day),
        });
      }
      if (isCustom && c.events.isNotEmpty) {
        for (var e in c.events) {
          flatEvents.add({
            'name': c.name,
            'dateStr': DateFormat('dd MMM yyyy').format(e.date),
            'subtitle': e.type, // e.g. "Work", "Custom"
            'icon': Icons.event,
            'color': kCustomEventColor,
            'sortDate': DateTime(e.date.year, e.date.month, e.date.day),
          });
        }
      }
    }

    // Sort by date (closest to today if possible, but here we just sort by month/day for birthdays)
    flatEvents.sort((a, b) => (a['sortDate'] as DateTime).compareTo(b['sortDate'] as DateTime));

    return Column(
      children: [
        // Birthday / Anniversary / Custom / All toggle
        Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildEventToggleBtn("✨  All",           'All',         Theme.of(context).primaryColor,     sw, sh),
                SizedBox(width: sw * 0.02),
                _buildEventToggleBtn("🎂  Birthdays",    'Birthday',    kBirthdayColor,    sw, sh),
                SizedBox(width: sw * 0.02),
                _buildEventToggleBtn("💛  Anniversaries", 'Anniversary', kAnniversaryColor, sw, sh),
                SizedBox(width: sw * 0.02),
                _buildEventToggleBtn("📅  Custom",       'Custom',      kCustomEventColor, sw, sh),
              ],
            ),
          ),
        ),
        SizedBox(height: sh * 0.012),
        // List
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await ref.read(contactsProvider.notifier).loadContacts();
            },
            color: Theme.of(context).primaryColor,
            child: flatEvents.isEmpty
                ? Center(child: Text("No $_selectedEventType events recorded", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)))
                : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: sh * 0.008).copyWith(bottom: sh * 0.16),
              itemCount: flatEvents.length,
              itemBuilder: (context, index) {
                final ev = flatEvents[index];
                return _buildEventCard(
                  ev['name'],
                  ev['dateStr'],
                  ev['subtitle'],
                  ev['icon'],
                  ev['color'],
                  sw, sh,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventToggleBtn(String label, String type, Color color, double sw, double sh) {
    final isSelected = _selectedEventType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedEventType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: sh * 0.012, horizontal: sw * 0.04),
        decoration: BoxDecoration(
          color: isSelected ? color : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(sw * 0.05),
          boxShadow: isSelected
              ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]
              : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: FontWeight.bold,
              fontSize: sw * 0.036,
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SHARED EVENT CARD
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildEventCard(
      String name,
      String dateOrType,
      String subtitle,
      IconData icon,
      Color color,
      double sw,
      double sh,
      ) {
    return Padding(
      padding: EdgeInsets.only(bottom: sh * 0.014),
      child: AppCard(
        padding: EdgeInsets.all(sw * 0.038),
        child: Row(
          children: [
            // Themed icon circle
            Container(
              width: sw * 0.12,
              height: sw * 0.12,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: sw * 0.058),
            ),
            SizedBox(width: sw * 0.035),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color, fontWeight: FontWeight.bold, fontSize: sw * 0.04),
                  ),
                  SizedBox(height: sh * 0.005),
                  Row(
                    children: [
                      // Colored date badge
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: sw * 0.02, vertical: sh * 0.004),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(sw * 0.02),
                        ),
                        child: Text(
                          dateOrType,
                          style: TextStyle(color: color, fontSize: sw * 0.03, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(width: sw * 0.02),
                      Text(
                        subtitle,
                        style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: sw * 0.029),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Theme.of(context).textTheme.labelSmall?.color, size: sw * 0.055),
          ],
        ),
      ),
    );
  }
}

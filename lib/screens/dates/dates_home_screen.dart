import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/common_widgets.dart';
import '../../providers/auth_provider.dart';

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
  String _selectedEventType = 'Birthday'; // 'Birthday' or 'Anniversary'

  // Person-wise state
  String _searchQuery = '';
  
  @override
  Widget build(BuildContext context) {
    // final isAdmin = ref.watch(authProvider).user?.isAdmin ?? false;
    final size = MediaQuery.of(context).size;
    final horizontalPadding = size.width * 0.045;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTopFilterToggle(horizontalPadding),
          Expanded(
            child: _buildBodyForFilter(horizontalPadding),
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
      title: const Text("Dates & Events"),
      actions: const [SizedBox(width: 48)],
    );
  }

  Widget _buildTopFilterToggle(double horizontalPadding) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
      child: Container(
        height: 50,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: kInputBg,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            _buildToggleOption("Date", 0),
            _buildToggleOption("Person", 1),
            _buildToggleOption("Event", 2),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleOption(String label, int index) {
    bool isSelected = _selectedFilterType == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilterType = index),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(21),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? kPrimaryColor : kTextSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBodyForFilter(double horizontalPadding) {
    switch (_selectedFilterType) {
      case 0:
        return _buildDateWiseView(horizontalPadding);
      case 1:
        return _buildPersonWiseView(horizontalPadding);
      case 2:
        return _buildEventWiseView(horizontalPadding);
      default:
        return const SizedBox();
    }
  }

  // ==========================================
  // DATE-WISE FILTERS & VIEW
  // ==========================================
  Widget _buildDateWiseView(double horizontalPadding) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
          child: GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                builder: (context, child) => Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(primary: kPrimaryColor),
                  ),
                  child: child!,
                ),
              );
              if (date != null) {
                setState(() => _selectedDate = date);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: kInputBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_month, color: kPrimaryColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('dd MMMM yyyy').format(_selectedDate),
                    style: const TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_drop_down, color: kTextSecondary),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildMockEventCard("Ali Raza", "Birthday", kPrimaryColor, Icons.cake, "28 years old"),
              _buildMockEventCard("Sara & Usman", "Anniversary", Colors.purple, Icons.favorite, "5th Anniversary"),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // PERSON-WISE FILTERS & VIEW
  // ==========================================
  Widget _buildPersonWiseView(double horizontalPadding) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
          child: AppCard(
            borderRadius: 30,
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              style: const TextStyle(color: kTextPrimary),
              decoration: const InputDecoration(
                hintText: "Search person...",
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                prefixIcon: Icon(Icons.search, color: kTextSecondary),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
            children: [
              if (_searchQuery.isEmpty || "kashif".contains(_searchQuery.toLowerCase()))
                _buildMockPersonBlock("Kashif", "10 September 1995", "15 January 2020"),
              
              if (_searchQuery.isEmpty || "tahir".contains(_searchQuery.toLowerCase()))
                _buildMockPersonBlock("M. Tahir", "12 March 1998", null),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMockPersonBlock(String name, String birthday, String? anniversary) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GradientAvatar(radius: 20, initials: name[0]),
              const SizedBox(width: 12),
              Text(name, style: const TextStyle(color: kTextPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow(Icons.cake, "Birthday", birthday, kPrimaryColor),
          if (anniversary != null) ...[
            const SizedBox(height: 12),
            _buildDetailRow(Icons.favorite, "Anniversary", anniversary, Colors.purple),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: kTextSecondary, fontSize: 12)),
            Text(value, style: const TextStyle(color: kTextPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  // ==========================================
  // EVENT-WISE FILTERS & VIEW
  // ==========================================
  Widget _buildEventWiseView(double horizontalPadding) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedEventType = 'Birthday'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _selectedEventType == 'Birthday' ? kPrimaryColor : kInputBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text("Birthdays", style: TextStyle(color: _selectedEventType == 'Birthday' ? Colors.white : kTextSecondary, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedEventType = 'Anniversary'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _selectedEventType == 'Anniversary' ? Colors.purple : kInputBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text("Anniversaries", style: TextStyle(color: _selectedEventType == 'Anniversary' ? Colors.white : kTextSecondary, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
            children: _selectedEventType == 'Birthday' 
              ? [
                  _buildMockEventCard("Hassan Ali", "12 March", kPrimaryColor, Icons.cake, "Turns 30"),
                  _buildMockEventCard("Zainab", "16 April", kPrimaryColor, Icons.cake, "Turns 25"),
                ]
              : [
                  _buildMockEventCard("Ayesha & Raza", "28 March", Colors.purple, Icons.favorite, "10 Years"),
                  _buildMockEventCard("Khalid Parents", "5 May", Colors.purple, Icons.favorite, "35 Years"),
                ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // COMMON MOCK WIDGETS
  // ==========================================
  Widget _buildMockEventCard(String name, String dateOrType, Color color, IconData icon, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(dateOrType, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
                      const Text(" • ", style: TextStyle(color: kTextTertiary)),
                      Text(subtitle, style: const TextStyle(color: kTextSecondary, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: kTextTertiary),
          ],
        ),
      ),
    );
  }
}

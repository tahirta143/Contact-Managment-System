import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/common_widgets.dart';
import '../../providers/reminders_provider.dart';
import '../../providers/contacts_provider.dart';

class AddReminderScreen extends ConsumerStatefulWidget {
  const AddReminderScreen({super.key});

  @override
  ConsumerState<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends ConsumerState<AddReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _reminderDate;
  String? _selectedContactId;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    if (_formKey.currentState!.validate() && _reminderDate != null) {
      final reminderData = {
        "title": _titleController.text.trim(),
        "description": _descController.text.trim(),
        "reminderDate": _reminderDate!.toIso8601String().split('T')[0],
        "contactId": _selectedContactId,
      };

      await ref.read(remindersProvider.notifier).addReminder(reminderData);
      
      final error = ref.read(remindersProvider).error;
      if (error == null) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Reminder added successfully!"), backgroundColor: Colors.green),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: Colors.red),
          );
        }
      }
    } else if (_reminderDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a date")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final contacts = ref.watch(contactsProvider).contacts;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Add Reminder"),
        actions: [
          TextButton(
            onPressed: _handleSave,
            child: const Text("SAVE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(sw * 0.05),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Title*",
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) => (v == null || v.isEmpty) ? "Title is required" : null,
              ),
              SizedBox(height: sh * 0.02),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: "Description",
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                maxLines: 3,
              ),
              SizedBox(height: sh * 0.02),
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) setState(() => _reminderDate = date);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sh * 0.018),
                  decoration: BoxDecoration(
                    color: kInputBg,
                    borderRadius: BorderRadius.circular(sw * 0.075),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: kPrimaryColor),
                      SizedBox(width: sw * 0.03),
                      Text(
                        _reminderDate != null ? DateFormat('yyyy-MM-dd').format(_reminderDate!) : "Select Date*",
                        style: TextStyle(color: _reminderDate != null ? kTextPrimary : kTextSecondary),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: sh * 0.03),
              const Text("Link to Contact (Optional)", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: sh * 0.01),
              DropdownButtonFormField<String>(
                value: _selectedContactId,
                items: contacts.map((c) {
                  return DropdownMenuItem(value: c.id, child: Text(c.name));
                }).toList(),
                onChanged: (val) => setState(() => _selectedContactId = val),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person_outline),
                  hintText: "Select a contact",
                ),
              ),
              SizedBox(height: sh * 0.05),
              SizedBox(
                width: double.infinity,
                height: sh * 0.06,
                child: ElevatedButton(
                  onPressed: _handleSave,
                  child: const Text("CREATE REMINDER"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

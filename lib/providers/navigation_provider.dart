import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

/// Manages the selected index of the MainScreen (Bottom Navigation Bar)
final mainSelectedIndexProvider = StateProvider<int>((ref) => 0);

/// Manages the active filter tab in the ContactsListScreen ('All' or 'By Group')
final contactsActiveTabProvider = StateProvider<String>((ref) => 'All');

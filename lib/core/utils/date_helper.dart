import 'package:intl/intl.dart';

class DateHelper {
  // Calculate age from birthday
  static int calculateAge(DateTime birthday) {
    final today = DateTime.now();
    int age = today.year - birthday.year;
    if (today.month < birthday.month ||
        (today.month == birthday.month && today.day < birthday.day)) {
      age--;
    }
    return age;
  }

  // Calculate years (for anniversary)
  static int calculateYears(DateTime since) => calculateAge(since);

  // Days until next occurrence of a date (birthday/anniversary repeat yearly)
  static int daysUntilNextOccurrence(DateTime date) {
    final today = DateTime.now();
    var next = DateTime(today.year, date.month, date.day);
    if (next.isBefore(DateTime(today.year, today.month, today.day))) {
      next = DateTime(today.year + 1, date.month, date.day);
    }
    return next.difference(DateTime(today.year, today.month, today.day)).inDays;
  }

  // Format date for display: "10 September 1998"
  static String formatDateFull(DateTime date) {
    return DateFormat('d MMMM yyyy').format(date);
  }

  // Format date short: "10 Sep"
  static String formatDateShort(DateTime date) {
    return DateFormat('d MMM').format(date);
  }

  // Countdown text
  static String countdownText(int days) {
    if (days == 0) return "Today!";
    if (days == 1) return "Tomorrow";
    return "in $days days";
  }
}

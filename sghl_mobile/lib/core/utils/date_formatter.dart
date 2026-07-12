import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  /// Formats a date as "12 juin 2026"
  static String formatDate(DateTime dt) {
    return DateFormat('d MMMM yyyy', 'fr_FR').format(dt);
  }

  /// Formats a datetime as "12 juin 2026 à 14:30"
  static String formatDateTime(DateTime dt) {
    final datePart = DateFormat('d MMMM yyyy', 'fr_FR').format(dt);
    final timePart = DateFormat('HH:mm', 'fr_FR').format(dt);
    return '$datePart à $timePart';
  }

  /// Formats a time as "14:30"
  static String formatTime(DateTime dt) {
    return DateFormat('HH:mm', 'fr_FR').format(dt);
  }

  /// Formats a date as "12/06/2026"
  static String formatDateShort(DateTime dt) {
    return DateFormat('dd/MM/yyyy', 'fr_FR').format(dt);
  }

  /// Returns a human-readable relative time string in French,
  /// e.g. "il y a 2 heures", "il y a 3 jours"
  static String timeAgo(DateTime dt) {
    final now = DateTime.now();
    final difference = now.difference(dt);

    if (difference.isNegative) {
      return formatDate(dt);
    }

    final seconds = difference.inSeconds;
    final minutes = difference.inMinutes;
    final hours = difference.inHours;
    final days = difference.inDays;
    final weeks = (days / 7).floor();
    final months = (days / 30).floor();
    final years = (days / 365).floor();

    if (seconds < 60) {
      return "il y a quelques secondes";
    } else if (minutes < 60) {
      return minutes == 1 ? "il y a 1 minute" : "il y a $minutes minutes";
    } else if (hours < 24) {
      return hours == 1 ? "il y a 1 heure" : "il y a $hours heures";
    } else if (days < 7) {
      return days == 1 ? "il y a 1 jour" : "il y a $days jours";
    } else if (weeks < 4) {
      return weeks == 1 ? "il y a 1 semaine" : "il y a $weeks semaines";
    } else if (months < 12) {
      return months == 1 ? "il y a 1 mois" : "il y a $months mois";
    } else {
      return years == 1 ? "il y a 1 an" : "il y a $years ans";
    }
  }

  /// Returns true if the given date is today
  static bool isToday(DateTime dt) {
    final now = DateTime.now();
    return dt.year == now.year && dt.month == now.month && dt.day == now.day;
  }

  /// Returns true if the given date is in the future
  static bool isFuture(DateTime dt) {
    return dt.isAfter(DateTime.now());
  }
}

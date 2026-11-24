import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  static final Map<String, DateFormat> _formatCache = {};

  String get _locale => Intl.getCurrentLocale();

  DateFormat _formatter(String pattern) => _formatCache.putIfAbsent(
        '$pattern|$_locale',
        () => DateFormat(pattern, _locale),
      );

  String get formatDDMMYYYY => _formatter("dd.MM.yyyy").format(this);

  String get formatDDMMSYYYY => _formatter("dd.MM yyyy").format(this);

  String get formatDDMMM => _formatter("dd MMM").format(this);

  String get formatMMMM => _formatter("MMMM").format(this);

  String get formatHourMin => _formatter("HH:mm").format(this);

  String get formatYYYYMMDD => _formatter("yyyy.MM.dd").format(this);

  String toFormat(String format) => _formatter(format).format(this);

  // --------------------------------------------------------------------------------------------

  DateTime get startOfDay => DateTime(year, month, day);

  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  DateTime get startOfMonth => DateTime(year, month, 1);

  DateTime get endOfMonth {
    DateTime startOfNextMonth = (month < 12)
        ? DateTime(year, month + 1, 1)
        : DateTime(year + 1, 1, 1);
    return startOfNextMonth.subtract(const Duration(milliseconds: 1));
  }

  DateTime get startOfYear => DateTime(year, 1, 1);

  DateTime get endOfYear => DateTime(year, 12, 31, 23, 59, 59, 999);

  // --------------------------------------------------------------------------------------------

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  int get daysInMonth => DateTime(year, month + 1, 0).day;
}

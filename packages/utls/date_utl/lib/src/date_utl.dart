import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

class DateUtl {
  static int getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  static int getFirstDayOffset(int year, int month) {
    final firstDay = DateTime(year, month, 1);
    if (firstDay.weekday == 7) return 0;
    return firstDay.weekday;
  }

  static bool isSameDay(DateTime? date1, DateTime? date2) {
    if (date1 == null || date2 == null) return false;
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static int getRowCount(int year, int month) {
    final daysInMonth = getDaysInMonth(year, month);
    final firstDayOffset = getFirstDayOffset(year, month);

    final totalSlots = daysInMonth + firstDayOffset;
    return (totalSlots / 7).ceil();
  }

  static String dateFormatStartEnd(DateTimeRange dateTimeRange) {
    final start = dateTimeRange.start;
    final end = dateTimeRange.end;
    final _dateFormatDayMonth = DateFormat('d MMM');
    final dayMonthEnd = _dateFormatDayMonth.format(end);
    if (start.month == end.month) {
      final dayStart = _dateFormatDayMonth.format(start);
      return '$dayStart - $dayMonthEnd';
    }
    final dayMonthStart = _dateFormatDayMonth.format(start);
    return '$dayMonthStart - $dayMonthEnd';
  }
}

class MeetingRoomTimeHelper {
  const MeetingRoomTimeHelper._();

  static Duration nextRefreshDelay(DateTime now) {
    final nextTick = nextQuarterHour(now).add(const Duration(seconds: 1));
    return nextTick.difference(now);
  }

  static DateTime nextQuarterHour(DateTime now) {
    final base = DateTime(now.year, now.month, now.day, now.hour, now.minute);
    final remainder = now.minute % 15;
    final isExact = remainder == 0 && now.second == 0 && now.millisecond == 0;
    final minutesToAdd = isExact ? 0 : (15 - remainder);
    return base.add(Duration(minutes: minutesToAdd));
  }

  static String buildTimeRangeLabel(DateTime now) {
    final start = nextQuarterHour(now);
    final end = start.add(const Duration(minutes: 30));
    return '${formatTime(start)} - ${formatTime(end)}';
  }

  static String buildTimeRangeLabelFrom(DateTime start, DateTime end) {
    return '${formatTime(start)} - ${formatTime(end)}';
  }

  static String formatTime(DateTime time) {
    final hour12 = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final suffix = time.hour >= 12 ? 'PM' : 'AM';
    return '${hour12.toString().padLeft(2, '0')}:$minute $suffix';
  }

  static String formatDateLabel(
    DateTime date, {
    DateTime? today,
  }) {
    final now = today ?? DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    if (isToday) {
      return 'Today';
    }
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}

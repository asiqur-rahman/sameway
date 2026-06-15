import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

abstract final class CommuteTimeFormat {
  static final _parser = DateFormat('h:mm a');

  static String format(TimeOfDay time) {
    final dt = DateTime(2020, 1, 1, time.hour, time.minute);
    return _parser.format(dt);
  }

  static TimeOfDay? parse(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final dt = _parser.parse(raw.trim());
      return TimeOfDay(hour: dt.hour, minute: dt.minute);
    } catch (_) {
      return null;
    }
  }
}

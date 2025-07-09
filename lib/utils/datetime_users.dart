// File: lib/utils/datetime_helpers.dart

import 'package:flutter/foundation.dart'; // Untuk debugPrint

DateTime? tryParseDateTime(String? dateString) {
  if (dateString == null || dateString.isEmpty) {
    return null;
  }
  try {
    return DateTime.parse(dateString);
  } catch (e) {
    try {
      if (dateString.length == 19 && dateString.contains(' ')) {
        return DateTime.parse(dateString.replaceFirst(' ', 'T') + 'Z');
      }
    } catch (e2) {
      debugPrint('Warning: Could not parse date string "$dateString": $e2');
    }
  }
  return null;
}
import 'package:flutter/material.dart';

enum JournalCategory {
  gratitude,
  prayer,
  reflection;

  String get label => switch (this) {
        JournalCategory.gratitude => 'Gratitude',
        JournalCategory.prayer => 'Prayer',
        JournalCategory.reflection => 'Reflection',
      };

  String get dbValue => name;

  IconData get icon => switch (this) {
        JournalCategory.gratitude => Icons.favorite_rounded,
        JournalCategory.prayer => Icons.church_rounded,
        JournalCategory.reflection => Icons.auto_stories_rounded,
      };

  static JournalCategory fromDb(String? value) {
    return JournalCategory.values.firstWhere(
      (c) => c.name == value,
      orElse: () => JournalCategory.reflection,
    );
  }
}

/// Filter label shown on home chips — includes "All".
class JournalCategoryFilter {
  static const all = 'All';
  static const options = [
    all,
    'Gratitude',
    'Prayer',
    'Reflection',
  ];

  static bool matches(String filter, JournalCategory category) {
    if (filter == all) return true;
    return category.label == filter;
  }
}

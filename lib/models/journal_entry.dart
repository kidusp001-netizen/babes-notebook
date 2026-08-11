import '../models/journal_category.dart';
import '../utils/journal_content.dart';

class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.userId,
    required this.entryDate,
    required this.content,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final DateTime entryDate;
  final String content;
  final JournalCategory category;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isEmpty => JournalContent.isEmptyDocument(content);

  String get preview => JournalContent.plainTextPreview(content);

  JournalEntry copyWith({
    String? id,
    String? userId,
    DateTime? entryDate,
    String? content,
    JournalCategory? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      entryDate: entryDate ?? this.entryDate,
      content: content ?? this.content,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      entryDate: DateTime.parse(json['entry_date'] as String),
      content: json['content'] as String? ?? '',
      category: JournalCategory.fromDb(json['category'] as String?),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'entry_date': _dateOnly(entryDate),
      'content': content,
      'category': category.dbValue,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  static String _dateOnly(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

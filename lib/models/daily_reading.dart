class BibleVerse {
  const BibleVerse({
    required this.book,
    required this.chapter,
    required this.verse,
    required this.content,
  });

  final String book;
  final int chapter;
  final int verse;
  final String content;

  factory BibleVerse.fromJson(Map<String, dynamic> json) {
    return BibleVerse(
      book: json['book'] as String,
      chapter: json['chapter'] as int,
      verse: json['verse'] as int,
      content: json['content'] as String,
    );
  }
}

class ScriptureReading {
  const ScriptureReading({
    required this.source,
    required this.reference,
    required this.shortReference,
    required this.verses,
  });

  final String source;
  final String reference;
  final String shortReference;
  final List<BibleVerse> verses;

  String get fullText => verses.map((v) => v.content).join(' ');

  String get excerpt {
    if (verses.isEmpty) return '';
    final first = verses.first.content;
    return first.length > 140 ? '${first.substring(0, 140)}…' : first;
  }

  factory ScriptureReading.fromJson(Map<String, dynamic> json) {
    final passage = json['passage'] as List? ?? [];
    return ScriptureReading(
      source: json['source'] as String? ?? '',
      reference: json['display'] as String? ?? '',
      shortReference: json['short_display'] as String? ?? '',
      verses: passage
          .map((v) => BibleVerse.fromJson(Map<String, dynamic>.from(v)))
          .toList(),
    );
  }
}

class DailyReading {
  const DailyReading({
    required this.date,
    required this.summaryTitle,
    required this.titles,
    required this.saints,
    required this.fastDescription,
    required this.readings,
  });

  final DateTime date;
  final String summaryTitle;
  final List<String> titles;
  final List<String> saints;
  final String fastDescription;
  final List<ScriptureReading> readings;

  ScriptureReading? get gospel {
    for (final r in readings) {
      if (r.source == 'Gospel') return r;
    }
    return null;
  }

  ScriptureReading? get epistle {
    for (final r in readings) {
      if (r.source == 'Epistle') return r;
    }
    return null;
  }

  String get notificationTitle {
    final gospel = this.gospel;
    if (gospel != null) return "Today's Gospel — ${gospel.shortReference}";
    return summaryTitle.isNotEmpty ? summaryTitle : 'Daily Orthodox Reading';
  }

  String get notificationBody {
    final gospel = this.gospel;
    if (gospel != null && gospel.excerpt.isNotEmpty) return gospel.excerpt;
    return 'Open your notebook for today\'s readings.';
  }

  factory DailyReading.fromJson(Map<String, dynamic> json, DateTime date) {
    final readingsJson = json['readings'] as List? ?? [];
    return DailyReading(
      date: date,
      summaryTitle: json['summary_title'] as String? ?? '',
      titles: (json['titles'] as List?)?.cast<String>() ?? [],
      saints: (json['saints'] as List?)?.cast<String>() ?? [],
      fastDescription: json['fast_level_desc'] as String? ?? '',
      readings: readingsJson
          .map((r) => ScriptureReading.fromJson(Map<String, dynamic>.from(r)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary_title': summaryTitle,
      'titles': titles,
      'saints': saints,
      'fast_level_desc': fastDescription,
      'readings': readings
          .map(
            (r) => {
              'source': r.source,
              'display': r.reference,
              'short_display': r.shortReference,
              'passage': r.verses
                  .map(
                    (v) => {
                      'book': v.book,
                      'chapter': v.chapter,
                      'verse': v.verse,
                      'content': v.content,
                    },
                  )
                  .toList(),
            },
          )
          .toList(),
    };
  }
}

enum OrthodoxCalendar { gregorian, julian }

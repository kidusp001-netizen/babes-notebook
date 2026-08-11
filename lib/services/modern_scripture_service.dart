import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/daily_reading.dart';

/// Fetches plain, modern English scripture text (World English Bible).
class ModernScriptureService {
  static const _translation = 'web';

  static const _bookNames = {
    'GEN': 'genesis',
    'EXO': 'exodus',
    'LEV': 'leviticus',
    'NUM': 'numbers',
    'DEU': 'deuteronomy',
    'JOS': 'joshua',
    'JDG': 'judges',
    'RUT': 'ruth',
    '1SA': '1 samuel',
    '2SA': '2 samuel',
    '1KI': '1 kings',
    '2KI': '2 kings',
    '1CH': '1 chronicles',
    '2CH': '2 chronicles',
    'EZR': 'ezra',
    'NEH': 'nehemiah',
    'EST': 'esther',
    'JOB': 'job',
    'PSA': 'psalms',
    'PRO': 'proverbs',
    'ECC': 'ecclesiastes',
    'SNG': 'song of solomon',
    'ISA': 'isaiah',
    'JER': 'jeremiah',
    'LAM': 'lamentations',
    'EZK': 'ezekiel',
    'DAN': 'daniel',
    'HOS': 'hosea',
    'JOL': 'joel',
    'AMO': 'amos',
    'OBA': 'obadiah',
    'JON': 'jonah',
    'MIC': 'micah',
    'NAM': 'nahum',
    'HAB': 'habakkuk',
    'ZEP': 'zephaniah',
    'HAG': 'haggai',
    'ZEC': 'zechariah',
    'MAL': 'malachi',
    'MAT': 'matthew',
    'MRK': 'mark',
    'LUK': 'luke',
    'JHN': 'john',
    'ACT': 'acts',
    'ROM': 'romans',
    '1CO': '1 corinthians',
    '2CO': '2 corinthians',
    'GAL': 'galatians',
    'EPH': 'ephesians',
    'PHP': 'philippians',
    'COL': 'colossians',
    '1TH': '1 thessalonians',
    '2TH': '2 thessalonians',
    '1TI': '1 timothy',
    '2TI': '2 timothy',
    'TIT': 'titus',
    'PHM': 'philemon',
    'HEB': 'hebrews',
    'JAM': 'james',
    '1PE': '1 peter',
    '2PE': '2 peter',
    '1JN': '1 john',
    '2JN': '2 john',
    '3JN': '3 john',
    'JUD': 'jude',
    'REV': 'revelation',
  };

  Future<ScriptureReading?> modernize(ScriptureReading reading) async {
    if (reading.verses.isEmpty) return null;

    final first = reading.verses.first;
    final last = reading.verses.last;
    final book = _bookNames[first.book.toUpperCase()];
    if (book == null) return null;

    final range = first.verse == last.verse
        ? '${first.chapter}:${first.verse}'
        : '${first.chapter}:${first.verse}-${last.verse}';

    final url = Uri.parse(
      'https://bible-api.com/${Uri.encodeComponent('$book $range')}?translation=$_translation',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final versesJson = json['verses'] as List?;
      if (versesJson == null || versesJson.isEmpty) return null;

      final verses = versesJson
          .map(
            (v) => BibleVerse(
              book: first.book,
              chapter: v['chapter'] as int,
              verse: v['verse'] as int,
              content: (v['text'] as String).trim(),
            ),
          )
          .toList();

      return ScriptureReading(
        source: reading.source,
        reference: reading.reference,
        shortReference: reading.shortReference,
        verses: verses,
      );
    } catch (_) {
      return null;
    }
  }

  Future<DailyReading> applyModernText(DailyReading reading) async {
    final updated = <ScriptureReading>[];

    for (final section in reading.readings) {
      if (section.source == 'Gospel' || section.source == 'Epistle') {
        final modern = await modernize(section);
        updated.add(modern ?? section);
      } else {
        updated.add(section);
      }
    }

    return DailyReading(
      date: reading.date,
      summaryTitle: reading.summaryTitle,
      titles: reading.titles,
      saints: reading.saints,
      fastDescription: reading.fastDescription,
      readings: updated,
    );
  }
}

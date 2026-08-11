import 'dart:convert';

import 'package:flutter_quill/flutter_quill.dart';

/// Reads/writes journal body as Quill delta JSON or plain text.
class JournalContent {
  static const _dearFather = 'Dear Father,\n\n';

  static Document documentFromStorage(String? raw) {
    if (raw == null || raw.isEmpty) {
      return Document()..insert(0, _dearFather);
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return Document.fromJson(decoded);
      }
    } catch (_) {
      // Plain text from older entries.
    }
    return Document()..insert(0, raw);
  }

  static String documentToStorage(Document doc) {
    if (doc.isEmpty()) return '';
    return jsonEncode(doc.toDelta().toJson());
  }

  static bool isEmptyDocument(String? raw) {
    if (raw == null || raw.trim().isEmpty) return true;
    return documentFromStorage(raw).toPlainText().trim().isEmpty;
  }

  static String plainTextPreview(String raw) {
    final text = documentFromStorage(raw).toPlainText().trim();
    if (text.isEmpty) return 'Empty entry';
    return text.length > 120 ? '${text.substring(0, 120)}…' : text;
  }
}

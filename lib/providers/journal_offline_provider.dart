import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether journal data is being shown from offline cache.
final journalOfflineProvider = StateProvider<bool>((ref) => false);

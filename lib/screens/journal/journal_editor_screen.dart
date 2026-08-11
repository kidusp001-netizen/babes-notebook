import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../config/theme.dart';
import '../../models/journal_category.dart';
import '../../models/journal_entry.dart';
import '../../providers/journal_offline_provider.dart';
import '../../services/journal_service.dart';
import '../../utils/journal_content.dart';
import '../../widgets/category_badge.dart';
import '../../widgets/queen_editor_toolbar.dart';

class JournalEditorScreen extends ConsumerStatefulWidget {
  const JournalEditorScreen({
    super.key,
    this.entryDate,
    this.entryId,
    this.initialContent,
    this.initialCategory,
  });

  final DateTime? entryDate;
  final String? entryId;
  final String? initialContent;
  final JournalCategory? initialCategory;

  @override
  ConsumerState<JournalEditorScreen> createState() =>
      _JournalEditorScreenState();
}

class _JournalEditorScreenState extends ConsumerState<JournalEditorScreen> {
  late final QuillController _quillController;
  late final FocusNode _focusNode;
  late final ScrollController _scrollController;
  late DateTime _entryDate;
  late JournalCategory _category;
  Timer? _saveTimer;
  bool _isSaving = false;
  bool _hasUnsavedChanges = false;
  String? _savedEntryId;

  bool get _isPastDate {
    final today = JournalEntry.normalizeDate(DateTime.now());
    return _entryDate.isBefore(today);
  }

  @override
  void initState() {
    super.initState();
    _entryDate = JournalEntry.normalizeDate(widget.entryDate ?? DateTime.now());
    _category = widget.initialCategory ?? JournalCategory.reflection;
    _savedEntryId = widget.entryId;
    _focusNode = FocusNode();
    _scrollController = ScrollController();
    _quillController = QuillController(
      document: JournalContent.documentFromStorage(widget.initialContent),
      selection: const TextSelection.collapsed(offset: 0),
    );
    _quillController.document.changes.listen((_) => _onTextChanged());
  }

  void _onTextChanged() {
    _hasUnsavedChanges = true;
    _scheduleAutoSave();
  }

  void _onCategoryChanged(JournalCategory category) {
    setState(() => _category = category);
    _hasUnsavedChanges = true;
    _scheduleAutoSave();
  }

  void _scheduleAutoSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 1500), _save);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _entryDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Pick journal date',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primary,
              onPrimary: Colors.white,
              surface: AppTheme.surface,
              onSurface: AppTheme.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _entryDate = JournalEntry.normalizeDate(picked));
      _hasUnsavedChanges = true;
      _scheduleAutoSave();
    }
  }

  Future<void> _save() async {
    if (!_hasUnsavedChanges && _savedEntryId != null) return;

    setState(() => _isSaving = true);

    try {
      final content =
          JournalContent.documentToStorage(_quillController.document);
      final saved = await ref.read(journalEntriesProvider.notifier).saveEntry(
            id: _savedEntryId,
            entryDate: _entryDate,
            content: content,
            category: _category,
          );
      _savedEntryId = saved.id;
      _hasUnsavedChanges = false;
      if (mounted && ref.read(journalOfflineProvider)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Saved on this device — will sync when online.'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not save. Check your connection.'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _goBack() async {
    if (_hasUnsavedChanges) await _save();
    if (mounted) context.pop();
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    if (_hasUnsavedChanges) _save();
    _quillController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) await _goBack();
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(context),
              _buildDateHeader(context),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: CategoryPicker(
                  selected: _category,
                  onChanged: _onCategoryChanged,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(child: _buildEditor(context)),
              QueenEditorToolbar(controller: _quillController),
              _buildDoneButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          _CircleButton(icon: Icons.arrow_back_rounded, onTap: _goBack),
          const Spacer(),
          if (_isSaving)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.primary,
              ),
            )
          else if (!_hasUnsavedChanges && _savedEntryId != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: (ref.watch(journalOfflineProvider)
                        ? AppTheme.primary
                        : AppTheme.success)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    ref.watch(journalOfflineProvider)
                        ? Icons.cloud_off_rounded
                        : Icons.cloud_done_rounded,
                    size: 16,
                    color: (ref.watch(journalOfflineProvider)
                            ? AppTheme.primary
                            : AppTheme.success)
                        .withValues(alpha: 0.9),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    ref.watch(journalOfflineProvider) ? 'Saved offline' : 'Saved',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: ref.watch(journalOfflineProvider)
                              ? AppTheme.primary
                              : AppTheme.success,
                        ),
                  ),
                ],
              ),
            ),
          const Spacer(),
          _CircleButton(
            icon: Icons.delete_outline_rounded,
            onTap: _savedEntryId != null ? _confirmDelete : () {},
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete entry?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red.shade700)),
          ),
        ],
      ),
    );
    if (confirmed == true && _savedEntryId != null) {
      await ref
          .read(journalEntriesProvider.notifier)
          .deleteEntry(_savedEntryId!);
      if (mounted) context.pop();
    }
  }

  Widget _buildDateHeader(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickDate,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryLight,
                      AppTheme.roseGold.withValues(alpha: 0.3),
                    ],
                  ),
                ),
              ),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primaryDark],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.primaryShadow,
                ),
                child: Center(
                  child: Text(
                    DateFormat('d').format(_entryDate),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: MediaQuery.of(context).size.width * 0.32,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppTheme.surface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    size: 16,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          DateFormat('EEEE, MMMM yyyy').format(_entryDate),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          _isPastDate
              ? 'Writing for a past day — tap date to change ♡'
              : 'Tap date to write for another day ♡',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.primary,
                fontStyle: FontStyle.italic,
                fontSize: 12,
              ),
        ),
      ],
    );
  }

  Widget _buildEditor(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.cardShadow,
      ),
      child: QuillEditor.basic(
        controller: _quillController,
        focusNode: _focusNode,
        scrollController: _scrollController,
        config: QuillEditorConfig(
          placeholder: 'Tell Him about your day…',
          padding: EdgeInsets.zero,
          customStyles: DefaultStyles(
            paragraph: DefaultTextBlockStyle(
              Theme.of(context).textTheme.bodyLarge!.copyWith(
                    height: 1.75,
                    fontSize: 16,
                    color: AppTheme.textDark,
                  ),
              HorizontalSpacing.zero,
              VerticalSpacing.zero,
              VerticalSpacing.zero,
              null,
            ),
            placeHolder: DefaultTextBlockStyle(
              Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontSize: 16,
                    color: AppTheme.textMuted,
                    fontStyle: FontStyle.italic,
                  ),
              HorizontalSpacing.zero,
              VerticalSpacing.zero,
              VerticalSpacing.zero,
              null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDoneButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.primary, AppTheme.primaryDark],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.primaryShadow,
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            minimumSize: const Size(double.infinity, 56),
          ),
          onPressed: _isSaving ? null : _goBack,
          child: Text(_isSaving ? 'Saving…' : 'Done ♡'),
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.border),
        ),
        child: Icon(icon, color: AppTheme.textDark, size: 22),
      ),
    );
  }
}

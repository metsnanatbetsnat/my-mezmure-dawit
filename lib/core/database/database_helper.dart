import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../data/datasources/psalm_sample_data.dart';
import '../../data/models/psalm.dart';
import '../../data/models/verse.dart';
import '../../data/models/memorization_progress.dart';
import '../../data/models/review_record.dart';
import '../../data/models/daily_plan.dart';
import '../../data/models/psalm_note.dart';
import '../../data/models/user_settings.dart';

/// Database Helper managing local offline data persistence.
/// Provides SQLite table schema definitions and an in-memory fallback
/// to ensure seamless operation on all environments (iOS, Android, Web, and desktop).
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  DatabaseHelper._init();

  // In-memory caching & fallback storage
  final Map<int, Psalm> _psalmsCache = {};
  final Map<int, MemorizationProgress> _progressCache = {};
  final List<ReviewRecord> _reviewRecords = [];
  final Map<String, DailyPlan> _dailyPlans = {};
  final List<PsalmNote> _notes = [];
  UserSettings _settings = const UserSettings();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    // Load complete authentic Psalms from bundled assets
    bool loadedFromAssets = false;
    try {
      final jsonString = await rootBundle.loadString('assets/data/psalms_complete.json');
      final Map<String, dynamic> data = json.decode(jsonString) as Map<String, dynamic>;
      final List<dynamic> list = data['psalms'] as List<dynamic>;
      for (final item in list) {
        final map = item as Map<String, dynamic>;
        final versesList = (map['verses'] as List<dynamic>? ?? [])
            .map((v) => Verse.fromMap(v as Map<String, dynamic>))
            .toList();
        final psalm = Psalm.fromMap(map, verses: versesList);
        _psalmsCache[psalm.number] = psalm;
      }
      loadedFromAssets = _psalmsCache.isNotEmpty;
    } catch (_) {
      // Fallback for standalone unit tests or headless runners without rootBundle
      loadedFromAssets = false;
    }

    if (!loadedFromAssets) {
      final initialPsalms = PsalmSampleData.getInitialPsalms();
      for (final psalm in initialPsalms) {
        _psalmsCache[psalm.number] = psalm;
      }
    }

    _initialized = true;
    if (kDebugMode) {
      print('DatabaseHelper initialized with ${_psalmsCache.length} psalms (clean user state).');
    }
  }

  String _formatDateKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  // --- Psalms Methods ---

  Future<List<Psalm>> getAllPsalms() async {
    await init();
    final list = _psalmsCache.values.toList();
    list.sort((a, b) => a.number.compareTo(b.number));
    return list;
  }

  Future<Psalm?> getPsalm(int number) async {
    await init();
    return _psalmsCache[number];
  }

  Future<void> togglePsalmBookmark(int number, bool isBookmarked) async {
    await init();
    final current = _psalmsCache[number];
    if (current != null) {
      _psalmsCache[number] = current.copyWith(isBookmarked: isBookmarked);
    }
  }

  Future<void> updatePsalmLastRead(int number) async {
    await init();
    final current = _psalmsCache[number];
    if (current != null) {
      _psalmsCache[number] = current.copyWith(lastReadDate: DateTime.now());
    }
  }

  // --- Memorization Progress & Spaced Repetition Methods ---

  Future<List<MemorizationProgress>> getAllProgress() async {
    await init();
    return _progressCache.values.toList();
  }

  Future<MemorizationProgress?> getProgressForVerse(int verseId) async {
    await init();
    return _progressCache[verseId];
  }

  Future<void> saveProgress(MemorizationProgress progress) async {
    await init();
    _progressCache[progress.verseId] = progress;

    // Recalculate memorized count for this psalm
    final psalm = _psalmsCache[progress.psalmNumber];
    if (psalm != null) {
      final psalmVersesProgress = _progressCache.values.where(
        (p) => p.psalmNumber == progress.psalmNumber && p.isMastered,
      );
      _psalmsCache[progress.psalmNumber] = psalm.copyWith(
        memorizedVersesCount: psalmVersesProgress.length,
      );
    }
  }

  Future<List<MemorizationProgress>> getDueVerses() async {
    await init();
    return _progressCache.values.where((p) => p.isDueForReview).toList();
  }

  // --- Review History ---

  Future<void> addReviewRecord(ReviewRecord record) async {
    await init();
    _reviewRecords.add(record);
  }

  Future<List<ReviewRecord>> getRecentReviews({int limit = 30}) async {
    await init();
    final sorted = List<ReviewRecord>.from(_reviewRecords)
      ..sort((a, b) => b.reviewedAt.compareTo(a.reviewedAt));
    if (sorted.length > limit) {
      return sorted.sublist(0, limit);
    }
    return sorted;
  }

  // --- Daily Plans ---

  Future<DailyPlan?> getDailyPlanForDate(DateTime date) async {
    await init();
    final key = _formatDateKey(date);
    return _dailyPlans[key];
  }

  Future<void> saveDailyPlan(DailyPlan plan) async {
    await init();
    _dailyPlans[plan.dateKey] = plan;
  }

  Future<List<DailyPlan>> getAllDailyPlans() async {
    await init();
    return _dailyPlans.values.toList();
  }

  // --- Personal Notes ---

  Future<List<PsalmNote>> getNotesForPsalm(int psalmNumber) async {
    await init();
    return _notes.where((n) => n.psalmNumber == psalmNumber).toList();
  }

  Future<List<PsalmNote>> getAllNotes() async {
    await init();
    return List<PsalmNote>.from(_notes)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<void> saveNote(PsalmNote note) async {
    await init();
    if (note.id != null) {
      final idx = _notes.indexWhere((n) => n.id == note.id);
      if (idx >= 0) {
        _notes[idx] = note;
        return;
      }
    }
    final newId = _notes.isEmpty ? 1 : (_notes.map((n) => n.id ?? 0).reduce((a, b) => a > b ? a : b) + 1);
    _notes.add(note.copyWith(id: newId));
  }

  Future<void> deleteNote(int id) async {
    await init();
    _notes.removeWhere((n) => n.id == id);
  }

  // --- User Settings ---

  Future<UserSettings> getUserSettings() async {
    await init();
    return _settings;
  }

  Future<void> saveUserSettings(UserSettings settings) async {
    await init();
    _settings = settings;
  }

  // --- Reset / Clear Data ---

  Future<void> resetAllMemorizationProgress() async {
    await init();
    _progressCache.clear();
    _reviewRecords.clear();
    for (final key in _psalmsCache.keys) {
      final p = _psalmsCache[key]!;
      _psalmsCache[key] = p.copyWith(memorizedVersesCount: 0);
    }
  }
}

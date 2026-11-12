import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/models/memorization_progress.dart';
import '../../data/models/review_record.dart';
import '../../data/models/verse.dart';
import '../../data/models/psalm.dart';
import '../../data/models/daily_plan.dart';
import '../../data/repositories/memorization_repository.dart';

enum MemorizeMode {
  read, // ፩. ንባብ (Read the Complete Psalm Song)
  hiddenWords, // ፪. የተሰወሩ ቃላት (Hidden Words Across Whole Psalm)
  fidelCue, // ፫. የፊደል ፍንጭ (First-Letter Mnemonic Prompts for Whole Song)
  recall, // ፬. ማስታወስ (Prompt Cue + Reveal Complete Song)
  psalmNumberRecall, // ፭. ቁጥር ማስታወስ (Recall Psalm Number from Random Studied Psalm)
  recitation, // ፮. ማዜም (Recite Complete Psalm Unassisted)
}

class MemorizationProvider extends ChangeNotifier {
  final MemorizationRepository _repo;

  List<MemorizationProgress> _allProgress = [];
  List<ReviewRecord> _recentReviews = [];
  DailyPlan? _todayPlan;
  bool _isLoading = true;

  // Active Psalm Song Session (Memorizing the entire Psalm song at once)
  Psalm? _sessionPsalm;
  MemorizeMode _currentMode = MemorizeMode.recall;

  // Mode 1: Whole Psalm Read counter
  int _psalmSongReadCount = 0;

  // Mode 2: Hidden Words across the Psalm
  final Set<int> _revealedWordKeys = {};

  // Mode 3: Fidel Cues
  final Set<int> _revealedFidelKeys = {};

  // Mode 4: Recall state
  bool _isAnswerRevealed = false;

  // Mode 5: Random Psalm Number Recall Challenge
  Psalm? _randomChallengePsalm;
  List<int> _psalmNumberOptions = [];
  int? _selectedGuessNumber;
  bool _isGuessCorrect = false;
  bool _isAnswerRevealedForNumber = false;
  int _correctNumberGuesses = 0;
  int _totalNumberGuesses = 0;
  bool _filterStudiedOnly = true;

  // Rating & Feedback
  String? _lastSessionRating;

  // Cross-reference visibility toggles (Ge'ez is primary)
  bool _showAmharicReference = true;
  bool _showEnglishReference = true;

  MemorizationProvider({MemorizationRepository? repo})
      : _repo = repo ?? MemorizationRepository() {
    loadProgress();
  }

  // Getters
  bool get isLoading => _isLoading;
  List<MemorizationProgress> get allProgress => _allProgress;
  List<ReviewRecord> get recentReviews => _recentReviews;
  DailyPlan? get todayPlan => _todayPlan;

  Psalm? get sessionPsalm => _sessionPsalm;
  MemorizeMode get currentMode => _currentMode;
  int get psalmSongReadCount => _psalmSongReadCount;
  Set<int> get revealedWordKeys => _revealedWordKeys;
  Set<int> get revealedFidelKeys => _revealedFidelKeys;
  bool get isAnswerRevealed => _isAnswerRevealed;
  String? get lastSessionRating => _lastSessionRating;
  bool get showAmharicReference => _showAmharicReference;
  bool get showEnglishReference => _showEnglishReference;

  // Psalm Number Recall Getters
  Psalm? get randomChallengePsalm => _randomChallengePsalm;
  List<int> get psalmNumberOptions => _psalmNumberOptions;
  int? get selectedGuessNumber => _selectedGuessNumber;
  bool get isGuessCorrect => _isGuessCorrect;
  bool get isAnswerRevealedForNumber => _isAnswerRevealedForNumber;
  int get correctNumberGuesses => _correctNumberGuesses;
  int get totalNumberGuesses => _totalNumberGuesses;
  bool get filterStudiedOnly => _filterStudiedOnly;

  // Spaced Repetition lists
  List<MemorizationProgress> get dueVerses =>
      _allProgress.where((p) => p.isDueForReview).toList();

  List<MemorizationProgress> get masteredVerses =>
      _allProgress.where((p) => p.isMastered).toList();

  List<MemorizationProgress> get learningVerses =>
      _allProgress.where((p) => p.repetitionLevel > 0 && !p.isMastered).toList();

  int get totalPsalmsCompleted =>
      _allProgress.where((p) => p.isMastered).map((p) => p.psalmNumber).toSet().length;

  int get totalVersesLearned => _allProgress.where((p) => p.repetitionLevel > 0).length;

  Set<int> get studiedPsalmNumbers {
    final set = _allProgress.where((p) => p.repetitionLevel > 0).map((p) => p.psalmNumber).toSet();
    if (_sessionPsalm != null) set.add(_sessionPsalm!.number);
    // Always include at least core canonical psalms if set is very small
    if (set.length < 3) {
      set.addAll([1, 23, 50, 120, 150]);
    }
    return set;
  }

  Future<void> loadProgress() async {
    _isLoading = true;
    notifyListeners();

    _allProgress = await _repo.getAllProgress();
    _recentReviews = await _repo.getRecentReviews();
    _todayPlan = await _repo.getDailyPlan(DateTime.now());

    _isLoading = false;
    notifyListeners();
  }

  // --- Start Session for a Whole Psalm Song ---

  void startPsalmSongSession({
    required Psalm psalm,
    MemorizeMode initialMode = MemorizeMode.recall,
    List<Psalm>? allPsalms,
  }) {
    _sessionPsalm = psalm;
    _currentMode = initialMode;
    _psalmSongReadCount = 0;
    _revealedWordKeys.clear();
    _revealedFidelKeys.clear();
    _isAnswerRevealed = false;
    _lastSessionRating = null;

    if (initialMode == MemorizeMode.psalmNumberRecall && allPsalms != null) {
      generateRandomPsalmNumberChallenge(allPsalms: allPsalms);
    }

    notifyListeners();
  }

  void setMode(MemorizeMode mode, {List<Psalm>? allPsalms}) {
    _currentMode = mode;
    _revealedWordKeys.clear();
    _revealedFidelKeys.clear();
    _isAnswerRevealed = false;

    if (mode == MemorizeMode.psalmNumberRecall && allPsalms != null && _randomChallengePsalm == null) {
      generateRandomPsalmNumberChallenge(allPsalms: allPsalms);
    }

    notifyListeners();
  }

  void incrementSongReadCount() {
    _psalmSongReadCount += 1;
    notifyListeners();
  }

  void toggleAmharicRef() {
    _showAmharicReference = !_showAmharicReference;
    notifyListeners();
  }

  void toggleEnglishRef() {
    _showEnglishReference = !_showEnglishReference;
    notifyListeners();
  }

  // Hidden word toggle by unique token key
  void toggleWordRevealed(int tokenKey) {
    if (_revealedWordKeys.contains(tokenKey)) {
      _revealedWordKeys.remove(tokenKey);
    } else {
      _revealedWordKeys.add(tokenKey);
    }
    notifyListeners();
  }

  void revealAllHiddenWords() {
    if (_sessionPsalm == null) return;
    int key = 0;
    for (final v in _sessionPsalm!.verses) {
      final words = (v.textGeez.isNotEmpty ? v.textGeez : v.textAmharic).split(RegExp(r'\s+'));
      for (int i = 0; i < words.length; i++) {
        _revealedWordKeys.add(key);
        key++;
      }
    }
    notifyListeners();
  }

  void hideAllHiddenWords() {
    _revealedWordKeys.clear();
    notifyListeners();
  }

  // Fidel Cue toggle
  void toggleFidelRevealed(int key) {
    if (_revealedFidelKeys.contains(key)) {
      _revealedFidelKeys.remove(key);
    } else {
      _revealedFidelKeys.add(key);
    }
    notifyListeners();
  }

  // Recall Answer toggle
  void toggleAnswerReveal() {
    _isAnswerRevealed = !_isAnswerRevealed;
    notifyListeners();
  }

  // ============================================================
  // Mode 5: Random Psalm Number Recall Challenge
  // "give me a random psalm from I studied and I will recall the psalm number"
  // ============================================================

  void generateRandomPsalmNumberChallenge({
    required List<Psalm> allPsalms,
    bool? studiedOnly,
  }) {
    if (allPsalms.isEmpty) return;

    if (studiedOnly != null) {
      _filterStudiedOnly = studiedOnly;
    }

    final rand = Random();
    List<Psalm> candidatesPool;

    if (_filterStudiedOnly) {
      final studiedNums = studiedPsalmNumbers;
      candidatesPool = allPsalms.where((p) => studiedNums.contains(p.number)).toList();
      if (candidatesPool.isEmpty) candidatesPool = allPsalms;
    } else {
      candidatesPool = allPsalms;
    }

    // Pick random psalm from the pool
    final target = candidatesPool[rand.nextInt(candidatesPool.length)];
    _randomChallengePsalm = target;

    // Pick 3 distinct distractor numbers
    final options = <int>{target.number};
    final availableNumbers = allPsalms.map((p) => p.number).where((n) => n != target.number).toList();
    availableNumbers.shuffle(rand);

    for (final num in availableNumbers) {
      if (options.length >= 4) break;
      options.add(num);
    }

    _psalmNumberOptions = options.toList()..shuffle(rand);
    _selectedGuessNumber = null;
    _isGuessCorrect = false;
    _isAnswerRevealedForNumber = false;

    notifyListeners();
  }

  void submitPsalmNumberGuess(int guess) {
    if (_randomChallengePsalm == null) return;
    _selectedGuessNumber = guess;
    _isGuessCorrect = (guess == _randomChallengePsalm!.number);
    _totalNumberGuesses++;
    if (_isGuessCorrect) {
      _correctNumberGuesses++;
    }
    _isAnswerRevealedForNumber = true;
    notifyListeners();
  }

  void revealPsalmNumberAnswer() {
    _isAnswerRevealedForNumber = true;
    notifyListeners();
  }

  void toggleFilterStudiedOnly({required List<Psalm> allPsalms}) {
    _filterStudiedOnly = !_filterStudiedOnly;
    generateRandomPsalmNumberChallenge(allPsalms: allPsalms, studiedOnly: _filterStudiedOnly);
  }

  // Submit Self-Evaluation for the Whole Psalm Song
  Future<void> submitPsalmSongEvaluation(String rating) async {
    if (_sessionPsalm == null) return;

    _lastSessionRating = rating;

    // Apply spaced repetition rating to all verses of this Psalm song
    for (final verse in _sessionPsalm!.verses) {
      final existing = await _repo.getProgressForVerse(verse.id) ??
          MemorizationProgress(
            verseId: verse.id,
            psalmNumber: _sessionPsalm!.number,
            verseNumber: verse.verseNumber,
            nextReviewDate: DateTime.now(),
          );

      final updated = existing.applyReview(rating);
      await _repo.saveProgress(updated);

      final record = ReviewRecord(
        verseId: verse.id,
        psalmNumber: _sessionPsalm!.number,
        verseNumber: verse.verseNumber,
        modeUsed: _currentMode.name,
        rating: rating,
        reviewedAt: DateTime.now(),
        intervalDays: updated.intervalDays,
      );
      await _repo.logReview(record);
    }

    await loadProgress();
  }

  Future<void> resetAllProgress() async {
    await _repo.resetAll();
    await loadProgress();
  }
}

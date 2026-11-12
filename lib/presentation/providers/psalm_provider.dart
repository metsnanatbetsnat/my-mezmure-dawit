import 'package:flutter/material.dart';
import '../../data/models/psalm.dart';
import '../../data/models/psalm_note.dart';
import '../../data/repositories/psalm_repository.dart';
import '../../core/constants/ethiopic_numerals.dart';

enum PsalmFilterType { all, bookmarked, inProgress, mastered }

class PsalmProvider extends ChangeNotifier {
  final PsalmRepository _repo;
  List<Psalm> _allPsalms = [];
  bool _isLoading = true;
  String _searchQuery = '';
  PsalmFilterType _activeFilter = PsalmFilterType.all;

  // Selected Psalm for detail
  Psalm? _activePsalm;
  List<PsalmNote> _activeNotes = [];
  List<PsalmNote> _allNotes = [];

  PsalmProvider({PsalmRepository? repo}) : _repo = repo ?? PsalmRepository() {
    loadPsalms();
  }

  List<Psalm> get allPsalms => _allPsalms;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  PsalmFilterType get activeFilter => _activeFilter;
  Psalm? get activePsalm => _activePsalm;
  List<PsalmNote> get activeNotes => _activeNotes;
  List<PsalmNote> get allNotes => _allNotes;

  Future<void> loadPsalms() async {
    _isLoading = true;
    notifyListeners();
    _allPsalms = await _repo.getAllPsalms();
    _allNotes = await _repo.getAllNotes();
    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  void setFilter(PsalmFilterType filter) {
    _activeFilter = filter;
    notifyListeners();
  }

  List<Psalm> get filteredPsalms {
    var list = _allPsalms;

    // Apply filter tab
    switch (_activeFilter) {
      case PsalmFilterType.all:
        break;
      case PsalmFilterType.bookmarked:
        list = list.where((p) => p.isBookmarked).toList();
        break;
      case PsalmFilterType.inProgress:
        list = list.where((p) => p.memorizedVersesCount > 0 && !p.isFullyMemorized).toList();
        break;
      case PsalmFilterType.mastered:
        list = list.where((p) => p.isFullyMemorized).toList();
        break;
    }

    // Apply search query
    if (_searchQuery.isEmpty) return list;

    final q = _searchQuery.toLowerCase();
    return list.where((p) {
      final numStr = p.number.toString();
      final ethNum = p.ethiopicNumber;
      final titleAm = p.titleAmharic.toLowerCase();
      final titleGz = p.titleGeez.toLowerCase();
      final titleEn = p.titleEnglish.toLowerCase();

      // Check number match
      if (numStr == q || ethNum == q || 'መዝሙር $numStr'.contains(q) || 'መዝሙር $ethNum'.contains(q)) {
        return true;
      }

      // Check title match
      if (titleAm.contains(q) || titleGz.contains(q) || titleEn.contains(q)) {
        return true;
      }

      // Check inside verse texts
      for (final v in p.verses) {
        if (v.textAmharic.toLowerCase().contains(q) ||
            v.textGeez.toLowerCase().contains(q) ||
            v.textEnglish.toLowerCase().contains(q)) {
          return true;
        }
      }

      return false;
    }).toList();
  }

  Future<void> openPsalm(int number) async {
    _activePsalm = await _repo.getPsalmByNumber(number);
    if (_activePsalm != null) {
      await _repo.markAsRead(number);
      _activeNotes = await _repo.getNotesForPsalm(number);
    }
    notifyListeners();
  }

  Future<void> toggleBookmark(int number) async {
    final idx = _allPsalms.indexWhere((p) => p.number == number);
    if (idx >= 0) {
      final current = _allPsalms[idx];
      final updated = current.copyWith(isBookmarked: !current.isBookmarked);
      _allPsalms[idx] = updated;

      if (_activePsalm?.number == number) {
        _activePsalm = updated;
      }

      notifyListeners();
      await _repo.toggleBookmark(number, updated.isBookmarked);
    }
  }

  Future<void> addNote({
    required int psalmNumber,
    int? verseNumber,
    required String content,
    String? reflection,
  }) async {
    final now = DateTime.now();
    final note = PsalmNote(
      psalmNumber: psalmNumber,
      verseNumber: verseNumber,
      content: content,
      reflection: reflection,
      createdAt: now,
      updatedAt: now,
    );
    await _repo.saveNote(note);
    if (_activePsalm?.number == psalmNumber) {
      _activeNotes = await _repo.getNotesForPsalm(psalmNumber);
    }
    _allNotes = await _repo.getAllNotes();
    notifyListeners();
  }

  Future<void> deleteNote(int id) async {
    await _repo.deleteNote(id);
    if (_activePsalm != null) {
      _activeNotes = await _repo.getNotesForPsalm(_activePsalm!.number);
    }
    _allNotes = await _repo.getAllNotes();
    notifyListeners();
  }
}

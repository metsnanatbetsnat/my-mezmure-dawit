import '../models/psalm.dart';
import '../models/psalm_note.dart';
import '../../core/database/database_helper.dart';

class PsalmRepository {
  final DatabaseHelper _db;

  PsalmRepository({DatabaseHelper? db}) : _db = db ?? DatabaseHelper.instance;

  Future<List<Psalm>> getAllPsalms() => _db.getAllPsalms();

  Future<Psalm?> getPsalmByNumber(int number) => _db.getPsalm(number);

  Future<void> toggleBookmark(int number, bool isBookmarked) =>
      _db.togglePsalmBookmark(number, isBookmarked);

  Future<void> markAsRead(int number) => _db.updatePsalmLastRead(number);

  Future<List<PsalmNote>> getNotesForPsalm(int psalmNumber) =>
      _db.getNotesForPsalm(psalmNumber);

  Future<List<PsalmNote>> getAllNotes() => _db.getAllNotes();

  Future<void> saveNote(PsalmNote note) => _db.saveNote(note);

  Future<void> deleteNote(int id) => _db.deleteNote(id);
}

import '../models/memorization_progress.dart';
import '../models/review_record.dart';
import '../models/daily_plan.dart';
import '../../core/database/database_helper.dart';

class MemorizationRepository {
  final DatabaseHelper _db;

  MemorizationRepository({DatabaseHelper? db}) : _db = db ?? DatabaseHelper.instance;

  Future<List<MemorizationProgress>> getAllProgress() => _db.getAllProgress();

  Future<MemorizationProgress?> getProgressForVerse(int verseId) =>
      _db.getProgressForVerse(verseId);

  Future<void> saveProgress(MemorizationProgress progress) =>
      _db.saveProgress(progress);

  Future<List<MemorizationProgress>> getDueVerses() => _db.getDueVerses();

  Future<void> logReview(ReviewRecord record) => _db.addReviewRecord(record);

  Future<List<ReviewRecord>> getRecentReviews({int limit = 30}) =>
      _db.getRecentReviews(limit: limit);

  Future<DailyPlan?> getDailyPlan(DateTime date) => _db.getDailyPlanForDate(date);

  Future<void> saveDailyPlan(DailyPlan plan) => _db.saveDailyPlan(plan);

  Future<List<DailyPlan>> getAllDailyPlans() => _db.getAllDailyPlans();

  Future<void> resetAll() => _db.resetAllMemorizationProgress();
}

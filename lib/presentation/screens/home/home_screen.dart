import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/ethiopic_numerals.dart';
import '../../core/decorations/harag_painter.dart';
import '../providers/psalm_provider.dart';
import '../providers/memorization_provider.dart';
import '../widgets/ethiopian_cross_icon.dart';
import '../psalms/psalm_detail_screen.dart';
import '../memorize/memorize_session_screen.dart';

class HomeScreen extends StatelessWidget {
  final Function(int tabIndex)? onNavigateTab;

  const HomeScreen({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final psalmProv = context.watch<PsalmProvider>();
    final memProv = context.watch<MemorizationProvider>();

    final targetPsalm = psalmProv.allPsalms.isNotEmpty ? psalmProv.allPsalms.first : null;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.creamBackground,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await psalmProv.loadPsalms();
            await memProv.loadProgress();
          },
          color: AppColors.goldMuted,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header with Ethiopian Orthodox Banner & Peaceful Greeting
                _buildHeader(context, isDark),
                const SizedBox(height: 10),

                // Traditional Harag manuscript ornament divider
                const HaragDivider(height: 18, showCentralCross: true),
                const SizedBox(height: 16),

                // Today's Goal: Full Psalm Song at once (መዝሙሩ ሙሉው በአንድነት)
                if (targetPsalm != null) ...[
                  _buildTodayTargetCard(context, targetPsalm, memProv, isDark),
                  const SizedBox(height: 16),
                ],

                // Daily Spaced Repetition Review Queue
                _buildDailyReviewSection(context, memProv, psalmProv, isDark),
                const SizedBox(height: 22),

                // Recently Studied Psalms Carousel
                _buildRecentlyStudiedSection(context, psalmProv, isDark),
                const SizedBox(height: 22),

                // Overall Memorization Progress Card
                _buildOverallProgressCard(context, memProv, isDark),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.cardWarm,
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? AppColors.darkCardBorder : AppColors.cardBorder,
              width: 1,
            ),
          ),
          child: const Center(
            child: EthiopianCrossIcon(size: 22),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.appNameAmharic,
                style: TextStyle(
                  fontFamily: 'Noto Serif Ethiopic',
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.goldMuted : AppColors.navyPrimary,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                AppStrings.peacefulGreeting,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Today's Target Card for Whole Psalm Song ---
  Widget _buildTodayTargetCard(
    BuildContext context,
    dynamic targetPsalm,
    MemorizationProvider memProv,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.navyPrimary,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.goldMuted.withOpacity(0.4),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.goldMuted.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'የዛሬ የሽምደዳ መዝሙር (Full Psalm Song)',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.goldLight,
                  ),
                ),
              ),
              Text(
                '${targetPsalm.versesCount} ጥቅሶች',
                style: const TextStyle(fontSize: 12, color: AppColors.goldLight),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            targetPsalm.titleGeez.isNotEmpty ? targetPsalm.titleGeez : targetPsalm.titleAmharic,
            style: const TextStyle(
              fontFamily: 'Noto Serif Ethiopic',
              fontSize: 17.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '«ብፁዕ ብእሲ ዘኢሖረ በምክረ ረሲዓን፤ ወዘኢቆመ ውስተ ፍኖተ ኃጥአን...»',
            style: TextStyle(
              fontFamily: 'Noto Serif Ethiopic',
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                memProv.startPsalmSongSession(
                  psalm: targetPsalm,
                  initialMode: MemorizeMode.read,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MemorizeSessionScreen()),
                );
              },
              icon: const Icon(Icons.play_circle_fill_rounded, color: AppColors.navyDeep, size: 18),
              label: const Text(
                'ሙሉውን መዝሙር በግዕዝ ጀምር (Start Full Psalm)',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navyDeep,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldMuted,
                foregroundColor: AppColors.navyDeep,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyReviewSection(
    BuildContext context,
    MemorizationProvider memProv,
    PsalmProvider psalmProv,
    bool isDark,
  ) {
    final dueCount = memProv.dueVerses.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: dueCount > 0 ? AppColors.manuscriptCrimson.withOpacity(0.3) : AppColors.cardBorder,
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.replay_rounded,
                    size: 18,
                    color: dueCount > 0 ? AppColors.manuscriptCrimson : AppColors.goldMuted,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.dailyReview,
                    style: TextStyle(
                      fontFamily: 'Noto Serif Ethiopic',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.navyPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: dueCount > 0 ? AppColors.manuscriptCrimsonLight : (isDark ? Colors.white10 : AppColors.cardWarm),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  dueCount > 0 ? '$dueCount ጥቅሶች ለክለሳ ደርሰዋል' : 'ሁሉም ክለሳዎች ተጠናቀዋል ✓',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: dueCount > 0 ? AppColors.manuscriptCrimson : AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            dueCount > 0
                ? 'በተወሰነ የጊዜ ልዩነት (1d, 3d, 7d, 14d, 30d) የተሸመደዱትን የግዕዝ መዝሙራት ለማጽናት ዛሬ ይከልሱ።'
                : 'ለዛሬ የሚጠበቁ የክለሳ መዝሙራት የሉም። አዳዲስ መዝሙራትን መሸምደድ ይችላሉ።',
            style: TextStyle(
              fontSize: 12.5,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              height: 1.4,
            ),
          ),
          if (dueCount > 0) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                final firstDue = memProv.dueVerses.first;
                final psalm = psalmProv.allPsalms.firstWhere(
                  (p) => p.number == firstDue.psalmNumber,
                  orElse: () => psalmProv.allPsalms.first,
                );
                memProv.startPsalmSongSession(
                  psalm: psalm,
                  initialMode: MemorizeMode.recall,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MemorizeSessionScreen()),
                );
              },
              icon: const Icon(Icons.flash_on_rounded, size: 16),
              label: Text('የዛሬውን $dueCount ክለሳ ጀምር (Start Ge\'ez Review)'),
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? AppColors.goldMuted : AppColors.navyPrimary,
                side: BorderSide(
                  color: isDark ? AppColors.goldMuted : AppColors.navyPrimary,
                  width: 0.9,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 14),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecentlyStudiedSection(
    BuildContext context,
    PsalmProvider psalmProv,
    bool isDark,
  ) {
    final recent = psalmProv.allPsalms
        .where((p) => p.lastReadDate != null || p.memorizedVersesCount > 0)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.recentlyStudied,
              style: TextStyle(
                fontFamily: 'Noto Serif Ethiopic',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimaryDark : AppColors.navyPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                if (onNavigateTab != null) onNavigateTab!(1);
              },
              child: const Text('ሁሉንም (፻፶፩) ›', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (recent.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.cardWarm,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppColors.darkCardBorder : AppColors.cardBorder,
                width: 0.8,
              ),
            ),
            child: Column(
              children: [
                const Text('📖', style: TextStyle(fontSize: 22)),
                const SizedBox(height: 6),
                Text(
                  'እስካሁን የተጠና መዝሙር የለም',
                  style: TextStyle(
                    fontFamily: 'Noto Serif Ethiopic',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.navyPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ከመዝሙር ፩ ጀምረው የመጀመሪያውን መዝሙር በቃልዎ ይያዙ!',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 120,
            child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: recent.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final p = recent[index];
              return Container(
                width: 184,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? AppColors.darkCardBorder : AppColors.cardBorder,
                    width: 0.8,
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    context.read<PsalmProvider>().openPsalm(p.number);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PsalmDetailScreen(psalmNumber: p.number),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'መዝሙር ${p.ethiopicNumber}',
                            style: const TextStyle(
                              fontFamily: 'Noto Serif Ethiopic',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.manuscriptCrimson,
                            ),
                          ),
                          Icon(
                            p.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                            size: 16,
                            color: AppColors.goldDark,
                          ),
                        ],
                      ),
                      Text(
                        p.titleGeez.isNotEmpty ? p.titleGeez : p.titleAmharic,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontFamily: 'Noto Serif Ethiopic', fontSize: 13, height: 1.3),
                      ),
                      Text(
                        '${p.versesCount} ጥቅሶች • በግዕዝ ያንብቡ →',
                        style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondaryLight),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOverallProgressCard(
    BuildContext context,
    MemorizationProvider memProv,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.cardWarm,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.cardBorder,
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.overallProgress,
                style: TextStyle(
                  fontFamily: 'Noto Serif Ethiopic',
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.navyPrimary,
                ),
              ),
              const Icon(Icons.insights_rounded, size: 18, color: AppColors.goldDark),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat('የተማሩ', '${memProv.totalVersesLearned}', isDark),
              _buildStat('የተሸመደዱ', '${memProv.masteredVerses.length}', isDark, color: AppColors.successGreen),
              _buildStat('የዛሬ ክለሳ', '${memProv.dueVerses.length}', isDark, color: AppColors.manuscriptCrimson),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String val, bool isDark, {Color? color}) {
    return Column(
      children: [
        Text(
          val,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: color ?? (isDark ? AppColors.goldMuted : AppColors.navyPrimary),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}

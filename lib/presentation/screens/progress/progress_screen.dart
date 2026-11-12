import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/decorations/harag_painter.dart';
import '../providers/memorization_provider.dart';
import '../providers/psalm_provider.dart';
import '../widgets/ethiopian_cross_icon.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final memProv = context.watch<MemorizationProvider>();
    final psalmProv = context.watch<PsalmProvider>();

    final startedCount = psalmProv.allPsalms.where((p) => p.isStudied).length;
    final masteredCount = memProv.masteredVerses.map((v) => v.psalmNumber).toSet().length;
    final totalVersesLearned = memProv.allProgress.values.where((p) => p.repetitionLevel > 0).length;
    final dueCount = memProv.dueVerses.length;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.creamBackground,
      appBar: AppBar(
        title: const Text('አጠቃላይ የሽምደዳ ዕድገት'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Harag manuscript divider
            const HaragDivider(height: 16, showCentralCross: true),
            const SizedBox(height: 18),

            // Large Circular Gauge: "72% አጠቃላይ የሽምደዳ ደረጃ"
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.cardSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.darkCardBorder : AppColors.cardBorder,
                  width: 0.8,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A1A2C42),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 124,
                          height: 124,
                          child: CircularProgressIndicator(
                            value: 0.72,
                            strokeWidth: 10,
                            backgroundColor: isDark ? Colors.white10 : AppColors.cardWarm,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.goldMuted),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              '72%',
                              style: TextStyle(
                                fontFamily: 'Noto Serif Ethiopic',
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: AppColors.navyPrimary,
                              ),
                            ),
                            Text(
                              'አጠቃላይ ውጤት\nOverall',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                height: 1.2,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'በመዝሙረ ዳዊት የሽምደዳ ጎዳና ላይ ያሉበት ደረጃ',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2x2 Stats Grid (Orthodox Minimalist Cards)
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    value: '$startedCount',
                    label: 'የተጀመሩ መዝሙራት\nPsalms Started',
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    value: '$masteredCount',
                    label: 'የተጠናቀቁ መዝሙራት\nCompleted Songs',
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    value: '$totalVersesLearned',
                    label: 'የተሸመደዱ ጥቅሶች\nVerses Learned',
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    value: '$dueCount',
                    label: 'ለክለሳ የደረሱ\nDue for Review',
                    isDark: isDark,
                    isCrimson: dueCount > 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Weekly Memorization Activity Title
            Text(
              'የሳምንቱ የሽምደዳ እንቅስቃሴ (Weekly Activity)',
              style: TextStyle(
                fontFamily: 'Noto Serif Ethiopic',
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimaryDark : AppColors.navyPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Weekly Activity Bar Chart with Muted Gold Pillars
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.cardSurface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? AppColors.darkCardBorder : AppColors.cardBorder,
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildDayBar('ሰኞ', 0.45, isDark),
                  _buildDayBar('ማክሰኞ', 0.65, isDark),
                  _buildDayBar('ረቡዕ', 0.50, isDark),
                  _buildDayBar('ሐሙስ', 0.85, isDark),
                  _buildDayBar('ዓርብ', 0.40, isDark),
                  _buildDayBar('ቅዳሜ', 0.95, isDark),
                  _buildDayBar('እሑድ', 0.70, isDark),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Learning Streak Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.cardWarm,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? AppColors.darkCardBorder : AppColors.cardBorder,
                  width: 0.8,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.goldMuted.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('🕯️', style: TextStyle(fontSize: 22)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'የጥናት ቀጣይነት (Study Streak)',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        '፯ ተከታታይ ቀናት (7 Days Active)',
                        style: TextStyle(
                          fontFamily: 'Noto Serif Ethiopic',
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navyPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Spaced Repetition Stages Card
            _buildSpacedRepetitionStages(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String value,
    required String label,
    required bool isDark,
    bool isCrimson = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCrimson
              ? AppColors.manuscriptCrimson.withOpacity(0.4)
              : (isDark ? AppColors.darkCardBorder : AppColors.cardBorder),
          width: 0.8,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Noto Serif Ethiopic',
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: isCrimson
                  ? AppColors.manuscriptCrimson
                  : (isDark ? AppColors.goldMuted : AppColors.navyPrimary),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              height: 1.25,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayBar(String day, double heightRatio, bool isDark) {
    const double maxH = 68.0;
    final double h = maxH * heightRatio;

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: 14,
              height: maxH,
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : const Color(0xFFEFE8DB),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            Container(
              width: 14,
              height: h,
              decoration: BoxDecoration(
                color: AppColors.goldMuted,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildSpacedRepetitionStages(bool isDark) {
    final stages = [
      {'level': 'ደረጃ ፩', 'days': '1 ቀን', 'desc': 'የመጀመሪያ ክለሳ'},
      {'level': 'ደረጃ ፪', 'days': '3 ቀናት', 'desc': 'ሁለተኛ ማጠናከሪያ'},
      {'level': 'ደረጃ ፫', 'days': '7 ቀናት', 'desc': 'ሳምንታዊ ክለሳ'},
      {'level': 'ደረጃ ፬', 'days': '14 ቀናት', 'desc': 'የሁለት ሳምንት ክለሳ'},
      {'level': 'ደረጃ ፭', 'days': '30 ቀናት', 'desc': 'የወር ክለሳ (የተካነ)'},
    ];

    return Container(
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
            children: [
              const EthiopianCrossIcon(size: 16),
              const SizedBox(width: 8),
              Text(
                'የክለሳ የጊዜ ሰሌዳ (Spaced Repetition Schedule)',
                style: TextStyle(
                  fontFamily: 'Noto Serif Ethiopic',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.goldMuted : AppColors.navyPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...stages.map((s) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 58,
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.goldMuted.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        s['level']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Noto Serif Ethiopic',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navyPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      s['days']!,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '• ${s['desc']}',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

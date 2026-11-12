import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/ethiopic_numerals.dart';
import '../../core/decorations/harag_painter.dart';
import '../../data/models/psalm.dart';
import '../providers/psalm_provider.dart';
import '../providers/memorization_provider.dart';
import 'memorize_session_screen.dart';

class MemorizeSelectScreen extends StatefulWidget {
  const MemorizeSelectScreen({super.key});

  @override
  State<MemorizeSelectScreen> createState() => _MemorizeSelectScreenState();
}

class _MemorizeSelectScreenState extends State<MemorizeSelectScreen> {
  int _selectedPsalmNumber = 1;
  MemorizeMode _selectedInitialMode = MemorizeMode.read;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final psalmProv = context.watch<PsalmProvider>();
    final memProv = context.watch<MemorizationProvider>();

    final psalms = psalmProv.allPsalms;
    final currentPsalm = psalms.firstWhere(
      (p) => p.number == _selectedPsalmNumber,
      orElse: () => psalms.isNotEmpty
          ? psalms.first
          : const Psalm(number: 1, titleAmharic: 'መዝሙር ፩', versesCount: 6),
    );

    final dueCount = memProv.dueVerses.length;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.creamBackground,
      appBar: AppBar(
        title: const Text('የግዕዝ መሸምደጃ ክፍል'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Due for Review Banner
            if (dueCount > 0) ...[
              _buildDueBanner(context, memProv, psalmProv, dueCount, isDark),
              const SizedBox(height: 16),
            ],

            // Section Header
            Text(
              'በአንድነት የሚሸመደድ ሙሉ መዝሙር (Full Psalm Song)',
              style: TextStyle(
                fontFamily: 'Noto Serif Ethiopic',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimaryDark : AppColors.navyPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const HaragDivider(height: 14, showCentralCross: false),
            const SizedBox(height: 12),

            // Psalm Selector Dropdown Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.cardSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkCardBorder : AppColors.cardBorder,
                  width: 0.8,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x061A2C42),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'መዝሙረ ዳዊት (Select Psalm Song):',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.goldDark,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white10 : AppColors.cardWarm,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${currentPsalm.versesCount} ጥቅሶች (ሙሉ መዝሙር)',
                          style: TextStyle(
                            fontFamily: 'Noto Serif Ethiopic',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.goldMuted : AppColors.navyPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: _selectedPsalmNumber,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark ? Colors.white10 : AppColors.cardWarm,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.darkCardBorder : AppColors.cardBorder,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: psalms.take(30).map((p) {
                      final title = p.titleGeez.isNotEmpty ? p.titleGeez : p.titleAmharic;
                      return DropdownMenuItem<int>(
                        value: p.number,
                        child: Text(
                          '$title (${p.versesCount} ጥቅሶች)',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Noto Serif Ethiopic',
                            fontSize: 13.5,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedPsalmNumber = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  // Preview Snippet of Psalm in Ge'ez
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.04) : AppColors.creamBackground,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? AppColors.darkCardBorder : AppColors.cardBorder,
                        width: 0.6,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'የመዝሙሩ መጀመሪያ በግዕዝ (Opening Strophe):',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.goldMuted : AppColors.navyPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentPsalm.verses.isNotEmpty && currentPsalm.verses.first.textGeez.isNotEmpty
                              ? '«${currentPsalm.verses.first.textGeez}»'
                              : '«${currentPsalm.titleGeez}»',
                          style: TextStyle(
                            fontFamily: 'Noto Serif Ethiopic',
                            fontSize: 13.5,
                            fontStyle: FontStyle.italic,
                            height: 1.45,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.navyPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ሙሉው መዝሙር (${currentPsalm.versesCount} ስንኞች) በአንድ ላይ ይሸመደዳል',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Memorization Challenges Header
            Text(
              'የመሸምደጃ ደረጃ እና የልምምድ ፈተናዎች',
              style: TextStyle(
                fontFamily: 'Noto Serif Ethiopic',
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimaryDark : AppColors.navyPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'የሚፈልጉትን የልምምድ ፈተና ይምረጡ፤ በክፍለ ጊዜው ውስጥ በነፃነት መቀያየር ይችላሉ።',
              style: TextStyle(
                fontSize: 11.5,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 10),

            _buildChallengeTile(
              title: '፩. ንባብ (Read Full Psalm Song)',
              desc: 'ሙሉውን መዝሙረ ዳዊት በተመስጦና በዜማ ደጋግመው ያንብቡ',
              mode: MemorizeMode.read,
              isDark: isDark,
            ),
            const SizedBox(height: 8),
            _buildChallengeTile(
              title: '፪. የተሰወሩ ቃላት (Hidden Words Across Song)',
              desc: 'በመዝሙሩ ውስጥ የተሸሸጉትን የግዕዝ ቃላት በልብዎ ይሙሉ። ለመክፈት ይንኩ',
              mode: MemorizeMode.hiddenWords,
              isDark: isDark,
            ),
            const SizedBox(height: 8),
            _buildChallengeTile(
              title: '፫. የፊደል ፍንጭ (First-Letter Fidel Mnemonic)',
              desc: 'የእያንዳንዱን ቃል መጀመሪያ ፊደል በማየት ሙሉውን መዝሙር ያስታውሱ',
              mode: MemorizeMode.fidelCue,
              isDark: isDark,
            ),
            const SizedBox(height: 8),
            _buildChallengeTile(
              title: '፬. ማስታወስ (Prompt Recall - Strophe Cue)',
              desc: 'የመጀመሪያውን ስንኝ አይተው ሙሉውን መዝሙር በቃልዎ ይድገሙ',
              mode: MemorizeMode.recall,
              isDark: isDark,
            ),
            const SizedBox(height: 8),
            _buildChallengeTile(
              title: '፭. የመዝሙር ቁጥር ማስታወስ (Recall Psalm Number)',
              desc: 'ከተጠኑት መዝሙራት የተመረጠውን ቃል አይተው ቁጥሩን በልብዎ ያስታውሱ',
              mode: MemorizeMode.psalmNumberRecall,
              isDark: isDark,
            ),
            const SizedBox(height: 8),
            _buildChallengeTile(
              title: '፮. ማዜም / በቃል መደገም (Recitation & Spaced Review)',
              desc: 'ያለ እገዛ ሙሉውን መዝሙር ያዜሙ፤ በድምፅ ይቅረጹ እና ራስዎን ይገምግሙ',
              mode: MemorizeMode.recitation,
              isDark: isDark,
            ),
            const SizedBox(height: 22),

            // Start Button for Full Psalm Song
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  memProv.startPsalmSongSession(
                    psalm: currentPsalm,
                    initialMode: _selectedInitialMode,
                    allPsalms: psalmProv.allPsalms,
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MemorizeSessionScreen()),
                  );
                },
                icon: const Icon(Icons.play_circle_fill_rounded, color: AppColors.navyDeep, size: 20),
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
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDueBanner(
    BuildContext context,
    MemorizationProvider memProv,
    PsalmProvider psalmProv,
    int dueCount,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.manuscriptCrimsonLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.manuscriptCrimson.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.alarm_on_rounded, color: AppColors.manuscriptCrimson, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'የዛሬ የክለሳ ጥሪ: $dueCount የግዕዝ ጥቅሶች ለክለሳ ደርሰዋል',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.manuscriptCrimson,
              ),
            ),
          ),
          ElevatedButton(
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.manuscriptCrimson,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
            ),
            child: const Text('አሁን ከልስ', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeTile({
    required String title,
    required String desc,
    required MemorizeMode mode,
    required bool isDark,
  }) {
    final isSelected = _selectedInitialMode == mode;

    return InkWell(
      onTap: () => setState(() => _selectedInitialMode = mode),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.goldMuted.withOpacity(0.18) : AppColors.cardWarm)
              : (isDark ? AppColors.darkCard : AppColors.cardSurface),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.goldMuted
                : (isDark ? AppColors.darkCardBorder : AppColors.cardBorder),
            width: isSelected ? 1.4 : 0.8,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
              color: isSelected ? AppColors.goldMuted : AppColors.textMutedLight,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Noto Serif Ethiopic',
                      fontSize: 13.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected
                          ? (isDark ? AppColors.goldMuted : AppColors.navyPrimary)
                          : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

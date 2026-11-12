import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/ethiopic_numerals.dart';
import '../../core/decorations/harag_painter.dart';
import '../../core/audio/recitation_audio_service.dart';
import '../../data/models/verse.dart';
import '../providers/memorization_provider.dart';
import '../providers/psalm_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/audio_player_bar.dart';

class MemorizeSessionScreen extends StatefulWidget {
  const MemorizeSessionScreen({super.key});

  @override
  State<MemorizeSessionScreen> createState() => _MemorizeSessionScreenState();
}

class _MemorizeSessionScreenState extends State<MemorizeSessionScreen> {
  final RecitationAudioService _audioService = RecitationAudioService();

  @override
  void dispose() {
    _audioService.stopRecitation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final memProv = context.watch<MemorizationProvider>();
    final psalmProv = context.watch<PsalmProvider>();
    final settings = context.watch<SettingsProvider>();

    final psalm = memProv.sessionPsalm;
    if (psalm == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('የመሸምደጃ ሰሌዳ')),
        body: Center(
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ተመለስ'),
          ),
        ),
      );
    }

    final psalmTitle = psalm.titleGeez.isNotEmpty ? psalm.titleGeez : psalm.titleAmharic;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.creamBackground,
      appBar: AppBar(
        title: Text(
          psalmTitle,
          style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : AppColors.cardWarm,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? AppColors.darkCardBorder : AppColors.cardBorder,
                  ),
                ),
                child: Text(
                  '${psalm.versesCount} ጥቅሶች (ሙሉ)',
                  style: TextStyle(
                    fontFamily: 'Noto Serif Ethiopic',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.goldMuted : AppColors.navyPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Challenge & Mode Selector Tabs (Horizontal Modern Orthodox Tabs)
          _buildChallengeTabs(memProv, psalmProv, isDark),

          // Scrollable Full Psalm Song Practice Area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Challenge Mode Header Notice
                  _buildModeHeader(memProv.currentMode, isDark),
                  const SizedBox(height: 14),

                  // Main Practice Surface (Full Psalm Song at once)
                  _buildFullPsalmPracticeCard(psalm, memProv, psalmProv, settings, isDark),
                  const SizedBox(height: 14),

                  // Cross-Reference Toggles (Amharic & English)
                  _buildCrossReferenceToggles(memProv, isDark),
                  const SizedBox(height: 14),

                  // Audio Recitation Bar
                  AudioPlayerBar(
                    verseId: psalm.number * 1000,
                    title: 'የመዝሙሩ ንባብ ድምፅ (Audio Recitation)',
                  ),
                  const SizedBox(height: 18),

                  // Mode 6 Evaluation Panel (Recitation & Spaced Review for Full Psalm Song)
                  if (memProv.currentMode == MemorizeMode.recitation) ...[
                    _buildEvaluationPanel(context, psalm, memProv, isDark),
                    const SizedBox(height: 18),
                  ],
                ],
              ),
            ),
          ),

          // Bottom Finish / Close Panel
          _buildBottomActionPanel(context, psalm, memProv, isDark),
        ],
      ),
    );
  }

  // --- Horizontal Mode Selector Tabs ---
  Widget _buildChallengeTabs(
    MemorizationProvider memProv,
    PsalmProvider psalmProv,
    bool isDark,
  ) {
    final modes = [
      {'mode': MemorizeMode.read, 'title': '፩. ንባብ (Read Song)'},
      {'mode': MemorizeMode.hiddenWords, 'title': '፪. ተሰወሩ (Hidden)'},
      {'mode': MemorizeMode.fidelCue, 'title': '፫. የፊደል ፍንጭ (Fidel Cue)'},
      {'mode': MemorizeMode.recall, 'title': '፬. ማስታወስ (Recall)'},
      {'mode': MemorizeMode.psalmNumberRecall, 'title': '፭. ቁጥር ማስታወስ (Identify #)'},
      {'mode': MemorizeMode.recitation, 'title': '፮. ማዜም (Recite)'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.cardSurface,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkCardBorder : AppColors.cardBorder,
            width: 0.8,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: modes.map((m) {
            final mode = m['mode'] as MemorizeMode;
            final isSelected = memProv.currentMode == mode;

            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: InkWell(
                onTap: () => memProv.setMode(mode, allPsalms: psalmProv.allPsalms),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? AppColors.goldMuted : AppColors.navyPrimary)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : (isDark ? AppColors.darkCardBorder : AppColors.cardBorder),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    m['title'] as String,
                    style: TextStyle(
                      fontFamily: 'Noto Serif Ethiopic',
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? (isDark ? AppColors.navyDeep : Colors.white)
                          : (isDark ? AppColors.textPrimaryDark : AppColors.navyPrimary),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildModeHeader(MemorizeMode mode, bool isDark) {
    String title;
    String desc;
    IconData icon;

    switch (mode) {
      case MemorizeMode.read:
        title = 'ደረጃ ፩: ሙሉውን መዝሙር በግዕዝ ማንበብ (Read Full Song)';
        desc = 'ሙሉውን መዝሙረ ዳዊት በተመስጦና በዜማ ደጋግመው ያንብቡ።';
        icon = Icons.menu_book_rounded;
        break;
      case MemorizeMode.hiddenWords:
        title = 'ደረጃ ፪: የተሰወሩ ቃላት (Hidden Words Across Song)';
        desc = 'በመዝሙሩ ውስጥ የተሸሸጉትን የግዕዝ ቃላት በልብዎ ይሙሉ። ለመክፈት ይንኩ።';
        icon = Icons.visibility_off_rounded;
        break;
      case MemorizeMode.fidelCue:
        title = 'ደረጃ ፫: የፊደል ፍንጭ (First-Letter Mnemonic Challenge)';
        desc = 'የእያንዳንዱን ቃል መጀመሪያ ፊደል ብቻ በማየት ሙሉውን መዝሙር በቃልዎ ያስታውሱ።';
        icon = Icons.lightbulb_outline_rounded;
        break;
      case MemorizeMode.recall:
        title = 'ደረጃ ፬: ማስታወስ (Recall Complete Song)';
        desc = 'የመጀመሪያውን ስንኝ አይተው ሙሉውን መዝሙር በቃልዎ ይድገሙ። መልስን ለማየት ይንኩ።';
        icon = Icons.psychology_rounded;
        break;
      case MemorizeMode.psalmNumberRecall:
        title = 'ደረጃ ፭: የመዝሙር ቁጥር ማስታወስ (Recall Psalm Number)';
        desc = 'ከተጠኑት መዝሙራት የተመረጠውን ቃል አይተው የመዝሙሩን ቁጥር በቃልዎ ያስታውሱ።';
        icon = Icons.quiz_rounded;
        break;
      case MemorizeMode.recitation:
        title = 'ደረጃ ፮: ማዜም / በቃል መደገም (Recite Complete Psalm)';
        desc = 'ያለ እገዛ ሙሉውን መዝሙር በቃልዎ ያዜሙ እና ራስዎን ይገምግሙ።';
        icon = Icons.record_voice_over_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.cardWarm,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.cardBorder,
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.goldDark),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.goldMuted : AppColors.navyPrimary,
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
    );
  }

  // --- Main Full Psalm Song Practice Card ---
  Widget _buildFullPsalmPracticeCard(
    dynamic psalm,
    MemorizationProvider memProv,
    PsalmProvider psalmProv,
    SettingsProvider settings,
    bool isDark,
  ) {
    switch (memProv.currentMode) {
      case MemorizeMode.read:
        return _buildFullSongRead(psalm, memProv, settings, isDark);
      case MemorizeMode.hiddenWords:
        return _buildFullSongHiddenWords(psalm, memProv, settings, isDark);
      case MemorizeMode.fidelCue:
        return _buildFullSongFidelCue(psalm, memProv, settings, isDark);
      case MemorizeMode.recall:
        return _buildFullSongRecall(psalm, memProv, settings, isDark);
      case MemorizeMode.psalmNumberRecall:
        return _buildPsalmNumberRecallCard(psalm, memProv, psalmProv, settings, isDark);
      case MemorizeMode.recitation:
        return _buildFullSongRecitation(psalm, memProv, settings, isDark);
    }
  }

  // 1. Full Song Read
  Widget _buildFullSongRead(
    dynamic psalm,
    MemorizationProvider memProv,
    SettingsProvider settings,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? AppColors.darkCardBorder : AppColors.cardBorder, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ሙሉው መዝሙረ ዳዊት ዘግዕዝ (Full Ge\'ez Song)',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.goldDark),
              ),
              Text(
                'ተደግሟል: ${memProv.psalmSongReadCount} ጊዜ',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // All verses flowing together
          ...psalm.verses.map((Verse v) {
            final geez = v.textGeez.isNotEmpty ? v.textGeez : v.textAmharic;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${EthiopicNumerals.toEthiopic(v.verseNumber)}. ',
                          style: const TextStyle(
                            fontFamily: 'Noto Serif Ethiopic',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.manuscriptCrimson,
                          ),
                        ),
                        TextSpan(
                          text: geez,
                          style: TextStyle(
                            fontFamily: 'Noto Serif Ethiopic',
                            fontSize: 17 * settings.fontScale,
                            height: 1.8,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (memProv.showAmharicReference && v.textAmharic.isNotEmpty && v.textGeez.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      v.textAmharic,
                      style: TextStyle(
                        fontFamily: 'Noto Sans Ethiopic',
                        fontSize: 13 * settings.fontScale,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                  if (memProv.showEnglishReference && v.textEnglish.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      v.textEnglish,
                      style: TextStyle(
                        fontSize: 12.5 * settings.fontScale,
                        fontStyle: FontStyle.italic,
                        color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => memProv.incrementSongReadCount(),
              icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
              label: Text('ሙሉውን መዝሙር አንብቤ ጨረስኩ (${memProv.psalmSongReadCount + 1}ኛ ድግግሞሽ)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navyPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 2. Hidden Words Across Whole Song
  Widget _buildFullSongHiddenWords(
    dynamic psalm,
    MemorizationProvider memProv,
    SettingsProvider settings,
    bool isDark,
  ) {
    int tokenIndex = 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? AppColors.darkCardBorder : AppColors.cardBorder, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'የተሰወሩ ቃላት (Tap to Reveal)',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.goldDark),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () => memProv.revealAllHiddenWords(),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                    child: const Text('ሁሉንም አሳይ', style: TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => memProv.hideAllHiddenWords(),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                    child: const Text('ደብቅ', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          ...psalm.verses.map((Verse v) {
            final words = (v.textGeez.isNotEmpty ? v.textGeez : v.textAmharic).split(RegExp(r'\s+'));

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Wrap(
                spacing: 4,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '${EthiopicNumerals.toEthiopic(v.verseNumber)}. ',
                    style: const TextStyle(
                      fontFamily: 'Noto Serif Ethiopic',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.manuscriptCrimson,
                    ),
                  ),
                  ...words.map((word) {
                    final currentKey = tokenIndex++;
                    final isMasked = (currentKey % 2 == 1);
                    final isRevealed = memProv.revealedWordKeys.contains(currentKey);

                    if (isMasked && !isRevealed) {
                      return InkWell(
                        onTap: () => memProv.toggleWordRevealed(currentKey),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : AppColors.cardWarm,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.goldMuted, width: 0.8),
                          ),
                          child: Text(
                            '•••••',
                            style: TextStyle(
                              fontSize: 15 * settings.fontScale,
                              letterSpacing: 2,
                              color: AppColors.goldDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }

                    return InkWell(
                      onTap: isMasked ? () => memProv.toggleWordRevealed(currentKey) : null,
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                        decoration: BoxDecoration(
                          color: (isMasked && isRevealed)
                              ? (isDark ? Colors.white10 : AppColors.goldLight)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          word,
                          style: TextStyle(
                            fontFamily: 'Noto Serif Ethiopic',
                            fontSize: 16.5 * settings.fontScale,
                            height: 1.7,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            fontWeight: (isMasked && isRevealed) ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // 3. Fidel Cue Challenge for Full Song
  Widget _buildFullSongFidelCue(
    dynamic psalm,
    MemorizationProvider memProv,
    SettingsProvider settings,
    bool isDark,
  ) {
    int cueIdx = 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? AppColors.darkCardBorder : AppColors.cardBorder, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'የፊደል ፍንጭ (First-Letter Mnemonic for Whole Psalm)',
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.goldDark),
          ),
          const SizedBox(height: 4),
          const Text(
            'የእያንዳንዱን ቃል የመጀመሪያ ፊደል በማየት ሙሉውን መዝሙረ ዳዊት በልብዎ ያስታውሱ። (ለመክፈት ይንኩ)',
            style: TextStyle(fontSize: 11.5, color: AppColors.textSecondaryLight),
          ),
          const SizedBox(height: 16),

          ...psalm.verses.map((Verse v) {
            final words = (v.textGeez.isNotEmpty ? v.textGeez : v.textAmharic).split(RegExp(r'\s+'));

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Wrap(
                spacing: 6,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '${EthiopicNumerals.toEthiopic(v.verseNumber)}.',
                    style: const TextStyle(
                      fontFamily: 'Noto Serif Ethiopic',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.manuscriptCrimson,
                    ),
                  ),
                  ...words.map((w) {
                    final key = cueIdx++;
                    final firstFidel = w.isNotEmpty ? w[0] : '';
                    final isExpanded = memProv.revealedFidelKeys.contains(key);

                    return InkWell(
                      onTap: () => memProv.toggleFidelRevealed(key),
                      borderRadius: BorderRadius.circular(7),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isExpanded
                              ? (isDark ? Colors.white10 : AppColors.goldLight)
                              : (isDark ? AppColors.navySurface : AppColors.cardWarm),
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(
                            color: isExpanded ? AppColors.goldMuted : AppColors.cardBorder,
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          isExpanded ? w : '$firstFidel...',
                          style: TextStyle(
                            fontFamily: 'Noto Serif Ethiopic',
                            fontSize: 15 * settings.fontScale,
                            fontWeight: FontWeight.w600,
                            color: isExpanded
                                ? (isDark ? AppColors.goldLight : AppColors.navyPrimary)
                                : (isDark ? AppColors.goldMuted : AppColors.manuscriptCrimson),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // 4. Recall Complete Song
  Widget _buildFullSongRecall(
    dynamic psalm,
    MemorizationProvider memProv,
    SettingsProvider settings,
    bool isDark,
  ) {
    final firstVerse = psalm.verses.isNotEmpty ? psalm.verses.first : null;
    final firstGeez = firstVerse?.textGeez ?? '';
    final cue = firstGeez.split(RegExp(r'\s+')).take(3).join(' ') + ' ...';

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? AppColors.darkCardBorder : AppColors.cardBorder, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_rounded, size: 18, color: AppColors.goldDark),
              const SizedBox(width: 8),
              const Text(
                'የመዝሙሩ መጀመሪያ ፍንጭ (Opening Strophe):',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.goldDark),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Opening Strophe Cue
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.navySurface : AppColors.cardWarm,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.goldBorder, width: 0.8),
            ),
            child: Text(
              cue,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Noto Serif Ethiopic',
                fontSize: 19 * settings.fontScale,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.goldLight : AppColors.navyDeep,
              ),
            ),
          ),
          const SizedBox(height: 14),

          const Text(
            'ከላይ ያለውን መጀመሪያ ፍንጭ በማየት ሙሉውን መዝሙረ ዳዊት በልብዎ ወይም በቃልዎ ያስታውሱ።',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondaryLight),
          ),
          const SizedBox(height: 16),

          // Answer Reveal Toggle
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => memProv.toggleAnswerReveal(),
              icon: Icon(memProv.isAnswerRevealed ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 18),
              label: Text(
                memProv.isAnswerRevealed ? 'መልስ ደብቅ' : 'ሙሉውን መዝሙር አሳይ (Reveal Full Song)',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? AppColors.goldMuted : AppColors.navyPrimary,
                side: BorderSide(color: isDark ? AppColors.goldMuted : AppColors.navyPrimary, width: 1.2),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),

          if (memProv.isAnswerRevealed) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : AppColors.cardWarm.withOpacity(0.6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.successGreen, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ሙሉው መዝሙረ ዳዊት (Complete Psalm Song):',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.successGreen),
                  ),
                  const SizedBox(height: 10),
                  ...psalm.verses.map((Verse v) {
                    final gz = v.textGeez.isNotEmpty ? v.textGeez : v.textAmharic;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '${EthiopicNumerals.toEthiopic(v.verseNumber)}. $gz',
                        style: TextStyle(
                          fontFamily: 'Noto Serif Ethiopic',
                          fontSize: 15.5 * settings.fontScale,
                          height: 1.7,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 5. Full Song Recitation & Voice Practice
  Widget _buildFullSongRecitation(
    dynamic psalm,
    MemorizationProvider memProv,
    SettingsProvider settings,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? AppColors.darkCardBorder : AppColors.cardBorder, width: 0.8),
      ),
      child: Column(
        children: [
          const Icon(Icons.record_voice_over_rounded, size: 36, color: AppColors.goldDark),
          const SizedBox(height: 10),
          Text(
            '${psalm.titleGeez.isNotEmpty ? psalm.titleGeez : psalm.titleAmharic} በቃልዎ ያዜሙ',
            style: const TextStyle(
              fontFamily: 'Noto Serif Ethiopic',
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'ያለ ምንም ጽሑፍ እገዛ ሙሉውን መዝሙረ ዳዊት በቃልዎ ያዜሙ',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondaryLight),
          ),
          const SizedBox(height: 16),

          // Optional Voice Recording Practice
          AnimatedBuilder(
            animation: _audioService,
            builder: (context, _) {
              final isRec = _audioService.isRecording;
              final hasRec = _audioService.hasRecording;

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : AppColors.cardWarm,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!isRec && !hasRec) ...[
                      ElevatedButton.icon(
                        onPressed: () => _audioService.startRecording(),
                        icon: const Icon(Icons.mic_rounded, size: 18),
                        label: const Text('የመዝሙር ልምምድ ቅረጽ (Record Practice)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.navyPrimary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ] else if (isRec) ...[
                      ElevatedButton.icon(
                        onPressed: () => _audioService.stopRecording(),
                        icon: const Icon(Icons.stop_rounded, size: 18),
                        label: Text('አቁም (${_audioService.recordDuration.inSeconds} ሰከንድ)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.dangerRose,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ] else ...[
                      IconButton(
                        icon: const Icon(Icons.play_arrow_rounded, color: AppColors.successGreen),
                        onPressed: () => _audioService.playRecordedVoice(),
                      ),
                      const Text('የተቀዳ ድምፅ ተጠናቋል', style: TextStyle(fontSize: 12)),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 18),
                        onPressed: () => _audioService.discardRecording(),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          TextButton(
            onPressed: () => memProv.toggleAnswerReveal(),
            child: Text(memProv.isAnswerRevealed ? 'ጽሑፍ ደብቅ' : 'ትክክል መሆኑን ፈትሽ (Check Song Text)'),
          ),

          if (memProv.isAnswerRevealed) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : AppColors.cardWarm,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: psalm.verses.map((Verse v) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      '${v.verseNumber}. ${v.textGeez.isNotEmpty ? v.textGeez : v.textAmharic}',
                      style: TextStyle(
                        fontFamily: 'Noto Serif Ethiopic',
                        fontSize: 15 * settings.fontScale,
                        height: 1.6,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- Mode 5: Psalm Number Recall Challenge (Random Studied Psalm) ---
  Widget _buildPsalmNumberRecallCard(
    dynamic psalm,
    MemorizationProvider memProv,
    PsalmProvider psalmProv,
    SettingsProvider settings,
    bool isDark,
  ) {
    if (memProv.randomChallengePsalm == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        memProv.generateRandomPsalmNumberChallenge(allPsalms: psalmProv.allPsalms);
      });
    }

    final target = memProv.randomChallengePsalm ?? psalm;
    final firstVerse = target.verses.isNotEmpty ? target.verses.first : null;
    final String geezText = (firstVerse?.textGeez.isNotEmpty ?? false)
        ? firstVerse!.textGeez
        : target.titleGeez;
    final options = memProv.psalmNumberOptions.isNotEmpty
        ? memProv.psalmNumberOptions
        : [target.number, 1, 23, 50];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.cardBorder,
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.quiz_rounded, size: 18, color: AppColors.goldDark),
                  const SizedBox(width: 8),
                  const Text(
                    'የመዝሙር ቁጥር ማስታወስ (Identify Psalm)',
                    style: TextStyle(
                      fontFamily: 'Noto Serif Ethiopic',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.goldDark,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : AppColors.cardWarm,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'ውጤት: ${memProv.correctNumberGuesses}/${memProv.totalNumberGuesses}',
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Filter Studied Only Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ከተጠኑት መዝሙራት ብቻ (Studied Only)',
                style: TextStyle(
                  fontSize: 11.5,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              Switch(
                value: memProv.filterStudiedOnly,
                onChanged: (_) {
                  memProv.toggleFilterStudiedOnly(allPsalms: psalmProv.allPsalms);
                },
                activeColor: AppColors.goldMuted,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Random Psalm Verse / Strophe Display in Ge'ez
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.navySurface : AppColors.cardWarm,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.goldBorder, width: 0.8),
            ),
            child: Column(
              children: [
                Text(
                  '«$geezText»',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Noto Serif Ethiopic',
                    fontSize: 16.5 * settings.fontScale,
                    height: 1.7,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.goldLight : AppColors.navyDeep,
                  ),
                ),
                if (target.liturgicalNote != null && memProv.isAnswerRevealedForNumber) ...[
                  const SizedBox(height: 8),
                  Text(
                    target.liturgicalNote!,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.goldLight.withOpacity(0.8) : AppColors.goldDark,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),

          const Text(
            'ይህ የመዝሙረ ዳዊት ቃል የየትኛው መዝሙር ቁጥር ነው?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // 2x2 Candidate Choices
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.6,
            children: options.map((num) {
              final isChosen = memProv.selectedGuessNumber == num;
              final isTarget = target.number == num;
              final revealed = memProv.isAnswerRevealedForNumber;

              Color bgColor;
              Color borderColor;
              Color textColor;

              if (!revealed) {
                bgColor = isDark ? Colors.white10 : AppColors.cardWarm;
                borderColor = isDark ? AppColors.darkCardBorder : AppColors.cardBorder;
                textColor = isDark ? AppColors.textPrimaryDark : AppColors.navyPrimary;
              } else if (isTarget) {
                bgColor = AppColors.successGreen.withOpacity(0.18);
                borderColor = AppColors.successGreen;
                textColor = AppColors.successGreen;
              } else if (isChosen && !isTarget) {
                bgColor = AppColors.dangerRose.withOpacity(0.18);
                borderColor = AppColors.dangerRose;
                textColor = AppColors.dangerRose;
              } else {
                bgColor = isDark ? Colors.white10 : AppColors.cardWarm;
                borderColor = isDark ? AppColors.darkCardBorder : AppColors.cardBorder;
                textColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
              }

              return InkWell(
                onTap: revealed
                    ? null
                    : () => memProv.submitPsalmNumberGuess(num),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor, width: isTarget && revealed ? 1.5 : 1),
                  ),
                  child: Center(
                    child: Text(
                      'መዝሙር ${EthiopicNumerals.toEthiopic(num)} ($num)',
                      style: TextStyle(
                        fontFamily: 'Noto Serif Ethiopic',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Feedback Card if revealed
          if (memProv.isAnswerRevealedForNumber) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: memProv.isGuessCorrect
                    ? AppColors.successGreen.withOpacity(0.12)
                    : AppColors.dangerRose.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: memProv.isGuessCorrect ? AppColors.successGreen : AppColors.dangerRose,
                  width: 0.8,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    memProv.isGuessCorrect ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                    color: memProv.isGuessCorrect ? AppColors.successGreen : AppColors.dangerRose,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      memProv.isGuessCorrect
                          ? 'ትክክል ነው! ✓ መዝሙር ${EthiopicNumerals.toEthiopic(target.number)} (${target.titleGeez})'
                          : 'ትክክለኛው መልስ፡ መዝሙር ${EthiopicNumerals.toEthiopic(target.number)} (${target.titleGeez}) ነው',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: memProv.isGuessCorrect ? AppColors.successGreen : AppColors.dangerRose,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Action Buttons: Next Random Challenge & Direct Reveal
          Row(
            children: [
              if (!memProv.isAnswerRevealedForNumber)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => memProv.revealPsalmNumberAnswer(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('መልሱን አሳይ'),
                  ),
                ),
              if (!memProv.isAnswerRevealedForNumber) const SizedBox(width: 10),
              Expanded(
                flex: memProv.isAnswerRevealedForNumber ? 2 : 1,
                child: ElevatedButton.icon(
                  onPressed: () {
                    memProv.generateRandomPsalmNumberChallenge(allPsalms: psalmProv.allPsalms);
                  },
                  icon: const Icon(Icons.skip_next_rounded, size: 18),
                  label: const Text('ቀጣይ የዘፈቀደ ፈተና (Next)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navyPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Cross Reference Toggle Pills ---
  Widget _buildCrossReferenceToggles(MemorizationProvider memProv, bool isDark) {
    return Row(
      children: [
        FilterChip(
          label: const Text('የአማርኛ ማጣቀሻ (Amharic)'),
          selected: memProv.showAmharicReference,
          onSelected: (_) => memProv.toggleAmharicRef(),
          backgroundColor: Colors.transparent,
          selectedColor: isDark ? Colors.white12 : AppColors.cardWarm,
          labelStyle: TextStyle(
            fontSize: 11.5,
            color: memProv.showAmharicReference
                ? (isDark ? AppColors.goldLight : AppColors.navyPrimary)
                : AppColors.textSecondaryLight,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.zero,
        ),
        const SizedBox(width: 8),
        FilterChip(
          label: const Text('English Ref'),
          selected: memProv.showEnglishReference,
          onSelected: (_) => memProv.toggleEnglishRef(),
          backgroundColor: Colors.transparent,
          selectedColor: isDark ? Colors.white12 : AppColors.cardWarm,
          labelStyle: TextStyle(
            fontSize: 11.5,
            color: memProv.showEnglishReference
                ? (isDark ? AppColors.goldLight : AppColors.navyPrimary)
                : AppColors.textSecondaryLight,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }

  // --- Spaced Repetition Feedback for Whole Psalm Song ---
  Widget _buildEvaluationPanel(
    BuildContext context,
    dynamic psalm,
    MemorizationProvider memProv,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'እንዴት አስታወሱት? (Self-Evaluation for Psalm Song):',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildEvalButton(
                label: 'ረሳሁ',
                sub: 'አላስታወስኩም',
                color: AppColors.dangerRose,
                bgColor: AppColors.dangerRoseLight,
                onTap: () async {
                  await memProv.submitPsalmSongEvaluation('forgot');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ተመዝግቧል: ይህ መዝሙር በዛሬው ክለሳ ውስጥ እንደገና ይመጣል።'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildEvalButton(
                label: 'ከባድ',
                sub: 'እገዛ ፈለግሁ',
                color: AppColors.warningAmber,
                bgColor: AppColors.warningAmberLight,
                onTap: () async {
                  await memProv.submitPsalmSongEvaluation('difficult');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ተመዝግቧል: የሚቀጥለው ክለሳ ከ 2 ቀናት በኋላ ይሆናል።'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildEvalButton(
                label: 'ቀላል',
                sub: 'አስታወስኩት ✓',
                color: AppColors.successGreen,
                bgColor: AppColors.successGreenLight,
                onTap: () async {
                  await memProv.submitPsalmSongEvaluation('easy');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('በጣም ጥሩ! የመዝሙሩ ቀጣይ የክለሳ ጊዜ ወደ ፊት ተራዝሟል።'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEvalButton({
    required String label,
    required String sub,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          alignment: Alignment.center,
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Noto Serif Ethiopic',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(sub, style: TextStyle(fontSize: 9.5, color: color.withOpacity(0.9))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActionPanel(
    BuildContext context,
    dynamic psalm,
    MemorizationProvider memProv,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.cardSurface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkCardBorder : AppColors.cardBorder,
            width: 0.8,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navyPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('ክፍለ ጊዜውን ጨርስ (Finish Session)'),
          ),
        ),
      ),
    );
  }
}

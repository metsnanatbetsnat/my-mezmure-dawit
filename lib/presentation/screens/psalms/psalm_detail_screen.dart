import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/ethiopic_numerals.dart';
import '../../data/models/psalm.dart';
import '../providers/psalm_provider.dart';
import '../providers/memorization_provider.dart';
import '../providers/settings_provider.dart';
import '../memorize/memorize_session_screen.dart';

class PsalmDetailScreen extends StatefulWidget {
  final int psalmNumber;

  const PsalmDetailScreen({super.key, required this.psalmNumber});

  @override
  State<PsalmDetailScreen> createState() => _PsalmDetailScreenState();
}

class _PsalmDetailScreenState extends State<PsalmDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final psalmProv = context.watch<PsalmProvider>();
    final settings = context.watch<SettingsProvider>();
    final memProv = context.watch<MemorizationProvider>();

    final psalm = psalmProv.allPsalms.firstWhere(
      (p) => p.number == widget.psalmNumber,
      orElse: () => Psalm(
        number: widget.psalmNumber,
        titleGeez: 'መዝሙር ዘዳዊት ${EthiopicNumerals.toEthiopic(widget.psalmNumber)}',
        titleAmharic: 'መዝሙረ ዳዊት ${widget.psalmNumber}',
        versesCount: 0,
      ),
    );

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.headerNavy,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.headerNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Psalm ${psalm.number}',
          style: const TextStyle(
            fontFamily: 'Noto Serif Ethiopic',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              psalm.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: Colors.white,
            ),
            onPressed: () => psalmProv.toggleBookmark(psalm.number),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.creamBackground,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: Column(
          children: [
            // Scrollable Reading Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 28, 22, 20),
                children: [
                  // Centered Title
                  Center(
                    child: Text(
                      'Psalm ${psalm.number}',
                      style: TextStyle(
                        fontFamily: 'Noto Serif Ethiopic',
                        fontSize: 22 * settings.fontScale,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.navyPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Elegant Gold Ornament `— ✦ —`
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 32, height: 1, color: AppColors.goldAccent),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.diamond_rounded, size: 10, color: AppColors.goldAccent),
                        ),
                        Container(width: 32, height: 1, color: AppColors.goldAccent),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Entire Psalm Song text in rhythmic verses
                  ...psalm.verses.map((verse) {
                    final primaryGeez = verse.textGeez.isNotEmpty ? verse.textGeez : verse.textAmharic;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        children: [
                          // Primary Ge'ez Sacred Text
                          Text(
                            primaryGeez,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Noto Serif Ethiopic',
                              fontSize: 18 * settings.fontScale,
                              height: 1.8,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.navyPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Amharic Translation
                          if (verse.textAmharic.isNotEmpty && verse.textGeez.isNotEmpty) ...[
                            Text(
                              verse.textAmharic,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Noto Sans Ethiopic',
                                fontSize: 14 * settings.fontScale,
                                height: 1.5,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                            const SizedBox(height: 6),
                          ],

                          // English Translation in Italic
                          if (verse.textEnglish.isNotEmpty) ...[
                            Text(
                              verse.textEnglish,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13.5 * settings.fontScale,
                                height: 1.45,
                                fontStyle: FontStyle.italic,
                                color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                          const SizedBox(height: 14),

                          // Subtle Gold Ornament between verses
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(width: 20, height: 0.8, color: AppColors.goldAccent.withOpacity(0.5)),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 6),
                                  child: Icon(Icons.star_rounded, size: 8, color: AppColors.goldAccent),
                                ),
                                Container(width: 20, height: 0.8, color: AppColors.goldAccent.withOpacity(0.5)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Bottom Floating Controls (Matching Screen 3)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.creamBackground,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pill with Text Size (A-, A+) and Dark Mode Icon (🌙)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : const Color(0xFFF1ECE1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () => settings.setFontScale(settings.fontScale - 0.1),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            child: Text('A-', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        Container(width: 1, height: 14, color: Colors.grey.withOpacity(0.3)),
                        InkWell(
                          onTap: () => settings.setFontScale(settings.fontScale + 0.1),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            child: Text('A+', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        Container(width: 1, height: 14, color: Colors.grey.withOpacity(0.3)),
                        IconButton(
                          icon: Icon(
                            settings.isDarkMode ? Icons.light_mode_rounded : Icons.nightlight_round,
                            size: 16,
                          ),
                          onPressed: () => settings.toggleDarkMode(!settings.isDarkMode),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Deep Navy Rounded Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
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
                        backgroundColor: AppColors.headerNavy,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Start Memorizing Psalm ${psalm.number}',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
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

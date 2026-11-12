import 'package:flutter/material.dart';
import '../../core/audio/recitation_audio_service.dart';
import '../../core/constants/app_colors.dart';

class AudioPlayerBar extends StatelessWidget {
  final int verseId;
  final String title;

  const AudioPlayerBar({
    super.key,
    required this.verseId,
    this.title = 'የንባብ ድምፅ ማዳመጫ',
  });

  @override
  Widget build(BuildContext context) {
    final audio = RecitationAudioService();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: audio,
      builder: (context, _) {
        final isPlayingCurrent = audio.isPlaying && audio.currentVerseId == verseId;
        final isPausedCurrent = audio.isPaused && audio.currentVerseId == verseId;
        final isActive = isPlayingCurrent || isPausedCurrent;

        final positionSeconds = isActive ? audio.position.inSeconds : 0;
        final totalSeconds = isActive ? audio.totalDuration.inSeconds : 12;
        final progressRatio = totalSeconds > 0 ? (positionSeconds / totalSeconds).clamp(0.0, 1.0) : 0.0;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.parchmentSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkCardBorder : AppColors.warmCardBorder,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black26 : AppColors.shadowWarm,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  // Play/Pause circular button
                  Material(
                    color: isDark ? AppColors.goldMuted : AppColors.navyPrimary,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {
                        if (isPlayingCurrent) {
                          audio.pauseRecitation();
                        } else if (isPausedCurrent) {
                          audio.resumeRecitation();
                        } else {
                          audio.playVerseRecitation(verseId);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Icon(
                          isPlayingCurrent ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: isDark ? AppColors.navyDeep : Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Label and audio progress bar
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.navyPrimary,
                              ),
                            ),
                            Text(
                              '${_formatDuration(audio.position)} / ${_formatDuration(audio.totalDuration)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progressRatio,
                            minHeight: 5,
                            backgroundColor: isDark ? Colors.white12 : AppColors.warmCardBorder,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDark ? AppColors.goldMuted : AppColors.goldDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Speed toggle button (0.8x -> 1.0x -> 1.2x)
                  TextButton(
                    onPressed: () {
                      final speeds = [0.8, 1.0, 1.2];
                      final nextIdx = (speeds.indexOf(audio.playbackSpeed) + 1) % speeds.length;
                      audio.setSpeed(speeds[nextIdx]);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: isDark ? Colors.white10 : AppColors.warmCard,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      '${audio.playbackSpeed}x',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.goldMuted : AppColors.navyPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

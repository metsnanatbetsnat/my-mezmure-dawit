import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/decorations/harag_painter.dart';
import '../../data/models/user_settings.dart';
import '../providers/settings_provider.dart';
import '../providers/memorization_provider.dart';
import '../widgets/ethiopian_cross_icon.dart';
import 'notes_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = context.watch<SettingsProvider>();
    final memProv = context.watch<MemorizationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('መገለጫ እና ማስተካከያ (Settings)'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header Card
            _buildProfileHeader(isDark),
            const SizedBox(height: 20),

            // Reading & Script Settings Section
            _buildSectionHeader('የንባብና የፊደላት ማስተካከያ (Display & Script)', isDark),
            const SizedBox(height: 8),
            _buildScriptSettings(context, settings, isDark),
            const SizedBox(height: 20),

            // Study & Memorization Schedule Settings
            _buildSectionHeader('የጥናትና የሽምደዳ ግቦች (Daily Memorization Plan)', isDark),
            const SizedBox(height: 8),
            _buildStudyTargetSettings(context, settings, isDark),
            const SizedBox(height: 20),

            // Daily Reminder Notification Settings
            _buildSectionHeader('የዕለት ማሳሰቢያ (Reminders)', isDark),
            const SizedBox(height: 8),
            _buildReminderSettings(context, settings, isDark),
            const SizedBox(height: 20),

            // Personal Notes Link
            _buildJournalTile(context, isDark),
            const SizedBox(height: 20),

            // Data & Storage (Backup / Reset)
            _buildSectionHeader('የመረጃ አያያዝ (Data & Storage)', isDark),
            const SizedBox(height: 8),
            _buildDataManagementSettings(context, memProv, isDark),
            const SizedBox(height: 24),

            // About App & Ethiopian Manuscript Tradition
            _buildAboutCard(isDark),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.parchmentSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.warmCardBorder,
        ),
        boxShadow: const [
          BoxShadow(color: AppColors.shadowWarm, blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isDark ? AppColors.navySurface : AppColors.warmCard,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.goldBorder, width: 1.5),
            ),
            child: const Center(
              child: EthiopianCrossIcon(size: 32),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.appNameAmharic,
            style: TextStyle(
              fontFamily: 'Noto Serif Ethiopic',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.goldMuted : AppColors.navyPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'የኢትዮጵያ ኦርቶዶክስ ተዋሕዶ ቤተክርስቲያን የመዝሙረ ዳዊት ማጥኛ',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'Noto Serif Ethiopic',
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.goldMuted : AppColors.navyPrimary,
      ),
    );
  }

  Widget _buildScriptSettings(BuildContext context, SettingsProvider settings, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.parchmentSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkCardBorder : AppColors.warmCardBorder),
      ),
      child: Column(
        children: [
          // Theme Toggle
          SwitchListTile(
            title: const Text('የሌሊት ገጽታ (Dark Theme)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: const Text('ለማታ ጸሎትና ንባብ ምቹ', style: TextStyle(fontSize: 12)),
            secondary: Icon(
              settings.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: AppColors.goldDark,
            ),
            value: settings.isDarkMode,
            activeColor: AppColors.goldMuted,
            onChanged: (val) => settings.toggleDarkMode(val),
          ),
          const Divider(height: 1),

          // Script Mode Selection
          ListTile(
            title: const Text('የጽሑፍ ቅጂና ቋንቋ (Script Mode)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: Text(_getScriptModeLabel(settings.scriptMode), style: const TextStyle(fontSize: 12)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onTap: () => _showScriptModeSheet(context, settings),
          ),
          const Divider(height: 1),

          // Font Scale Slider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('የፊደላት መጠን (Font Scale)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    Text('${(settings.fontScale * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Slider(
                  value: settings.fontScale,
                  min: 0.85,
                  max: 1.35,
                  divisions: 5,
                  onChanged: (val) => settings.setFontScale(val),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getScriptModeLabel(ScriptDisplayMode mode) {
    switch (mode) {
      case ScriptDisplayMode.amharicOnly:
        return 'አማርኛ ብቻ (Amharic)';
      case ScriptDisplayMode.geezOnly:
        return 'ግዕዝ ብቻ (Ge\'ez)';
      case ScriptDisplayMode.bilingualAmharicGeez:
        return 'አማርኛና ግዕዝ በጋራ (Bilingual)';
      case ScriptDisplayMode.withEnglishTranslation:
        return 'ከእንግሊዝኛ ትርጉም ጋር (With English)';
    }
  }

  void _showScriptModeSheet(BuildContext context, SettingsProvider settings) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('የጽሑፍና የቋንቋ ምርጫ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),
                RadioListTile<ScriptDisplayMode>(
                  title: const Text('አማርኛ ብቻ'),
                  value: ScriptDisplayMode.amharicOnly,
                  groupValue: settings.scriptMode,
                  onChanged: (val) {
                    if (val != null) settings.setScriptMode(val);
                    Navigator.pop(ctx);
                  },
                ),
                RadioListTile<ScriptDisplayMode>(
                  title: const Text('ግዕዝ ብቻ (ለሊቃውንትና ለተማሪዎች)'),
                  value: ScriptDisplayMode.geezOnly,
                  groupValue: settings.scriptMode,
                  onChanged: (val) {
                    if (val != null) settings.setScriptMode(val);
                    Navigator.pop(ctx);
                  },
                ),
                RadioListTile<ScriptDisplayMode>(
                  title: const Text('አማርኛና ግዕዝ በጋራ (Bilingual)'),
                  value: ScriptDisplayMode.bilingualAmharicGeez,
                  groupValue: settings.scriptMode,
                  onChanged: (val) {
                    if (val != null) settings.setScriptMode(val);
                    Navigator.pop(ctx);
                  },
                ),
                RadioListTile<ScriptDisplayMode>(
                  title: const Text('ከእንግሊዝኛ ትርጉም ጋር (English)'),
                  value: ScriptDisplayMode.withEnglishTranslation,
                  groupValue: settings.scriptMode,
                  onChanged: (val) {
                    if (val != null) settings.setScriptMode(val);
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStudyTargetSettings(BuildContext context, SettingsProvider settings, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.parchmentSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkCardBorder : AppColors.warmCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'የዕለት የመሸምደድ ግብ (Daily Target):',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'በቀን ስንት አዳዲስ ጥቅሶች መሸምደድ ይፈልጋሉ?',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [1, 2, 3, 5].map((target) {
              final isSelected = settings.dailyTargetVerses == target;
              return ChoiceChip(
                label: Text('$target ጥቅሶች'),
                selected: isSelected,
                selectedColor: isDark ? AppColors.goldMuted : AppColors.navyPrimary,
                labelStyle: TextStyle(
                  color: isSelected ? (isDark ? AppColors.navyDeep : Colors.white) : null,
                  fontWeight: isSelected ? FontWeight.bold : null,
                ),
                onSelected: (_) => settings.setDailyTarget(target),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderSettings(BuildContext context, SettingsProvider settings, bool isDark) {
    final timeStr = settings.reminderTime.format(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.parchmentSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkCardBorder : AppColors.warmCardBorder),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('የጥናት ማሳሰቢያ (Daily Reminder)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: Text('የማለዳ/የማታ ጸሎት ሰዓት: $timeStr', style: const TextStyle(fontSize: 12)),
            secondary: const Icon(Icons.alarm_on_rounded, color: AppColors.goldDark),
            value: settings.reminderEnabled,
            activeColor: AppColors.goldMuted,
            onChanged: (val) => settings.setReminder(enabled: val),
          ),
          if (settings.reminderEnabled) ...[
            const Divider(height: 1),
            ListTile(
              title: const Text('የማሳሰቢያ ሰዓት ቀይር (Change Time)', style: TextStyle(fontSize: 13.5)),
              trailing: Text(timeStr, style: const TextStyle(fontWeight: FontWeight.bold)),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: settings.reminderTime,
                );
                if (picked != null) {
                  settings.setReminder(enabled: true, time: picked);
                }
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildJournalTile(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.parchmentSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkCardBorder : AppColors.warmCardBorder),
      ),
      child: ListTile(
        leading: const Icon(Icons.book_rounded, color: AppColors.goldDark),
        title: const Text('የግል ማስታወሻና ነጸብራቅ (Personal Journal)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: const Text('የተቀመጡ መንፈሳዊ ማስታወሻዎችን ይመልከቱ', style: TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotesScreen()),
          );
        },
      ),
    );
  }

  Widget _buildDataManagementSettings(
    BuildContext context,
    MemorizationProvider memProv,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.parchmentSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkCardBorder : AppColors.warmCardBorder),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.download_rounded, color: AppColors.goldDark),
            title: const Text('የመረጃ ቅጂ ውሰድ (Export Progress)', style: TextStyle(fontSize: 14)),
            subtitle: const Text('የሽምደዳ ታሪክዎን በአካባቢ ማህደር ያስቀምጡ', style: TextStyle(fontSize: 12)),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('የሽምደዳ መረጃዎ በስልክዎ ውስጣዊ ዳታቤዝ ላይ ተቀምጧል።')),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.restart_alt_rounded, color: AppColors.dangerRose),
            title: const Text('የሽምደዳ ታሪክን እንደገና አስጀምር (Reset Progress)', style: TextStyle(fontSize: 14, color: AppColors.dangerRose)),
            onTap: () => _showResetDialog(context, memProv),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, MemorizationProvider memProv) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('ታሪክን ዳግም ማስጀመር?'),
          content: const Text('ይህ እርምጃ የተሸመደዱትንና የክለሳ ታሪክዎን በሙሉ ወደ መጀመሪያ ይመልሰዋል። እርግጠኛ ኖት?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('ተመለስ'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.dangerRose),
              onPressed: () async {
                await memProv.resetAllProgress();
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('የሽምደዳ ታሪክ ዳግም ተጀምሯል።')),
                );
              },
              child: const Text('አዎ ዳግም ጀምር', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAboutCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.warmCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkCardBorder : AppColors.warmCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const EthiopianCrossIcon(size: 18),
              const SizedBox(width: 8),
              Text(
                'ስለ መተግበሪያው (About my መዝሙረ ዳዊት)',
                style: TextStyle(
                  fontFamily: 'Noto Serif Ethiopic',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.goldMuted : AppColors.navyPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'ይህ መተግበሪያ ክርስቲያኖች መዝሙረ ዳዊትን በቀላሉ፣ በሰላምና በሥርዓት እንዲሸመድዱ ታስቦ የተዘጋጀ ነው። ምንም አይነት የበይነመረብ (Internet) ግንኙነት አይፈልግም፤ ሙሉ በሙሉ ከመስመር ውጭ (Offline) ይሠራል።',
            style: TextStyle(fontSize: 12.5, height: 1.5, color: AppColors.textSecondaryLight),
          ),
          const SizedBox(height: 10),
          const Text(
            'ሥሪት 1.0.0 (MVP) • የኢትዮጵያ ኦርቶዶክስ ተዋሕዶ ቤተክርስቲያን ቅዱሳት መጻሕፍት ትውፊት',
            style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.goldDark),
          ),
        ],
      ),
    );
  }
}

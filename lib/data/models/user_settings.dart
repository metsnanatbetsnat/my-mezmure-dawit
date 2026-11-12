enum ScriptDisplayMode {
  geezOnly, // Ge'ez only (pure liturgical memorization)
  geezWithAmharicRef, // Ge'ez primary with optional Amharic cross-reference
  geezWithEnglishRef, // Ge'ez primary with optional English cross-reference
  geezWithBothRef, // Ge'ez primary with both Amharic & English
}

class UserSettings {
  final ScriptDisplayMode scriptMode;
  final double fontScale; // 0.85 to 1.35
  final bool isDarkMode;
  final int dailyTargetVerses; // 1, 2, 3, 5
  final bool reminderEnabled;
  final int reminderHour;
  final int reminderMinute;
  final bool autoPlayAudio;
  final double audioPlaybackSpeed; // 0.8, 1.0, 1.2
  final bool showAmharicReference; // Toggle for showing Amharic cross-reference
  final bool showEnglishReference; // Toggle for showing English cross-reference

  const UserSettings({
    this.scriptMode = ScriptDisplayMode.geezWithAmharicRef, // Ge'ez is primary!
    this.fontScale = 1.05,
    this.isDarkMode = false,
    this.dailyTargetVerses = 2,
    this.reminderEnabled = true,
    this.reminderHour = 6,
    this.reminderMinute = 30,
    this.autoPlayAudio = false,
    this.audioPlaybackSpeed = 1.0,
    this.showAmharicReference = true,
    this.showEnglishReference = false,
  });

  UserSettings copyWith({
    ScriptDisplayMode? scriptMode,
    double? fontScale,
    bool? isDarkMode,
    int? dailyTargetVerses,
    bool? reminderEnabled,
    int? reminderHour,
    int? reminderMinute,
    bool? autoPlayAudio,
    double? audioPlaybackSpeed,
    bool? showAmharicReference,
    bool? showEnglishReference,
  }) {
    return UserSettings(
      scriptMode: scriptMode ?? this.scriptMode,
      fontScale: fontScale ?? this.fontScale,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      dailyTargetVerses: dailyTargetVerses ?? this.dailyTargetVerses,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      autoPlayAudio: autoPlayAudio ?? this.autoPlayAudio,
      audioPlaybackSpeed: audioPlaybackSpeed ?? this.audioPlaybackSpeed,
      showAmharicReference: showAmharicReference ?? this.showAmharicReference,
      showEnglishReference: showEnglishReference ?? this.showEnglishReference,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'scriptMode': scriptMode.index,
      'fontScale': fontScale,
      'isDarkMode': isDarkMode ? 1 : 0,
      'dailyTargetVerses': dailyTargetVerses,
      'reminderEnabled': reminderEnabled ? 1 : 0,
      'reminderHour': reminderHour,
      'reminderMinute': reminderMinute,
      'autoPlayAudio': autoPlayAudio ? 1 : 0,
      'audioPlaybackSpeed': audioPlaybackSpeed,
      'showAmharicReference': showAmharicReference ? 1 : 0,
      'showEnglishReference': showEnglishReference ? 1 : 0,
    };
  }

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      scriptMode: ScriptDisplayMode.values[(map['scriptMode'] as int? ?? 1).clamp(0, ScriptDisplayMode.values.length - 1)],
      fontScale: (map['fontScale'] as num?)?.toDouble() ?? 1.05,
      isDarkMode: (map['isDarkMode'] as int? ?? 0) == 1,
      dailyTargetVerses: map['dailyTargetVerses'] as int? ?? 2,
      reminderEnabled: (map['reminderEnabled'] as int? ?? 1) == 1,
      reminderHour: map['reminderHour'] as int? ?? 6,
      reminderMinute: map['reminderMinute'] as int? ?? 30,
      autoPlayAudio: (map['autoPlayAudio'] as int? ?? 0) == 1,
      audioPlaybackSpeed: (map['audioPlaybackSpeed'] as num?)?.toDouble() ?? 1.0,
      showAmharicReference: (map['showAmharicReference'] as int? ?? 1) == 1,
      showEnglishReference: (map['showEnglishReference'] as int? ?? 0) == 1,
    );
  }
}

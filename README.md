# my መዝሙረ ዳዊት (my Mezmure Dawit)
## An Ethiopian Orthodox Psalm Memorization Mobile Application

A mobile application crafted in Flutter and Dart, specifically designed to help Christians gradually memorize the Book of Psalms (መዝሙረ ዳዊት) through reading, repetition, listening, active recall, recitation, and spaced repetition.

---

## 1. Visual Design & Brand Identity

The application embraces a peaceful, reverent Ethiopian Orthodox Christian manuscript aesthetic:
- **Warm Ivory / Cream Background** (`#FBF8F2` / `#FFFDF9`): Evokes traditional vellum parchment manuscripts.
- **Deep Orthodox Navy Blue** (`#0F1A28` / `#1A2C42`): Grounded, liturgical, and distraction-free.
- **Muted Gold Accents** (`#C5A059` / `#D4AF37`): Inspired by traditional Ethiopian church embroidery (ጥልፍ / ጥበብ) and illuminated gilding.
- **Manuscript Crimson Ink** (`#8B263E`): Authentic vermilion ink (ቀይ ቀለም) traditionally used by Ethiopian scribes for psalm headers and verse numerals.
- **Ethiopian Harag (ሐረግ) Ornamental Dividers**: Crisp, vector-drawn interlace cross ribbons.
- **Traditional Ethiopic Numerals**: Seamless conversion and display of Fidel numbers (፩, ፪, ፫, ፬, ፭, ፮, ፯, ፰, ፱, ፲ ... ፻፶).
- **Light & Dark Themes**: Fully supported with serene contrast for day and night prayer.

---

## 2. Architecture & Folder Structure

Built using Clean Architecture principles and the Provider pattern with a feature-first approach:

```
lib/
├── core/
│   ├── audio/              # Recitation audio service & voice recording practice
│   ├── constants/          # Colors, localized strings, and Ethiopic numerals converter
│   ├── database/           # SQLite database helper & offline persistence
│   ├── decorations/        # Ethiopian Harag (ሐረግ) custom vector painters
│   └── theme/              # Ivory light & midnight dark themes
├── data/
│   ├── datasources/        # Authentic sample data (Psalms 1, 23, 50, 120, 150 + 150 index)
│   ├── models/             # Psalm, Verse, MemorizationProgress, ReviewRecord, DailyPlan, PsalmNote
│   └── repositories/       # PsalmRepository, MemorizationRepository, SettingsRepository
└── presentation/
    ├── providers/          # SettingsProvider, PsalmProvider, MemorizationProvider
    ├── screens/
    │   ├── home/           # Dashboard: Target, Spaced Review, Recents, Stats
    │   ├── psalms/         # 150 Psalm library, search & dignified reading interface
    │   ├── memorize/       # 4 Interactive Memorization Modes & Psalm chooser
    │   ├── progress/       # Spaced Repetition stages, charts & review history
    │   ├── profile/        # Script settings, font scale, reminders, and notes journal
    │   └── main_navigation_screen.dart # 5-tab bottom navigation
    └── widgets/            # Ethiopian Cross icon, Audio recitation player bar
```

---

## 3. The Four Memorization Modes

Located under **ሸምድድ (Memorize)**:

1. **MODE 1: READ (ንባብ)**
   - Complete verse displayed in prominent Ethiopic Fidel and translated script.
   - Interactive repeat counter (`+1 አንብቤያለሁ`) allowing the reader to read repeatedly.
   - Audio recitation playback bar.

2. **MODE 2: HIDDEN WORDS (የተሰወሩ ቃላት)**
   - Selected words are masked with delicate manuscript dashed boxes (`•••••`).
   - The user mentally completes the verse.
   - Any word can be tapped to reveal its text instantly.
   - Quick "ሁሉንም አሳይ" (Reveal All) and "ደብቅ" (Hide) actions.

3. **MODE 3: RECALL (ማስታወስ / Active Recall)**
   - Displays only the first few words of the verse as a prompt cue (e.g. `ምስጉን ነው በክፉዎች ...`).
   - User recalls the rest mentally or aloud.
   - Single tap to reveal and verify the complete verse.

4. **MODE 4: RECITATION (ማዜም / በቃል መደገም)**
   - The complete verse is hidden.
   - User recites the verse independently from memory.
   - Integrated voice recorder to practice reciting and listen back.
   - Three-tier Spaced Repetition self-evaluation:
     - 🟢 **ቀላል (Easy)**: "I remembered it effortlessly" → advances level & extends interval (1d → 3d → 7d → 14d → 30d).
     - 🟡 **ከባድ (Difficult)**: "I needed help/hesitated" → keeps interval short (2 days).
     - 🔴 **ረሳሁ (Forgot)**: "I could not remember it" → resets to Day 1.

---

## 4. Spaced Repetition System

- **Interval Progression**: 1 Day → 3 Days → 7 Days → 14 Days → 30 Days.
- Adapts dynamically based on user feedback.
- Verses are never marked as permanently mastered after a single attempt; they must successfully progress through higher intervals.
- The **ዕለት ክለሳ (Daily Review)** section on the Home and Progress screens alerts the user whenever verses are due for review.

---

## 5. Offline & Local Storage

- 100% offline functionality.
- No mandatory login or external API dependencies.
- SQLite database schema stores:
  - Psalms & Verses
  - Bookmarks
  - Memorization Progress & Ease Factors
  - Review History Records
  - Daily Learning Plans
  - Personal Notes & Reflections
  - User Settings

---

## 6. How to Run

### Mobile (Android & iOS)
```bash
# Ensure Flutter SDK is installed
flutter pub get
flutter run
```

### Run Tests
```bash
flutter test
```

### Run Web Preview
Open `web/preview.html` directly in any web browser to test all 5 tabs and the 4 memorization modes interactively!

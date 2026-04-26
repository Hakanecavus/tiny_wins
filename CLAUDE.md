# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**tiny_wins** ("Minik Kazanımlar") is a Flutter habit-tracking mobile app with a Turkish-language UI. It helps users build daily habits with progress tracking, streaks, and celebrations.

## Tech Stack

- **Flutter** (SDK ^3.11.1)
- **Riverpod** (flutter_riverpod) — state management
- **Hive** (hive, hive_flutter) — local NoSQL storage
- **flutter_animate** — animations
- **intl** — Turkish date formatting
- **uuid** — ID generation

## Architecture

Feature-based architecture under `lib/`:
- `main.dart` — entry point, initializes Riverpod ProviderScope with tr_TR date formatting
- `app.dart` — root widget, checks onboarding state, shows OnboardingScreen or HomeScreen
- `core/` — shared services, models, constants
- `features/` — feature modules (habits, onboarding)

### Core Services

- `LocalStorageService` — Hive wrapper; manages 3 boxes: `habits`, `habit_logs`, `settings`
- `NotificationService` — schedules local notifications for habit reminders
- `HapticService` — provides haptic feedback (increment vs completion)

### Core Models

- `Habit` (Hive typeId: 1) — stores id, name, icon, color, frequency, targetCount, currentCount, streakCount, notifications, isArchived
- `HabitLog` (Hive typeId: 0) — completion records with timestamp
- `NotificationSettings` (Hive typeId: 2) — notification preferences per habit

### Habits Feature Structure

- `domain/habit_provider.dart` — Riverpod providers and HabitsNotifier (StateNotifier)
  - `habitsProvider` — main state
  - `activeHabitsProvider` — filtered to non-archived habits
  - `todayCompletionRateProvider` — completion percentage
  - `globalStreakProvider` — Duolingo-style chain (consecutive days where ALL habits completed)
  - `calendarStatsProvider` — daily success map for calendar
- `presentation/home_screen.dart` — main habits list
- `presentation/widgets/` — HabitCard, HabitCalendar, ProgressRing, CompletionAnimation
- `presentation/templates/` — TemplateSelectionScreen, CustomHabitCreationScreen

## Common Commands

```bash
cd tiny_wins
flutter pub get              # Install dependencies
flutter run                  # Run on connected device/simulator
flutter build ios --simulator --no-codesign  # Build for iOS simulator
flutter test                 # Run all tests
flutter analyze              # Run static analysis
```

## Key Implementation Details

- Onboarding completion stored in Hive settings box (`onboarding_completed` key)
- Daily progress auto-resets via `resetAllDailyProgress()` on midnight transition
- Global streak requires ALL active habits to be completed on a given day
- Habit templates in `core/constants/habit_templates.dart` are UI-only (not persisted to Hive)
- Icons use MaterialIcons by default; custom icon support via `iconCodePoint` and `iconFontFamily`
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/habit_templates.dart';
import '../../../core/models/habit.dart';
import '../domain/habit_provider.dart';
import 'widgets/completion_animation.dart';
import 'widgets/habit_card.dart';
import 'widgets/habit_calendar.dart';
import 'widgets/progress_ring.dart';
import 'templates/template_selection_screen.dart';

/// Ana ekran - Alışkanlık listesi
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _showCelebration = false;
  String _celebrationMessage = '';
  int _celebrationStreak = 0;

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(activeHabitsProvider);
    final completionRate = ref.watch(todayCompletionRateProvider);
    final globalStreak = ref.watch(globalStreakProvider);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Ana içerik
            CustomScrollView(
              slivers: [
                // App Bar
                SliverToBoxAdapter(
                  child: _buildAppBar(globalStreak),
                ),
                // Zinciri Kırma Kartı (Duolingo Tarzı)
                if (globalStreak > 0)
                  SliverToBoxAdapter(
                    child: _buildGlobalStreakCard(globalStreak),
                  ),
                // Günlük özet
                SliverToBoxAdapter(
                  child: _buildDailySummary(completionRate, habitsAsync),
                ),
                // Takvim
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: HabitCalendar(),
                  ),
                ),
                // Seçili gün detayları
                SliverToBoxAdapter(
                  child: _buildSelectedDayDetails(),
                ),
                // Alışkanlık listesi (Sadece bugün için başlık)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text(
                      _isToday(ref.watch(selectedDateProvider)) 
                          ? 'Bugünkü Alışkanlıkların' 
                          : 'Tüm Alışkanlıklar',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                habitsAsync.when(
                  data: (habits) {
                    final selectedDate = ref.watch(selectedDateProvider);
                    final habitsForDate = ref.watch(habitsForDateProvider(selectedDate));
                    final isToday = _isToday(selectedDate);

                    if (habitsForDate.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: _buildEmptyState(),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final habit = habitsForDate[index];
                          return HabitCard(
                            habit: habit,
                            onIncrement: isToday ? () => _handleIncrement(habit) : null,
                            onComplete: isToday ? () => _handleComplete(habit) : null,
                            onLongPress: isToday ? () => _showHabitOptions(habit) : null,
                          );
                        },
                        childCount: habitsForDate.length,
                      ),
                    );
                  },
                  loading: () => const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, _) => SliverFillRemaining(
                    child: Center(child: Text('Hata: $err')),
                  ),
                ),
                // Alt boşluk
                const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
              ],
            ),
            // Kutlama overlay
            if (_showCelebration)
              CompletionAnimation(
                message: _celebrationMessage,
                onComplete: () => setState(() => _showCelebration = false),
              ),
            if (_celebrationStreak >= 7 && !_showCelebration)
              StreakCelebration(
                streak: _celebrationStreak,
                onComplete: () => setState(() => _celebrationStreak = 0),
              ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildGlobalStreakCard(int streak) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.orange, Colors.redAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_fire_department,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$streak Gündür Zinciri Kırmadın!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Harika gidiyorsun, devler gibi başarısın!',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().scale(delay: 400.ms).shimmer(duration: 1.seconds);
  }

  Widget _buildAppBar(int totalStreak) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Logo/İkon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.star,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          // Başlık
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Minik Kazanımlar',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  MotivationMessages.getRandomDaily(),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Toplam streak
          if (totalStreak > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    color: Colors.orange,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$totalStreak',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: -0.2, duration: 400.ms);
  }

  Widget _buildDailySummary(
    double completionRate,
    AsyncValue<List<Habit>> habitsAsync,
  ) {
    final percentage = (completionRate * 100).round();
    final habits = habitsAsync.value ?? [];
    final completedCount = habits.where((h) => h.isCompletedToday).length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // İlerleme çemberi
          ProgressRing(
            progress: completionRate,
            size: 80,
            strokeWidth: 8,
            progressColor: percentage >= 100
                ? AppColors.success
                : percentage >= 50
                    ? AppColors.primary
                    : AppColors.warning,
            child: Center(
              child: Text(
                '$percentage%',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          // Metin
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      percentage >= 100
                          ? 'Harika!'
                          : percentage >= 50
                              ? 'Yarıya geldin!'
                              : 'Başla!',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      percentage >= 100
                          ? Icons.celebration
                          : percentage >= 50
                              ? Icons.fitness_center
                              : Icons.star_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$completedCount/${habits.length} alışkanlık tamamlandı',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 200.ms)
        .slideX(begin: -0.2, duration: 500.ms);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.add_circle_outline,
              size: 60,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Henüz alışkanlık yok',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'İlk alışkanlığını ekleyerek başla! ✨',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToAddHabit,
            icon: const Icon(Icons.add),
            label: const Text('Alışkanlık Ekle'),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: _navigateToAddHabit,
      icon: const Icon(Icons.add),
      label: const Text('Alışkanlık Ekle'),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 600.ms)
        .slideY(begin: 1, duration: 500.ms);
  }

  void _handleIncrement(Habit habit) {
    ref.read(habitsProvider.notifier).incrementProgress(habit);

    // Tamamlandıysa kutlama göster
    if (habit.currentCount + 1 >= habit.targetCount) {
      setState(() {
        _celebrationMessage = '${habit.name} tamamlandı!';
        _showCelebration = true;
        _celebrationStreak = habit.streakCount + 1;
      });
    }
  }

  void _handleComplete(Habit habit) {
    ref.read(habitsProvider.notifier).completeHabit(habit);

    setState(() {
      _celebrationMessage = '${habit.name} tamamlandı!';
      _showCelebration = true;
      _celebrationStreak = habit.streakCount + 1;
    });
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  Widget _buildSelectedDayDetails() {
    final selectedDate = ref.watch(selectedDateProvider);
    final completedHabits = ref.watch(dailyCompletionsProvider(selectedDate));
    
    if (_isToday(selectedDate)) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                '${DateFormat('d MMMM', 'tr_TR').format(selectedDate)} Kazanımları',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (completedHabits.isEmpty)
            const Text(
              'Bu günde tamamlanan alışkanlık bulunamadı.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: completedHabits.map((habit) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(habit.colorValue).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Color(habit.colorValue).withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(habit.iconData, size: 16, color: Color(habit.colorValue)),
                      const SizedBox(width: 6),
                      Text(
                        habit.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(habit.colorValue),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.check_circle, size: 14, color: AppColors.success),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  void _showHabitOptions(Habit habit) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.archive),
              title: const Text('Arşivle'),
              onTap: () {
                ref.read(habitsProvider.notifier).archiveHabit(habit.id);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.warning),
              title:
                  const Text('Sil', style: TextStyle(color: AppColors.warning)),
              onTap: () {
                _showDeleteConfirmation(habit);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Habit habit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alışkanlığı Sil'),
        content: Text('${habit.name} alışkanlığını silmek istediğine emin misin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(habitsProvider.notifier).deleteHabit(habit.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  void _navigateToAddHabit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TemplateSelectionScreen(),
      ),
    );
  }
}

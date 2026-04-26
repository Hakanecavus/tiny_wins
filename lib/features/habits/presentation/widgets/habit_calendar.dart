import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../domain/habit_provider.dart';

class HabitCalendar extends ConsumerStatefulWidget {
  const HabitCalendar({super.key});

  @override
  ConsumerState<HabitCalendar> createState() => _HabitCalendarState();
}

class _HabitCalendarState extends ConsumerState<HabitCalendar> {
  DateTime _focusedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(calendarStatsProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    
    final startingWeekday = firstDayOfMonth.weekday;
    final totalDays = lastDayOfMonth.day;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Ay Navigasyonu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: AppColors.textSecondary),
                onPressed: () {
                  setState(() {
                    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
                  });
                },
              ),
              Text(
                DateFormat('MMMM yyyy', 'tr_TR').format(_focusedMonth),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                onPressed: () {
                  setState(() {
                    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Gün İsimleri
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz']
                .map((day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          // Günler Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: totalDays + (startingWeekday - 1),
            itemBuilder: (context, index) {
              if (index < startingWeekday - 1) {
                return const SizedBox.shrink();
              }
              
              final dayNumber = index - (startingWeekday - 2);
              final date = DateTime(_focusedMonth.year, _focusedMonth.month, dayNumber);
              final today = DateTime.now();
              final isToday = date.day == today.day && date.month == today.month && date.year == today.year;
              final isSelected = date.day == selectedDate.day && date.month == selectedDate.month && date.year == selectedDate.year;
              final dateKey = DateTime(date.year, date.month, date.day);
              final isPerfect = stats[dateKey] ?? false;
              final isFuture = date.isAfter(today);

              return GestureDetector(
                onTap: () {
                  ref.read(selectedDateProvider.notifier).state = date;
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : isPerfect 
                            ? Colors.orange.withOpacity(0.2) 
                            : isToday 
                                ? AppColors.primary.withOpacity(0.1)
                                : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: isToday && !isSelected
                        ? Border.all(color: AppColors.primary, width: 2)
                        : null,
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ] : null,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '$dayNumber',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: (isToday || isSelected) ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? Colors.white
                              : isFuture 
                                  ? AppColors.textTertiary.withOpacity(0.3)
                                  : isToday 
                                      ? AppColors.primary 
                                      : AppColors.textSecondary,
                        ),
                      ),
                      if (isPerfect)
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Icon(
                            Icons.local_fire_department, 
                            color: isSelected ? Colors.white : Colors.orange, 
                            size: 14
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

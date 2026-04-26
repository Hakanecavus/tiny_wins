import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/models/habit.dart';
import '../../../../core/services/haptic_service.dart';

/// Alışkanlık kartı widget'ı
class HabitCard extends StatefulWidget {
  final Habit habit;
  final VoidCallback? onTap;
  final VoidCallback? onIncrement;
  final VoidCallback? onComplete;
  final VoidCallback? onLongPress;

  const HabitCard({
    super.key,
    required this.habit,
    this.onTap,
    this.onIncrement,
    this.onComplete,
    this.onLongPress,
  });

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  Color get _cardColor => Color(widget.habit.colorValue);

  void _handleTap() {
    HapticService.lightImpact();
    widget.onTap?.call();
  }

  void _handleIncrement() {
    if (widget.habit.isCompletedToday) return;

    setState(() => _isPressed = true);
    _scaleController.forward().then((_) => _scaleController.reverse());

    widget.onIncrement?.call();

    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() => _isPressed = false);
    });
  }

  void _handleComplete() {
    if (widget.habit.isCompletedToday) return;

    _scaleController.forward().then((_) => _scaleController.reverse());
    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.habit.isCompletedToday;
    final progress = widget.habit.completionPercentage;

    return GestureDetector(
      onTap: _handleTap,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: _scaleController,
        builder: (context, child) {
          final scale = 1 - (_scaleController.value * 0.05);

          return Transform.scale(
            scale: scale,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_cardColor, _cardColor.withOpacity(0.8)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _cardColor.withOpacity(_isPressed ? 0.2 : 0.4),
                    blurRadius: _isPressed ? 8 : 12,
                    offset: Offset(0, _isPressed ? 2 : 4),
                    spreadRadius: _isPressed ? 0 : 1,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    // Dekoratif arka plan deseni
                    Positioned(
                      right: -20,
                      bottom: -20,
                      child: Icon(
                        Icons.star,
                        size: 120,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Üst satır: İkon + Başlık + Streak
                          Row(
                            children: [
                              // Alışkanlık ikonu
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Center(
                                  child: Icon(
                                    widget.habit.iconData,
                                    size: 28,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // İsim ve açıklama
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.habit.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontFamily: null,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      widget.habit.progressMessage,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Streak göstergesi
                              if (widget.habit.streakCount > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        widget.habit.streakCount >= 7
                                            ? Icons.local_fire_department
                                            : Icons.auto_awesome,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${widget.habit.streakCount}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Alt satır: İlerleme + Butonlar
                          Row(
                            children: [
                              // İlerleme çubuğu
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // İlerleme metni
                                    Row(
                                      children: [
                                        Text(
                                          '${widget.habit.currentCount}',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          ' / ${widget.habit.targetCount} ${widget.habit.unit ?? 'kez'}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white.withOpacity(
                                              0.8,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    // Progress bar
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        backgroundColor: Colors.white
                                            .withValues(alpha: 0.2),
                                        valueColor:
                                            const AlwaysStoppedAnimation(
                                              Colors.white,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Aksiyon butonu
                              if (!isCompleted)
                                _buildActionButton()
                              else
                                _buildCompletedBadge(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, duration: 300.ms),
          );
        },
      ),
    );
  }

  Widget _buildActionButton() {
    final canIncrement = widget.habit.currentCount < widget.habit.targetCount;

    return GestureDetector(
      onTap: canIncrement ? _handleIncrement : null,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(canIncrement ? 0.9 : 0.3),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (canIncrement)
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Icon(Icons.add, color: _cardColor, size: 28),
      ),
    );
  }

  Widget _buildCompletedBadge() {
    return Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.5),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.check,
            color: AppColors.successDark,
            size: 36,
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .scale(
          duration: 800.ms,
          begin: const Offset(1, 1),
          end: const Offset(1.05, 1.05),
        )
        .then()
        .scale(
          duration: 800.ms,
          begin: const Offset(1.05, 1.05),
          end: const Offset(1, 1),
        );
  }
}

/// Arşivlenmiş alışkanlık kartı (daha soluk)
class ArchivedHabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback? onRestore;
  final VoidCallback? onDelete;

  const ArchivedHabitCard({
    super.key,
    required this.habit,
    this.onRestore,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(habit.colorValue).withOpacity(0.5);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.surfaceVariant,
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(habit.iconData, size: 22, color: color),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  Text(
                    'En uzun seri: ${habit.streakCount} gün',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onRestore,
              icon: const Icon(Icons.restore),
              color: AppColors.secondary,
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
              color: AppColors.warning,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

/// Dairesell ilerleme çemberi
class ProgressRing extends StatelessWidget {
  final double progress; // 0.0 - 1.0
  final double size;
  final double strokeWidth;
  final Color? backgroundColor;
  final Color? progressColor;
  final Widget? child;
  final bool animate;

  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 60,
    this.strokeWidth = 4,
    this.backgroundColor,
    this.progressColor,
    this.child,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Arka plan çemberi
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: strokeWidth,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(
                backgroundColor ?? AppColors.textTertiary.withOpacity(0.2),
              ),
            ),
          ),
          // İlerleme çemberi
          TweenAnimationBuilder<double>(
            duration: animate
                ? const Duration(milliseconds: 800)
                : Duration.zero,
            curve: Curves.easeOutCubic,
            tween: Tween<double>(begin: 0, end: progress),
            builder: (context, value, child) {
              return SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: strokeWidth,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation(
                    progressColor ?? AppColors.primary,
                  ),
                  strokeCap: StrokeCap.round,
                ),
              );
            },
          ),
          // İçerik
          ?child,
        ],
      ),
    );
  }
}

/// Mini ilerleme göstergesi (lineer)
class CustomLinearProgressIndicator extends StatelessWidget {
  final double progress;
  final double height;
  final Color? backgroundColor;
  final Color? progressColor;
  final BorderRadius? borderRadius;

  const CustomLinearProgressIndicator({
    super.key,
    required this.progress,
    this.height = 8,
    this.backgroundColor,
    this.progressColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.textTertiary.withOpacity(0.2),
        borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            tween: Tween<double>(begin: 0, end: progress),
            builder: (context, value, child) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: constraints.maxWidth * value,
                  height: height,
                  decoration: BoxDecoration(
                    color: progressColor ?? AppColors.primary,
                    borderRadius:
                        borderRadius ?? BorderRadius.circular(height / 2),
                    boxShadow: [
                      BoxShadow(
                        color: (progressColor ?? AppColors.primary).withOpacity(
                          0.3,
                        ),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Görev sayısı göstergesi (örn: 2/5)
class CountIndicator extends StatelessWidget {
  final int current;
  final int target;
  final Color? color;
  final double size;

  const CountIndicator({
    super.key,
    required this.current,
    required this.target,
    this.color,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = current >= target;
    final displayColor = color ?? AppColors.primary;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isCompleted ? displayColor : displayColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: isCompleted
            ? Icon(Icons.check, size: size * 0.5, color: Colors.white)
            : Text(
                '$current',
                style: TextStyle(
                  color: displayColor,
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}

/// Streak (seri) göstergesi
class StreakIndicator extends StatelessWidget {
  final int streak;
  final double size;

  const StreakIndicator({super.key, required this.streak, this.size = 24});

  @override
  Widget build(BuildContext context) {
    if (streak <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: streak >= 7
            ? AppColors.accent.withOpacity(0.2)
            : AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            streak >= 7 ? '🔥' : '✨',
            style: TextStyle(fontSize: size * 0.6),
          ),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: TextStyle(
              color: streak >= 7 ? AppColors.accentDark : AppColors.primary,
              fontSize: size * 0.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (streak >= 7) ...[
            const SizedBox(width: 2),
            Text(
              'gün!',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: size * 0.35,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

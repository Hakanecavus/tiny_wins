import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/habit_templates.dart';

/// Tamamlama kutlama animasyonu
class CompletionAnimation extends StatefulWidget {
  final String message;
  final VoidCallback? onComplete;
  final Color? accentColor;

  const CompletionAnimation({
    super.key,
    this.message = '',
    this.onComplete,
    this.accentColor,
  });

  @override
  State<CompletionAnimation> createState() => _CompletionAnimationState();
}

class _CompletionAnimationState extends State<CompletionAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.accentColor ?? AppColors.primary;
    final message = widget.message.isNotEmpty
        ? widget.message
        : MotivationMessages.getRandomCompletion();

    return Material(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Kutlama emoji/ikon
            _buildCelebrationEmoji(color),
            const SizedBox(height: 24),
            // Mesaj
            Text(
              message,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 300.ms)
                .scale(begin: const Offset(0.8, 0.8)),
            const SizedBox(height: 8),
            // Alt metin
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Harika gidiyorsun!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.auto_awesome,
                  color: Colors.white.withOpacity(0.8),
                  size: 16,
                ),
              ],
            )
                .animate()
                .fadeIn(delay: 500.ms),
            const SizedBox(height: 32),
            // Kapat butonu
            ElevatedButton(
              onPressed: () => widget.onComplete?.call(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: color,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Harika!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.celebration, color: color, size: 20),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: 700.ms)
                .slideY(begin: 0.2),
          ],
        ),
      ),
    );
  }

  Widget _buildCelebrationEmoji(Color color) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Patlama efekti
        ...List.generate(12, (index) {
          final angle = index * 30.0;
          final distance = 60.0 + (index % 3) * 20;

          return Transform.rotate(
            angle: angle * 3.14159 / 180,
            child: Container(
              width: 8,
              height: distance,
              alignment: Alignment.topCenter,
              child: Container(
                width: 8,
                height: 20,
                decoration: BoxDecoration(
                  color: [
                    color,
                    AppColors.secondary,
                    AppColors.accent,
                  ][index % 3],
                  borderRadius: BorderRadius.circular(4),
                ),
              )
                  .animate(controller: _controller, autoPlay: false)
                  .scale(
                    duration: 600.ms,
                    begin: const Offset(0, 0),
                    end: const Offset(1, 1),
                    curve: Curves.easeOutBack,
                  )
                  .moveY(
                    duration: 600.ms,
                    begin: 0,
                    end: -distance / 2,
                    curve: Curves.easeOut,
                  )
                  .then()
                  .fadeOut(duration: 400.ms),
            ),
          );
        }),
        // Ana emoji
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.stars,
              size: 60,
              color: color,
            ),
          ),
        )
            .animate(controller: _controller, autoPlay: false)
            .scale(
              duration: 500.ms,
              begin: const Offset(0, 0),
              end: const Offset(1, 1),
              curve: Curves.elasticOut,
            )
            .then()
            .shake(duration: 200.ms, hz: 3)
            .then(delay: 800.ms)
            .fadeOut(duration: 300.ms),
      ],
    );
  }
}

/// Basit partikül patlama efekti
class ParticleExplosion extends StatelessWidget {
  final Widget child;
  final Color color;
  final VoidCallback? onComplete;

  const ParticleExplosion({
    super.key,
    required this.child,
    this.color = AppColors.primary,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Partiküller
        ...List.generate(8, (index) {
          final angle = index * 45.0;
          return Transform.rotate(
            angle: angle * 3.14159 / 180,
            child: Container(
              width: 6,
              height: 40,
              alignment: Alignment.topCenter,
              child: Container(
                width: 6,
                height: 12,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            )
                .animate()
                .scale(
                  duration: 400.ms,
                  begin: const Offset(0, 0),
                  end: const Offset(1, 1),
                )
                .moveY(
                  duration: 400.ms,
                  begin: 0,
                  end: -30,
                )
                .then()
                .fadeOut(duration: 200.ms),
          );
        }),
        // Ana widget
        child
            .animate()
            .scale(
              duration: 300.ms,
              begin: const Offset(0.9, 0.9),
              end: const Offset(1.1, 1.1),
              curve: Curves.easeOutBack,
            )
            .then()
            .scale(
              duration: 200.ms,
              begin: const Offset(1.1, 1.1),
              end: const Offset(1, 1),
            ),
      ],
    );
  }
}

/// Streak kutlama animasyonu (7+ gün)
class StreakCelebration extends StatelessWidget {
  final int streak;
  final VoidCallback? onComplete;

  const StreakCelebration({
    super.key,
    required this.streak,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Alev animasyonu
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.local_fire_department, color: Colors.orange, size: 48)
                      .animate(onPlay: (c) => c.repeat())
                      .shake(duration: 500.ms, hz: 4),
                  const SizedBox(width: 8),
                  Text(
                    '$streak',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                   Icon(Icons.local_fire_department, color: Colors.orange, size: 48)
                      .animate(onPlay: (c) => c.repeat())
                      .shake(duration: 500.ms, hz: 4),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                streak >= 30
                    ? 'Aylık Seri! 🏆'
                    : streak >= 14
                        ? 'İki Haftalık Seri! 🌟'
                        : 'Haftalık Seri! ✨',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$streak gündür devam ediyorsun!',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onComplete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.textPrimary,
                ),
                child: const Text('Mükemmel!'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Floating hearts animasyonu (ekranın üzerinde uçan kalpler)
class FloatingHearts extends StatefulWidget {
  final int count;
  final Duration duration;

  const FloatingHearts({
    super.key,
    this.count = 10,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<FloatingHearts> createState() => _FloatingHeartsState();
}

class _FloatingHeartsState extends State<FloatingHearts> {
  final List<Widget> _hearts = [];

  @override
  void initState() {
    super.initState();
    _generateHearts();
  }

  void _generateHearts() {
    final random = DateTime.now().millisecond;
    final icons = [
      Icons.favorite,
      Icons.auto_awesome,
      Icons.star,
      Icons.volunteer_activism,
      Icons.celebration,
      Icons.local_fire_department
    ];

    for (int i = 0; i < widget.count; i++) {
      _hearts.add(
        _buildHeart(
          icons[i % icons.length],
          random + i,
        ),
      );
    }
  }

  Widget _buildHeart(IconData icon, int seed) {
    final left = (seed * 17) % 100;
    final duration = 1500 + (seed % 1000);

    return Positioned(
      left: left.toDouble() * 3, // Daha geniş bir yayılım için
      bottom: -50,
      child: Icon(
        icon,
        size: 24,
        color: [
          Colors.redAccent,
          Colors.amber,
          Colors.blueAccent,
          Colors.pinkAccent,
        ][seed % 4].withOpacity(0.8),
      )
          .animate()
          .moveY(
            duration: Duration(milliseconds: duration),
            begin: 0,
            end: -600 - (seed % 200),
            curve: Curves.easeOut,
          )
          .fadeIn(duration: 200.ms)
          .then(delay: Duration(milliseconds: duration - 500))
          .fadeOut(duration: 200.ms),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _hearts,
    );
  }
}

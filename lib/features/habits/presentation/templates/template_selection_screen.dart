import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/habit_templates.dart';
import '../../../../core/models/habit.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/habit_provider.dart';
import 'custom_habit_creation_screen.dart';

/// Template seçim ekranı
class TemplateSelectionScreen extends ConsumerWidget {
  const TemplateSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alışkanlık Seç'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Başlık
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Hangi alışkanlıkla başlamak istersin?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'İstediğin şablonu seç, sonra hedefini özelleştir!',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Template grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: HabitTemplates.all.length,
                itemBuilder: (context, index) {
                  final template = HabitTemplates.all[index];
                  return _TemplateCard(
                    template: template,
                    onTap: () => _showCustomizeDialog(context, ref, template),
                  );
                },
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.1, duration: 400.ms),
            ),
            // Kendi alışkanlığını ekle
            Padding(
              padding: const EdgeInsets.all(16),
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CustomHabitCreationScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Kendi Alışkanlığımı Oluştur'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomizeDialog(BuildContext context, WidgetRef ref, HabitTemplate template) {
    int targetCount = template.defaultTarget;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sürükleme çubuğu
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              // Template ikonu
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Color(template.colorValue).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Icon(
                    template.icon,
                    size: 40,
                    color: Color(template.colorValue),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // İsim
              Text(
                template.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              // Açıklama
              Text(
                template.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Hedef ayarı
              const Text(
                'Hedefini Belirle',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              // Hedef sayacı
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Azalt
                  IconButton(
                    onPressed: targetCount > 1
                        ? () => setState(() => targetCount--)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                    color: Color(template.colorValue),
                  ),
                  const SizedBox(width: 16),
                  // Değer
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Color(template.colorValue).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$targetCount',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(template.colorValue),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Arttır
                  IconButton(
                    onPressed: targetCount < 100
                        ? () => setState(() => targetCount++)
                        : null,
                    icon: const Icon(Icons.add_circle_outline),
                    color: Color(template.colorValue),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Birim
              Text(
                template.unit,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              // Ekle butonu
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    final habit = HabitTemplates.createHabitFromTemplate(
                      template,
                      customTarget: targetCount,
                    ).copyWith(id: const Uuid().v4());

                    await ref.read(habitsProvider.notifier).addHabit(habit);

                    // Bildirimleri ayarla
                    await NotificationService.scheduleMorningReminder(habit, '08:00');
                    await NotificationService.scheduleEveningReminder(habit, '20:00');
                    await NotificationService.scheduleRandomReminder(habit);

                    if (context.mounted) {
                      Navigator.pop(context); // Bottom sheet kapat
                      Navigator.pop(context); // Ekranı kapat
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(template.colorValue),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    '${template.name} Ekle',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Template kartı
class _TemplateCard extends StatelessWidget {
  final HabitTemplate template;
  final VoidCallback onTap;

  const _TemplateCard({
    required this.template,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Color(template.colorValue).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Color(template.colorValue).withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // İkon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Color(template.colorValue).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  template.icon,
                  size: 32,
                  color: Color(template.colorValue),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // İsim
            Text(
              template.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            // Hedef
            Text(
              '${template.defaultTarget} ${template.unit}',
              style: TextStyle(
                fontSize: 12,
                color: Color(template.colorValue),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            // Frekans
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Color(template.colorValue).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                FrequencyLabels.getLabel(template.frequency),
                style: TextStyle(
                  fontSize: 11,
                  color: Color(template.colorValue),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

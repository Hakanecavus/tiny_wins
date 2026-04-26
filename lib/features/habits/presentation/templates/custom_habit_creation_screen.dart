import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/models/habit.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/habit_provider.dart';

/// Özel alışkanlık oluşturma ekranı
class CustomHabitCreationScreen extends ConsumerStatefulWidget {
  const CustomHabitCreationScreen({super.key});

  @override
  ConsumerState<CustomHabitCreationScreen> createState() =>
      _CustomHabitCreationScreenState();
}

class _CustomHabitCreationScreenState
    extends ConsumerState<CustomHabitCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetController = TextEditingController(text: '1');
  final _unitController = TextEditingController(text: 'kez');

  IconData _selectedIcon = Icons.water_drop;
  int _selectedColorIndex = 0;
  FrequencyType _selectedFrequency = FrequencyType.daily;
  final List<bool> _selectedDays = List.filled(7, true); // Pzt-Paz

  bool _morningReminder = true;
  bool _eveningReminder = true;
  bool _randomReminders = true;

  final List<IconData> _availableIcons = [
    // Sağlık ve Su
    Icons.water_drop,
    Icons.local_drink,
    Icons.medication,
    Icons.monitor_weight,

    // Spor ve Hareket
    Icons.directions_run,
    Icons.directions_walk,
    Icons.directions_bike,
    Icons.fitness_center,
    Icons.self_improvement,
    Icons.sports_handball,
    Icons.sports_tennis,
    Icons.sports_basketball,
    Icons.surfing,
    Icons.hiking,

    // Zihin ve Öğrenme
    Icons.menu_book,
    Icons.auto_stories,
    Icons.edit_note,
    Icons.psychology,
    Icons.lightbulb,
    Icons.language,
    Icons.code,
    Icons.draw,

    // Doğa ve Yaşam
    Icons.forest,
    Icons.nature,
    Icons.eco,
    Icons.wb_sunny,
    Icons.bedtime,
    Icons.pets,
    Icons.cleaning_services,
    Icons.restaurant,

    // Sosyal ve Hobiler
    Icons.favorite,
    Icons.volunteer_activism,
    Icons.music_note,
    Icons.palette,
    Icons.camera_alt,
    Icons.sports_esports,
    Icons.movie,

    // Rozetler ve Diğer
    Icons.star,
    Icons.emoji_events,
    Icons.military_tech,
    Icons.local_fire_department,
    Icons.bolt,
    Icons.push_pin,
    Icons.notifications,
    Icons.work,
    Icons.home,
  ];

  void _createHabit() async {
    if (!_formKey.currentState!.validate()) return;

    final habit = Habit(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      iconCodePoint: _selectedIcon.codePoint,
      iconFontFamily: _selectedIcon.fontFamily ?? 'MaterialIcons',
      colorValue: AppColors.habitGradients[_selectedColorIndex].value,
      frequencyType: _selectedFrequency.toString().split('.').last,
      targetCount: int.parse(_targetController.text),
      unit: _unitController.text.trim().isEmpty
          ? 'kez'
          : _unitController.text.trim(),
      createdAt: DateTime.now(),
      weeklySchedule: _selectedFrequency == FrequencyType.specificDays
          ? _selectedDays
          : null,
      notifications: NotificationSettings(
        enabled: _morningReminder || _eveningReminder || _randomReminders,
        morningTime: _morningReminder ? '08:00' : null,
        eveningTime: _eveningReminder ? '20:00' : null,
        randomReminders: _randomReminders,
      ),
    );

    await ref.read(habitsProvider.notifier).addHabit(habit);

    // Schedule notifications
    if (_morningReminder) {
      await NotificationService.scheduleMorningReminder(habit, '08:00');
    }
    if (_eveningReminder) {
      await NotificationService.scheduleEveningReminder(habit, '20:00');
    }
    if (_randomReminders) {
      await NotificationService.scheduleRandomReminder(habit);
    }

    if (mounted) {
      Navigator.pop(context); // Bu ekranı kapat
      Navigator.pop(context); // Alışkanlık Seç ekranını kapat
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Alışkanlık')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // İkon seçimi - Popup
            Center(
              child: GestureDetector(
                onTap: _showIconPicker,
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.habitGradients[_selectedColorIndex]
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.habitGradients[_selectedColorIndex]
                              .withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        _selectedIcon,
                        size: 40,
                        color: AppColors.habitGradients[_selectedColorIndex],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'İkonu Değiştir',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.habitGradients[_selectedColorIndex],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // İsim
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Alışkanlık İsmi',
                hintText: 'örn: Su İç',
                prefixIcon: Icon(Icons.edit),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'İsim gerekli';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Hedef ve Birim
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _targetController,
                    decoration: const InputDecoration(
                      labelText: 'Hedef',
                      hintText: '3',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Gerekli';
                      }
                      final num = int.tryParse(value);
                      if (num == null || num < 1) {
                        return 'Geçersiz';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _unitController,
                    decoration: const InputDecoration(
                      labelText: 'Birim',
                      hintText: 'bardak, sayfa, dk...',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Renk seçimi
            const Text(
              'Renk Seç',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(
                AppColors.habitGradients.length,
                (index) => GestureDetector(
                  onTap: () => setState(() => _selectedColorIndex = index),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.habitGradients[index],
                      borderRadius: BorderRadius.circular(12),
                      border: _selectedColorIndex == index
                          ? Border.all(color: AppColors.textPrimary, width: 3)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.habitGradients[index].withOpacity(
                            0.4,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _selectedColorIndex == index
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Sıklık
            const Text(
              'Sıklık',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            SegmentedButton<FrequencyType>(
              segments: const [
                ButtonSegment(
                  value: FrequencyType.daily,
                  label: Text('Her Gün'),
                  icon: Icon(Icons.calendar_today),
                ),
                ButtonSegment(
                  value: FrequencyType.weekly,
                  label: Text('Haftalık'),
                  icon: Icon(Icons.calendar_view_week),
                ),
                ButtonSegment(
                  value: FrequencyType.specificDays,
                  label: Text('Belirli Günler'),
                  icon: Icon(Icons.date_range),
                ),
              ],
              selected: {_selectedFrequency},
              onSelectionChanged: (Set<FrequencyType> selected) {
                setState(() => _selectedFrequency = selected.first);
              },
            ),

            // Belirli günler seçimi
            if (_selectedFrequency == FrequencyType.specificDays) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(7, (index) {
                  final days = [
                    'Pzt',
                    'Sal',
                    'Çar',
                    'Per',
                    'Cum',
                    'Cmt',
                    'Paz',
                  ];
                  return Column(
                    children: [
                      Text(
                        days[index],
                        style: TextStyle(
                          fontSize: 12,
                          color: _selectedDays[index]
                              ? AppColors.primary
                              : AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Checkbox(
                        value: _selectedDays[index],
                        onChanged: (value) {
                          setState(() => _selectedDays[index] = value ?? false);
                        },
                      ),
                    ],
                  );
                }),
              ),
            ],
            const SizedBox(height: 24),

            // Bildirim ayarları
            const Text(
              'Bildirimler',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Sabah Hatırlatıcı'),
                    subtitle: const Text('08:00'),
                    value: _morningReminder,
                    onChanged: (value) =>
                        setState(() => _morningReminder = value),
                    secondary: const Icon(Icons.wb_sunny),
                  ),
                  SwitchListTile(
                    title: const Text('Akşam Hatırlatıcı'),
                    subtitle: const Text('20:00'),
                    value: _eveningReminder,
                    onChanged: (value) =>
                        setState(() => _eveningReminder = value),
                    secondary: const Icon(Icons.nightlight_round),
                  ),
                  SwitchListTile(
                    title: const Text('"Beni Unutma Sakın"'),
                    subtitle: const Text('Gün içi sürpriz hatırlatıcılar'),
                    value: _randomReminders,
                    onChanged: (value) =>
                        setState(() => _randomReminders = value),
                    secondary: const Icon(Icons.favorite),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Oluştur butonu
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _createHabit,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.habitGradients[_selectedColorIndex],
                ),
                child: const Text(
                  'Alışkanlık Oluştur',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showIconPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Bir İkon Seç',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _availableIcons.length,
                itemBuilder: (context, index) {
                  final icon = _availableIcons[index];
                  final isSelected = icon == _selectedIcon;
                  final habitColor =
                      AppColors.habitGradients[_selectedColorIndex];

                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedIcon = icon);
                      Navigator.pop(context);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? habitColor
                            : habitColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? habitColor : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected
                            ? Colors.white
                            : habitColor.withOpacity(0.8),
                        size: 24,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _unitController.dispose();
    super.dispose();
  }
}

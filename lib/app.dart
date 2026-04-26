import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/theme.dart';
import 'core/services/local_storage_service.dart';
import 'core/services/notification_service.dart';
import 'features/habits/presentation/home_screen.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';

import 'features/habits/domain/habit_provider.dart';

/// Uygulama widget'ı
class TinyWinsApp extends ConsumerStatefulWidget {
  const TinyWinsApp({super.key});

  @override
  ConsumerState<TinyWinsApp> createState() => _TinyWinsAppState();
}

class _TinyWinsAppState extends ConsumerState<TinyWinsApp> with WidgetsBindingObserver {
  bool _initialized = false;
  bool _showOnboarding = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _initialized) {
      _checkDayChange();
    }
  }

  Future<void> _checkDayChange() async {
    await LocalStorageService.checkAndResetDailyProgress();
    // Eğer veriler değiştiyse provider'ı yenile
    if (mounted) {
      ref.read(habitsProvider.notifier).refresh();
    }
  }

  Future<void> _initialize() async {
    // Local storage'ı başlat
    await LocalStorageService.initialize();
    
    // Günlük sıfırlama kontrolü
    await LocalStorageService.checkAndResetDailyProgress();

    // Bildirim servisini başlat
    await NotificationService.initialize();
    await NotificationService.requestPermissions();

    // Onboarding durumunu kontrol et
    final onboardingCompleted = LocalStorageService.onboardingCompleted;

    if (mounted) {
      setState(() {
        _showOnboarding = !onboardingCompleted;
        _initialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Minik Kazanımlar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: _showOnboarding
          ? const OnboardingScreen()
          : const HomeScreen(),
    );
  }
}
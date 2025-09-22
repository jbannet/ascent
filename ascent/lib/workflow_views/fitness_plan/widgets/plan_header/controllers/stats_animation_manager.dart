import 'package:flutter/material.dart';

class StatsAnimationManager {
  final TickerProvider tickerProvider;

  late AnimationController _waveController;
  late AnimationController _countUpController;
  late AnimationController _nutritionController;
  late AnimationController _sleepController;

  late Animation<double> _countUpAnimation;
  late Animation<double> _nutritionAnimation;
  late Animation<double> _sleepAnimation;

  StatsAnimationManager({
    required this.tickerProvider,
    required int completedMinutes,
  }) {
    _initializeControllers(completedMinutes);
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeControllers(int completedMinutes) {
    // Wave animation - continuous (respects accessibility settings)
    _waveController = AnimationController(
      duration: const Duration(seconds: 14), // Even slower, more hypnotic waves
      vsync: tickerProvider,
    );

    // Count-up animation for main number
    _countUpController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: tickerProvider,
    );

    // Circle progress animations
    _nutritionController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: tickerProvider,
    );

    _sleepController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: tickerProvider,
    );
  }

  void _initializeAnimations() {
    _countUpAnimation = Tween<double>(
      begin: 0,
      end: 0, // Will be updated when completedMinutes changes
    ).animate(CurvedAnimation(
      parent: _countUpController,
      curve: Curves.easeOut,
    ));

    _nutritionAnimation = Tween<double>(
      begin: 0.0,
      end: 0.78, // Target nutrition progress
    ).animate(CurvedAnimation(
      parent: _nutritionController,
      curve: Curves.easeOut,
    ));

    _sleepAnimation = Tween<double>(
      begin: 0.0,
      end: 0.94, // Target sleep progress
    ).animate(CurvedAnimation(
      parent: _sleepController,
      curve: Curves.easeOut,
    ));
  }

  void _startAnimations() {
    // Start wave animation immediately
    _waveController.repeat();

    // Start animations with staggered delays
    _countUpController.forward();

    // Start nutrition circle after a delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _nutritionController.forward();
    });

    // Start sleep circle after another delay
    Future.delayed(const Duration(milliseconds: 700), () {
      _sleepController.forward();
    });
  }

  void updateCountUpAnimation(int newCompletedMinutes) {
    _countUpAnimation = Tween<double>(
      begin: 0,
      end: newCompletedMinutes.toDouble(),
    ).animate(CurvedAnimation(
      parent: _countUpController,
      curve: Curves.easeOut,
    ));
    _countUpController.reset();
    _countUpController.forward();
  }

  // Getters for animations
  AnimationController get waveController => _waveController;
  Animation<double> get countUpAnimation => _countUpAnimation;
  Animation<double> get nutritionAnimation => _nutritionAnimation;
  Animation<double> get sleepAnimation => _sleepAnimation;

  void dispose() {
    _waveController.dispose();
    _countUpController.dispose();
    _nutritionController.dispose();
    _sleepController.dispose();
  }
}
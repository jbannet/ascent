import 'package:flutter/material.dart';
import '../../../models/blocks/cooldown_step.dart';

class CooldownStepCard extends StatelessWidget {
  final CooldownStep step;

  const CooldownStepCard({
    super.key,
    required this.step,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final minutes = (step.timeSec / 60).floor();
    final seconds = step.timeSec % 60;
    final timeDisplay = minutes > 0 
        ? '${minutes}m ${seconds > 0 ? "${seconds}s" : ""}'
        : '${seconds}s';
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.tertiaryContainer,
              theme.colorScheme.tertiaryContainer.withValues(alpha: 0.6),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.spa,
                  size: 64,
                  color: theme.colorScheme.tertiary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Cool Down',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onTertiaryContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                step.displayName,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.onTertiaryContainer,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer,
                      color: theme.colorScheme.tertiary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeDisplay,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Recovery and relaxation',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onTertiaryContainer.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [
                  Chip(
                    label: const Text('Gentle stretching'),
                    backgroundColor: theme.colorScheme.secondaryContainer,
                  ),
                  Chip(
                    label: const Text('Controlled breathing'),
                    backgroundColor: theme.colorScheme.secondaryContainer,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
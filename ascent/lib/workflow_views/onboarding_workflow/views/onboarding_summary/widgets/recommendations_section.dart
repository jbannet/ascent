import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../../models/fitness_profile_model/fitness_profile.dart';
import '../../../../../models/fitness_profile_model/fitness_profile_extraction_extensions/recommendations.dart';
import '../../../../../services_and_utilities/llm/llm_bridge.dart';

class RecommendationsSection extends StatefulWidget {
  final FitnessProfile fitnessProfile;

  const RecommendationsSection({
    super.key,
    required this.fitnessProfile,
  });

  @override
  State<RecommendationsSection> createState() => _RecommendationsSectionState();
}

class _RecommendationsSectionState extends State<RecommendationsSection> {

  String _introduction = '';
  String _summary = '';
  bool _isGenerating = false;
  StreamSubscription<String>? _summarySubscription;

  @override
  void initState() {
    super.initState();
    _generateSummary();
  }

  @override
  void dispose() {
    _summarySubscription?.cancel();
    super.dispose();
  }

  Future<void> _generateSummary() async {
    // Calculate recommendations on-demand
    widget.fitnessProfile.calculateRecommendations();
    final recommendations = widget.fitnessProfile.recommendationsList ?? [];

    if (recommendations.isEmpty) {
      return;
    }

    setState(() {
      _isGenerating = true;
      _introduction = '';
      _summary = '';
    });

    try {
      // First generate introduction
      final introBuffer = StringBuffer();
      final introCompleter = Completer<void>();

      _summarySubscription = LlmBridge.introduction(
        style: 'motivational',
        temperature: 0.1,
      ).listen(
        (token) {
          if (mounted) {
            introBuffer.write(token);
            setState(() {
              _introduction = introBuffer.toString();
            });
          }
        },
        onDone: () {
          if (mounted) {
            setState(() {
              _introduction = introBuffer.toString().trim();
            });
          }
          introCompleter.complete();
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _introduction = 'Welcome to your fitness journey!';
            });
          }
          introCompleter.complete();
        },
      );

      await introCompleter.future;
      if (!mounted) return;
      // Take top 3 recommendations and make separate calls
      final top3 = recommendations.take(3).toList();
      final summaries = <String>[];

      for (int i = 0; i < top3.length; i++) {
        if (!mounted) return;

        final buffer = StringBuffer();
        final completer = Completer<void>();

        _summarySubscription = LlmBridge.rewriteRecommendation(
          top3[i],
          style: 'motivational',
          temperature: 0.1,
        ).listen(
          (token) {
            if (mounted) {
              buffer.write(token);
            }
          },
          onDone: () {
            if (mounted) {
              final summary = buffer.toString().trim();
              summaries.add('• $summary');
              setState(() {
                _summary = summaries.join('\n\n');
              });
            }
            completer.complete();
          },
          onError: (error) {
            if (mounted) {
              summaries.add('• Unable to process this recommendation.');
              setState(() {
                _summary = summaries.join('\n\n');
              });
            }
            completer.complete();
          },
        );

        await completer.future;
        if (!mounted) return;
      }

      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isGenerating = false;
          _summary = 'Unable to generate summary at this time.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate recommendations to check if we have any
    widget.fitnessProfile.calculateRecommendations();
    final recommendations = widget.fitnessProfile.recommendationsList ?? [];

    if (recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your personal Kettlebell AI says...',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.psychology, size: 24, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: _isGenerating
                      ? const Row(
                          children: [
                            SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text('Analyzing your profile...'),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_introduction.isNotEmpty) ...[
                              Text(
                                _introduction,
                                style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                              ),
                              const SizedBox(height: 16),
                            ],
                            Text(
                              _summary.isEmpty ? '—' : _summary,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

}
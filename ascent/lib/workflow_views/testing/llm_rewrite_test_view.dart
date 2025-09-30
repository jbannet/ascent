import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ascent/services_and_utilities/app_state/app_state.dart';
import 'package:ascent/services_and_utilities/llm/bundled_model_loader.dart';
import 'package:ascent/services_and_utilities/llm/llm_bridge.dart';
import 'package:ascent/services_and_utilities/llm/llm_service.dart';
import 'package:ascent/models/fitness_profile_model/fitness_profile_extraction_extensions/recommendations.dart';

enum _RewriteStatus { idle, loadingModel, thinking, done, error }

class LlmRewriteTestView extends StatefulWidget {
  const LlmRewriteTestView({super.key});

  @override
  State<LlmRewriteTestView> createState() => _LlmRewriteTestViewState();
}

class _LlmRewriteTestViewState extends State<LlmRewriteTestView> {
  bool _showControls = false;
  _RewriteStatus _status = _RewriteStatus.idle;
  String? _selectedTone;
  String? _errorMessage;
  double? _downloadProgress;
  int _activeRequestId = 0;
  List<String> _original = const [];
  String _summary = '';

  @override
  void dispose() {
    _activeRequestId++;
    super.dispose();
  }

  Future<void> _handleToneTap(String toneKey) async {
    if (_original.isEmpty) {
      setState(() {
        _errorMessage =
            'No recommendations available. Complete onboarding first.';
        _status = _RewriteStatus.error;
      });
      return;
    }

    final requestId = ++_activeRequestId;
    setState(() {
      _selectedTone = toneKey;
      _summary = '';
      _errorMessage = null;
      final loading = llmService.state != LlmState.ready;
      _downloadProgress = loading ? 0 : null;
      _status = loading ? _RewriteStatus.loadingModel : _RewriteStatus.thinking;
    });

    try {
      if (llmService.state != LlmState.ready) {
        final modelDir = await ensureBundledModelAvailable();
        await llmService.ensureEngine(
          onProgress: (received, total) {
            if (_activeRequestId != requestId) return;
            if (total == null || total == 0) {
              setState(() => _downloadProgress = null);
            } else {
              setState(() => _downloadProgress = received / total);
            }
          },
          overrideModelDirectory: modelDir.path,
        );
        if (_activeRequestId != requestId) return;
        setState(() {
          _downloadProgress = null;
          _status = _RewriteStatus.thinking;
        });
      }

      // Take top 3 recommendations and make separate calls
      final top3 = _original.take(3).toList();
      final summaries = <String>[];

      for (int i = 0; i < top3.length; i++) {
        if (_activeRequestId != requestId) return;

        final buffer = StringBuffer();
        await for (final token in LlmBridge.rewriteRecommendation(
          top3[i],
          style: toneKey,
          temperature: 0.1,
        )) {
          if (_activeRequestId != requestId) return;
          buffer.write(token);
        }

        if (_activeRequestId != requestId) return;
        final summary = buffer.toString().trim();
        summaries.add('• $summary');

        // Update UI with progress
        setState(() {
          _summary = summaries.join('\n\n');
        });
      }

      if (_activeRequestId != requestId) return;
      setState(() => _status = _RewriteStatus.done);
    } catch (error) {
      if (_activeRequestId != requestId) return;
      setState(() {
        _status = _RewriteStatus.error;
        _errorMessage = error.toString();
      });
    }
  }

  Future<void> _handleClearCache() async {
    setState(() {
      _status = _RewriteStatus.idle;
      _errorMessage = null;
      _downloadProgress = null;
      _selectedTone = null;
      _summary = '';
    });
    await llmService.clearCache();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();

    // Calculate recommendations on-demand
    appState.profile?.calculateRecommendations();
    final recs = appState.profile?.recommendationsList;
    final sanitized = recs != null ? List<String>.from(recs) : <String>[];

    if (!listEquals(_original, sanitized)) {
      _original = List<String>.from(sanitized);
      _summary = '';
    }

    final statusWidget = _buildStatusIndicator(theme);

    return Scaffold(
      appBar: AppBar(title: const Text('LLM Recommendation Test')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Test on-device rewriting for the current recommendations list. '
              'Pick a tone to stream the rewritten copy.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                setState(() {
                  _showControls = true;
                  _status = _RewriteStatus.idle;
                  _errorMessage = null;
                  _selectedTone = null;
                  _summary = '';
                });
              },
              child: const Text('Try LLM Rewrite'),
            ),
            const SizedBox(height: 12),
            if (_showControls) ...[
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.tonal(
                    onPressed: _handleClearCache,
                    child: const Text('Clear cached model'),
                  ),
                  FilledButton.tonal(
                    onPressed: () async {
                      await llmService.dispose();
                      if (mounted) {
                        setState(() {
                          _status = _RewriteStatus.idle;
                          _downloadProgress = null;
                          _errorMessage = null;
                        });
                      }
                    },
                    child: const Text('Dispose engine'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildToneGrid(theme),
              const SizedBox(height: 16),
              if (statusWidget != null) statusWidget,
              Expanded(
                child: _RecommendationSummary(
                  original: _original,
                  summary: _summary,
                  selectedTone: _selectedTone,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget? _buildStatusIndicator(ThemeData theme) {
    switch (_status) {
      case _RewriteStatus.idle:
        return Text(
          'Select a tone to start rewrites.',
          style: theme.textTheme.bodyMedium,
        );
      case _RewriteStatus.loadingModel:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Text('Loading model…', style: theme.textTheme.bodyMedium),
              ],
            ),
            if (_downloadProgress != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: LinearProgressIndicator(value: _downloadProgress),
              ),
          ],
        );
      case _RewriteStatus.thinking:
        return Row(
          children: [
            const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            Text(
              'Thinking… streaming tokens',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        );
      case _RewriteStatus.done:
        return Text(
          'Rewrites complete.',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        );
      case _RewriteStatus.error:
        return Text(
          _errorMessage ?? 'Something went wrong.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.error,
          ),
        );
    }
  }

  Widget _buildToneGrid(ThemeData theme) {
    final tones = <String, String>{
      'friendly': 'Friendly',
      'direct': 'Direct',
      'motivational': 'Motivational',
      'educational': 'Educational',
    };

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children:
          tones.entries.map((entry) {
            final isSelected = _selectedTone == entry.key;
            return FilledButton(
              onPressed: () => _handleToneTap(entry.key),
              style: FilledButton.styleFrom(
                backgroundColor:
                    isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainer,
              ),
              child: Text(entry.value),
            );
          }).toList(),
    );
  }
}

class _RecommendationSummary extends StatelessWidget {
  const _RecommendationSummary({
    required this.original,
    required this.summary,
    required this.selectedTone,
  });

  final List<String> original;
  final String summary;
  final String? selectedTone;

  @override
  Widget build(BuildContext context) {
    if (original.isEmpty) {
      return const Center(child: Text('No recommendations available.'));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Original Recommendations', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  for (final rec in original) ...[
                    Text('• $rec', style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 4),
                  ],
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedTone != null
                        ? 'Generated Summary (${selectedTone!.toUpperCase()})'
                        : 'Generated Summary',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 150),
                    child: Text(
                      summary.isEmpty ? '—' : summary,
                      key: ValueKey(summary.hashCode),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

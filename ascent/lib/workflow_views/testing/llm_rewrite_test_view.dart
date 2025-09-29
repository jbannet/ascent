import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ascent/services_and_utilities/app_state/app_state.dart';
import 'package:ascent/services_and_utilities/llm/bundled_model_loader.dart';
import 'package:ascent/services_and_utilities/llm/llm_bridge.dart';
import 'package:ascent/services_and_utilities/llm/llm_service.dart';

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
  List<String> _rewritten = const [];

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
      _rewritten = List<String>.filled(_original.length, '');
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

      for (var index = 0; index < _original.length; index++) {
        final buffer = StringBuffer();
        await for (final token in LlmBridge.rewrite(
          _original[index],
          style: toneKey,
          temperature: 0.7,
        )) {
          if (_activeRequestId != requestId) {
            return;
          }
          buffer.write(token);
          setState(() {
            if (_rewritten.length != _original.length) {
              _rewritten = List<String>.filled(_original.length, '');
            }
            _rewritten[index] = buffer.toString();
          });
        }
        if (_activeRequestId != requestId) {
          return;
        }
        final completed = buffer.toString().trim();
        setState(() {
          if (_rewritten.length != _original.length) {
            _rewritten = List<String>.filled(_original.length, '');
          }
          _rewritten[index] = completed;
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
      _rewritten = List<String>.filled(_original.length, '');
    });
    await llmService.clearCache();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    final recs = appState.profile?.recommendationsList;
    final sanitized =
        (recs == null || recs.isEmpty)
            ? <String>[
              'Add two brisk 20-minute walks this week.',
              'Prioritize eight hours of sleep at least four nights.',
              'Complete two strength sessions focusing on compound lifts.',
            ]
            : List<String>.from(recs);

    if (!listEquals(_original, sanitized)) {
      _original = List<String>.from(sanitized);
      _rewritten = List<String>.filled(_original.length, '');
    } else if (_rewritten.length != _original.length) {
      _rewritten = List<String>.filled(_original.length, '');
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
                  _rewritten = List<String>.filled(_original.length, '');
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
                child: _RecommendationList(
                  original: _original,
                  rewritten: _rewritten,
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

class _RecommendationList extends StatelessWidget {
  const _RecommendationList({
    required this.original,
    required this.rewritten,
    required this.selectedTone,
  });

  final List<String> original;
  final List<String> rewritten;
  final String? selectedTone;

  @override
  Widget build(BuildContext context) {
    if (original.isEmpty) {
      return const Center(child: Text('No recommendations available.'));
    }

    return ListView.builder(
      itemCount: original.length,
      itemBuilder: (context, index) {
        final rewrittenText = index < rewritten.length ? rewritten[index] : '';
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Original', style: Theme.of(context).textTheme.labelSmall),
                Text(original[index]),
                const SizedBox(height: 8),
                Text(
                  selectedTone != null
                      ? 'Rewritten (${selectedTone!.toUpperCase()})'
                      : 'Rewritten',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  child: Text(
                    rewrittenText.isEmpty ? '—' : rewrittenText,
                    key: ValueKey(rewrittenText.hashCode ^ index),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

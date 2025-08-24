import 'package:flutter/material.dart';

class RankingOption {
  final String id;
  final String label;
  final String? description;
  final dynamic value;

  const RankingOption({
    required this.id,
    required this.label,
    this.description,
    required this.value,
  });
}

class RankingWidget extends StatefulWidget {
  final String questionId;
  final String title;
  final String? subtitle;
  final List<RankingOption> options;
  final Map<String, int>? currentRankings; // value -> rank
  final Function(String questionId, Map<String, int> rankings) onAnswerChanged;
  final bool isRequired;
  final int maxRankings; // How many items to rank (e.g., rank top 3)
  final bool allowTies;

  const RankingWidget({
    super.key,
    required this.questionId,
    required this.title,
    this.subtitle,
    required this.options,
    this.currentRankings,
    required this.onAnswerChanged,
    this.isRequired = true,
    required this.maxRankings,
    this.allowTies = false,
  });

  @override
  State<RankingWidget> createState() => _RankingWidgetState();
}

class _RankingWidgetState extends State<RankingWidget> {
  Map<String, int> _rankings = {};

  @override
  void initState() {
    super.initState();
    _rankings = widget.currentRankings?.map((key, value) => MapEntry(key, value)) ?? {};
  }

  @override
  void didUpdateWidget(RankingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentRankings != oldWidget.currentRankings) {
      _rankings = widget.currentRankings?.map((key, value) => MapEntry(key, value)) ?? {};
    }
  }

  void _setRanking(String optionValue, int rank) {
    setState(() {
      if (!widget.allowTies) {
        // Remove any existing item with this rank
        _rankings.removeWhere((key, value) => value == rank);
      }
      
      // Set new ranking
      _rankings[optionValue] = rank;
      
      // Remove if rank is 0 (unranked)
      if (rank == 0) {
        _rankings.remove(optionValue);
      }
    });
    
    widget.onAnswerChanged(widget.questionId, _rankings);
  }

  int _getRanking(String optionValue) {
    return _rankings[optionValue] ?? 0;
  }

  List<RankingOption> _getSortedRankedOptions() {
    final rankedOptions = widget.options
        .where((option) => _rankings.containsKey(option.value.toString()))
        .toList();
    
    rankedOptions.sort((a, b) {
      final rankA = _rankings[a.value.toString()] ?? 0;
      final rankB = _rankings[b.value.toString()] ?? 0;
      return rankA.compareTo(rankB);
    });
    
    return rankedOptions;
  }

  String _getRankText(int rank) {
    switch (rank) {
      case 1: return '1st';
      case 2: return '2nd'; 
      case 3: return '3rd';
      default: return '${rank}th';
    }
  }

  Color _getRankColor(ThemeData theme, int rank) {
    switch (rank) {
      case 1: return Colors.amber.shade600; // Gold
      case 2: return Colors.grey.shade400;  // Silver
      case 3: return Colors.orange.shade600; // Bronze
      default: return theme.colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rankedOptions = _getSortedRankedOptions();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question Title
        Text(
          widget.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        
        // Subtitle if provided
        if (widget.subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.subtitle!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
        
        const SizedBox(height: 8),
        
        // Instructions and required indicator
        Row(
          children: [
            Expanded(
              child: Text(
                'Rank your top ${widget.maxRankings} choices (1 = most important)',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (widget.isRequired) ...[
              const SizedBox(width: 8),
              Text(
                '* Required',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
        
        // Progress indicator
        const SizedBox(height: 8),
        Text(
          '${_rankings.length}/${widget.maxRankings} ranked',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Current Rankings Summary (if any)
        if (rankedOptions.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Rankings',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ...rankedOptions.map((option) {
                  final rank = _rankings[option.value.toString()]!;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _getRankColor(theme, rank),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              rank.toString(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${_getRankText(rank)} choice',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            option.label,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
        
        // Options List
        Text(
          'Tap to rank each option:',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        
        Column(
          children: widget.options.map((option) {
            final currentRank = _getRanking(option.value.toString());
            final isRanked = currentRank > 0;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showRankingDialog(option),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isRanked
                            ? _getRankColor(theme, currentRank)
                            : theme.colorScheme.outline.withValues(alpha: 0.3),
                        width: isRanked ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: isRanked
                          ? _getRankColor(theme, currentRank).withValues(alpha: 0.05)
                          : theme.colorScheme.surface,
                    ),
                    child: Row(
                      children: [
                        // Rank indicator
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isRanked
                                ? _getRankColor(theme, currentRank)
                                : theme.colorScheme.outline.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              isRanked ? currentRank.toString() : '?',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isRanked ? Colors.white : theme.colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Option content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                option.label,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: isRanked ? FontWeight.w600 : FontWeight.w400,
                                  color: isRanked
                                      ? _getRankColor(theme, currentRank)
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                              if (option.description != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  option.description!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                              if (isRanked) ...[
                                const SizedBox(height: 4),
                                Text(
                                  _getRankText(currentRank),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: _getRankColor(theme, currentRank),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        
                        // Tap indicator
                        Icon(
                          isRanked ? Icons.edit : Icons.add_circle_outline,
                          color: isRanked
                              ? _getRankColor(theme, currentRank)
                              : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showRankingDialog(RankingOption option) {
    final currentRank = _getRanking(option.value.toString());
    
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text('Rank: ${option.label}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (option.description != null) ...[
                Text(
                  option.description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text(
                'Select a ranking:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Unrank option
                  if (currentRank > 0)
                    _buildRankButton(theme, 0, 'Remove', option.value.toString()),
                  // Rank options
                  ...List.generate(widget.maxRankings, (index) {
                    final rank = index + 1;
                    final isUnavailable = !widget.allowTies && 
                        _rankings.values.contains(rank) && 
                        currentRank != rank;
                    return _buildRankButton(
                      theme, 
                      rank, 
                      _getRankText(rank), 
                      option.value.toString(),
                      isUnavailable: isUnavailable,
                    );
                  }),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRankButton(
    ThemeData theme, 
    int rank, 
    String label, 
    String optionValue,
    {bool isUnavailable = false}
  ) {
    final isSelected = _getRanking(optionValue) == rank;
    
    return GestureDetector(
      onTap: isUnavailable ? null : () {
        _setRanking(optionValue, rank);
        Navigator.of(context).pop();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? _getRankColor(theme, rank)
              : isUnavailable
                  ? theme.colorScheme.surface.withValues(alpha: 0.5)
                  : theme.colorScheme.surface,
          border: Border.all(
            color: isSelected
                ? _getRankColor(theme, rank)
                : isUnavailable
                    ? theme.colorScheme.outline.withValues(alpha: 0.2)
                    : theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected
                ? Colors.white
                : isUnavailable
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                    : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
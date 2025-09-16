import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Represents a single item in the bucket with its properties
class BucketItem {
  final String type;
  final String icon;
  final Color color;
  Offset position;
  bool isFalling;
  double opacity;
  double rotation;
  final String id;

  BucketItem({
    required this.type,
    required this.icon,
    required this.color,
    required this.position,
    this.isFalling = false,
    this.opacity = 1.0,
    this.rotation = 0.0,
  }) : id = '${type}_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(1000)}';
}

/// Configuration for each nutrition type
class NutritionTypeConfig {
  final String type;
  final List<String> icons;
  final Color color;
  final String label;
  final int maxValue;

  const NutritionTypeConfig({
    required this.type,
    required this.icons,
    required this.color,
    required this.label,
    required this.maxValue,
  });

  static const Map<String, NutritionTypeConfig> configs = {
    'treats': NutritionTypeConfig(
      type: 'treats',
      icons: ['🍪', '🍬', '🧁', '🍩'],
      color: Color(0xFFFF6F61), // Coral
      label: 'Sweet Treats',
      maxValue: 15,
    ),
    'sodas': NutritionTypeConfig(
      type: 'sodas',
      icons: ['🥤', '🧋', '🥛'],
      color: Color(0xFFE9C46A), // Amber
      label: 'Sodas & Drinks',
      maxValue: 15,
    ),
    'grains': NutritionTypeConfig(
      type: 'grains',
      icons: ['🌾', '🍞', '🥖', '🥯'],
      color: Color(0xFF29AD8F), // Teal
      label: 'Grain Servings',
      maxValue: 15,
    ),
    'alcohol': NutritionTypeConfig(
      type: 'alcohol',
      icons: ['🍷', '🍺', '🍸', '🥃'],
      color: Color(0xFF8A4FD3), // Purple
      label: 'Alcohol (weekly)',
      maxValue: 20,
    ),
  };
}

/// A persistent bucket widget that accumulates items across nutrition questions
/// with wheel picker for selection and rain/fade animations
class PersistentBucketWidget extends StatefulWidget {
  final Map<String, int> allItems; // Current values for all nutrition types
  final String currentType; // Which type is being edited
  final int currentValue; // Current value for the active type
  final Function(int) onValueChanged;

  const PersistentBucketWidget({
    super.key,
    required this.allItems,
    required this.currentType,
    required this.currentValue,
    required this.onValueChanged,
  });

  @override
  State<PersistentBucketWidget> createState() => _PersistentBucketWidgetState();
}

class _PersistentBucketWidgetState extends State<PersistentBucketWidget>
    with TickerProviderStateMixin {
  
  final List<BucketItem> _bucketItems = [];
  final List<BucketItem> _fallingItems = [];
  
  late AnimationController _rainController;
  late AnimationController _fadeController;
  late AnimationController _bucketController;
  
  final GlobalKey _bucketKey = GlobalKey();
  Size _bucketSize = Size.zero;
  
  @override
  void initState() {
    super.initState();
    
    _rainController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _bucketController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeBucketItems();
    });
  }
  
  @override
  void didUpdateWidget(PersistentBucketWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Check if current type value changed
    if (oldWidget.currentValue != widget.currentValue) {
      _handleValueChange(oldWidget.currentValue, widget.currentValue);
    }
    
    // Check if other types changed (when navigating between questions)
    if (oldWidget.allItems != widget.allItems) {
      _updateAllItems();
    }
  }
  
  void _initializeBucketItems() {
    _bucketItems.clear();
    
    // Add items for all nutrition types based on current values
    widget.allItems.forEach((type, count) {
      final config = NutritionTypeConfig.configs[type];
      if (config != null && count > 0) {
        for (int i = 0; i < count; i++) {
          _bucketItems.add(_createBucketItem(type, config));
        }
      }
    });
    
    _arrangeBucketItems();
  }
  
  void _updateAllItems() {
    // Rebuild all items when navigating between questions
    _initializeBucketItems();
    setState(() {});
  }
  
  BucketItem _createBucketItem(String type, NutritionTypeConfig config) {
    final random = math.Random();
    final icon = config.icons[random.nextInt(config.icons.length)];
    
    return BucketItem(
      type: type,
      icon: icon,
      color: config.color,
      position: Offset.zero, // Will be positioned in _arrangeBucketItems
      rotation: random.nextDouble() * 360,
    );
  }
  
  void _arrangeBucketItems() {
    if (_bucketSize.width == 0 || _bucketSize.height == 0) {
      // Bucket size not available yet, try again after render
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final RenderBox? renderBox = _bucketKey.currentContext?.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          _bucketSize = renderBox.size;
          _arrangeBucketItems();
        }
      });
      return;
    }
    
    const itemSize = 30.0;
    const spacing = 4.0;
    final itemsPerRow = (_bucketSize.width / (itemSize + spacing)).floor();
    
    for (int i = 0; i < _bucketItems.length; i++) {
      final row = i ~/ itemsPerRow;
      final col = i % itemsPerRow;
      
      // Start from bottom of bucket and stack upward
      final x = col * (itemSize + spacing) + spacing;
      final y = _bucketSize.height - (row + 1) * (itemSize + spacing);
      
      _bucketItems[i].position = Offset(x, y);
    }
  }
  
  void _handleValueChange(int oldValue, int newValue) {
    final difference = newValue - oldValue;
    
    if (difference > 0) {
      // Value increased - rain animation
      _animateRain(difference);
    } else if (difference < 0) {
      // Value decreased - fade animation
      _animateFadeOut(-difference);
    }
  }
  
  void _animateRain(int itemsToAdd) {
    final config = NutritionTypeConfig.configs[widget.currentType]!;
    
    // Create falling items
    for (int i = 0; i < itemsToAdd; i++) {
      final item = _createBucketItem(widget.currentType, config);
      item.isFalling = true;
      item.position = _getRandomFallingStartPosition();
      _fallingItems.add(item);
      
      // Stagger the drops
      Future.delayed(Duration(milliseconds: i * 100), () {
        _dropItem(item);
      });
    }
  }
  
  void _animateFadeOut(int itemsToRemove) {
    // Find the most recent items of the current type and fade them out
    final currentTypeItems = _bucketItems
        .where((item) => item.type == widget.currentType)
        .toList();
    
    // Take the last N items (most recently added)
    final itemsToFade = currentTypeItems.take(itemsToRemove).toList();
    
    for (final item in itemsToFade) {
      item.opacity = 0.0;
      _bucketItems.remove(item);
    }
    
    _arrangeBucketItems();
    setState(() {});
  }
  
  Offset _getRandomFallingStartPosition() {
    final random = math.Random();
    final x = random.nextDouble() * (_bucketSize.width - 30);
    return Offset(x, -50); // Start above the visible area
  }
  
  void _dropItem(BucketItem item) async {
    // Animate the item falling into the bucket
    final targetPosition = _getNextBucketPosition();
    
    // Add to bucket items first
    _bucketItems.add(item);
    item.isFalling = false;
    item.position = targetPosition;
    
    // Remove from falling items
    _fallingItems.remove(item);
    
    // Trigger bucket shake animation
    _bucketController.forward().then((_) {
      _bucketController.reverse();
    });
    
    setState(() {});
  }
  
  Offset _getNextBucketPosition() {
    const itemSize = 30.0;
    const spacing = 4.0;
    final itemsPerRow = (_bucketSize.width / (itemSize + spacing)).floor();
    final itemCount = _bucketItems.length;
    
    final row = itemCount ~/ itemsPerRow;
    final col = itemCount % itemsPerRow;
    
    final x = col * (itemSize + spacing) + spacing;
    final y = _bucketSize.height - (row + 1) * (itemSize + spacing);
    
    return Offset(x, y);
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = NutritionTypeConfig.configs[widget.currentType]!;
    
    return Column(
      children: [
        // Falling zone
        SizedBox(
          height: 120,
          width: double.infinity,
          child: Stack(
            children: [
              // Falling items
              ..._fallingItems.map((item) => _buildFallingItem(item)),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Bucket container
        AnimatedBuilder(
          animation: _bucketController,
          builder: (context, child) {
            final shake = math.sin(_bucketController.value * math.pi * 2) * 2;
            return Transform.translate(
              offset: Offset(shake, 0),
              child: Container(
                key: _bucketKey,
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    width: 3,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Stack(
                  children: [
                    // Bucket items
                    ..._bucketItems.map((item) => _buildBucketItem(item)),
                    
                    // Empty state message
                    if (_bucketItems.isEmpty)
                      Center(
                        child: Text(
                          'Your habits will stack up here',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        
        const SizedBox(height: 20),
        
        // Current count and wheel picker
        _buildWheelPicker(config, theme),
      ],
    );
  }
  
  Widget _buildFallingItem(BucketItem item) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 800),
      curve: Curves.bounceOut,
      left: item.position.dx,
      top: item.position.dy,
      child: Transform.rotate(
        angle: item.rotation * math.pi / 180,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: item.color.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              item.icon,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildBucketItem(BucketItem item) {
    final isCurrentType = item.type == widget.currentType;
    
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      left: item.position.dx,
      top: item.position.dy,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: item.opacity,
        child: Transform.rotate(
          angle: item.rotation * math.pi / 180,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: isCurrentType ? 1.0 : 0.7),
              borderRadius: BorderRadius.circular(8),
              border: isCurrentType ? Border.all(
                color: Colors.white,
                width: 2,
              ) : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Center(
              child: Text(
                item.icon,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildWheelPicker(NutritionTypeConfig config, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surface,
      ),
      child: Column(
        children: [
          // Header showing current value
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: config.color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              '${widget.currentValue}',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: config.color,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // Wheel picker
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Selection indicator
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: config.color.withValues(alpha: 0.1),
                      border: Border.symmetric(
                        horizontal: BorderSide(
                          color: config.color.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  
                  // Wheel scroll view
                  ListWheelScrollView.useDelegate(
                    controller: FixedExtentScrollController(
                      initialItem: widget.currentValue,
                    ),
                    itemExtent: 40,
                    physics: const FixedExtentScrollPhysics(),
                    diameterRatio: 2.0,
                    perspective: 0.003,
                    onSelectedItemChanged: (index) {
                      widget.onValueChanged(index);
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      builder: (context, index) {
                        if (index < 0 || index > config.maxValue) return null;
                        final isSelected = index == widget.currentValue;
                        
                        return Container(
                          alignment: Alignment.center,
                          child: Text(
                            index.toString(),
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: isSelected 
                                  ? config.color
                                  : theme.colorScheme.onSurface,
                              fontWeight: isSelected 
                                  ? FontWeight.bold 
                                  : FontWeight.w500,
                              fontSize: isSelected ? 24 : 18,
                            ),
                          ),
                        );
                      },
                      childCount: config.maxValue + 1,
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
  
  @override
  void dispose() {
    _rainController.dispose();
    _fadeController.dispose();
    _bucketController.dispose();
    super.dispose();
  }
}
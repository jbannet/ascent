import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Temporary mapping tool to identify body part coordinates on gender-specific images
class TemporaryMappingTool extends StatefulWidget {
  const TemporaryMappingTool({super.key});

  @override
  State<TemporaryMappingTool> createState() => _TemporaryMappingToolState();
}

class _TemporaryMappingToolState extends State<TemporaryMappingTool> {
  String _selectedImage = 'man'; // 'man' or 'woman'
  final Map<String, List<TappedRegion>> _tappedRegions = {};
  String? _selectedBodyPart;
  final GlobalKey _imageKey = GlobalKey();
  
  // Standard body parts to map
  final List<String> _bodyParts = [
    'ankles',
    'feet',
    'shins',
    'wrists',
    'elbows',
    'knees',
    'abdominals',
    'hamstrings',
    'calves',
    'shoulders',
    'hips',
    'glutes',
    'quadriceps',
    'biceps',
    'forearms',
    'triceps',
    'chest',
    'lower back',
    'traps',
    'middle back',
    'lats',
    'neck',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Body Map Coordinate Mapper'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload),
            onPressed: _importCoordinates,
            tooltip: 'Import coordinates from clipboard',
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: _exportCoordinates,
            tooltip: 'Copy coordinates to clipboard',
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearAllRegions,
            tooltip: 'Clear all regions',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Use single column layout on narrow screens
          if (constraints.maxWidth < 800) {
            return _buildMobileLayout();
          }
          
          // Use row layout on wide screens
          return Row(
            children: [
              // Left panel - Controls
              SizedBox(
                width: 300, // Fixed width instead of flex
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    border: Border(
                      right: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  // Image selector
                  Text(
                    'Select Image',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ToggleButtons(
                    isSelected: [_selectedImage == 'man', _selectedImage == 'woman'],
                    onPressed: (index) {
                      setState(() {
                        _selectedImage = index == 0 ? 'man' : 'woman';
                        _clearAllRegions();
                      });
                    },
                    children: const [
                      Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Man')),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Woman')),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Body part selector
                  Text(
                    'Select Body Part to Map',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _bodyParts.length,
                      itemBuilder: (context, index) {
                        final part = _bodyParts[index];
                        final isMapped = _tappedRegions.containsKey(part);
                        final isSelected = _selectedBodyPart == part;
                        
                        return Card(
                          color: isSelected 
                              ? theme.colorScheme.primaryContainer
                              : isMapped 
                                  ? theme.colorScheme.secondaryContainer
                                  : null,
                          child: ListTile(
                            title: Text(_formatBodyPartName(part)),
                            subtitle: isMapped 
                                ? Text('${_tappedRegions[part]!.length} cells mapped')
                                : const Text('Not mapped'),
                            leading: Icon(
                              isMapped ? Icons.check_circle : Icons.circle_outlined,
                              color: isMapped ? Colors.green : null,
                            ),
                            trailing: isSelected ? const Icon(Icons.touch_app) : null,
                            onTap: () {
                              setState(() {
                                _selectedBodyPart = _selectedBodyPart == part ? null : part;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Instructions
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Instructions:',
                          style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text('1. Select a body part from the list'),
                        const Text('2. Tap on the image to map that part'),
                        const Text('3. Copy coordinates when done'),
                      ],
                    ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Right panel - Image with mapping
            Expanded(
              child: Container(
                color: Colors.grey[100],
                child: Center(
                  child: _buildImageMapper(),
                ),
              ),
            ),
          ]);
        },
      ),
    );
  }

  Widget _buildMobileLayout() {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // Top panel - Controls (collapsed)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            border: Border(
              bottom: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
            ),
          ),
          child: Row(
            children: [
              // Image selector
              ToggleButtons(
                isSelected: [_selectedImage == 'man', _selectedImage == 'woman'],
                onPressed: (index) {
                  setState(() {
                    _selectedImage = index == 0 ? 'man' : 'woman';
                    _clearAllRegions();
                  });
                },
                children: const [
                  Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Man')),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Woman')),
                ],
              ),
              
              const SizedBox(width: 16),
              
              // Current selection
              if (_selectedBodyPart != null)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Mapping: ${_formatBodyPartName(_selectedBodyPart!)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              
              const Spacer(),
              
              // Body part selector button
              FilledButton.icon(
                onPressed: () => _showBodyPartSelector(),
                icon: const Icon(Icons.list),
                label: const Text('Select'),
              ),
            ],
          ),
        ),
        
        // Image area
        Expanded(
          child: Container(
            color: Colors.grey[100],
            child: Center(
              child: _buildImageMapper(),
            ),
          ),
        ),
      ],
    );
  }

  void _showBodyPartSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Body Part to Map',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _bodyParts.length,
                itemBuilder: (context, index) {
                  final part = _bodyParts[index];
                  final isMapped = _tappedRegions.containsKey(part);
                  
                  return Card(
                    color: isMapped ? Colors.green.withValues(alpha: 0.2) : null,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedBodyPart = part;
                        });
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            Icon(
                              isMapped ? Icons.check_circle : Icons.circle_outlined,
                              color: isMapped ? Colors.green : null,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _formatBodyPartName(part),
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageMapper() {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(20),
        child: Stack(
          children: [
            // Image with overlay
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: _selectedBodyPart != null ? _handleImageTap : null,
              onTap: _selectedBodyPart != null ? () {} : null,
              child: Stack(
                children: [
                  Image.asset(
                    'assets/images/$_selectedImage.png',
                    key: _imageKey,
                    fit: BoxFit.contain,
                  ),
                  // Overlay showing tapped regions
                  ..._buildRegionOverlays(),
                ],
              ),
            ),
            
            // Selected body part indicator
            if (_selectedBodyPart != null)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Mapping: ${_formatBodyPartName(_selectedBodyPart!)}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRegionOverlays() {
    return [
      // Always show grid overlay - rebuilt on every state change
      Positioned.fill(
        child: IgnorePointer(
          child: CustomPaint(
            key: ValueKey(_tappedRegions.toString()), // Force rebuild when regions change
            painter: GridOverlayPainter(
              tappedRegions: _tappedRegions,
            ),
          ),
        ),
      ),
    ];
  }

  void _handleImageTap(TapDownDetails details) {
    
    if (_selectedBodyPart == null) {
      return;
    }
    
    final RenderBox? renderBox = _imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return;
    }
    
    final localPosition = renderBox.globalToLocal(details.globalPosition);
    final imageSize = renderBox.size;
    
    if (imageSize.width <= 0 || imageSize.height <= 0) {
      return;
    }
    
    // Calculate which grid cell was clicked
    final cellWidth = imageSize.width / 20; // gridCols = 20
    final cellHeight = imageSize.height / 30; // gridRows = 30
    final gridX = (localPosition.dx / cellWidth).floor();
    final gridY = (localPosition.dy / cellHeight).floor();
    
    // Convert grid coordinates back to center of cell percentages
    final cellCenterX = ((gridX + 0.5) * cellWidth / imageSize.width) * 100;
    final cellCenterY = ((gridY + 0.5) * cellHeight / imageSize.height) * 100;
    
    setState(() {
      // Check if this cell is already used by ANY body part
      String? existingBodyPart;
      for (final entry in _tappedRegions.entries) {
        for (final region in entry.value) {
          if (region.gridX == gridX && region.gridY == gridY) {
            existingBodyPart = entry.key;
            break;
          }
        }
        if (existingBodyPart != null) break;
      }
      
      if (existingBodyPart == _selectedBodyPart) {
        // Cell already selected for current body part, remove it (toggle off)
        _tappedRegions[_selectedBodyPart!]!.removeWhere(
          (region) => region.gridX == gridX && region.gridY == gridY
        );
        
        // Clean up empty lists
        if (_tappedRegions[_selectedBodyPart!]!.isEmpty) {
          _tappedRegions.remove(_selectedBodyPart!);
        }
      } else if (existingBodyPart != null) {
        // Cell belongs to different body part, move it to current selection
        _tappedRegions[existingBodyPart]!.removeWhere(
          (region) => region.gridX == gridX && region.gridY == gridY
        );
        
        // Clean up empty lists
        if (_tappedRegions[existingBodyPart]!.isEmpty) {
          _tappedRegions.remove(existingBodyPart);
        }
        
        // Add to current body part
        _tappedRegions[_selectedBodyPart!] ??= [];
        _tappedRegions[_selectedBodyPart!]!.add(TappedRegion(
          bodyPart: _selectedBodyPart!,
          xPercent: cellCenterX,
          yPercent: cellCenterY,
          gridX: gridX,
          gridY: gridY,
        ));
      } else {
        // New cell, add to current body part
        _tappedRegions[_selectedBodyPart!] ??= [];
        _tappedRegions[_selectedBodyPart!]!.add(TappedRegion(
          bodyPart: _selectedBodyPart!,
          xPercent: cellCenterX,
          yPercent: cellCenterY,
          gridX: gridX,
          gridY: gridY,
        ));
      }
    });
  }

  void _clearAllRegions() {
    setState(() {
      _tappedRegions.clear();
      _selectedBodyPart = null;
    });
  }

  void _importCoordinates() async {
    try {
      final clipboardData = await Clipboard.getData('text/plain');
      final text = clipboardData?.text?.trim();
      
      if (text == null || text.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Clipboard is empty or contains no text'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      
      // Parse the coordinate data
      final importedRegions = _parseCoordinateData(text);
      
      if (importedRegions.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No valid coordinate data found in clipboard'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Filter to only include body parts that exist in current list
      final filteredRegions = <String, List<TappedRegion>>{};
      final skippedParts = <String>[];
      int totalImported = 0;
      
      for (final entry in importedRegions.entries) {
        final bodyPart = entry.key;
        final regions = entry.value;
        
        if (_bodyParts.contains(bodyPart)) {
          filteredRegions[bodyPart] = regions;
          totalImported += regions.length;
        } else {
          skippedParts.add(bodyPart);
        }
      }

      setState(() {
        _tappedRegions.clear();
        _tappedRegions.addAll(filteredRegions);
      });

      if (mounted) {
        String message = 'Imported $totalImported cells for ${filteredRegions.length} body parts';
        if (skippedParts.isNotEmpty) {
          message += '\n\nSkipped (not in current list): ${skippedParts.join(', ')}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error importing coordinates: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Map<String, List<TappedRegion>> _parseCoordinateData(String text) {
    final regions = <String, List<TappedRegion>>{};
    
    try {
      // Look for body part definitions in the format:
      // 'bodypart': [
      //   BodyRegion(id: 'bodypart', xPercent: X, yPercent: Y, ...),
      // ],
      
      final bodyPartRegex = RegExp(r"'([^']+)':\s*\[([^\]]+)\]", multiLine: true, dotAll: true);
      final matches = bodyPartRegex.allMatches(text);
      
      for (final match in matches) {
        final bodyPart = match.group(1)!;
        final regionsText = match.group(2)!;
        
        // Parse individual BodyRegion entries
        final regionRegex = RegExp(
          r'BodyRegion\([^)]*xPercent:\s*([\d.]+)[^)]*yPercent:\s*([\d.]+)[^)]*\)',
          multiLine: true
        );
        final regionMatches = regionRegex.allMatches(regionsText);
        
        final bodyPartRegions = <TappedRegion>[];
        
        for (final regionMatch in regionMatches) {
          final xPercent = double.parse(regionMatch.group(1)!);
          final yPercent = double.parse(regionMatch.group(2)!);
          
          // Convert percentages back to grid coordinates (approximation)
          final gridX = ((xPercent / 100) * 20 - 0.5).round().clamp(0, 19);
          final gridY = ((yPercent / 100) * 30 - 0.5).round().clamp(0, 29);
          
          bodyPartRegions.add(TappedRegion(
            bodyPart: bodyPart,
            xPercent: xPercent,
            yPercent: yPercent,
            gridX: gridX,
            gridY: gridY,
          ));
        }
        
        if (bodyPartRegions.isNotEmpty) {
          regions[bodyPart] = bodyPartRegions;
        }
      }
      
    } catch (e) {
      // Parsing failed silently
    }
    
    return regions;
  }

  void _exportCoordinates() {
    if (_tappedRegions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No coordinates to export. Map some body parts first!')),
      );
      return;
    }

    final buffer = StringBuffer();
    buffer.writeln('// Body map coordinates for $_selectedImage');
    buffer.writeln("final ${_selectedImage}BodyRegions = <String, List<BodyRegion>>{");
    
    for (final entry in _tappedRegions.entries) {
      final bodyPart = entry.key;
      final regions = entry.value;
      
      buffer.writeln("  '$bodyPart': [");
      for (final region in regions) {
        buffer.writeln("    BodyRegion(");
        buffer.writeln("      id: '${region.bodyPart}',");
        buffer.writeln("      xPercent: ${region.xPercent.toStringAsFixed(2)},");
        buffer.writeln("      yPercent: ${region.yPercent.toStringAsFixed(2)},");
        buffer.writeln("      widthPercent: 5.0, // Single cell width");
        buffer.writeln("      heightPercent: 3.33, // Single cell height");
        buffer.writeln("    ),");
      }
      buffer.writeln("  ],");
    }
    
    buffer.writeln("};");
    buffer.writeln();
    buffer.writeln("// Usage example:");
    buffer.writeln("// final region = ${_selectedImage}BodyRegions['chest'];");
    buffer.writeln("// final rect = region?.toRect(imageSize);");

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Coordinates for ${_tappedRegions.length} body parts copied to clipboard!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _formatBodyPartName(String part) {
    return part.replaceAll('_', ' ').split(' ').map((word) {
      return word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '';
    }).join(' ');
  }
}

class TappedRegion {
  final String bodyPart;
  final double xPercent;
  final double yPercent;
  final int gridX;
  final int gridY;

  TappedRegion({
    required this.bodyPart,
    required this.xPercent,
    required this.yPercent,
    required this.gridX,
    required this.gridY,
  });
}

class BodyRegion {
  final String id;
  final double xPercent;
  final double yPercent;
  final double widthPercent;
  final double heightPercent;

  const BodyRegion({
    required this.id,
    required this.xPercent,
    required this.yPercent,
    required this.widthPercent,
    required this.heightPercent,
  });

  Rect toRect(Size imageSize) {
    return Rect.fromLTWH(
      imageSize.width * xPercent / 100,
      imageSize.height * yPercent / 100,
      imageSize.width * widthPercent / 100,
      imageSize.height * heightPercent / 100,
    );
  }
}

/// Custom painter for grid overlay showing clickable regions
class GridOverlayPainter extends CustomPainter {
  final Map<String, List<TappedRegion>> tappedRegions;
  
  // Grid configuration
  static const int gridCols = 20;
  static const int gridRows = 30;
  
  GridOverlayPainter({
    required this.tappedRegions,
  });

  @override
  void paint(Canvas canvas, Size size) {
    
    final cellWidth = size.width / gridCols;
    final cellHeight = size.height / gridRows;
    
    // Draw grid lines (more visible)
    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.6)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    
    // Draw vertical grid lines
    for (int i = 0; i <= gridCols; i++) {
      final x = i * cellWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    
    // Draw horizontal grid lines
    for (int i = 0; i <= gridRows; i++) {
      final y = i * cellHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    
    // Draw mapped regions as colored grid cells
    final regionPaint = Paint()..style = PaintingStyle.fill;
    
    // Draw each mapped cell for each body part
    for (final entry in tappedRegions.entries) {
      final bodyPart = entry.key;
      final regions = entry.value;
      final bodyPartColor = _getBodyPartColor(bodyPart);
      
      for (int i = 0; i < regions.length; i++) {
        final region = regions[i];
        final x = region.gridX;
        final y = region.gridY;
        
        if (x >= 0 && x < gridCols && y >= 0 && y < gridRows) {
          final cellRect = Rect.fromLTWH(
            x * cellWidth,
            y * cellHeight,
            cellWidth,
            cellHeight,
          );
          
          // Fill cell with body part color (more opaque for visibility)
          regionPaint.color = bodyPartColor.withValues(alpha: 0.7);
          canvas.drawRect(cellRect, regionPaint);
          
          // Draw border around the cell (same color as fill but darker)
          final borderPaint = Paint()
            ..color = bodyPartColor.withValues(alpha: 1.0)
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke;
          canvas.drawRect(cellRect, borderPaint);
          
          // Add a small label in every cell (not just first one)
          final textSpan = TextSpan(
            text: _getBodyPartShortName(bodyPart),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 6,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  offset: Offset(0.5, 0.5),
                  color: Colors.black,
                  blurRadius: 1.0,
                ),
              ],
            ),
          );
          final textPainter = TextPainter(
            text: textSpan,
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();
          
          final textX = cellRect.center.dx - textPainter.width / 2;
          final textY = cellRect.center.dy - textPainter.height / 2;
          textPainter.paint(canvas, Offset(textX, textY));
        }
      }
    }
  }
  
  Color _getBodyPartColor(String bodyPart) {
    // Assign different colors to different body parts for easy identification
    const colors = [
      Colors.red, Colors.blue, Colors.green, Colors.orange, 
      Colors.purple, Colors.teal, Colors.pink, Colors.amber,
      Colors.cyan, Colors.lime, Colors.indigo, Colors.brown,
      Colors.grey, Colors.yellow, Colors.lightBlue, Colors.lightGreen,
      Colors.deepOrange, Colors.deepPurple, Colors.blueGrey, Colors.redAccent,
    ];
    
    final index = bodyPart.hashCode.abs() % colors.length;
    return colors[index];
  }
  
  String _getBodyPartShortName(String bodyPart) {
    // Create short abbreviations for grid labels
    const Map<String, String> shortNames = {
      'ankles': 'AN',
      'feet': 'FT',
      'shins': 'SH',
      'wrists': 'WR',
      'elbows': 'EL',
      'knees': 'KN',
      'abdominals': 'AB',
      'hamstrings': 'HM',
      'calves': 'CA',
      'shoulders': 'SD',
      'hips': 'HP',
      'glutes': 'GL',
      'quadriceps': 'QU',
      'biceps': 'BI',
      'forearms': 'FA',
      'triceps': 'TR',
      'chest': 'CH',
      'lower back': 'LB',
      'traps': 'TP',
      'middle back': 'MB',
      'lats': 'LA',
      'neck': 'NK',
    };
    
    return shortNames[bodyPart] ?? bodyPart.substring(0, 2).toUpperCase();
  }

  @override
  bool shouldRepaint(covariant GridOverlayPainter oldDelegate) {
    final shouldRepaint = oldDelegate.tappedRegions.toString() != tappedRegions.toString();
    return shouldRepaint || oldDelegate.tappedRegions.length != tappedRegions.length;
  }
}
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_treemap/src/treemap.dart';

/// A widget that displays a **Treemap visualization**.
///
/// Each [Treemap] node is represented as a rectangle sized
/// proportionally to its `value`. The layout is generated using
/// a squarified treemap algorithm for readability.
class FlutterTreemap extends StatefulWidget {
  final List<Treemap> nodes;

  /// [minTileRatio] keep it between 0 and 1
  final double minTileRatio;
  final bool showLabel;
  final bool showValue;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final EdgeInsetsGeometry tilePadding;
  final BoxBorder? border;

  /// A wrapper around the built tile.
  /// This allows adding extra functionality (e.g., onTap, onHover).
  final Widget Function(
    BuildContext context,
    Widget child,
    Treemap node,
    int index,
    Rect rect,
  )?
  tileWrapper;

  /// Custom builder for rendering tiles.
  /// If null, a default text-based tile is created.
  final Widget Function(
    BuildContext context,
    Treemap node,
    int index,
    Rect rect,
  )?
  tileBuilder;

  const FlutterTreemap({
    super.key,
    required this.nodes,
    this.minTileRatio = 0.02,
    this.showLabel = true,
    this.showValue = true,
    this.labelStyle,
    this.valueStyle,
    this.tilePadding = const EdgeInsets.all(2),
    this.border,
    this.tileBuilder,
    this.tileWrapper,
  });

  @override
  State<FlutterTreemap> createState() => _FlutterTreemapState();
}

class _FlutterTreemapState extends State<FlutterTreemap> {
  /// Utility to measure text height for overflow checks.
  double _measureTextHeight(TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: "Np", style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.size.height;
  }

  double totalWeight = 0;

  @override
  Widget build(BuildContext context) {
    // Compute total weight dynamically on every build
    totalWeight = widget.nodes.fold(0.0, (sum, node) => sum + node.value);

    if (totalWeight == 0 || widget.nodes.isEmpty) {
      return const SizedBox.shrink(); // No nodes → show empty widget
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final rectangleMap = <Treemap, Rect>{};

        // Compute treemap layout on every build (hot-restart safe)
        _squarify(
          widget.nodes,
          Rect.fromLTWH(0, 0, constraints.maxWidth, constraints.maxHeight),
          rectangleMap,
        );

        // Build tiles
        return Stack(
          clipBehavior: Clip.hardEdge,
          children: widget.nodes.asMap().entries.map((entry) {
            final index = entry.key;
            final node = entry.value;
            final rect = rectangleMap[node];
            if (rect == null) return const SizedBox.shrink();

            final builtTile = _buildTile(node: node, rect: rect, index: index);

            return Positioned(
              left: rect.left,
              top: rect.top,
              width: rect.width,
              height: rect.height,
              child:
                  widget.tileWrapper?.call(
                    context,
                    builtTile,
                    node,
                    index,
                    rect,
                  ) ??
                  builtTile,
            );
          }).toList(),
        );
      },
    );
  }

  /// Recursive squarified treemap layout algorithm.
  ///
  /// Splits rectangles into sub-rectangles based on node weights,
  /// trying to keep aspect ratios as close to 1:1 as possible.
  void _squarify(
    List<Treemap> nodes,
    Rect rect,
    Map<Treemap, Rect> rectangleMap,
  ) {
    if (nodes.isEmpty || rect.width <= 0 || rect.height <= 0) return;

    // Base case: only one node → assign the entire rect
    if (nodes.length == 1) {
      rectangleMap[nodes.first] = rect;
      return;
    }

    final horizontal = (rect.width / rect.height) >= 1.0;

    // Sum of adjusted weights (ensuring min tile ratio)
    final sumWeights = nodes.fold(
      0.0,
      (sum, node) => sum + _adjustedWeight(node, rect),
    );

    // Find optimal split index
    int splitIndex = _findBestSplit(nodes, rect, sumWeights);

    // Split into two groups
    final firstGroup = nodes.sublist(0, splitIndex);
    final secondGroup = nodes.sublist(splitIndex);

    // Weight of first group
    final double firstWeight = firstGroup.fold(
      0.0,
      (sum, node) => sum + _adjustedWeight(node, rect),
    );

    final double ratio = firstWeight / sumWeights;

    // Split the current rectangle either horizontally or vertically
    Rect rect1, rect2;
    if (horizontal) {
      double splitWidth = rect.width * ratio;
      splitWidth = min(splitWidth, rect.width);
      rect1 = Rect.fromLTWH(rect.left, rect.top, splitWidth, rect.height);
      rect2 = Rect.fromLTWH(
        rect.left + splitWidth,
        rect.top,
        rect.width - splitWidth,
        rect.height,
      );
    } else {
      double splitHeight = rect.height * ratio;
      splitHeight = min(splitHeight, rect.height);
      rect1 = Rect.fromLTWH(rect.left, rect.top, rect.width, splitHeight);
      rect2 = Rect.fromLTWH(
        rect.left,
        rect.top + splitHeight,
        rect.width,
        rect.height - splitHeight,
      );
    }

    // Recurse into sub-rectangles
    _squarify(firstGroup, rect1, rectangleMap);
    _squarify(secondGroup, rect2, rectangleMap);
  }

  /// Returns adjusted weight for a node considering the minimum tile ratio.
  double _adjustedWeight(Treemap node, Rect rect) {
    double investVal = node.value.abs();
    double rectArea = rect.width * rect.height;
    if (rectArea == 0) return investVal;

    // Ensure node does not shrink below minimum ratio
    double minWeight = totalWeight * widget.minTileRatio;
    return max(investVal, minWeight);
  }

  /// Finds the best index to split the node list
  /// to minimize bad aspect ratios.
  int _findBestSplit(List<Treemap> nodes, Rect rect, double sumWeights) {
    if (nodes.length <= 2) return 1;

    final horizontal = (rect.width / rect.height) >= 1.0;
    int bestIndex = 1;
    double bestAspect = double.infinity;

    for (int i = 1; i < nodes.length; i++) {
      final firstGroup = nodes.sublist(0, i);
      final secondGroup = nodes.sublist(i);

      final firstWeight = firstGroup.fold(
        0.0,
        (sum, node) => sum + _adjustedWeight(node, rect),
      );
      final secondWeight = secondGroup.fold(
        0.0,
        (sum, node) => sum + _adjustedWeight(node, rect),
      );

      double splitDimension = horizontal
          ? rect.width * (firstWeight / sumWeights)
          : rect.height * (firstWeight / sumWeights);

      // Skip invalid splits
      if (splitDimension < 0) continue;
      if ((rect.width - splitDimension) < 0 &&
          (rect.height - splitDimension) < 0) {
        continue;
      }

      // Evaluate aspect ratios
      final aspect1 = _aspectRatio(firstWeight, rect, sumWeights, horizontal);
      final aspect2 = _aspectRatio(secondWeight, rect, sumWeights, horizontal);
      final worstAspect = max(aspect1, aspect2);

      // Apply slight penalty for uneven splits
      double penalty = horizontal
          ? (i / nodes.length)
          : ((nodes.length - i) / nodes.length);
      final adjustedAspect = worstAspect * (1 + penalty * 0.5);

      if (adjustedAspect < bestAspect) {
        bestAspect = adjustedAspect;
        bestIndex = i;
      }
    }

    return bestIndex;
  }

  /// Computes aspect ratio of a group’s rectangle relative to treemap.
  double _aspectRatio(
    double groupWeight,
    Rect rect,
    double totalWeight,
    bool horizontal,
  ) {
    if (groupWeight == 0 || totalWeight == 0) return double.infinity;

    final areaRatio = groupWeight / totalWeight;
    double length = horizontal
        ? rect.width * areaRatio
        : rect.height * areaRatio;
    double breadth = horizontal ? rect.height : rect.width;

    if (length == 0 || breadth == 0) return double.infinity;

    double aspect = max(length / breadth, breadth / length);

    // Penalize extreme aspect ratios more heavily
    return aspect * (aspect > 2 ? 1.5 : 1.0);
  }

  /// Builds a single treemap tile.
  ///
  /// If [tileBuilder] is provided, it is used. Otherwise, a
  /// default container with label and value text is drawn.
  Widget _buildTile({
    required Treemap node,
    required Rect rect,
    required int index,
  }) {
    if (widget.tileBuilder != null) {
      return Container(
        width: rect.width,
        height: rect.height,
        decoration: BoxDecoration(color: node.color, border: widget.border),
        padding: widget.tilePadding,
        alignment: Alignment.center,
        child: FittedBox(
          child: widget.tileBuilder!(context, node, index, rect),
        ),
      );
    }

    return Container(
      width: rect.width,
      height: rect.height,
      decoration: BoxDecoration(color: node.color, border: widget.border),
      padding: widget.tilePadding,
      alignment: Alignment.center,
      child: FittedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showLabel && (node.label != null))
              Text(
                node.label!,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style:
                    widget.labelStyle ??
                    TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
              ),
            if (widget.showValue)
              Text(
                node.value.toString(),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style:
                    widget.valueStyle ??
                    TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.2,
                    ),
              ),
          ],
        ),
      ),
    );
  }
}

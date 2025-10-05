import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_treemap/src/treemap.dart';

class FlutterTreemap extends StatefulWidget {
  final List<Treemap> nodes;
  final double minTileRatio;
  final bool showLabel;
  final bool showValue;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final EdgeInsetsGeometry tilePadding;
  final Function(int index)? onTap;
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
    this.onTap,
    this.minTileRatio = 0.02,
    this.showLabel = true,
    this.showValue = true,
    this.labelStyle,
    this.valueStyle,
    this.tilePadding = const EdgeInsets.all(2),
    this.tileBuilder,
  });

  @override
  State<FlutterTreemap> createState() => _FlutterTreemapState();
}

class _FlutterTreemapState extends State<FlutterTreemap> {
  double totalWeight = 0;
  bool addListenerAdded = false;

  @override
  void initState() {
    totalWeight = widget.nodes.fold(0.0, (sum, node) {
      return sum + node.value;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (totalWeight == 0 || widget.nodes.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        Map<Treemap, Rect> rectangleMap = {};
        _squarify(
          widget.nodes,
          Rect.fromLTWH(0, 0, constraints.maxWidth, constraints.maxHeight),
          rectangleMap,
        );

        return Stack(
          clipBehavior: Clip.hardEdge,
          children: widget.nodes
              .map((node) {
                final rect = rectangleMap[node];
                if (rect == null) return null;
                return Positioned(
                  left: rect.left,
                  top: rect.top,
                  width: rect.width,
                  height: rect.height,
                  child: GestureDetector(
                    onTap: () => widget.onTap?.call(widget.nodes.indexOf(node)),
                    child: _buildTile(
                      node: node,
                      rect: rect,
                      index: widget.nodes.indexOf(node),
                    ),
                  ),
                );
              })
              .whereType<Widget>()
              .toList(),
        );
      },
    );
  }

  void _squarify(
    List<Treemap> nodes,
    Rect rect,
    Map<Treemap, Rect> rectangleMap,
  ) {
    if (nodes.isEmpty || rect.width <= 0 || rect.height <= 0) return;

    if (nodes.length == 1) {
      rectangleMap[nodes.first] = Rect.fromLTWH(
        rect.left,
        rect.top,
        rect.width,
        rect.height,
      );
      return;
    }

    final horizontal = (rect.width / rect.height) >= 1.0;
    final sumWeights = nodes.fold(
      0.0,
      (sum, node) => sum + _adjustedWeight(node, rect),
    );
    int splitIndex = _findBestSplit(nodes, rect, sumWeights);

    final firstGroup = nodes.sublist(0, splitIndex);
    final secondGroup = nodes.sublist(splitIndex);
    final double firstWeight = firstGroup.fold(
      0.0,
      (sum, node) => sum + _adjustedWeight(node, rect),
    );
    final double ratio = firstWeight / sumWeights;

    Rect rect1, rect2;
    double splitDimension;
    if (horizontal) {
      splitDimension = rect.width * ratio;
      splitDimension = min(splitDimension, rect.width);
      splitDimension = min(splitDimension, rect.width);
      rect1 = Rect.fromLTWH(rect.left, rect.top, splitDimension, rect.height);
      rect2 = Rect.fromLTWH(
        rect.left + splitDimension,
        rect.top,
        rect.width - splitDimension,
        rect.height,
      );
    } else {
      splitDimension = rect.height * ratio;
      splitDimension = min(splitDimension, rect.height);
      splitDimension = min(splitDimension, rect.height);
      rect1 = Rect.fromLTWH(rect.left, rect.top, rect.width, splitDimension);
      rect2 = Rect.fromLTWH(
        rect.left,
        rect.top + splitDimension,
        rect.width,
        rect.height - splitDimension,
      );
    }

    _squarify(firstGroup, rect1, rectangleMap);
    _squarify(secondGroup, rect2, rectangleMap);
  }

  double _adjustedWeight(Treemap node, Rect rect) {
    double investVal = node.value;
    double rectArea = rect.width * rect.height;
    if (rectArea == 0) return investVal;
    double minWeight = totalWeight * widget.minTileRatio;
    return max(investVal, minWeight);
  }

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
      if (splitDimension < 0) {
        continue;
      }
      if ((rect.width - splitDimension) < 0 &&
          (rect.height - splitDimension) < 0) {
        continue;
      }

      final aspect1 = _aspectRatio(firstWeight, rect, sumWeights, horizontal);
      final aspect2 = _aspectRatio(secondWeight, rect, sumWeights, horizontal);
      final worstAspect = max(aspect1, aspect2);

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
    return aspect * (aspect > 2 ? 1.5 : 1.0);
  }

  Widget _buildTile({
    required Treemap node,
    required Rect rect,
    required int index,
  }) {
    if (widget.tileBuilder != null) {
      return widget.tileBuilder!(context, node, index, rect);
    }
    double fontSize = min(rect.width, rect.height) * 0.3;
    fontSize = fontSize.clamp(6, 16);

    Size measureTextSize(
      TextStyle style, {
      int maxLines = 1,
      double maxWidth = double.infinity,
    }) {
      final TextPainter textPainter = TextPainter(
        text: TextSpan(text: "Np", style: style),
        maxLines: maxLines,
        textDirection: TextDirection.ltr,
      )..layout(minWidth: 0, maxWidth: maxWidth);

      return textPainter.size;
    }

    double labelHeight = measureTextSize(
      widget.labelStyle ??
          TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
    ).height;
    double valueHeight = measureTextSize(
      widget.valueStyle ??
          TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w400,
            height: 1.2,
          ),
    ).height;
    return Container(
      width: rect.width,
      height: rect.height,
      decoration: BoxDecoration(
        color: node.color,
        border: Border.all(color: Colors.white),
      ),
      padding: widget.tilePadding,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showLabel &&
              (node.label != null) &&
              (labelHeight < (rect.height - widget.tilePadding.vertical)))
            Text(
              node.label!,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style:
                  widget.labelStyle ??
                  TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
            ),
          if (widget.showValue &&
              ((labelHeight + valueHeight) <
                  (rect.height - widget.tilePadding.vertical)))
            Text(
              node.value.toString(),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style:
                  widget.valueStyle ??
                  TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                  ),
            ),
        ],
      ),
    );
  }
}

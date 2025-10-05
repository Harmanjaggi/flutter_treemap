# Flutter Treemap

A Flutter widget for creating beautiful and interactive treemap visualizations. Treemaps display hierarchical data as a set of nested rectangles, where the area of each rectangle is proportional to its value.

This package uses a squarified algorithm to generate layouts with optimal aspect ratios, making the chart easy to read and visually appealing.

## Features

- Proportional Sizing: Rectangle sizes are directly proportional to their data values.
- Squarified Layout: Generates a layout with rectangles that are as close to square as possible for better readability.
- Highly Customizable:
 - Control the visibility and style of labels and values.
 - Add padding and borders to individual tiles.
- Custom Tile Builders: Use the tileBuilder for complete control over the appearance of each tile.
- Interactive Wrappers: Use the tileWrapper to add gestures (onTap, onHover), Tooltips, or any other wrapping widget to the tiles.

## Getting Started

### Installation
Add this to your package's `pubspec.yaml` file:
```YAML
dependencies:
  flutter_treemap: ^1.0.0
```

Then, install the package from your terminal:

```SHELL
flutter pub get
```

### Import the package
Now, import the package in your Dart code:
```DART
import 'package:flutter_treemap/flutter_treemap.dart';
```

## Usage

###Basic Example
To create a simple treemap, provide a list of `Treemap` objects to the `FlutterTreemap` widget. Each `Treemap` object must have a `value` (which determines its size) and a `title`.
```Dart
import 'package:flutter/material.dart';
import 'package:flutter_treemap/flutter_treemap.dart';

class SimpleTreemap extends StatelessWidget {
  const SimpleTreemap({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Treemap> nodes = [
      Treemap(value: 50, label: 'Node 1'),
      Treemap(value: 40, label: 'Node 2'),
      Treemap(value: 30, label: 'Node 3'),
      Treemap(value: 20, label: 'Node 4'),
      Treemap(value: 20, label: 'Node 5'),
      Treemap(value: 11, label: 'Node 6'),
      Treemap(value: 10, label: 'Node 7'),
      Treemap(value: 5, label: 'Node 8'),
      Treemap(value: 1, label: 'Node 9'),
    ];

    return Scaffold(
      appBar: AppBar(title: Text('Basic Treemap')),
      body: FlutterTreemap(
        nodes: nodes,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }
}
```

## Customization

You can easily customize the treemap's appearance and add interactivity.

### Interactive Tiles and Custom Content

Use the tileWrapper to make tiles interactive (e.g., show a tooltip or handle taps) and the tileBuilder to define custom content for each tile.

```Dart
import 'package:flutter/material.dart';
import 'package:flutter_treemap/flutter_treemap.dart';

class CustomizedTreemap extends StatelessWidget {
  const CustomizedTreemap({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Treemap> nodes = [
      Treemap(value: 50, label: 'Reports'),
      Treemap(value: 40, label: 'Sales'),
      Treemap(value: 30, label: 'Marketing'),
      Treemap(value: 20, label: 'Analytics'),
      Treemap(value: 20, label: 'R&D'),
    ];

    return Scaffold(
      appBar: AppBar(title: Text('Customized Treemap')),
      body: FlutterTreemap(
        nodes: nodes,
        border: Border.all(color: Colors.white, width: 2),
        // Wrap each tile with a Tooltip
        tileWrapper: (context, child, node, index, rect) {
          return Tooltip(
            message: '${node.label}\nValue: ${node.value}',
            child: GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Tapped on ${node.label}')),
              ),
              child: child,
            ),
          );
        },
        // Custom builder to render tile content
        tileBuilder: (context, node, index, rect) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                node.label ?? '',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                '${node.value.toInt()}',
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
```

## API Reference

### `FlutterTreemap` Widget
| Property       | Type                | Description                                                                          |
| :------------- | :------------------ | :----------------------------------------------------------------------------------- |
| `nodes`        | `List<Treemap>`     | **Required**. The list of data nodes to display.                                     |
| `minTileRatio` | `double`            | Minimum area a tile can occupy as a percentage of the total. Defaults to `0.02`.     |
| `showLabel`    | `bool`              | Whether to display the default label on the tile. Defaults to `true`.                |
| `showValue`    | `bool`              | Whether to display the default value on the tile. Defaults to `true`.                |
| `labelStyle`   | `TextStyle?`        | The text style for the default tile labels.                                          |
| `valueStyle`   | `TextStyle?`        | The text style for the default tile values.                                          |
| `tilePadding`  | `EdgeInsetsGeometry`| Padding applied inside each tile. Defaults to `EdgeInsets.all(2)`.                   |
| `border`       | `BoxBorder?`        | A border to draw around each tile.                                                   |
| `tileBuilder`  | `Function?`         | A custom builder `(context, node, index, rect)` for rendering a tile. Overrides the default. |
| `tileWrapper`  | `Function?`         | A wrapper `(context, child, node, index, rect)` for the tile, useful for gesture detection. |

### `Treemap` Class

| Property | Type      | Description                                                                     |
| :------- | :-------- | :------------------------------------------------------------------------------ |
| `value`  | `double`  | **Required**. The value that determines the area of the tile.                   |
| `label`  | `String?` | The label to be displayed on the tile.                                          |
| `color`  | `Color`   | The background color of the tile. A random light color is used if not provided. |



## Contributing

Contributions are welcome! If you find any bugs or have feature requests, please file them at the [issue tracker].

[issue tracker]: https://github.com/Harmanjaggi/flutter_treemap/issues

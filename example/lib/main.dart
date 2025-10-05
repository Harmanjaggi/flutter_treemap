import 'package:flutter/material.dart';
import 'package:flutter_treemap/flutter_treemap.dart';

void main() {
  runApp(const MyApp());
}

/// Root widget of the example application.
///
/// This sets up the basic [MaterialApp] and launches [MyHomePage].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Treemap Example',
      debugShowCheckedModeBanner: false, // Removes the "debug" banner
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Treemap'),
    );
  }
}

/// Example home page demonstrating how to use [FlutterTreemap].
class MyHomePage extends StatelessWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    /// Example dataset for the treemap.
    ///
    /// Each [Treemap] represents a node with a `value` (area)
    /// and an optional `label` (displayed inside the tile).
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
      appBar: AppBar(
        title: Text(title), // Top bar with page title
      ),
      body: SingleChildScrollView(
        // Scrollable column in case content overflows
        child: Column(
          children: [
            // ---------------------------------------------------
            // Basic Example: Simple treemap with border
            // ---------------------------------------------------
            SizedBox(
              height: 400, // Fixed height for treemap
              child: FlutterTreemap(
                nodes: nodes, // Pass dataset
                border: Border.all(
                  color: Colors.white,
                ), // Optional border around tiles
              ),
            ),

            // Section heading for the second example
            Text(
              "Customized Tiles",
              style: Theme.of(context).textTheme.headlineSmall,
            ),

            // ---------------------------------------------------
            // Advanced Example: Custom tile builder & tooltip
            // ---------------------------------------------------
            SizedBox(
              height: 400,
              child: FlutterTreemap(
                nodes: nodes,
                border: Border.all(color: Colors.white),

                // [tileWrapper] allows wrapping each tile with custom widgets.
                // Here we add a tooltip showing the node label & value.
                tileWrapper: (context, child, node, index, rect) {
                  return Tooltip(
                    message: '${node.label}\nValue: ${node.value}',
                    child: child,
                  );
                },

                // [tileBuilder] lets you override the default tile content.
                // In this example, only the label is shown with custom text style.
                tileBuilder: (context, node, index, rect) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        node.label ?? '',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

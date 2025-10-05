import 'package:flutter/material.dart';
import 'package:flutter_treemap/flutter_treemap.dart';

void main() {
  runApp(const MyApp());
}

/// Root widget of the application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false, // Remove debug banner
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Treemap'), // Home screen
    );
  }
}

/// Home page showing examples of FlutterTreemap usage.
class MyHomePage extends StatelessWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    // Sample data nodes for the treemap
    List<Treemap> nodes = [
      Treemap(value: 20, label: 'Node 1'),
      Treemap(value: 1, label: 'Node 2'),
      Treemap(value: 50, label: 'Node 3'),
      Treemap(value: 30, label: 'Node 4'),
      Treemap(value: 11, label: 'Node 5'),
      Treemap(value: 20, label: 'Node 6'),
      Treemap(value: 10, label: 'Node 7'),
      Treemap(value: 5, label: 'Node 8'),
      Treemap(value: 40, label: 'Node 9'),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(title)), // Top app bar with title
      body: SingleChildScrollView(
        // Allow scrolling if content is larger than screen
        child: Column(
          children: [
            // Simple treemap example
            SizedBox(
              height: 400, // Fixed height for treemap
              child: FlutterTreemap(
                nodes: nodes, // Pass data
                border: Border.all(
                  color: Colors.white,
                ), // Optional border around tiles
              ),
            ),
            // Heading for customized treemap section
            Text(
              "Customized Tiles",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            // Treemap with custom tile builder and tooltip
            SizedBox(
              height: 400,
              child: FlutterTreemap(
                nodes: nodes,
                border: Border.all(color: Colors.white),
                // Wrap each tile with a Tooltip showing label and value
                tileWrapper: (context, child, node, index, rect) {
                  return Tooltip(
                    message: '${node.label}\nValue: ${node.value}',
                    child: child,
                  );
                },
                // Custom tile builder to override default tile content
                tileBuilder: (context, node, index, rect) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Only show node label in custom style
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

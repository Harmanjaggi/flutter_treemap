import 'package:flutter/material.dart';
import 'package:flutter_treemap/flutter_treemap.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Treemap'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    List<Treemap> nodes = [
      Treemap(value: 20, title: 'Node 1'),
      Treemap(value: 1, title: 'Node 2'),
      Treemap(value: 50, title: 'Node 3'),
      Treemap(value: 30, title: 'Node 4'),
      Treemap(value: 11, title: 'Node 5'),
      Treemap(value: 20, title: 'Node 6'),
      Treemap(value: 10, title: 'Node 7'),
      Treemap(value: 5, title: 'Node 8'),
      Treemap(value: 40, title: 'Node 9'),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: FlutterTreemap(nodes: nodes, minTileRatio: 0.02),
    );
  }
}

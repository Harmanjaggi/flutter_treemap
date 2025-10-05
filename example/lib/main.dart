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
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 400,
              child: FlutterTreemap(
                nodes: nodes,
                border: Border.all(color: Colors.white),
              ),
            ),
            Text(
              "Customized Tiles",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(
              height: 400,
              child: FlutterTreemap(
                nodes: nodes,
                border: Border.all(color: Colors.white),
                tileWrapper: (context, child, node, index, rect) {
                  return Tooltip(
                    message: '${node.label}\nValue: ${node.value}',
                    child: child,
                  );
                },
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

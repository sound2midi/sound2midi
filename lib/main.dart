import 'package:flutter/material.dart';
import 'package:record/record.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sound Detection',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Sound Detection'),
        ),
        body: const Center(child: Text('Press the button below!')),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Add your onPressed code here!
          },
          backgroundColor: Colors.green,
          child: const Icon(Icons.mic),
        ),
      ),
    );
  }
}
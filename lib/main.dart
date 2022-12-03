import 'package:flutter/material.dart';
import 'package:record/record.dart';

class ListItem extends StatelessWidget {
  const ListItem({super.key});

  @override
  Widget build(BuildContext context) {

    final titles = ["Song 1", "Song 2", "Song 3", "Song 4", "Song 5", "Song 6", "Song7"];

    final icons = Icons.graphic_eq;

    return ListView.builder(
      itemCount: titles.length,
      itemBuilder: (context, index) {
        return Card( //                           <-- Card widget
          child: ListTile(
            leading: Icon(icons),
            title: Text(titles[index]),
          ),
        );
      },
    );
  }
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
        body:
            ListItem(),

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

void main() {
  runApp(
    const MaterialApp(
      title: 'My app', // used by the OS task switcher
      home: SafeArea(
        child: MyApp(),
      ),
    ),
  );
}
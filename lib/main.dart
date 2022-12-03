import 'package:flutter/material.dart';
import 'package:record/record.dart';

class ListItem extends StatelessWidget {
  const ListItem({super.key});

  @override
  Widget build(BuildContext context) {

    final titles = ['bike', 'boat', 'bus', 'car',
      'railway', 'run', 'subway', 'transit', 'walk'];

    final icons = [Icons.directions_bike, Icons.directions_boat,
      Icons.directions_bus, Icons.directions_car, Icons.directions_railway,
      Icons.directions_run, Icons.directions_subway, Icons.directions_transit,
      Icons.directions_walk];

    return ListView.builder(
      itemCount: titles.length,
      itemBuilder: (context, index) {
        return Card( //                           <-- Card widget
          child: ListTile(
            leading: Icon(icons[index]),
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
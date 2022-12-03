import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fftea/fftea.dart';
import 'package:android_path_provider/android_path_provider.dart';
import 'package:wav/wav.dart';
import 'dart:math';
import 'dart:core';

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

void read_file() async {
  var documentsPath = await AndroidPathProvider.documentsPath;
   final wav = await Wav.readFile("$documentsPath/sound4.wav");
   final sound2 = wav.channels.first;

  List<double> audio = sound2;

  final fft = FFT(audio.length);
  final spectrum = fft.realFft(audio).toRealArray();

  final maxFreq = spectrum.indexOf(spectrum.sublist(0, 20000).reduce(max));
  print("frequency $maxFreq ... ${fft.frequency(maxFreq, 48000)}");
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
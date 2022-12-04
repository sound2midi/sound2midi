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
            read_file();
          },
          backgroundColor: Colors.green,
          child: const Icon(Icons.mic),
        ),
      ),
    );
  }
}

void read_file() async {
  const notes = {
    4186: "C8",
    3951: "B7",
    3729: "A♯7/B♭7",
    3520: "A7",
    3322: "G♯7/A♭7",
    3135: "G7",
    2959: "F♯7/G♭7",
    2793: "F7",
    2637: "E7",
    2489: "D♯7/E♭7",
    2349: "D7",
    2217: "C♯7/D♭7",
    2093: "C7",
    1975: "B6",
    1864: "A♯6/B♭6",
    1760: "A6",
    1661: "G♯6/A♭6",
    1567: "G6",
    1479: "F♯6/G♭6",
    1396: "F6",
    1318: "E6",
    1244: "D♯6/E♭6",
    1174: "D6",
    1108: "C♯6/D♭6",
    1046: "C6",
    987: "B5",
    932: "A♯5/B♭5",
    880: "A5",
    830: "G♯5/A♭5",
    783: "G5",
    739: "F♯5/G♭5",
    698: "F5",
    659: "E5",
    622: "D♯5/E♭5",
    587: "D5",
    554: "C♯5/D♭5",
    523: "C5",
    493: "B4",
    466: "A♯4/B♭4",
    415: "G♯4/A♭4",
    369: "F♯4/G♭4",
    349: "F4",
    329: "E4",
    311: "D♯4/E♭4",
    293: "D4",
    277: "C♯4/D♭4",
    261: "C4",
    233: "A♯3/B♭3",
    207: "G♯3/A♭3",
    195: "G3",
    184: "F♯3/G♭3",
    155: "D♯3/E♭3",
    146: "D3",
    138: "C♯3/D♭3",
    130: "C3",
    116: "A♯2/B♭2",
    103: "G♯2/A♭2",
    92: "F♯2/G♭2",
    87: "F2",
    82: "E2",
    77: "D♯2/E♭2",
    73: "D2",
    65: "C2",
    61: "B1",
    58: "A♯1/B♭1",
    51: "G♯1/A♭1",
    46: "F♯1/G♭1",
    38: "D♯1/E♭1",
    34: "C♯1/D♭1",
    32: "C1",
    30: "B0",
    27: "A0"
  };

  var documentsPath = await AndroidPathProvider.documentsPath;
  final wav = await Wav.readFile("$documentsPath/sound2.wav");
  final sound2 = wav.channels.first;

  List<double> audio = sound2;

  final fft = FFT(audio.length);
  final spectrum = fft.realFft(audio).toRealArray();

  final maxFreq = spectrum.indexOf(spectrum.sublist(0, 20000).reduce(max));
  final freq = fft.frequency(maxFreq, 48000);

  print(freq);

  var minDiff = 10000000.0;
  var noteName = "";
  for (var i in notes.entries) {
    var curDiff = (i.key - freq).abs();
    if (curDiff < minDiff) {
      minDiff = curDiff;
      noteName = i.value;
    };
  }
  print(noteName);

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
import 'dart:core';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import "package:flutter/widgets.dart";
import 'package:fftea/fftea.dart';
import 'package:android_path_provider/android_path_provider.dart';
import 'package:wav/wav.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:record/record.dart';
import 'dart:math';
import 'dart:core';
import 'dart:async';

void main() => runApp(const MyApp());

class AudioRecorder extends StatefulWidget {
  final void Function(String path) onStop;

  const AudioRecorder({Key? key, required this.onStop}) : super(key: key);

  @override
  _AudioRecorderState createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  int _recordDuration = 0;
  Timer? _timer;
  final _audioRecorder = Record();
  StreamSubscription<RecordState>? _recordSub;
  RecordState _recordState = RecordState.stop;
  StreamSubscription<Amplitude>? _amplitudeSub;
  Amplitude? _amplitude;

  @override
  void initState() {
    _recordSub = _audioRecorder.onStateChanged().listen((recordState) {
      setState(() => _recordState = recordState);
    });

    _amplitudeSub = _audioRecorder
        .onAmplitudeChanged(const Duration(milliseconds: 300))
        .listen((amp) => setState(() => _amplitude = amp));

    super.initState();
  }

  Future<void> _start() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        // We don't do anything with this but printing
        final isSupported = await _audioRecorder.isEncoderSupported(
          AudioEncoder.aacLc,
        );
        if (kDebugMode) {
          print('${AudioEncoder.aacLc.name} supported: $isSupported');
        }

        // final devs = await _audioRecorder.listInputDevices();
        // final isRecording = await _audioRecorder.isRecording();

        await _audioRecorder.start(
          encoder: AudioEncoder.wav,
        );

        _recordDuration = 0;

        _startTimer();
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> _stop() async {
    _timer?.cancel();
    _recordDuration = 0;

    final path = await _audioRecorder.stop();

    if (path != null) {
      widget.onStop(path);
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const SecondPage(title: 'Analyzing');
    }));

    final freq = await read_file(path!);

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ResultPage(data: freq);
    }));
  }

  Future<void> _pause() async {
    _timer?.cancel();
    await _audioRecorder.pause();
  }

  Future<void> _resume() async {
    _startTimer();
    await _audioRecorder.resume();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildRecordStopControl(),
              const SizedBox(width: 20),
              _buildPauseResumeControl(),
              const SizedBox(width: 20),
              _buildText(),
            ],
          ),
          if (_amplitude != null) ...[
            const SizedBox(height: 40),
            Text('Current: ${_amplitude?.current ?? 0.0}'),
            Text('Max: ${_amplitude?.max ?? 0.0}'),
          ],
          TextButton(child: Text("abc"), onPressed: () {}),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recordSub?.cancel();
    _amplitudeSub?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  Widget _buildRecordStopControl() {
    late Icon icon;
    late Color color;

    if (_recordState != RecordState.stop) {
      icon = const Icon(Icons.stop, color: Colors.red, size: 30);
      color = Colors.red.withOpacity(0.1);
    } else {
      final theme = Theme.of(context);
      icon = Icon(Icons.mic, color: theme.primaryColor, size: 30);
      color = theme.primaryColor.withOpacity(0.1);
    }

    return ClipOval(
      child: Material(
        color: color,
        child: InkWell(
          child: SizedBox(width: 56, height: 56, child: icon),
          onTap: () {
            (_recordState != RecordState.stop) ? _stop() : _start();
          },
        ),
      ),
    );
  }

  Widget _buildPauseResumeControl() {
    if (_recordState == RecordState.stop) {
      return const SizedBox.shrink();
    }

    late Icon icon;
    late Color color;

    if (_recordState == RecordState.record) {
      icon = const Icon(Icons.pause, color: Colors.red, size: 30);
      color = Colors.red.withOpacity(0.1);
    } else {
      final theme = Theme.of(context);
      icon = const Icon(Icons.play_arrow, color: Colors.red, size: 30);
      color = theme.primaryColor.withOpacity(0.1);
    }

    return ClipOval(
      child: Material(
        color: color,
        child: InkWell(
          child: SizedBox(width: 56, height: 56, child: icon),
          onTap: () {
            (_recordState == RecordState.pause) ? _resume() : _pause();
          },
        ),
      ),
    );
  }

  Widget _buildText() {
    if (_recordState != RecordState.stop) {
      return _buildTimer();
    }

    return const Text("Waiting to record");
  }

  Widget _buildTimer() {
    final String minutes = _formatNumber(_recordDuration ~/ 60);
    final String seconds = _formatNumber(_recordDuration % 60);

    return Text(
      '$minutes : $seconds',
      style: const TextStyle(color: Colors.red),
    );
  }

  String _formatNumber(int number) {
    String numberStr = number.toString();
    if (number < 10) {
      numberStr = '0' + numberStr;
    }

    return numberStr;
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => _recordDuration++);
    });
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: AudioRecorder(
            onStop: (path) {
              if (kDebugMode) print('Recorded file path: $path');
            },
          ),
        ),
      ),
    );
  }
//@override
//_MyAppState createState() => _MyAppState();
}

class SecondPage extends StatelessWidget {
  const SecondPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: const Center(
        child: LoadingIndicator(
          indicatorType: Indicator.pacman,
          colors: [Colors.black],
          strokeWidth: 4.0,
          pathBackgroundColor: Colors.white,
        ),
      ),
    );
  }
}

class ResultPage extends StatelessWidget {
  const ResultPage({Key? key, required this.data}) : super(key: key);
  final List<Note> data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Result:"),
      ),
      body: ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            return Card(
              //                           <-- Card widget
              child: ListTile(
                leading: Icon(Icons.music_note),
                title: Text(data[index].toString()),
              ),
            );
          }),
    );
  }
}

class Note {
  Note({required this.name, required this.freq});
  final String name;
  final double freq;

  String toString() {
    return "$name ($freq)";
  }
}

Future<List<Note>> read_file(String path) async {
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

  final wav = await Wav.readFile(path);
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
    }
    ;
  }
  print(noteName);

  return [
    Note(name: noteName, freq: freq),
  ];
}

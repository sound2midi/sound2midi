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
            TextButton(
              child: Text("abc"),
                onPressed: () {

                }
            ),
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
  final List<String> data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Result:"),
      ),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          return Card( //                           <-- Card widget
            child: ListTile(
              leading: Icon(Icons.music_note),
              title: Text(data[index]),
            ),
          );
        }
      ),
    );
  }
}

class Note {
  Note({required this.name, required this.freq});
  final String name;
  final double freq;

  String toString() {
    return "";
  }
}

Future<List<Note>> read_file(String file) async {
   final wav = await Wav.readFile(file);
   final sound2 = wav.channels.first;

  List<double> audio = sound2;

  final fft = FFT(audio.length);
  final spectrum = fft.realFft(audio).toRealArray();

  final maxFreq = spectrum.indexOf(spectrum.sublist(0, 20000).reduce(max));
  print("frequency $maxFreq ... ${fft.frequency(maxFreq, 48000)}");

  return [
    Note(name: "A", freq: maxFreq),
  ];
}


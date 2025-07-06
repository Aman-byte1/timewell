import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class StopwatchScreen extends ConsumerStatefulWidget {
  const StopwatchScreen({super.key});

  @override
  _StopwatchScreenState createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends ConsumerState<StopwatchScreen> {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  List<Duration> _laps = [];

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final elapsedMillis = prefs.getInt('stopwatch_elapsed') ?? 0;
    final isRunning = prefs.getBool('stopwatch_running') ?? false;
    
    setState(() {
      _elapsed = Duration(milliseconds: elapsedMillis);
      if (isRunning) {
        _stopwatch.start();
        _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
          setState(() {
            _elapsed = _stopwatch.elapsed;
          });
        });
      }
    });
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('stopwatch_elapsed', _elapsed.inMilliseconds);
    await prefs.setBool('stopwatch_running', _stopwatch.isRunning);
  }

  void _startStopwatch() {
    setState(() {
      _stopwatch.start();
      _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
        setState(() {
          _elapsed = _stopwatch.elapsed;
        });
      });
    });
    _saveState();
  }

  void _pauseStopwatch() {
    setState(() {
      _stopwatch.stop();
      _timer?.cancel();
    });
    _saveState();
  }

  void _resetStopwatch() {
    setState(() {
      _stopwatch.reset();
      _timer?.cancel();
      _elapsed = Duration.zero;
      _laps.clear();
    });
    _saveState();
  }

  void _addLap() {
    setState(() {
      _laps.add(_elapsed);
    });
  }

  @override
  Widget build(BuildContext context) {
    final hours = _elapsed.inHours.remainder(24).toString().padLeft(2, '0');
    final minutes = _elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = _elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    final milliseconds = (_elapsed.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');

    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$hours:$minutes:$seconds.$milliseconds',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 48,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _stopwatch.isRunning ? _pauseStopwatch : _startStopwatch,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                      child: Text(
                        _stopwatch.isRunning ? 'Pause' : 'Start',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: _resetStopwatch,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        backgroundColor: Colors.red.shade700,
                      ),
                      child: const Text(
                        'Reset',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _stopwatch.isRunning ? _addLap : null,
                  child: const Text('Add Lap'),
                ),
              ],
            ),
          ),
        ),
        if (_laps.isNotEmpty)
          Expanded(
            child: ListView.builder(
              itemCount: _laps.length,
              itemBuilder: (context, index) {
                final lap = _laps[index];
                final lapNumber = index + 1;
                final lapTime = '${lap.inMinutes.remainder(60).toString().padLeft(2, '0')}:'
                    '${lap.inSeconds.remainder(60).toString().padLeft(2, '0')}.'
                    '${(lap.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0')}';
                
                return ListTile(
                  leading: Text('Lap $lapNumber'),
                  trailing: Text(lapTime),
                );
              },
            ),
          ),
      ],
    );
  }
}
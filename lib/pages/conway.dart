import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/conway/game.dart';
import 'package:portfolio/conway/grid_view.dart';

class ConwayPage extends StatefulWidget {
  const ConwayPage({super.key});

  @override
  State<ConwayPage> createState() => _ConwayPageState();
}

class _ConwayPageState extends State<ConwayPage> {
  static const _boardWidth = 60;
  static const _boardHeight = 40;
  static const _tick = Duration(milliseconds: 100);

  final _random = Random();
  late ConwayLife _sim = _newSim();
  Timer? _timer;

  bool get _running => _timer != null;

  ConwayLife _newSim() => ConwayLife(
        width: _boardWidth,
        height: _boardHeight,
        seed: _random.nextInt(1 << 31),
      );

  void _togglePlay() {
    setState(() {
      if (_running) {
        _timer!.cancel();
        _timer = null;
      } else {
        _timer = Timer.periodic(_tick, (_) => setState(_sim.step));
      }
    });
  }

  void _step() => setState(_sim.step);

  void _newBoard() => setState(() => _sim = _newSim());

  @override
  void dispose() {
    // Leaving the page must stop the timer, or it keeps calling setState
    // on a widget that no longer exists.
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Home',
          onPressed: () => context.go('/'),
        ),
        title: const Text("Conway's Game of Life"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Generation ${_sim.generation}  ·  Population ${_sim.population}'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: _togglePlay,
                  icon: Icon(_running ? Icons.pause : Icons.play_arrow),
                  label: Text(_running ? 'Pause' : 'Play'),
                ),
                OutlinedButton.icon(
                  onPressed: _running ? null : _step,
                  icon: const Icon(Icons.skip_next),
                  label: const Text('Step'),
                ),
                OutlinedButton.icon(
                  onPressed: _newBoard,
                  icon: const Icon(Icons.casino),
                  label: const Text('New board'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: _boardWidth / _boardHeight,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: colors.outline),
                    ),
                    child: GridViewBoard(sim: _sim),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

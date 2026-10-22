import 'dart:io';

import 'package:args/args.dart';
import 'package:cellular_automaton_zoo/cellular_automaton_zoo.dart';

/// Each "species" is a concrete mixin composition — this is the payoff
/// line students write themselves: which mixins, in which order.
class Conway extends CellularAutomaton
    with ConwayRules, AsciiRenderable, DecoratedRenderable {
  Conway({required super.width, required super.height, required super.seed});
}

CellularAutomaton _buildSpecies(String name, int w, int h, int seed) =>
    switch (name) {
      'conway' => Conway(width: w, height: h, seed: seed),
      _ => throw ArgumentError('Unknown species: $name'),
    };

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('species', defaultsTo: 'conway', allowed: ['conway'])
    ..addOption('seed', defaultsTo: '42')
    ..addOption('width', defaultsTo: '40')
    ..addOption('height', defaultsTo: '20')
    ..addOption('generations', defaultsTo: '100')
    ..addOption('fps', defaultsTo: '8');

  final args = parser.parse(arguments);
  final width = int.parse(args['width']);
  final height = int.parse(args['height']);
  final generations = int.parse(args['generations']);
  final fps = int.parse(args['fps']);
  final seed = int.parse(args['seed']);

  final sim = _buildSpecies(args['species'], width, height, seed);

  for (var i = 0; i <= generations; i++) {
    stdout.write('\x1B[2J\x1B[H'); // clear screen, cursor home
    stdout.writeln('species=${args['species']}  seed=$seed');
    stdout.writeln('generation ${sim.generation}/$generations  '
        'population=${sim.population}');
    stdout.write(sim.render());
    if (i < generations) {
      sim.step();
      await Future.delayed(Duration(milliseconds: 1000 ~/ fps));
    }
  }
}

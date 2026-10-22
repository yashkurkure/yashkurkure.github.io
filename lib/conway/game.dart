import 'package:cellular_automaton_zoo/cellular_automaton_zoo.dart';

class ConwayLife extends CellularAutomaton with ConwayRules, AsciiRenderable {
  ConwayLife({required super.width, required super.height, required super.seed});
}
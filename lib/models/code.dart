import 'package:flutter/material.dart';

enum PegColor {
  red,
  blue,
  green,
  yellow,
  orange,
  purple;

  Color get color {
    switch (this) {
      case PegColor.red:
        return Colors.red;
      case PegColor.blue:
        return Colors.blue;
      case PegColor.green:
        return Colors.green;
      case PegColor.yellow:
        return Colors.yellow.shade700;
      case PegColor.orange:
        return Colors.orange;
      case PegColor.purple:
        return Colors.purple;
    }
  }

  String get label {
    return name[0].toUpperCase() + name.substring(1);
  }
}

class Code {
  final List<PegColor> pegs;

  const Code(this.pegs);

  int get length => pegs.length;

  PegColor operator [](int index) => pegs[index];

  @override
  bool operator ==(Object other) {
    if (other is! Code) return false;
    if (pegs.length != other.pegs.length) return false;
    for (int i = 0; i < pegs.length; i++) {
      if (pegs[i] != other.pegs[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(pegs);

  @override
  String toString() => pegs.map((p) => p.label).join('-');
}

final List<Code> allCodes = _generateAllCodes();

List<Code> _generateAllCodes() {
  final codes = <Code>[];
  final colors = PegColor.values;
  for (int i = 0; i < 1296; i++) {
    int n = i;
    final pegs = <PegColor>[];
    for (int j = 0; j < 4; j++) {
      pegs.add(colors[n % 6]);
      n ~/= 6;
    }
    codes.add(Code(pegs));
  }
  return codes;
}

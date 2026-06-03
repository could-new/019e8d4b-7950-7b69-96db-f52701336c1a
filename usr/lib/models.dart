import 'package:flutter/material.dart';

enum PcbLayer { top, bottom }

class PcbPad {
  final String id;
  Offset position;
  final double radius;

  PcbPad({
    required this.id,
    required this.position,
    this.radius = 10.0,
  });
}

class PcbTrace {
  final String id;
  final List<Offset> points;
  final PcbLayer layer;
  final double width;

  PcbTrace({
    required this.id,
    required this.points,
    required this.layer,
    this.width = 4.0,
  });
}

enum EditorMode {
  select,
  placePad,
  routeTrace,
}

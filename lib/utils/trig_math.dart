// lib/utils/trig_math.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Converts Angle (0-360 degrees) and Distance into a 2D Offset
Offset getOffsetFromAngle(double angle, double distance) {
  // Convert degrees to radians: radians = degrees * (pi / 180)
  double radians = angle * (math.pi / 180);

  // Calculate X and Y
  double dx = distance * math.cos(radians);
  double dy = distance * math.sin(radians);

  return Offset(dx, dy);
}

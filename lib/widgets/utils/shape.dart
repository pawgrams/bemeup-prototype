// Datei: widgets\utils\shape.dart
import 'package:flutter/material.dart';
import 'dart:math';

Widget applyShape(Widget child, String shape) {
  switch (shape) {
    case 'sphere':        return ClipOval(child: child);
    case 'triangleup':    return ClipPath(clipper: _TriangleUpClipper(), child: child);
    case 'triangledown':  return ClipPath(clipper: _TriangleDownClipper(), child: child);
    case 'hexagon':       return ClipPath(clipper: _PolygonClipper(sides: 6), child: child);
    case 'octagon':       return ClipPath(clipper: _PolygonClipper(sides: 8), child: child);
    case 'rhombus':       return ClipPath(clipper: _RhombusClipper(), child: child);
    case 'diamond':       return ClipPath(clipper: _DiamondClipper(), child: child);
    case 'star':          return ClipPath(clipper: _StarClipper(), child: child);
    case 'square':        return ClipRRect(borderRadius: BorderRadius.circular(8), child: child);
    default:              return ClipRRect(borderRadius: BorderRadius.circular(8), child: child);
  }
}

Path getShapePath(String shape, Size size) {
  switch (shape) {
    case 'triangleup':
      final widthFactor = 0.9;
      final heightFactor = 0.85;
      final dx = (size.width * (1 - widthFactor)) / 2;
      final dy = size.height * (1 - heightFactor);
      final yShift = -size.height * 0.10;
      return Path()
        ..moveTo(size.width / 2, dy + yShift)
        ..lineTo(size.width - dx, size.height + yShift)
        ..lineTo(dx, size.height + yShift)
        ..close();
    case 'triangledown':
      final widthFactor = 0.9;
      final heightFactor = 0.85;
      final dx = (size.width * (1 - widthFactor)) / 2;
      final dy = size.height * (1 - heightFactor);
      final yShift = size.height * 0.10;
      return Path()
        ..moveTo(dx, yShift)
        ..lineTo(size.width - dx, yShift)
        ..lineTo(size.width / 2, size.height - dy + yShift)
        ..close();
    case 'hexagon':
      return _polygonPath(6, size);
    case 'octagon':
      return _polygonPath(8, size);
    case 'rhombus':
      return Path()
        ..moveTo(size.width / 2, 0)
        ..lineTo(size.width, size.height / 2)
        ..lineTo(size.width / 2, size.height)
        ..lineTo(0, size.height / 2)
        ..close();
    case 'diamond':
      final w = size.width;
      final h = size.height;
      final shiftY = -h * 0.05;
      return Path()
        ..moveTo(w * 0.2, h * 0.2 + shiftY)
        ..lineTo(w * 0.8, h * 0.2 + shiftY)
        ..lineTo(w, h * 0.5 + shiftY)
        ..lineTo(w * 0.5, h + shiftY)
        ..lineTo(0, h * 0.5 + shiftY)
        ..close();
    case 'star':
  final path = Path();
  final center = Offset(size.width / 2, size.height / 2);
  final outerRadius = size.width / 2;
  final innerRadius = outerRadius * 0.5;
  final angle = pi / 5;
  for (int i = 0; i < 10; i++) {
    final radius = i.isEven ? outerRadius : innerRadius;
    final x = center.dx + radius * cos(angle * i - pi / 2);
    final y = center.dy + radius * sin(angle * i - pi / 2);
    if (i == 0) {
      path.moveTo(x, y);
    } else {
      path.lineTo(x, y);
    }
  }
  return path..close();
    case 'sphere':
      final r = size.width / 2;
      return Path()..addOval(Rect.fromCircle(center: Offset(r, r), radius: r));
    case 'square':
    default:
      return Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(8)));
  }
}

Path _polygonPath(int sides, Size size) {
  final path = Path();
  final angle = (2 * pi) / sides;
  final radius = size.width / 2;
  final center = Offset(size.width / 2, size.height / 2);
  path.moveTo(
    center.dx + radius * cos(0),
    center.dy + radius * sin(0),
  );
  for (int i = 1; i <= sides; i++) {
    path.lineTo(
      center.dx + radius * cos(angle * i),
      center.dy + radius * sin(angle * i),
    );
  }
  return path..close();
}

class _TriangleUpClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => getShapePath('triangleup', size);
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _TriangleDownClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => getShapePath('triangledown', size);
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _PolygonClipper extends CustomClipper<Path> {
  final int sides;
  _PolygonClipper({required this.sides});
  @override
  Path getClip(Size size) => _polygonPath(sides, size);
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _RhombusClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => getShapePath('rhombus', size);
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _DiamondClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => getShapePath('diamond', size);
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _StarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => getShapePath('star', size);
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}


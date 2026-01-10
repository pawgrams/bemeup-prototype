// Datei: widgets\utils\shape_glow.dart
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';

class ShapeGlow extends StatelessWidget {
  final double size;
  final Widget child;
  final Color glowColor;
  final String shape;
  final double glowBlur;

  const ShapeGlow({
    super.key,
    required this.size,
    required this.child,
    required this.glowColor,
    required this.shape,
    this.glowBlur = 12,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GlowPainter(shape: shape, glowColor: glowColor, blur: glowBlur),
      child: _clipShape(child),
    );
  }

  Widget _clipShape(Widget child) {
    switch (shape) {
      case 'sphere':
        return ClipOval(child: SizedBox(width: size, height: size, child: child));
      default:
        return ClipPath(
          clipper: _getClipper(shape),
          child: SizedBox(width: size, height: size, child: child),
        );
    }
  }
}

class _GlowPainter extends CustomPainter {
  final String shape;
  final Color glowColor;
  final double blur;

  _GlowPainter({required this.shape, required this.glowColor, required this.blur});

  @override
  void paint(Canvas canvas, Size size) {
    final path = _getPath(shape, size);
    final paint = Paint()
      ..color = glowColor
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Path _getPath(String shape, Size size) {
  switch (shape) {
    case 'triangleup':
      final widthFactor = 0.9;
      final heightFactor = 0.85;
      final dx = (size.width * (1 - widthFactor)) / 2;
      final dy = size.height * (1 - heightFactor);
      final yShift = -size.height * 0.10;
      final path = Path();
      path.moveTo(size.width / 2, dy + yShift);
      path.lineTo(size.width - dx, size.height + yShift);
      path.lineTo(dx, size.height + yShift);
      path.close();
      return path;
    case 'triangledown':
      final widthFactor = 0.9;
      final heightFactor = 0.85;
      final dx = (size.width * (1 - widthFactor)) / 2;
      final dy = size.height * (1 - heightFactor);
      final yShift = size.height * 0.10;
      final path = Path();
      path.moveTo(dx, yShift);
      path.lineTo(size.width - dx, yShift);
      path.lineTo(size.width / 2, size.height - dy + yShift);
      path.close();
      return path;
    case 'hexagon':
      return _polygonPath(6, size);
    case 'octagon':
      return _polygonPath(8, size);
    case 'rhombus':
      final path = Path();
      path.moveTo(size.width / 2, 0);
      path.lineTo(size.width, size.height / 2);
      path.lineTo(size.width / 2, size.height);
      path.lineTo(0, size.height / 2);
      path.close();
      return path;
    case 'diamond':
      final w = size.width;
      final h = size.height;
      final shiftY = -h * 0.05;
      final path = Path();
      path.moveTo(w * 0.2, h * 0.2 + shiftY);
      path.lineTo(w * 0.8, h * 0.2 + shiftY);
      path.lineTo(w, h * 0.5 + shiftY);
      path.lineTo(w * 0.5, h + shiftY);
      path.lineTo(0, h * 0.5 + shiftY);
      path.close();
      return path;
    case 'star':
      final path = Path();
      final center = Offset(size.width / 2, size.height / 2);
      final outerRadius = size.width / 2;
      final innerRadius = outerRadius * 0.5;
      final angle = pi / 5;
      for (int i = 0; i <= 10; i++) {
        final radius = i.isEven ? outerRadius : innerRadius;
        final x = center.dx + radius * cos(i * angle - pi / 2);
        final y = center.dy + radius * sin(i * angle - pi / 2);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.quadraticBezierTo(center.dx, center.dy, x, y);
        }
      }
      path.close();
      return path;
    case 'sphere':
      final r = size.width / 2;
      return Path()..addOval(Rect.fromCircle(center: Offset(r, r), radius: r));
    case 'square':
    default:
      return Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(8)));
  }
}

CustomClipper<Path> _getClipper(String shape) {
  switch (shape) {
    case 'triangleup': return _TriangleUpClipper();
    case 'triangledown': return _TriangleDownClipper();
    case 'hexagon': return _PolygonClipper(6);
    case 'octagon': return _PolygonClipper(8);
    case 'rhombus': return _RhombusClipper();
    case 'diamond': return _DiamondClipper();
    case 'star': return _StarClipper();
    case 'square': default: return _SquareClipper();
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
  path.close();
  return path;
}

class _TriangleUpClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => _getPath('triangleup', size);
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _TriangleDownClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => _getPath('triangledown', size);
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _PolygonClipper extends CustomClipper<Path> {
  final int sides;
  _PolygonClipper(this.sides);
  @override
  Path getClip(Size size) => _polygonPath(sides, size);
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _RhombusClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => _getPath('rhombus', size);
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _DiamondClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => _getPath('diamond', size);
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _StarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => _getPath('star', size);
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _SquareClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => _getPath('square', size);
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

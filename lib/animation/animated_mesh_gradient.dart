import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Data class for a color point
class ColorPoint {
  Offset position;
  Color color;
  Offset velocity;
  double targetRadius; // Influence radius

  ColorPoint({
    required this.position,
    required this.color,
    required this.velocity,
    this.targetRadius = 150.0, // Default influence radius
  });

  // Method to update position based on velocity
  void update(Size bounds) {
    position += velocity;

    // Bounce off edges
    if (position.dx < 0 || position.dx > bounds.width) {
      velocity = Offset(-velocity.dx, velocity.dy);
      position = position.clamp(
          Offset.zero, Offset(bounds.width, bounds.height)); // Clamp to bounds
    }
    if (position.dy < 0 || position.dy > bounds.height) {
      velocity = Offset(velocity.dx, -velocity.dy);
      position = position.clamp(
          Offset.zero, Offset(bounds.width, bounds.height)); // Clamp to bounds
    }
  }
}

// The main widget for the animation page
class AnimatedMeshGradientPage extends StatefulWidget {
  const AnimatedMeshGradientPage({super.key});

  @override
  _AnimatedMeshGradientPageState createState() =>
      _AnimatedMeshGradientPageState();
}

class _AnimatedMeshGradientPageState extends State<AnimatedMeshGradientPage>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  final List<ColorPoint> _colorPoints = [];
  final Random _random = Random();
  late Size _screenSize;

  // Configurable parameters
  final int _numPoints = 5; // Number of color points
  final double _maxSpeed = 1.5; // Increased speed from 0.8

  @override
  void initState() {
    super.initState();
    // Ticker for animation updates
    _ticker = createTicker((elapsed) {
      _updatePoints();
      setState(() {}); // Trigger repaint
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize points only once or when screen size is available
    if (_colorPoints.isEmpty) {
      _screenSize = MediaQuery.of(context).size;
      _initializePoints();
      if (!_ticker.isTicking) {
        _ticker.start();
      }
    }
  }

  void _initializePoints() {
    _colorPoints.clear();
    // Initial colors - can be customized
    final List<Color> baseColors = [
      Colors.blue.shade300,
      Colors.purple.shade300,
      Colors.red.shade300,
      Colors.green.shade300,
      Colors.orange.shade300,
      Colors.pink.shade300,
      Colors.teal.shade300,
    ];

    for (int i = 0; i < _numPoints; i++) {
      _colorPoints.add(
        ColorPoint(
            position: Offset(
              _random.nextDouble() * _screenSize.width,
              _random.nextDouble() * _screenSize.height,
            ),
            color: baseColors[i % baseColors.length]
                .withOpacity(0.8), // Cycle through colors
            velocity: Offset(
              (_random.nextDouble() - 0.5) * 2 * _maxSpeed,
              (_random.nextDouble() - 0.5) * 2 * _maxSpeed,
            ),
            targetRadius: _screenSize.width * 0.4 +
                _random.nextDouble() *
                    _screenSize.width *
                    0.3 // Radius based on screen width
            ),
      );
    }
  }

  void _updatePoints() {
    // Update position for each point
    for (final point in _colorPoints) {
      point.update(_screenSize);
    }
  }

  @override
  void dispose() {
    _ticker.dispose(); // Important to dispose the ticker
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Add a dark background
      // Remove AppBar to allow placing title in the center
      // extendBodyBehindAppBar: true,
      // appBar: AppBar(
      //   title: const Text('动态网格渐变',
      //       style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      //   backgroundColor: Colors.transparent, // Transparent app bar
      //   elevation: 0,
      //   iconTheme: IconThemeData(color: Colors.white), // White back button
      // ),
      body: Stack(
        // Use Stack to layer text over the gradient
        children: [
          // The gradient background
          CustomPaint(
            painter: MeshGradientPainter(points: _colorPoints),
            size: Size.infinite, // Cover the entire screen
          ),
          // Centered Title Text
          Center(
            child: Text(
              '动态网格渐变动画',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black.withOpacity(0.5),
                      offset: Offset(2.0, 2.0),
                    ),
                  ]),
            ),
          ),
          // Optional: Add back button manually if needed without AppBar
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: BackButton(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

// The CustomPainter that draws the mesh gradient
class MeshGradientPainter extends CustomPainter {
  final List<ColorPoint> points;

  MeshGradientPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    // Use saveLayer for blend modes to work correctly across multiple draws
    // Using Rect.largest might be inefficient if the canvas is much larger than the screen,
    // but it's simple for a full-screen effect.
    canvas.saveLayer(Rect.largest, Paint());

    final paint = Paint()
      ..blendMode = ui.BlendMode.plus; // Use additive blending

    // Draw a radial gradient for each point
    for (final point in points) {
      // Create the radial gradient
      final gradient = ui.Gradient.radial(
        point.position,
        point.targetRadius, // Use the point's radius
        [
          point.color.withOpacity(0.6), // Start with slightly less opaque color
          point.color.withOpacity(0.0) // Fade to fully transparent
        ],
        [0.0, 1.0], // Gradient stops (0% to 100%)
      );

      // Apply the gradient shader to the paint
      paint.shader = gradient;

      // Draw a rect covering the whole canvas with this gradient
      // Each draw adds its color to the layer due to BlendMode.plus
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    }

    // Restore the layer, applying the blended gradients to the main canvas
    canvas.restore();

    /*
    // --- Old Placeholder Code Removed ---
    final paint = Paint();
    for (final point in points) {
      paint.color = point.color;
      canvas.drawCircle(point.position, 15, paint); // Draw point as a circle
    }
    */
  }

  @override
  bool shouldRepaint(covariant MeshGradientPainter oldDelegate) {
    // Repaint needed because points list or their properties change
    return true;
  }
}

// Helper extension for clamping Offset
extension OffsetClamp on Offset {
  Offset clamp(Offset min, Offset max) {
    return Offset(
      dx.clamp(min.dx, max.dx),
      dy.clamp(min.dy, max.dy),
    );
  }
}

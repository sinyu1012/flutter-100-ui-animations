import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class FallingConfettiPage extends HookWidget {
  const FallingConfettiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('彩带飘落'),
      ),
      body: const FallingConfettiWidget(numberOfPieces: 50),
    );
  }
}

class ConfettiPiece {
  final Color color;
  final double width;
  final double height;
  final double angle;
  double x;
  double y;
  final double speed;

  ConfettiPiece({
    required this.color,
    required this.width,
    required this.height,
    required this.angle,
    required this.x,
    required this.y,
    required this.speed,
  });
}

class FallingConfettiWidget extends HookWidget {
  final int numberOfPieces;

  const FallingConfettiWidget({super.key, this.numberOfPieces = 100});

  @override
  Widget build(BuildContext context) {
    final random = Random();
    final colors = [
      const Color(0xFFFF9BC5),
      const Color(0xFF9383FF),
      const Color(0xFF7ED9FF),
      const Color(0xFF7FD8FF),
    ];

    final confetti = useState<List<ConfettiPiece>>([]);
    final size = useState(Size.zero);

    void updateSize(Size newSize) {
      if (size.value != newSize) {
        size.value = newSize;
        confetti.value =
            _generateConfetti(random, colors, newSize, numberOfPieces);
      }
    }

    useEffect(() {
      final timer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
        confetti.value = confetti.value.map((piece) {
          piece.y += piece.speed;
          if (piece.y > size.value.height) {
            piece.y = -piece.height;
            piece.x = random.nextDouble() * size.value.width;
          }
          return piece;
        }).toList();
      });
      return () => timer.cancel();
    }, [size.value]);

    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          updateSize(Size(constraints.maxWidth, constraints.maxHeight));
        });

        return ClipRect(
          child: CustomPaint(
            painter: ConfettiPainter(confetti: confetti.value),
            size: Size(constraints.maxWidth, constraints.maxHeight),
          ),
        );
      },
    );
  }

  List<ConfettiPiece> _generateConfetti(
      Random random, List<Color> colors, Size size, int count) {
    return List.generate(count, (index) {
      final pieceWidth = random.nextDouble() * 10 + 10;
      final pieceHeight = pieceWidth * (0.5 + random.nextDouble() * 0.3);
      return ConfettiPiece(
        color: colors[random.nextInt(colors.length)],
        width: pieceWidth,
        height: pieceHeight,
        angle: random.nextDouble() * 2 * pi,
        x: random.nextDouble() * size.width,
        y: random.nextDouble() * size.height, // Changed this line
        speed: random.nextDouble() * 2 + 1,
      );
    });
  }
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiPiece> confetti;

  ConfettiPainter({required this.confetti});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final piece in confetti) {
      // Only draw pieces that are within the visible area
      if (piece.y >= -piece.height && piece.y <= size.height) {
        paint.color = piece.color;
        canvas.save();
        canvas.translate(piece.x, piece.y);
        canvas.rotate(piece.angle);
        canvas.drawRect(
          Rect.fromCenter(
              center: Offset.zero, width: piece.width, height: piece.height),
          paint,
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

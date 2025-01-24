import 'dart:math';

import 'package:flutter/material.dart';

class WavePainter extends CustomPainter {
  final double waveProgress;

  WavePainter(this.waveProgress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.fill;

    // 绘制波浪的路径
    final path = Path();
    path.moveTo(0, size.height * 0.5);
    for (double i = 0; i <= size.width; i++) {
      path.lineTo(i, size.height * 0.5 + 10 * sin((i / size.width * 2 * pi) + (waveProgress * 2 * pi)));
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class WaveAnimationPage extends StatefulWidget {
  @override
  _WaveAnimationPageState createState() => _WaveAnimationPageState();
}

class _WaveAnimationPageState extends State<WaveAnimationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('波浪动画效果')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: WavePainter(_controller.value),
            child: Container(),
          );
        },
      ),
    );
  }
}

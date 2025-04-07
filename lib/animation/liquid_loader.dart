import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vector;

class LiquidLoaderPage extends StatefulWidget {
  @override
  _LiquidLoaderPageState createState() => _LiquidLoaderPageState();
}

class _LiquidLoaderPageState extends State<LiquidLoaderPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _progress = 0.0;
  final _dragHeight = 100.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3000),
    )..addListener(() {
        setState(() {
          _progress = _controller.value;
        });
      });

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('流体液态加载动画'),
        backgroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CustomPaint(
                  painter: LiquidPainter(
                    progress: _progress,
                    color1: Colors.blue,
                    color2: Colors.purple,
                  ),
                ),
              ),
            ),
            SizedBox(height: 50),
            GestureDetector(
              onVerticalDragUpdate: (details) {
                setState(() {
                  _progress -= details.delta.dy / _dragHeight;
                  _progress = _progress.clamp(0.0, 1.0);
                });
                // 暂停自动动画
                _controller.stop();
              },
              onVerticalDragEnd: (details) {
                // 恢复自动动画
                _controller.repeat();
              },
              child: Container(
                width: 200,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.purple],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '拖动调整液位',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LiquidPainter extends CustomPainter {
  final double progress;
  final Color color1;
  final Color color2;

  LiquidPainter({
    required this.progress,
    required this.color1,
    required this.color2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 绘制背景
    final backgroundPaint = Paint()..color = Colors.black87;
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    // 绘制液体
    final liquidHeight = size.height * progress;
    final liquidRect =
        Rect.fromLTWH(0, size.height - liquidHeight, size.width, liquidHeight);

    // 创建液体渐变
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [color1, color2],
    );

    final liquidPaint = Paint()..shader = gradient.createShader(liquidRect);

    // 创建液体波浪路径
    final path = Path();

    // 起始点
    path.moveTo(0, size.height);

    // 左边界
    path.lineTo(0, size.height - liquidHeight);

    // 使用平滑的贝塞尔曲线绘制波浪
    final waveHeight = 6.0; // 减小波浪高度
    final baseHeight = size.height - liquidHeight;

    // 先添加第一个点
    path.lineTo(0, baseHeight);

    // 使用更多的点和quadraticBezierTo绘制平滑曲线
    final segments = 16;
    double previousX = 0;
    double previousY = baseHeight;

    for (int i = 1; i <= segments; i++) {
      final t = i / segments;
      final x = size.width * t;

      // 使用单一的正弦函数，避免尖锐的波峰
      final sinValue = sin((progress * 2 * pi) + (t * 4 * pi));
      final y = baseHeight + sinValue * waveHeight;

      // 控制点，在前一点和当前点之间
      final controlX = (previousX + x) / 2;
      final controlY = baseHeight +
          sin((progress * 2 * pi) + ((t - 0.5 / segments) * 4 * pi)) *
              waveHeight;

      // 使用二次贝塞尔曲线连接点
      path.quadraticBezierTo(controlX, controlY, x, y);

      previousX = x;
      previousY = y;
    }

    // 右边界和底部
    path.lineTo(size.width, size.height - liquidHeight);
    path.lineTo(size.width, size.height);
    path.close();

    // 绘制液体
    canvas.drawPath(path, liquidPaint);

    // 添加气泡效果
    drawBubbles(canvas, size, liquidRect);

    // 添加光晕效果
    drawGlow(canvas, size, path, liquidPaint);
  }

  void drawBubbles(Canvas canvas, Size size, Rect liquidRect) {
    final random = Random(progress.toInt() * 1000);
    final bubblePaint = Paint()..color = Colors.white.withOpacity(0.5);

    for (int i = 0; i < 15; i++) {
      final bubbleSize = random.nextDouble() * 8 + 2;
      final bubbleX = random.nextDouble() * size.width;
      final bubbleY =
          size.height - (random.nextDouble() * liquidRect.height * 0.8);
      final offset = sin((progress * 2 * pi) + i) * 5;

      canvas.drawCircle(
          Offset(bubbleX, bubbleY + offset), bubbleSize, bubblePaint);
    }
  }

  void drawGlow(Canvas canvas, Size size, Path path, Paint paint) {
    // 添加发光效果
    for (int i = 0; i < 5; i++) {
      final glowPaint = Paint()
        ..color = color1.withOpacity(0.1 - i * 0.02)
        ..style = PaintingStyle.stroke
        ..strokeWidth = i * 2.0;

      canvas.drawPath(path, glowPaint);
    }

    // 添加顶部高光
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final highlightPath = Path();
    final baseHeight = size.height - size.height * progress;

    highlightPath.moveTo(0, baseHeight);

    // 使用贝塞尔曲线绘制平滑的高光
    double previousX = 0;
    double previousY = baseHeight;
    final segments = 16;

    for (int i = 1; i <= segments; i++) {
      final t = i / segments;
      final x = size.width * t;

      // 使用单一的正弦函数
      final sinValue = sin((progress * 2 * pi) + (t * 4 * pi));
      final y = baseHeight + sinValue * 4.0; // 减小高光的波峰

      // 控制点
      final controlX = (previousX + x) / 2;
      final controlY = baseHeight +
          sin((progress * 2 * pi) + ((t - 0.5 / segments) * 4 * pi)) * 4.0;

      // 使用二次贝塞尔曲线
      highlightPath.quadraticBezierTo(controlX, controlY, x, y);

      previousX = x;
      previousY = y;
    }

    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant LiquidPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

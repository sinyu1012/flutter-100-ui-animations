import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class MagneticParticlesPage extends StatefulWidget {
  @override
  _MagneticParticlesPageState createState() => _MagneticParticlesPageState();
}

class _MagneticParticlesPageState extends State<MagneticParticlesPage>
    with SingleTickerProviderStateMixin {
  final int particleCount = 120;
  final List<Particle> particles = [];
  Offset? pointerPosition;
  late Ticker _ticker;
  double _time = 0;

  // 屏幕尺寸
  late Size _screenSize;

  // 颜色配置
  final Color primaryColor = Color(0xFF007AFF);
  final Color secondaryColor = Color(0xFF6C13FF);
  final Color tertiaryColor = Color(0xFF00E5FF);

  @override
  void initState() {
    super.initState();

    // 使用Ticker而不是AnimationController，可以获得更高的帧率
    _ticker = createTicker((elapsed) {
      _time += 0.016; // 约60fps
      _updateParticles();
      setState(() {});
    });

    _ticker.start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _screenSize = MediaQuery.of(context).size;

    // 初始化粒子，只在第一次或屏幕尺寸变化时执行
    if (particles.isEmpty) {
      _initializeParticles();
    }
  }

  void _initializeParticles() {
    final random = Random();

    // 生成随机粒子
    for (int i = 0; i < particleCount; i++) {
      final position = Offset(
        random.nextDouble() * _screenSize.width,
        random.nextDouble() * _screenSize.height,
      );

      // 随机速度
      final velocity = Offset(
        (random.nextDouble() - 0.5) * 1.0,
        (random.nextDouble() - 0.5) * 1.0,
      );

      // 随机大小，但保持在一个合理范围内
      final size = random.nextDouble() * 2.5 + 1.5;

      // 随机不透明度
      final opacity = random.nextDouble() * 0.4 + 0.6;

      // 随机颜色 - 在三种主色之间选择
      Color color;
      final colorPick = random.nextDouble();
      if (colorPick < 0.33) {
        color = primaryColor;
      } else if (colorPick < 0.66) {
        color = secondaryColor;
      } else {
        color = tertiaryColor;
      }

      // 创建粒子并添加到列表
      particles.add(
        Particle(
          position: position,
          velocity: velocity,
          size: size,
          opacity: opacity,
          color: color,
          originalPosition: position.clone(),
        ),
      );
    }
  }

  void _updateParticles() {
    for (final particle in particles) {
      // 基础移动 - 微小的随机运动
      final noise = Offset(
        sin(_time * 0.5 + particle.originalPosition.dx * 0.05) * 0.3,
        cos(_time * 0.5 + particle.originalPosition.dy * 0.05) * 0.3,
      );

      // 更新位置
      particle.position = particle.position + particle.velocity + noise;

      // 慢慢将粒子拉回其原始位置附近（保持在屏幕内）
      final toOriginal = particle.originalPosition - particle.position;
      particle.velocity = particle.velocity + toOriginal * 0.003;

      // 摩擦力，减慢粒子速度
      particle.velocity = particle.velocity * 0.95;

      // 如果有鼠标/触摸点，添加吸引力
      if (pointerPosition != null) {
        final pointerForce = pointerPosition! - particle.position;
        final distance = pointerForce.distance;

        // 吸引距离范围
        final attractRadius = 180.0;

        if (distance < attractRadius) {
          // 吸引力随距离减弱
          final strength = 1.0 - (distance / attractRadius);
          final attractForce = pointerForce.normalize() * strength * 2.0;

          // 应用吸引力
          particle.velocity = particle.velocity + attractForce;

          // 接近鼠标时增加不透明度和大小
          particle.currentOpacity = particle.opacity + strength * 0.3;
          particle.currentSize = particle.size + strength * 2.0;
        } else {
          // 恢复正常状态
          particle.currentOpacity = particle.opacity;
          particle.currentSize = particle.size;
        }
      } else {
        // 无鼠标/触摸时恢复正常状态
        particle.currentOpacity = particle.opacity;
        particle.currentSize = particle.size;
      }

      // 边界检查 - 保持粒子在屏幕内
      if (particle.position.dx < 0) {
        particle.position = Offset(0, particle.position.dy);
        particle.velocity =
            Offset(-particle.velocity.dx * 0.5, particle.velocity.dy);
      } else if (particle.position.dx > _screenSize.width) {
        particle.position = Offset(_screenSize.width, particle.position.dy);
        particle.velocity =
            Offset(-particle.velocity.dx * 0.5, particle.velocity.dy);
      }

      if (particle.position.dy < 0) {
        particle.position = Offset(particle.position.dx, 0);
        particle.velocity =
            Offset(particle.velocity.dx, -particle.velocity.dy * 0.5);
      } else if (particle.position.dy > _screenSize.height) {
        particle.position = Offset(particle.position.dx, _screenSize.height);
        particle.velocity =
            Offset(particle.velocity.dx, -particle.velocity.dy * 0.5);
      }
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('磁性粒子流', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            pointerPosition = details.localPosition;
          });
        },
        onPanEnd: (details) {
          setState(() {
            pointerPosition = null;
          });
        },
        child: Stack(
          children: [
            // 粒子绘制层
            CustomPaint(
              painter: ParticlePainter(
                particles: particles,
                pointerPosition: pointerPosition,
              ),
              size: Size.infinite,
            ),

            // 中央文本
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '交互式粒子流',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: primaryColor.withOpacity(0.8),
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '触摸屏幕创造粒子流动效果',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.7),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            // 底部指引
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.2),
                        blurRadius: 15,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Text(
                    '拖动手指探索粒子流动',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
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

class Particle {
  Offset position;
  Offset velocity;
  final double size;
  final double opacity;
  final Color color;
  final Offset originalPosition;
  double currentSize;
  double currentOpacity;

  Particle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.opacity,
    required this.color,
    required this.originalPosition,
  })  : currentSize = size,
        currentOpacity = opacity;
}

extension OffsetExtension on Offset {
  Offset normalize() {
    final magnitude = distance;
    if (magnitude == 0) return Offset.zero;
    return this / magnitude;
  }

  Offset clone() {
    return Offset(dx, dy);
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final Offset? pointerPosition;
  final linkDistance = 100.0;

  ParticlePainter({
    required this.particles,
    this.pointerPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 绘制粒子连线
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // 检查粒子距离并绘制连线
    for (int i = 0; i < particles.length; i++) {
      final p1 = particles[i];

      // 绘制鼠标/触摸与附近粒子的连线
      if (pointerPosition != null) {
        final pointerDistance = (p1.position - pointerPosition!).distance;
        if (pointerDistance < linkDistance) {
          final opacity = (1.0 - pointerDistance / linkDistance) * 0.8;
          linePaint.color = p1.color.withOpacity(opacity * 0.5);
          canvas.drawLine(pointerPosition!, p1.position, linePaint);
        }
      }

      // 绘制粒子之间的连线
      for (int j = i + 1; j < particles.length; j++) {
        final p2 = particles[j];
        final distance = (p1.position - p2.position).distance;

        if (distance < linkDistance) {
          final opacity = (1.0 - distance / linkDistance) * 0.3;

          // 使用两个粒子的颜色混合
          final blendedColor = Color.lerp(p1.color, p2.color, 0.5)!;
          linePaint.color = blendedColor.withOpacity(opacity);

          canvas.drawLine(p1.position, p2.position, linePaint);
        }
      }
    }

    // 绘制粒子
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.currentOpacity)
        ..style = PaintingStyle.fill
        ..maskFilter =
            MaskFilter.blur(BlurStyle.normal, particle.currentSize * 0.5);

      // 绘制粒子
      canvas.drawCircle(particle.position, particle.currentSize, paint);

      // 绘制发光核心
      final corePaint = Paint()
        ..color = Colors.white.withOpacity(particle.currentOpacity * 0.7)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
          particle.position, particle.currentSize * 0.4, corePaint);
    }

    // 绘制鼠标/触摸点的光晕效果
    if (pointerPosition != null) {
      final pointerPaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.white.withOpacity(0.15)
        ..strokeWidth = 1
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10);

      // 绘制光晕环
      canvas.drawCircle(pointerPosition!, 50, pointerPaint);
      canvas.drawCircle(pointerPosition!, 100, pointerPaint..strokeWidth = 0.5);

      // 绘制中心点
      canvas.drawCircle(
          pointerPosition!,
          4,
          Paint()
            ..color = Colors.white.withOpacity(0.8)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2));
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) {
    return true; // 每帧都重绘
  }
}

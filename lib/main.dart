import 'package:flutter/material.dart';
import 'package:flutter_100_ui_animations/animation/falling_confett.dart';
import 'package:flutter_100_ui_animations/animation/wave.dart';
import 'package:flutter_100_ui_animations/animation/liquid_loader.dart';
import 'package:flutter_100_ui_animations/animation/magnetic_particles.dart';
import 'package:flutter_100_ui_animations/animation/animated_mesh_gradient.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter 100 UI Animations',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AnimatedContainerDemo(),
    );
  }
}

class AnimatedContainerDemo extends StatefulWidget {
  const AnimatedContainerDemo({super.key});

  @override
  _AnimatedContainerDemoState createState() => _AnimatedContainerDemoState();
}

class _AnimatedContainerDemoState extends State<AnimatedContainerDemo> {
  bool _isExpanded = false;

  void _toggleContainer() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('100 UI Animations 示例'),
      ),
      body: Center(
        // List of animations
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FallingConfettiPage()),
                );
              },
              child: const Text('彩带飘落'),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WaveAnimationPage()),
                );
              },
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('Animate-波浪', style: TextStyle(fontSize: 16)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LiquidLoaderPage()),
                );
              },
              child: Text('流体液态加载动画'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MagneticParticlesPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF007AFF),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text('磁性粒子流', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AnimatedMeshGradientPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade300,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child:
                  const Text('动态网格渐变', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

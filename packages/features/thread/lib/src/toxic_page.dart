import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class ToxicRenderPage extends StatefulWidget {
  const ToxicRenderPage({super.key});

  @override
  State<ToxicRenderPage> createState() => _ToxicRenderPageState();
}

class _ToxicRenderPageState extends State<ToxicRenderPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
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
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://picsum.photos/800/800',
              fit: BoxFit.cover,
            ),
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  100 * cos(_controller.value * 2 * pi),
                  100 * sin(_controller.value * 2 * pi),
                ),
                child: Center(
                  child: ClipPath(
                    clipper: _StarClipper(),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                      child: Container(
                        width: 200,
                        height: 200,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    for (int i = 0; i < 50; i++) {
      path.lineTo(
        Random().nextDouble() * size.width,
        Random().nextDouble() * size.height,
      );
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

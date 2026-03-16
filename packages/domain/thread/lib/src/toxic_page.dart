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
    // 疯狂的 60fps 动画，强制每帧重绘
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
          // 铺满屏幕的复杂背景（模拟图层混合的底部）
          Positioned.fill(
            child: Image.network(
              'https://picsum.photos/800/800',
              fit: BoxFit.cover,
            ),
          ),
          // 致命的动画层
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  100 * cos(_controller.value * 2 * pi),
                  100 * sin(_controller.value * 2 * pi),
                ),
                child: Center(
                  // 毒点 1：极其复杂的自定义裁剪路径 (不规则边缘)
                  child: ClipPath(
                    clipper: _StarClipper(),
                    // 毒点 2：高斯模糊（极其消耗 GPU 算力）
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                      // 毒点 3：半透明图层（引发严重的 Color Blending 图层混合）
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

// 模拟极其复杂的矢量数学计算边缘
class _StarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    // 故意制造大量不规则的曲线节点
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
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true; // 强制每帧重新计算裁剪！
}

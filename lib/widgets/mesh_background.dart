import 'dart:ui';
import 'package:flutter/material.dart';

class MeshBackground extends StatelessWidget {
  final Widget child;
  const MeshBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. The base color
          Container(color: const Color(0xFFF5F7FA)),

          // 2. Blurry "Mesh" blobs
          Positioned(
            top: -100,
            right: -50,
            child: _BlurBlob(color: Colors.blue.withOpacity(0.4), size: 300),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: _BlurBlob(color: Colors.orange.withOpacity(0.3), size: 250),
          ),

          // 3. The Blur Filter
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
            child: Container(color: Colors.transparent),
          ),

          // 4. The actual screen content
          SafeArea(child: child),
        ],
      ),
    );
  }
}

class _BlurBlob extends StatelessWidget {
  final Color color;
  final double size;
  const _BlurBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
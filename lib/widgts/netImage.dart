// lib/widgets/net_image.dart
import 'package:flutter/material.dart';

class NetImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;

  const NetImage(this.url, {super.key, this.fit = BoxFit.cover, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      // keeps layout stable while loading
      loadingBuilder: (ctx, child, evt) {
        if (evt == null) return child;
        return ColoredBox(
          color: const Color(0xFFE5E7EB),
          child: const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
        );
      },
      // prevents exceptions and overflow when 404/timeout
      errorBuilder: (ctx, err, st) {
        return ColoredBox(
          color: const Color(0xFFE5E7EB),
          child: const Center(child: Icon(Icons.broken_image, size: 32, color: Color(0xFF6B7280))),
        );
      },
    );
  }
}
 
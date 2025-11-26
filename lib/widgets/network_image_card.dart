import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class NetworkImageCard extends StatelessWidget {
  final String url;
  final double height;
  final BorderRadius borderRadius;

  const NetworkImageCard({
    super.key,
    required this.url,
    required this.height,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: borderRadius,
      child: CachedNetworkImage(
        imageUrl: url,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          height: height,
          color: cs.surfaceContainerHighest,
          alignment: Alignment.center,
          child: const SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (_, __, ___) => Container(
          height: height,
          color: cs.surfaceContainerHighest,
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image_outlined),
        ),
      ),
    );
  }
}

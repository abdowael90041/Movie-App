import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';

class MoviePoster extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BorderRadius borderRadius;

  const MoviePoster({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  Widget build(BuildContext context) {
    if (path.isEmpty) return _placeholder();

    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.network(
        '${AppConstants.tmdbImageBaseUrl}$path',
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            width: width,
            height: height,
            alignment: Alignment.center,
            color: Colors.grey.shade200,
            child: const CircularProgressIndicator(strokeWidth: 2),
          );
        },
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: const Icon(Icons.movie_outlined, size: 32),
    );
  }
}

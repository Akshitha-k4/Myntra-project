import 'package:flutter/material.dart';

class CachedImage extends StatelessWidget {
  final String? url;
  final double? height;
  final double width;
  final BoxShape shape;

  CachedImage({this.url, this.height, this.width = double.infinity, this.shape = BoxShape.circle});

  @override
  Widget build(BuildContext context) {
    return url != null && url!.isNotEmpty
        ? Image.network(
            url!,
            height: height,
            width: width,
            fit: BoxFit.fill,
            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
          )
        : _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: shape,
      ),
      child: Image.asset(
        'assets/blank_image.png', // Replace with your placeholder image path
        fit: BoxFit.cover,
      ),
    );
  }
}

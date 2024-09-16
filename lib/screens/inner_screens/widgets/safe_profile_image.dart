import 'package:flutter/material.dart';

class SafeProfileImage extends StatelessWidget {
  final String? imageUrl;
  final double size;

  const SafeProfileImage({Key? key, this.imageUrl, this.size = 100})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildDefaultAvatar();
    } else {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: NetworkImage(imageUrl!),
        onBackgroundImageError: (exception, stackTrace) {
          //Error Log
          print('Error loading image: $exception');
        },
        child:
            imageUrl == null || imageUrl!.isEmpty ? _buildDefaultIcon() : null,
      );
    }
  }

  Widget _buildDefaultAvatar() {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: Colors.grey[300],
      child: _buildDefaultIcon(),
    );
  }

  Widget _buildDefaultIcon() {
    return Icon(Icons.person, size: size * 0.6, color: Colors.grey[600]);
  }
}

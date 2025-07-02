import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tuncbt/core/enums/message_enum.dart';
import 'package:tuncbt/view/screens/chat/widgets/video_player_item.dart';

class DisplayTextImageGIF extends StatelessWidget {
  final String message;
  final String? mediaUrl;
  final MessageType type;

  const DisplayTextImageGIF({
    Key? key,
    required this.message,
    required this.type,
    this.mediaUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isPlaying = false;
    final AudioPlayer audioPlayer = AudioPlayer();

    Widget _buildImageWidget(String url) {
      return Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
          maxHeight: 150, // Reply preview için daha küçük
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            errorWidget: (context, url, error) {
              print('Image error: $error for URL: $url');
              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error, color: Colors.red[400]),
                    const SizedBox(height: 4),
                    const Text(
                      'Image not available',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    }

    switch (type) {
      case MessageType.text:
        return Text(
          message,
          style: const TextStyle(fontSize: 16),
        );

      case MessageType.image:
        final imageUrl = mediaUrl ?? message;
        print('Displaying image with URL: $imageUrl');
        return _buildImageWidget(imageUrl);

      case MessageType.gif:
        return _buildImageWidget(message);

      case MessageType.video:
        return VideoPlayerItem(
          videoUrl: mediaUrl ?? message,
        );

      case MessageType.audio:
        return StatefulBuilder(
          builder: (context, setState) {
            return IconButton(
              constraints: const BoxConstraints(
                minWidth: 100,
              ),
              onPressed: () async {
                if (isPlaying) {
                  await audioPlayer.pause();
                  setState(() {
                    isPlaying = false;
                  });
                } else {
                  await audioPlayer.play(UrlSource(mediaUrl ?? message));
                  setState(() {
                    isPlaying = true;
                  });
                }
              },
              icon: Icon(
                isPlaying ? Icons.pause_circle : Icons.play_circle,
              ),
            );
          },
        );

      default:
        return Text(message);
    }
  }
}

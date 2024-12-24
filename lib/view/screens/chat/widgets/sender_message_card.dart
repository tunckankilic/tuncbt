import 'package:flutter/material.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:tuncbt/core/enums/message_enum.dart';
import 'package:tuncbt/view/screens/chat/widgets/display_text_image_gif.dart';

class SenderMessageCard extends StatelessWidget {
  final String message;
  final String date;
  final MessageType type;
  final String? mediaUrl;
  final VoidCallback onRightSwipe;
  final String? replyTo;
  final String? repliedTo;
  final MessageType? repliedMessageType;

  const SenderMessageCard({
    Key? key,
    required this.message,
    required this.date,
    required this.type,
    this.mediaUrl,
    required this.onRightSwipe,
    this.replyTo,
    this.repliedTo,
    this.repliedMessageType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isReplying = replyTo != null && replyTo!.isNotEmpty;

    return SwipeTo(
      onRightSwipe: (details) => onRightSwipe(),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 45,
          ),
          child: Card(
            elevation: 1,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            color: Colors.grey[800],
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Stack(
              children: [
                Padding(
                  padding: type == MessageType.text
                      ? const EdgeInsets.only(
                          left: 10,
                          right: 30,
                          top: 5,
                          bottom: 20,
                        )
                      : const EdgeInsets.only(
                          left: 5,
                          top: 5,
                          right: 5,
                          bottom: 25,
                        ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isReplying) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.yellow.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                repliedTo ?? 'Reply',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 2),
                              DisplayTextImageGIF(
                                message: replyTo!,
                                type: repliedMessageType ?? MessageType.text,
                                mediaUrl: mediaUrl,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      DisplayTextImageGIF(
                        message: message,
                        type: type,
                        mediaUrl: mediaUrl,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 10,
                  child: Text(
                    date,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white60,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

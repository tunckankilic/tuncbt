import 'package:flutter/material.dart';
import 'package:tuncbt/view/screens/chat/chat_controller.dart';
import 'package:tuncbt/view/screens/chat/widgets/display_text_image_gif.dart';
import 'package:get/get.dart';

class MessageReplyPreview extends GetView<ChatController> {
  const MessageReplyPreview({Key? key}) : super(key: key);

  void cancelReply() {
    controller.messageReply.value = null;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final messageReply = controller.messageReply.value;
      if (messageReply == null) return const SizedBox();

      return Container(
        width: 350,
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    messageReply.isMe ? 'Me' : 'Opposite',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                GestureDetector(
                  child: const Icon(
                    Icons.close,
                    size: 16,
                  ),
                  onTap: cancelReply,
                ),
              ],
            ),
            const SizedBox(height: 8),
            DisplayTextImageGIF(
              message: messageReply.message,
              type: messageReply.messageEnum,
            ),
          ],
        ),
      );
    });
  }
}

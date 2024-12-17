import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuncbt/view/screens/chat/chat_controller.dart';
import 'package:tuncbt/view/screens/chat/widgets/message_reply_preview.dart';

class BottomChatField extends GetView<ChatController> {
  final String receiverUserId;
  final bool isGroupChat;

  const BottomChatField({
    Key? key,
    required this.receiverUserId,
    required this.isGroupChat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(() => controller.messageReply.value != null
            ? const MessageReplyPreview()
            : const SizedBox()),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller.messageController,
                onChanged: controller.onMessageChanged,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.green,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: controller.toggleEmojiKeyboardContainer,
                            icon: const Icon(
                              Icons.emoji_emotions,
                              color: Colors.grey,
                            ),
                          ),
                          IconButton(
                            onPressed: () => controller.sendGIFMessage(
                              receiverUserId,
                              isGroupChat,
                            ),
                            icon: const Icon(
                              Icons.gif,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // ... rest of your decoration
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8, right: 2, left: 2),
              child: CircleAvatar(
                backgroundColor: const Color(0xFF128C7E),
                radius: 25,
                child: Obx(
                  () => GestureDetector(
                    child: Icon(
                      controller.isShowSendButton.value
                          ? Icons.send
                          : controller.isRecording.value
                              ? Icons.close
                              : Icons.mic,
                      color: Colors.white,
                    ),
                    onTap: () => controller.sendTextMessage(
                      receiverUserId,
                      isGroupChat,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Obx(() => controller.isShowEmojiContainer.value
            ? SizedBox(
                height: 310,
                child: EmojiPicker(
                  onEmojiSelected: ((category, emoji) {
                    controller.messageController.text += emoji.emoji;
                    if (!controller.isShowSendButton.value) {
                      controller.isShowSendButton.value = true;
                    }
                  }),
                ),
              )
            : const SizedBox()),
      ],
    );
  }
}

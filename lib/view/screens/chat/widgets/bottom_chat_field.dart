import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuncbt/view/screens/chat/chat_controller.dart';
import 'package:tuncbt/view/screens/chat/widgets/message_reply_preview.dart';

class BottomChatField extends GetView<ChatController> {
  final String receiverUserId;
  final bool isGroupChat;

  BottomChatField({
    Key? key,
    required this.receiverUserId,
    required this.isGroupChat,
  }) : super(key: key);

  void _showAttachmentOptions(BuildContext context) {
    controller.showAttachmentOptions(context, receiverUserId, isGroupChat);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Column(
        children: [
          Obx(() => controller.messageReply.value != null
              ? const MessageReplyPreview()
              : const SizedBox()),
          Row(
            children: [
              // Dosya ekleme butonu
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(25),
                  onTap: () => _showAttachmentOptions(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.attach_file,
                      color: Color(0xFF128C7E),
                      size: 24,
                    ),
                  ),
                ),
              ),
              // Mesaj yazma alanı
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      // Emoji butonu
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(25),
                          onTap: controller.toggleEmojiKeyboardContainer,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              Icons.emoji_emotions,
                              color: Colors.grey[600],
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      // TextField
                      Expanded(
                        child: TextFormField(
                          controller: controller.messageController,
                          onChanged: controller.onMessageChanged,
                          style: const TextStyle(fontSize: 16),
                          decoration: const InputDecoration(
                            hintText: 'Mesaj yazın',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Gönder butonu
              Obx(() {
                final isShowSend = controller.isShowSendButton.value;
                final isSending = controller.isSending.value;

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(25),
                    onTap: (isShowSend && !isSending)
                        ? () => controller.handleSendMessage(
                              context,
                              receiverUserId,
                              isGroupChat,
                            )
                        : null,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            isSending ? Colors.grey : const Color(0xFF128C7E),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
          // Emoji klavyesi
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
      ),
    );
  }
}

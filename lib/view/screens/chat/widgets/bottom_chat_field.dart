import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuncbt/view/screens/chat/chat_controller.dart';
import 'package:tuncbt/view/screens/chat/widgets/message_reply_preview.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:tuncbt/core/enums/message_enum.dart';

class BottomChatField extends GetView<ChatController> {
  final String receiverUserId;
  final bool isGroupChat;

  const BottomChatField({
    Key? key,
    required this.receiverUserId,
    required this.isGroupChat,
  }) : super(key: key);

  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo),
            title: const Text('Photo'),
            onTap: () async {
              Navigator.pop(context);
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(
                source: ImageSource.gallery,
                imageQuality: 70,
              );
              if (image != null) {
                await controller.sendFileMessage(
                  context,
                  File(image.path),
                  receiverUserId,
                  MessageType.image,
                  isGroupChat,
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.videocam),
            title: const Text('Video'),
            onTap: () async {
              Navigator.pop(context);
              final ImagePicker picker = ImagePicker();
              final XFile? video = await picker.pickVideo(
                source: ImageSource.gallery,
              );
              if (video != null) {
                await controller.sendFileMessage(
                  context,
                  File(video.path),
                  receiverUserId,
                  MessageType.video,
                  isGroupChat,
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.mic),
            title: const Text('Audio'),
            onTap: () async {
              Navigator.pop(context);
              final FilePickerResult? result =
                  await FilePicker.platform.pickFiles(
                type: FileType.audio,
              );
              if (result != null) {
                await controller.sendFileMessage(
                  context,
                  File(result.files.single.path!),
                  receiverUserId,
                  MessageType.audio,
                  isGroupChat,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(() => controller.messageReply.value != null
            ? const MessageReplyPreview()
            : const SizedBox()),
        Row(
          children: [
            IconButton(
              onPressed: () => _showAttachmentOptions(context),
              icon: const Icon(Icons.attach_file, color: Colors.grey),
            ),
            Expanded(
              child: TextFormField(
                controller: controller.messageController,
                onChanged: controller.onMessageChanged,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
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
                          // IconButton(
                          //   onPressed: () => controller.showGifPicker(
                          //       context, receiverUserId),
                          //   icon: const Icon(
                          //     Icons.gif,
                          //     color: Colors.grey,
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                  hintText: 'Type a message',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide.none,
                  ),
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
                      context,
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

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tuncbt/core/models/user_model.dart';
import 'package:tuncbt/view/screens/chat/chat_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../l10n/app_localizations.dart';

class CreateGroupScreen extends StatefulWidget {
  static const routeName = '/create-group';

  const CreateGroupScreen({Key? key}) : super(key: key);

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _selectedMembers = <UserModel>{}.obs;
  File? _groupImage;
  final _chatController = Get.find<ChatController>();

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image != null) {
      setState(() {
        _groupImage = File(image.path);
      });
    }
  }

  Future<void> _createGroup() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMembers.isEmpty) {
      Get.snackbar(
        AppLocalizations.of(context)!.error,
        AppLocalizations.of(context)!.selectMembers,
        backgroundColor: Colors.red.withOpacity(0.1),
      );
      return;
    }

    try {
      await _chatController.createGroup(
        name: _nameController.text,
        description: _descriptionController.text,
        members: _selectedMembers.map((user) => user.id).toList(),
        imageFile: _groupImage,
      );

      Get.back();
      Get.snackbar(
        AppLocalizations.of(context)!.success,
        AppLocalizations.of(context)!.groupCreated,
        backgroundColor: Colors.green.withOpacity(0.1),
      );
    } catch (e) {
      Get.snackbar(
        AppLocalizations.of(context)!.error,
        AppLocalizations.of(context)!.groupCreationError,
        backgroundColor: Colors.red.withOpacity(0.1),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.newGroup),
        actions: [
          TextButton(
            onPressed: _createGroup,
            child: Text(
              l10n.create,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  backgroundImage:
                      _groupImage != null ? FileImage(_groupImage!) : null,
                  child: _groupImage == null
                      ? const Icon(Icons.camera_alt,
                          size: 40, color: Colors.grey)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.groupName,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.fieldRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.groupDescription,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.groupMembers,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              FutureBuilder<List<UserModel>>(
                future: _chatController.getTeamMembers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(l10n.noMembers),
                    );
                  }

                  return Obx(() => ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final user = snapshot.data![index];
                          final isSelected = _selectedMembers.contains(user);

                          return CheckboxListTile(
                            value: isSelected,
                            onChanged: (value) {
                              if (value == true) {
                                _selectedMembers.add(user);
                              } else {
                                _selectedMembers.remove(user);
                              }
                            },
                            title: Text(user.name),
                            subtitle: Text(user.position),
                            secondary: CircleAvatar(
                              backgroundColor: Colors.grey[200],
                              backgroundImage: user.imageUrl.isNotEmpty
                                  ? CachedNetworkImageProvider(user.imageUrl)
                                  : null,
                              child: user.imageUrl.isEmpty
                                  ? const Icon(Icons.person, color: Colors.grey)
                                  : null,
                            ),
                          );
                        },
                      ));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

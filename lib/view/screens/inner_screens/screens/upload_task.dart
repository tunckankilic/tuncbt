import 'package:flutter/material.dart';

class UploadTaskScreen extends StatelessWidget {
  static const routeName = '/upload-task';

  const UploadTaskScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Task'),
      ),
      body: Center(
        child: Text('Upload Task Screen'),
      ),
    );
  }
}

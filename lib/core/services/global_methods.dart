import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tuncbt/core/config/constants.dart';

class GlobalMethod {
  static void showErrorDialog({
    required String error,
    required BuildContext context,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: _buildDialogTitle(),
          content: _buildDialogContent(error),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  static Widget _buildDialogTitle() {
    return Row(
      children: [
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.person,
              size: 20.r,
            )),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Error occurred'),
        ),
      ],
    );
  }

  static Widget _buildDialogContent(String error) {
    return Text(
      error,
      style: TextStyle(
        color: Constants.darkBlue,
        fontSize: 20,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}

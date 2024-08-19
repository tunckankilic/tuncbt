import 'package:flutter/material.dart';
import 'package:tuncbt/constants/constants.dart';

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
          child: Image.network(
            'https://image.flaticon.com/icons/png/128/1252/1252006.png',
            height: 20,
            width: 20,
          ),
        ),
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

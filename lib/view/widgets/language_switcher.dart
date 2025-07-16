import 'package:flutter/material.dart';
import 'package:tuncbt/main.dart';

const String LANGUAGE_CODE = 'languageCode';

class LanguageSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: Localizations.localeOf(context).languageCode,
      items: const [
        DropdownMenuItem(value: 'tr', child: Text('Türkçe')),
        DropdownMenuItem(value: 'en', child: Text('English')),
        DropdownMenuItem(value: 'de', child: Text('Deutsch')),
      ],
      onChanged: (String? newValue) {
        if (newValue != null) {
          MyAppState.key.currentState?.changeLanguage(newValue);
        }
      },
    );
  }
}

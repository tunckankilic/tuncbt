import 'package:flutter/material.dart';
import 'package:tuncbt/main.dart';

const String LANGUAGE_CODE = 'languageCode';

class LanguageSwitcher extends StatelessWidget {
  final bool isLargeTablet;

  const LanguageSwitcher({
    Key? key,
    this.isLargeTablet = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: Localizations.localeOf(context).languageCode,
      items: [
        DropdownMenuItem(
          value: 'tr',
          child: Text(
            'Türkçe',
            style: TextStyle(
              fontSize: isLargeTablet ? 16.0 : 14.0,
            ),
          ),
        ),
        DropdownMenuItem(
          value: 'en',
          child: Text(
            'English',
            style: TextStyle(
              fontSize: isLargeTablet ? 16.0 : 14.0,
            ),
          ),
        ),
        DropdownMenuItem(
          value: 'de',
          child: Text(
            'Deutsch',
            style: TextStyle(
              fontSize: isLargeTablet ? 16.0 : 14.0,
            ),
          ),
        ),
      ],
      onChanged: (String? newValue) {
        if (newValue != null) {
          MyAppState.key.currentState?.changeLanguage(newValue);
        }
      },
      iconSize: isLargeTablet ? 28.0 : 24.0,
      itemHeight: isLargeTablet ? 56.0 : 48.0,
      style: TextStyle(
        fontSize: isLargeTablet ? 16.0 : 14.0,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      dropdownColor: Theme.of(context).cardColor,
      elevation: isLargeTablet ? 8 : 4,
      borderRadius: BorderRadius.circular(isLargeTablet ? 12.0 : 8.0),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:tuncbt/l10n/app_localizations.dart';

const String LANGUAGE_CODE = 'languageCode';

class LanguageSwitcher extends StatefulWidget {
  const LanguageSwitcher({super.key});

  @override
  State<LanguageSwitcher> createState() => _LanguageSwitcherState();
}

class _LanguageSwitcherState extends State<LanguageSwitcher> {
  String _currentLanguage = 'tr'; // Varsayılan dil
  final List<Map<String, String>> _languages = [
    {'code': 'tr', 'name': 'Türkçe'},
    {'code': 'en', 'name': 'English'},
    {'code': 'de', 'name': 'Deutsch'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(LANGUAGE_CODE) ?? 'tr';
    setState(() {
      _currentLanguage = savedLanguage;
    });
  }

  Future<void> _changeLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(LANGUAGE_CODE, languageCode);

    setState(() {
      _currentLanguage = languageCode;
    });

    // GetX ile dil değişikliğini uygula
    Get.updateLocale(Locale(languageCode));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: DropdownButtonFormField<String>(
        value: _currentLanguage,
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.language,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        items: _languages.map((language) {
          return DropdownMenuItem(
            value: language['code'],
            child: Text(language['name']!),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            _changeLanguage(value);
          }
        },
      ),
    );
  }
}

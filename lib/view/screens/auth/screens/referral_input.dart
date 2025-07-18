import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tuncbt/core/services/referral_service.dart';
import 'package:tuncbt/l10n/app_localizations.dart';

class ReferralInputScreen extends StatefulWidget {
  const ReferralInputScreen({super.key});

  @override
  State<ReferralInputScreen> createState() => _ReferralInputScreenState();
}

class _ReferralInputScreenState extends State<ReferralInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _referralController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 500);
  bool _isLoading = false;
  bool _isValid = false;
  String? _errorMessage;

  @override
  void dispose() {
    _referralController.dispose();
    super.dispose();
  }

  void _validateReferralCode(String value) {
    if (value.length != 8) {
      setState(() {
        _isValid = false;
        _errorMessage = 'Referans kodu 8 karakter olmalıdır';
      });
      return;
    }

    setState(() => _isLoading = true);

    _debouncer.run(() async {
      try {
        final referralService = ReferralService();
        final result = await referralService.validateCode(value);
        setState(() {
          _isValid = result.isValid;
          _errorMessage = result.isValid
              ? null
              : (result.error?.message ?? 'Geçersiz referans kodu');
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isValid = false;
          _errorMessage = 'Doğrulama sırasında bir hata oluştu';
          _isLoading = false;
        });
      }
    });
  }

  void _showInfoDialog() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeTablet = screenWidth >= 1200;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.referralCodeTitle,
          style: TextStyle(
            fontSize: isLargeTablet ? 24.0 : 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Container(
          width: isLargeTablet ? 600.0 : null,
          child: Text(
            AppLocalizations.of(context)!.referralCodeDescription,
            style: TextStyle(
              fontSize: isLargeTablet ? 18.0 : 16.0,
            ),
          ),
        ),
        contentPadding: EdgeInsets.all(isLargeTablet ? 24.0 : 16.0),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                vertical: isLargeTablet ? 16.0 : 12.0,
                horizontal: isLargeTablet ? 24.0 : 16.0,
              ),
            ),
            child: Text(
              AppLocalizations.of(context)!.ok,
              style: TextStyle(
                fontSize: isLargeTablet ? 18.0 : 16.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.referralCode),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLargeTablet = constraints.maxWidth >= 1200;
          final horizontalPadding =
              isLargeTablet ? constraints.maxWidth * 0.2 : 16.0;

          return Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isLargeTablet ? 800.0 : double.infinity,
              ),
              padding: EdgeInsets.all(horizontalPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _referralController,
                            style: TextStyle(
                              fontSize: isLargeTablet ? 18.0 : 16.0,
                            ),
                            decoration: InputDecoration(
                              labelText:
                                  AppLocalizations.of(context)!.referralCode,
                              labelStyle: TextStyle(
                                fontSize: isLargeTablet ? 20.0 : 16.0,
                              ),
                              hintText: 'XXXXXXXX',
                              hintStyle: TextStyle(
                                fontSize: isLargeTablet ? 18.0 : 16.0,
                              ),
                              errorText: _errorMessage,
                              errorStyle: TextStyle(
                                fontSize: isLargeTablet ? 16.0 : 14.0,
                              ),
                              suffixIcon: _isLoading
                                  ? SizedBox(
                                      width: isLargeTablet ? 28.0 : 20.0,
                                      height: isLargeTablet ? 28.0 : 20.0,
                                      child: CircularProgressIndicator(
                                        strokeWidth: isLargeTablet ? 3.0 : 2.0,
                                      ),
                                    )
                                  : _isValid
                                      ? Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                          size: isLargeTablet ? 28.0 : 24.0,
                                        )
                                      : null,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: isLargeTablet ? 20.0 : 16.0,
                                horizontal: isLargeTablet ? 24.0 : 16.0,
                              ),
                            ),
                            inputFormatters: [
                              UpperCaseTextFormatter(),
                              LengthLimitingTextInputFormatter(8),
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[A-Z0-9]')),
                            ],
                            onChanged: _validateReferralCode,
                            textCapitalization: TextCapitalization.characters,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.info_outline,
                            size: isLargeTablet ? 28.0 : 24.0,
                          ),
                          padding: EdgeInsets.all(isLargeTablet ? 16.0 : 12.0),
                          onPressed: _showInfoDialog,
                        ),
                      ],
                    ),
                    SizedBox(height: isLargeTablet ? 32.0 : 24.0),
                    ElevatedButton(
                      onPressed: _isValid
                          ? () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() => _isLoading = true);
                                try {
                                  final referralService = ReferralService();
                                  final result = await referralService
                                      .validateCode(_referralController.text);

                                  if (result.isValid) {
                                    Get.toNamed('/auth/register', arguments: {
                                      'referralCode': _referralController.text
                                    });
                                  } else {
                                    setState(() {
                                      _errorMessage = result.error?.message ??
                                          'Geçersiz referans kodu';
                                      _isValid = false;
                                    });
                                  }
                                } catch (e) {
                                  setState(() {
                                    _errorMessage = 'Bir hata oluştu: $e';
                                    _isValid = false;
                                  });
                                } finally {
                                  setState(() => _isLoading = false);
                                }
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: isLargeTablet ? 24.0 : 16.0,
                          horizontal: isLargeTablet ? 32.0 : 24.0,
                        ),
                      ),
                      child: Text(
                        'Devam Et',
                        style: TextStyle(
                          fontSize: isLargeTablet ? 20.0 : 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

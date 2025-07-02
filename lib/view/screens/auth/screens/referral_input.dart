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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.referralCodeTitle),
        content: Text(AppLocalizations.of(context)!.referralCodeDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.ok),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.referralCode,
                        hintText: 'XXXXXXXX',
                        errorText: _errorMessage,
                        suffixIcon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : _isValid
                                ? const Icon(Icons.check_circle,
                                    color: Colors.green)
                                : null,
                      ),
                      inputFormatters: [
                        UpperCaseTextFormatter(),
                        LengthLimitingTextInputFormatter(8),
                        FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                      ],
                      onChanged: _validateReferralCode,
                      textCapitalization: TextCapitalization.characters,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: _showInfoDialog,
                  ),
                ],
              ),
              const SizedBox(height: 24),
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
                child: const Text('Devam Et'),
              ),
            ],
          ),
        ),
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

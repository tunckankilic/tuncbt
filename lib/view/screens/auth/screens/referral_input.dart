import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tuncbt/core/services/referral_service.dart';

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
        final isValid = await ReferralService().validateReferralCode(value);
        setState(() {
          _isValid = isValid;
          _errorMessage = isValid ? null : 'Geçersiz referans kodu';
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
        title: const Text('Referans Kodu Nedir?'),
        content: const Text(
          'Referans kodu, mevcut bir kullanıcıdan aldığınız 8 karakterlik özel bir koddur. '
          'Bu kod ile sisteme kayıt olarak ekstra avantajlardan yararlanabilirsiniz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anladım'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Referans Kodu'),
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
                        labelText: 'Referans Kodu',
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
                    ? () {
                        if (_formKey.currentState!.validate()) {
                          // TODO: Handle referral code submission
                          Get.toNamed('/auth/register', arguments: {
                            'referralCode': _referralController.text
                          });
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

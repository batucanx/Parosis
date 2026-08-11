import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:parosis_sulama/core/permissions/onboarding_permissions.dart';
import 'package:parosis_sulama/core/validation/auth_validators.dart';
import 'package:parosis_sulama/features/auth/presentation/controllers/auth_controller.dart';
import 'package:parosis_sulama/features/auth/presentation/widgets/auth_buttons.dart';
import 'package:parosis_sulama/features/auth/presentation/widgets/auth_input_formatters.dart';
import 'package:parosis_sulama/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:parosis_sulama/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:parosis_sulama/icons/app_icons.dart';
import 'package:parosis_sulama/theme/colors.dart';
import 'package:parosis_sulama/theme/text_styles.dart';
import 'package:parosis_sulama/widgets/pressable_scale.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    required this.controller,
    required this.onBackToLogin,
  });

  final AuthController controller;
  final VoidCallback onBackToLogin;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _tcKimlikCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  final _emailFocus = FocusNode();
  final _tcKimlikFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  String? _fullNameError;
  String? _emailError;
  String? _tcKimlikError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _tcKimlikCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _emailFocus.dispose();
    _tcKimlikFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final phoneDigits = _phoneCtrl.text.replaceAll(RegExp(r'\D'), '');
    final fullNameError = validateFullName(_fullNameCtrl.text);
    final emailError = validateEmail(_emailCtrl.text);
    final tcKimlikError = validateTcKimlik(_tcKimlikCtrl.text);
    final phoneError = validatePhoneDigits(phoneDigits);
    final passwordError = validatePassword(_passwordCtrl.text);
    final confirmPasswordError = validateConfirmPassword(
      _passwordCtrl.text,
      _confirmPasswordCtrl.text,
    );

    setState(() {
      _fullNameError = fullNameError;
      _emailError = emailError;
      _tcKimlikError = tcKimlikError;
      _phoneError = phoneError;
      _passwordError = passwordError;
      _confirmPasswordError = confirmPasswordError;
    });

    if ([
      fullNameError,
      emailError,
      tcKimlikError,
      phoneError,
      passwordError,
      confirmPasswordError,
    ].any((e) => e != null)) {
      return;
    }

    final success = await widget.controller.register(
      fullName: _fullNameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      tcKimlik: _tcKimlikCtrl.text,
      phone: phoneDigits,
      password: _passwordCtrl.text,
    );
    if (success) {
      unawaited(requestOnboardingPermissions());
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) {
      final controller = widget.controller;
      return AuthScaffold(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Hesap Oluştur',
              textAlign: TextAlign.center,
              style: figtree(
                size: 20,
                weight: W.extrabold,
                tracking: Tracking.tight,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Bilgilerinizi girin, kuyularınızı yönetmeye başlayın',
              textAlign: TextAlign.center,
              style: figtree(
                size: 12.5,
                weight: W.medium,
                color: AppColors.inkSoft,
              ),
            ),
            const SizedBox(height: 22),
            AuthTextField(
              controller: _fullNameCtrl,
              label: 'Ad Soyad',
              hint: 'Adınız Soyadınız',
              iconBuilder: (c) => AppIcons.user(size: 19, color: c),
              errorText: _fullNameError,
              onSubmitted: (_) => FocusScope.of(context).requestFocus(_emailFocus),
              autofillHints: const [AutofillHints.name],
            ),
            const SizedBox(height: 14),
            AuthTextField(
              controller: _emailCtrl,
              focusNode: _emailFocus,
              label: 'E-posta',
              hint: 'ornek@eposta.com',
              iconBuilder: (c) => AppIcons.mail(size: 19, color: c),
              keyboardType: TextInputType.emailAddress,
              errorText: _emailError,
              onSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_tcKimlikFocus),
              autofillHints: const [AutofillHints.email],
            ),
            const SizedBox(height: 14),
            AuthTextField(
              controller: _tcKimlikCtrl,
              focusNode: _tcKimlikFocus,
              label: 'T.C. Kimlik No',
              hint: '12345678901',
              iconBuilder: (c) => AppIcons.idCard(size: 19, color: c),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              errorText: _tcKimlikError,
              onSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_phoneFocus),
            ),
            const SizedBox(height: 14),
            AuthTextField(
              controller: _phoneCtrl,
              focusNode: _phoneFocus,
              label: 'Telefon',
              hint: '05xx xxx xx xx',
              iconBuilder: (c) => AppIcons.phone(size: 19, color: c),
              keyboardType: TextInputType.phone,
              inputFormatters: [TurkishPhoneInputFormatter()],
              errorText: _phoneError,
              onSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_passwordFocus),
              autofillHints: const [AutofillHints.telephoneNumber],
            ),
            const SizedBox(height: 14),
            AuthTextField(
              controller: _passwordCtrl,
              focusNode: _passwordFocus,
              label: 'Şifre',
              hint: 'Güçlü bir şifre oluşturun',
              iconBuilder: (c) => AppIcons.lock(size: 19, color: c),
              obscureText: true,
              errorText: _passwordError,
              onSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_confirmPasswordFocus),
              autofillHints: const [AutofillHints.newPassword],
            ),
            const SizedBox(height: 14),
            AuthTextField(
              controller: _confirmPasswordCtrl,
              focusNode: _confirmPasswordFocus,
              label: 'Şifre Tekrar',
              hint: 'Şifrenizi tekrar girin',
              iconBuilder: (c) => AppIcons.lock(size: 19, color: c),
              obscureText: true,
              errorText: _confirmPasswordError,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              autofillHints: const [AutofillHints.newPassword],
            ),
            if (controller.error != null) ...[
              const SizedBox(height: 12),
              Text(
                controller.error!,
                textAlign: TextAlign.center,
                style: figtree(
                  size: 12.5,
                  weight: W.semibold,
                  color: AppColors.red600,
                ),
              ),
            ],
            const SizedBox(height: 20),
            AuthPrimaryButton(
              label: 'Hesap Oluştur',
              loading: controller.isSubmitting,
              onTap: _submit,
            ),
            const SizedBox(height: 18),
            Center(
              child: PressableScale(
                onTap: widget.onBackToLogin,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Zaten hesabınız var mı? ',
                          style: figtree(
                            size: 12.5,
                            weight: W.medium,
                            color: AppColors.inkSoft,
                          ),
                        ),
                        TextSpan(
                          text: 'Giriş yapın',
                          style: figtree(
                            size: 12.5,
                            weight: W.bold,
                            color: AppColors.brand700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

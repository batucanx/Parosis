import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:parosis_sulama/core/forms/scroll_to_field.dart';
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
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _tcKimlikCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _tcKimlikFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  final _firstNameKey = GlobalKey();
  final _lastNameKey = GlobalKey();
  final _emailKey = GlobalKey();
  final _tcKimlikKey = GlobalKey();
  final _phoneKey = GlobalKey();
  final _passwordKey = GlobalKey();
  final _confirmPasswordKey = GlobalKey();

  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _tcKimlikError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _tcKimlikCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _emailFocus.dispose();
    _tcKimlikFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final phoneDigits = _phoneCtrl.text.replaceAll(RegExp(r'\D'), '');
    final firstNameError = validateFirstName(_firstNameCtrl.text);
    final lastNameError = validateLastName(_lastNameCtrl.text);
    final emailError = validateEmail(_emailCtrl.text);
    final tcKimlikError = validateTcKimlik(_tcKimlikCtrl.text);
    final phoneError = validatePhoneDigits(phoneDigits);
    final passwordError = validatePassword(_passwordCtrl.text);
    final confirmPasswordError = validateConfirmPassword(
      _passwordCtrl.text,
      _confirmPasswordCtrl.text,
    );

    setState(() {
      _firstNameError = firstNameError;
      _lastNameError = lastNameError;
      _emailError = emailError;
      _tcKimlikError = tcKimlikError;
      _phoneError = phoneError;
      _passwordError = passwordError;
      _confirmPasswordError = confirmPasswordError;
    });

    final hasError = [
      firstNameError,
      lastNameError,
      emailError,
      tcKimlikError,
      phoneError,
      passwordError,
      confirmPasswordError,
    ].any((e) => e != null);

    if (hasError) {
      await scrollToFirstError([
        (firstNameError, _firstNameKey, _firstNameFocus),
        (lastNameError, _lastNameKey, _lastNameFocus),
        (emailError, _emailKey, _emailFocus),
        (tcKimlikError, _tcKimlikKey, _tcKimlikFocus),
        (phoneError, _phoneKey, _phoneFocus),
        (passwordError, _passwordKey, _passwordFocus),
        (confirmPasswordError, _confirmPasswordKey, _confirmPasswordFocus),
      ]);
      return;
    }

    final fullName =
        '${_firstNameCtrl.text.trim()} ${_lastNameCtrl.text.trim()}'.trim();
    final success = await widget.controller.register(
      fullName: fullName,
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
        onBack: widget.onBackToLogin,
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
            const SizedBox(height: 22),
            AuthTextField(
              key: _firstNameKey,
              controller: _firstNameCtrl,
              focusNode: _firstNameFocus,
              label: 'Ad',
              hint: 'Adınız',
              iconBuilder: (c) => AppIcons.user(size: 19, color: c),
              errorText: _firstNameError,
              onSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_lastNameFocus),
              autofillHints: const [AutofillHints.givenName],
            ),
            const SizedBox(height: 14),
            AuthTextField(
              key: _lastNameKey,
              controller: _lastNameCtrl,
              focusNode: _lastNameFocus,
              label: 'Soyad',
              hint: 'Soyadınız',
              iconBuilder: (c) => AppIcons.user(size: 19, color: c),
              errorText: _lastNameError,
              onSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_emailFocus),
              autofillHints: const [AutofillHints.familyName],
            ),
            const SizedBox(height: 14),
            AuthTextField(
              key: _emailKey,
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
              key: _tcKimlikKey,
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
              key: _phoneKey,
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
              key: _passwordKey,
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
              key: _confirmPasswordKey,
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

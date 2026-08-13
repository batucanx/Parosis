import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:parosis_sulama/core/forms/scroll_to_field.dart';
import 'package:parosis_sulama/core/permissions/onboarding_permissions.dart';
import 'package:parosis_sulama/core/validation/auth_validators.dart';
import 'package:parosis_sulama/features/auth/presentation/controllers/auth_controller.dart';
import 'package:parosis_sulama/features/auth/presentation/widgets/auth_buttons.dart';
import 'package:parosis_sulama/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:parosis_sulama/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:parosis_sulama/icons/app_icons.dart';
import 'package:parosis_sulama/theme/colors.dart';
import 'package:parosis_sulama/theme/text_styles.dart';
import 'package:parosis_sulama/widgets/pressable_scale.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.controller,
    required this.onForgotPassword,
    required this.onRegister,
  });

  final AuthController controller;
  final VoidCallback onForgotPassword;
  final VoidCallback onRegister;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _emailKey = GlobalKey();
  final _passwordKey = GlobalKey();

  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final emailError = validateEmail(_emailCtrl.text);
    final passwordError = _passwordCtrl.text.isEmpty ? 'Şifre gerekli.' : null;
    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
    });
    if (emailError != null || passwordError != null) {
      await scrollToFirstError([
        (emailError, _emailKey, _emailFocus),
        (passwordError, _passwordKey, _passwordFocus),
      ]);
      return;
    }

    final success = await widget.controller.login(
      email: _emailCtrl.text,
      password: _passwordCtrl.text,
    );
    if (success) {
      unawaited(requestOnboardingPermissions());
    }
  }

  Future<void> _loginWithGoogle() async {
    final success = await widget.controller.loginWithGoogle();
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
              'Parosis Sulama Sistemleri',
              textAlign: TextAlign.center,
              style: figtree(
                size: 20,
                weight: W.extrabold,
                tracking: Tracking.tight,
              ),
            ),
            const SizedBox(height: 22),
            AuthTextField(
              key: _emailKey,
              controller: _emailCtrl,
              focusNode: _emailFocus,
              label: 'E-posta Adresi',
              hint: 'you@example.com',
              iconBuilder: (c) => AppIcons.mail(size: 19, color: c),
              keyboardType: TextInputType.emailAddress,
              errorText: _emailError,
              onSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_passwordFocus),
              autofillHints: const [AutofillHints.email],
            ),
            const SizedBox(height: 16),
            AuthTextField(
              key: _passwordKey,
              controller: _passwordCtrl,
              focusNode: _passwordFocus,
              label: 'Şifre',
              hint: 'Şifrenizi girin',
              iconBuilder: (c) => AppIcons.lock(size: 19, color: c),
              obscureText: true,
              errorText: _passwordError,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              autofillHints: const [AutofillHints.password],
            ),
            const SizedBox(height: 8),
            Center(
              child: PressableScale(
                onTap: widget.onForgotPassword,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Şifremi unuttum?',
                    style: figtree(
                      size: 13,
                      weight: W.bold,
                      color: AppColors.brand700,
                    ),
                  ),
                ),
              ),
            ),
            if (controller.error != null) ...[
              const SizedBox(height: 4),
              Text(
                controller.error!,
                textAlign: TextAlign.center,
                style: figtree(
                  size: 12.5,
                  weight: W.semibold,
                  color: AppColors.red600,
                ),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 6),
            AuthPrimaryButton(
              label: 'Giriş Yap',
              loading: controller.isSubmitting,
              onTap: _submit,
            ),
            const SizedBox(height: 20),
            const AuthOrDivider(),
            const SizedBox(height: 20),
            AuthOutlineButton(
              label: 'Google ile giriş yap',
              onTap: _loginWithGoogle,
              leading: const _GoogleMark(),
            ),
            const SizedBox(height: 12),
            AuthTonalButton(label: 'Kayıt Ol', onTap: widget.onRegister),
          ],
        ),
      );
    },
  );
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) =>
      SvgPicture.asset('assets/icons/google_logo.svg', width: 20, height: 20);
}

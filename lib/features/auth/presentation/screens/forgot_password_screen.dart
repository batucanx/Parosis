import 'package:flutter/material.dart';

import 'package:parosis_sulama/core/forms/scroll_to_field.dart';
import 'package:parosis_sulama/core/validation/auth_validators.dart';
import 'package:parosis_sulama/features/auth/presentation/controllers/auth_controller.dart';
import 'package:parosis_sulama/features/auth/presentation/widgets/auth_buttons.dart';
import 'package:parosis_sulama/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:parosis_sulama/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:parosis_sulama/icons/app_icons.dart';
import 'package:parosis_sulama/theme/colors.dart';
import 'package:parosis_sulama/theme/text_styles.dart';
import 'package:parosis_sulama/widgets/pressable_scale.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({
    super.key,
    required this.controller,
    required this.onBackToLogin,
  });

  final AuthController controller;
  final VoidCallback onBackToLogin;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _emailKey = GlobalKey();
  String? _emailError;
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final emailError = validateEmail(_emailCtrl.text);
    setState(() => _emailError = emailError);
    if (emailError != null) {
      await scrollToFirstError([(emailError, _emailKey, _emailFocus)]);
      return;
    }

    final success = await widget.controller.sendPasswordResetLink(
      email: _emailCtrl.text,
    );
    if (success && mounted) setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) => AuthScaffold(
      onBack: widget.onBackToLogin,
      child: _sent ? _buildSuccess() : _buildForm(widget.controller),
    ),
  );

  Widget _buildForm(AuthController controller) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        'Şifremi Unuttum',
        textAlign: TextAlign.center,
        style: figtree(
          size: 20,
          weight: W.extrabold,
          color: AppColors.brand700,
          tracking: Tracking.tight,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        'E-posta adresinizi girin, şifre sıfırlama bağlantınızı gönderelim.',
        textAlign: TextAlign.center,
        style: figtree(size: 12.5, weight: W.medium, color: AppColors.inkSoft),
      ),
      const SizedBox(height: 22),
      AuthTextField(
        key: _emailKey,
        controller: _emailCtrl,
        focusNode: _emailFocus,
        label: 'E-posta Adresi',
        hint: 'ornek@email.com',
        iconBuilder: (c) => AppIcons.mail(size: 19, color: c),
        keyboardType: TextInputType.emailAddress,
        errorText: _emailError,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
        autofillHints: const [AutofillHints.email],
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
        label: 'Şifre Sıfırlama Bağlantısı Gönder',
        loading: controller.isSubmitting,
        onTap: _submit,
        icon: AppIcons.mail(size: 17, color: Colors.white),
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
                    text: 'Şifrenizi hatırladınız mı? ',
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
  );

  Widget _buildSuccess() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Center(
        child: Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: AppColors.brand100,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: AppIcons.check(size: 26, color: AppColors.brand700),
          ),
        ),
      ),
      const SizedBox(height: 18),
      Text(
        'Bağlantı Gönderildi',
        textAlign: TextAlign.center,
        style: figtree(size: 19, weight: W.extrabold, tracking: Tracking.tight),
      ),
      const SizedBox(height: 8),
      Text(
        '${_emailCtrl.text.trim()} adresine şifre sıfırlama bağlantısı '
        'gönderdik. Gelen kutunuzu kontrol edin.',
        textAlign: TextAlign.center,
        style: figtree(size: 12.5, weight: W.medium, color: AppColors.inkSoft),
      ),
      const SizedBox(height: 22),
      AuthPrimaryButton(
        label: 'Giriş Ekranına Dön',
        onTap: widget.onBackToLogin,
      ),
    ],
  );
}

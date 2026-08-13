import 'package:flutter/material.dart';

import 'package:parosis_sulama/core/validation/auth_validators.dart';
import 'package:parosis_sulama/features/auth/presentation/controllers/auth_controller.dart';
import 'package:parosis_sulama/features/auth/presentation/widgets/auth_buttons.dart';
import 'package:parosis_sulama/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:parosis_sulama/icons/app_icons.dart';
import 'package:parosis_sulama/theme/colors.dart';
import 'package:parosis_sulama/theme/text_styles.dart';
import 'package:parosis_sulama/widgets/modal_header.dart';

class SecurityScreen extends StatefulWidget {
  final AuthController controller;
  const SecurityScreen({super.key, required this.controller});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  String? _currentError;
  String? _newError;
  String? _confirmError;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final currentError = _currentCtrl.text.isEmpty
        ? 'Mevcut şifrenizi girin.'
        : null;
    final newError = validatePassword(_newCtrl.text);
    final confirmError = validateConfirmPassword(
      _newCtrl.text,
      _confirmCtrl.text,
    );
    setState(() {
      _currentError = currentError;
      _newError = newError;
      _confirmError = confirmError;
    });
    if (currentError != null || newError != null || confirmError != null) {
      return;
    }

    final success = await widget.controller.changePassword(
      currentPassword: _currentCtrl.text,
      newPassword: _newCtrl.text,
    );
    if (!mounted || !success) return;

    _currentCtrl.clear();
    _newCtrl.clear();
    _confirmCtrl.clear();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Şifreniz güncellendi.')));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.canvas,
    body: SafeArea(
      child: Column(
        children: [
          const ModalHeader(title: 'Güvenlik'),
          Expanded(
            child: ListenableBuilder(
              listenable: widget.controller,
              builder: (context, _) {
                final controller = widget.controller;
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  children: [
                    Text(
                      'Şifre Değiştir',
                      style: figtree(size: 15, weight: W.extrabold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Hesap güvenliğiniz için şifrenizi düzenli aralıklarla güncelleyin.',
                      style: figtree(
                        size: 12.5,
                        weight: W.medium,
                        color: AppColors.inkSoft,
                      ),
                    ),
                    const SizedBox(height: 20),
                    AuthTextField(
                      controller: _currentCtrl,
                      label: 'Mevcut Şifre',
                      hint: 'Mevcut şifrenizi girin',
                      iconBuilder: (c) => AppIcons.lock(size: 19, color: c),
                      obscureText: true,
                      errorText: _currentError,
                      autofillHints: const [AutofillHints.password],
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      controller: _newCtrl,
                      label: 'Yeni Şifre',
                      hint: 'En az 6 karakter',
                      iconBuilder: (c) => AppIcons.lock(size: 19, color: c),
                      obscureText: true,
                      errorText: _newError,
                      autofillHints: const [AutofillHints.newPassword],
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      controller: _confirmCtrl,
                      label: 'Yeni Şifre (Tekrar)',
                      hint: 'Yeni şifrenizi tekrar girin',
                      iconBuilder: (c) => AppIcons.lock(size: 19, color: c),
                      obscureText: true,
                      errorText: _confirmError,
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
                      label: 'Şifreyi Güncelle',
                      loading: controller.isSubmitting,
                      onTap: _submit,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

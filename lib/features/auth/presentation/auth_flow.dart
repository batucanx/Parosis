import 'package:flutter/material.dart';

import 'package:parosis_sulama/features/auth/presentation/controllers/auth_controller.dart';
import 'package:parosis_sulama/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:parosis_sulama/features/auth/presentation/screens/login_screen.dart';
import 'package:parosis_sulama/features/auth/presentation/screens/register_screen.dart';
import 'package:parosis_sulama/theme/colors.dart';

enum _AuthScreen { login, register, forgotPassword }

/// Login/Kayıt/Şifremi-unuttum arasındaki geçişi yöneten, `AppRoot`'un
/// enum tabanlı ekran state machine'iyle aynı desende kurulmuş küçük kök
/// widget. Router paketi kullanmaz.
class AuthFlow extends StatefulWidget {
  const AuthFlow({super.key, required this.controller});

  final AuthController controller;

  @override
  State<AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<AuthFlow> {
  _AuthScreen _screen = _AuthScreen.login;

  void _go(_AuthScreen next) => setState(() => _screen = next);

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.canvas,
    body: SafeArea(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: switch (_screen) {
          _AuthScreen.login => LoginScreen(
            key: const ValueKey('login'),
            controller: widget.controller,
            onForgotPassword: () => _go(_AuthScreen.forgotPassword),
            onRegister: () => _go(_AuthScreen.register),
          ),
          _AuthScreen.register => RegisterScreen(
            key: const ValueKey('register'),
            controller: widget.controller,
            onBackToLogin: () => _go(_AuthScreen.login),
          ),
          _AuthScreen.forgotPassword => ForgotPasswordScreen(
            key: const ValueKey('forgot-password'),
            controller: widget.controller,
            onBackToLogin: () => _go(_AuthScreen.login),
          ),
        },
      ),
    ),
  );
}

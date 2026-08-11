import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:parosis_sulama/features/auth/presentation/auth_flow.dart';
import 'package:parosis_sulama/theme/colors.dart';

import 'app_dependencies.dart';
import 'app_root.dart';

/// Uygulamanın kökü: önce önceki oturum var mı diye bakar (kısa bir splash
/// gösterir), sonra oturum yoksa [AuthFlow]'u, varsa mevcut [AppRoot]'u
/// gösterir. Login/kayıt tamamlanınca veya çıkış yapılınca `AuthController`
/// bildirim yayınlar ve bu widget otomatik olarak doğru tarafa geçer.
class AppGate extends StatelessWidget {
  const AppGate({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: dependencies.authController,
    builder: (context, _) {
      final auth = dependencies.authController;
      if (auth.isRestoring) {
        return const _AuthSplash();
      }
      if (!auth.isAuthenticated) {
        return AuthFlow(controller: dependencies.authController);
      }
      return AppRoot(
        dependencies: dependencies,
        onLogout: dependencies.authController.logout,
      );
    },
  );
}

class _AuthSplash extends StatelessWidget {
  const _AuthSplash();

  @override
  Widget build(BuildContext context) => const Scaffold(
    backgroundColor: AppColors.canvas,
    body: Center(
      child: SizedBox(
        width: 64,
        height: 64,
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          child: _SplashMark(),
        ),
      ),
    ),
  );
}

class _SplashMark extends StatelessWidget {
  const _SplashMark();

  @override
  Widget build(BuildContext context) =>
      SvgPicture.asset('assets/icons/parosis_mark.svg', fit: BoxFit.cover);
}

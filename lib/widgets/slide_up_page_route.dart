import 'package:flutter/material.dart';

/// `MaterialPageRoute`, iOS'ta Cupertino'nun sağdan kaydırmalı (ve kenardan
/// geri kaydırma jestli) geçişini, Android'de ise Material'ın
/// fade/zoom geçişini kullanır — aynı ekran iki platformda farklı
/// davranır ve farklı görünür. "Kayıtlı Kartlar" / profil bilgisi gibi
/// navbar'dan yukarı doğru açılan tam ekran sayfalar için, platformdan
/// bağımsız olarak HER İKİ platformda da aynı hissi veren tek bir geçiş
/// kullanıyoruz.
class SlideUpPageRoute<T> extends PageRouteBuilder<T> {
  SlideUpPageRoute({required WidgetBuilder builder, super.settings})
    : super(
        opaque: true,
        barrierColor: Colors.transparent,
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (context, animation, secondaryAnimation) =>
            builder(context),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          );
        },
      );
}

import 'package:flutter/material.dart';

/// React index.css `@theme` bloğundaki renklerin birebir karşılığı.
class AppColors {
  AppColors._();

  // Uygulama zemini ve premium kart yuzeyleri
  static const canvas = Color(0xFFF6F8F7);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceSoft = Color(0xFFFAFCFB);
  static const surfaceBorder = Color(0xFFDDE6E3);

  // Yeşil — birincil eylem, "aktif / açık" durumu
  static const brand50 = Color(0xFFF0FBF7);
  static const brand100 = Color(0xFFD6F1E8);
  static const brand200 = Color(0xFFADE3D3);
  static const brand300 = Color(0xFF74CCB6);
  static const brand400 = Color(0xFF3FAE94);
  static const brand500 = Color(0xFF1F8F76);
  static const brand600 = Color(0xFF17735F);
  static const brand700 = Color(0xFF115A4B);
  static const brand800 = Color(0xFF0D4539);

  // Mavi — ikincil eylem, "bilgi / enerji" durumu
  static const sea50 = Color(0xFFEFF7FC);
  static const sea100 = Color(0xFFD8EBF7);
  static const sea200 = Color(0xFFB0D6EE);
  static const sea300 = Color(0xFF7BB8DD);
  static const sea500 = Color(0xFF2B7CAE);
  static const sea600 = Color(0xFF21648E);
  static const sea700 = Color(0xFF1A4F70);

  // Gri — nötr, "pasif / kapalı" durumu
  static const mist100 = Color(0xFFE6EDED);
  static const mist200 = Color(0xFFCFDCDA);
  static const mist500 = Color(0xFF66807C);
  static const mist600 = Color(0xFF4F6763);

  // Tam nötr gri — renk alt tonu içermeyen ikincil yüzeyler
  static const neutral600 = Color(0xFF333333);

  // Metin
  static const ink = Color(0xFF08302A);
  static const inkSoft = Color(0xFF35605A);
  static const inkFaint = Color(0xFF4A6F69);

  // Tailwind varsayılan paleti (CardsModal, TopUpScreen, WellList'te kullanılıyor)
  static const red50 = Color(0xFFFEF2F2);
  static const red100 = Color(0xFFFEE2E2);
  static const red200 = Color(0xFFFECACA);
  static const red500 = Color(0xFFEF4444);
  static const red600 = Color(0xFFDC2626);

  static const amber50 = Color(0xFFFFFBEB);
  static const amber200 = Color(0xFFFDE68A);
  static const amber400 = Color(0xFFFBBF24);
  static const amber800 = Color(0xFF92400E);

  static const slate100 = Color(0xFFF1F5F9);
  static const slate200 = Color(0xFFE2E8F0);

  // Sayfaya gömülü sahte-sayfa yüzeyleri (hamburger menü, bottom sheet arkaplanı)
  static const sheetBg = Color(0xFFF8FAF9);

  // TopUpScreen onay butonu
  static const nearBlack = Color(0xFF111111);
}

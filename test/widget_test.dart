import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:parosis_sulama/main.dart';
import 'package:parosis_sulama/widgets/marquee_text.dart';

void main() {
  testWidgets('App açılır ve ana ekran görünür', (WidgetTester tester) async {
    await tester.pumpWidget(const SulamaApp());
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Ana Sayfa'), findsOneWidget);
  });

  testWidgets('Alt ekranda hamburger geri butonuna dönüşür', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(375, 812));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const SulamaApp());
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.bySemanticsLabel('Hızlı erişim menüsünü aç'), findsOneWidget);

    await tester.tap(find.text('Program Sulama'));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.bySemanticsLabel('Geri'), findsOneWidget);
    expect(find.bySemanticsLabel('Hızlı erişim menüsünü aç'), findsNothing);

    await tester.tap(find.bySemanticsLabel('Geri'));
    await tester.pumpAndSettle();

    expect(find.text('Ana Sayfa'), findsOneWidget);
    expect(find.bySemanticsLabel('Hızlı erişim menüsünü aç'), findsOneWidget);
  });

  testWidgets('Uzun kuyu adı kullanıcı müdahalesi olmadan otomatik kayar', (
    WidgetTester tester,
  ) async {
    const longName = 'Yayla Yaylası Ana Sulama Kuyusu ABCABCABCABC';

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 140,
              child: MarqueeText(
                text: longName,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ),
    );

    final movingTransform = find.descendant(
      of: find.byType(MarqueeText),
      matching: find.byType(Transform),
    );
    expect(movingTransform, findsOneWidget);
    expect(tester.getSize(find.text(longName)).width, greaterThan(140));

    await tester.pump(const Duration(seconds: 2));

    final transform = tester.widget<Transform>(movingTransform);
    expect(transform.transform.getTranslation().x, lessThan(0));
    expect(find.text(longName), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 300,
            child: MarqueeText(
              text: 'Ova Kuyusu 1',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );

    expect(
      find.descendant(
        of: find.byType(MarqueeText),
        matching: find.byType(Transform),
      ),
      findsNothing,
    );
  });

  testWidgets('Sinirdaki kuyu adi sabit kalir, bir harf tasinca kayar', (
    WidgetTester tester,
  ) async {
    const name = 'Yayla Yaylasi Ana Sulama Kuyusu';
    const style = TextStyle(fontSize: 15, fontWeight: FontWeight.w700);
    final painter = TextPainter(
      text: const TextSpan(text: name, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    Widget testApp(double width) => MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: width,
          child: const MarqueeText(text: name, style: style),
        ),
      ),
    );

    await tester.pumpWidget(testApp(painter.width - 3));

    expect(
      find.descendant(
        of: find.byType(MarqueeText),
        matching: find.byType(Transform),
      ),
      findsNothing,
    );
    expect(find.byType(FittedBox), findsOneWidget);

    await tester.pumpWidget(testApp(painter.width - 5));

    expect(
      find.descendant(
        of: find.byType(MarqueeText),
        matching: find.byType(Transform),
      ),
      findsOneWidget,
    );
  });

  testWidgets('Kayitli kart ayri ekranda duzenlenir ve geri doner', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(375, 812));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const SulamaApp());
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kayıtlı Kartlar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Garanti Banka Kartım'));
    await tester.pumpAndSettle();

    expect(find.text('Kayıtlı Kartı Düzenle'), findsOneWidget);
    expect(find.bySemanticsLabel('Kayıtlı kartlara geri dön'), findsOneWidget);
    expect(find.text('Güncelle'), findsOneWidget);
    expect(find.text('Kartı Sil'), findsOneWidget);
    expect(find.text('İptal'), findsNothing);

    await tester.tap(find.bySemanticsLabel('Kayıtlı kartlara geri dön'));
    await tester.pumpAndSettle();
    expect(find.text('Kayıtlı Kartı Düzenle'), findsNothing);
    expect(find.text('Garanti Banka Kartım'), findsOneWidget);

    await tester.tap(find.text('Garanti Banka Kartım'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'Güncellenen Kartım');
    await tester.tap(find.text('Güncelle'));
    await tester.pumpAndSettle();

    expect(find.text('Kayıtlı Kartı Düzenle'), findsNothing);
    expect(find.text('Güncellenen Kartım'), findsOneWidget);
  });

  testWidgets('Kart silme islemi onay ister', (WidgetTester tester) async {
    await tester.pumpWidget(const SulamaApp());
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kayıtlı Kartlar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Garanti Banka Kartım'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Kartı Sil'));
    await tester.pumpAndSettle();

    expect(find.text('Kartı silmek istiyor musunuz?'), findsOneWidget);
    expect(find.text('Vazgeç'), findsOneWidget);

    await tester.tap(find.text('Vazgeç'));
    await tester.pumpAndSettle();
    expect(find.text('Kayıtlı Kartı Düzenle'), findsOneWidget);
  });
}

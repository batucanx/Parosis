import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:parosis_sulama/screens/cards_modal.dart';

typedef _DeviceCase = ({String name, Size size, FakeViewPadding safeArea});

void main() {
  const devices = <_DeviceCase>[
    (
      name: 'iPhone SE',
      size: Size(375, 667),
      safeArea: FakeViewPadding(top: 20),
    ),
    (
      name: 'iPhone with notch',
      size: Size(393, 852),
      safeArea: FakeViewPadding(top: 59, bottom: 34),
    ),
    (
      name: 'compact Android',
      size: Size(360, 640),
      safeArea: FakeViewPadding(top: 24, bottom: 24),
    ),
  ];

  for (final device in devices) {
    testWidgets(
      'kart sheet ve düzenleme akışı ${device.name} ölçüsünde taşmaz',
      (tester) async {
        _configureView(tester, device);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SafeArea(child: CardsModal(onClose: () {})),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final sheetRect = tester.getRect(
          find.byKey(const ValueKey('overlay-sheet-panel')),
        );
        final availableHeight =
            device.size.height - device.safeArea.top - device.safeArea.bottom;

        expect(sheetRect.height, closeTo(availableHeight * 0.88, 1));
        expect(sheetRect.top, greaterThan(device.safeArea.top));
        expect(tester.takeException(), isNull);

        await tester.tap(find.text('Garanti Banka Kartım'));
        await tester.pumpAndSettle();

        expect(find.text('Kayıtlı Kartı Düzenle'), findsOneWidget);
        expect(tester.takeException(), isNull);

        final editList = find.byType(ListView).last;
        for (
          var i = 0;
          i < 4 && find.text('Kartı Sil').evaluate().isEmpty;
          i++
        ) {
          await tester.drag(editList, const Offset(0, -300));
          await tester.pumpAndSettle();
        }
        expect(find.text('Güncelle'), findsOneWidget);
        expect(find.text('Kartı Sil'), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.tap(find.bySemanticsLabel('Kayıtlı kartlara geri dön'));
        await tester.pumpAndSettle();

        expect(find.text('Kayıtlı Kartlar'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('overlay-sheet-panel')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}

void _configureView(WidgetTester tester, _DeviceCase device) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = device.size;
  tester.view.padding = device.safeArea;
  tester.view.viewPadding = device.safeArea;

  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
    tester.view.resetPadding();
    tester.view.resetViewPadding();
  });
}

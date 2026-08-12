import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parosis_sulama/features/payment_cards/data/repositories/mock_payment_cards_repository.dart';
import 'package:parosis_sulama/features/payment_cards/domain/entities/saved_card.dart';
import 'package:parosis_sulama/features/payment_cards/presentation/controllers/payment_cards_controller.dart';
import 'package:parosis_sulama/features/payment_cards/presentation/screens/cards_modal.dart';

typedef _DeviceCase = ({String name, Size size, FakeViewPadding safeArea});

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

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
        final controller = PaymentCardsController(
          repository: MockPaymentCardsRepository(
            currentUserId: () => 'test-user',
          ),
        );
        addTearDown(controller.dispose);
        await controller.addCard(
          label: 'Garanti Banka Kartım',
          last4: '4242',
          expiry: '08/27',
          holderName: 'TEST KULLANICI',
          scheme: CardScheme.visa,
          makePrimary: true,
        );

        await tester.pumpWidget(
          MaterialApp(home: CardsModal(controller: controller)),
        );
        await tester.pumpAndSettle();

        expect(find.text('Kayıtlı Kartlar'), findsOneWidget);
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

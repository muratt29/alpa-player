// Magaza ekran goruntuleri: uygulamayi demo modunda gezip ekranlari kaydeder.
// Calistirma: flutter drive --driver=test_driver/integration_test.dart \
//   --target=integration_test/screenshots_test.dart
import 'package:alpa_player/account_store.dart';
import 'package:alpa_player/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:media_kit/media_kit.dart';

Future<void> settle(WidgetTester t, [int seconds = 2]) async {
  for (var i = 0; i < seconds * 10; i++) {
    await t.pump(const Duration(milliseconds: 100));
  }
}

Future<void> goBack(WidgetTester t) async {
  t.state<NavigatorState>(find.byType(Navigator).first).pop();
  await settle(t, 2);
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('magaza ekran goruntuleri', (tester) async {
    MediaKit.ensureInitialized();
    await AccountStore.clear();
    await tester.pumpWidget(const AlpaApp());
    await settle(tester);
    await binding.convertFlutterSurfaceToImage();
    await settle(tester);
    await binding.takeScreenshot('1-giris');

    await tester.tap(find.text('Demo modunu dene'));
    await settle(tester, 3);
    await binding.takeScreenshot('2-kategoriler');

    await tester.tap(find.text('Demo yayınlar'));
    await settle(tester, 3);
    await binding.takeScreenshot('3-canli-tv');
    await goBack(tester);

    await tester.tap(find.text('Filmler').last);
    await settle(tester, 2);
    await tester.tap(find.text('Açık kaynak filmler'));
    await settle(tester, 3);
    await binding.takeScreenshot('4-filmler');

    await tester.tap(find.text('Big Buck Bunny (2008)'));
    await settle(tester, 25);
    await binding.takeScreenshot('5-oynatici');
    await goBack(tester);
    await goBack(tester);

    await tester.tap(find.text('Diziler').last);
    await settle(tester, 2);
    await tester.tap(find.text('Demo diziler'));
    await settle(tester, 3);
    await tester.tap(find.text('Blender Açık Filmleri'));
    await settle(tester, 3);
    await binding.takeScreenshot('6-dizi-bolumleri');
  });
}

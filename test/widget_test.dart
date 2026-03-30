import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shoplite/main.dart';
import 'package:shoplite/injection_container.dart' as di;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final tempDir = Directory.systemTemp.createTempSync();
    Hive.init(tempDir.path);

    try {
      await di.init();
    } catch (e) {
    }
  });

  testWidgets('ShopLite App Smoke Test - App loads and shows Splash', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('ShopLite'), findsOneWidget);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

  });

  tearDownAll(() async {
    await Hive.close();
  });
}
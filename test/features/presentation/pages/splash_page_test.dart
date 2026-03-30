import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:shoplite/features/splash/presentation/pages/splash_page.dart';
import 'package:shoplite/features/auth/presentation/cubit/auth_cubit.dart';

// 1. AuthCubit ko mock karein
class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  late MockAuthCubit mockAuthCubit;

  setUp(() {
    mockAuthCubit = MockAuthCubit();
    // Initial state set karein taaki splash load ho sake
    when(() => mockAuthCubit.state).thenReturn(AuthInitial());
    // checkAuthStatus method ko mock karein
    when(() => mockAuthCubit.checkAuthStatus()).thenAnswer((_) async => {});
  });

  testWidgets('SplashPage renders logo and app name', (WidgetTester tester) async {
    // 2. SplashPage ko load karein (BlocProvider ke saath)
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthCubit>.value(
          value: mockAuthCubit,
          child: const SplashPage(),
        ),
      ),
    );

    // 3. VERIFICATION
    // Check karein ki 'ShopLite' text dikh raha hai
    expect(find.text('ShopLite'), findsOneWidget);

    // Check karein ki Image (Logo) widget maujood hai
    expect(find.byType(Image), findsOneWidget);

    // Check karein ki CircularProgressIndicator dikh raha hai
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
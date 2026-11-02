import 'package:driving_school/app.dart';
import 'package:driving_school/core/auth/login_email.dart';
import 'package:driving_school/core/config/flavor.dart';
import 'package:driving_school/features/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget app(Widget home) => DrivingSchoolApp(config: const AppConfig(flavor: Flavor.direct), home: home);

  testWidgets('login screen is Arabic RTL and sends the national ID + password', (tester) async {
    String? sentId;
    String? sentPw;
    await tester.pumpWidget(app(LoginScreen(onLogin: (id, pw) async {
      sentId = id;
      sentPw = pw;
    })));
    expect(Directionality.of(tester.element(find.text('دخول'))), TextDirection.rtl);
    await tester.enterText(find.byKey(const Key('nationalId')), '900000001');
    await tester.enterText(find.byKey(const Key('password')), 'secret');
    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pumpAndSettle();
    expect(sentId, '900000001');
    expect(sentPw, 'secret');
  });

  testWidgets('login errors are shown to the user', (tester) async {
    await tester.pumpWidget(app(LoginScreen(onLogin: (id, pw) async => throw Exception('رقم الهوية أو كلمة السر غلط'))));
    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('loginError')), findsOneWidget);
  });

  test('national ID → login email', () {
    expect(loginEmail(' 900000001 '), '900000001@login.your-firebase-project.web.app');
    expect(isValidNationalId('12345678'), isFalse);
    expect(isValidNationalId('123456789'), isTrue);
  });

  test('only the direct flavor sends SMS itself and self-updates', () {
    expect(const AppConfig(flavor: Flavor.direct).canSendSmsDirectly, isTrue);
    expect(const AppConfig(flavor: Flavor.play).canSendSmsDirectly, isFalse);
    expect(const AppConfig(flavor: Flavor.play).usesSelfUpdater, isFalse);
  });
}

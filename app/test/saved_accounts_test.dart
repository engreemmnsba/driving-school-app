import 'package:driving_school/core/auth/saved_accounts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('saved accounts: newest first, one per ID, at most 5, no password', () async {
    final s = SavedAccounts();
    expect(await s.list(), isEmpty);
    for (var i = 1; i <= 6; i++) {
      await s.remember(SavedAccount(nationalId: '90000000$i', name: 'user $i'));
    }
    await s.remember(const SavedAccount(nationalId: '900000003', name: 'user 3 again'));
    final ids = (await s.list()).map((a) => a.nationalId).toList();
    expect(ids, ['900000003', '900000006', '900000005', '900000004', '900000002']);
    await s.forget('900000006');
    expect((await s.list()).length, 4);
    expect(SavedAccounts.idFromEmail('401234567@login.your-firebase-project.web.app'), '401234567');
    expect(SavedAccounts.idFromEmail('x@y'), isNull);
  });
}

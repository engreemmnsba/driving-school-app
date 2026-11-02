import 'package:flutter/widgets.dart';

import 'app.dart';
import 'core/auth/auth_service.dart';
import 'core/config/flavor.dart';
import 'core/firebase/firebase_setup.dart';

/// `flutter run --flavor play -t lib/main_play.dart`  (add `--dart-define=EMULATOR=true` for the local server)
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initFirebase();
  runApp(DrivingSchoolApp(config: const AppConfig(flavor: Flavor.play), home: AuthGate(auth: AuthService())));
}

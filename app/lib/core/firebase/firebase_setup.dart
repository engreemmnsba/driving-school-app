import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../firebase_options.dart';

/// Region of applyOpsFn (DECISIONS A9).
const functionsRegion = 'europe-west1';

/// `--dart-define=EMULATOR=true` → talk to the local emulators started by emulators.ps1.
const useEmulator = bool.fromEnvironment('EMULATOR');

Future<void> initFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  const host = '127.0.0.1';
  // The Auth emulator must be set before anything touches Auth: Firestore below starts Auth to get a
  // token, and on the web a saved session would otherwise be refreshed against Google's live servers.
  if (useEmulator) await FirebaseAuth.instance.useAuthEmulator(host, 9099);
  // Drift is the only local store; Firestore is used only to pull changes (docs/05).
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: false);
  if (useEmulator) {
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
    FirebaseFunctions.instanceFor(region: functionsRegion).useFunctionsEmulator(host, 5001);
  }
}

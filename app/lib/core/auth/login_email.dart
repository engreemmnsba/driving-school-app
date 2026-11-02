/// Firebase Auth needs an email; users log in with their national ID.
/// Must match functions/scripts/seed-emulator.mjs (and the future createUser function).
String loginEmail(String nationalId) => '${nationalId.trim()}@login.your-firebase-project.web.app';

/// Palestinian national ID: 9 digits.
bool isValidNationalId(String v) => RegExp(r'^\d{9}$').hasMatch(v.trim());

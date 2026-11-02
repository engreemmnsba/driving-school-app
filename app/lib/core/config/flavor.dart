/// The two distributions built from one codebase (DECISIONS P7).
enum Flavor {
  /// APK outside Google Play: self-updater + automatic SMS.
  direct,

  /// Google Play build: Play In-App Updates, SMS/WhatsApp via intent.
  play,
}

class AppConfig {
  const AppConfig({required this.flavor});

  final Flavor flavor;

  bool get canSendSmsDirectly => flavor == Flavor.direct;
  bool get usesSelfUpdater => flavor == Flavor.direct;
}

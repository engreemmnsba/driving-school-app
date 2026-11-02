import 'money.dart';

/// One price version of a license type (docs/04: license_price).
class LicensePrice {
  const LicensePrice({
    required this.id,
    required this.licenseTypeId,
    required this.effectiveFrom,
    required this.registrationFee,
    required this.practicalLessonPrice,
    required this.theoryRetakeFee,
    required this.practicalExamFee,
  });

  final String id;
  final String licenseTypeId;

  /// YYYY-MM-DD
  final String effectiveFrom;
  final Money registrationFee;
  final Money practicalLessonPrice;
  final Money theoryRetakeFee;
  final Money practicalExamFee;
}

/// The price effective on [businessDate] (latest effectiveFrom <= date), or null if none.
/// Same rule as the server's priceAt(): a later price change never rewrites older charges.
LicensePrice? priceAt(Iterable<LicensePrice> versions, String licenseTypeId, String businessDate) {
  LicensePrice? best;
  for (final v in versions) {
    if (v.licenseTypeId != licenseTypeId) continue;
    if (v.effectiveFrom.compareTo(businessDate) > 0) continue;
    if (best == null || v.effectiveFrom.compareTo(best.effectiveFrom) > 0) best = v;
  }
  return best;
}

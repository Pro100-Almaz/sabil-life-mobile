import '../../data/models/listing.dart';
import '../l10n/app_localizations.dart';

extension CategoryLabel on CategoryType {
  String label(AppLocalizations l10n) {
    switch (this) {
      case CategoryType.schools:
        return l10n.catSchools;
      case CategoryType.nurseries:
        return l10n.catNurseries;
      case CategoryType.activities:
        return l10n.catActivities;
      case CategoryType.entertainment:
        return l10n.catEntertainment;
      case CategoryType.tutoring:
        return l10n.catTutoring;
      case CategoryType.masterclasses:
        return l10n.catMasterclasses;
      case CategoryType.partnerships:
        return l10n.catPartnerships;
    }
  }
}

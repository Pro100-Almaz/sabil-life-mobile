import '../../data/models/tutor.dart';
import '../l10n/app_localizations.dart';

String subjectLabel(String backendKey, AppLocalizations l10n) {
  return switch (backendKey.toUpperCase()) {
    'MATH' => l10n.subjectMath,
    'ARABIC' => l10n.subjectArabic,
    'ENGLISH' => l10n.subjectEnglish,
    'SCIENCE' => l10n.subjectScience,
    'EXAM_PREP' => l10n.subjectExamPrep,
    _ => backendKey,
  };
}

extension TutorFormatLabel on TutorFormat {
  String label(AppLocalizations l10n) {
    switch (this) {
      case TutorFormat.oneOnOne:
        return l10n.formatOneOnOne;
      case TutorFormat.smallGroup:
        return l10n.formatSmallGroup;
      case TutorFormat.atCentre:
        return l10n.formatAtCentre;
      case TutorFormat.online:
        return l10n.formatOnline;
    }
  }
}

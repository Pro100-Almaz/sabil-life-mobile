import '../../data/models/tutor.dart';
import '../l10n/app_localizations.dart';

extension TutorSubjectLabel on TutorSubject {
  String label(AppLocalizations l10n) {
    switch (this) {
      case TutorSubject.math:
        return l10n.subjectMath;
      case TutorSubject.arabic:
        return l10n.subjectArabic;
      case TutorSubject.english:
        return l10n.subjectEnglish;
      case TutorSubject.science:
        return l10n.subjectScience;
      case TutorSubject.examPrep:
        return l10n.subjectExamPrep;
    }
  }
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

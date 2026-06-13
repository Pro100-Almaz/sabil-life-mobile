import '../l10n/app_localizations.dart';

/// "12m ago" / "3h ago" / "2d ago", localized.
String formatRelative(DateTime when, AppLocalizations l10n) {
  final diff = DateTime.now().difference(when);
  if (diff.inMinutes < 1) return l10n.minutesAgo(1);
  if (diff.inMinutes < 60) return l10n.minutesAgo(diff.inMinutes);
  if (diff.inHours < 24) return l10n.hoursAgo(diff.inHours);
  return l10n.daysAgo(diff.inDays);
}

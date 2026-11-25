import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';

final Uri privacyPolicyUri = Uri.parse(
  'https://docs.google.com/document/d/1oDxhVBO7CqQnHuXZh44HQ0LLXK-eK8Be/preview',
);

final Uri supportUri = Uri.parse('https://support.sabil-life.com/');

/// Opens [uri] in the browser, telling the user if that isn't possible.
Future<void> openLegalLink(BuildContext context, Uri uri) async {
  var opened = false;
  try {
    opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    opened = false;
  }
  if (opened || !context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(AppLocalizations.of(context)!.linkOpenFailed)),
  );
}

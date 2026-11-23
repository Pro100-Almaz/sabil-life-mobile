import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/l10n/app_localizations.dart';
import '../../data/models/listing_event.dart';

class ListingEventCard extends StatelessWidget {
  const ListingEventCard({super.key, required this.event});
  final ListingEvent event;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final format = DateFormat.yMMMd(
      Localizations.localeOf(context).toString(),
    ).add_Hm();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              '${format.format(event.startsAt)}${event.endsAt == null ? '' : ' – ${format.format(event.endsAt!)}'}',
            ),
            if (event.location.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(event.location),
              ),
            if (event.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(event.description),
              ),
            if (event.registrationUrl.isNotEmpty)
              TextButton.icon(
                icon: const Icon(Icons.open_in_new),
                label: Text(l10n.eventRegister),
                onPressed: () async {
                  final uri = Uri.tryParse(event.registrationUrl);
                  var opened = false;
                  try {
                    if (uri != null &&
                        ['https', 'http'].contains(uri.scheme) &&
                        uri.host.isNotEmpty) {
                      opened = await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  } catch (_) {
                    /* Show the same message for platform launch failures. */
                  }
                  if (!opened && context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(l10n.invalidUrl)));
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}

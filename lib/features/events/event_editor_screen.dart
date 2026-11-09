import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/state/auth_provider.dart';
import '../../core/state/event_providers.dart';
import '../../core/state/provider_providers.dart';
import '../../data/models/listing_event.dart';
import 'listing_event_card.dart';

class EventEditorScreen extends ConsumerStatefulWidget {
  const EventEditorScreen({super.key, required this.listingId});
  final String listingId;
  @override
  ConsumerState<EventEditorScreen> createState() => _EventEditorScreenState();
}

class _EventEditorScreenState extends ConsumerState<EventEditorScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _location = TextEditingController();
  final _url = TextEditingController();
  DateTime? _start, _end;
  bool _loading = true, _busy = false, _uncertain = false, _blocked = false;
  String? _message;
  Map<String, String> _errors = {};
  List<ListingEvent>? _checkedEvents;
  late final String _draftKey;
  Future<void> _writes = Future.value();

  @override
  void initState() {
    super.initState();
    _draftKey =
        'event.draft.${ref.read(authProvider).user?.id}.${widget.listingId}';
    _restore();
  }

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_draftKey);
      if (!mounted) return;
      if (raw != null) {
        final data = jsonDecode(raw) as Map;
        _title.text = data['title'] as String? ?? '';
        _description.text = data['description'] as String? ?? '';
        _location.text = data['location'] as String? ?? '';
        _url.text = data['registration_url'] as String? ?? '';
        _start = DateTime.tryParse(
          data['starts_at'] as String? ?? '',
        )?.toLocal();
        _end = DateTime.tryParse(data['ends_at'] as String? ?? '')?.toLocal();
        _uncertain = data['uncertain'] == true;
      }
    } catch (_) {
      /* A malformed local draft must not prevent event creation. */
    }
    if (mounted) setState(() => _loading = false);
  }

  Map<String, dynamic> _fields() => {
    'title': _title.text.trim(),
    'description': _description.text.trim(),
    'location': _location.text.trim(),
    'registration_url': _url.text.trim(),
    'starts_at': _start?.toUtc().toIso8601String(),
    'ends_at': _end?.toUtc().toIso8601String(),
  };

  void _saveDraft() {
    final data = jsonEncode({..._fields(), 'uncertain': _uncertain});
    _writes = _writes
        .then((_) async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_draftKey, data);
        })
        .catchError((Object _) {});
  }

  Future<void> _pickDate(bool end) async {
    final initial = (end ? _end ?? _start : _start) ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null || !mounted) return;
    setState(() {
      final value = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      if (end) {
        _end = value;
      } else {
        _start = value;
      }
    });
    _saveDraft();
  }

  Future<void> _checkEvents() async {
    setState(() => _busy = true);
    try {
      final events = <ListingEvent>[];
      var page = 1;
      while (true) {
        final result = await ref
            .read(eventRepositoryProvider)
            .forListing(widget.listingId, page: page++, owned: true);
        events.addAll(result.results);
        if (!result.hasNext) break;
      }
      if (!mounted) return;
      setState(() {
        _checkedEvents = events;
        _uncertain = false;
      });
      _saveDraft();
      ref.invalidate(listingEventsProvider);
    } on DioException catch (e) {
      _handleError(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _handleError(DioException e) {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final status = e.response?.statusCode;
    if (status == 401 || status == 403 || status == 404) {
      setState(() {
        _blocked = true;
        _message = status == 401 ? l10n.eventSignIn : l10n.eventAccessDenied;
      });
      ref.invalidate(listingEventsProvider);
      final user = ref.read(authProvider).user;
      if (user != null) ref.invalidate(myListingsProvider(user.id));
      return;
    }
    final data = e.response?.data;
    setState(() {
      _message = data is Map && data['detail'] is String
          ? data['detail'] as String
          : l10n.eventPublishFailed;
      if (data is Map) {
        _errors = {
          for (final entry in data.entries)
            entry.key.toString(): entry.value is List
                ? (entry.value as List).join('\n')
                : entry.value.toString(),
        };
      }
    });
  }

  Future<void> _publish() async {
    if (_busy || _uncertain || _blocked) return;
    setState(() {
      _errors = {};
      _message = null;
    });
    if (!_form.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;
    if (_start == null || (_end != null && !_end!.isAfter(_start!))) {
      setState(
        () => _message = _start == null
            ? l10n.eventRequired
            : l10n.eventEndInvalid,
      );
      return;
    }
    setState(() => _busy = true);
    _uncertain =
        true; // Persist before sending: a process exit can also hide a successful response.
    _saveDraft();
    await _writes;
    try {
      await ref
          .read(eventRepositoryProvider)
          .publish(widget.listingId, _fields());
    } on DioException catch (e) {
      if (!mounted) return;
      if (e.response == null || (e.response?.statusCode ?? 0) >= 500) {
        setState(() => _message = l10n.eventUncertain);
        await _checkEvents();
      } else {
        _uncertain = false;
        _saveDraft();
        _handleError(e);
      }
      if (mounted) setState(() => _busy = false);
      return;
    }
    // Success is final even if local storage cleanup fails.
    await _writes;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_draftKey);
    } catch (_) {}
    if (!mounted) return;
    ref.invalidate(listingEventsProvider);
    ref.invalidate(catalogDetailProvider(widget.listingId));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.eventPublished)));
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    for (final controller in [_title, _description, _location, _url]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final format = DateFormat.yMMMd(
      Localizations.localeOf(context).toString(),
    ).add_Hm();
    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.createListingEvent)),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _form,
                onChanged: _saveDraft,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(l10n.eventPublishNotice),
                      const SizedBox(height: 16),
                      if (_message != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            _message!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      TextFormField(
                        controller: _title,
                        enabled: !_busy && !_blocked,
                        maxLength: 200,
                        decoration: InputDecoration(
                          labelText: l10n.eventTitle,
                          errorText: _errors['title'],
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? l10n.eventRequired
                            : null,
                      ),
                      TextFormField(
                        controller: _description,
                        enabled: !_busy && !_blocked,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: l10n.eventDescription,
                          errorText: _errors['description'],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(l10n.eventLocalTime),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.eventStart),
                        subtitle: Text(
                          _errors['starts_at'] ??
                              (_start == null
                                  ? l10n.eventRequired
                                  : format.format(_start!)),
                        ),
                        trailing: const Icon(Icons.calendar_month),
                        onTap: _busy || _blocked
                            ? null
                            : () => _pickDate(false),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.eventEnd),
                        subtitle: Text(
                          _errors['ends_at'] ??
                              (_end == null ? '—' : format.format(_end!)),
                        ),
                        trailing: const Icon(Icons.calendar_month),
                        onTap: _busy || _blocked ? null : () => _pickDate(true),
                      ),
                      if (_end != null)
                        TextButton(
                          onPressed: _busy || _blocked
                              ? null
                              : () {
                                  setState(() => _end = null);
                                  _saveDraft();
                                },
                          child: Text(l10n.eventClearEnd),
                        ),
                      TextFormField(
                        controller: _location,
                        enabled: !_busy && !_blocked,
                        maxLength: 500,
                        decoration: InputDecoration(
                          labelText: l10n.eventLocation,
                          errorText: _errors['location'],
                        ),
                      ),
                      TextFormField(
                        controller: _url,
                        enabled: !_busy && !_blocked,
                        maxLength: 200,
                        keyboardType: TextInputType.url,
                        decoration: InputDecoration(
                          labelText: l10n.eventRegistrationUrl,
                          errorText: _errors['registration_url'],
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return null;
                          final uri = Uri.tryParse(v.trim());
                          return uri != null &&
                                  ['http', 'https'].contains(uri.scheme) &&
                                  uri.host.isNotEmpty
                              ? null
                              : l10n.invalidUrl;
                        },
                      ),
                      const SizedBox(height: 20),
                      if (_uncertain) ...[
                        Text(l10n.eventUncertain),
                        TextButton(
                          onPressed: _busy || _blocked ? null : _checkEvents,
                          child: Text(l10n.retry),
                        ),
                      ],
                      if (_checkedEvents != null) ...[
                        Text(
                          l10n.listingEvents,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (_checkedEvents!.isEmpty) Text(l10n.eventNoEvents),
                        for (final event in _checkedEvents!)
                          ListingEventCard(event: event),
                      ],
                      FilledButton(
                        onPressed: _busy || _blocked || _uncertain
                            ? null
                            : _publish,
                        child: _busy
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(l10n.publishListingEvent),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Current app locale. Settings writes it; `app.dart` feeds it to
/// `MaterialApp.locale` so the whole UI re-localizes live.
final localeProvider = StateProvider<Locale>((ref) => const Locale('en'));

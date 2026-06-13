import 'package:flutter/foundation.dart';

/// Plain [ChangeNotifier] adapter so go_router can refresh whenever a
/// Riverpod auth state change fires.
class RouterRefreshListenable extends ChangeNotifier {
  void notify() => notifyListeners();
}

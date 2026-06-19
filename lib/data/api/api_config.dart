import 'package:flutter_dotenv/flutter_dotenv.dart';

String get apiBaseUrl {
    final value = dotenv.env['API_BASE_URL'];
    if (value == null || value.isEmpty) {
      throw StateError('API_BASE_URL is missing from .env');
    }
    return value;
}


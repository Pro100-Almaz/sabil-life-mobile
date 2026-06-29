/// A selectable city. Names are stored per language (`en`, `ru`, `kk`); the
/// canonical value persisted / sent to the backend is always English plus the
/// ISO country code, formatted as `"City, COUNTRY_CODE"` (e.g. `"Doha, QA"`).
class City {
  const City({required this.country, required this.names});

  /// ISO 3166-1 alpha-2 country code, e.g. `"QA"`.
  final String country;

  /// Localized display names keyed by language code, e.g.
  /// `{"en": "Doha", "ru": "Доха", "kk": "Доха"}`. `en` is required.
  final Map<String, String> names;

  factory City.fromJson(Map<String, dynamic> json) => City(
    country: json['country'] as String,
    names: Map<String, String>.from(json['names'] as Map),
  );

  /// English name — the canonical identity of the city.
  String get englishName => names['en'] ?? names.values.first;

  /// Display name in [languageCode], falling back to English.
  String localizedName(String languageCode) =>
      names[languageCode] ?? englishName;

  /// The value persisted and sent to the backend, e.g. `"Doha, QA"`.
  String get backendValue => '$englishName, $country';

  @override
  bool operator ==(Object other) =>
      other is City && other.backendValue == backendValue;

  @override
  int get hashCode => backendValue.hashCode;
}

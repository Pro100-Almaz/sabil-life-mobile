import 'package:flutter_test/flutter_test.dart';
import 'package:sabil_life/core/util/linkedin.dart';

void main() {
  group('LinkedIn URL validation', () {
    test('accepts empty optional value and LinkedIn profile URLs', () {
      expect(isValidOptionalLinkedInUrl(''), isTrue);
      expect(
        isValidOptionalLinkedInUrl(
          'https://www.linkedin.com/in/example-tutor/',
        ),
        isTrue,
      );
      expect(
        isValidOptionalLinkedInUrl('https://qa.linkedin.com/in/example'),
        isTrue,
      );
    });

    test('rejects plain text and non-LinkedIn URLs', () {
      expect(isValidOptionalLinkedInUrl('example tutor'), isFalse);
      expect(
        isValidOptionalLinkedInUrl('https://example.com/in/example-tutor'),
        isFalse,
      );
    });
  });
}

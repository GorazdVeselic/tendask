import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/features/suggestions/presentation/suggestion_text.dart';

void main() {
  test('fills a single marker', () {
    expect(
      fillTemplate('Mowing is {days} days overdue', {'days': '12'}),
      'Mowing is 12 days overdue',
    );
  });

  test('fills multiple markers, including a repeated one', () {
    expect(
      fillTemplate('{subject}: water {subject} now', {'subject': 'Basil'}),
      'Basil: water Basil now',
    );
  });

  test('a missing key collapses to empty (optional engine params)', () {
    expect(
      fillTemplate('Prune by {window_end_date}{frost_date}', {
        'window_end_date': '20. 6. 2026',
      }),
      'Prune by 20. 6. 2026',
    );
  });

  test('leaves text without markers untouched', () {
    expect(fillTemplate('No markers here', const {}), 'No markers here');
  });

  test('ignores unknown extra values', () {
    expect(fillTemplate('Hi {a}', {'a': 'x', 'b': 'y'}), 'Hi x');
  });

  test('does not re-substitute markers that appear inside a value', () {
    // A subject named "Rose {prune}" must not have its {prune} re-expanded —
    // substitution is a single pass (no injection from server-sent params).
    expect(
      fillTemplate('Care for {subject}', {
        'subject': 'Rose {prune}',
        'prune': 'DANGER',
      }),
      'Care for Rose {prune}',
    );
  });

  test(r'a value with a $ is inserted literally (not a replacement pattern)', () {
    expect(fillTemplate('{a}', {'a': r'$1 price'}), r'$1 price');
  });
}

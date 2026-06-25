// Locale-aware-ish ordering for catalog labels. Folds Slovenian (č š ž) and
// German (ä ö ü ß) letters into their correct alphabetical slot — e.g. 'č'
// sorts between 'c' and 'd', not after 'z' as raw UTF-16 `compareTo` would.

// Base letters get even weights so the Slovenian distinct letters (č š ž) fit
// in the odd slot right after their base. German umlauts fold onto their base
// vowel (DIN 5007-1: ä≈a, ö≈o, ü≈u, ß≈s).
final Map<int, int> _weights = () {
  const base = 'abcdefghijklmnopqrstuvwxyz';
  final m = {
    for (var i = 0; i < base.length; i++) base.codeUnitAt(i): i * 2,
  };
  int w(String c) => m[c.runes.first]!;
  m['č'.runes.first] = w('c') + 1;
  m['š'.runes.first] = w('s') + 1;
  m['ž'.runes.first] = w('z') + 1;
  m['ä'.runes.first] = w('a');
  m['ö'.runes.first] = w('o');
  m['ü'.runes.first] = w('u');
  m['ß'.runes.first] = w('s');
  return m;
}();

String _collationKey(String s) {
  final buf = StringBuffer();
  for (final r in s.toLowerCase().runes) {
    final w = _weights[r];
    if (w != null) {
      buf.writeCharCode(0x100 + w); // known letter, in alphabet order
    } else if (r < 0x100) {
      buf.writeCharCode(r); // punctuation/digits/space sort before letters
    } else {
      buf.writeCharCode(0x1000 + r); // exotic accents after the known alphabet
    }
  }
  return buf.toString();
}

/// Compares two display labels by Slovenian/German collation order.
int compareCatalogLabels(String a, String b) =>
    _collationKey(a).compareTo(_collationKey(b));

/// Returns [items] sorted by their localized [label], computing each key once
/// (decorate-sort) so the per-item label lookup isn't repeated per comparison.
List<T> sortedByLabel<T>(Iterable<T> items, String Function(T) label) {
  final decorated = [
    for (final it in items) (key: _collationKey(label(it)), item: it),
  ];
  decorated.sort((a, b) => a.key.compareTo(b.key));
  return [for (final d in decorated) d.item];
}

import 'package:flutter/material.dart';

/// The "this word takes you somewhere" part of a translated sentence, for slang
/// rich-text keys: `t.some.key(link: (text) => linkSpan(context, text))`.
///
/// Styling only — deliberately no [TapGestureRecognizer]. The tap target is the
/// card the sentence sits in, which keeps those widgets stateless (a recognizer
/// would have to be disposed) and the target far bigger than one word.
TextSpan linkSpan(BuildContext context, String text) {
  final primary = Theme.of(context).colorScheme.primary;
  return TextSpan(
    text: text,
    style: TextStyle(
      color: primary,
      fontWeight: FontWeight.w700,
      decoration: TextDecoration.underline,
      decorationColor: primary,
    ),
  );
}

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Builds a [TextSpan] from a string containing plain text and `<a href="...">...</a>`
/// tags, rendering the anchors as tappable links.
///
/// Only supports flat text with `<a>` tags (no nested/other HTML tags) — enough
/// for simple inline links like terms & conditions text.
class HtmlLinkTextSpan {
  static final _anchorPattern = RegExp(
    '''<a\\s+href=["']([^"']*)["']\\s*>(.*?)</a>''',
    caseSensitive: false,
    dotAll: true,
  );

  static TextSpan build(
    String htmlContent, {
    TextStyle? defaultTextStyle,
    TextStyle? linkTextStyle,
    required void Function(String link) onLinkTap,
  }) {
    final content =
        htmlContent
            .replaceAll(RegExp(r'</?p>', caseSensitive: false), '')
            .trim();

    final spans = <InlineSpan>[];
    int lastEnd = 0;

    for (final match in _anchorPattern.allMatches(content)) {
      if (match.start > lastEnd) {
        spans.add(
          TextSpan(
            text: content.substring(lastEnd, match.start),
            style: defaultTextStyle,
          ),
        );
      }

      final href = match.group(1)!;
      final label = match.group(2)!;
      spans.add(
        TextSpan(
          text: label,
          style:
              linkTextStyle ??
              defaultTextStyle?.copyWith(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
          recognizer: TapGestureRecognizer()..onTap = () => onLinkTap(href),
        ),
      );

      lastEnd = match.end;
    }

    if (lastEnd < content.length) {
      spans.add(
        TextSpan(text: content.substring(lastEnd), style: defaultTextStyle),
      );
    }

    return TextSpan(children: spans, style: defaultTextStyle);
  }
}

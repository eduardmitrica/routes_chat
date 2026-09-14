import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:routes_chat/domain/chats/messages/message_links.dart';

/// [text] with its links shown in [linkStyle], each opened with [onOpenLink]
/// when tapped. See [splitLinks] for what counts as a link.
class LinkifiedText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextStyle? linkStyle;
  final ValueChanged<Uri>? onOpenLink;

  const LinkifiedText(
    this.text, {
    super.key,
    this.style,
    this.linkStyle,
    this.onOpenLink,
  });

  @override
  State<LinkifiedText> createState() => _LinkifiedTextState();
}

class _LinkifiedTextState extends State<LinkifiedText> {
  /// One for each link shown, replaced on every build.
  final _recognizers = <TapGestureRecognizer>[];

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _disposeRecognizers() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }

  TapGestureRecognizer? _recognizerFor(Uri link) {
    final onOpenLink = widget.onOpenLink;
    if (onOpenLink == null) return null;
    final recognizer = TapGestureRecognizer()..onTap = () => onOpenLink(link);
    _recognizers.add(recognizer);
    return recognizer;
  }

  @override
  Widget build(BuildContext context) {
    _disposeRecognizers();
    return Text.rich(
      TextSpan(
        style: widget.style,
        children: [
          for (final part in splitLinks(widget.text))
            if (part.link case final link?)
              TextSpan(
                text: part.text,
                style: widget.linkStyle,
                recognizer: _recognizerFor(link),
              )
            else
              TextSpan(text: part.text),
        ],
      ),
    );
  }
}

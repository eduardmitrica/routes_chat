import 'package:flutter/material.dart';

/// Asks whether to open [link], showing where it really leads. True only if
/// the user chose to open it.
Future<bool> confirmOpenLink(BuildContext context, Uri link) async =>
    await showDialog<bool>(
      context: context,
      builder: (_) => OpenLinkDialog(link: link),
    ) ??
    false;

/// "Open this link?", with the site a link leads to and anything about it
/// worth a second look. A message can say anything, so the dialog shows the
/// address itself.
class OpenLinkDialog extends StatelessWidget {
  final Uri link;

  const OpenLinkDialog({super.key, required this.link});

  bool get _isEmail => link.scheme == 'mailto';

  /// Letters outside ASCII in a site name can imitate a known site, such as
  /// a Cyrillic "а" in "аpple.com". Uri keeps them percent-encoded, and
  /// punycode ("xn--") spells them in ASCII, so both count too.
  bool get _hostLooksAlike =>
      link.host.contains('%') ||
      link.host.split('.').any((label) => label.startsWith('xn--')) ||
      link.host.runes.any((rune) => rune > 0x7f);

  /// The site name as it reads, rather than percent-encoded.
  String get _site {
    try {
      return Uri.decodeComponent(link.host);
    } on ArgumentError {
      return link.host;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final warnings = [
      if (!_isEmail && link.scheme == 'http')
        'This link is not secure: people on the same network could see or '
            'change the page.',
      if (_hostLooksAlike)
        'The site name uses letters from other alphabets, which can make it '
            'look like a site it is not.',
    ];

    return AlertDialog(
      icon: Icon(
        _isEmail ? Icons.mail_outline_rounded : Icons.open_in_new_rounded,
      ),
      title: Text(_isEmail ? 'Write an email?' : 'Open this link?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_isEmail ? 'Your mail app opens to write to' : 'It leads to'),
          const SizedBox(height: 4),
          Text(
            _isEmail ? link.path : _site,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (!_isEmail) ...[
            const SizedBox(height: 4),
            Text(
              link.toString(),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
          for (final warning in warnings) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded, color: scheme.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    warning,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (!_isEmail) ...[
            const SizedBox(height: 12),
            Text(
              'Only open links from people you trust.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(_isEmail ? 'Write' : 'Open'),
        ),
      ],
    );
  }
}

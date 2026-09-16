import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:routes_chat/application/encryption/safety_number/safety_number_bloc.dart';
import 'package:routes_chat/domain/encryption/key_verifications.dart';
import 'package:routes_chat/domain/encryption/safety_number.dart';
import 'package:routes_chat/presentation/core/theme/app_colors.dart';

import 'widgets/scan_code_page.dart';

/// The number the user and [name] compare to be sure nobody swapped a key
/// through the server, with the code to scan when they are together.
///
/// The bloc comes from the chat, so what is checked here shows there at once.
class SafetyNumberPage extends StatelessWidget {
  static const safetyNumberPageRoute = '/home/chats/safety-number';

  final String name;

  const SafetyNumberPage({super.key, required this.name});

  static Route<void> route({
    required SafetyNumberBloc bloc,
    required String name,
  }) => MaterialPageRoute(
    settings: const RouteSettings(name: safetyNumberPageRoute),
    builder: (_) => BlocProvider.value(
      value: bloc,
      child: SafetyNumberPage(name: name),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Safety number')),
      body: BlocConsumer<SafetyNumberBloc, SafetyNumberState>(
        listenWhen: (previous, current) => previous.scans != current.scans,
        listener: (context, state) => _tell(context, switch (state.lastScan) {
          ScanOutcome.matched => 'The codes match. $name is verified.',
          ScanOutcome.differed =>
            'The codes don\'t match. Compare the numbers, and don\'t send '
                'anything private until they do.',
          _ => 'That code isn\'t a routes safety number.',
        }),
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          final number = state.number;
          if (number == null) {
            return _NothingToCompare(
              name: name,
              retry: () => _refresh(context),
            );
          }
          return _Number(name: name, number: number, state: state);
        },
      ),
    );
  }

  void _refresh(BuildContext context) =>
      context.read<SafetyNumberBloc>().add(const SafetyNumberEvent.refreshed());

  static void _tell(BuildContext context, String text) =>
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(text)));
}

/// One of the two has no keys yet, so there is nothing to compare.
class _NothingToCompare extends StatelessWidget {
  final String name;
  final VoidCallback retry;

  const _NothingToCompare({required this.name, required this.retry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$name hasn\'t set up encryption yet, so there is no number to '
              'compare.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: retry, child: const Text('Check again')),
          ],
        ),
      ),
    );
  }
}

class _Number extends StatelessWidget {
  final String name;
  final SafetyNumber number;
  final SafetyNumberState state;

  const _Number({
    required this.name,
    required this.number,
    required this.state,
  });

  Future<void> _scan(BuildContext context) async {
    final bloc = context.read<SafetyNumberBloc>();
    final code = await Navigator.of(context).push(ScanCodePage.route(name));
    if (code != null) bloc.add(SafetyNumberEvent.scanned(code));
  }

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: number.groups.join(' ')));
    if (context.mounted) {
      SafetyNumberPage._tell(context, 'Number copied.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bloc = context.read<SafetyNumberBloc>();
    final verified = state.state == KeyVerificationState.verified;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      children: [
        if (state.state == KeyVerificationState.changed)
          _ChangedNotice(name: name),
        Text(
          'This number belongs to you and $name together. Compare it when '
          'you\'re side by side, or read it out on a call you trust. If it '
          'matches, nobody is reading along.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        Center(child: _Code(payload: number.qrPayload)),
        const SizedBox(height: 20),
        _Digits(number: number),
        const SizedBox(height: 20),
        if (verified)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.verified_user_outlined,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '$name is verified on this phone.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          )
        else
          Text(
            'Not verified yet. Verifying is kept on this phone only, and '
            '$name is not told.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => unawaited(_scan(context)),
          icon: const Icon(Icons.qr_code_scanner_rounded),
          label: Text('Scan $name\'s code'),
        ),
        const SizedBox(height: 8),
        if (verified)
          OutlinedButton(
            onPressed: () => bloc.add(const SafetyNumberEvent.forgotten()),
            child: const Text('Clear this verification'),
          )
        else
          OutlinedButton(
            onPressed: () => bloc.add(const SafetyNumberEvent.verified()),
            child: const Text('I compared it, it matches'),
          ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => unawaited(_copy(context)),
          child: const Text('Copy the number'),
        ),
      ],
    );
  }
}

/// The warning at the top once the number is not the one that was checked.
class _ChangedNotice extends StatelessWidget {
  final String name;

  const _ChangedNotice({required this.name});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: theme.colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'This number is not the one you checked. It happens when $name '
              'reinstalls or resets their keys - and it is also what someone '
              'reading along would look like. Compare it again before you '
              'send anything private.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The QR code. It stays black on white whatever the app's theme is, because
/// that is what cameras read best.
class _Code extends StatelessWidget {
  final String payload;

  const _Code({required this.payload});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.code,
        borderRadius: BorderRadius.circular(12),
      ),
      child: QrImageView(
        data: payload,
        size: 220,
        backgroundColor: colors.code,
        eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.square, color: colors.onCode),
        dataModuleStyle: QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: colors.onCode,
        ),
      ),
    );
  }
}

/// The 60 digits, in the groups of five they are read out in.
class _Digits extends StatelessWidget {
  final SafetyNumber number;

  const _Digits({required this.number});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groups = number.groups;
    return Semantics(
      label: 'Safety number: ${groups.join(', ')}',
      child: ExcludeSemantics(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          runSpacing: 8,
          children: [
            for (final group in groups)
              Text(
                group,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                  letterSpacing: 1.5,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

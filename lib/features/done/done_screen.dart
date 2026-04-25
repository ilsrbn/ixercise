import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ixercise/design_system/theme.dart';
import 'package:ixercise/features/session/session_controller.dart';
import 'package:ixercise/features/settings/locale_controller.dart';
import 'package:ixercise/l10n/app_localizations.dart';

class DoneScreen extends ConsumerWidget {
  const DoneScreen({super.key, required this.sessionId, this.onBackHome});

  final String sessionId;
  final VoidCallback? onBackHome;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sessionControllerProvider);
    final AppLocalizations l10n = ref.watch(appStringsProvider);
    final IxThemeColors colors = context.ixColors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      l10n.completeLabel,
                      style: const TextStyle(
                        color: Color(0xFFE11D2E),
                        fontSize: 12,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      l10n.doneBigLabel,
                      style: const TextStyle(
                        fontSize: 62,
                        height: 1,
                        letterSpacing: -1.8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      _fmt(state.session.elapsedSeconds),
                      style: const TextStyle(
                        fontSize: 84,
                        height: 0.9,
                        letterSpacing: -3,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.totalTime,
                      style: TextStyle(
                        fontSize: 13,
                        letterSpacing: 1.2,
                        color: colors.softMute,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  key: const Key('done_back_home'),
                  onPressed: onBackHome ?? () {},
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    elevation: 0,
                    backgroundColor: colors.ink,
                    foregroundColor: colors.inverse,
                    shape: const StadiumBorder(),
                  ),
                  child: Text(l10n.backHome),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(int seconds) {
    final int m = seconds ~/ 60;
    final int s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

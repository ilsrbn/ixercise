import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ixercise/design_system/ix_button.dart';
import 'package:ixercise/design_system/theme.dart';
import 'package:ixercise/features/settings/locale_controller.dart';

class LanguageScreen extends ConsumerStatefulWidget {
  const LanguageScreen({super.key, required this.onSelected});

  final VoidCallback onSelected;

  @override
  ConsumerState<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends ConsumerState<LanguageScreen> {
  String? _selectedCode;

  @override
  Widget build(BuildContext context) {
    final IxThemeColors colors = context.ixColors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Choose\nyour language.',
                style: TextStyle(
                  fontSize: 42,
                  letterSpacing: -1.2,
                  height: 1.0,
                  fontWeight: FontWeight.w700,
                  color: colors.ink,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'You can change this later in settings.',
                style: TextStyle(
                  fontSize: 15,
                  color: colors.mute,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 32),
              _LanguageOption(
                label: 'English',
                selected: _selectedCode == 'en',
                onTap: () => setState(() => _selectedCode = 'en'),
              ),
              const SizedBox(height: 10),
              _LanguageOption(
                label: 'Українська',
                selected: _selectedCode == 'uk',
                onTap: () => setState(() => _selectedCode = 'uk'),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: IxButton.primary(
                  key: const Key('language_continue'),
                  label: 'Continue',
                  onPressed: _selectedCode != null ? _handleContinue : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleContinue() async {
    if (_selectedCode == null) return;
    await ref
        .read(localeControllerProvider.notifier)
        .setLocale(Locale(_selectedCode!));
    widget.onSelected();
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final IxThemeColors colors = context.ixColors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: selected ? colors.ink : colors.surface,
          border: Border.all(color: selected ? colors.ink : colors.line),
        ),
        child: Row(
          children: <Widget>[
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: selected ? colors.inverse : colors.ink,
              ),
            ),
            const Spacer(),
            if (selected)
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: colors.accent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 14, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}

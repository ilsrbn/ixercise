import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ixercise/data/repositories.dart';
import 'package:ixercise/l10n/app_localizations.dart';

class LocaleState {
  const LocaleState({required this.isLoading, this.locale});
  final bool isLoading;
  final Locale? locale;
}

class LocaleController extends StateNotifier<LocaleState> {
  LocaleController(this._repository) : super(const LocaleState(isLoading: true)) {
    _hydrate();
  }
  final LocaleRepository _repository;

  Future<void> _hydrate() async {
    try {
      final String? code = await _repository.load();
      state = LocaleState(isLoading: false, locale: code != null ? Locale(code) : null);
    } catch (_) {
      state = const LocaleState(isLoading: false, locale: null);
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = LocaleState(isLoading: false, locale: locale);
    await _repository.save(locale.languageCode);
  }
}

final localeControllerProvider = StateNotifierProvider<LocaleController, LocaleState>(
  (ref) => LocaleController(ref.watch(localeRepositoryProvider)),
);

final appStringsProvider = Provider<AppLocalizations>((ref) {
  final Locale locale =
      ref.watch(localeControllerProvider).locale ?? const Locale('en');
  return AppLocalizations(locale);
});

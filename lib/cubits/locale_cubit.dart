import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/settings_service.dart';

class LocaleCubit extends Cubit<Locale> {
  final SettingsService _settingsService;
  late StreamSubscription _settingsSubscription;

  LocaleCubit(this._settingsService)
      : super(Locale(_settingsService.getLanguageSetting())) {
    _settingsSubscription = _settingsService.settingsStream.listen((_) {
      final lang = _settingsService.getLanguageSetting();
      final newLocale = Locale(lang);
      if (state != newLocale) {
        emit(newLocale);
      }
    });
  }

  void setLocale(String languageCode) {
    _settingsService.updateLanguageSetting(languageCode);
  }

  static LocaleCubit create(BuildContext context) {
    return LocaleCubit(context.read<SettingsService>());
  }

  @override
  Future<void> close() {
    _settingsSubscription.cancel();
    return super.close();
  }
}

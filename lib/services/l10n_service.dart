import '../l10n/app_localizations.dart';

class L10nService {
  static late AppLocalizations current;

  static void update(AppLocalizations localizations) {
    current = localizations;
  }
}

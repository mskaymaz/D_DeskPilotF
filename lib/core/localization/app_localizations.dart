import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import '../design_tokens/design_tokens.dart';

class AppLocalizations {
  final Locale locale;
  late final Map<String, String> _strings;

  AppLocalizations(this.locale) {
    _strings = locale.languageCode == 'tr' ? _tr : _en;
  }

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  String tr(String key) {
    return _strings[key] ?? key;
  }

  static const Map<String, String> _tr = {
    'app_title': 'DeskPilotF',
    'settings': 'Ayarlar',
    'todo': 'Yapılacaklar',
    'reminder': 'Hatırlatıcı',
    'clock': 'Saat',
    'date': 'Tarih',
    'battery': 'Pil',
    'close': 'Kapat',
    'open': 'Aç',
    'save': 'Kaydet',
    'cancel': 'İptal',
    'delete': 'Sil',
    'edit': 'Düzenle',
    'add': 'Ekle',
    'new': 'Yeni',
    'search': 'Ara',
    'clear': 'Temizle',
    'confirm': 'Onayla',
    'discard': 'Vazgeç',
    'loading': 'Yükleniyor...',
    'error_occurred': 'Bir hata oluştu',
    'settings_saved': 'Ayarlar kaydedildi',
    'settings_reset': 'Ayarlar sıfırlandı',
    'no_items': 'Öğe yok',
    'todo_empty': 'Henüz yapılacak yok',
    'reminder_empty': 'Henüz hatırlatıcı yok',
    'welcome': 'Hoş geldiniz',
  };

  static const Map<String, String> _en = {
    'app_title': 'DeskPilotF',
    'settings': 'Settings',
    'todo': 'Todo',
    'reminder': 'Reminder',
    'clock': 'Clock',
    'date': 'Date',
    'battery': 'Battery',
    'close': 'Close',
    'open': 'Open',
    'save': 'Save',
    'cancel': 'Cancel',
    'delete': 'Delete',
    'edit': 'Edit',
    'add': 'Add',
    'new': 'New',
    'search': 'Search',
    'clear': 'Clear',
    'confirm': 'Confirm',
    'discard': 'Discard',
    'loading': 'Loading...',
    'error_occurred': 'An error occurred',
    'settings_saved': 'Settings saved',
    'settings_reset': 'Settings reset',
    'no_items': 'No items',
    'todo_empty': 'No todos yet',
    'reminder_empty': 'No reminders yet',
    'welcome': 'Welcome',
  };
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['tr', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

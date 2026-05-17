import 'package:flutter/material.dart';

/// Localization strings for [CDatePicker].
class CalendarPickerLocalizations {
  final String selectEndDate;
  final String daysLabel;
  final List<String> weekDays;
  final String localeCode;

  const CalendarPickerLocalizations({
    required this.selectEndDate,
    required this.daysLabel,
    required this.weekDays,
    required this.localeCode,
  });

  static const english = CalendarPickerLocalizations(
    selectEndDate: 'select end date',
    daysLabel: 'days',
    weekDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    localeCode: 'en',
  );

  static const italian = CalendarPickerLocalizations(
    selectEndDate: 'seleziona data fine',
    daysLabel: 'giorni',
    weekDays: ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'],
    localeCode: 'it',
  );

  static const french = CalendarPickerLocalizations(
    selectEndDate: 'sélectionner la date de fin',
    daysLabel: 'jours',
    weekDays: ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'],
    localeCode: 'fr',
  );

  static const spanish = CalendarPickerLocalizations(
    selectEndDate: 'seleccionar fecha final',
    daysLabel: 'días',
    weekDays: ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'],
    localeCode: 'es',
  );

  static const portuguese = CalendarPickerLocalizations(
    selectEndDate: 'selecionar data final',
    daysLabel: 'dias',
    weekDays: ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'],
    localeCode: 'pt',
  );

  static const german = CalendarPickerLocalizations(
    selectEndDate: 'Enddatum wählen',
    daysLabel: 'Tage',
    weekDays: ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'],
    localeCode: 'de',
  );

  static CalendarPickerLocalizations fromLocale(String localeCode) {
    final code = localeCode.toLowerCase().split('_').first;
    switch (code) {
      case 'it':
        return italian;
      case 'fr':
        return french;
      case 'es':
        return spanish;
      case 'pt':
        return portuguese;
      case 'de':
        return german;
      case 'en':
      default:
        return english;
    }
  }

  static CalendarPickerLocalizations of(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return fromLocale(locale.languageCode);
  }
}

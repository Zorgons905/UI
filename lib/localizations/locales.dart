import 'package:flutter_localization/flutter_localization.dart';

const List<MapLocale> LOCALES = [
  MapLocale("en", LocaleData.EN),
  MapLocale("id", LocaleData.ID),
];

mixin LocaleData {
  static const String appName = 'DOKO';
  static const String hello = 'hello';
  static const String welcome = 'welcome';

  static const Map<String, dynamic> EN = {
    hello: 'Hello %a!',
    welcome: 'Welcome back to $appName',
  };

  static const Map<String, dynamic> ID = {
    hello: 'Halo %a!',
    welcome: 'Selamat datang lagi di $appName',
  };
}

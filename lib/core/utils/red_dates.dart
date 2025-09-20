// import '../constants/user_preference.dart';
// import 'package:dokie/models/user_preference.dart';
// import 'package:flutter/material.dart';

// class RedDates {
//   final bool isEn;
//   final Map<String, List<String>> _fixedHolidays;

//   RedDates(BuildContext context)
//     : isEn =
//           Provider.of<UserPreference>(context, listen: false).language == 'en',
//       _fixedHolidays = {
//         '-01-01': ['New Year\'s Eve', 'Tahun Baru Masehi'],
//         '-05-01': ['International Worker\'s Day', 'Hari Buruh'],
//         '-06-01': ['Pancasila Sanctity Day', 'Hari Kesaktian Pancasila'],
//         '-08-17': [
//           'Indonesia\'s Independence Day',
//           'Hari Kemerdekaan Indonesia',
//         ],
//         '-12-25': ['Christmas\'s Eve', 'Hari Natal'],
//         '-12-26': [
//           'Christmas\'s Eve (Day-Off)',
//           'Cuti Bersama Hari Raya Natal',
//         ],
//       };

//   Map<String, List<String>> getRedDates({int? startYear, int? endYear}) {
//     final now = DateTime.now();
//     final int start = startYear ?? now.year;
//     final int end = endYear ?? now.year + 1;
//     final Map<String, List<String>> redDates = {};

//     String formatDateKey(DateTime date) =>
//         "${date.year.toString().padLeft(4, '0')}-"
//         "${date.month.toString().padLeft(2, '0')}-"
//         "${date.day.toString().padLeft(2, '0')}";

//     void add(DateTime date, String label) {
//       if (date.year < start || date.year > end) return;
//       final key = formatDateKey(date);
//       redDates.putIfAbsent(key, () => []).add(label);
//     }

//     // Tambahkan fixed holidays untuk semua tahun di rentang [start..end]
//     for (int y = start; y <= end; y++) {
//       for (var entry in _fixedHolidays.entries) {
//         final dateStr = '$y${entry.key}';
//         final label = isEn ? entry.value.first : entry.value.last;
//         final labelWithYear =
//             label.contains('New Year') || label.contains('Tahun Baru')
//                 ? '$label $y'
//                 : label;
//         redDates[dateStr] = [labelWithYear];
//       }
//     }

//     DateTime hijriyahToGregorian(int hYear, int hMonth, int hDay) {
//       const double islamicEPOCH = 1948439.5;
//       const double gregorianEPOCH = 1721425.5;

//       // Hitung Julian Day Number (JDN) dari tanggal Hijriyah
//       final double jdn =
//           islamicEPOCH +
//           (hYear - 1) * 354 +
//           (hYear - 1) ~/ 30 * 11 +
//           (hMonth - 1) * 29 +
//           ((hMonth - 1) ~/ 2).toDouble() +
//           hDay;

//       // Hitung jumlah hari sejak Gregorian Epoch
//       final double daysSinceEpoch = jdn - gregorianEPOCH;

//       // Konversi ke tahun Gregorian
//       int year = ((daysSinceEpoch - 0.5) / 365.25).floor();
//       double dayOfYear = daysSinceEpoch - (365.25 * year).floor();
//       int month = ((dayOfYear - 0.5) / 30.6).floor() + 1;
//       int day = (dayOfYear - (30.6 * (month - 1)).floor()).floor();
//       var result = DateTime.utc(year, month + 1, day - 1);
//       return result;
//     }

//     /// Perkiraan pergeseran Hijriyah ±10.875 hari mundur tiap tahun dari basis 2024
//     DateTime shiftHijriFromHijriDate(int hYear, int hMonth, int hDay) {
//       return hijriyahToGregorian(hYear, hMonth, hDay);
//     }

//     for (int y = start; y < end; y++) {
//       final idulFitri1 = shiftHijriFromHijriDate(y - 578, 10, 1);
//       final idulFitri2 = shiftHijriFromHijriDate(y - 578, 10, 2);
//       final idulAdha = shiftHijriFromHijriDate(y - 578, 12, 10);
//       final israMiraj = shiftHijriFromHijriDate(y - 577, 7, 27);
//       final tahunBaruHijriyah = shiftHijriFromHijriDate(y - 577, 1, 1);
//       final maulid = shiftHijriFromHijriDate(y - 577, 3, 12);
//       final awalRamadhan = shiftHijriFromHijriDate(y - 578, 9, 1);

//       add(awalRamadhan, isEn ? 'The Beginning of Ramadhan' : 'Awal Ramadhan');
//       add(israMiraj, 'Isra Mi\'raj');
//       add(
//         tahunBaruHijriyah,
//         isEn ? 'Islamic New Year ${y - 578}H' : 'Tahun Baru Islam ${y - 578}H',
//       );
//       add(maulid, isEn ? 'Mawlid An-nabi' : 'Maulid Nabi Muhammad');
//       add(idulFitri1, isEn ? 'Eid Al Fitr' : 'Hari Raya Idul Fitri');
//       add(idulFitri2, isEn ? 'Eid Al Fitr' : 'Hari Raya Idul Fitri');
//       add(idulAdha, isEn ? 'Eid Al Adha' : 'Hari Raya Idul Adha');

//       add(
//         idulFitri1.add(Duration(days: -1)),
//         isEn ? 'Eid Al Fitr (Day-Off)' : 'Cuti Bersama Idul Fitri',
//       );
//       add(
//         idulFitri2.add(Duration(days: 1)),
//         isEn ? 'Eid Al Fitr (Day-Off)' : 'Cuti Bersama Idul Fitri',
//       );
//       add(
//         idulFitri2.add(Duration(days: 2)),
//         isEn ? 'Eid Al Fitr (Day-Off)' : 'Cuti Bersama Idul Fitri',
//       );
//       add(
//         idulFitri2.add(Duration(days: 3)),
//         isEn ? 'Eid Al Fitr (Day-Off)' : 'Cuti Bersama Idul Fitri',
//       );
//       add(
//         idulFitri2.add(Duration(days: 6)),
//         isEn ? 'Eid Al Fitr (Day-Off)' : 'Cuti Bersama Idul Fitri',
//       );
//       add(
//         idulAdha.add(Duration(days: 3)),
//         isEn ? 'Eid Al Adha (Day-Off)' : 'Cuti Bersama Idul Adha',
//       );
//       final imlekDates = {
//         2024: DateTime(2024, 2, 10),
//         2025: DateTime(2025, 1, 29),
//         2026: DateTime(2026, 2, 17),
//         2027: DateTime(2027, 2, 6),
//         2028: DateTime(2028, 1, 26),
//         2029: DateTime(2029, 2, 13),
//         2030: DateTime(2030, 2, 3),
//       };

//       final waisakDates = {
//         2024: DateTime(2024, 5, 23),
//         2025: DateTime(2025, 5, 12),
//         2026: DateTime(2026, 5, 31),
//         2027: DateTime(2027, 5, 20),
//         2028: DateTime(2028, 5, 9),
//         2029: DateTime(2029, 5, 27),
//         2030: DateTime(2030, 5, 17),
//       };

//       final nyepiDates = {
//         2024: DateTime(2024, 3, 11),
//         2025: DateTime(2025, 3, 29),
//         2026: DateTime(2026, 3, 19),
//         2027: DateTime(2027, 3, 8),
//         2028: DateTime(2028, 3, 26),
//         2029: DateTime(2029, 3, 14),
//         2030: DateTime(2030, 3, 5),
//       };

//       final imlek = imlekDates[y];
//       if (imlek != null) {
//         add(imlek, isEn ? 'Lunar New Year' : 'Tahun Baru Imlek');
//         add(
//           imlek.subtract(Duration(days: 1)),
//           isEn ? 'Lunar New Year (Day-Off)' : 'Cuti Bersama Imlek',
//         );
//       }

//       final waisak = waisakDates[y];
//       if (waisak != null) {
//         add(waisak, isEn ? 'Vesak Day' : 'Hari Raya Waisak');
//         add(
//           waisak.add(Duration(days: 1)),
//           isEn ? 'Vesak Day (Day-Off)' : 'Cuti Bersama Waisak',
//         );
//       }

//       final nyepi = nyepiDates[y];
//       if (nyepi != null) {
//         add(nyepi, isEn ? 'Nyepi Day' : 'Hari Raya Nyepi');
//         add(
//           nyepi.add(Duration(days: 1)),
//           isEn ? 'Nyepi Day (Day-Off)' : 'Cuti Bersama Nyepi',
//         );
//       }
//     }

//     // Hitung Paskah dan turunannya menggunakan algoritma Anonymous Gregorian
//     DateTime calcEaster(int year) {
//       final a = year % 19;
//       final b = year ~/ 100;
//       final c = year % 100;
//       final d = b ~/ 4;
//       final e = b % 4;
//       final f = (b + 8) ~/ 25;
//       final g = (b - f + 1) ~/ 3;
//       final h = (19 * a + b - d - g + 15) % 30;
//       final i = c ~/ 4;
//       final k = c % 4;
//       final l = (32 + 2 * e + 2 * i - h - k) % 7;
//       final m = (a + 11 * h + 22 * l) ~/ 451;
//       final month = (h + l - 7 * m + 114) ~/ 31;
//       final day = ((h + l - 7 * m + 114) % 31) + 1;
//       return DateTime(year, month, day);
//     }

//     for (int y = start; y < end; y++) {
//       final easter = calcEaster(y);
//       final goodFriday = easter.subtract(Duration(days: 2));
//       final ascension = easter.add(Duration(days: 39));

//       add(goodFriday, isEn ? 'Good Friday' : 'Jumat Agung (Wafat Isa Almasih)');
//       add(easter, isEn ? 'Easter' : 'Hari Paskah');
//       add(ascension, isEn ? 'Ascension Day' : 'Kenaikan Isa Almasih');

//       add(
//         ascension.add(Duration(days: 1)),
//         isEn ? 'Ascension Day (Day-Off)' : 'Cuti Bersama Kenaikan Isa Almasih',
//       );
//     }

//     // Sortir berdasarkan tanggal (key)
//     return Map.fromEntries(
//       redDates.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
//     );
//   }

//   /// Mendapatkan tanggal merah untuk bulan dan tahun tertentu saja
//   Map<String, List<String>> getRedDatesForMonth(int year, int month) {
//     if (month < 1 || month > 12) return {};
//     if (year < 1) return {};

//     final allRedDates = getRedDates(startYear: year, endYear: year + 1);

//     final filtered = <String, List<String>>{};
//     allRedDates.forEach((dateStr, labels) {
//       final parts = dateStr.split('-');
//       if (parts.length == 3) {
//         final y = int.tryParse(parts[0]);
//         final m = int.tryParse(parts[1]);
//         if (y == year && m == month) {
//           filtered[dateStr] = labels;
//         }
//       }
//     });

//     return filtered;
//   }
// }

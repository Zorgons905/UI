import 'package:flutter/material.dart';

/*
untuk masalah color mengikuti preferensi user jika user
memilih violet (defaultnya violet) maka ia (colorPreference) akan
di set violet.
*/

/*
jangan gunakan list color ini secara literal 
gunakan colorPreference dari user
*/

const List<Color> violet = [
  Color(0xff30074f), //0 untuk gradasi gelap navbar
  Color(0xff4d107f), //1 untuk navbar dan counter di group
  Color(0xff7E1AD1), //2 untuk appbar, calendar, dan judul group
  Color(0xffb877f0), //3 untuk gradasi appbar, dan warna description
];

const List<Color> rose = [
  Color(0xff990000),
  Color(0xffCE2424),
  Color(0xffff8080),
  Color(0xffffb3b3),
];

const List<Color> amber = [
  Color(0xfffa7d00),
  Color(0xffffb333),
  Color(0xffffd34d),
  Color(0xffffee99),
];

const List<Color> grass = [
  Color(0xff236e0e),
  Color(0xff1c8720),
  Color(0xff35a017),
  Color(0xFF6BEA66),
];

const List<Color> ocean = [
  Color(0xff2851c6),
  Color(0xff3f72e0),
  Color(0xff0f9cf8),
  Color(0xff63cbff),
];

const List<Color> wood = [
  Color(0xff663300),
  Color(0xff8a4a2d),
  Color(0xffaf6e4d),
  Color(0xffdfa57d),
];

const List<Color> metal = [
  Color(0xff404040),
  Color(0xff5e5e5e),
  Color(0xff757575),
  Color(0xff9c9c9c),
];

/*
Ini default pallete untuk lightmode dan darkmode
*/
const Color white1 = Color(0xFFFFFFFF); //buat foreground / tulisan
const Color white2 = Color(0xFFF5F5F5); //buat hint text
const Color gray1 = Color(0xFF7F7F7F); //buat box shadow
const Color gray2 = Color(0xFF3F3F3F); //buat title
const Color black1 = Color(0xFF141414); //buat tulisan
const Color black2 = Color(0xFF000000); //buat tulisan
const Color transparent = Colors.transparent;

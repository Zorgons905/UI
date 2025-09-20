import 'package:flutter/material.dart';

Widget buildShadowedButton({required Widget child}) {
  return PhysicalModel(
    color: Colors.transparent,
    elevation: 5,
    shadowColor: Colors.black45,
    shape: BoxShape.circle,
    child: child,
  );
}
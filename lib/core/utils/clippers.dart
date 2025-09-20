import 'package:flutter/material.dart';

class BookmarkClipper extends CustomClipper<Path> {
  final bool isCompactView;

  BookmarkClipper({required this.isCompactView});

  @override
  Path getClip(Size size) {
    final path = Path();

    if (isCompactView) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height / 2);
      path.lineTo(size.width / 2, size.height - 5);
      path.lineTo(0, size.height / 2);
      path.close();
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width / 2, size.height - 10);
      path.lineTo(0, size.height);
      path.close();
    }
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class TriangleClipper extends CustomClipper<Path> {
  final double progress;
  final bool isFlippingRight;

  TriangleClipper({required this.progress, required this.isFlippingRight});

  @override
  Path getClip(Size size) {
    var path = Path();

    if (progress == 0) {
      path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
      return path;
    }

    if (isFlippingRight) {
      final diagonal = size.width + size.height;
      final currentSize = diagonal * progress;

      path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));

      final trianglePath = Path();
      trianglePath.moveTo(size.width, size.height);
      trianglePath.lineTo(size.width - currentSize, size.height);
      trianglePath.lineTo(size.width, size.height - currentSize);
      trianglePath.close();

      path = Path.combine(PathOperation.difference, path, trianglePath);
    } else {
      final diagonal = size.width + size.height;
      final currentSize = diagonal * progress;

      path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));

      final trianglePath = Path();
      trianglePath.moveTo(0, 0);
      trianglePath.lineTo(currentSize, 0);
      trianglePath.lineTo(0, currentSize);
      trianglePath.close();

      path = Path.combine(PathOperation.difference, path, trianglePath);
    }

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

class MonthHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final double triangleWidth = 30.0;

    path.moveTo(triangleWidth, 0);
    path.lineTo(size.width - triangleWidth, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width - triangleWidth, size.height);
    path.lineTo(triangleWidth, size.height);
    path.lineTo(0, size.height / 2);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

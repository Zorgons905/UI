import "package:flutter/material.dart";

class DotLineAssets extends StatelessWidget {
  final int count;
  final double gap;
  final double height;
  final double width;
  final Color color;

  const DotLineAssets({
    Key? key,
    this.count = 15,
    this.gap = 10.0,
    this.height = 7.5,
    this.width = 10.0,

    this.color = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        count,
        (index) => Container(
          margin: EdgeInsets.only(right: index < count - 1 ? gap : 0),
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(50),
            ),
          ),
        ),
      ),
    );
  }
}

class VerticalLineAssets extends StatelessWidget {
  final int count;
  final double gap;
  final double height;
  final double width;
  final Color color;

  const VerticalLineAssets({
    Key? key,
    this.count = 15,
    this.gap = 20.0,
    this.height = 20.0,
    this.width = 15.0,
    this.color = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(
        count,
        (index) => Container(
          margin: EdgeInsets.only(right: index < count - 1 ? gap : 0),
          child: Container(
            width: width,
            height: (index == 0) ? height / 1.25 : height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

class DiagonalLineAssets extends StatelessWidget {
  final int count;
  final double gap;
  final double width;
  final double height;
  final Color color;

  const DiagonalLineAssets({
    Key? key,
    this.count = 15,
    this.gap = 20.0,
    this.width = 4.0,
    this.height = 28.28,
    this.color = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        count,
        (index) => Container(
          margin: EdgeInsets.only(right: index < count - 1 ? gap : 0),
          child: Transform.rotate(
            angle: 0.75,
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

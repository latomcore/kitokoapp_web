import 'package:flutter/material.dart';

class TSeparator extends StatelessWidget {
  final double height;
  final double width;
  final Color color;

  const TSeparator({
    super.key,
    this.height = 300,
    this.width = 2,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: width,
          height: height,
          color: color,
        ),
        Positioned(
          top: height / 2,
          child: Container(
            width: 16,
            height: width,
            color: color,
          ),
        ),
      ],
    );
  }
}

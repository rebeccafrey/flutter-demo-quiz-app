import 'package:flutter/material.dart';
import 'package:quiz_app/constants.dart';

class ReusableText extends StatelessWidget {
  ReusableText({
    this.textColor = colorWhite,
    this.text,
    this.textAlign = TextAlign.center,
    this.decoration = TextDecoration.none,
    this.fontSize = 18,
    this.fontWeight = FontWeight.normal,
    this.maxLines,
    this.overflow,
  });

  final Color textColor;
  final String text;
  final TextAlign textAlign;
  final TextDecoration decoration;
  final double fontSize;
  final FontWeight fontWeight;
  final int maxLines;
  final TextOverflow overflow;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: textColor,
        decoration: decoration,
      ),
    );
  }
}

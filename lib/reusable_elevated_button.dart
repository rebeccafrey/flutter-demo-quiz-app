import 'package:flutter/material.dart';
import 'package:quiz_app/constants.dart';

class ReusableElevatedButton extends StatelessWidget {
  ReusableElevatedButton({
    this.backgroundColour = primaryColorLight,
    this.textColor = colorBlack,
    this.text,
    this.textAlign = TextAlign.center,
    this.decoration,
    this.onPressed,
    this.fontSize = 20,
    this.height,
    this.padding = const EdgeInsets.all(12.0),
  });

  final Color backgroundColour;
  final Color textColor;
  final String text;
  final TextAlign textAlign;
  final TextDecoration decoration;
  final double fontSize;
  final Function onPressed;
  final double height;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      // reusable text button to take 70% of screen width:
      width: MediaQuery.of(context).size.width * 0.80,
      height: height,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          child: ElevatedButton(
            style: TextButton.styleFrom(
              backgroundColor: backgroundColour,
              padding: padding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: Text(
              text,
              textAlign: textAlign,
              style: TextStyle(
                fontSize: fontSize,
                color: textColor,
                decoration: decoration,
              ),
            ),
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:quiz_app/constants.dart';

class ReusableTextButton extends StatelessWidget {
  ReusableTextButton({
    this.textColor = colorWhite,
    this.text,
    this.textAlign = TextAlign.center,
    this.decoration = TextDecoration.underline,
    this.onPressed,
    this.fontSize = 20,
    this.height,
  });

  final Color textColor;
  final String text;
  final TextAlign textAlign;
  final TextDecoration decoration;
  final double fontSize;
  final Function onPressed;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      // reusable text button to take 80% of screen width:
      width: MediaQuery.of(context).size.width * 0.80,
      height: height,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          child: TextButton(
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

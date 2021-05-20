import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quiz_app/constants.dart';
import 'package:quiz_app/reusable_text.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class ReusableAlert extends StatelessWidget {
  ReusableAlert({
    this.title,
    this.titleColor = primaryBackgroundColorLight,
    this.titleFontWeight = FontWeight.bold,
    this.titleFontSize = 24,
    this.contentColor = colorBlack,
    this.contentFontWeight,
    this.contentFontSize = 20,
    this.content,
    this.contentTextStyle,
    this.backgroundColor,
    this.semanticLabel,
    this.borderRadius,
    this.dialogButtonColor = primaryBackgroundColorLight,
    this.dialogButtonHeight = 60,
    this.onPressed,
    this.dialogButtonText,
  });

  final Widget title;
  final Color titleColor;
  final FontWeight titleFontWeight;
  final double titleFontSize;
  final List<Widget> content;
  final Color contentColor;
  final FontWeight contentFontWeight;
  final double contentFontSize;
  final TextStyle contentTextStyle;
  final Color backgroundColor;
  final String semanticLabel;
  final BorderRadius borderRadius;
  final Color dialogButtonColor;
  final double dialogButtonHeight;
  final Function onPressed;
  final String dialogButtonText;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title,
      titleTextStyle: TextStyle(
        color: titleColor,
        fontWeight: titleFontWeight,
        fontSize: titleFontSize,
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: content,
        ),
      ),
      contentTextStyle: TextStyle(
        color: contentColor,
        fontWeight: contentFontWeight,
        fontSize: contentFontSize,
      ),
      actions: [
        DialogButton(
          height: dialogButtonHeight,
          padding: EdgeInsets.all(12),
          color: dialogButtonColor,
          radius: BorderRadius.circular(100),
          onPressed: onPressed,
          child: ReusableText(
            text: dialogButtonText,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ],
      backgroundColor: backgroundColor,
      semanticLabel: semanticLabel,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:quiz_app/constants.dart';
import 'package:quiz_app/reusable_elevated_button.dart';
import 'package:quiz_app/reusable_text.dart';

class ReusableWillPopScope extends StatelessWidget {
  ReusableWillPopScope({
    this.titleText,
    this.contentText,
    this.child,
  });

  final String titleText;
  final String contentText;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: ReusableText(
                    text: titleText,
                    textColor: colorBlack,
                  ),
                  content: ReusableText(
                    text: contentText,
                    textColor: colorBlack,
                  ),
                  actions: [
                    ReusableElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      text: 'Ok',
                    ),
                  ],
                ));
      },
      child: child,
    );
  }
}

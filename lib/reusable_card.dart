import 'package:flutter/material.dart';
import 'package:quiz_app/constants.dart';
import 'package:quiz_app/reusable_text.dart';

class ReusableCard extends StatelessWidget {
  const ReusableCard({
    this.text,
    this.color = primaryColorLight,
  });
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 12,
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        margin: EdgeInsets.all(15),
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.3,
        child: Center(
          child: ReusableText(
            text: text,
            fontSize: 24,
            textColor: colorBlack,
          ),
        ),
      ),
    );
  }
}

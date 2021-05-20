import 'package:flutter/material.dart';
import 'package:quiz_app/reusable_elevated_button.dart';
import 'package:quiz_app/reusable_text.dart';
import 'package:quiz_app/reusable_text_button.dart';
import 'package:quiz_app/reusable_will_pop_scope.dart';

class ScorePage extends StatefulWidget {
  static const routeName = '/score';

  final int score;

  ScorePage({Key key, @required this.score}) : super(key: key);

  @override
  _ScorePageState createState() => _ScorePageState(score);
}

class _ScorePageState extends State<ScorePage> {
  int score;
  _ScorePageState(this.score);

  displayResult() => (score == null) ? 'No score to display' : score.toString();

  @override
  Widget build(BuildContext context) {
    return ReusableWillPopScope(
      titleText: 'Sorry',
      contentText: 'You can\'t go back at this stage. '
          'Instead, choose an option with the buttons below.',
      child: Scaffold(
        appBar: AppBar(title: Text('Your score this time')),
        body: SafeArea(
          child: Center(
            child: Column(
              children: [
                Spacer(),
                _resultDisplay(),
                Spacer(),
                _navButtons(),
                ReusableElevatedButton(
                  text: 'Go to score overview',
                  onPressed: () {
                    Navigator.pushNamed(context, '/highscore');
                  },
                ),
                ReusableTextButton(
                  text: 'or go home',
                  onPressed: () {
                    Navigator.pushNamed(context, '/');
                  },
                ),
                //Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //code for landscape orientation - not needed but left in for reference
  Widget _resultDisplay() {
    Orientation orientation = MediaQuery.of(context).orientation;

    if (orientation == Orientation.portrait) {
      return Column(
        children: [
          ReusableText(
            text: 'Your score is:',
            fontSize: 26,
          ),
          ReusableText(
            text: displayResult(),
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: ReusableText(
              text: 'Your score is:',
              fontSize: 26,
            ),
          ),
          ReusableText(
            text: displayResult(),
            fontSize: 40,
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.end,
          ),
        ],
      );
    }
  }

  Widget _navButtons() {
    Orientation orientation = MediaQuery.of(context).orientation;

    if (orientation == Orientation.portrait) {
      return Column(
        children: [
          ReusableElevatedButton(
            text: 'Take quiz in slow mode',
            onPressed: () {
              Navigator.pushNamed(context, '/quiz');
            },
          ),
          ReusableElevatedButton(
            text: 'Take timed swipey quiz',
            onPressed: () {
              Navigator.pushNamed(context, '/swipe-quiz');
            },
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: ReusableElevatedButton(
              text: 'Go to start of quiz',
              onPressed: () {
                Navigator.pushNamed(context, '/rotate-card-swipe');
              },
            ),
          ),
          Expanded(
            child: ReusableElevatedButton(
              text: 'Take timed swipey quiz',
              onPressed: () {
                Navigator.pushNamed(context, '/swipe-quiz');
              },
            ),
          ),
        ],
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:quiz_app/constants.dart';
import 'package:quiz_app/reusable_elevated_button.dart';
import 'package:quiz_app/reusable_text.dart';
import 'package:quiz_app/reusable_text_button.dart';
import 'package:quiz_app/reusable_will_pop_scope.dart';

class ScoreWithCategoriesPage extends StatefulWidget {
  static const routeName = '/score-category';

  final int totalScore;
  final int musicScore;
  final int filmScore;
  final List mydata;

  ScoreWithCategoriesPage(
      {Key key,
      @required this.totalScore,
      this.musicScore,
      this.filmScore,
      @required this.mydata})
      : super(key: key);

  @override
  _ScoreWithCategoriesPageState createState() => _ScoreWithCategoriesPageState(
        totalScore,
        musicScore,
        filmScore,
        mydata,
      );
}

class _ScoreWithCategoriesPageState extends State<ScoreWithCategoriesPage> {
  int totalScore;
  int musicScore;
  int filmScore;
  final List mydata;
  _ScoreWithCategoriesPageState(
      this.totalScore, this.musicScore, this.filmScore, this.mydata);

  displayResult() =>
      (totalScore == null) ? 'No score to display' : totalScore.toString();

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
                ReusableText(
                  text: 'Your total score is:',
                  fontSize: 26,
                ),
                ReusableText(
                  text: displayResult(),
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
                ReusableText(
                  text: 'out of ${mydata.length} questions',
                  fontSize: 26,
                ),
                Container(
                  padding: EdgeInsets.all(15),
                  margin: EdgeInsets.fromLTRB(10, 40, 10, 20),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                    colors: [
                      primaryColorLight,
                      secondaryColorLight,
                    ],
                  )),
                  child: Column(
                    children: [
                      ReusableText(
                        text: 'Your scores per category:',
                        textAlign: TextAlign.left,
                        fontSize: 24,
                        decoration: TextDecoration.underline,
                        textColor: colorBlack,
                      ),
                      Table(
                        defaultColumnWidth: FlexColumnWidth(1),
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        children: [
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Icon(
                                  Icons.local_movies,
                                  size: 48,
                                  color: colorBlack,
                                ),
                              ),
                              ReusableText(
                                text: filmScore.toString(),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                textColor: colorBlack,
                              ),
                              ReusableText(
                                text: '(film)',
                                fontSize: 24,
                                textAlign: TextAlign.end,
                                textColor: colorBlack,
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Icon(
                                  Icons.music_note,
                                  size: 48,
                                  color: colorBlack,
                                ),
                              ),
                              ReusableText(
                                text: musicScore.toString(),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                textColor: colorBlack,
                              ),
                              ReusableText(
                                text: '(music)',
                                fontSize: 24,
                                textAlign: TextAlign.end,
                                textColor: colorBlack,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Spacer(),
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
}

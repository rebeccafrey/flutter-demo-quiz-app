import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:quiz_app/database/database_helpers.dart';
import 'package:clay_containers/clay_containers.dart';

import 'package:quiz_app/constants.dart';
import 'package:quiz_app/reusable_text_button.dart';
import 'package:quiz_app/reusable_text.dart';

class HighscorePage extends StatefulWidget {
  static const routeName = '/highscore';

  @override
  _HighscorePageState createState() => _HighscorePageState();
}

class _HighscorePageState extends State<HighscorePage> {
  List<Highscore> highscoreList = List();

  @override
  void initState() {
    super.initState();

    DatabaseHelper.instance.queryAllRows().then((value) {
      setState(() {
        value.forEach((element) {
          highscoreList.add(
            Highscore(
              id: element['id'],
              highscore: element['highscore'],
              quizType: element['quizType'],
            ),
          );
        });
      });
    }).catchError((error) {
      print(error);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Your Scores')),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                child: ReusableText(
                  text: 'Your scores are as follows:',
                ),
              ),
              Container(
                child: highscoreList.isEmpty
                    ? Expanded(
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          alignment: Alignment.center,
                          child: ReusableText(
                            text: 'There are no scores to display. '
                                'Take the quiz now and start your journey.',
                          ),
                        ),
                      )
                    : Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24.0,
                            vertical: 12,
                          ),
                          child: ClayContainer(
                            color: primaryBackgroundColorLight,
                            borderRadius: 12,
                            emboss: true,
                            curveType: CurveType.concave,
                            child: ListView.builder(
                              itemBuilder: (context, index) {
                                if (index == highscoreList.length) return null;
                                return Center(
                                  child: ListTile(
                                    leading: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.2,
                                      child: ReusableText(
                                        text:
                                            highscoreList[index].id.toString() +
                                                '.',
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    title: Container(
                                      child: ReusableText(
                                        text: highscoreList[index]
                                            .highscore
                                            .toString(),
                                        textAlign: TextAlign.left,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    trailing: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                      child: ReusableText(
                                        text: highscoreList[index]
                                            .quizType
                                            .toString(),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
              ),
              ReusableTextButton(
                text: 'Go to home screen',
                onPressed: () {
                  Navigator.pushNamed(context, '/');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

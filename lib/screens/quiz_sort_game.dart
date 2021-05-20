import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quiz_app/constants.dart';
import 'package:quiz_app/reusable_elevated_button.dart';
import 'package:quiz_app/reusable_text.dart';

class QuizSortGame extends StatelessWidget {
  static const routeName = '/quiz-sort-game';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DefaultAssetBundle.of(context)
          .loadString('assets/sort_game_colours.json', cache: false),
      builder: (context, snapshot) {
        List sortGameData = json.decode(snapshot.data.toString());
        if (sortGameData == null) {
          return Scaffold(
            body: Center(
              child: ReusableText(
                text: 'Loading',
              ),
            ),
          );
        } else {
          return QuizSortGamePage(sortGameData: sortGameData);
        }
      },
    );
  }
}

class QuizSortGamePage extends StatefulWidget {
  final List sortGameData;

  QuizSortGamePage({Key key, @required this.sortGameData}) : super(key: key);
  @override
  _QuizSortGamePageState createState() => _QuizSortGamePageState(sortGameData);
}

class _QuizSortGamePageState extends State<QuizSortGamePage> {
  final List sortGameData;

  _QuizSortGamePageState(this.sortGameData);

  List shuffledSortGameAnswers;
  int score = 0;

  List shuffleSortGameAnswers() {
    shuffledSortGameAnswers = List.from(sortGameData[0]['answers']);
    shuffledSortGameAnswers.shuffle();
    return shuffledSortGameAnswers;
  }

  @override
  void initState() {
    shuffleSortGameAnswers();

    super.initState();
  }

  void checkOrder() {
    if (listEquals(sortGameData[0]['answers'], shuffledSortGameAnswers) ==
        true) {
      showOverlay(context, colorTrueGreen, Icon(Icons.check, size: 48));
    } else {
      showOverlay(context, colorFalseRed, Icon(Icons.close, size: 48));
    }
  }

  showOverlay(BuildContext context, Color color, Icon icon) async {
    OverlayState overlayState = Overlay.of(context);
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.transparent,
        child: Container(
          color: Colors.black38,
          child: Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: color,
              child: icon,
            ),
          ),
        ),
      ),
    );
    overlayState.insert(overlayEntry);
    await Future.delayed(Duration(seconds: 2));
    overlayEntry.remove();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(sortGameData[0]['appBarTitle']),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Expanded(
                child: ReorderableListView(
                  header: Container(
                    color: colorBlack,
                    margin: const EdgeInsets.all(12.0),
                    padding: const EdgeInsets.all(8.0),
                    child: ReusableText(
                      text: sortGameData[0]['instruction'],
                      fontSize: 20,
                    ),
                  ),
                  onReorder: (int oldIndex, int newIndex) {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }

                    setState(() {
                      String answer = shuffledSortGameAnswers[oldIndex];
                      shuffledSortGameAnswers.removeAt(oldIndex);
                      shuffledSortGameAnswers.insert(newIndex, answer);
                    });
                    return shuffledSortGameAnswers;
                  },
                  children: [
                    for (final answer in shuffledSortGameAnswers)
                      Container(
                        margin: const EdgeInsets.all(2.0),
                        key: ValueKey(answer),
                        child: Center(
                            child: ReusableText(
                          text: answer,
                          fontSize: 24,
                          textColor: colorBlack,
                        )),
                        height: MediaQuery.of(context).size.height * 0.1,
                        width: MediaQuery.of(context).size.width * 0.9,
                        decoration: BoxDecoration(
                          color: secondaryColorLight,
                          boxShadow: [
                            BoxShadow(
                              color: colorBlack.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset:
                                  Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                      )
                  ],
                ),
              ),
              ReusableElevatedButton(
                text: "Think you\'re done? Check the result!",
                onPressed: () {
                  setState(() {
                    checkOrder();
                  });
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

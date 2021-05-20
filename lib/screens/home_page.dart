import 'package:flutter/material.dart';
import 'package:quiz_app/constants.dart';
import 'package:quiz_app/reusable_elevated_button.dart';
import 'package:quiz_app/screens/quiz_open_text.dart';
import 'package:quiz_app/screens/quiz_drag_rainbow.dart';
import 'package:quiz_app/screens/quiz_calc.dart';
import 'package:quiz_app/screens/quiz_sort_game.dart';
import 'package:quiz_app/screens/quiz_mc_with_categories.dart';
import 'package:quiz_app/screens/quiz_buttons.dart';
import 'package:quiz_app/screens/quiz_swipe.dart';
import 'package:quiz_app/reusable_text.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map> quizInfo = [
    {
      'routeName': QuizSwipe.routeName,
      'quizName': 'Swipe | timer | optional asset | up to 3 directions | '
          'faster = higher score',
      'quizDesc': '>>swipe<<'
    },
    {
      'routeName': QuizButtons.routeName,
      'quizName': 'Buttons t/f | optional asset | no timer | animation',
      'quizDesc': '>>buttons<<'
    },
    {
      'routeName': QuizMCWithCategoriesPage.routeName,
      'quizName': 'MC | single correct answer | '
          'scores for categories | no timer | no assets | animation',
      'quizDesc': '>>mc with categories<<'
    },
    {
      'routeName': QuizSortGame.routeName,
      'quizName': 'Sort Game | rainbow colors | Reorderable ListView',
      'quizDesc': '>>make a rainbow<<'
    },
    {
      'routeName': QuizCalc.routeName,
      'quizName': 'Number Input | images according to input value',
      'quizDesc': '>>calculations<<'
    },
    {
      'routeName': QuizOpenText.routeName,
      'quizName': 'Open text field',
      'quizDesc': '>>open questions<<'
    },
    {
      'routeName': QuizDragRainbow.routeName,
      'quizName': 'Drag & Drop | only lands on correct tile',
      'quizDesc': '>>drag & drop<<'
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Welcome!')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ReusableText(
                    text: 'Welcome to this quiz compilation. '
                        'See below for your quiz choices. '
                        'Have fun!',
                  ),
                ),
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  //childAspectRatio: 1.3,
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 10.0,
                  children: [
                    for (var i = 0; i < quizInfo.length; i++)
                      buildInkWellNavTile(context, i),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ReusableText(
                          text: 'look at your score overview:',
                        ),
                        ReusableElevatedButton(
                          text: 'Go to score overview',
                          onPressed: () {
                            Navigator.pushNamed(context, '/highscore');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InkWell buildInkWellNavTile(BuildContext context, int index) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, quizInfo[index]['routeName']);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: ShaderMask(
          shaderCallback: (bounds) => RadialGradient(
            center: Alignment.topRight,
            radius: 1.1,
            colors: [
              primaryColorLight,
              primaryBackgroundColorLight,
            ],
            tileMode: TileMode.mirror,
          ).createShader(bounds),
          child: Container(
            color: colorWhite,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ReusableText(
                  text: quizInfo[index]['quizName'],
                  textColor: colorBlack,
                ),
                ReusableText(
                  text: quizInfo[index]['quizDesc'],
                  textColor: colorBlack,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

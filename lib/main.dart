import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:quiz_app/constants.dart';
import 'package:quiz_app/screens/highscore_page.dart';
import 'package:quiz_app/screens/home_page.dart';
import 'package:quiz_app/screens/quiz_open_text.dart';
import 'package:quiz_app/screens/quiz_drag_rainbow.dart';
import 'package:quiz_app/screens/quiz_mc_with_categories.dart';
import 'package:quiz_app/screens/quiz_buttons.dart';
import 'package:quiz_app/screens/score_category_page.dart';
import 'package:quiz_app/screens/score_page.dart';
import 'package:quiz_app/screens/quiz_calc.dart';
import 'package:quiz_app/screens/quiz_sort_game.dart';
import 'package:quiz_app/screens/quiz_swipe.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(Quiz());
}

class Quiz extends StatelessWidget {
  static int score;
  static int totalScore;
  static int musicScore;
  static int filmScore;
  static List mydata;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
    return MaterialApp(
      onGenerateRoute: (settings) {
        if (settings.name == ScorePage.routeName) {
          final ScreenArguments args = settings.arguments;

          return MaterialPageRoute(
            builder: (context) {
              return ScorePage(
                score: args.score,
              );
            },
          );
        }
        if (settings.name == ScoreWithCategoriesPage.routeName) {
          final ScreenArguments args = settings.arguments;

          return MaterialPageRoute(
            builder: (context) {
              return ScoreWithCategoriesPage(
                totalScore: args.totalScore,
                musicScore: args.musicScore,
                filmScore: args.filmScore,
                mydata: args.mydata,
              );
            },
          );
        }
        // The code only supports ScorePage.routeName right now.
        // Other values need to be implemented if we add them. The assertion
        // here will help remind us of that higher up in the call stack, since
        // this assertion would otherwise fire somewhere in the framework.
        assert(false, 'Need to implement ${settings.name}');
        return null;
      },
      theme: ThemeData(
        primaryColor: primaryBackgroundColorLight,
        accentColor: primaryColorLight,
        scaffoldBackgroundColor: primaryBackgroundColorLight,
        // buttonTheme: ButtonThemeData(
        //   buttonColor: Colors.amber,
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(100),
        //   ),
        // ),
      ),
      initialRoute: '/',
      routes: {
        ScorePage.routeName: (context) => ScorePage(
              score: score,
            ),
        ScoreWithCategoriesPage.routeName: (context) => ScoreWithCategoriesPage(
              totalScore: totalScore,
              musicScore: musicScore,
              filmScore: filmScore,
              mydata: mydata,
            ),
        '/': (context) => HomePage(),
        '/highscore': (context) => HighscorePage(),
        '/quiz-buttons': (context) => QuizButtons(),
        '/quiz-mc-with-categories': (context) => QuizMCWithCategoriesPage(),
        '/quiz-sort-game': (context) => QuizSortGame(),
        '/quiz-swipe': (context) => QuizSwipe(),
        '/quiz-calc': (context) => QuizCalc(),
        '/quiz-open-text': (context) => QuizOpenText(),
        '/quiz-drag-rainbow': (context) => QuizDragRainbow(),
      },
    );
  }
}

class ScreenArguments {
  final int score;
  final int totalScore;
  final int musicScore;
  final int filmScore;
  final List mydata;

  ScreenArguments(
    this.score,
    this.totalScore,
    this.musicScore,
    this.filmScore,
    this.mydata,
  );
}

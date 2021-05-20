import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quiz_app/constants.dart';
import 'package:quiz_app/database/database_helpers.dart';
import 'package:quiz_app/reusable_alert.dart';
import 'package:quiz_app/reusable_elevated_button.dart';
import 'package:quiz_app/reusable_text.dart';
import 'package:quiz_app/reusable_will_pop_scope.dart';
import 'package:quiz_app/screens/score_category_page.dart';

class QuizMCWithCategoriesPage extends StatelessWidget {
  static const routeName = '/quiz-mc-with-categories';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DefaultAssetBundle.of(context)
          .loadString('assets/mc_with_categories.json', cache: false),
      builder: (context, snapshot) {
        List mydata = json.decode(snapshot.data.toString());
        if (mydata == null) {
          return Scaffold(
            body: Center(
              child: ReusableText(
                text: 'Loading',
              ),
            ),
          );
        } else {
          return QuizPageMultiplechoice(mydata: mydata);
        }
      },
    );
  }
}

class QuizPageMultiplechoice extends StatefulWidget {
  final List mydata;

  QuizPageMultiplechoice({Key key, @required this.mydata}) : super(key: key);
  @override
  _QuizPageMultiplechoiceState createState() =>
      _QuizPageMultiplechoiceState(mydata);
}

class _QuizPageMultiplechoiceState extends State<QuizPageMultiplechoice> {
  final List mydata;

  _QuizPageMultiplechoiceState(this.mydata);

  List<Highscore> highscoreList = List();
  List<Container> scoreKeeper = [];
  int totalScore = 0;
  int filmScore = 0;
  int musicScore = 0;
  double opacityLevelCheckmark = 0;
  double opacityLevelX = 0;
  int i = 0;
  int j = 0;
  int questionNumber = 0;

  List<dynamic> randomizeArray() {
    var random = Random();

    for (var i = mydata.length - 1; i > 0; i--) {
      var n = random.nextInt(i + 1);

      var temp = mydata[i];
      mydata[i] = mydata[n];
      mydata[n] = temp;
    }
    return mydata;
  }

  @override
  void initState() {
    randomizeArray();
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ReusableAlert(
          semanticLabel: 'The quiz is finished, go to see your score',
          title: Text('You\'re done!'),
          content: [
            Text('You have finished this quiz.'),
          ],
          onPressed: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => ScoreWithCategoriesPage(
                totalScore: totalScore,
                musicScore: musicScore,
                filmScore: filmScore,
                mydata: mydata,
              ),
            ));
            _addToDb();
            scoreKeeper = [];
          },
          dialogButtonText: 'Go to result',
          borderRadius: BorderRadius.circular(8.0),
        );
      },
    );
  }

  void scoreKeeperFalseAnswer() {
    return scoreKeeper.add(Container(
      height: 10,
      color: colorFalseRed,
      width: MediaQuery.of(context).size.width / mydata.length,
    ));
  }

  void scoreKeeperCorrectAnswer() {
    return scoreKeeper.add(Container(
      height: 10,
      color: colorTrueGreen,
      width: MediaQuery.of(context).size.width / mydata.length,
    ));
  }

  void nextQuestion() {
    setState(() {
      if (questionNumber < mydata.length - 1) {
        questionNumber++;
        j++;
      } else {
        _showMyDialog();
      }
    });
  }

  void checkAnswer(String answer) {
    String userPickedAnswer = answer.toString();
    String correctAnswer = mydata[j]['correctAnswer'];
    List categoryAndScore = mydata[j]['score'];

    if (userPickedAnswer == correctAnswer) {
      if (categoryAndScore.toString().contains('film')) {
        int filmIndex = categoryAndScore
            .indexWhere((element) => element.toString().contains('film'));
        filmScore += categoryAndScore[filmIndex]['film'];
      }
      if (categoryAndScore.toString().contains('music')) {
        int musicIndex = categoryAndScore
            .indexWhere((element) => element.toString().contains('music'));
        musicScore += categoryAndScore[musicIndex]['music'];
      }

      scoreKeeperCorrectAnswer();
      opacityLevelCheckmark = opacityLevelCheckmark == 0 ? 1.0 : 0.0;
    } else {
      scoreKeeperFalseAnswer();
      opacityLevelX = opacityLevelX == 0 ? 1.0 : 0.0;
    }
    totalScore = musicScore + filmScore;
    nextQuestion();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
    return ReusableWillPopScope(
      titleText: 'Sorry',
      contentText: 'You can\'t go back at this stage.',
      child: Scaffold(
        appBar: AppBar(
          title: Text('Categories'),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Spacer(),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Center(
                    child: ReusableText(
                      text: mydata[j]['question'],
                      fontSize: 24.0,
                    ),
                  ),
                ),
              ),
              _answerButton('a'),
              _answerButton('b'),
              _answerButton('c'),
              _answerButton('d'),
              SizedBox(
                height: 50,
                child: Stack(
                  children: [
                    AnimatedOpacity(
                      opacity: opacityLevelCheckmark,
                      duration: Duration(milliseconds: 1000),
                      curve: Curves.easeInOutCubic,
                      onEnd: () {
                        setState(() {
                          opacityLevelCheckmark = 0;
                        });
                      },
                      child: Icon(
                        Icons.check,
                        color: colorTrueGreen,
                        size: 50,
                      ),
                    ),
                    AnimatedOpacity(
                      opacity: opacityLevelX,
                      duration: Duration(milliseconds: 1000),
                      curve: Curves.easeInOutCubic,
                      onEnd: () {
                        setState(() {
                          opacityLevelX = 0;
                        });
                      },
                      child: Icon(
                        Icons.close,
                        color: colorFalseRed,
                        size: 50,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: scoreKeeper,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _answerButton(String answer) {
    return Column(
      children: [
        ReusableElevatedButton(
          text: mydata[j]['answers'][answer],
          onPressed: () {
            checkAnswer(answer);
          },
        ),
      ],
    );
  }

  void _addToDb() async {
    int highscore = totalScore;

    String quizType = 'mc with cat';
    var id = await DatabaseHelper.instance
        .insert(Highscore(highscore: highscore, quizType: quizType));
    setState(() {
      highscoreList.insert(
          0, Highscore(id: id, highscore: highscore, quizType: quizType));
    });
  }
}

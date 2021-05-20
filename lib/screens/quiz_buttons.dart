import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:quiz_app/constants.dart';
import 'package:quiz_app/database/database_helpers.dart';
import 'package:quiz_app/reusable_alert.dart';
import 'package:quiz_app/reusable_elevated_button.dart';
import 'package:quiz_app/reusable_text.dart';
import 'package:quiz_app/reusable_will_pop_scope.dart';
import 'package:quiz_app/screens/score_page.dart';
import 'package:transparent_image/transparent_image.dart';

class QuizButtons extends StatelessWidget {
  static const routeName = '/quiz-buttons';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DefaultAssetBundle.of(context)
          .loadString('assets/questions.json', cache: false),
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
          return QuizButtonsPage(mydata: mydata);
        }
      },
    );
  }
}

class QuizButtonsPage extends StatefulWidget {
  final List mydata;

  QuizButtonsPage({Key key, @required this.mydata}) : super(key: key);
  @override
  _QuizButtonsPageState createState() => _QuizButtonsPageState(mydata);
}

class _QuizButtonsPageState extends State<QuizButtonsPage> {
  final List mydata;

  _QuizButtonsPageState(this.mydata);

  List<Highscore> highscoreList = List();
  List<Container> scoreKeeper = [];
  int score = 0;
  double opacityLevelCheckmark = 0;
  double opacityLevelX = 0;
  int i = 0;
  int j = 0;
  int questionNumber = 0;

  List<dynamic> randomizeArray() {
    var random = Random();

    // Go through all elements.
    for (var i = mydata.length - 1; i > 0; i--) {
      // Pick a pseudorandom number according to the list length
      var n = random.nextInt(i + 1);

      var temp = mydata[i];
      mydata[i] = mydata[n];
      mydata[n] = temp;
    }
    return mydata;
  }

  // overriding the initstate function to randomize
  @override
  void initState() {
    randomizeArray();
    super.initState();
  }

  // overriding the setstate function to be called only if mounted
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return ReusableAlert(
          semanticLabel: 'The quiz is finished, go to see your score',
          title: Text('You\'re done!'),
          content: [
            Text('You have finished this quiz.'),
          ],
          onPressed: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => ScorePage(score: score),
            ));
            _addToDb();
            //quizBrain.reset();
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

  void checkAnswer(bool userPickedAnswer) {
    bool correctAnswer = mydata[j]['answer'];

    if (userPickedAnswer == correctAnswer) {
      score++;
      scoreKeeperCorrectAnswer();
      opacityLevelCheckmark = opacityLevelCheckmark == 0 ? 1.0 : 0.0;
    } else {
      scoreKeeperFalseAnswer();
      opacityLevelX = opacityLevelX == 0 ? 1.0 : 0.0;
    }

    nextQuestion();
  }

  @override
  Widget build(BuildContext context) {
    //SystemChrome.setPreferredOrientations(
    //   [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
    return ReusableWillPopScope(
      titleText: 'Sorry',
      contentText: 'You can\'t go back at this stage.',
      child: Scaffold(
        appBar: AppBar(
          title: Text('Quizzy Christmas spirit'),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Spacer(),
              _hasImage(),
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
              _trueFalseButtons(),
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

  Widget _hasImage() {
    if (mydata[j].containsKey('image')) {
      return InteractiveViewer(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.3,
          padding: EdgeInsets.symmetric(vertical: 12.0),
          child: FadeInImage.memoryNetwork(
            placeholder: kTransparentImage,
            image: mydata[j]['image'],
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
            imageSemanticLabel: mydata[j]['semanticLabel'],
          ),
        ),
      );
    } else {
      return Container(
        height: MediaQuery.of(context).size.height * 0.3,
        width: 0,
      );
    }
  }

  Widget _trueFalseButtons() {
    Orientation orientation = MediaQuery.of(context).orientation;

    if (orientation == Orientation.portrait) {
      return Column(
        children: [
          _buttonTrue(),
          _buttonFalse(),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: _buttonTrue(),
          ),
          Expanded(
            child: _buttonFalse(),
          ),
        ],
      );
    }
  }

  Widget _buttonTrue() {
    return ReusableElevatedButton(
      backgroundColour: colorTrueGreen,
      text: 'True',
      textColor: colorWhite,
      onPressed: () {
        checkAnswer(true);
      },
    );
  }

  Widget _buttonFalse() {
    return ReusableElevatedButton(
      backgroundColour: colorFalseRed,
      text: 'False',
      textColor: colorWhite,
      onPressed: () {
        checkAnswer(false);
      },
    );
  }

  void _addToDb() async {
    int highscore = score;
    String quizType = 'buttons';
    var id = await DatabaseHelper.instance
        .insert(Highscore(highscore: highscore, quizType: quizType));
    setState(() {
      highscoreList.insert(
          0, Highscore(id: id, highscore: highscore, quizType: quizType));
    });
  }
}

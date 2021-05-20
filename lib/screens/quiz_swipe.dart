import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:quiz_app/constants.dart';
import 'package:quiz_app/database/database_helpers.dart';
import 'package:quiz_app/reusable_alert.dart';
import 'package:quiz_app/reusable_card.dart';
import 'package:quiz_app/reusable_text.dart';
import 'package:quiz_app/reusable_will_pop_scope.dart';
import 'package:quiz_app/screens/score_page.dart';
import 'package:transparent_image/transparent_image.dart';

class QuizSwipe extends StatelessWidget {
  static const routeName = '/quiz-swipe';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DefaultAssetBundle.of(context)
          .loadString('assets/questions_extended.json', cache: false),
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
          return QuizSwipePage(mydata: mydata);
        }
      },
    );
  }
}

class QuizSwipePage extends StatefulWidget {
  final List mydata;

  QuizSwipePage({Key key, @required this.mydata}) : super(key: key);
  @override
  _QuizSwipePageState createState() => _QuizSwipePageState(mydata);
}

class _QuizSwipePageState extends State<QuizSwipePage> {
  final List mydata;

  _QuizSwipePageState(this.mydata);

  List<Highscore> highscoreList = List();
  List<Container> scoreKeeper = [];
  int score = 0;
  int i = 0;
  int j = 0;
  int questionNumber = 0;
  double _progress = 0;
  int countdown = 5;
  int timeLeft;
  String showTimer = '5';
  bool cancelTimer = false;
  Timer _timer;

  List shuffledQuestions;

  List shuffleQuestions() {
    shuffledQuestions = List.from(mydata[1]['questions']);
    shuffledQuestions.shuffle();
    return shuffledQuestions;
  }

  // overriding the initstate function to shuffle
  @override
  void initState() {
    shuffleQuestions();

    //alert with instructions for quiz before it starts
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        await showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return ReusableAlert(
              title: Text('Instructions'),
              content: [
                Text(mydata[0]['quizInfo'][0]['instruction']),
              ],
              onPressed: () {
                Navigator.of(context).pop();
                startTimer();
              },
              dialogButtonText: 'I\'m ready!',
              borderRadius: BorderRadius.circular(8.0),
              titleColor: primaryBackgroundColorLight,
              dialogButtonColor: primaryBackgroundColorLight,
            );
          },
        );
      },
    );

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
            scoreKeeper = [];
          },
          dialogButtonText: 'Go to result',
          borderRadius: BorderRadius.circular(8.0),
        );
      },
    );
  }

  void startTimer() async {
    const oneSec = Duration(seconds: 1);
    if (_timer != null) {
      _timer.cancel();
      countdown = 5;
      _progress = 0;
    }
    _timer = Timer.periodic(oneSec, (Timer t) {
      setState(() {
        if (countdown < 1) {
          t.cancel();
          countdown = 5;
          scoreKeeperProgress(color: colorFalseRed);

          if (questionNumber == shuffledQuestions.length - 1) {
            _showMyDialog();
            cancelTimer = true;
          } else {
            nextQuestion();
            startTimer();
          }
        } else if (cancelTimer == true) {
          t.cancel();
          countdown = 5;
          startTimer();
        } else {
          countdown = countdown - 1;
          _progress += 0.2;
        }
        showTimer = countdown.toInt().toString();
      });
    });
  }

  void onDrag(drag) {
    List swipeDirection = mydata[0]['quizInfo'][0]['swipeDirectionsAnswers'];
    int indexLeft =
        swipeDirection.indexWhere((k) => k.toString().contains('left'));
    int indexRight =
        swipeDirection.indexWhere((k) => k.toString().contains('right'));
    int indexDown =
        swipeDirection.indexWhere((k) => k.toString().contains('down'));

    setState(() {
      if (swipeDirection.toString().contains('left') &&
          drag.offset.dx < -MediaQuery.of(context).size.width * 0.2) {
        //left swipe
        checkAnswer(swipeDirection[indexLeft]['left']);
      } else if (swipeDirection.toString().contains('right') &&
          drag.offset.dx > MediaQuery.of(context).size.width * 0.2) {
        //right swipe
        checkAnswer(swipeDirection[indexRight]['right']);
      } else if (swipeDirection.toString().contains('down') &&
          drag.offset.dy > MediaQuery.of(context).size.height * 0.5) {
        //down swipe
        checkAnswer(swipeDirection[indexDown]['down']);
      }
    });
  }

  void scoreKeeperProgress({Color color}) {
    return scoreKeeper.add(Container(
      height: 10,
      color: color,
      width: MediaQuery.of(context).size.width / mydata[1]['questions'].length,
    ));
  }

  void nextQuestion() {
    setState(() {
      if (questionNumber < shuffledQuestions.length - 1) {
        questionNumber++;
        j++;
      } else {
        _showMyDialog();
        cancelTimer = true;
      }
    });
  }

  void checkAnswer(bool userPickedAnswer) {
    bool correctAnswer = shuffledQuestions[j]['answer'];

    if (userPickedAnswer == correctAnswer) {
      timeLeft = 0 + int.parse(showTimer);
      score += 5 + timeLeft;
      scoreKeeperProgress(color: colorTrueGreen);
    } else {
      scoreKeeperProgress(color: colorFalseRed);
    }

    nextQuestion();
    startTimer();
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
              //quiz instruction:
              Container(
                color: secondaryColorLight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.arrow_back,
                          color: colorBlack,
                          size: 30,
                        ),
                        Icon(
                          Icons.close,
                          color: colorFalseRed,
                          size: 30,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.arrow_downward,
                          color: colorBlack,
                          size: 30,
                        ),
                        Icon(
                          Icons.not_interested,
                          color: colorFalseRed,
                          size: 30,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.check,
                          color: colorTrueGreen,
                          size: 30,
                        ),
                        Icon(
                          Icons.arrow_forward,
                          color: colorBlack,
                          size: 30,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              //timer:
              Stack(
                alignment: Alignment.center,
                children: [
                  ReusableText(
                    text: showTimer,
                    fontSize: 25,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 80,
                      width: 80,
                      child: CircularProgressIndicator(
                        value: _progress,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(secondaryColorLight),
                        backgroundColor: primaryBackgroundColorLight,
                        strokeWidth: 5,
                      ),
                    ),
                  ),
                ],
              ),
              Spacer(),
              //question with optional image:
              Stack(
                children: [
                  RotationTransition(
                    turns: AlwaysStoppedAnimation(2 / 360),
                    child: ReusableCard(
                      color: secondaryColorLight,
                      text: 'you can do it',
                    ),
                  ),
                  Draggable(
                    //axis: Axis.horizontal,
                    onDragEnd: onDrag,
                    childWhenDragging: RotationTransition(
                      turns: AlwaysStoppedAnimation(-2 / 360),
                      child: buildDraggableChild(
                        text:
                            'next question will appear here until you\'re done',
                        color: secondaryColorLight,
                        showImage: false,
                      ),
                    ),
                    feedback: buildDraggableChild(
                      text: shuffledQuestions[j]['question'],
                      showImage: true,
                    ),
                    child: buildDraggableChild(
                      text: shuffledQuestions[j]['question'],
                      showImage: true,
                    ),
                  ),
                ],
              ),
              //scorekeeper/progressbar:
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

  Column buildDraggableChild({String text, Color color, bool showImage}) {
    return Column(
      children: [
        ReusableCard(
          text: text,
        ),
        _hasImage(showImage: showImage),
      ],
    );
  }

  Widget _hasImage({bool showImage}) {
    if (showImage == true && shuffledQuestions[j].containsKey('image')) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.2,
        width: MediaQuery.of(context).size.width * 0.8,
        padding: EdgeInsets.symmetric(vertical: 12.0),
        child: FadeInImage.memoryNetwork(
          placeholder: kTransparentImage,
          image: shuffledQuestions[j]['image'],
          fit: BoxFit.cover,
          imageSemanticLabel: shuffledQuestions[j]['semanticLabel'],
        ),
      );
    } else {
      return Container(
        height: MediaQuery.of(context).size.height * 0.2,
        width: 0,
      );
    }
  }

  void _addToDb() async {
    int highscore = score;
    String quizType = 'swipey timey';
    var id = await DatabaseHelper.instance
        .insert(Highscore(highscore: highscore, quizType: quizType));
    setState(() {
      highscoreList.insert(
          0, Highscore(id: id, highscore: highscore, quizType: quizType));
    });
  }
}

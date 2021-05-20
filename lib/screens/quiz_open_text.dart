import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quiz_app/constants.dart';
import 'package:quiz_app/database/database_helpers.dart';
import 'package:quiz_app/reusable_alert.dart';
import 'package:quiz_app/reusable_elevated_button.dart';
import 'package:quiz_app/reusable_text.dart';
import 'package:quiz_app/reusable_will_pop_scope.dart';
import 'package:quiz_app/screens/score_page.dart';
import 'package:transparent_image/transparent_image.dart';

class QuizOpenText extends StatelessWidget {
  static const routeName = '/quiz-open-text';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DefaultAssetBundle.of(context)
          .loadString('assets/open_text_questions.json', cache: false),
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
          return QuizOpenTextPage(mydata: mydata);
        }
      },
    );
  }
}

class QuizOpenTextPage extends StatefulWidget {
  final List mydata;

  QuizOpenTextPage({Key key, @required this.mydata}) : super(key: key);
  @override
  _QuizOpenTextPageState createState() => _QuizOpenTextPageState(mydata);
}

class _QuizOpenTextPageState extends State<QuizOpenTextPage> {
  TextEditingController _controller = TextEditingController();

  final List mydata;

  _QuizOpenTextPageState(this.mydata);

  List<Highscore> highscoreList = List();
  List<Container> scoreKeeper = [];
  int score = 0;
  int j = 0;
  List dataList = [];
  final _formKey = GlobalKey<FormState>();

  List<dynamic> randomizeArray() {
    dataList = mydata[1]['pictures'];

    var random = Random();
    for (var i = dataList.length - 1; i > 0; i--) {
      var n = random.nextInt(i + 1);

      var temp = dataList[i];
      dataList[i] = dataList[n];
      dataList[n] = temp;
    }
    return dataList;
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

  void scoreKeeperFalseAnswer() {
    return scoreKeeper.add(Container(
      height: 10,
      color: colorFalseRed,
      width: MediaQuery.of(context).size.width / dataList.length,
    ));
  }

  void scoreKeeperCorrectAnswer() {
    return scoreKeeper.add(Container(
      height: 10,
      color: colorTrueGreen,
      width: MediaQuery.of(context).size.width / dataList.length,
    ));
  }

  void nextQuestion() {
    setState(() {
      if (j < dataList.length - 1) {
        j++;
      } else {
        _showMyDialog();
      }
    });
  }

  void checkAnswer() {
    String correctAnswerLong = dataList[j]['numberWritten'];
    String correctAnswerShort = dataList[j]['number'];

    //given answer trimmed whitespace & all to lowercase
    if (_controller.text.toLowerCase().trim() ==
            correctAnswerLong.toLowerCase() ||
        _controller.text.toLowerCase().trim() ==
            correctAnswerShort.toLowerCase()) {
      score++;
      scoreKeeperCorrectAnswer();
    } else {
      scoreKeeperFalseAnswer();
    }
    _controller.clear();
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
          title: Text(mydata[0]['quizInfo'][0]['appBarText']),
        ),
        body: SafeArea(
          child: ListView(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 48, horizontal: 12),
                child: Center(
                  child: ReusableText(
                    text: mydata[0]['quizInfo'][0]['question'],
                    fontSize: 24.0,
                  ),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  image: dataList[j]['image'],
                ),
              ),
              buildInputField(),
              ReusableElevatedButton(
                text: 'check & move on',
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    checkAnswer();
                  }
                },
              ),
              Row(
                children: scoreKeeper,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container buildInputField() {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Form(
          key: _formKey,
          child: TextFormField(
            textCapitalization: TextCapitalization.sentences,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              hintText: 'write the number here',
              errorStyle: TextStyle(color: colorWhite),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: primaryColorLight),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: primaryColorLight),
              ),
            ),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24),
            controller: _controller,
            keyboardType: TextInputType.text,
            validator: (value) {
              if (value.isEmpty) {
                return 'Please give an answer';
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  void _addToDb() async {
    int highscore = score;
    String quizType = 'open-text';
    var id = await DatabaseHelper.instance
        .insert(Highscore(highscore: highscore, quizType: quizType));
    setState(() {
      highscoreList.insert(
          0, Highscore(id: id, highscore: highscore, quizType: quizType));
    });
  }
}

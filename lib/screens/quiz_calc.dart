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

class QuizCalc extends StatelessWidget {
  static const routeName = '/quiz-calc';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DefaultAssetBundle.of(context)
          .loadString('assets/calculations.json', cache: false),
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
          return QuizCalcPage(mydata: mydata);
        }
      },
    );
  }
}

class QuizCalcPage extends StatefulWidget {
  final List mydata;

  QuizCalcPage({Key key, @required this.mydata}) : super(key: key);
  @override
  _QuizCalcPageState createState() => _QuizCalcPageState(mydata);
}

class _QuizCalcPageState extends State<QuizCalcPage> {
  TextEditingController _controller = TextEditingController();

  final List mydata;

  _QuizCalcPageState(this.mydata);

  List<Highscore> highscoreList = List();
  List<Container> scoreKeeper = [];
  int score = 0;
  int j = 0;
  List calculationList = [];
  final _formKey = GlobalKey<FormState>();

  List<dynamic> randomizeArray() {
    calculationList = mydata[1]['calculations'];

    var random = Random();
    for (var i = calculationList.length - 1; i > 0; i--) {
      var n = random.nextInt(i + 1);

      var temp = calculationList[i];
      calculationList[i] = calculationList[n];
      calculationList[n] = temp;
    }
    return calculationList;
  }

  @override
  void initState() {
    randomizeArray();
    _controller.text = "0";
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
      width: MediaQuery.of(context).size.width / calculationList.length,
    ));
  }

  void scoreKeeperCorrectAnswer() {
    return scoreKeeper.add(Container(
      height: 10,
      color: colorTrueGreen,
      width: MediaQuery.of(context).size.width / calculationList.length,
    ));
  }

  void nextQuestion() {
    setState(() {
      if (j < calculationList.length - 1) {
        j++;
      } else {
        _showMyDialog();
      }
    });
  }

  void checkAnswer() {
    int correctAnswer = calculationList[j]['answer'];

    if (int.tryParse(_controller.text) == correctAnswer) {
      score++;
      scoreKeeperCorrectAnswer();
    } else {
      scoreKeeperFalseAnswer();
    }
    _controller.text = "0";
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Center(
                  child: ReusableText(
                    text: mydata[0]['quizInfo'][0]['question'],
                    fontSize: 24.0,
                  ),
                ),
              ),
              Container(
                color: primaryColorLight,
                padding: EdgeInsets.all(12.0),
                child: Center(
                  child: ReusableText(
                    text: calculationList[j]['calculation'],
                    fontSize: 24.0,
                    textColor: colorBlack,
                  ),
                ),
              ),
              buildInputFieldWithIncrementDecrement(),
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

  Container buildInputFieldWithIncrementDecrement() {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.6,
            child: Form(
              key: _formKey,
              child: TextFormField(
                autocorrect: false,
                enableSuggestions: false,
                decoration: InputDecoration(
                  hintText: 'result',
                  errorStyle: TextStyle(color: colorWhite),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: primaryColorLight),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: primaryColorLight),
                  ),
                ),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, color: colorWhite),
                controller: _controller,
                keyboardType: TextInputType.numberWithOptions(
                  decimal: false,
                  signed: false,
                ),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                validator: (value) {
                  if (value.isEmpty || value == "0") {
                    return 'Please enter a number between 1 and 10';
                  } else if (int.tryParse(value) > 10) {
                    return 'max 10';
                  }
                  return null;
                },
                onTap: () => _controller.selection = TextSelection(
                  baseOffset: 0,
                  extentOffset: _controller.value.text.length,
                ),
                onChanged: (String value) async {
                  _formKey.currentState.validate();
                },
              ),
            ),
          ),
          Container(
            height: 100,
            padding: EdgeInsets.only(left: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: InkWell(
                    child: Icon(
                      Icons.arrow_drop_up,
                      size: 48,
                    ),
                    onTap: () {
                      int currentValue = int.tryParse(_controller.text);
                      setState(() {
                        currentValue++;
                        _controller.text =
                            (currentValue).toString(); // incrementing value
                      });
                      _formKey.currentState.validate();
                    },
                  ),
                ),
                InkWell(
                  child: Icon(
                    Icons.arrow_drop_down,
                    size: 48,
                  ),
                  onTap: () {
                    int currentValue = int.tryParse(_controller.text);
                    setState(() {
                      currentValue--;
                      _controller.text = (currentValue > 0 ? currentValue : 0)
                          .toString(); // decrementing value
                    });
                    _formKey.currentState.validate();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addToDb() async {
    int highscore = score;
    String quizType = 'calculation';
    var id = await DatabaseHelper.instance
        .insert(Highscore(highscore: highscore, quizType: quizType));
    setState(() {
      highscoreList.insert(
          0, Highscore(id: id, highscore: highscore, quizType: quizType));
    });
  }
}

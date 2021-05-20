import 'dart:convert';
import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:quiz_app/constants.dart';
import 'package:quiz_app/reusable_alert.dart';
import 'package:quiz_app/reusable_text.dart';
import 'package:quiz_app/screens/home_page.dart';

class QuizDragRainbow extends StatelessWidget {
  static const routeName = '/quiz-drag-rainbow';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ReusableText(
          text: 'Rainbow Drag & Drop',
        ),
      ),
      body: Center(
        // Use future builder and DefaultAssetBundle to load the local JSON file
        child: FutureBuilder(
          future: DefaultAssetBundle.of(context)
              .loadString('assets/drag_rainbow_colors.json', cache: false),
          builder: (context, snapshot) {
            List rainbowColors = json.decode(snapshot.data.toString());

            if (rainbowColors == null) {
              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else {
              return QuizDragRainbowPage(rainbowColors: rainbowColors);
            }
          },
        ),
      ),
    );
  }
}

class QuizDragRainbowPage extends StatefulWidget {
  final List rainbowColors;

  QuizDragRainbowPage({Key key, @required this.rainbowColors})
      : super(key: key);

  @override
  _QuizDragRainbowPageState createState() =>
      _QuizDragRainbowPageState(rainbowColors);
}

class _QuizDragRainbowPageState extends State<QuizDragRainbowPage> {
  final List rainbowColors;

  _QuizDragRainbowPageState(this.rainbowColors);

  int score = 0;
  List shuffledColors;
  List<Widget> _colors;
  int tableRows = 6;
  int tableCols = 1;
  int j = 0;
  String key;
  int index;
  bool accepting = false;
  bool successfulDrop = false;
  var tmpColor;

  List shuffleElements() {
    var random = Random();

    shuffledColors = List.from(rainbowColors);
    for (var i = shuffledColors.length - 1; i > 0; i--) {
      var n = random.nextInt(i + 1);

      var temp = shuffledColors[i];
      shuffledColors[i] = shuffledColors[n];
      shuffledColors[n] = temp;
    }
    return shuffledColors;
  }

  void nextElement() {
    setState(() {
      if (j < shuffledColors.length - 1) {
        j++;
      } else {
        _showMyDialog();
        print(score);
      }
    });
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ReusableAlert(
          semanticLabel: 'Taste the rainbow!',
          title: Text('Done!'),
          content: [
            Text('Awesome, you built a rainbow!'),
          ],
          onPressed: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => HomePage(),
            ));
          },
          dialogButtonText: 'go back home',
          borderRadius: BorderRadius.circular(8.0),
        );
      },
    );
  }

  List<Widget> getColors() {
    if (_colors != null) {
      return _colors;
    }

    _colors = [];
    for (var j = 0; j < tableCols; j++) {
      for (var i = 0; i < tableRows; i++) {
        key = '${j + 1}x${i + 1}';
        index = rainbowColors.indexWhere((e) => e.containsValue(key));

        if (index != -1) {
          tmpColor = rainbowColors[index];
          _colors.add(elementDragTarget(tmpColor));
        } else {
          _colors.add(Blank());
        }
      }
    }

    return _colors;
  }

  @override
  void initState() {
    shuffleElements();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                color: primaryColorLight,
                height: MediaQuery.of(context).size.height * 0.7,
                padding: EdgeInsets.all(8),
                child: GridView.count(
                  childAspectRatio: 0.7,
                  crossAxisCount: tableRows,
                  scrollDirection: Axis.horizontal,
                  children: getColors(),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: ReusableText(
                        text: "Drag the element to the correct position:"),
                  ),
                  Draggable(
                    data: shuffledColors[j],
                    child: DraggableElementTile(
                        shuffledColors: shuffledColors, j: j),
                    childWhenDragging: Container(
                      color: primaryColorLight,
                      padding: EdgeInsets.all(12),
                      margin: EdgeInsets.all(8),
                      height: elementHeight,
                      width: elementWidth,
                    ),
                    feedback: DraggableElementTile(
                        shuffledColors: shuffledColors, j: j),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              child: ReusableText(
                text: score.toString(),
                fontWeight: FontWeight.bold,
              ),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryBackgroundColorLight,
              ),
              padding: EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget elementDragTarget(tmpColor) {
    return DragTarget(
      onWillAccept: (value) {
        if (tmpColor['successfulDrop'] == true) {
          tmpColor['accepting'] = false;
        } else {
          setState(() {
            tmpColor['accepting'] = true;
          });
        }
        return true;
      },
      onAccept: (value) {
        if (shuffledColors[j]["color"] == tmpColor['color']) {
          setState(() {
            tmpColor['successfulDrop'] = true;
            score += 10;
            nextElement();
            tmpColor['accepting'] = false;
          });
        } else {
          tmpColor['accepting'] = false;
          score -= 5;
        }
        return true;
      },
      onLeave: (value) {
        setState(() {
          tmpColor['accepting'] = false;
        });
        return false;
      },
      builder: (context, acceptedData, rejectedData) {
        return buildElementTileInGrid(tmpColor);
      },
    );
  }

  //revealed in grid
  Widget buildElementTileInGrid(tmpColor) {
    accepting = tmpColor['accepting'];
    successfulDrop = tmpColor['successfulDrop'];

    return Container(
      padding: EdgeInsets.all(4),
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(
          width: 4,
          color: accepting == true
              ? primaryBackgroundColorLight
              : Colors.transparent,
        ),
        color: successfulDrop == true
            ? primaryBackgroundColorLight
            : secondaryColorLight,
      ),
      child: successfulDrop == true
          ? Center(
              child: ReusableText(
                text: tmpColor['color'],
              ),
            )
          : Container(),
    );
  }
}

//draggable
class DraggableElementTile extends StatelessWidget {
  const DraggableElementTile({
    Key key,
    @required this.shuffledColors,
    @required this.j,
  }) : super(key: key);

  final List shuffledColors;
  final int j;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorBlack,
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.all(8),
      height: elementHeight,
      width: elementWidth,
      child: Center(
        child: ReusableText(
          text: shuffledColors[j]['color'],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class Blank extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.all(8),
      height: elementHeight,
      width: elementWidth,
    );
  }
}

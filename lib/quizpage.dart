import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quizstar/resultpage.dart';

import 'package:flutter/services.dart' show rootBundle;

// Renamed class to follow Dart naming conventions
// ignore: must_be_immutable
class GetJson extends StatelessWidget {
  final String langname;
  GetJson({this.langname = ""});

  late String assetToLoad;

  // Corrected method name to follow Dart conventions
  void setAsset() {
    switch (langname) {
      case "Python":
        assetToLoad = "python.json";
        break;
      case "Java":
        assetToLoad = "java.json";
        break;
      case "Javascript":
        assetToLoad = "js.json";
        break;
      case "C++":
        assetToLoad = "cpp.json";
        break;
      default:
        assetToLoad = "linux.json";
    }
  }

  @override
  Widget build(BuildContext context) {
    setAsset(); // Call setAsset before building the widget

    return FutureBuilder<String>(
      future:
          // DefaultAssetBundle.of(context).loadString(assetToLoad, cache: false),
          rootBundle.loadString(assetToLoad, cache: false),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<dynamic> mydata = json.decode(snapshot.data.toString());

          print(mydata);

          return QuizPage(mydata: mydata);
        } else if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text("Error loading data")));
        }
        return Scaffold(body: Center(child: Text("Loading...")));
      },
    );
  }
}

// Renamed class to follow Dart naming conventions
class QuizPage extends StatefulWidget {
  final List<dynamic> mydata;
  QuizPage({required this.mydata});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  Color colorToShow = Colors.indigoAccent;
  Color right = Colors.green;
  Color wrong = Colors.red;
  int marks = 0, i = 1, timer = 30;
  bool disableAnswer = false;
  late List<int> randomArray;
  Map<String, Color> btnColor = {
    "a": Colors.indigoAccent,
    "b": Colors.indigoAccent,
    "c": Colors.indigoAccent,
    "d": Colors.indigoAccent,
  };
  bool cancelTimer = false;

  String showtimer = "30";

  @override
  void initState() {
    super.initState();
    startTimer();
    genRandomArray();
  }

  void genRandomArray() {
    randomArray = List.generate(10, (index) => index)..shuffle();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    Timer.periodic(oneSec, (Timer t) {
      if (mounted) {
        setState(() {
          if (timer < 1) {
            t.cancel();
            nextQuestion();
          } else if (cancelTimer) {
            t.cancel();
          } else {
            timer--;
          }
        });
      }
    });
  }

  void nextQuestion() {
    cancelTimer = false;
    timer = 30;
    setState(() {
      if (i < randomArray.length) {
        i = randomArray[i];
        i++;
      } else {
        // Navigate to result page
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => ResultPage(marks: marks),
        ));
      }
      btnColor = {
        "a": Colors.indigoAccent,
        "b": Colors.indigoAccent,
        "c": Colors.indigoAccent,
        "d": Colors.indigoAccent
      };
      disableAnswer = false;
    });
    startTimer();
  }

  void checkAnswer(String k) {
    if (widget.mydata[2][i.toString()] == widget.mydata[1][i.toString()][k]) {
      marks += 5;
      colorToShow = right;
    } else {
      colorToShow = wrong;
    }
    setState(() {
      btnColor[k] = colorToShow;
      cancelTimer = true;
      disableAnswer = true;
    });
    Timer(Duration(seconds: 2), nextQuestion);
  }

  Widget choiceButton(String k) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: MaterialButton(
        onPressed: () => checkAnswer(k),
        child: Text(
          widget.mydata[1][i.toString()][k],
          style: TextStyle(color: Colors.white, fontSize: 16.0),
        ),
        color: btnColor[k]!,
        splashColor: Colors.indigo[700],
        highlightColor: Colors.indigo[700],
        minWidth: 200.0,
        height: 45.0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    return WillPopScope(
      onWillPop: () async {
        final result = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Quizstar"),
            content: Text("You Can't Go Back At This Stage."),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .pop(true); // Return true when popping the dialog
                },
                child: Text('Ok'),
              ),
            ],
          ),
        );

        return result ?? false; // Return false if dialog is dismissed
      },
      child: Scaffold(
        body: Column(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Container(
                padding: EdgeInsets.all(15.0),
                alignment: Alignment.bottomLeft,
                child: Text(
                  widget.mydata[0][i.toString()],
                  style: TextStyle(
                    fontSize: 16.0,
                    fontFamily: "Quando",
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: AbsorbPointer(
                absorbing: disableAnswer,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      choiceButton('a'),
                      choiceButton('b'),
                      choiceButton('c'),
                      choiceButton('d'),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.topCenter,
                child: Center(
                  child: Text(
                    showtimer,
                    style: TextStyle(
                      fontSize: 35.0,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Times New Roman',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

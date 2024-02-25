import 'package:flutter/material.dart';
import 'package:quizstar/splash.dart';

// import 'package:flutter_web_plugins/url_strategy.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // usePathUrlStrategy();

  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Quizstar",
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: splashscreen(),
    );
  }
}

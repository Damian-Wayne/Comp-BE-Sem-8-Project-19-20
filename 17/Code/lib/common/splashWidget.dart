import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';

Widget splash(Widget widget) {
  final Shader linearGradient = LinearGradient(
    colors: <Color>[Color(0xffDA44bb), Color(0xff8921aa)],
  ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));
  return SplashScreen(
    seconds: 3,
    navigateAfterSeconds: widget,
    image: Image.asset(
      'assets/splashNew.png',
      alignment: Alignment.topLeft,
    ),
    photoSize: 200,
    gradientBackground: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xff0E1626), Color(0xff023E58)],
      stops: [0.2, 5],
    ),
    title: Text(
      'Pothole Scout',
      style: TextStyle(
        fontSize: 50,
        fontWeight: FontWeight.bold,
        foreground: Paint()..shader = linearGradient
      ),
    ),
    loadingText: Text("Loading...."),
  );
}

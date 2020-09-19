import 'package:flutter/material.dart';
import 'package:pothole_scout/common/providerWidget.dart';
import 'package:pothole_scout/services/authService.dart';
import 'package:pothole_scout/views/First/firstScreen.dart';
import 'package:pothole_scout/views/Home/homeScreen.dart';

class HomeController extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthService auth = Provider.of(context).auth;
    return StreamBuilder(
      stream: auth.onAuthStateChanged,
      builder: (context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final bool signedIn = snapshot.hasData;
          return signedIn ? new HomeScreen() : FirstScreen();
        }
        return CircularProgressIndicator();
      },
    );
  }
}
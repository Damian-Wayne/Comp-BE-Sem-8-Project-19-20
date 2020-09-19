import 'package:flutter/material.dart';

import 'package:pothole_scout/routes/routeGenerator.dart';

import 'package:pothole_scout/services/authService.dart';
import 'package:pothole_scout/views/Anonymous/anonymousScreen.dart';
import 'package:pothole_scout/views/Authentication/citizenAuthScreen.dart';
import 'package:pothole_scout/views/Authentication/municipalAuthScreen.dart';
import 'package:pothole_scout/views/First/firstScreen.dart';
import 'package:pothole_scout/views/Home/homeScreen.dart';
import 'package:pothole_scout/common/providerWidget.dart';
import 'package:pothole_scout/common/splashWidget.dart';
import 'package:pothole_scout/views/Map/mapScreen.dart';
import 'package:pothole_scout/views/Buffer/bufferScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Provider(
      auth: AuthService(),
      child: MaterialApp(
        title: 'Auth',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: splash(HomeController()),
        // onGenerateRoute: RouteGenerator.generateRoute,
        routes: <String, WidgetBuilder>{
          // '/signup': (BuildContext context) =>
          //     MunicipalSignup(authFormType: AuthFormType.signup),
          '/homeScreen': (BuildContext context) => HomeController(),
          '/municipalAuthScreen': (BuildContext context) =>
              MunicipalSignup(authFormType: AuthFormType.signin),
          '/citizenAuthScreen': (BuildContext context) =>
              CitizenSignup(authFormType: CitizenAuthForm.signup),
          // '/anonymousAuthScreen': (BuildContext context) =>
          //     CitizenSignup(authFormType: CitizenAuthForm.anonymous),
          '/anonymousScreen': (BuildContext context) => AnonymousScreen(),
          '/convertUserScreen': (BuildContext context) =>
              CitizenSignup(authFormType: CitizenAuthForm.convert),
          '/mapScreen': (BuildContext context) => MapScreen(),
          '/bufferScreen': (BuildContext context) => BufferScreen(),
        },
      ),
    );
  }
}

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

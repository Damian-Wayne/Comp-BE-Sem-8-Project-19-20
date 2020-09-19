import 'package:flutter/material.dart';
import 'package:pothole_scout/common/homeController.dart';

import 'package:pothole_scout/views/Authentication/citizenAuthScreen.dart';
import 'package:pothole_scout/views/Authentication/municipalAuthScreen.dart';
import 'package:pothole_scout/views/Map/mapScreen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      
      case '/homeScreen':
        return MaterialPageRoute(
          builder: (_) => HomeController(),
        );

      case '/municipalAuthScreen':
        return MaterialPageRoute(
          builder: (_) => MunicipalSignup(authFormType: AuthFormType.signin),
        );

      case '/citizenAuthScreen':
        return MaterialPageRoute(
          builder: (_) => CitizenSignup(authFormType: CitizenAuthForm.signup),
        );

      case '/anonymousAuthScreen':
        return MaterialPageRoute(
          builder: (_) =>
              CitizenSignup(authFormType: CitizenAuthForm.anonymous),
        );

      case '/convertUserScreen':
        return MaterialPageRoute(
          builder: (_) => CitizenSignup(authFormType: CitizenAuthForm.convert),
        );

      case '/mapScreen':
        return MaterialPageRoute(
          builder: (_) => MapScreen(),
        );

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Error'),
          ),
          body: Center(
            child: Text('ERROR'),
          ),
        );
      },
    );
  }
}

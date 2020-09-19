import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';

import '../../services/validatorService.dart';
import '../../common/providerWidget.dart';

final primaryColor = const Color(0xFF75A2EA);

enum CitizenAuthForm { signin, signup, reset, anonymous, convert }

class CitizenSignup extends StatefulWidget {
  final CitizenAuthForm authFormType;

  CitizenSignup({Key key, @required this.authFormType}) : super(key: key);

  @override
  _CitizenSignupState createState() =>
      _CitizenSignupState(authFormType: this.authFormType);
}

class _CitizenSignupState extends State<CitizenSignup> {
  CitizenAuthForm authFormType;
  _CitizenSignupState({this.authFormType});
  final formKey = GlobalKey<FormState>();
  String _email;
  String _password;
  String _name;
  String _error;
  String role = "Citizen";

  void switchFormState(String state) {
    formKey.currentState.reset();
    if (state == "signup") {
      setState(() {
        authFormType = CitizenAuthForm.signup;
      });
    } else if (state == 'home') {
      Navigator.of(context).pop();
    } else {
      setState(() {
        authFormType = CitizenAuthForm.signin;
      });
    }
  }

  bool validate() {
    final form = formKey.currentState;
    if (authFormType == CitizenAuthForm.anonymous) {
      return true;
    }
    form.save();
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  void submit() async {
    if (validate()) {
      try {
        final auth = Provider.of(context).auth;
        switch (authFormType) {
          case CitizenAuthForm.signin:
            String uid =
                await auth.signInWithEmailAndPassword(_email, _password);
            print("Signed in with ID $uid");
            break;
          case CitizenAuthForm.signup:
            String uid = await auth.createUserWithEmailAndPassword(
                _email, _password, _name, role);
            print("Signed up with new ID $uid");
            break;
          case CitizenAuthForm.reset:
            await auth.sendPasswordResetEmail(_email);
            setState(() {
              authFormType = CitizenAuthForm.signin;
            });
            break;
          case CitizenAuthForm.anonymous:
            await auth.signInAnonymously();
            Navigator.of(context).pushReplacementNamed("/anonymousScreen");
            break;
          case CitizenAuthForm.convert:
            await auth.convertUserWithEmail(_email, _password, _name);
            Navigator.of(context).pop();
            break;
        }
        Navigator.of(context).pushReplacementNamed("/bufferScreen");
      } catch (e) {
        setState(() {
          _error = e.message;
        });
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    if (authFormType == CitizenAuthForm.anonymous) {
      submit();
      return Scaffold(
        backgroundColor: primaryColor,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SpinKitDoubleBounce(
              color: Colors.white,
            ),
            Text(
              "Loading",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        body: Container(
          color: primaryColor,
          height: _height,
          width: _width,
          child: SafeArea(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: _height * .025,
                ),
                showAlert(),
                SizedBox(
                  height: _height * .025,
                ),
                buildHeaderText(),
                SizedBox(
                  height: _height * .05,
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: buildInputs() + buildButtons(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget showAlert() {
    if (_error != null) {
      return Container(
        color: Colors.amberAccent,
        width: double.infinity,
        padding: EdgeInsets.all(8),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(Icons.error_outline),
            ),
            Expanded(
              child: AutoSizeText(
                _error,
                maxLines: 3,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _error = null;
                  });
                },
              ),
            ),
          ],
        ),
      );
    }
    return SizedBox(height: 0);
  }

  AutoSizeText buildHeaderText() {
    String _headerText;
    if (authFormType == CitizenAuthForm.signin) {
      _headerText = "Sign In";
    } else if (authFormType == CitizenAuthForm.reset) {
      _headerText = "Reset Password";
    } else {
      _headerText = "Create New Account";
    }

    return AutoSizeText(
      _headerText,
      maxLines: 1,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 35,
        color: Colors.white,
      ),
    );
  }

  InputDecoration buildSignUpInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      focusColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.white,
          width: 0.0,
        ),
      ),
      contentPadding: EdgeInsets.only(left: 14, bottom: 10, top: 10),
    );
  }

  List<Widget> buildInputs() {
    List<Widget> textFields = [];

    if (authFormType == CitizenAuthForm.reset) {
      textFields.add(
        TextFormField(
          validator: EmailValidator.validate,
          style: TextStyle(fontSize: 22),
          decoration: buildSignUpInputDecoration("Email"),
          onSaved: (value) {
            _email = value;
          },
        ),
      );

      textFields.add(SizedBox(height: 20));
      return textFields;
    }

    if ([CitizenAuthForm.signup, CitizenAuthForm.convert]
        .contains(authFormType)) {
      textFields.add(
        TextFormField(
          validator: NameValidator.validate,
          style: TextStyle(fontSize: 22),
          decoration: buildSignUpInputDecoration("Name"),
          onSaved: (value) {
            _name = value;
          },
        ),
      );

      textFields.add(SizedBox(height: 20));
    }
    textFields.add(
      TextFormField(
        validator: EmailValidator.validate,
        style: TextStyle(fontSize: 22),
        decoration: buildSignUpInputDecoration("Email"),
        onSaved: (value) {
          _email = value;
        },
      ),
    );

    textFields.add(SizedBox(height: 20));

    textFields.add(
      TextFormField(
        validator: PasswordValidator.validate,
        style: TextStyle(fontSize: 22),
        decoration: buildSignUpInputDecoration("Password"),
        obscureText: true,
        onSaved: (value) {
          _password = value;
        },
      ),
    );

    textFields.add(SizedBox(height: MediaQuery.of(context).size.height * 0.05));

    return textFields;
  }

  List<Widget> buildButtons() {
    String _switchButtonText;
    String _newFormState;
    String _submitButtonText;
    bool _showForgotPassword = false;
    bool _showSocial = true;

    if (authFormType == CitizenAuthForm.signin) {
      _switchButtonText = "Create Account";
      _newFormState = "signup";
      _submitButtonText = "Sign In";
      _showForgotPassword = true;
    } else if (authFormType == CitizenAuthForm.reset) {
      _switchButtonText = "Return to Sign In";
      _newFormState = "signin";
      _submitButtonText = "Submit";
      _showSocial = false;
    } else if (authFormType == CitizenAuthForm.convert) {
      _switchButtonText = "Cancel";
      _newFormState = "home";
      _submitButtonText = "Sign Up";
    } else {
      _switchButtonText = "Have an Account? Sign In";
      _newFormState = "signin";
      _submitButtonText = "Sign Up";
    }

    return [
      Container(
        width: MediaQuery.of(context).size.width * 0.70,
        child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _submitButtonText,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          onPressed: submit,
        ),
      ),
      showForgotPassword(_showForgotPassword),
      FlatButton(
        child: Text(
          _switchButtonText,
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          switchFormState(_newFormState);
        },
      ),
      buildSocialIncons(_showSocial),
    ];
  }

  Widget showForgotPassword(bool visible) {
    return Visibility(
      child: FlatButton(
        child: Text(
          "Forgot Password??",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        onPressed: () {
          setState(() {
            authFormType = CitizenAuthForm.reset;
          });
        },
      ),
      visible: visible,
    );
  }

  Widget buildSocialIncons(bool visible) {
    final _auth = Provider.of(context).auth;
    return Visibility(
      child: Column(
        children: <Widget>[
          Divider(
            color: Colors.white,
          ),
          SizedBox(
            height: 5,
          ),
          GoogleSignInButton(
            onPressed: () async {
              try {
                if (authFormType == CitizenAuthForm.convert) {
                  await _auth.convertWithGoogle();
                  Navigator.of(context).pop();
                } else {
                  await _auth.signInWithGoogle();
                  Navigator.of(context).pushReplacementNamed('/bufferScreen');
                }
              } catch (e) {
                setState(() {
                  _error = e.message;
                });
              }
            },
          ),
        ],
      ),
      visible: visible,
    );
  }
}

import 'package:NewsBuzz/app_localizations.dart';
import 'package:NewsBuzz/services/api_manager.dart';
import 'package:NewsBuzz/utility/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:NewsBuzz/services/base_auth.dart';
import 'package:provider/provider.dart';

class LoginSignUpPage extends StatefulWidget {
  LoginSignUpPage({this.onSignedIn});
  final VoidCallback onSignedIn;

  @override
  State<StatefulWidget> createState() => new _LoginSignUpPageState();
}

enum FormMode { LOGIN, SIGNUP }

class _LoginSignUpPageState extends State<LoginSignUpPage> {
  final _formKey = new GlobalKey<FormState>();

  String _email;
  String _password;
  String _confirmPass;
  String _userName;
  String _errorMessage;

  // Initial form is login form
  FormMode _formMode = FormMode.LOGIN;
  bool _isLoading;

  // Check if form is valid before perform login or signup
  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  bool rightToLeft() {
    final APIManager apiManager = Provider.of<APIManager>(context);
    return apiManager.languageDirection == 'right';
  }

  // Perform login or signup
  void _validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });
    if (_validateAndSave()) {
      String returnMsg = "";
      try {
        if (_formMode == FormMode.LOGIN) {
          try {
            returnMsg =
                await Provider.of<MyAuth>(context).signIn(_email, _password);
          } catch (e) {
//            _showAlert(e);
            setState(() {
              _errorMessage = e;
              _isLoading = false;
            });
          }
        } else {
          if (_confirmPass != _password) {
            _errorMessage =
                AppLocalizations.of(context).translate('passwords dont match');
          } else {
            try {
              returnMsg = await Provider.of<MyAuth>(context)
                  .signUp(_email, _password, _userName);
            } catch (e) {
//              _showAlert(e);
              setState(() {
                _errorMessage = e;
                _isLoading = false;
              });
            }
          }
        }
        setState(() {
          _isLoading = false;
        });

        if (returnMsg.isNotEmpty && _errorMessage.isEmpty) {
          Navigator.pop(context);
          widget.onSignedIn();
        }
      } catch (e) {
        print('Error: $e');
        setState(() {
          _isLoading = false;
          _errorMessage = e;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    super.initState();
  }

//  Future<void> _showAlert(String title) async {
//    return showDialog<void>(
//      context: context,
//      barrierDismissible: false, // user must tap button!
//      builder: (BuildContext context) {
//        return AlertDialog(
//          title: Text(title),
//          actions: <Widget>[
//            FlatButton(
//              child: Text('Ok'),
//              onPressed: () {
//                Navigator.pop(context);
//              },
//            ),
//          ],
//        );
//      },
//    );
//  }

  void _changeFormToSignUp() {
    _formKey.currentState.reset();
    _errorMessage = "";
    setState(() {
      _formMode = FormMode.SIGNUP;
    });
  }

  void _changeFormToLogin() {
    _formKey.currentState.reset();
    _errorMessage = "";
    setState(() {
      _formMode = FormMode.LOGIN;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: kAppBarPrimaryColor,
        ),
        body: Stack(
          children: <Widget>[
            _showBody(),
            _showCircularProgress(),
          ],
        ));
  }

  Widget _showCircularProgress() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

//  void _showVerifyEmailSentDialog() {
//    showDialog(
//      context: context,
//      builder: (BuildContext context) {
//        // return object of type Dialog
//        return AlertDialog(
//          title: new Text("Verify your account"),
//          content: new Text("Link to verify account has been sent to your email"),
//          actions: <Widget>[
//            new FlatButton(
//              child: new Text("Dismiss"),
//              onPressed: () {
//                _changeFormToLogin();
//                Navigator.of(context).pop();
//              },
//            ),
//          ],
//        );
//      },
//    );
//  }

  Widget _showBody() {
    return new Container(
        padding: EdgeInsets.all(16.0),
        child: new Form(
          key: _formKey,
          child: new ListView(
            shrinkWrap: true,
            children: <Widget>[
              _showLogo(),
              if (_formMode == FormMode.SIGNUP) ...[
                _showUsernameInput(),
              ],
              _showEmailInput(),
              _showPasswordInput(0),
              if (_formMode == FormMode.SIGNUP) ...[
                _showPasswordInput(1),
              ],
              _showPrimaryButton(),
              SizedBox(height: 20),
              _showSecondaryButton(),
              _showErrorMessage(),
            ],
          ),
        ));
  }

  Widget _showErrorMessage() {
    if (_errorMessage != null && _errorMessage.isNotEmpty) {
      return new Text(
        _errorMessage,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 15.0,
            color: Colors.red,
            height: 1.0,
            fontWeight: FontWeight.w300),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

  Widget _showLogo() {
    return new Hero(
      tag: 'LoginLogo',
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 70.0, 0.0, 0.0),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 48.0,
          child: Image.asset('images/fyipress.png'),
        ),
      ),
    );
  }

  Widget _showEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        textAlign: rightToLeft() ? TextAlign.right : TextAlign.left,
        decoration: new InputDecoration(
          hintText: AppLocalizations.of(context).translate('email'),
          prefixIcon: rightToLeft()
              ? null
              : Icon(
                  Icons.mail,
                  color: Colors.grey,
                ),
          suffixIcon: rightToLeft()
              ? Icon(
                  Icons.mail,
                  color: Colors.grey,
                )
              : null,
        ),
        validator: (value) => value.isEmpty
            ? AppLocalizations.of(context).translate('email not empty')
            : null,
        onSaved: (value) => _email = value.trim(),
      ),
    );
  }

  Widget _showPasswordInput(num) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        textAlign: rightToLeft() ? TextAlign.right : TextAlign.left,
        obscureText: true,
        autofocus: false,
        decoration: new InputDecoration(
          hintText: num == 0
              ? AppLocalizations.of(context).translate('password')
              : AppLocalizations.of(context).translate('confirm password'),
          prefixIcon: rightToLeft()
              ? null
              : Icon(
                  Icons.lock,
                  color: Colors.grey,
                ),
          suffixIcon: rightToLeft()
              ? Icon(
                  Icons.lock,
                  color: Colors.grey,
                )
              : null,
        ),
        validator: (value) {
          if (num == 1) {
            return value.isEmpty && _formMode == FormMode.SIGNUP
                ? AppLocalizations.of(context).translate('password not empty')
                : null;
          }
          return value.isEmpty
              ? AppLocalizations.of(context).translate('password not empty')
              : null;
        },
        onSaved: (value) {
          num == 0 ? _password = value.trim() : _confirmPass = value.trim();
        },
      ),
    );
  }

  Widget _showUsernameInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        textAlign: rightToLeft() ? TextAlign.right : TextAlign.left,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: new InputDecoration(
          hintText: AppLocalizations.of(context).translate('username'),
          prefixIcon: rightToLeft()
              ? null
              : Icon(
                  Icons.person,
                  color: Colors.grey,
                ),
          suffixIcon: rightToLeft()
              ? Icon(
                  Icons.person,
                  color: Colors.grey,
                )
              : null,
        ),
        validator: (value) => value.isEmpty && _formMode == FormMode.SIGNUP
            ? AppLocalizations.of(context).translate('username not empty')
            : null,
        onSaved: (value) => _userName = value.trim(),
      ),
    );
  }

  Widget _showSecondaryButton() {
    return new FlatButton(
      child: _formMode == FormMode.LOGIN
          ? new Text(AppLocalizations.of(context).translate('create account'),
              style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300))
          : new Text(AppLocalizations.of(context).translate('have an account'),
              style:
                  new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300)),
      onPressed: _formMode == FormMode.LOGIN
          ? _changeFormToSignUp
          : _changeFormToLogin,
    );
  }

  Widget _showPrimaryButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            color: Theme.of(context).iconTheme.color,
            splashColor: Colors.red,
            child: _formMode == FormMode.LOGIN
                ? new Text(AppLocalizations.of(context).translate('login'),
                    style: new TextStyle(fontSize: 20.0, color: Colors.white))
                : new Text(
                    AppLocalizations.of(context).translate('create account'),
                    style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: _validateAndSubmit,
          ),
        ));
  }
}

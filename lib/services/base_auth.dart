import 'package:NewsBuzz/models/user.dart';
import 'package:NewsBuzz/services/base_api.dart';
import 'package:flutter/cupertino.dart';
import 'my_encryptor.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyAuth extends ChangeNotifier with BaseApi {
  User user = User();
  String language = 'ar';

  MyAuth() {
    getLanguage();
  }

  getLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String lang = prefs.getString('language') ?? 'ar';
    language = lang;
  }

  Future<String> signIn(String email, String password) async {
    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();

    Map<String, String> params = {
      'email': email,
      'password': encrypt(password + timeStamp, timeStamp).body,
    };

    try {
      var json = await postRequest(
          action: 'login',
          params: params,
          timeStamp: timeStamp,
          lang: language);
      print(json);
      user.setData(
          json['name'], json['email'], password, json['profile_image']);
      await _setMyData();
      notifyListeners();
      return json['message'];
    } catch (e) {
      throw e;
    }
  }

  Future<String> signUp(String email, String password, String name) async {
    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();

    String encryptedPassword = encrypt(password + timeStamp, timeStamp).body;

    Map<String, String> params = {
      'email': email,
      'password': encryptedPassword,
      'confirm_password': encryptedPassword,
      'name': name,
    };
    try {
      var json = await postRequest(
          action: 'register',
          params: params,
          timeStamp: timeStamp,
          lang: language);
      user.setData(name, email, password, null);
      _setMyData();
      notifyListeners();
      return json['message'];
    } catch (e) {
      throw e;
    }
  }

  Future<String> resendEmail() async {
    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();

    Map<String, String> params = {
      'email': user.email,
    };

    try {
      var json = await postRequest(
          action: 'resend_verification_email',
          params: params,
          timeStamp: timeStamp,
          lang: language);
      return json['message'];
    } catch (e) {
      throw e;
    }
  }

  Future<String> changePassword(String oldPass, String newPass) async {
    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();

    String encryptedOldPassword = encrypt(oldPass, timeStamp).body;
    String encryptedNewPassword = encrypt(newPass, timeStamp).body;

    Map<String, String> params = {
      'email': user.email,
      'password': encryptedOldPassword,
      'new_password': encryptedNewPassword,
      'confirm_password': encryptedNewPassword,
    };

    try {
      var json = await postRequest(
          action: 'change_password',
          params: params,
          timeStamp: timeStamp,
          lang: language);
      return json['message'];
    } catch (e) {
      throw e;
    }
  }

  Future<void> signOut() {
    user.signOut();
    _clearMyData();
    notifyListeners();
    return null;
  }

  _setMyData() async {
    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('email', user.email);
    prefs.setString('username', user.username);
    prefs.setString('image', user.imageUrl);
    prefs.setString('password', encrypt(user.password, timeStamp).body);
  }

  _clearMyData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('email', null);
    prefs.setString('username', null);
    prefs.setString('password', null);
    prefs.setString('image', null);
  }

  getMyData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var email = prefs.getString('email');
    var username = prefs.getString('username');
    var pass = prefs.getString('password');
    var imageUrl = prefs.getString('image');
    var decryptedPass = pass != null ? decrypt(pass) : null;
    user.setData(username, email, decryptedPass, imageUrl);
    print('GET MY DATA DONE $username, $email');
  }

  profilePicChanged() {
    notifyListeners();
  }
}

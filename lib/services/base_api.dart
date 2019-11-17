import 'dart:convert';
import 'package:NewsBuzz/models/user.dart';
import 'package:http/http.dart' as http;
import 'my_encryptor.dart';

mixin BaseApi {
  final _baseUrl = '2dobest.com';
  final _port = '/api/index.php';

  Future getRequest(
      {String action,
      Map params,
      String timeStamp,
      User user,
      String lang,
      bool emailIncluded = false}) async {
    EncryptionUnit enc = getEnc(timeStamp);

    Map<String, String> newParams = {
      'do': action,
      'enc': enc.body,
      'time': enc.timeStamp,
      'lang': lang == 'hi' ? 'in' : lang,
    };

    if (emailIncluded) {
      newParams['email'] = user.email;
      newParams['password'] =
          encrypt(user.password + timeStamp, timeStamp).body;
    }
    newParams.addAll(params);

    var response =
        await http.get(Uri.encodeFull(_baseUrl + _port), headers: newParams);

    var sourcesResponse = jsonDecode(response.body);
    if (sourcesResponse == null) {
      throw 'Get error: Response == null';
    } else if (sourcesResponse['error'] != '0' &&
        sourcesResponse['message'] != null) {
      throw sourcesResponse['message'];
    } else {
      return sourcesResponse;
    }
  }

  Future postRequest(
      {String action,
      Map params,
      String timeStamp,
      User user,
      String lang,
      bool emailIncluded = false}) async {
    EncryptionUnit enc = getEnc(timeStamp);

    Map<String, String> newParams = {
      'do': action,
      'enc': enc.body,
      'time': enc.timeStamp,
      'lang': lang == 'hi' ? 'in' : lang,
    };

    if (emailIncluded) {
      newParams['email'] = user.email ?? '';
      newParams['password'] = user.password == null
          ? ''
          : encrypt(user.password + timeStamp, timeStamp).body;
    }

    newParams.addAll(params);
    print(newParams);
    var response = await http
        .post(Uri.https(_baseUrl, _port), body: newParams)
        .catchError((e) => throw e);

    var sourcesResponse;
    try {
      sourcesResponse = jsonDecode(response.body);
    } catch (e) {
      print(e);
      throw e;
    }

    if (sourcesResponse == null) {
      throw 'post error: Response == null';
    } else if (sourcesResponse['error'] == 1 &&
        sourcesResponse['message'] != null) {
      print(sourcesResponse['message']);
      throw sourcesResponse['message'];
    } else {
      return sourcesResponse;
    }
  }
}

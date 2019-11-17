import 'dart:io';

import 'package:NewsBuzz/app_localizations.dart';
import 'package:NewsBuzz/models/article.dart';
import 'package:NewsBuzz/services/api_manager.dart';
import 'package:NewsBuzz/services/base_auth.dart';
import 'package:NewsBuzz/utility/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:html/parser.dart' show parse;

class AddReplyRightScreen extends StatefulWidget {
  @override
  _AddReplyRightScreenState createState() => _AddReplyRightScreenState();
}

class _AddReplyRightScreenState extends State<AddReplyRightScreen> {
  Article article;

  bool _loading = false;
  String _phone;
  String _message;
  String _title;
  String _reply;
  String userImage;
  String mainImage;

  String userImageText = 'insert your image';
  String replyMainImageText = 'insert main reply image';

  Future sendReply() async {
    setState(() {
      _loading = true;
    });
    if (_title != null &&
        _title.isNotEmpty &&
        _reply != null &&
        _reply.isNotEmpty) {
      try {
        String message = await Provider.of<APIManager>(context).addRightToReply(
            user: Provider.of<MyAuth>(context).user,
            newsId: article.id,
            reply: _reply,
            title: _title,
            rank: article.rank,
            userImage: userImage,
            replyImage: mainImage,
            phone: _phone ?? '',
            messageToAdmin: _message ?? '');

        setState(() {
          _loading = false;
        });
        showAlert(message, () {
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pop(context);
        });
      } catch (e) {
        showAlert(e, () => Navigator.pop(context));
      }
    } else {
      showAlert(
          AppLocalizations.of(context).translate('insert reply and title'),
          () => Navigator.pop(context));
    }
  }

  showAlert(String title, Function onOkPress) {
    setState(() {
      _loading = false;
    });
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text(title),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok', style: TextStyle(color: kIconPrimaryColor)),
                onPressed: onOkPress,
              )
            ],
          );
        });
  }

  String _articleTitle() {
    try {
      var document = parse(article.title);
      return document.body.text;
    } catch (e) {
      print(e);
      return article.title;
    }
  }

  bool rightToLeft() {
    final APIManager apiManager = Provider.of<APIManager>(context);
    return apiManager.languageDirection == 'right';
  }

  @override
  Widget build(BuildContext context) {
    article = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kAppBarPrimaryColor,
        title: Text(
          AppLocalizations.of(context).translate('reply right'),
          style: TextStyle(fontSize: 24),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.send,
              color: Colors.white,
            ),
            onPressed: () {
              sendReply();
            },
          )
        ],
      ),
      body: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                AutoSizeText(
                  _articleTitle(),
                  maxLines: 3,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 30),
                AutoSizeText(
                  AppLocalizations.of(context).translate('replyright message'),
                  maxLines: 6,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.red),
                ),
                SizedBox(height: 30),
                TextField(
                  maxLines: 1,
                  cursorColor: kIconPrimaryColor,
                  textDirection:
                      rightToLeft() ? TextDirection.rtl : TextDirection.ltr,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                  textAlign: rightToLeft() ? TextAlign.right : TextAlign.left,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)
                        .translate('phone optional'),
                    focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: kIconPrimaryColor, width: 1),
                    ),
                  ),
                  onChanged: (value) {
                    _phone = value;
                  },
                ),
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Flexible(
                      child: Container(
                        height: 50,
                        child: FlatButton(
                          child: Text(
                            AppLocalizations.of(context)
                                .translate(userImageText),
                            textAlign: TextAlign.center,
                          ),
                          color: kAppBarPrimaryColor,
                          onPressed: () {
                            _openImagePicker(PicType.user);
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Flexible(
                      child: Container(
                        height: 50,
                        child: FlatButton(
                          child: Text(
                            AppLocalizations.of(context)
                                .translate(replyMainImageText),
                            textAlign: TextAlign.center,
                          ),
                          color: kAppBarPrimaryColor,
                          onPressed: () {
                            _openImagePicker(PicType.main);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                TextField(
                  maxLines: 1,
                  cursorColor: kIconPrimaryColor,
                  textDirection:
                      rightToLeft() ? TextDirection.rtl : TextDirection.ltr,
                  style: TextStyle(fontSize: 20),
                  textAlign: rightToLeft() ? TextAlign.right : TextAlign.left,
                  decoration: InputDecoration(
                    hintText: '* ' +
                        AppLocalizations.of(context).translate('reply title'),
                    hintStyle: TextStyle(
                        color: Colors.red, fontFamily: 'HelviticaNeue'),
                    focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: kIconPrimaryColor, width: 1),
                    ),
                  ),
                  onChanged: (value) {
                    _title = value;
                  },
                ),
                SizedBox(
                  height: 40,
                ),
                TextField(
                  maxLines: 10,
                  cursorColor: kIconPrimaryColor,
                  textDirection:
                      rightToLeft() ? TextDirection.rtl : TextDirection.ltr,
                  style: TextStyle(fontSize: 20),
                  textAlign: rightToLeft() ? TextAlign.right : TextAlign.left,
                  decoration: InputDecoration(
                    hintText:
                        '* ' + AppLocalizations.of(context).translate('reply'),
                    hintStyle: TextStyle(
                        color: Colors.red, fontFamily: 'HelviticaNeue'),
                    border:
                        OutlineInputBorder(borderSide: BorderSide(width: 1)),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(width: 1, color: kIconPrimaryColor)),
                  ),
                  onChanged: (value) {
                    _reply = value;
                  },
                ),
                SizedBox(
                  height: 40,
                ),
                TextField(
                  maxLines: 3,
                  cursorColor: kIconPrimaryColor,
                  textDirection:
                      rightToLeft() ? TextDirection.rtl : TextDirection.ltr,
                  style: TextStyle(fontSize: 20),
                  textAlign: rightToLeft() ? TextAlign.right : TextAlign.left,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)
                        .translate('message to admin'),
                    border:
                        OutlineInputBorder(borderSide: BorderSide(width: 1)),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(width: 1, color: kIconPrimaryColor)),
                  ),
                  onChanged: (value) {
                    _message = value;
                  },
                ),
              ],
            ),
          ),
          if (_loading) ...[
            Center(child: CircularProgressIndicator()),
          ]
        ],
      ),
    );
  }

  void _openImagePicker(PicType type) async {
    File pick = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      switch (type) {
        case PicType.user:
          userImageText = 'change main reply right image';
          break;
        case PicType.main:
          replyMainImageText = 'change reply right user image';
          break;
        case PicType.other:
          break;
      }
    });
    String url =
        await Provider.of<APIManager>(context).uploadImage(imageFile: pick);
    type == PicType.user ? userImage = url : mainImage = url;
  }
}

enum PicType { user, main, other }

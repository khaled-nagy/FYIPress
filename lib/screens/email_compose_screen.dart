import 'dart:async';
import 'dart:io';
import 'package:NewsBuzz/ConstantVarables.dart';
import 'package:NewsBuzz/utility/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:image_picker/image_picker.dart';

class MailComposerScreen extends StatefulWidget {
  @override
  _MailComposerScreenState createState() => _MailComposerScreenState();
}

class _MailComposerScreenState extends State<MailComposerScreen> {
  final recepientEmail = '';

  String attachment;
  bool _loading = false;

  final _nameController = TextEditingController();

  final _phoneController = TextEditingController();

  final _emailController = TextEditingController();

  final _subjectController = TextEditingController();

  final _bodyController = TextEditingController();

  String validateUserName(String val) {
    if (val.trim().isEmpty) {
      return "من فضلك ادخل البيانات";
    } else
      return null;
  }

  Future<void> send() async {
    var form = ConstantVarable.messageformKey.currentState;
     ConstantVarable.messageAutoValid = true;
    if (form.validate()) {
      setState(() {
        _loading = true;
      });
      //TODO: Ask for a mail API
      final MailOptions mailOptions = MailOptions(
        body: _bodyController.text,
        subject: _subjectController.text,
        recipients: [recepientEmail],
        isHTML: true,
        attachments: [
          attachment,
        ],
      );

      String platformResponse;

      try {
        await FlutterMailer.send(mailOptions);
        platformResponse = 'success';
      } catch (error) {
        platformResponse = error.toString();
      }

      if (!mounted) return;

      setState(() {
        _loading = false;
      });
      showAlert(platformResponse, () {
        Navigator.pop(context);
        Navigator.pop(context);
      });
    } else {
      setState(() {
        form.save();
      });
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

  @override
  Widget build(BuildContext context) {
    final Widget imagePath = Text(attachment ?? '');

    return Scaffold(
      appBar: AppBar(
        title: Text('ارسل لنا رسالة'),
        actions: <Widget>[
          IconButton(
            onPressed: send,
            icon: Icon(Icons.send),
          )
        ],
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Form(
                  key: ConstantVarable.messageformKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      myTextField(
                          label: 'Name*',
                          controller: _nameController,
                          labelColor: Colors.red),
                      myTextField(
                          label: 'Email*',
                          controller: _emailController,
                          labelColor: Colors.red),
                      myTextField(
                          label: 'Phone',
                          controller: _phoneController,
                          labelColor: Colors.black54),
                      myTextField(
                          label: 'Subject*',
                          controller: _subjectController,
                          labelColor: Colors.red),
                      myTextField(
                          label: 'Body*',
                          controller: _bodyController,
                          linesNum: 10,
                          labelColor: Colors.red),
                      imagePath,
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_loading) ...[
            Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.camera),
        label: Text('Add Image'),
        backgroundColor: kAppBarPrimaryColor,
        onPressed: _openImagePicker,
      ),
    );
  }

  Padding myTextField(
      {String label,
      TextEditingController controller,
      int linesNum = 1,
      Color labelColor}) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        maxLines: linesNum,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: label,
          labelStyle: TextStyle(color: labelColor, fontFamily: 'HelviticaNeue'),
        ),
        validator: (val) {
         return  validateUserName(val);
        }
      ),
    );
  }

  void _openImagePicker() async {
    File pick = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      attachment = pick.path;
    });
  }
}

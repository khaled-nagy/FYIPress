import 'package:flutter/material.dart';

const kSendButtonTextStyle = TextStyle(
  color: Colors.lightBlueAccent,
  fontWeight: FontWeight.bold,
  fontSize: 18.0,
);

const kMessageTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  hintText: 'Type your comment here...',
  border: InputBorder.none,
);

const kMessageContainerDecoration = BoxDecoration(
  border: Border(
    top: BorderSide(color: kAppBarPrimaryColor, width: 2.0),
  ),
);

const kAppBarPrimaryColor = Color(0xFF55abcc);
const kbackgroundPrimaryColor = Color(0xFFEEEDE7);
const kIconPrimaryColor = Color(0xFFfb5660);

const kBaseKey = 'fyipress2020';
const kSecretKey = '12345678912345678912345678912345';

const klanguages = [
  'ar',
  'en',
  'tu',
  'ur',
  'sp',
  'ru',
  'jp',
  'hi',
  'ge',
  'fr',
  'ch',
  'he'
];

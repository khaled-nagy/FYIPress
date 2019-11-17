import 'package:flutter/material.dart';
import 'package:NewsBuzz/utility/constants.dart';

class CommentFieldContainer extends StatefulWidget {
  final Function(String) submitButtonPressed;

  CommentFieldContainer({@required this.submitButtonPressed});

  @override
  _CommentFieldContainerState createState() => _CommentFieldContainerState();
}

class _CommentFieldContainerState extends State<CommentFieldContainer> {
  final TextEditingController textController = TextEditingController();

  String fieldText;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: kMessageContainerDecoration,
      height: 60,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: textController,
              onChanged: (value) {
                fieldText = value;
              },
              decoration: kMessageTextFieldDecoration,
            ),
          ),
          FlatButton(
            onPressed: () {
              widget.submitButtonPressed(fieldText);
              textController.clear();
              fieldText = null;
            },
            child: Icon(
              Icons.comment,
              color: kIconPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

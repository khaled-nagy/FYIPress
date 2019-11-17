import 'package:NewsBuzz/services/api_manager.dart';
import 'package:NewsBuzz/utility/constants.dart';
import 'package:flutter/material.dart';

class ReportDialog extends StatefulWidget {
  final Function(ReportReason, String) didSubmitReport;

  const ReportDialog({@required this.didSubmitReport});
  @override
  _ReportDialogState createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  ReportReason _reason = ReportReason.hateSpeech;
  final TextEditingController _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RadioListTile<ReportReason>(
            title: Text('خطاب كراهية'),
            activeColor: kIconPrimaryColor,
            value: ReportReason.hateSpeech,
            groupValue: _reason,
            onChanged: (ReportReason value) {
              setState(() {
                _reason = value;
              });
            },
          ),
          RadioListTile<ReportReason>(
            title: Text('محتوى عنيف'),
            activeColor: kIconPrimaryColor,
            value: ReportReason.violentContent,
            groupValue: _reason,
            onChanged: (ReportReason value) {
              setState(() {
                _reason = value;
              });
            },
          ),
          RadioListTile<ReportReason>(
            title: Text('كلمات سيئة'),
            activeColor: kIconPrimaryColor,
            value: ReportReason.badWords,
            groupValue: _reason,
            onChanged: (ReportReason value) {
              setState(() {
                _reason = value;
              });
            },
          ),
          RadioListTile<ReportReason>(
            title: Text('محتوى جنسي'),
            activeColor: kIconPrimaryColor,
            value: ReportReason.sexualContent,
            groupValue: _reason,
            onChanged: (ReportReason value) {
              setState(() {
                _reason = value;
              });
            },
          ),
          RadioListTile<ReportReason>(
            title: Text('إساءة'),
            activeColor: kIconPrimaryColor,
            value: ReportReason.abuse,
            groupValue: _reason,
            onChanged: (ReportReason value) {
              setState(() {
                _reason = value;
              });
            },
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                  labelText: 'notes',
                  labelStyle: TextStyle(color: Colors.black87),
                  border: OutlineInputBorder()),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: FlatButton(
                  child: Text(
                    'ارسل',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  color: kIconPrimaryColor,
                  onPressed: () {
                    widget.didSubmitReport(_reason, _notesController.text);
                  },
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                child: FlatButton(
                  child: Text(
                    'الغاء',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  color: kIconPrimaryColor,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

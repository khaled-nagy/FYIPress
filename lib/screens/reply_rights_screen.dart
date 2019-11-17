import 'package:NewsBuzz/models/article.dart';
import 'package:NewsBuzz/models/reply_right.dart';
import 'package:NewsBuzz/services/api_manager.dart';
import 'package:NewsBuzz/services/base_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:NewsBuzz/app_localizations.dart';

class ReplyRightsScreen extends StatefulWidget {
  @override
  _ReplyRightsScreenState createState() => _ReplyRightsScreenState();
}

class _ReplyRightsScreenState extends State<ReplyRightsScreen> {
  bool fetchingRights = false;
  List<ReplyRight> rights;

  getReplyRights(String id, String rank) async {
    if (fetchingRights || rights != null) {
      return;
    }
    fetchingRights = true;
    final APIManager apiManager = Provider.of<APIManager>(context);

    final Article article = await apiManager.getArticleByID(
        id, Provider.of<MyAuth>(context).user, rank);

    setState(() {
      rights = article.replyRights ?? [];
      fetchingRights = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Article article = ModalRoute.of(context).settings.arguments;
    getReplyRights(article.id, article.rank);
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/addreplyright',
                  arguments: article);
            },
          )
        ],
      ),
      body: rights == null
          ? Center(child: CircularProgressIndicator())
          : rights.isEmpty
              ? Center(
                  child: Container(
                  width: 150,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.thumb_up,
                        size: 100,
                        color: Colors.black54,
                      ),
                      Text(
                        AppLocalizations.of(context)
                            .translate('no reply rights'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54),
                      ),
                    ],
                  ),
                ))
              : Container(
                  child: ListView.builder(
                    itemCount: 2,
                    itemBuilder: (context, index) {
                      final ReplyRight right = article.replyRights[index];
                      return Card(
                        elevation: 1.6,
                        child: Container(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                right.name,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87),
                              ),
                              Text(
                                right.title,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    fontSize: 24, color: Colors.black87),
                              ),
                              SizedBox(height: 10),
                              Text(
                                right.reply,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    fontSize: 18, color: Colors.black87),
                              ),
                              SizedBox(height: 20),
                              Text(
                                right.when,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

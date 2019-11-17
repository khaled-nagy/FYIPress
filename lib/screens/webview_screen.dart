import 'package:NewsBuzz/app_localizations.dart';
import 'package:NewsBuzz/models/article.dart';
import 'package:NewsBuzz/services/api_manager.dart';
import 'package:NewsBuzz/services/base_auth.dart';
import 'package:NewsBuzz/utility/constants.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';
import '../widgets/comment_container.dart';
import 'package:provider/provider.dart';

class WebViewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Article article = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(title: Text(article.sourceName), actions: <Widget>[
        FlatButton(
          child: Text(
            AppLocalizations.of(context).translate('reply right'),
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          onPressed: () =>
              Navigator.pushNamed(context, '/replyright', arguments: article),
        ),
      ]),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: WebView(
              initialUrl: article.url,
            ),
          ),
          CommentFieldContainer(
            submitButtonPressed: (comment) async {
              if (comment == null || comment.isEmpty) {
                goToCommentScreen(context, article);
              } else {
                try {
                  await Provider.of<APIManager>(context).addComment(
                    comment: comment,
                    articleID: article.id,
                    rank: article.rank,
                    user: Provider.of<MyAuth>(context).user,
                  );

                  goToCommentScreen(context, article);
                } catch (e) {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: Text(e),
                            actions: <Widget>[
                              FlatButton(
                                child: Text('Ok'),
                                color: kAppBarPrimaryColor,
                                onPressed: () => Navigator.pop(context),
                              )
                            ],
                          ));
                }
              }
            },
          )
        ],
      ),
    );
  }

  goToCommentScreen(BuildContext context, Article article) {
    Navigator.pushNamed(context, '/comments', arguments: article);
  }
}

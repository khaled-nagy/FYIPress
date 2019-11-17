import 'package:NewsBuzz/app_localizations.dart';
import 'package:NewsBuzz/models/comment.dart';
import 'package:NewsBuzz/models/user.dart';
import 'package:NewsBuzz/services/api_manager.dart';
import 'package:NewsBuzz/utility/constants.dart';
import 'package:NewsBuzz/widgets/report_dialog.dart';
import 'package:flutter/material.dart';
import '../widgets/comment_container.dart';
import 'package:NewsBuzz/models/article.dart';
import 'package:timeago/timeago.dart' as timeAgo;
import 'package:provider/provider.dart';
import 'package:NewsBuzz/services/base_auth.dart';

class CommentsScreen extends StatefulWidget {
  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  List<Comment> comments;
  bool fetchingComments = false;
  bool sendingNewComment = false;

  @override
  void initState() {
    super.initState();
  }

  fetchComments() async {
    if (!fetchingComments) {
      fetchingComments = true;
      APIManager apiManager = Provider.of<APIManager>(context);
      User user = Provider.of<MyAuth>(context).user;
      final Article article = ModalRoute.of(context).settings.arguments;

      Article fullArticle =
          await apiManager.getArticleByID(article.id, user, article.rank);
      fetchingComments = false;
      setState(() {
        comments = fullArticle.comments;
        sendingNewComment = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Article article = ModalRoute.of(context).settings.arguments;
    if (comments == null) {
      fetchComments();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('comments')),
      ),
      body: comments == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Stack(children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: ListView.separated(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: comments.length > 0 ? comments.length + 1 : 2,
                      itemBuilder: (context, index) {
                        return index == 0
                            ? Container(
                                margin: EdgeInsets.all(8),
                                child: Column(
                                  children: <Widget>[
                                    Image.network(
                                      article.imageUrl,
                                      fit: BoxFit.cover,
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              article.sourceName,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 20,
                                              ),
                                            ),
                                            Text(
                                              timeAgo.format(
                                                      article.publishedAt) ??
                                                  '',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      article.title,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                  ],
                                ),
                              )
                            : comments.isNotEmpty
                                ? commentContainer(index - 1)
                                : Column(
                                    children: [
                                      SizedBox(height: 30),
                                      Text(
                                        'اكتب التعليق الأول على الخبر',
                                        style: TextStyle(
                                            fontSize: 30,
                                            color: kIconPrimaryColor),
                                      ),
                                    ],
                                  );
                      },
                      separatorBuilder: (c, _) {
                        return Divider(
                          height: 1,
                          color: Colors.black,
                          indent: 10,
                          endIndent: 10,
                        );
                      },
                    ),
                  ),
                  CommentFieldContainer(
                    submitButtonPressed: (comment) async {
                      print(comment);
                      if (comment != null && comment != '') {
                        setState(() {
                          sendingNewComment = true;
                        });
                        try {
                          await Provider.of<APIManager>(context).addComment(
                            comment: comment,
                            articleID: article.id,
                            rank: article.rank,
                            user: Provider.of<MyAuth>(context).user,
                          );
                          Future.delayed(Duration(seconds: 1), () {
                            fetchComments();
                          });
                        } catch (e) {
                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    title: Text(e),
                                    actions: <Widget>[
                                      FlatButton(
                                          child: Text('Ok',
                                              style: TextStyle(
                                                  color: kAppBarPrimaryColor)),
                                          onPressed: () =>
                                              Navigator.popAndPushNamed(
                                                  context, '/login'))
                                    ],
                                  ));
                        }
                      }
                    },
                  ),
                ],
              ),
              if (sendingNewComment) ...[
                Center(
                  child: CircularProgressIndicator(),
                ),
              ]
            ]),
    );
  }

  Container commentContainer(int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    comments[index].name,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                  ),
                ],
              ),
              Text(
                comments[index].when,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black54),
              ),
            ],
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            comments[index].comment,
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
          ),
          SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.reply),
                onPressed: () {},
              ),
              if (!comments[index].reported) ...[
                IconButton(
                  icon: Icon(Icons.flag),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (c) => Dialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0)),
                            child: ReportDialog(
                              didSubmitReport: (reason, notes) async {
                                APIManager apiManager =
                                    Provider.of<APIManager>(context);
                                User user = Provider.of<MyAuth>(context).user;

                                try {
                                  Article article =
                                      ModalRoute.of(context).settings.arguments;
                                  String response =
                                      await apiManager.reportCommentOrReply(
                                          articleID: article.id,
                                          isComment: true,
                                          id: comments[index].id,
                                          reason: reason,
                                          notes: notes,
                                          rank: article.rank,
                                          user: user);
                                  Navigator.pop(context);
                                  showAlert(response, () {
                                    Navigator.pop(context);
                                    setState(() {
                                      comments[index].reported = true;
                                    });
                                  });
                                } catch (e) {
                                  showAlert(e, () => Navigator.pop(context));
                                }
                              },
                            )));
                  },
                )
              ],
            ],
          ),
        ],
      ),
    );
  }

  showAlert(String title, Function onOkPress) {
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
}

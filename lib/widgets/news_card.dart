import 'package:NewsBuzz/app_localizations.dart';
import 'package:NewsBuzz/models/article.dart';
import 'package:NewsBuzz/services/api_manager.dart';
import 'package:NewsBuzz/utility/constants.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:provider/provider.dart';
import 'package:html/parser.dart' show parse;

class NewsCard extends StatelessWidget {
  final Article article;
  final Function bookMarked;
  final bool isHotNews;

  NewsCard({this.article, this.bookMarked, this.isHotNews});

  Column buildButtonColumn(IconData icon) {
    return new Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        new Icon(icon),
      ],
    );
  }

  String _articleTitle(Article article) {
    try {
      var document = parse(article.title);
      return document.body.text;
    } catch (e) {
      print(e);
      return article.title;
    }
  }

  @override
  Widget build(BuildContext context) {
    final APIManager apiManager = Provider.of<APIManager>(context);
    final bool rightToLeft = apiManager.languageDirection == 'right';

    return GestureDetector(
      child: Card(
        elevation: isHotNews ? 2.5 : 1.7,
        child: Container(
          child: new Padding(
            padding: new EdgeInsets.only(
                top: 10.0, right: isHotNews ? 0 : 5, left: isHotNews ? 0 : 5),
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage( article.imageUrl==null?"https://blog.akhbarak.net/blog/wp-content/uploads/2018/04/%D8%B5%D9%88%D8%B1%D8%A9-%D8%A7%D9%84%D8%A7%D8%AE%D8%A8%D8%A7%D8%B1-600x330.jpg":article.imageUrl),
                    fit: BoxFit.cover )
                ),
                  constraints: BoxConstraints(
                      maxHeight: isHotNews ? 200 : 400, minHeight: 200),
                ),
                new Row(
                  children: [
                    new Expanded(
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: new EdgeInsets.only(
                                left: 4.0,
                                right: isHotNews ? 0 : 8.0,
                                top: isHotNews ? 0 : 4.0),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.0),
                              child: Text(
                                _articleTitle(article),
                                maxLines: isHotNews ? 2 : 3,
                                style: new TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                textAlign: rightToLeft
                                    ? TextAlign.right
                                    : TextAlign.left,
                              ),
                            ),
                          ),
                          if (!isHotNews) ...[
                            Padding(
                              padding: new EdgeInsets.only(
                                  left: 4.0, right: 4.0, bottom: 4.0),
                              child: Text(
                                article.description,
                                textAlign: rightToLeft
                                    ? TextAlign.right
                                    : TextAlign.left,
                                style: new TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                          SizedBox(
                            height: 5,
                          ),
                          bottomRowBuilder(context),
                        ],
                      ),
                    ),
                  ],
                ),
                if (!isHotNews) ...[
                  Row(
                    mainAxisAlignment: rightToLeft
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: <Widget>[
                      new GestureDetector(
                          child: new Padding(
                              padding: new EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 5.0),
                              child: buildButtonColumn(Icons.share)),
                          onTap: () {
                            Share.share(article.url);
                          }),
//                    GestureDetector(
//                      child: new Padding(
//                          padding: new EdgeInsets.all(5.0),
//                          child: article.bookMarked
//                              ? buildButtonColumn(Icons.bookmark)
//                              : buildButtonColumn(Icons.bookmark_border)),
//                      onTap: () {
//                        bookMarked(article);
//                      },
//                    ),
                    ],
                  ),
                ],
              ],
            ), ////
          ),
        ),
      ),
      onTap: () {
        Navigator.pushNamed(context, '/webview', arguments: article);
      },
    );
  }

  Row bottomRowBuilder(BuildContext context) {
    final APIManager apiManager = Provider.of<APIManager>(context);
    final bool rightToLeft = apiManager.languageDirection == 'right';

    final List<Widget> secondRowChildren = [
      Padding(
        padding: new EdgeInsets.only(
            right: rightToLeft ? 5 : 0, left: rightToLeft ? 0 : 5),
        child: new AutoSizeText(
          article.sourceName,
          maxFontSize: 12,
          minFontSize: 8,
          style: new TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
      ),
      Padding(
        padding: new EdgeInsets.only(left: 5, right: 5),
        child: new AutoSizeText(
          article.when,
          maxFontSize: 12,
          minFontSize: 8,
          style: new TextStyle(
            fontWeight: FontWeight.w400,
            color: Colors.grey[800],
          ),
        ),
      ),
      if (article.commentCount != null && article.commentCount.isNotEmpty) ...[
        AutoSizeText(
          article.commentCount +
              ' ' +
              AppLocalizations.of(context).translate('comment'),
          maxFontSize: 12,
          minFontSize: 8,
          style: TextStyle(
            color: kIconPrimaryColor,
          ),
        ),
      ],
    ];

    final List<Widget> firstRowChildren = [
      GestureDetector(
        child: SizedBox(
          child: Image.asset('images/replyright.png'),
          height: 40,
          width: 40,
        ),
        onTap: () {
          Navigator.pushNamed(context, '/addreplyright', arguments: article);
        },
      ),
      Row(
          children: rightToLeft
              ? secondRowChildren.reversed.toList()
              : secondRowChildren),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children:
          rightToLeft ? firstRowChildren : firstRowChildren.reversed.toList(),
    );
  }
}

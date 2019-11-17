import 'package:NewsBuzz/models/article.dart';
import 'package:NewsBuzz/services/api_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:share/share.dart';
import 'package:timeago/timeago.dart' as timeAgo;
import 'package:provider/provider.dart';

class BookmarksScreen extends StatefulWidget {
  @override
  _BookmarksScreenState createState() => new _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  _onBookmarkTap(Article article) {
    Provider.of<APIManager>(context).bookmarkArticle(article);
    Scaffold.of(context).showSnackBar(new SnackBar(
      content: new Text('Article removed'),
      backgroundColor: Colors.grey[600],
      duration: Duration(seconds: 1),
    ));
  }

  Column buildButtonColumn(IconData icon) {
    return new Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        new Icon(icon),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<APIManager>(builder: (context, apiManager, _) {
      List<Article> bookMarks =
          apiManager.articles?.articles?.where((a) => a.bookMarked);
      if (bookMarks?.isEmpty ?? false) {
        return noBookmarksView;
      }
      final List<Article> articles = bookMarks;
      return Scaffold(
        backgroundColor: Colors.grey[200],
        body: articles == null
            ? Center(child: CircularProgressIndicator())
            : articles.isNotEmpty
                ? new Column(
                    children: <Widget>[
                      new Flexible(
                          child: ListView.builder(
                        padding: new EdgeInsets.all(2.0),
                        itemCount: articles.length,
                        itemBuilder: (context, index) {
                          return new GestureDetector(
                            child: new Card(
                              elevation: 1.7,
                              child: new Padding(
                                padding: new EdgeInsets.all(10.0),
                                child: new Column(
                                  children: [
                                    new Row(
                                      children: <Widget>[
                                        new Padding(
                                          padding:
                                              new EdgeInsets.only(left: 4.0),
                                          child: new Text(
                                            timeAgo.format(articles[index]
                                                    .publishedAt) ??
                                                '',
                                            style: new TextStyle(
                                              fontWeight: FontWeight.w400,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                        new Padding(
                                          padding: new EdgeInsets.all(5.0),
                                          child: new Text(
                                            articles[index].sourceName,
                                            style: new TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    new Row(
                                      children: [
                                        new Expanded(
                                          child: new GestureDetector(
                                            child: new Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                new Padding(
                                                  padding: new EdgeInsets.only(
                                                      left: 4.0,
                                                      right: 8.0,
                                                      bottom: 8.0,
                                                      top: 8.0),
                                                  child: new Text(
                                                    articles[index].title,
                                                    style: new TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                new Padding(
                                                  padding: new EdgeInsets.only(
                                                      left: 4.0,
                                                      right: 4.0,
                                                      bottom: 4.0),
                                                  child: new Text(
                                                    articles[index].description,
                                                    style: new TextStyle(
                                                      color: Colors.grey[500],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            onTap: () {
                                              Navigator.pushNamed(
                                                  context, '/webview',
                                                  arguments: articles[index]);
                                            },
                                          ),
                                        ),
                                        new Column(
                                          children: <Widget>[
                                            new Padding(
                                              padding:
                                                  new EdgeInsets.only(top: 8.0),
                                              child: new SizedBox(
                                                height: 100.0,
                                                width: 100.0,
                                                child: new Image.network(
                                                  articles[index].imageUrl,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            new Row(
                                              children: <Widget>[
                                                new GestureDetector(
                                                  child: new Padding(
                                                      padding: new EdgeInsets
                                                              .symmetric(
                                                          vertical: 10.0,
                                                          horizontal: 5.0),
                                                      child: buildButtonColumn(
                                                          Icons.share)),
                                                  onTap: () {
                                                    Share.share(
                                                        articles[index].url);
                                                  },
                                                ),
                                                new GestureDetector(
                                                  child: buildButtonColumn(
                                                      Icons.bookmark),
                                                  onTap: () {
                                                    _onBookmarkTap(
                                                        articles[index]);
                                                  },
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      )),
                    ],
                  )
                : noBookmarksView,
      );
    });
  }

  Center get noBookmarksView {
    return Center(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          new Icon(Icons.chrome_reader_mode, color: Colors.grey, size: 60.0),
          new Text(
            "No articles saved",
            style: new TextStyle(fontSize: 24.0, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

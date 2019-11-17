import 'dart:async';
import 'package:NewsBuzz/models/article.dart';
import 'package:NewsBuzz/models/user.dart';
import 'package:NewsBuzz/services/api_manager.dart';
import 'package:NewsBuzz/services/base_auth.dart';
import 'package:NewsBuzz/utility/constants.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:provider/provider.dart';
import 'package:loadmore/loadmore.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({
    this.searchQuery = '',
  });

  final String searchQuery;
  @override
  _SearchScreenState createState() => new _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Article> articles;

  Future getData() async {
    APIManager apiManager = Provider.of<APIManager>(context);
    User user = Provider.of<MyAuth>(context).user;
    try {
      List<Article> results =
          await apiManager.searchForArticles(widget.searchQuery, 1, user);
      if (mounted) {
        setState(() {
          articles = results;
        });
      }
    } catch (e) {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: e,
                actions: <Widget>[
                  FlatButton(
                    child: Text(
                      'Ok',
                      style: TextStyle(color: kIconPrimaryColor),
                    ),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ));
    }
  }

  Future<bool> _loadMoreArticles() async {
    APIManager apiManager = Provider.of<APIManager>(context);
    int finalPage = articles.length ~/ 10;

    try {
      List<Article> newArts = await apiManager.searchForArticles(
          widget.searchQuery, finalPage + 1, Provider.of<MyAuth>(context).user);
      if (mounted) {
        setState(() {
          articles.addAll(newArts);
        });
      }
      return true;
    } catch (e) {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: e,
                actions: <Widget>[
                  FlatButton(
                    child: Text(
                      'Ok',
                      style: TextStyle(color: kIconPrimaryColor),
                    ),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ));
      return true;
    }
  }

  _onBookmarkTap(article) {
    //TODO: Search bookmark tap
  }

  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 0), () {
      this.getData();
    });
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

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text(widget.searchQuery),
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[200],
      body: articles == null
          ? const Center(child: const CircularProgressIndicator())
          : articles.isEmpty
              ? new Padding(
                  padding: new EdgeInsets.only(top: 60.0),
                  child: new Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        new Icon(Icons.error_outline,
                            size: 60.0, color: Colors.redAccent[200]),
                        new Center(
                          child: new Text(
                            "Could not find anything related to '${widget.searchQuery}'",
                            textScaleFactor: 1.5,
                            textAlign: TextAlign.center,
                            style: new TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                      ]))
              : LoadMore(
                  onLoadMore: _loadMoreArticles,
                  textBuilder: (_) => 'Loading more results',
                  child: ListView.builder(
                    itemCount: articles.length,
                    itemBuilder: (BuildContext context, int index) {
                      return new GestureDetector(
                          child: Card(
                        elevation: 1.7,
                        child: new Padding(
                          padding: new EdgeInsets.all(10.0),
                          child: new Column(
                            children: [
                              new Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  new Padding(
                                    padding: new EdgeInsets.only(right: 10.0),
                                    child: new Text(
                                      articles[index].sourceName,
                                      style: new TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: kIconPrimaryColor,
                                      ),
                                    ),
                                  ),
                                  new Padding(
                                    padding: new EdgeInsets.only(left: 4.0),
                                    child: new Text(
                                      articles[index].when,
                                      style: new TextStyle(
                                        fontWeight: FontWeight.w400,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              GestureDetector(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: articles[index].imageUrl != null
                                      ? Image.network(
                                          articles[index].imageUrl,
                                          fit: BoxFit.cover,
                                        )
                                      : SizedBox(),
                                ),
                                onTap: () {
                                  Navigator.pushNamed(context, '/webview',
                                      arguments: articles[index]);
                                },
                              ),
                              new Row(
                                children: [
                                  new Expanded(
                                    child: new GestureDetector(
                                      child: new Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
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
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                          new Padding(
                                            padding: new EdgeInsets.only(
                                                left: 4.0,
                                                right: 4.0,
                                                bottom: 4.0),
                                            child: new Text(
                                              articles[index].description,
                                              textAlign: TextAlign.right,
                                              style: new TextStyle(
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        Navigator.pushNamed(context, '/webview',
                                            arguments: articles[index]);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  new GestureDetector(
                                      child: new Padding(
                                          padding: new EdgeInsets.symmetric(
                                              vertical: 10.0, horizontal: 5.0),
                                          child:
                                              buildButtonColumn(Icons.share)),
                                      onTap: () {
                                        Share.share(articles[index].url);
                                      }),
                                  new GestureDetector(
                                    child: new Padding(
                                        padding: new EdgeInsets.all(5.0),
                                        child: articles[index].bookMarked
                                            ? buildButtonColumn(Icons.bookmark)
                                            : buildButtonColumn(
                                                Icons.bookmark_border)),
                                    onTap: () {
                                      _onBookmarkTap(articles[index]);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ), ////
                        ),
                      ));
                    },
                  )),
    );
  }
}

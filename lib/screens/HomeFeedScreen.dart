import 'dart:io';

import 'package:NewsBuzz/app_localizations.dart';
import 'package:NewsBuzz/models/article.dart';
import 'package:NewsBuzz/screens/SearchScreen.dart';
import 'package:NewsBuzz/services/api_manager.dart';
import 'package:NewsBuzz/services/base_auth.dart';
import 'package:NewsBuzz/widgets/my_scaffold.dart';
import 'package:NewsBuzz/widgets/news_card.dart';

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:loadmore/loadmore.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeFeedScreen extends StatefulWidget {
  @override
  _HomeFeedScreenState createState() => new _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  final TextEditingController _controller = TextEditingController();

  final ScrollController listScrollController = ScrollController();
  SlideShowData slideShowData;
  bool searching = false;

  @override
  void initState() {
    listScrollController.addListener(_scrollListener);
    super.initState();
  }

  _scrollListener() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  _onBookmarkTap(Article article) async {
    final apiManager = Provider.of<APIManager>(context);

    final process = await apiManager.bookmarkArticle(article);

    if (process == 'added') {
      _showSnackBar('Article bookmarked!');
    } else if (process == 'removed') {
      _showSnackBar('Article removed from bookmarks!');
    } else {
      _goToLogin();
    }
  }

  _showSnackBar(String title) {
    Scaffold.of(context).showSnackBar(new SnackBar(
      content: new Text(title),
      backgroundColor: Colors.grey[600],
      duration: Duration(seconds: 1),
    ));
  }

  _goToLogin() {
    Navigator.pushNamed(context, '/2');
  }

//  _onRemoveSource(id) async {
//    final apiManager = Provider.of<APIManager>(context);
//    NewsSource theSource =
//        apiManager.sources.sources.where((s) => s.id == id).first;
//
//    Scaffold.of(context).showSnackBar(new SnackBar(
//      content: new Text('Are you sure you want to remove ${theSource.name}?'),
//      backgroundColor: Colors.grey[600],
//      duration: new Duration(seconds: 3),
//      action: new SnackBarAction(
//          label: 'Yes',
//          onPressed: () async {
//            final process = await apiManager.toggleSource(theSource);
//
//            if (process == 'removed') {
//              _showSnackBar('Source removed!');
//            } else {
//              _goToLogin();
//            }
//            Scaffold.of(context).showSnackBar(new SnackBar(
//                content: new Text('${theSource.name} removed'),
//                backgroundColor: Colors.grey[600]));
//          }),
//    ));
//  }

  void handleTextInputSubmit(var input) {
    if (input != '') {
      Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider.value(
                value: Provider.of<APIManager>(context),
                child: SearchScreen(searchQuery: input))),
      );
    }
  }

  bool areArticlesNull() {
    final apiManager = Provider.of<APIManager>(context);
    if (apiManager.articles == null || apiManager.articles.articles == null) {
      reloadData();
      return true;
    }
    return false;
  }

  bool areSelectedArticlesEmpty() {
    final apiManager = Provider.of<APIManager>(context);
    List<Article> arts = apiManager.showingAdminNews
        ? apiManager.articles.adminArticles
        : apiManager.articles.articles;

    return arts.isEmpty;
  }

  bool areHotNewsLoaded() {
    if (slideShowData == null) {
      loadHotNews();
      return false;
    } else {
      return true;
    }
  }

  Future loadHotNews() async {
    APIManager apiManager = Provider.of<APIManager>(context);
    MyAuth myAuth = Provider.of<MyAuth>(context);
    var hots = await apiManager.getHotArticles(myAuth.user);
    if (hots != null) {
      if (mounted) {
        setState(() {
          slideShowData = hots;
        });
      }
    }
  }

  Future reloadData() async {
    MyAuth myAuth = Provider.of<MyAuth>(context);

    await myAuth.getMyData();
    await Provider.of<APIManager>(context)
        .getArticles(page: 1, user: myAuth.user);
  }

  Future<bool> _loadMoreArticles() async {
    APIManager apiManager = Provider.of<APIManager>(context);
    int finalPage = apiManager.articles.articles.length ~/ 10;
    if (apiManager.articles.numberOfPages != null &&
        finalPage > apiManager.articles.numberOfPages) {
      return false;
    }

    if (apiManager.showingBreakingNews) {
      await apiManager.getBreakingNews(
          page: finalPage + 1, user: Provider.of<MyAuth>(context).user);
    } else {
      await apiManager.getArticles(
          page: finalPage + 1, user: Provider.of<MyAuth>(context).user);
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return MyMainScaffold(
      itemSelected: (index) {
        switch (index) {
          case 0:
            break;
          case 5:
            Provider.of<MyAuth>(context).signOut();
            Provider.of<APIManager>(context).handleAfterSignOut();
            break;
          default:
            Navigator.pushNamed(context, '/$index');
        }
      },
      searchPressed: () {
        setState(() {
          searching = !searching;
        });
      },
      profilePicClicked: () {
        _openImagePicker();
      },
      body: Stack(
        alignment: AlignmentDirectional.bottomStart,
        children: <Widget>[
          Consumer<APIManager>(builder: (context, apiManager, _) {
            return Column(
              children: <Widget>[
                if (searching) ...[
                  Padding(
                    padding: EdgeInsets.all(0.0),
                    child: PhysicalModel(
                      color: Colors.white,
                      elevation: 3.0,
                      child: TextField(
                        textAlign: apiManager.languageDirection == 'right'
                            ? TextAlign.right
                            : TextAlign.left,
                        controller: _controller,
                        onSubmitted: handleTextInputSubmit,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(14),
                          hintText: AppLocalizations.of(context)
                              .translate('look for news'),
                          suffixIcon: apiManager.languageDirection == 'right'
                              ? Icon(Icons.search)
                              : null,
                          prefixIcon: apiManager.languageDirection == 'right'
                              ? null
                              : Icon(Icons.search),
                        ),
                      ),
                    ),
                  )
                ],
                Expanded(
                  child: areArticlesNull()
                      ? Center(child: CircularProgressIndicator())
                      : !areSelectedArticlesEmpty()
                          ? LoadMore(
                              textBuilder: (_) => AppLocalizations.of(context)
                                  .translate('Loading more news'),
                              onLoadMore: _loadMoreArticles,
                              child: ListView.builder(
                                controller: listScrollController,
                                itemCount: apiManager.showingAdminNews
                                    ? apiManager.articles.adminArticles.length
                                    : apiManager.articles.articles.length,
//                                padding: new EdgeInsets.all(8.0),
                                itemBuilder: (context, index) {
                                  if (index == 0) {
                                    if (areHotNewsLoaded() &&
                                        (slideShowData?.articles?.isNotEmpty ??
                                            false)) {
                                      return CarouselSlider(
                                        autoPlayInterval: Duration(
                                            milliseconds:
                                                slideShowData.duration),
                                        viewportFraction: 1.0,
                                        enlargeCenterPage: false,
                                        pauseAutoPlayOnTouch:
                                            Duration(seconds: 2),
                                        height: 340,
                                        autoPlay: true,
                                        items: slideShowData.articles
                                            .map((hotArticle) {
                                          return Builder(
                                            builder: (context) {
                                              return NewsCard(
                                                article: hotArticle,
                                                bookMarked: (_) {},
                                                isHotNews: true,
                                              );
                                            },
                                          );
                                        }).toList(),
                                      );
                                    } else {
                                      return Container();
                                    }
                                  }
                                  Article art = apiManager.showingAdminNews
                                      ? apiManager
                                          .articles.adminArticles[index - 1]
                                      : apiManager.articles.articles[index - 1];
                                  return NewsCard(
                                    article: art,
                                    bookMarked: () => _onBookmarkTap(
                                      art,
                                    ),
                                    isHotNews: false,
                                  );
                                },
                              ),
                            )
                          : new Center(
                              child: new Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  new Icon(Icons.chrome_reader_mode,
                                      color: Colors.grey, size: 60.0),
                                  new Text(
                                    AppLocalizations.of(context)
                                        .translate('no articles found'),
                                    textAlign: TextAlign.center,
                                    style: new TextStyle(
                                        fontSize: 24.0, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                ),
              ],
            );
          }),
         
          Container(
            height: 170,
            width: 80,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              children: <Widget>[
                Container(
                  child: AutoSizeText(
                    AppLocalizations.of(context).translate('contact us'),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    minFontSize: 16,
                    maxFontSize: 20,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  width: 80,
                ),
                GestureDetector(
                  child: Icon(CupertinoIcons.conversation_bubble,
                      color: Colors.white, size: 40),
                  onTap: () async {
                    var whatsappUrl = "whatsapp://send?phone=+97450279427";
                    await canLaunch(whatsappUrl)
                        ? launch(whatsappUrl)
                        : print('Error Launching whatsapp ==================');
//                    await FlutterLaunch.launchWathsApp(
//                        phone: "+97450279427", message: '');
                  },
                ),
                GestureDetector(
                  child: Icon(
                    Icons.email,
                    color: Colors.white,
                    size: 40,
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/mailcomposer');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openImagePicker() async {
    File pick = await ImagePicker.pickImage(source: ImageSource.gallery);
    final APIManager apiManager = Provider.of<APIManager>(context);
    final MyAuth myAuth = Provider.of<MyAuth>(context);

    await apiManager.uploadAndSaveProfilePic(
        user: myAuth.user, imageFile: pick.absolute);
    myAuth.profilePicChanged();
  }
}

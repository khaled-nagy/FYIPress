import 'package:NewsBuzz/app_localizations.dart';
import 'package:NewsBuzz/models/category.dart';
import 'package:NewsBuzz/models/country.dart';
import 'package:NewsBuzz/models/news_source.dart';
import 'package:NewsBuzz/models/user.dart';
import 'package:NewsBuzz/services/api_manager.dart';
import 'package:NewsBuzz/services/base_auth.dart';
import 'package:NewsBuzz/utility/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class CountryScreen extends StatefulWidget {
  final Function savedNewSources;

  const CountryScreen({this.savedNewSources});

  @override
  _CountryScreenState createState() => new _CountryScreenState();
}

class _CountryScreenState extends State<CountryScreen> {
  ListContent listContent = ListContent.countries;
  Country thePickedCountry;
  NewsSource thePickedSource;
  bool isLoading = false;

  _onAddTap(Country country, NewsSource source, int index) {
    print(country.sources.length);
    if (Provider.of<MyAuth>(context).user.isLoggedIn()) {
      CountryList theList = Provider.of<CountryList>(context);
      if (!theList.startedEditing) {
        theList.startEditing();
      }
      switch (listContent) {
        case ListContent.countries:
          final bool active = country.isActive;

          theList.toggleCountry(country, !active);

          break;
        case ListContent.sources:
          if (!theList.countriesEdited.contains(country)) {
            theList.startEditingCountry(country);
          }
          NewsSource source = country.sources[index];
          theList.toggleSource(source, !source.isActive);

          break;
        case ListContent.categories:
          SourceCategory cat = source.categories[index];
          theList.toggleCategory(cat, !cat.isActive);
          if (!theList.sourcesEdited.contains(source)) {
            theList.startEditingCategoriesFor(source);
          }
          break;
      }
    } else {
      _goToLogin();
    }
  }

  _handleSaveTap() async {
    setState(() {
      isLoading = true;
    });

    APIManager apiManager = Provider.of<APIManager>(context);
    User user = Provider.of<MyAuth>(context).user;
    if (apiManager.countryList.countries
            .where((c) => c.isActive)
            .toList()
            .length >
        4) {
      await apiManager.sendSourcesChanges(user);
      Provider.of<CountryList>(context).clearAllEdits();
      setState(() {
        isLoading = false;
      });
      widget.savedNewSources();
      Navigator.pop(context);
    } else {
      setState(() {
        isLoading = false;
      });
      _showAlert(AppLocalizations.of(context).translate('5 country warning'));
    }
  }

  _handleTileTap(int index, NewsSource source) async {
    User user = Provider.of<MyAuth>(context).user;
    var countryList = Provider.of<CountryList>(context);
    switch (listContent) {
      case ListContent.countries:
        setState(() {
          isLoading = true;
        });
        if (countryList.countries[index].sources.isEmpty) {
          var sources = await Provider.of<APIManager>(context)
              .getSourcesForCountry(countryList.countries[index], user);
          print(sources.length);
          countryList.setSourcesForCountry(
              countryList.countries[index], sources);
        }
        thePickedCountry = countryList.countries[index];
        setState(() {
          listContent = ListContent.sources;
          isLoading = false;
        });
        break;
      case ListContent.sources:
        print(source.name + ' ' + source.categories.length.toString());
        if (source.categories.isNotEmpty) {
          thePickedSource = source;
          setState(() {
            listContent = ListContent.categories;
          });
        }
        break;
      case ListContent.categories:
        break;
    }
  }

  _showAlert(String title) {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text(title),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  'Ok',
                  style: TextStyle(color: kAppBarPrimaryColor),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  _goToLogin() {
    Navigator.pushNamed(context, '/2');
  }

  CircleAvatar _loadAvatar(url) {
    try {
      return new CircleAvatar(
        backgroundColor: Colors.transparent,
        backgroundImage: NetworkImage(url),
        radius: 40.0,
      );
    } catch (e) {
      print(e);
      return new CircleAvatar(
        child: new Icon(Icons.library_books),
        radius: 40.0,
      );
    }
  }

  int _itemCount(List countrylist) {
    switch (listContent) {
      case ListContent.countries:
        return countrylist.length;
        break;
      case ListContent.sources:
        return thePickedCountry.sources.length;
        break;
      case ListContent.categories:
        return thePickedSource.categories.length;
        break;
      default:
        return 0;
        break;
    }
  }

  String _nameOfTile(Country country, int index) {
    switch (listContent) {
      case ListContent.countries:
        return country.nameAr.isEmpty ? country.nameEn : country.nameAr;
        break;
      case ListContent.sources:
        return thePickedCountry.sources[index].name;
        break;
      case ListContent.categories:
        return thePickedSource.categories[index].localizedName;
        break;
      default:
        return '';
        break;
    }
  }

  String _urlOfAvatar(Country country, int index) {
    switch (listContent) {
      case ListContent.countries:
        return country.flagUrl;
        break;
      case ListContent.sources:
        return thePickedCountry.sources[index].logoUrl;
        break;
      case ListContent.categories:
        return thePickedSource.categories[index].thumbUrl;
        break;
      default:
        return 'http://www.stleos.uq.edu.au/wp-content/uploads/2016/08/image-placeholder.png';
        break;
    }
  }

  bool _checkIfActive(Country country, int index) {
    switch (listContent) {
      case ListContent.countries:
        return country.isActive;
        break;
      case ListContent.sources:
        return thePickedCountry.sources[index].isActive;
        break;
      case ListContent.categories:
        return thePickedSource.categories[index].isActive;
        break;
      default:
        return false;
        break;
    }
  }

  String _screenTitle() {
    switch (listContent) {
      case ListContent.countries:
        return AppLocalizations.of(context).translate('countries');
        break;
      case ListContent.sources:
        return thePickedCountry.nameAr;
        break;
      case ListContent.categories:
        return thePickedSource.name;
        break;
      default:
        return '';
        break;
    }
  }

  setActiveCountries() async {
    APIManager apiManager = Provider.of<APIManager>(context);
    User user = Provider.of<MyAuth>(context).user;

    List<Country> countries = await apiManager.getCountries(user);
    Provider.of<CountryList>(context).setCountries(countries);
  }

  bool _handleBackPressed() {
    switch (listContent) {
      case ListContent.countries:
        return true;
        break;
      case ListContent.sources:
        thePickedCountry = null;
        setState(() {
          listContent = ListContent.countries;
        });
        return false;
        break;
      case ListContent.categories:
        thePickedSource = null;
        setState(() {
          listContent = ListContent.sources;
        });
        return false;
        break;
      default:
        return true;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool loggedIn = Provider.of<MyAuth>(context).user.isLoggedIn();

    return Consumer<CountryList>(
      builder: (context, countrylist, _) {
        final activeCountries =
            countrylist.countries?.where((c) => c.isActive)?.toList();
        if (countrylist.countries == null ||
            (loggedIn && (activeCountries?.isEmpty ?? false))) {
          setActiveCountries();
        }

        return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                _screenTitle(),
                style: TextStyle(fontSize: 22),
              ),
//              leading: Padding(
//                  padding: EdgeInsets.only(left: 10),
//                  child: IconButton(
//                    icon: Icon(Icons.arrow_back_ios),
//                    color: kIconPrimaryColor,
//                    onPressed: () {
//                      Navigator.pop(context);
//                    },
//                  )),
              actions: <Widget>[
                if (listContent == ListContent.sources ||
                    listContent == ListContent.categories) ...[
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: kIconPrimaryColor,
                      size: 30,
                    ),
                    padding: EdgeInsets.only(right: 40, top: 2),
                    onPressed: () {
                      _handleBackPressed();
                    },
                  )
                ],
                IconButton(
                  icon: Icon(
                    Icons.save,
                    color: kIconPrimaryColor,
                    size: 40,
                  ),
                  padding: EdgeInsets.only(right: 30),
                  onPressed: () {
                    _handleSaveTap();
                  },
                ),
              ],
            ),
            backgroundColor: Colors.grey[200],
            body: countrylist.countries == null || isLoading
                ? const Center(child: const CircularProgressIndicator())
                : listContent == ListContent.countries
                    ? countryGrid(countrylist)
                    : sourcesListView(countrylist));
      },
    );
  }

  GridView countryGrid(CountryList countrylist) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, mainAxisSpacing: 25.0),
      padding: const EdgeInsets.all(10.0),
      itemCount: _itemCount(countrylist.countries),
      itemBuilder: (context, index) {
        return GridTile(
          footer: new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Flexible(
                  child: new SizedBox(
                    height: 35.0,
                    width: 100.0,
                    child: new Text(
                      _nameOfTile(countrylist.countries[index], index) ?? '',
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
              ]),
          child: new Container(
            height: 500.0,
            padding: const EdgeInsets.only(bottom: 5.0),
            child: new GestureDetector(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  new SizedBox(
                    height: 100.0,
                    width: 100.0,
                    child: new Row(
                      children: <Widget>[
                        new Stack(
                          children: <Widget>[
                            new SizedBox(
                              child: new Container(
                                child: _loadAvatar(_urlOfAvatar(
                                        countrylist.countries[index], index) ??
                                    'http://www.stleos.uq.edu.au/wp-content/uploads/2016/08/image-placeholder.png'),
                                padding: const EdgeInsets.only(
                                    left: 10.0,
                                    top: 12.0,
                                    right: 10.0,
                                    bottom: 10),
                              ),
                            ),
                            new Positioned(
                              right: 0.0,
                              child: new GestureDetector(
                                child: _checkIfActive(
                                        countrylist.countries[index], index)
                                    ? new Icon(
                                        Icons.check_circle,
                                        color: Colors.greenAccent[700],
                                      )
                                    : new Icon(
                                        Icons.add_circle_outline,
                                        color: Colors.grey[500],
                                      ),
                                onTap: () {
                                  _onAddTap(countrylist.countries[index], null,
                                      index);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              onTap: () {
                thePickedCountry = countrylist.countries[index];
                _handleTileTap(index, null);
              },
            ),
          ),
        );
      },
    );
  }

  ListView sourcesListView(CountryList countrylist) {
    return ListView.separated(
      padding: const EdgeInsets.all(5.0),
      itemCount: _itemCount(countrylist.countries),
      separatorBuilder: (_, index) => Divider(
        thickness: 1,
      ),
      itemBuilder: (context, index) {
        Country country = thePickedCountry;
        return ListTile(
          onTap: () {
            _handleTileTap(
                index,
                listContent == ListContent.sources
                    ? thePickedCountry.sources[index]
                    : null);
          },
          trailing: Container(
            width: 65,
            child: Image.network(
              _urlOfAvatar(country, index),
              fit: BoxFit.cover,
            ),
            padding: const EdgeInsets.only(left: 10.0, top: 12.0),
          ),
          title: Text(
            _nameOfTile(thePickedCountry, index) ?? '',
            maxLines: 2,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          leading: sourceAddButton(index),
        );
      },
    );
  }

  Container sourceAddButton(int index) {
    final bool active = _checkIfActive(thePickedCountry, index);
    return Container(
        width: 100,
        height: 40,
        decoration: BoxDecoration(
            border: Border.all(color: kIconPrimaryColor),
            borderRadius: BorderRadius.circular(10),
            color: active ? kIconPrimaryColor : Colors.transparent),
        child: FlatButton(
          color: Colors.transparent,
          child: Row(
            children: <Widget>[
              Icon(
                active ? Icons.clear : Icons.add,
                color: active ? Colors.black : kIconPrimaryColor,
              ),
              SizedBox(width: 5),
              Text(
                active
                    ? AppLocalizations.of(context).translate('remove')
                    : AppLocalizations.of(context).translate('add'),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          onPressed: () {
            _onAddTap(
                thePickedCountry,
                listContent == ListContent.categories ? thePickedSource : null,
                index);
          },
        ));
  }
}

enum ListContent { countries, sources, categories }

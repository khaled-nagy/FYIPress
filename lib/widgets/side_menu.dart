import 'package:NewsBuzz/app_localizations.dart';
import 'package:NewsBuzz/models/country.dart';
import 'package:NewsBuzz/models/news_category.dart';
import 'package:NewsBuzz/models/user.dart';
import 'package:NewsBuzz/services/api_manager.dart';
import 'package:NewsBuzz/services/base_auth.dart';
import 'package:NewsBuzz/utility/constants.dart';
import 'package:NewsBuzz/widgets/restart_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:NewsBuzz/widgets/my_scaffold.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auto_size_text/auto_size_text.dart';

class SideMenu extends StatelessWidget {
  final Function(int) itemSelected;
  final Function profilePicClicked;
  final String guest = 'guest';

  SideMenu({@required this.itemSelected, @required this.profilePicClicked});

  final categoriesList = [
    NewsCategory(arName: 'الأخبار العاجلة', enName: 'Breaking News'),
    NewsCategory(arName: 'أخبار', enName: 'News'),
    NewsCategory(arName: 'رياضة', enName: 'Sports'),
    NewsCategory(arName: 'فن', enName: 'Arts'),
    NewsCategory(arName: 'تكنولوجيا', enName: 'Technology'),
    NewsCategory(arName: 'ثقافة عامة', enName: 'Culture'),
    NewsCategory(arName: 'اقتصاد', enName: 'Economy'),
    NewsCategory(arName: 'صحة', enName: 'Health'),
    NewsCategory(arName: 'الدول', enName: 'countries'),
  ];

  @override
  Widget build(BuildContext context) {
    MenuTypes menuType = Provider.of<MenuType>(context).menuType;
    final APIManager apiManager = Provider.of<APIManager>(context);
    final bool rightToLeft = apiManager.languageDirection == 'right';
    return Consumer<MyAuth>(
      builder: (context, myAuth, _) => ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: rightToLeft
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: <Widget>[
                GestureDetector(
                  child: userImage(myAuth.user, context),
                  onTap: () {
                    if (myAuth.user.isLoggedIn()) {
                      profilePicClicked();
                    }
                  },
                ),
                AutoSizeText(
                  AppLocalizations.of(context).translate('hello') +
                      (myAuth.user.isLoggedIn()
                          ? myAuth.user.username
                          : AppLocalizations.of(context).translate(guest)),
                  maxLines: 1,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            decoration: BoxDecoration(
              color: kAppBarPrimaryColor,
            ),
          ),
          if (menuType == MenuTypes.list) ...[
            menuTile(
                title: AppLocalizations.of(context).translate('home'),
                onTap: () {
                  Navigator.pop(context);
                  itemSelected(0);
                    Provider.of<APIManager>(context)
                        .toggleArticleType(type: ArticleType.server);
                },
                rightToLeft: rightToLeft),
            menuTile(
                title: AppLocalizations.of(context).translate('sources'),
                onTap: () {
                  Navigator.pop(context);
                  itemSelected(1);
                },
                rightToLeft: rightToLeft),
//          menuTile(
//              icon: Icons.bookmark,
//              title: '    Bookmarks',
//              onTap: () {
//                Navigator.pop(context);
//                itemSelected(2);
//              }),
            menuTile(
                title: AppLocalizations.of(context).translate('my sources'),
                onTap: () {
                  Navigator.pop(context);
                  itemSelected(2);
                },
                rightToLeft: rightToLeft),
            menuTile(
                title: AppLocalizations.of(context).translate('categories'),
                onTap: () {
                  Navigator.pop(context);
                  itemSelected(4);
                },
                rightToLeft: rightToLeft),
            menuTile(
                title: AppLocalizations.of(context).translate('contact us'),
                onTap: () {
                  Navigator.popAndPushNamed(context, '/mailcomposer');
                },
                rightToLeft: rightToLeft),
            menuTile(
                title: myAuth.user.isLoggedIn()
                    ? AppLocalizations.of(context).translate('log out')
                    : AppLocalizations.of(context).translate('log in'),
                onTap: () {
                  if (myAuth.user.isLoggedIn()) {
                    Navigator.pop(context);
                    itemSelected(5);
                  } else {
                    Navigator.pop(context);
                    itemSelected(3);
                  }
                },
                rightToLeft: rightToLeft),
          ],
          if (menuType == MenuTypes.language) ...[
            languageTile(
                'العربية', languageTileTapped(context, 'ar'), rightToLeft),
            languageTile(
                'English', languageTileTapped(context, 'en'), rightToLeft),
            languageTile(
                'Turkish', languageTileTapped(context, 'tu'), rightToLeft),
            languageTile(
                'Urdu', languageTileTapped(context, 'ur'), rightToLeft),
            languageTile(
                'Spanish', languageTileTapped(context, 'sp'), rightToLeft),
            languageTile(
                'Russian', languageTileTapped(context, 'ru'), rightToLeft),
            languageTile(
                'Japanese', languageTileTapped(context, 'jp'), rightToLeft),
            languageTile(
                'Indian', languageTileTapped(context, 'hi'), rightToLeft),
            languageTile(
                'German', languageTileTapped(context, 'ge'), rightToLeft),
            languageTile(
                'French', languageTileTapped(context, 'fr'), rightToLeft),
            languageTile(
                'Chinese', languageTileTapped(context, 'ch'), rightToLeft),
            languageTile(
                'Hebrew', languageTileTapped(context, 'he'), rightToLeft),
          ],
          if (menuType == MenuTypes.categories)
            ...categoriesList.map(
              (c) {
                User user = Provider.of<MyAuth>(context).user;
                CountryList countryList = Provider.of<CountryList>(context);
                if (c.enName == 'countries') {
                  if (countryList.countries == null) {
                    apiManager.getCountries(user);
                    return SizedBox();
                  }
                  return ExpansionTile(
                    title: Text(
                      AppLocalizations.of(context).translate(c.enName),
                      textAlign: rightToLeft ? TextAlign.right : TextAlign.left,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    children: countryList.countries?.map((c) {
                          return languageTile(
                              c.nameAr.isEmpty ? c.nameEn : c.nameAr, () {
                            Navigator.pop(context);
                            apiManager.clearArticles();
                            apiManager.getCountryArticles(
                                page: 1, country: c, user: user);
                          }, rightToLeft);
                        })?.toList() ??
                        [],
                  );
                }

                if (c.enName == 'Breaking News') {
                  return languageTile(
                      AppLocalizations.of(context).translate(c.enName), () {
                    Navigator.pop(context);
                    apiManager.clearArticles();
                    apiManager.getBreakingNews(page: 1, user: user);
                  }, rightToLeft);
                }

                return languageTile(
                  AppLocalizations.of(context).translate(c.enName),
                  () {
                    Navigator.pop(context);
                    apiManager.clearArticles();
                    apiManager.currentCategory = c.enName;
                    apiManager.getArticles(page: 1, user: user);
                  },
                  rightToLeft,
                );
              },
            ).toList()
        ],
      ),
    );
  }

  Function languageTileTapped(BuildContext context, String language) {
    return () async {
      Provider.of<APIManager>(context)
          .changeLanguage(language, Provider.of<MyAuth>(context).user);
      Provider.of<MyAuth>(context).language = language;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('language', language);
      RestartWidget.restartApp(context);
    };
  }

  Widget userImage(User user, BuildContext context) {
    final APIManager apiManager = Provider.of<APIManager>(context);

    if (apiManager.uploadingProfilePic) {
      return CircularProgressIndicator();
    } else if (user.imageUrl == null) {
      return Icon(
        Icons.person_pin,
        size: 75,
        color: Colors.white,
      );
    } else {
      return CircleAvatar(
        backgroundColor: Colors.transparent,
        backgroundImage: NetworkImage(
          user.imageUrl,
        ),
        radius: 45,
      );
    }
  }

  Widget languageTile(String title, Function onTap, bool rightToLeft) {
    return ListTile(
      title: Text(
        title,
        textAlign: rightToLeft ? TextAlign.right : TextAlign.left,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      onTap: onTap,
    );
  }

  ListTile menuTile(
      {IconData icon,
      String title,
      Function onTap,
      @required bool rightToLeft}) {
    return ListTile(
      title: Text(
        title,
        textAlign: rightToLeft ? TextAlign.right : TextAlign.left,
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
      ),
      onTap: onTap,
    );
  }
}

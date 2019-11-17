import 'package:NewsBuzz/services/api_manager.dart';
import 'package:NewsBuzz/utility/constants.dart';
import 'package:NewsBuzz/widgets/side_menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyMainScaffold extends StatefulWidget {
  final Function(int) itemSelected;
  final Function profilePicClicked;
  final Widget body;
  final Function searchPressed;

  MyMainScaffold(
      {this.itemSelected,
      this.searchPressed,
      this.profilePicClicked,
      this.body});

  @override
  _MyMainScaffoldState createState() => _MyMainScaffoldState();
}

class _MyMainScaffoldState extends State<MyMainScaffold> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  MenuType type = MenuType();
  final double iconSize = 30;

  Scaffold myMainScaffold(
      Function(int) itemSelected, Function profilePicClicked, Widget body) {
    final APIManager apiManager = Provider.of<APIManager>(context);
    final bool rightToLeft = apiManager.languageDirection == 'right';

    return Scaffold(
        key: _scaffoldKey,
        endDrawer: rightToLeft
            ? Drawer(
                child: ChangeNotifierProvider<MenuType>.value(
                  value: type,
                  child: SideMenu(
                    itemSelected: itemSelected,
                    profilePicClicked: profilePicClicked,
                  ),
                ),
              )
            : null,
        drawer: rightToLeft
            ? null
            : Drawer(
                child: ChangeNotifierProvider<MenuType>.value(
                  value: type,
                  child: SideMenu(
                    itemSelected: itemSelected,
                    profilePicClicked: profilePicClicked,
                  ),
                ),
              ),
        appBar: AppBar(
          titleSpacing: 0.0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: GestureDetector(
                  child: Image.asset(
                    'images/fyipress.png',
                    height: 30,
                    width: 40,
                  ),
                  onTap: () {
                    Provider.of<APIManager>(context)
                        .toggleArticleType(type: ArticleType.server);
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 5),
                child: GestureDetector(
                  child: Image.asset(
                    'images/fyipress2.png',
                    height: 30,
                    width: 40,
                  ),
                  onTap: () {
                    Provider.of<APIManager>(context)
                        .toggleArticleType(type: ArticleType.admin);
                  },
                ),
              ),
            ],
          ),
          automaticallyImplyLeading: false,
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.search,
                size: iconSize,
                color: kIconPrimaryColor,
              ),
              padding: EdgeInsets.only(right: 10),
              onPressed: () {
                widget.searchPressed();
              },
            ),
            IconButton(
              icon: Icon(
                Icons.language,
                size: iconSize,
                color: kIconPrimaryColor,
              ),
              padding: EdgeInsets.only(right: 10),
              onPressed: () {
                type.changeType(MenuTypes.language);
                rightToLeft
                    ? _scaffoldKey.currentState.openEndDrawer()
                    : _scaffoldKey.currentState.openDrawer();
              },
            ),
            IconButton(
              icon: Icon(
                Icons.apps,
                size: iconSize,
                color: kIconPrimaryColor,
              ),
              padding: EdgeInsets.only(right: 10),
              onPressed: () {
                type.changeType(MenuTypes.list);
                rightToLeft
                    ? _scaffoldKey.currentState.openEndDrawer()
                    : _scaffoldKey.currentState.openDrawer();
              },
            ),
            IconButton(
              icon: Icon(
                Icons.menu,
                size: iconSize,
                color: kIconPrimaryColor,
              ),
              padding: EdgeInsets.only(right: 10),
              onPressed: () {
                type.changeType(MenuTypes.categories);
                rightToLeft
                    ? _scaffoldKey.currentState.openEndDrawer()
                    : _scaffoldKey.currentState.openDrawer();
              },
            ),
          ],
        ),
        body: body);
  }

  @override
  Widget build(BuildContext context) {
    return myMainScaffold(
        widget.itemSelected, widget.profilePicClicked, widget.body);
  }
}

class MenuType extends ChangeNotifier {
  MenuTypes menuType = MenuTypes.list;

  changeType(MenuTypes type) {
    menuType = type;
    notifyListeners();
  }
}

enum MenuTypes { list, language, categories }

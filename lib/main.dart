import 'package:NewsBuzz/app_localizations.dart';
import 'package:NewsBuzz/models/article.dart';
import 'package:NewsBuzz/screens/categories_screen.dart';
import 'package:NewsBuzz/screens/comments_screen.dart';
import 'package:NewsBuzz/screens/email_compose_screen.dart';
import 'package:NewsBuzz/screens/login_screen.dart';
import 'package:NewsBuzz/screens/add_reply_right_screen.dart';
import 'package:NewsBuzz/screens/my_sources_screen.dart';
import 'package:NewsBuzz/screens/reply_rights_screen.dart';
import 'package:NewsBuzz/screens/webview_screen.dart';
import 'package:NewsBuzz/services/api_manager.dart';
import 'package:NewsBuzz/utility/constants.dart';
import 'package:NewsBuzz/widgets/restart_widget.dart';
import 'package:flutter/material.dart';
import 'screens/HomeFeedScreen.dart';
import 'screens/country_screen.dart';
import 'package:provider/provider.dart';
import 'services/base_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  final MyAuth myAuth = MyAuth();
  final APIManager apiManager = APIManager();

  myAuth.getMyData();
  apiManager.setInitialLanguage();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(builder: (_) => apiManager),
        ChangeNotifierProvider(builder: (_) => apiManager.countryList),
        ChangeNotifierProvider(builder: (_) => myAuth),
      ],
      child: RestartWidget(
        child: MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: klanguages.map((lang) => Locale(lang)).toList(),
//          localeResolutionCallback: (locale, supportedLocales) {
          // Check if the current device locale is supported
//            for (var supportedLocale in supportedLocales) {
//              if (supportedLocale.languageCode == locale.languageCode &&
//                  supportedLocale.countryCode == locale.countryCode) {
//                return supportedLocale;
//              }
//            }
//
//            return supportedLocales.first;
//          },
          theme: ThemeData(
              backgroundColor: kbackgroundPrimaryColor,
              appBarTheme: AppBarTheme(
                color: kAppBarPrimaryColor,
              ),
              iconTheme: IconThemeData(
                color: kIconPrimaryColor,
              ),
              buttonTheme: ButtonThemeData(
                buttonColor: kIconPrimaryColor,
              ),
              fontFamily: 'jazeera'),
          routes: {
            '/': (_) => NewsBuzz(),
            '/1': (_) => CountryScreen(
                  savedNewSources: () {
                    apiManager.articles = null;
                    apiManager.getArticles(page: 1, user: myAuth.user);
                  },
                ),
            '/2': (_) => MySourcesScreen(),
            '/3': (_) => LoginSignUpPage(
                  onSignedIn: () {
                    apiManager.getCountries(myAuth.user);
                    apiManager.getArticles(page: 1, user: myAuth.user);
                  },
                ),
            '/4': (_) => CategoriesScreen(),
            '/comments': (_) => CommentsScreen(),
            '/webview': (_) => WebViewScreen(),
            '/replyright': (_) => ReplyRightsScreen(),
            '/addreplyright': (_) => AddReplyRightScreen(),
            '/mailcomposer': (_) => MailComposerScreen(),
          },
          initialRoute: '/',
        ),
      ),
    ),
  );
}

class NewsBuzz extends StatefulWidget {
  @override
  createState() => new NewsBuzzState();
}

class NewsBuzzState extends State<NewsBuzz>
    with SingleTickerProviderStateMixin {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  setupNotifs() async {
    print('SETTING UP NOTIFS');
    _firebaseMessaging
        .requestNotificationPermissions(IosNotificationSettings());
    _firebaseMessaging.configure(onMessage: (msg) {
      print('ON MESSAGE ---');
      print(msg.toString());
      return null;
    }, onResume: (msg) {
      print('ON RESUME --------');
      msg.keys.map((k) => print(k));
      Map<String, String> myData = msg['gcm.notification.data'];
      Article newArticle = Article(
          rank: myData['rank'], url: myData['link'], id: myData['news_id']);
      Navigator.pushNamed(context, '/webview', arguments: newArticle);
      return null;
    }, onLaunch: (msg) {
      print('ON LAUNCH ----------');
      msg.keys.map((k) => print(k));
      Map<String, String> myData = msg['gcm.notification.data'];
      Article newArticle = Article(
          rank: myData['rank'], url: myData['link'], id: myData['news_id']);
      Navigator.pushNamed(context, '/webview', arguments: newArticle);
      return null;
    });
    var token = await _firebaseMessaging.getToken();
    print('TOKEN IS $token');
  }

  @override
  Widget build(BuildContext context) {
    setupNotifs();
    print('BUILD NEWS BUZZ');
    return HomeFeedScreen();
  }
}

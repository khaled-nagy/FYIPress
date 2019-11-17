import 'package:NewsBuzz/models/article.dart';
import 'package:NewsBuzz/models/category.dart';
import 'package:NewsBuzz/models/comment.dart';
import 'package:NewsBuzz/models/country.dart';
import 'package:NewsBuzz/models/reply_right.dart';
import 'package:NewsBuzz/models/news_source.dart';
import 'package:NewsBuzz/models/user.dart';
import 'package:NewsBuzz/services/base_api.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class APIManager extends ChangeNotifier with BaseApi {
  ArticleList articles;
  bool showingAdminNews = false;
  bool showingBreakingNews = false;
  bool uploadingProfilePic = false;
  CountryList countryList = CountryList();

  bool countriesLoading = false;
  bool articlesLoading = false;
  bool hotArticlesLoading = false;

  String currentCategory = 'News';
  String language;
  String get languageDirection {
    return ['ar', 'ur', 'he'].contains(language) ? 'right' : 'left';
  }

  changeLanguage(String lang, User user) {
    language = lang;
    clearArticles();
    getArticles(page: 1, user: user);
  }

  setInitialLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String lang = prefs.getString('language') ?? 'ar';
    language = lang;
  }

  Future getArticles({int page, int limit = 10, User user}) async {
    if (articlesLoading) {
      return;
    }

    if (language == null) {
      await setInitialLanguage();
    }

    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      articlesLoading = true;
      final response = await postRequest(
        action: 'get_category_news',
        params: <String, String>{
          'page': page.toString(),
          'category': currentCategory,
          'limit': limit.toString(),
        },
        user: user,
        timeStamp: timeStamp,
        lang: language,
        emailIncluded: user?.isLoggedIn() ?? false,
      );

      if (this.articles == null) {
        this.articles = ArticleList();
      }
      List<Article> newArticles = [];
      response['news'].forEach((article) {
        final newArticle = Article.fromMap(article);
        newArticles.add(newArticle);
      });

      this.articles.setNewArticles(newArticles, response['all_pages']);
      showingBreakingNews = false;
      notifyListeners();
      articlesLoading = false;
    } catch (e) {
      articlesLoading = false;
      throw e;
    }
  }

  Future getBreakingNews(
      {int page, int limit = 10, User user, String category = 'News'}) async {
    if (articlesLoading) {
      return;
    }

    if (language == null) {
      await setInitialLanguage();
    }

    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      articlesLoading = true;
      final response = await postRequest(
        action: 'breaking_news',
        params: <String, String>{
          'page': page.toString(),
          'limit': limit.toString(),
        },
        user: user,
        timeStamp: timeStamp,
        lang: language,
        emailIncluded: user?.isLoggedIn() ?? false,
      );

      if (this.articles == null) {
        this.articles = ArticleList();
      }
      List<Article> newArticles = [];
      response['news'].forEach((article) {
        final newArticle = Article.fromMap(article);
        newArticles.add(newArticle);
      });

      this.articles.setNewArticles(newArticles, response['all_pages']);
      showingBreakingNews = true;
      notifyListeners();
      articlesLoading = false;
    } catch (e) {
      articlesLoading = false;
      throw e;
    }
  }

  Future<List<Country>> getCountries(User user) async {
    if (countriesLoading) {
      return null;
    }

    if (language == null) {
      await setInitialLanguage();
    }

    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
    try {
      countriesLoading = true;
      final response = await postRequest(
        action: 'get_countries',
        params: <String, String>{},
        user: user,
        timeStamp: timeStamp,
        lang: language,
        emailIncluded: user.isLoggedIn(),
      );

      List<Country> newCountries = [];
      response['countries'].forEach((country) {
        final newCountry = Country.fromMap(country);
        newCountries.add(newCountry);
      });
      countriesLoading = false;
      countryList.setCountries(newCountries);
      return newCountries;
    } catch (e) {
      countriesLoading = false;
      throw e;
    }
  }

  toggleArticleType({ArticleType type}) {
    showingAdminNews = type == ArticleType.admin;
    notifyListeners();
  }

  Future getCountryArticles(
      {int page,
      int limit = 10,
      Country country,
      User user,
      String category = 'News'}) async {
    if (articlesLoading) {
      return;
    }

    if (language == null) {
      await setInitialLanguage();
    }

    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      articlesLoading = true;
      final response = await postRequest(
        action: 'country_news',
        params: <String, String>{
          'page': page.toString(),
          'country': country.nameEn,
          'limit': limit.toString(),
        },
        user: user,
        timeStamp: timeStamp,
        lang: language,
        emailIncluded: user?.isLoggedIn() ?? false,
      );

      if (this.articles == null) {
        this.articles = ArticleList();
      }

      List<Article> newArticles = [];
      response['news'].forEach((article) {
        final newArticle = Article.fromMap(article);
        newArticles.add(newArticle);
      });

      this.articles.setNewArticles(newArticles, response['all_pages']);
      notifyListeners();
      articlesLoading = false;
    } catch (e) {
      articlesLoading = false;
      throw e;
    }
  }

  Future<SlideShowData> getHotArticles(User user) async {
    if (hotArticlesLoading) {
      return null;
    }

    if (language == null) {
      await setInitialLanguage();
    }

    hotArticlesLoading = true;
    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      final response = await postRequest(
        action: 'slideshow',
        params: <String, String>{
          'limit': '10',
        },
        user: user,
        timeStamp: timeStamp,
        lang: language,
        emailIncluded: user.isLoggedIn(),
      );

      if (response['slideshow'] != null) {
        List<Article> results = [];
        response['slideshow'].forEach((article) {
          final newArticle = Article.fromMap(article);
          results.add(newArticle);
        });
        hotArticlesLoading = false;
        return SlideShowData(
            articles: results, duration: response['duration'] ?? 2500);
      } else {
        hotArticlesLoading = false;
        throw 'Results are null!';
      }
    } catch (e) {
      hotArticlesLoading = false;
      throw e;
    }
  }

  List<Country> getActiveCountries() {
    return countryList.countries.where((c) => c.isActive)?.toList();
  }

  Future<List<NewsSource>> getSourcesForCountry(
      Country country, User user) async {
    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();

    if (language == null) {
      await setInitialLanguage();
    }

    try {
      final response = await postRequest(
        action: 'get_country_sources',
        params: <String, String>{'country': country.nameEn},
        user: user,
        timeStamp: timeStamp,
        lang: language,
        emailIncluded: true,
      );

      List<NewsSource> sources = [];
      response['sources'].forEach((source) {
        final newSource = NewsSource.fromMap(source);
        sources.add(newSource);
      });

      return sources;
    } catch (e) {
      throw e;
    }
  }

  Future<String> setActiveCountries(List<Country> countries, User user) async {
    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();

    if (language == null) {
      await setInitialLanguage();
    }

    if (!user.isLoggedIn()) {
      throw 'Please login to perform this action.';
    }

    if (countries.length < 5) {
      throw 'You must select at least 5 countries';
    }

    String countriesString = '';
    countries
        .forEach((c) => countriesString = countriesString + '${c.nameEn},');
    countriesString = countriesString.substring(0, countriesString.length - 1);
    try {
      final response = await postRequest(
        action: 'change_source_countries',
        params: <String, String>{'countries': countriesString},
        user: user,
        timeStamp: timeStamp,
        lang: language,
        emailIncluded: true,
      );

      this.countryList.countries.forEach((c) {
        var check = countries.where((country) => country.nameEn == c.nameEn);
        c.isActive = check.isNotEmpty;
      });
      notifyListeners();
      return response['message'];
    } catch (e) {
      throw e;
    }
  }

  Future<String> setSourcesForCountry(
      Country country, List<NewsSource> sources, User user) async {
    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();

    if (language == null) {
      await setInitialLanguage();
    }

    if (!user.isLoggedIn()) {
      throw 'Please login to perform this action.';
    }

    String sourcesString = '';
    sources.forEach((s) => sourcesString = sourcesString + '${s.name},');
    if (sources.isNotEmpty) {
      sourcesString = sourcesString.substring(0, sourcesString.length - 1);
    } else {
      sourcesString = '';
    }

    try {
      final response = await postRequest(
        action: 'change_country_sources',
        params: <String, String>{
          'country': country.nameEn,
          'user_sources': sourcesString,
        },
        user: user,
        timeStamp: timeStamp,
        lang: language,
        emailIncluded: true,
      );

      int countryIndex = countryList.countries.indexOf(country);
      countryList.countries[countryIndex].sources.forEach((source) {
        var check = sources.where((s) => s.name == source.name);
        source.isActive = check.isNotEmpty;
      });
      notifyListeners();
      return response['message'];
    } catch (e) {
      throw e;
    }
  }

  Future<String> setCategoriesForSource(Country country, NewsSource source,
      List<SourceCategory> categories, User user) async {
    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();

    if (language == null) {
      await setInitialLanguage();
    }

    if (!user.isLoggedIn()) {
      throw 'Please login to perform this action.';
    }

    String categoriesString = '';
    categories
        .forEach((c) => categoriesString = categoriesString + '${c.name},');
    if (categories.isNotEmpty) {
      categoriesString =
          categoriesString.substring(0, categoriesString.length - 1);
    } else {
      categoriesString = '';
    }

    try {
      final response = await postRequest(
        action: 'change_source_categories',
        params: <String, String>{
          'country': country.nameEn,
          'source': source.name,
          'categories': categoriesString,
        },
        user: user,
        timeStamp: timeStamp,
        lang: language,
        emailIncluded: true,
      );

      int countryIndex = countryList.countries.indexOf(country);
      int sourceIndex =
          countryList.countries[countryIndex].sources.indexOf(source);
      countryList.countries[countryIndex].sources[sourceIndex].categories
          .forEach((category) {
        var check = categories.where((c) => c.name == source.name);
        category.isActive = check.isNotEmpty;
      });
      notifyListeners();
      return response['message'];
    } catch (e) {
      throw e;
    }
  }

  Future sendSourcesChanges(User user) async {
    if (language == null) {
      await setInitialLanguage();
    }

    if (countryList.startedEditing) {
      await setActiveCountries(
          countryList.countries.where((c) => c.isActive).toList(), user);
      for (Country country in countryList.countries) {
        if (country.sources.isNotEmpty) {
          if (countryList.countriesEdited.isNotEmpty) {
            for (Country country in countryList.countriesEdited) {
              var activeSources =
                  country.sources.where((s) => s.isActive).toList();
              await setSourcesForCountry(country, activeSources, user);
            }
          }

          if (countryList.sourcesEdited.isNotEmpty) {
            for (NewsSource source in countryList.sourcesEdited) {
              var activeCats =
                  source.categories.where((c) => c.isActive).toList();
              await setCategoriesForSource(country, source, activeCats, user);
            }
          }
        }
      }
    }
  }

  Future<List<Article>> searchForArticles(
      String keyword, int page, User user) async {
    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();

    if (language == null) {
      await setInitialLanguage();
    }

    try {
      final response = await postRequest(
        action: 'search',
        params: <String, String>{
          'search_for': keyword,
          'page': page.toString(),
          'limit': '10',
        },
        user: user,
        timeStamp: timeStamp,
        lang: language,
        emailIncluded: user.isLoggedIn(),
      );

      if (response['result'] != null) {
        List<Article> results = [];
        response['result'].forEach((article) {
          final newArticle = Article.fromMap(article);
          results.add(newArticle);
        });
        return results;
      } else {
        throw 'Results are null!';
      }
    } catch (e) {
      throw e;
    }
  }

  Future<Article> getArticleByID(String id, User user, String rank) async {
    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();

    if (language == null) {
      await setInitialLanguage();
    }

    try {
      final response = await postRequest(
        action: 'get_single_news',
        params: <String, String>{
          'news_id': id,
          'rank': rank,
        },
        user: user,
        timeStamp: timeStamp,
        lang: language,
        emailIncluded: user.isLoggedIn(),
      );

      if (response['data'] != null) {
        Article newArticle = Article.fromMap(response['data']);
        if (response['data']['comments'] != null) {
          List<Comment> newComments = [];

          response['data']['comments'].forEach((c) {
            Comment com = Comment.fromMap(c);
            newComments.add(com);
          });
          newArticle.comments = newComments;
        }
        if (response['data']['right_of_reply'] != null) {
          List<ReplyRight> rights = [];
          response['data']['right_of_reply'].forEach((r) {
            ReplyRight right = ReplyRight.fromMap(r);
            rights.add(right);
          });
          newArticle.replyRights = rights;
        }
        return newArticle;
      } else {
        throw 'Article not found';
      }
    } catch (e) {
      throw e;
    }
  }

  clearArticles() {
    articles = null;
    notifyListeners();
  }

  Future<String> addComment(
      {String comment,
      String articleID,
      String rank,
      @required User user,
      String replyToID = '0'}) async {
    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();

    if (language == null) {
      await setInitialLanguage();
    }

    if (!user.isLoggedIn()) {
      throw 'Please login to perform this action.';
    }

    try {
      final response = await postRequest(
        action: 'add_comment',
        params: <String, String>{
          'news_id': articleID,
          'comment': comment,
          'media_url': '',
          'reply_to_comment': replyToID,
          'rank': rank
        },
        user: user,
        timeStamp: timeStamp,
        lang: language,
        emailIncluded: true,
      );

      return response['message'];
    } catch (e) {
      throw e;
    }
  }

  Future<String> reportCommentOrReply(
      {String articleID,
      bool isComment,
      String id,
      ReportReason reason,
      String rank,
      User user,
      String notes = ''}) async {
    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();

    if (language == null) {
      await setInitialLanguage();
    }

    if (!user.isLoggedIn()) {
      throw 'Please login to perform this action.';
    }

    String theReason;
    switch (reason) {
      case ReportReason.hateSpeech:
        theReason = 'Hate speech';
        break;
      case ReportReason.badWords:
        theReason = 'A bad words';
        break;
      case ReportReason.sexualContent:
        theReason = 'Sexual content';
        break;
      case ReportReason.violentContent:
        theReason = 'Violent content';
        break;
      case ReportReason.abuse:
        theReason = 'Abuse';
        break;
    }

    try {
      final response = await postRequest(
        action: 'report',
        params: <String, String>{
          'news_id': articleID,
          'comment_id': isComment ? id : '0',
          'reply_id': isComment ? '0' : id,
          'reason': theReason,
          'rank': rank,
          'other': notes,
        },
        user: user,
        timeStamp: timeStamp,
        lang: language,
        emailIncluded: true,
      );

      return response['message'];
    } catch (e) {
      throw e;
    }
  }

  Future<String> addRightToReply(
      {User user,
      String newsId,
      String title,
      String reply,
      String rank,
      String userImage,
      String replyImage,
      String phone = '',
      String messageToAdmin = ''}) async {
    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();

    if (language == null) {
      await setInitialLanguage();
    }

    if (!user.isLoggedIn()) {
      throw 'Please login to perform this action.';
    }

    try {
      final response = await postRequest(
        action: 'add_right_of_reply',
        params: <String, String>{
          'news_id': newsId,
          'reply': reply,
          'reply_title': title,
          'reply_to_link': '',
          'phone': phone,
          'rank': rank,
          'message': messageToAdmin,
          'user_image': userImage ?? '',
          'reply_image': replyImage ?? '',
        },
        user: user,
        timeStamp: timeStamp,
        lang: language,
        emailIncluded: true,
      );

      return response['message'];
    } catch (e) {
      throw e;
    }
  }

  Future<String> uploadImage({var imageFile, String reference}) async {
    print('Started uploading pic');
    StorageReference ref =
        FirebaseStorage.instance.ref().child(reference ?? Uuid().v1());
    StorageUploadTask uploadTask = ref.putFile(imageFile.absolute);

    var downurl = await (await uploadTask.onComplete).ref.getDownloadURL();
    String url = downurl.toString();

    return url;
  }

  Future<String> setUserImageUrl(String url, User user) async {
    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();

    if (!user.isLoggedIn()) {
      throw 'Please login to perform this action.';
    }

    if (language == null) {
      await setInitialLanguage();
    }

    try {
      final response = await postRequest(
        action: 'change_profile_pic',
        params: <String, String>{
          'url': url,
        },
        user: user,
        timeStamp: timeStamp,
        lang: language,
        emailIncluded: true,
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('image', user.imageUrl);

      return response['message'];
    } catch (e) {
      throw e;
    }
  }

  Future<String> uploadAndSaveProfilePic({User user, var imageFile}) async {
    uploadingProfilePic = true;
    notifyListeners();
    String url = await uploadImage(imageFile: imageFile, reference: user.email);

    if (language == null) {
      await setInitialLanguage();
    }

    if (url != null) {
      try {
        String response = await setUserImageUrl(url, user);
        user.imageUrl = url;
        uploadingProfilePic = false;
        notifyListeners();
        return response;
      } catch (e) {
        throw e;
      }
    } else {
      throw 'Error uploading profile picture';
    }
  }

  Future toggleSourceNotifications(
      {User user, Map<Country, List<NewsSource>> changes}) async {
    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();

    if (language == null) {
      await setInitialLanguage();
    }

    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

    if (!user.isLoggedIn()) {
      throw 'Please login to perform this action.';
    }

    changes.forEach((country, sourcesArray) async {
      String activeSources = '';
      sourcesArray.forEach((source) {
        if (source.notificationsActive) {
          activeSources = activeSources + source.name + ',';
          _firebaseMessaging.subscribeToTopic(source.topicName);
        } else {
          _firebaseMessaging.unsubscribeFromTopic(source.topicName);
        }
      });
      activeSources = activeSources.substring(0, activeSources.length - 1);

      try {
        final response = await postRequest(
          action: 'update_notification_sources',
          params: <String, String>{
            'country': country.nameEn,
            'sources': activeSources,
          },
          user: user,
          timeStamp: timeStamp,
          lang: language,
          emailIncluded: true,
        );

        return response['message'];
      } catch (e) {
        throw e;
      }
    });
  }

  Future getMyBookMarks() async {}

  Future bookmarkArticle(Article article) async {}

//  Future handleAfterSignIn() async {
//    clearArticles();
//    await getCountries();
//    await getArticles(page: 1);
//  }

  Future handleAfterSignOut() async {
    articles.clearData();
    getArticles(page: 1);
  }
}

enum ReportReason {
  hateSpeech,
  badWords,
  sexualContent,
  violentContent,
  abuse,
}

enum ArticleType {
  admin,
  server,
}

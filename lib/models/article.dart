import 'package:NewsBuzz/models/comment.dart';
import 'package:NewsBuzz/models/reply_right.dart';

class Article {
  bool bookMarked;
  final String id;
  final String commentCount;
  final String sourceLogo;
  final String sourceName;
  final String title;
  final String description;
  final String url;
  final String imageUrl;
  final DateTime publishedAt;
  final String rank;
  final String when;
  List<Comment> comments;
  List<ReplyRight> replyRights;

  Article(
      {this.id,
      this.bookMarked = false,
      this.sourceName,
      this.sourceLogo,
      this.commentCount,
      this.title,
      this.description,
      this.url,
      this.imageUrl,
      this.publishedAt,
      this.when,
      this.rank});

  factory Article.fromMap(Map v) {
    DateTime publishAt;
    try {
      publishAt = DateTime.tryParse(v['pubDate']);
    } catch (e) {
      print(e);
    }

    return Article(
        id: v['news_id']?.toString() ?? v['id'].toString() ?? '',
        sourceName: v['source'] ?? '',
        sourceLogo: v['source_logo'] ?? '',
        title: v['title'] ?? '',
        description: v['description'] ?? '',
        url: v['link'] ?? '',
        publishedAt: publishAt,
        imageUrl: v['image'],
        commentCount: v['comments_count']?.toString() ?? '',
        rank: v['rank']?.toString() ?? '2',
        when: v['when'] ?? '');
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'link': url,
      'image': imageUrl,
      'pubDate': publishedAt?.toIso8601String() ?? '0000',
      'source': sourceName,
      'source_logo': sourceLogo,
      'comments_count': commentCount,
      'rank': rank,
      'when': when,
    };
  }
}

class SlideShowData {
  final List<Article> articles;
  final int duration;

  SlideShowData({this.articles, this.duration});
}

class ArticleList {
  List<Article> articles;
  List<Article> adminArticles;
  int numberOfPages;

  ArticleList({this.articles, this.numberOfPages}) {
    adminArticles = articles?.where((a) => a.rank == '1')?.toList() ?? [];
  }

  setNewArticles(List<Article> articles, int pages) {
    if (this.articles == null) {
      this.articles = articles;
      adminArticles = articles?.where((a) => a.rank == '1')?.toList() ?? [];
      numberOfPages = pages;
    } else {
      this.articles.addAll(articles);
      adminArticles = articles?.where((a) => a.rank == '1')?.toList() ?? [];
    }
  }

  clearData() {
    articles = [];
    adminArticles = [];
    numberOfPages = null;
  }
}

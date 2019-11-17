import 'package:NewsBuzz/models/category.dart';

class NewsSource {
  final String name;
  final String nameAr;
  final String topicName;
  final String logoUrl;
  final String twitter;
  final String followers;
  final bool canSelect;
  bool notificationsActive;
  bool isActive;
  final List<SourceCategory> categories;

  NewsSource(
      {this.name,
      this.nameAr,
      this.topicName,
      this.twitter,
      this.followers,
      this.notificationsActive,
      this.canSelect,
      this.logoUrl,
      this.isActive,
      this.categories});

  factory NewsSource.fromMap(Map map) {
    List<SourceCategory> categories = [];
    if (map['types'] != null) {
      map['types'].forEach((t) => categories.add(SourceCategory.fromMap(t)));
    }
    return NewsSource(
        name: map['source'],
        nameAr: map['source_name'],
        topicName: map['topic_name'],
        twitter: map['twitter'],
        notificationsActive: map['notifications_from_this_source'] == 1,
        canSelect: map['can_select_as_source'] == 1,
        logoUrl: map['source_logo'],
        followers: map['followers'],
        isActive: map['is_source'] == 1,
        categories: categories);
  }
}

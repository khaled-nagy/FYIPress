class SourceCategory {
  final String name;
  final String localizedName;
  final String thumbUrl;
  bool isActive;

  SourceCategory({this.name, this.localizedName, this.thumbUrl, this.isActive});

  factory SourceCategory.fromMap(Map map) {
    return SourceCategory(
        name: map['name'],
        localizedName: map['ar_name'],
        thumbUrl: map['thumb'],
        isActive: map['is_source'] == '1');
  }
}

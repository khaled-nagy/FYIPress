import 'package:NewsBuzz/models/category.dart';
import 'package:NewsBuzz/models/news_source.dart';
import 'package:flutter/cupertino.dart';

class CountryList extends ChangeNotifier {
  List<Country> countries;
  bool startedEditing = false;
  List<Country> countriesEdited = [];
  List<NewsSource> sourcesEdited = [];

  startEditing() {
    startedEditing = true;
    notifyListeners();
  }

  endEditing() {
    startedEditing = false;
    notifyListeners();
  }

  startEditingCountry(Country country) {
    if (!countriesEdited.contains(country)) {
      countriesEdited.add(country);
      notifyListeners();
    }
  }

  startEditingCategoriesFor(NewsSource source) {
    if (!sourcesEdited.contains(source)) {
      sourcesEdited.add(source);
      notifyListeners();
    }
  }

  clearAllEdits() {
    startedEditing = false;
    countriesEdited.clear();
    sourcesEdited.clear();
    notifyListeners();
  }

  setCountries(List<Country> countries) {
    this.countries = countries;
    notifyListeners();
  }

  setSourcesForCountry(Country country, List<NewsSource> sources) {
    Country theCountry =
        countries?.where((c) => c.nameEn == country.nameEn)?.toList()?.first;

    if (theCountry != null) {
      theCountry.sources = sources;
      notifyListeners();
    }
  }

  toggleCountry(Country country, bool on) {
    if (country.isActive != on) {
      country.isActive = on;
      notifyListeners();
    }
  }

  toggleSource(NewsSource source, bool on) {
    if (source.isActive != on) {
      source.isActive = on;
      notifyListeners();
    }
  }

  toggleNotificationsForSource(NewsSource source, bool on) {
    if (source.notificationsActive != on) {
      source.notificationsActive = on;
      notifyListeners();
    }
  }

  toggleCategory(SourceCategory category, bool on) {
    if (category.isActive != on) {
      category.isActive = on;
      notifyListeners();
    }
  }
}

class Country {
  final String nameAr;
  final String nameEn;
  final String flagUrl;
  bool isActive;
  List<NewsSource> sources;
  List<NewsSource> get notificationSources => sources
      .where((s) => s.topicName != null && s.topicName.isNotEmpty)
      .toList();

  Country(
      {this.nameAr, this.nameEn, this.flagUrl, this.isActive, this.sources});

  factory Country.fromMap(Map map) {
    List<NewsSource> sources = [];
    if (map['sources'] != null) {
      map['sources']
          .forEach((source) => sources.add(NewsSource.fromMap(source)));
    }

    return Country(
      nameEn: map['name_en'],
      nameAr: map['name_ar'],
      flagUrl: map['flag'],
      isActive: map['is_source'] == 1,
      sources: sources,
    );
  }
}

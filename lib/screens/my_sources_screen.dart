import 'package:NewsBuzz/models/country.dart';
import 'package:NewsBuzz/models/news_source.dart';
import 'package:NewsBuzz/models/user.dart';
import 'package:NewsBuzz/services/api_manager.dart';
import 'package:NewsBuzz/services/base_auth.dart';
import 'package:NewsBuzz/utility/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MySourcesScreen extends StatefulWidget {
  @override
  _MySourcesScreenState createState() => _MySourcesScreenState();
}

class _MySourcesScreenState extends State<MySourcesScreen> {
  Map<Country, List<NewsSource>> notificationChanges =
      {}; // {'Egypt': [{'source': 'Youm7', 'topic': '', 'on': true},{}]}
  bool savingChanges = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('مصادري'),
        actions: <Widget>[
          if (notificationChanges.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.only(right: 12),
              child: IconButton(
                icon: Icon(
                  Icons.save,
                  size: 40,
                ),
                onPressed: () async {
                  if (mounted) {
                    setState(() {
                      savingChanges = true;
                    });
                  }
                  final APIManager apiManager =
                      Provider.of<APIManager>(context);
                  final User user = Provider.of<MyAuth>(context).user;
                  try {
                    final String response =
                        await apiManager.toggleSourceNotifications(
                            user: user, changes: notificationChanges);
                    print(response);
                    if (mounted) {
                      setState(() {
                        savingChanges = false;
                      });
                    }
                  } catch (e) {
                    print(e);
                    if (mounted) {
                      setState(() {
                        savingChanges = false;
                      });
                    }
                  }
                },
              ),
            )
          ]
        ],
      ),
      body: Consumer<CountryList>(
        builder: (c, countrylist, _) {
          if (countrylist.countries == null) {
            Provider.of<APIManager>(context)
                .getCountries(Provider.of<MyAuth>(context).user);
          }
          return countrylist.countries == null || savingChanges
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : ListView.builder(
                  itemCount: countrylist.countries?.length ?? 0,
                  itemBuilder: (_, index) {
                    Country country = countrylist.countries[index];
                    return ExpansionTile(
                      trailing: SizedBox(
                        height: 30,
                        width: 60,
                        child: Image.network(
                          country.flagUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Text(
                          country.nameAr,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      leading: Icon(Icons.keyboard_arrow_down),
                      children: <Widget>[
                        if (country.notificationSources.isEmpty) ...[
                          Container(
                            height: 150,
                            child: Center(child: CircularProgressIndicator()),
                          )
                        ] else
                          ...country.notificationSources.map((source) {
                            return sourceTile(country, source);
                          }).toList()
                      ],
                      onExpansionChanged: (expanded) async {
                        if (country.notificationSources.isEmpty) {
                          final List<NewsSource> sources =
                              await Provider.of<APIManager>(context)
                                  .getSourcesForCountry(country,
                                      Provider.of<MyAuth>(context).user);
                          countrylist.setSourcesForCountry(country, sources);
                        }
                      },
                    );
                  },
                );
        },
      ),
    );
  }

  Widget sourceTile(Country country, NewsSource source) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Text(
              source.nameAr,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 18),
            ),
          ),
          trailing: SizedBox(
            height: 30,
            width: 40,
            child: Image.network(
              source.logoUrl,
              fit: BoxFit.fitWidth,
            ),
          ),
          leading: sourceAddButton(
              active: source.notificationsActive,
              onPressed: (on) {
                Provider.of<CountryList>(context)
                    .toggleNotificationsForSource(source, on);
                setState(() {
                  if (notificationChanges[country]?.contains(source) ?? false) {
                    notificationChanges[country].remove(source);
                  }
                  if (notificationChanges[country] == null) {
                    notificationChanges[country] = [];
                  }
                  notificationChanges[country].add(source);
                  print(notificationChanges);
                });
              }),
        ),
        Divider(
          height: 1,
        )
      ],
    );
  }

  Container sourceAddButton({bool active, Function(bool) onPressed}) {
    return Container(
        width: 110,
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
                active ? Icons.clear : Icons.notifications,
                color: active ? Colors.black : kIconPrimaryColor,
              ),
              SizedBox(width: 5),
              Text(
                active ? 'الغاء' : 'تنبيه',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          onPressed: () => onPressed(!active),
        ));
  }
}

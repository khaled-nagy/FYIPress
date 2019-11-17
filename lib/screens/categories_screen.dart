import 'package:NewsBuzz/models/news_category.dart';
import 'package:NewsBuzz/services/api_manager.dart';
import 'package:NewsBuzz/services/base_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:NewsBuzz/app_localizations.dart' as local;

class CategoriesScreen extends StatelessWidget {
  final categoriesList = [
    NewsCategory(
        arName: 'الأخبار العاجلة',
        enName: 'Breaking News',
        imageName: 'breaking'),
    NewsCategory(arName: 'رياضة', enName: 'Sports', imageName: 'sport'),
    NewsCategory(arName: 'فن', enName: 'Arts', imageName: 'tv'),
    NewsCategory(arName: 'تكنولوجيا', enName: 'Technology', imageName: 'tech'),
    NewsCategory(arName: 'ثقافة عامة', enName: 'Culture', imageName: 'culture'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title:
              Text(local.AppLocalizations.of(context).translate('categories'))),
      body: StaggeredGridView.countBuilder(
        staggeredTileBuilder: (index) =>
            StaggeredTile.count(index == 0 ? 4 : 2, 2),
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        crossAxisCount: 4,
        itemCount: categoriesList.length,
        itemBuilder: (c, index) => GridTile(
          child: GestureDetector(
            child: FittedBox(
              fit: BoxFit.cover,
              child:
                  Image.asset('images/${categoriesList[index].imageName}.png'),
            ),
            onTap: () async {
              final APIManager apiManager = Provider.of<APIManager>(context);
              apiManager.clearArticles();
              apiManager.currentCategory = categoriesList[index].enName;
              apiManager.getArticles(
                page: 1,
                user: Provider.of<MyAuth>(context).user,
              );
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
}

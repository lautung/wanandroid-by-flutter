import 'package:flutter/material.dart';
import 'package:wanandroid_flutter/common/res/icons.dart';
import 'package:wanandroid_flutter/ui/page/page_collect_article.dart';
import 'package:wanandroid_flutter/ui/page/page_collect_website.dart';

class CollectPage extends StatefulWidget {
  @override
  _CollectPageState createState() => _CollectPageState();
}

class _CollectPageState extends State<CollectPage> {
  final tabs = ["文章", "网站"];

  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return  DefaultTabController(
      ///tab长度
      length: tabs.length,
      child: new Scaffold(
        appBar: new AppBar(
          title: new Text('我的收藏'),
          bottom: new TabBar(
            tabs: <Widget>[
              new Tab(
                icon: Icon(article,size: 32.0,),
              ),
              new Tab(
                icon: Icon(website,size: 32.0),
              ),
            ],
          ),
        ),
        body:  TabBarView(
          children: <Widget>[
            ArticleCollectPage(),
            WebsiteCollectPage(),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:wanandroid_flutter/ui/page/page_splash.dart';

void main() => runApp(new ArticleApp());

class ArticleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      routes: {
        '/': (context) => SplashPage(),
      },
    );
  }
}

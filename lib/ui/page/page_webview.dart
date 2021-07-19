import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:wanandroid_flutter/common/event/events.dart';
import 'package:wanandroid_flutter/common/http/api.dart';
import 'package:wanandroid_flutter/manager/app_manager.dart';
import 'package:wanandroid_flutter/ui/page/page_login.dart';

class WebViewPage extends StatefulWidget {
  final data;

  ///是否允許收藏
  final supportCollect;

  WebViewPage(this.data, {this.supportCollect = false});

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  bool isLoad = true;
  late FlutterWebviewPlugin flutterWebViewPlugin;

  @override
  void initState() {
    super.initState();

    flutterWebViewPlugin = new FlutterWebviewPlugin();
    flutterWebViewPlugin.onStateChanged.listen((state) {
      if (state.type == WebViewState.finishLoad) {
        // 加载完成
        setState(() {
          isLoad = false;
        });
      } else if (state.type == WebViewState.startLoad) {
        setState(() {
          isLoad = true;
        });
      }
    });
  }

  @override
  void dispose() {
    flutterWebViewPlugin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var isCollect = widget.data['collect']??false;

    ///WebView插件
    return WebviewScaffold(
        appBar: AppBar(
          title: Text(widget.data['title']),
          actions: <Widget>[
            Offstage(
              offstage: !widget.supportCollect,
              child: IconButton(
                icon: Icon(Icons.favorite,
                    color: isCollect
                        ? Colors.red
                        : Colors.white),
                onPressed: () => _collect(),
              ),
            )
          ],

          ///appbar下边摆放一个进度条
          bottom: PreferredSize(
              //提供一个希望的 大小
              preferredSize: const Size.fromHeight(1.0),
              //进度条
              child: const LinearProgressIndicator()),

          ///透明度
          bottomOpacity: isLoad ? 1.0 : 0.0,
        ),
        withLocalStorage: true, //缓存，数据存储
        url: widget.data['url'],
        withJavascript: true);
  }

  _collect() async {
    var result;
    bool isLogin =  AppManager.isLogin();
    if (isLogin) {
      if (widget.data['collect']) {
        result = await Api.unCollectArticle(widget.data['id']);
      } else {
        result = await Api.collectArticle(widget.data['id']);
      }
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => LoginPage()));
    }
    if (result['errorCode'] == 0) {
      setState(() {
        widget.data['collect'] = !widget.data['collect'];
        AppManager.eventBus.fire(CollectEvent(widget.data['id'],widget.data['collect']));
      });
    }
  }
}

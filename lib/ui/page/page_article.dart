import 'package:flutter/material.dart';
import 'package:banner_view/banner_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:wanandroid_flutter/common/event/events.dart';
import 'package:wanandroid_flutter/common/http/api.dart';
import 'package:wanandroid_flutter/manager/app_manager.dart';
import 'package:wanandroid_flutter/ui/page/page_webview.dart';
import 'package:wanandroid_flutter/ui/widget/article_item.dart';
import 'package:wanandroid_flutter/ui/widget/main_drawer.dart';

class ArticlePage extends StatefulWidget {
  @override
  _ArticlePageState createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  ///滑动控制器
  ScrollController _controller = new ScrollController();

  ///控制正在加载的显示
  bool _isLoading = true;

  ///请求到的文章数据
  List articles = [];

  ///banner图
  List banners = [];

  ///总文章数有多少
  var listTotalSize = 0;

  ///分页加载，当前页码
  var curPage = 0;

  late DateTime _lastClick;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      ///获得 SrollController 监听控件可以滚动的最大范围
      var maxScroll = _controller.position.maxScrollExtent;

      ///获得当前位置的像素值
      var pixels = _controller.position.pixels;

      ///当前滑动位置到达底部，同时还有更多数据
      if (maxScroll == pixels && articles.length < listTotalSize) {
        ///加载更多
        _getArticlelist();
      }
    });
    AppManager.eventBus.on<LoginEvent>().listen((event) {
      if (mounted) {
        setState(() {
          _pullToRefresh();
        });
      }
    });
    AppManager.eventBus.on<LogoutEvent>().listen((_) {
      if (mounted) {
        setState(() {
          _pullToRefresh();
        });
      }
    });
    AppManager.eventBus.on<CollectEvent>().listen((event) {
      ///页面没有被dispose
      if (mounted) {
        //收藏更新
        articles.every((item) {
          if (item['id'] == event.id) {
            item['collect'] = event.collect;
            return false;
          }
          return true;
        });
      }
    });
    _pullToRefresh();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _getArticlelist([bool update = true]) async {
    /// 请求成功是map，失败是null
    var data = await Api.getArticleList(curPage);
    if (data != null) {
      var map = data['data'];
      var datas = map['datas'];

      ///文章总数
      listTotalSize = map["total"];

      if (curPage == 0) {
        articles.clear();
      }
      curPage++;
      articles.addAll(datas);

      ///更新ui
      if (update) {
        setState(() {});
      }
    }
  }

  _getBanner([bool update = true]) async {
    var data = await Api.getBanner();
    if (data != null) {
      banners.clear();
      banners.addAll(data['data']);
      if (update) {
        setState(() {});
      }
    }
  }

  ///下拉刷新
  Future<void> _pullToRefresh() async {
    curPage = 0;
    Iterable<Future> futures = [_getArticlelist(), _getBanner()];
    await Future.wait(futures);
    _isLoading = false;
    setState(() {});
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          //在一定的时间内 2s点击两次才能返回
          if (_lastClick == null ||
              DateTime.now().difference(_lastClick) > Duration(seconds: 2)) {
            _lastClick = DateTime.now();
            Fluttertoast.showToast(msg: "请再按一次退出");
            return false;
          }
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              '文章',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          drawer: Drawer(
            child: MainDrawer(),
          ),
          body: Stack(
            children: <Widget>[
              ///正在加载
              Offstage(
                offstage: !_isLoading, //是否隐藏
                child: new Center(child: CircularProgressIndicator()),
              ),

              ///内容
              Offstage(
                offstage: _isLoading,
                child: new RefreshIndicator(
                    child: ListView.builder(
                      itemCount: articles.length + 1,
                      itemBuilder: (context, i) => _buildItem(i),
                      controller: _controller,
                    ),
                    onRefresh: _pullToRefresh),
              ),
              Offstage(
                offstage: _isLoading || articles.isNotEmpty, //是否隐藏
                child: new Center(
                    child: InkWell(
                  child: Text("(＞﹏＜) 点击重试......"),
                  onTap: () {
                    setState(() {
                      _isLoading = true;
                    });
                    _pullToRefresh();
                  },
                )),
              ),
            ],
          ),
        ));
  }

  Widget _buildItem(int i) {
    if (i == 0) {
      return new Container(
        height: 180.0,
        child: _bannerView(),
      );
    }
    var itemData = articles[i - 1];
    return new ArticleItem(itemData);
  }

  Widget? _bannerView() {
    var list = banners.map((item) {
      /// 能让我们快速添加各种触摸事件的一个Widget
      return InkWell(
        child: Image.network(item['imagePath'], fit: BoxFit.cover), //fit 图片充满容器
        ///点击事件
        onTap: () {
          ///跳转页面
          Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
            return WebViewPage(item);
          }));
        },
      );
    }).toList();
    return list.isNotEmpty
        ? BannerView(
            list,
            intervalDuration: const Duration(seconds: 3),
          )
        : null;
  }
}

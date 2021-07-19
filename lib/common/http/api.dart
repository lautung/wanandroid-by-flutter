import 'package:dio/dio.dart';
import 'package:wanandroid_flutter/common/http/http_manager.dart';
import 'package:wanandroid_flutter/manager/app_manager.dart';

typedef void OnResult(Map<String, dynamic> data);

class Api {
  static const String baseUrl = "https://www.wanandroid.com/";

  //首页文章列表 http://www.wanandroid.com/article/list/0/json
  static const String ARTICLE_LIST = "article/list/";

  static const String BANNER = "banner/json";

  //登录
  static const String LOGIN = "user/login";

  //注册
  static const String REGISTER = "user/register";

  //退出
  static const String LOGOUT = "user/logout/json";

  //收藏列表
  static const String COLLECT_ARTICLE_LIST = "lg/collect/list/";
  static const String COLLECT_WEBSITE_LIST = "lg/collect/usertools/json";

  //收藏站内
  static const String COLLECT_INTERNAL_ARTICLE = "lg/collect/";

  //取消收藏
  static const String UNCOLLECT_INTERNAL_ARTICLE = "lg/uncollect_originId/";

  static const String COLLECT_WEBSITE = "lg/collect/addtool/json";

  static const String UNCOLLECT_WEBSITE = "lg/collect/deletetool/json";

  static late HttpManager http;

  static init() async {
    http = HttpManager.getInstance();
    await http.init();
  }

  static getArticleList(int page) async {
    return await http.request('$ARTICLE_LIST$page/json');
  }

  static getBanner() async {
    return await http.request(BANNER);
  }

  static login(String username, String password) async {
    var formData = FormData.fromMap({
      "username": username,
      "password": password,
    });
    return await http.request(LOGIN, data: formData, method: "post");
  }

  static register(String username, String password) async {
    ///必须使用form表单提交
    var formData = FormData.fromMap(
        {"username": username, "password": password, "repassword": password});
    return await http
        .request(REGISTER, data: formData, method: "post");
  }

  static clearCookie() {
    http.clearCookie();
  }

  static getArticleCollects(int page) async {
    return await http.request("$COLLECT_ARTICLE_LIST/$page/json");
  }

  static getWebSiteCollects() async {
    return await http.request(COLLECT_WEBSITE_LIST);
  }

  static collectArticle(int id) async {
    return await http
        .request("$COLLECT_INTERNAL_ARTICLE$id/json", method: "post");
  }

  static unCollectArticle(int id) async {
    return await http
        .request("$UNCOLLECT_INTERNAL_ARTICLE$id/json", method: "post");
  }

  static collectWebsite(String name, String link) async {
    var formData = FormData.fromMap({"name": name, "link": link});
    return await http
        .request(COLLECT_WEBSITE, data: formData, method: "post");
  }

  static unCollectWebsite(int id) async {
    var formData = FormData.fromMap({"id": id});
    return await http
        .request(UNCOLLECT_WEBSITE, data: formData, method: "post");
  }

}

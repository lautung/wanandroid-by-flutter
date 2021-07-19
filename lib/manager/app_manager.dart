import 'package:event_bus/event_bus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wanandroid_flutter/common/http/api.dart';
import 'package:wanandroid_flutter/common/http/http_manager.dart';

class AppManager {
  static const String ACCOUNT = "accoutName";
  static EventBus eventBus = EventBus();
  static late SharedPreferences prefs;


  static initApp() async {
    await Api.init();
    prefs = await SharedPreferences.getInstance();
  }

  static isLogin() {
    return  prefs.getString(ACCOUNT) != null;
  }
}

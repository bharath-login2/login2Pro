import 'dart:developer';

import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:login2/core/common.dart';

class Config {
  static getUrl() async {
    // String? url = await Common.getSharedPref("url");
    // log("SharedPref URL = $url");
    String baseUrl;
    // String? api = '/version3_0_8/Api/';
    baseUrl = 'https://mentorbee.login2.co.in/index.php/version3_0_9/api/';
    // if (url != null) {
    //   baseUrl = url.toString() + api;
    // } else {
    //   baseUrl = '';
    // }
    return baseUrl;
  }

  static requestPermission() async {
    await FlutterOverlayWindow.requestPermission();
  }
}

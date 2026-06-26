
import 'dart:developer';

import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:login2/core/common.dart';

class Config {
  static getUrl() async {
    // String? url = await Common.getSharedPref("url");
    // log("SharedPref URL = $url");
     String baseUrl;
    // String? api = '/v1_1_7/Api/';
    // if (url != null) {
    //  baseUrl = url.toString() + api;

      baseUrl = 'https://funriders.login2.co.in/index.php/version3_0_8/Api/';
  //  } else {
  //    baseUrl = '';
  //  }
    return baseUrl;
  }

  static requestPermission() async {
    await FlutterOverlayWindow.requestPermission();
  }
}

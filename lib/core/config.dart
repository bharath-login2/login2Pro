import 'dart:developer';

import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:login2/core/common.dart';

class Config {
  static getUrl() async {
    String? url = await Common.getSharedPref("url");
    log("SharedPref URL = $url");
    String baseUrl;
    String? api = '/version3_0_10/Api/';
    if (url != null) {
      baseUrl = url.toString() + api;
    } else {  
      baseUrl = '';
    }
    return baseUrl;
  }

  static requestPermission() async {
    await FlutterOverlayWindow.requestPermission();
  }
}

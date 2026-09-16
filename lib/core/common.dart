import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/premium_toast.dart';

class Common {
  static toastMessaage(message, color) {
    return Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: color,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  static void premiumToast(BuildContext context, String message, IconData icon,
      {Color color = Colors.blue}) {
    PremiumToast.show(
      context: context,
      message: message,
      icon: icon,
      color: color,
    );
  }

  static String trimPlus91(String mobileNumber) {
    if (mobileNumber.length == 13) {
      return mobileNumber.substring(3);
    } else if (mobileNumber.length == 12) {
      return mobileNumber.substring(2);
    } else {
      return mobileNumber;
    }
  }

  static String trimCountryCode({
    required String mobileNumber,
    required String countryCode,
  }) {
    if (mobileNumber.isEmpty) return mobileNumber;
    final cleanNumber = mobileNumber.replaceAll('+', '');
    if (cleanNumber.startsWith(countryCode)) {
      return cleanNumber.substring(countryCode.length);
    }
    return cleanNumber;
  }

  static addPlus(String number) async {
    if (number.length == 12) {
      return "+$number";
    } else {
      return number;
    }
  }

  // static dialPad(String number) async {
  //   if (number.length == 12) {
  //     await FlutterPhoneDirectCaller.callNumber('+$number');
  //   } else {
  //     await FlutterPhoneDirectCaller.callNumber(number);
  //   }
  // }

  static dialPad(String number) async {
    if (number.length == 12) {
      String url = 'tel:+$number';
      await launchUrl(Uri.parse(url));
    } else {
      String url = 'tel:$number';
      await launchUrl(Uri.parse(url));
    }
  }

  static saveSharedPref(String key, String val) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, val);
  }

  // static clearSharedPref() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   prefs.clear();
  // }
  static Future<void> clearSharedPref(
      {List<String> excludeKeys = const []}) async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();

    for (String key in allKeys) {
      if (!excludeKeys.contains(key)) {
        await prefs.remove(key);
      }
    }
  }

  static getSharedPref(String key) async {
    final prefs = await SharedPreferences.getInstance();
    print('$key:${prefs.get(key)}');
    return prefs.get(key);
  }

  static showProgressDialog(BuildContext context, String title) {
    try {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              content: Flex(
                direction: Axis.horizontal,
                children: <Widget>[
                  const CircularProgressIndicator(),
                  const Padding(
                    padding: EdgeInsets.only(left: 15),
                  ),
                  title.isEmpty
                      ? Container()
                      : Flexible(
                          flex: 8,
                          child: Text(
                            title,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          )),
                ],
              ),
            );
          });
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  static openWhatsApp(String number) async {
    final whatsappUrl = "whatsapp://send?phone=$number";
    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(Uri.parse(whatsappUrl));
    } else {
      await launchUrl(Uri.parse("https://wa.me/$number"),
          mode: LaunchMode.externalApplication);
    }
  }

  static Future<bool> showLocationDisclosure(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.location_on, color: Colors.blue),
                SizedBox(width: 8),
                Text("Location Access Disclosure",
                    style: TextStyle(fontSize: 18)),
              ],
            ),
            content: const SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "We collect your location data only when you use the app to:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Text(
                      "• Verify your presence within the permitted work location during attendance"),
                  Text(
                      "• Record your location at the time of login and logout"),
                  Text(
                      "• Identify the location from where work-related data is updated"),
                  SizedBox(height: 12),
                  Text(
                    "This data is used by the organization/admin to monitor attendance and work activity.",
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Your location is collected only while using the app and is not tracked in the background.",
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Deny", style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child:
                    const Text("Allow", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ) ??
        false;
  }

  static Map<String, dynamic>? decodeJwt(String? token) {
    if (token == null || token.isEmpty) return null;
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      String payload = parts[1];
      switch (payload.length % 4) {
        case 2:
          payload += '==';
          break;
        case 3:
          payload += '=';
          break;
      }
      final decoded = utf8.decode(base64Url.decode(payload));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        print("Error decoding JWT: $e");
      }
      return null;
    }
  }

  static Future<void> saveDateFilterFromToken(String? token) async {
    if (token == null || token.isEmpty) return;
    try {
      final payload = decodeJwt(token);
      if (payload != null) {
        dynamic val;
        if (payload['data'] is Map<String, dynamic>) {
          val = payload['data']['date_filter'];
        }
        val ??= payload['date_filter'];
        if (val != null && val.toString().isNotEmpty) {
          await saveSharedPref("date_filter", val.toString());
          if (kDebugMode) {
            print("Successfully saved date_filter from JWT token: $val");
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error extracting date_filter from JWT token: $e");
      }
    }
  }

  static Future<int?> getDateFilter() async {
    final dateFilterVal = await getSharedPref("date_filter");
    if (dateFilterVal != null && dateFilterVal.toString().isNotEmpty) {
      final parsed = int.tryParse(dateFilterVal.toString());
      if (parsed != null && parsed > 0) return parsed;
    }
    final token = await getSharedPref("token");
    if (token != null) {
      final payload = decodeJwt(token.toString());
      if (payload != null) {
        dynamic val;
        if (payload['data'] is Map<String, dynamic>) {
          val = payload['data']['date_filter'];
        }
        val ??= payload['date_filter'];
        if (val != null && val.toString().isNotEmpty) {
          final parsed = int.tryParse(val.toString());
          if (parsed != null && parsed > 0) {
            await saveSharedPref("date_filter", parsed.toString());
            return parsed;
          }
        }
      }
    }
    return null;
  }

  static DateTime subtractMonths(DateTime date, int months) {
    if (months <= 0) return date;
    int year = date.year;
    int month = date.month - months;
    while (month <= 0) {
      month += 12;
      year -= 1;
    }
    int day = date.day;
    int maxDaysInMonth = DateTime(year, month + 1, 0).day;
    if (day > maxDaysInMonth) {
      day = maxDaysInMonth;
    }
    return DateTime(
      year,
      month,
      day,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond,
    );
  }

  static DateTime addMonths(DateTime date, int months) {
    if (months <= 0) return date;
    int year = date.year;
    int month = date.month + months;
    while (month > 12) {
      month -= 12;
      year += 1;
    }
    int day = date.day;
    int maxDaysInMonth = DateTime(year, month + 1, 0).day;
    if (day > maxDaysInMonth) {
      day = maxDaysInMonth;
    }
    return DateTime(
      year,
      month,
      day,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond,
    );
  }
}

RegExp regex = RegExp(PatterStrings.email);

class PatterStrings {
  static const String email =
      // r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
}

Center noResultWidget(BuildContext context, text) {
  return Center(
    child: SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: text == "Type to search..." ? 250 : 200,
            height: text == "Type to search..." ? 250 : 200,
            child: text == "Type to search..."
                ? Lottie.asset("assets/icons/search_here.json")
                : Image.asset(
                    "assets/icons/nodatafound.png",
                  ),
          ),
          // if (text != "Type to search...")
          Text(
            text,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 10,
          ),
          // InkWell(
          //   onTap: () {
          //     Navigator.pop(context);
          //   },
          //   child: Container(
          //     width: MediaQuery.of(context).size.width * 0.4,
          //     height: 40,
          //     decoration: BoxDecoration(
          //       color: Colors.black,
          //       borderRadius: BorderRadius.circular(10),
          //     ),
          //     child: const Center(
          //       child: Text('Go Back',
          //           style: TextStyle(
          //               fontSize: 15,
          //               color: Colors.white,
          //               fontWeight: FontWeight.w500)),
          //     ),
          //   ),
          // )
        ],
      ),
    ),
  );
}

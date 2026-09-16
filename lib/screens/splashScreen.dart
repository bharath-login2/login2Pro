// ignore_for_file: unnecessary_this

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:device_marketing_names/device_marketing_names.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:login2/models/userPermissionModel.dart';
import 'package:login2/screens/accounts/dashboard/accounts_dashboard.dart';
import 'package:login2/screens/accounts/renewal_mannagement/renewal_dashboard.dart';
import 'package:login2/screens/homePage.dart';
import 'package:login2/screens/leadManagement/dashboardLeadsNewUpdated2.dart';
import 'package:login2/screens/leadManagement/minimalDashboard.dart';
import 'package:login2/screens/leadManagement/projectDashboard.dart';
import 'package:login2/screens/leadManagement/quotationDashboard.dart';
import 'package:login2/screens/push_notification_channel.dart';
import 'package:login2/screens/roombooking/hotelDashboard.dart';
import 'package:login2/service/loggerservice.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/common.dart';
import '../../models/loginCheckModel.dart';
import '../../models/updateModel.dart';
import '../../screens/authentication/login.dart';
import '../../screens/forceUpdate.dart';
import '../../screens/leadManagement/dashboard.dart';
import 'package:login2/screens/authentication/deep_link_handler.dart';
import '../../service/service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final splashDelay = 2;
  bool? result = true;
  bool timeOut = false;
  String? firebaseToken;
  UpdateModel? updatedata;
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  );
  // ignore: unused_field
  String? navigation;
  String? _debugLink; // Debug variable
  final firebaseServices = FirebaseServices();

  Future<Map<String, String>> getDeviceInfo() async {
    String deviceName = '';
    String platform = '';
    String osVersion = '';
    String modelCode = '';

    try {
      final deviceInfo = DeviceInfoPlugin();
      final marketingNames = DeviceMarketingNames();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceName = await marketingNames.getSingleName();
        if (deviceName.isEmpty || deviceName == androidInfo.model) {
          deviceName =
              androidInfo.manufacturer != null && androidInfo.model != null
                  ? '${androidInfo.manufacturer} ${androidInfo.model}'
                  : androidInfo.model ?? 'Unknown Android Device';
        }

        platform = 'Android';
        osVersion = androidInfo.version.release ?? 'Unknown';
        modelCode = androidInfo.model ?? '';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceName = await marketingNames.getSingleName();
        if (deviceName.isEmpty) {
          deviceName =
              iosInfo.utsname.machine ?? iosInfo.model ?? 'Unknown iOS Device';
        }

        platform = 'iOS';
        osVersion = iosInfo.systemVersion ?? 'Unknown';
        modelCode = iosInfo.utsname.machine ?? '';
      }

      log('Device detected: $deviceName ($platform $osVersion)');
    } catch (e) {
      log('Error getting device info: $e');
      deviceName = 'Unknown Device';
      platform = Platform.isAndroid ? 'Android' : 'iOS';
      osVersion = 'Unknown';
    }

    return {
      'deviceName': deviceName,
      'platform': platform,
      'osVersion': osVersion,
      'mobileName': modelCode,
    };
  }

  @override
  void initState() {
    super.initState();
    print("[INIT] SplashScreen: initState");
    try {
      print("[INIT] SplashScreen: Initializing FirebaseServices");
      firebaseServices.init(context);
      print("[INIT] SplashScreen: FirebaseServices initialized");
    } catch (e) {
      print("[INIT] SplashScreen ERROR: FirebaseServices.init: $e");
    }
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      setState(() {
        navigation = message.data['navigation'];
      });
    });
    print("[INIT] SplashScreen: handleAsync start");
    handleAsync();
    print("[INIT] SplashScreen: getData start");
    getData();
    _updateSelectedDashboard();
    _checkInitialDeepLink();
    log('[DEEPLINK] SplashScreen: initState completed');
  }

  Future<void> _checkInitialDeepLink() async {
    try {
      log('[DEEPLINK] SplashScreen: Checking for initial app link');
      final initialLink = await DeepLinkHandler().getInitialAppLink();
      if (initialLink != null) {
        log('[DEEPLINK] SplashScreen: Initial link captured: $initialLink');
        await DeepLinkHandler().handleAppLink(initialLink);
      } else {
        log('[DEEPLINK] SplashScreen: No initial link found');
      }
    } catch (e) {
      log('[DEEPLINK] SplashScreen ERROR: _checkInitialDeepLink: $e');
    }
  }

  Future<void> _updateSelectedDashboard() async {
    try {
      final token = await Common.getSharedPref("token");
      if (token != null) {
        await Common.saveDateFilterFromToken(token.toString());
        final UserPermissionModel? object1 =
            await HttpService.userPermissionCheck(token);
        if (object1 != null && object1.status == true && object1.data != null) {
          Common.saveSharedPref("ProjectDashboardPermission",
              object1.data!.ProjectDashboard.toString());
          Common.saveSharedPref(
              "LeadDashboard", object1.data!.LeadDashboard.toString());
          Common.saveSharedPref("AccountsDashboardPermission",
              object1.data!.AccountsDashboard.toString());
          Common.saveSharedPref(
              "MenuDashboard", object1.data!.MenuDashboard.toString());
          Common.saveSharedPref("RenewalDashboardPermission",
              object1.data!.RenewalDashboard.toString());
          Common.saveSharedPref("NewleadDashboardPermission",
              object1.data!.NewleadDashboard.toString());
          Common.saveSharedPref("QuotationDashboardPermission",
              object1.data!.QuotationDashboard.toString());
          Common.saveSharedPref(
              "RoomDashboard", object1.data!.RoomDashboard.toString());
          Common.saveSharedPref("addApproveLeavePermission",
              object1.data!.addApproveLeave.toString());
          Common.saveSharedPref("rejectRequestLeavePermission",
              object1.data!.rejectRequestLeave.toString());
          Common.saveSharedPref("editLeaveRequestPermission",
              object1.data!.editLeaveRequest.toString());
          Common.saveSharedPref("deleteLeaveRequestPermission",
              object1.data!.deleteLeaveRequest.toString());
          if (object1.data!.ProjectDashboard == "true") {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const ProjectDashboard()),
              (route) => false,
            );
            return;
          }
          if (object1.data!.LeadDashboard == "true") {
            Navigator.pushAndRemoveUntil(
              context,
              // MaterialPageRoute(builder: (_) =>  Dashboard(token)),
              MaterialPageRoute(
                  builder: (_) => DashboardLeadNewUpdatedTwo(token)),
              (route) => false,
            );
            return;
          }
          if (object1.data!.AccountsDashboard == "true") {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (_) => AccountsDashboard(token: token)),
              (route) => false,
            );
            return;
          }
          if (object1.data!.RenewalDashboard == "true") {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const RenewalDashboard()),
              (route) => false,
            );
            return;
          }
          if (object1.data!.QuotationDashboard == "true") {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const QuotationDashboard()),
              (route) => false,
            );
            return;
          }
          if (object1.data!.MenuDashboard == "true") {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => HomePage(token)),
              (route) => false,
            );
            return;
          }
          if (object1.data!.NewleadDashboard == "true") {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => MinimalDashboard(token)),
              (route) => false,
            );
            return;
          }
          if (object1.data!.RoomDashboard == "true") {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => RoomDashboard()),
              (route) => false,
            );
            return;
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (_) => DashboardLeadNewUpdatedTwo(token)),
              (route) => false,
            );
          }
        }
      }
    } catch (e) {
      print("Error refreshing permissions after dashboard update: $e");
    }
  }

  Future<void> initDeepLinks() async {
    log('[DEEPLINK] SplashScreen: initDeepLinks called');
    String? token = await Common.getSharedPref("token");
    String? ProjectDashboardPermission =
        await Common.getSharedPref("ProjectDashboardPermission");
    String? LeadDashboard = await Common.getSharedPref("LeadDashboard");
    String? AccountsDashboardPermission =
        await Common.getSharedPref("AccountsDashboardPermission");
    String? MenuDashboard = await Common.getSharedPref("MenuDashboard");
    String? RenewalDashboardPermission =
        await Common.getSharedPref("RenewalDashboardPermission");
    String? NewleadDashboardPermission =
        await Common.getSharedPref("NewleadDashboardPermission");
    String? QuotationDashboardPermission =
        await Common.getSharedPref("QuotationDashboardPermission");
    String? RoomDashboardPer = await Common.getSharedPref("RoomDashboard");

    Widget dashboardToOpen;
    if (ProjectDashboardPermission == "true") {
      dashboardToOpen = const ProjectDashboard();
    } else if (LeadDashboard == "true") {
      dashboardToOpen = DashboardLeadNewUpdatedTwo(token);
    } else if (AccountsDashboardPermission == "true") {
      if (token != null) {
        dashboardToOpen = AccountsDashboard(token: token);
      } else {
        dashboardToOpen = DashboardLeadNewUpdatedTwo(token);
      }
    } else if (MenuDashboard == "true") {
      dashboardToOpen = HomePage(token);
    } else if (RenewalDashboardPermission == "true") {
      dashboardToOpen = const RenewalDashboard();
    } else if (NewleadDashboardPermission == "true") {
      dashboardToOpen = MinimalDashboard(token);
    } else if (QuotationDashboardPermission == "true") {
      dashboardToOpen = const QuotationDashboard();
    } else if (RoomDashboardPer == "true") {
      dashboardToOpen = RoomDashboard();
    } else {
      dashboardToOpen = HomePage(token);
    }

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => dashboardToOpen),
        (route) => false,
      );

      // Handle pending deep links after a short delay to ensure dashboard is ready
      Future.delayed(const Duration(milliseconds: 800), () {
        DeepLinkHandler().checkAndHandlePendingDeepLink();
      });
    }
  }

  handleAsync() async {
    try {
      // await FirebaseMessaging.instance.requestPermission(
      //   alert: true,
      //   announcement: false,
      //   badge: true,
      //   carPlay: false,
      //   criticalAlert: true,
      //   provisional: true,
      //   sound: true,
      // );
      firebaseToken = await FirebaseMessaging.instance.getToken();
      await LoggerService.log("Firebase token received: $firebaseToken");
      if (kDebugMode) {
        print("Firebase token : $firebaseToken");
      }
    } catch (error, stackTrace) {
      firebaseToken = '';
      log("Error while get FCM", error: error, stackTrace: stackTrace);
    }
  }

  // getData() async {
  //   setState(() {
  //     timeOut = false;
  //   });
  //   try {
  //     final connectivityResult = await (Connectivity().checkConnectivity());
  //     if (connectivityResult == ConnectivityResult.mobile ||
  //         connectivityResult == ConnectivityResult.wifi) {
  //       result = true;
  //     } else {
  //       result = false;
  //     }

  //     updatedata = await HttpService.forceUpdate();
  //     if (mounted) {
  //       setState(() {
  //         if (updatedata!.data!.server!.length == 1) {
  //           Common.saveSharedPref(
  //               "url", updatedata!.data!.server![0].url.toString());
  //         }
  //       });
  //       final info = await PackageInfo.fromPlatform();
  //       setState(() {
  //         _packageInfo = info;
  //       });
  //       final appVersion = _packageInfo.version;
  //       int versionCompare =
  //           appVersion.compareTo(updatedata!.data!.minVersion.toString());
  //       if (versionCompare < 0) {
  //         _checkVersion();
  //       } else {
  //         _loadWidget();
  //       }
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       setState(() {
  //         timeOut = true;
  //       });
  //     }
  //   }
  // }
// working code by ansar
  // getData() async {
  //   setState(() {
  //     timeOut = false;
  //   });
  //   try {
  //     await LoggerService.log("Checking network connectivity...");
  //     final connectivityResult = await (Connectivity().checkConnectivity());
  //     await LoggerService.log("Connectivity: $connectivityResult");

  //     if (connectivityResult == ConnectivityResult.mobile ||
  //         connectivityResult == ConnectivityResult.wifi) {
  //       result = true;
  //     } else {
  //       result = false;
  //     }

  //     await LoggerService.log("Fetching forceUpdate data...");
  //     updatedata = await HttpService.forceUpdate();
  //     await LoggerService.log(
  //         "forceUpdate data received: ${updatedata?.data?.minVersion}");

  //     if (mounted) {
  //       setState(()  {
  //         if (updatedata!.data!.server!.isNotEmpty) {
  //           Common.saveSharedPref(
  //               "url", updatedata!.data!.server![0].url.toString());
  //           LoggerService.log(
  //               "Server URL saved: ${updatedata!.data!.server![0].url}");
  //         }

  //       });

  //       final info = await PackageInfo.fromPlatform();
  //       setState(() {
  //         _packageInfo = info;
  //       });
  //       await LoggerService.log("App version: ${_packageInfo.version}");

  //       int versionCompare = _packageInfo.version
  //           .compareTo(updatedata!.data!.minVersion.toString());
  //       await LoggerService.log("Version compare result: $versionCompare");

  //       if (versionCompare < 0) {
  //         await LoggerService.log(
  //             "Version outdated, navigating to ForceUpdate");
  //         _checkVersion();
  //       } else {
  //         await LoggerService.log("Version OK, proceeding to loadWidget");
  //         _loadWidget();
  //       }
  //     }
  //   } catch (e) {
  //     await LoggerService.log("Error in getData: $e");
  //     if (mounted) {
  //       setState(() {
  //         timeOut = true;
  //       });
  //     }
  //   }
  // }
  // working code by ansar above

  //code by sk

//   getData() async {
//   setState(() {
//     timeOut = false;
//   });

//   try {
//     await LoggerService.log("Checking network connectivity...");
//     final connectivityResult = await (Connectivity().checkConnectivity());
//     await LoggerService.log("Connectivity: $connectivityResult");
//     bool hasNetwork = connectivityResult == ConnectivityResult.mobile ||
//         connectivityResult == ConnectivityResult.wifi;
//     result = hasNetwork;
//     await LoggerService.log("Fetching forceUpdate data...");
//     updatedata = await HttpService.forceUpdate();
//     await LoggerService.log(
//         "forceUpdate data received: ${updatedata?.data?.minVersion}");
//     if (updatedata!.data!.server!.isNotEmpty) {
//       String? savedUrl = await Common.getSharedPref("url");
//       if (savedUrl == null || savedUrl.isEmpty) {
//         await Common.saveSharedPref(
//           "url",
//           updatedata!.data!.server![0].url.toString(),
//         );
//         await LoggerService.log(
//             "Server URL saved (initial): ${updatedata!.data!.server![0].url}");
//       } else {
//         await LoggerService.log("Keeping already saved URL: $savedUrl");
//       }
//     }
//     final info = await PackageInfo.fromPlatform();

//     if (mounted) {
//       setState(() {
//         _packageInfo = info;
//       });
//     }

//     await LoggerService.log("App version: ${_packageInfo.version}");

//     int versionCompare = _packageInfo.version
//         .compareTo(updatedata!.data!.minVersion.toString());
//     await LoggerService.log("Version compare result: $versionCompare");

//     if (versionCompare < 0) {
//       await LoggerService.log("Version outdated, navigating to ForceUpdate");
//       _checkVersion();
//     } else {
//       await LoggerService.log("Version OK, proceeding to loadWidget");
//       _loadWidget();
//     }
//   } catch (e) {
//     await LoggerService.log("Error in getData: $e");
//     if (mounted) {
//       setState(() {
//         timeOut = true;
//       });
//     }
//   }
// }

  getData() async {
    setState(() {
      timeOut = false;
    });

    try {
      await LoggerService.log("Checking network connectivity...");
      // final connectivityResult = await (Connectivity().checkConnectivity());
      // await LoggerService.log("Connectivity: $connectivityResult");

      // bool hasNetwork = connectivityResult == ConnectivityResult.mobile ||
      //     connectivityResult == ConnectivityResult.wifi;
      // result = hasNetwork;
      final connectivityResult = await Connectivity().checkConnectivity();

      // Check connectivity
      if (connectivityResult is List<ConnectivityResult>) {
        result = connectivityResult.contains(ConnectivityResult.mobile) ||
            connectivityResult.contains(ConnectivityResult.wifi);
      } else if (connectivityResult is ConnectivityResult) {
        result = connectivityResult == ConnectivityResult.mobile ||
            connectivityResult == ConnectivityResult.wifi;
      }

      if (!result!) {
        setState(() {});
        return;
      }

      await LoggerService.log("Fetching forceUpdate data...");
      updatedata = await HttpService.forceUpdate();
      await LoggerService.log(
          "forceUpdate data received: ${updatedata?.data?.minVersion}");

      if (updatedata!.data!.server!.isNotEmpty) {
        String? savedUrl = await Common.getSharedPref("url");

        if (savedUrl == null || savedUrl.isEmpty) {
          await Common.saveSharedPref("url", "");
          await LoggerService.log("Cleared saved URL (was null/empty).");
        } else {
          await LoggerService.log("Keeping already saved URL: $savedUrl");
        }
      }

      final info = await PackageInfo.fromPlatform();

      if (mounted) {
        setState(() {
          _packageInfo = info;
        });
      }

      await LoggerService.log("App version: ${_packageInfo.version}");

      int versionCompare = _packageInfo.version
          .compareTo(updatedata!.data!.minVersion.toString());
      await LoggerService.log("Version compare result: $versionCompare");

      if (versionCompare < 0) {
        await LoggerService.log("Version outdated, navigating to ForceUpdate");
        _checkVersion();
      } else {
        await LoggerService.log("Version OK, proceeding to loadWidget");
        _loadWidget();
      }
    } catch (e) {
      await LoggerService.log("Error in getData: $e");
      if (mounted) {
        setState(() {
          timeOut = true;
        });
      }
    }
  }

  void _checkVersion() async {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const ForceUpdate()),
        (Route<dynamic> route) => false);
  }

  _loadWidget() async {
    var duration = Duration(seconds: splashDelay);
    return Timer(duration, routeTOHomePage);
  }

  @override
  Widget build(BuildContext context) {
    return result == true && timeOut == false
        ? Stack(
            children: [
              Container(
                  color: Colors.white,
                  width: MediaQuery.of(context).size.width * 1,
                  child: Center(
                    child: Image.asset(
                      'assets/main/logo.png',
                      width: 200,
                    ),
                  )),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Colors.red,
                        backgroundColor: Colors.grey.withOpacity(0.5),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        _packageInfo.version == 'Unknown'
                            ? ' Connecting...'
                            : 'Version ${_packageInfo.version}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_debugLink != null)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            _debugLink!,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      const SizedBox(height: 10),
                      if (_debugLink != null)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            _debugLink!,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              )
            ],
          )
        : Scaffold(
            backgroundColor: Colors.white,
            body: SizedBox(
              width: MediaQuery.of(context).size.width * 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 300,
                    height: 300,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/icons/noNetwork.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Text(
                    timeOut == true
                        ? "There seems to be a temporary issue !, \n Please retry to continue"
                        : 'No Network Found !',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  InkWell(
                    onTap: () {
                      getData();
                    },
                    child: SizedBox(
                      width: 120,
                      height: 35,
                      child: Padding(
                        padding: const EdgeInsets.all(1.5),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Center(
                            child: Text(
                              'Try Again',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ));
  }

  routeTOHomePage() async {
    if (navigation == null) {
      String? token = await Common.getSharedPref("token");
      log(firebaseToken.toString());
      if (firebaseToken == null) {
        log("Firebase token is still null. Retrying...");
        firebaseToken = await FirebaseMessaging.instance.getToken();
      }

      if (firebaseToken == null) {
        Common.toastMessaage(
            'Unable to get Firebase token. Try restarting app.', Colors.red);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Login()),
            (Route<dynamic> route) => false);
        return;
      }
      final deviceInfo = await getDeviceInfo();
    //   HttpService.mobileDetails(
    //  //   token: token,
    //     deviceName: deviceInfo['deviceName'],
    //     platform: deviceInfo['platform'],
    //     osVersion: deviceInfo['osVersion'],
    //     mobileName: deviceInfo['mobileName'],
    //   );

      LoginCheckModel? loginCheck =
          await HttpService.loginCheck(token, firebaseToken!);
      if (loginCheck == null) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Login()),
            (Route<dynamic> route) => false);
      }
      if (loginCheck!.data == true) {
        initDeepLinks();
      } else {
        Common.premiumToast(context, 'Token Expired', Icons.lock_clock_rounded,
            color: Colors.red);
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const Login()),
              (Route<dynamic> route) => false);
        }
      }
    } else {}
  }
  // routeTOHomePage() async {
  //   await LoggerService.log("routeTOHomePage started, navigation=$navigation");

  //   if (navigation == null) {
  //     String? token = await Common.getSharedPref("token");
  //     await LoggerService.log("Token from shared pref: $token");

  //     if (firebaseToken == null) {
  //       await LoggerService.log("Firebase token is null, retrying...");
  //       firebaseToken = await FirebaseMessaging.instance.getToken();
  //     }

  //     if (firebaseToken == null) {
  //       await LoggerService.log(
  //           "Firebase token still null. Redirecting to Login.");
  //       Common.toastMessaage(
  //           'Unable to get Firebase token. Try restarting app.', Colors.red);
  //       Navigator.of(context).pushAndRemoveUntil(
  //           MaterialPageRoute(builder: (context) => const Login()),
  //           (Route<dynamic> route) => false);
  //       return;
  //     }

  //     try {
  //       await LoggerService.log("Checking login status...");
  //       LoginCheckModel? loginCheck =
  //           await HttpService.loginCheck(token, firebaseToken!);
  //       await LoggerService.log("Login check result: ${loginCheck?.data}");

  //       if (loginCheck == null || loginCheck.data != true) {
  //         Common.toastMessaage('Token Expired', Colors.red);
  //         Navigator.of(context).pushAndRemoveUntil(
  //             MaterialPageRoute(builder: (context) => const Login()),
  //             (Route<dynamic> route) => false);
  //       } else {
  //         await LoggerService.log("Login successful, initializing deep links");
  //         initDeepLinks();
  //       }
  //     } catch (e) {
  //       await LoggerService.log("Error during loginCheck: $e");
  //       Navigator.of(context).pushAndRemoveUntil(
  //           MaterialPageRoute(builder: (context) => const Login()),
  //           (Route<dynamic> route) => false);
  //     }
  //   }
  // }
}

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/expense/expense_post.dart';
import 'package:login2/models/lead_management/leadDashboardModel.dart';
import 'package:login2/models/lead_management/projectList_model.dart';
import 'package:login2/models/lead_management/workstatus_model.dart';
import 'package:login2/models/loginCheckModel.dart';
import 'package:login2/screens/accounts/dashboard/accountsDashboardNew.dart';

import 'package:login2/screens/accounts/dashboard/accounts_dashboard.dart';
import 'package:login2/screens/accounts/clients/clientList.dart';
import 'package:login2/screens/customer/customer_dashboard_home.dart';
import 'package:login2/screens/authentication/face_detection_camera.dart';
import 'package:login2/screens/authentication/login.dart';
import 'package:login2/screens/fileManager/fileManagerList.dart';
import 'package:login2/screens/leadManagement/ViewAllTargetReportPage.dart';
import 'package:login2/screens/leadManagement/allReport_new.dart';
import 'package:login2/screens/leadManagement/dashboardLeadsNew.dart';
import 'package:login2/screens/leadManagement/dashboardLeadsNewUpdated.dart';
import 'package:login2/screens/leadManagement/dashboardLeadsNewUpdated2.dart';
import 'package:login2/screens/leadManagement/detailed_reports_page.dart';
import 'package:login2/screens/leadManagement/minimalDashboard.dart';
import 'package:login2/screens/leadManagement/notification_page.dart';
import 'package:login2/screens/leadManagement/projectDashboard.dart';
import 'package:login2/screens/leadManagement/quotationDashboard.dart';
import 'package:login2/screens/leadManagement/quotationPage.dart';
import 'package:login2/screens/leadManagement/salaryReportPage.dart';
import 'package:login2/screens/leadManagement/staffReport.dart';
import 'package:login2/screens/leadManagement/transferLeadReport.dart';
import 'package:login2/screens/accounts/renewal_mannagement/renewal_dashboard.dart';
import 'package:login2/screens/leadManagement/viewLeadsNew.dart';
import 'package:login2/screens/leave_request_list_page.dart';
import 'package:login2/screens/product_mannagement/product_list.dart';
import 'package:login2/screens/rental/rentalDashboard.dart';
import 'package:login2/screens/roombooking/hotelDashboard.dart';
import 'package:login2/screens/search/search.dart';
import 'package:login2/screens/serviceman/dashboard_page.dart';
import 'package:login2/screens/stock/stockDashboard.dart';
import 'package:login2/screens/purchase/purchaseDashboard.dart';
import 'package:login2/screens/staff_reports/followupCalendarPage.dart';
import 'package:login2/screens/staff_reports/staffwiseCallReports.dart';
import 'package:login2/widgets/togglebutton_start.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/common.dart';
import '../../models/commonConfigureModel.dart';
import '../../models/dashboardModel.dart';
import 'bottom_navigation_bar.dart';
import '../../screens/drawerScreen.dart';
import '../../screens/leadManagement/dashboard.dart';
import '../../screens/settings/whatsappSettings.dart';
import '../../screens/userManagement/viewUsers.dart';
import '../../service/service.dart';
import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:url_launcher/url_launcher.dart';
import 'complaints/complaint_list_screen.dart';
import 'leadManagement/allReport.dart';
import 'officialWhatsapp/chat_home_screen.dart';

class HomePage extends StatefulWidget {
  String? token;

  HomePage(this.token, {super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool? result = true;
  bool? result1 = true;
  Timer? _timer;
  int _currentPage = 0;
  DashboardModel? userDashboard;
  CommonConfigureModel? configure;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String name = '';
  String role = '';
  String token = '';
  String userId = '';
  String? ProjectDashboardPermission;
  String? AccountsDashboardPermission;
  String? MenuDashboard;
  String? RenewalDashboardPermission;
  String? NewleadDashboardPermission;
  bool isLongPress = false;
  String officialWhatsapp = '';
  String unOfficialWhatsapp = '';
  String phoneCallLogPermission = '';
  String viewWorkReportPermission = '';
  String startAndStopWorkPermission = '';
  String viewLeadPermission = '';
  bool isLoading = false;
  int notificationCount = 0;
  var fromdate = DateTime.now();
  var todate = DateTime.now();
  var fromdate1 =
      DateTime(DateTime.now().year, DateTime.now().month, 1).toString();
  var todate1 = DateTime.now();
  var outputFormat = DateFormat('dd-MM-yyyy');
  LeadDashboardModel? leadDashboard;
  bool createLeadCategory1 = false;
  bool updateLeadCategory1 = false;
  bool deleteLeadCategory1 = false;
  String createLeadCategory = '';
  String updateLeadCategory = '';
  String deleteLeadCategory = '';
  String updateLeadPermission = '';
  String deleteLeadPermission = '';
  String cloudCallPermission = '';
  bool updateLeadPermission1 = false;
  bool deleteLeadPermission1 = false;
  bool cloudCallPermission1 = false;
  String? firebaseToken;
  CommonResponse? loginOrNot;
  bool isWorkStarted = false;
  bool isExpired = false;
  ProjectList? projectList;
  WorkStatusModel? workStatus;
  DateTime? createdAt;
  @override
  void initState() {
    super.initState();
    getData();
    _loadWorkStatus();
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  getData() async {
    token = await Common.getSharedPref("token");
    name = await Common.getSharedPref("name");
    role = await Common.getSharedPref("role");
    userId = await Common.getSharedPref("userId");
    viewLeadPermission = await Common.getSharedPref("viewLeadPermission");
    ProjectDashboardPermission =
        await Common.getSharedPref("ProjectDashboardPermission");
    AccountsDashboardPermission =
        await Common.getSharedPref("AccountsDashboardPermission");
    MenuDashboard = await Common.getSharedPref("MenuDashboard");
    RenewalDashboardPermission =
        await Common.getSharedPref("RenewalDashboardPermission");
    NewleadDashboardPermission =
        await Common.getSharedPref("NewleadDashboardPermission");
    log(role.toString());
    officialWhatsapp = await Common.getSharedPref("officialWhatsApp");
    unOfficialWhatsapp = await Common.getSharedPref("unofficialWhatsApp");
    phoneCallLogPermission =
        await Common.getSharedPref("phoneCallLogPermission");
    viewWorkReportPermission =
        await Common.getSharedPref("viewWorkReportPermission");
    startAndStopWorkPermission =
        await Common.getSharedPref("startAndStopWorkPermission");
    createLeadCategory = await Common.getSharedPref("createLeadCategory");
    updateLeadCategory = await Common.getSharedPref("updateLeadCategory");
    deleteLeadCategory = await Common.getSharedPref("deleteLeadCategory");
    updateLeadPermission = await Common.getSharedPref("updateLeadPermission");
    deleteLeadPermission = await Common.getSharedPref("deleteLeadPermission");
    cloudCallPermission = await Common.getSharedPref("cloudCallPermission");
    createLeadCategory1 = createLeadCategory == 'true';
    updateLeadCategory1 = updateLeadCategory == 'true';
    deleteLeadCategory1 = deleteLeadCategory == 'true';

    if (updateLeadPermission == 'true') {
      updateLeadPermission1 = true;
    }
    if (deleteLeadPermission == 'true') {
      deleteLeadPermission1 = true;
    }
    if (cloudCallPermission == 'true') {
      cloudCallPermission1 = true;
    }

    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult is List<ConnectivityResult>) {
      if (connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi)) {
        setState(() {
          result = true;
        });
      }
    } else {
      setState(() {
        result = false;
      });
    }
    // if (connectivityResult == ConnectivityResult.mobile ||
    //     connectivityResult == ConnectivityResult.wifi) {
    //   setState(() {
    //     result = true;
    //   });
    // } else {
    //   setState(() {
    //     result = false;
    //   });
    // }

    userDashboard = await HttpService.mainDashboard(widget.token);
    Common.saveSharedPref("profile_pic", userDashboard!.data.profilePic);

    if (userDashboard != null) {
      setState(() {
        _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
          if (_currentPage < userDashboard!.data.slides.length) {
            _currentPage++;
          } else {
            _currentPage = 0;
          }
          if (isLongPress == false) {
            _pageController.animateToPage(
              _currentPage,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeIn,
            );
          }
        });
      });
    }
    firebaseToken = await FirebaseMessaging.instance.getToken();
    LoginCheckModel? loginCheck =
        await HttpService.loginCheck(token, firebaseToken!);

    if (loginCheck == null || loginCheck.data == false) {
      if (mounted) {
        Common.toastMessaage('Session Expired', Colors.red);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Login()),
            (Route<dynamic> route) => false);
      }
      return;
    } else {
      configure = await HttpService.configure(token);
      if (configure != null) {
        isExpired = configure!.data!.isExpired!;
        setState(() {});
      }

      projectList = await HttpService.getProjectList();
      workStatus = await HttpService.getWorkStatus();
      if (workStatus!.data.isNotEmpty) {
        createdAt = DateTime.parse(workStatus!.data.first.createdAt);
      }

      userDashboard = await HttpService.mainDashboard(token);
      Common.saveSharedPref("profile_pic", userDashboard!.data.profilePic);

      Common.saveSharedPref(
          "whatsapp", userDashboard!.data.isWhatsappConfigured.toString());
      leadDashboard = await HttpService.leadDashboard(
          token, fromdate, todate, fromdate1, todate1);
      setState(() {
        notificationCount = leadDashboard!.data.unreadNotification;
      });
      await Permission.notification.request();
    }
    // configure = await HttpService.configure(widget.token);
    // if (configure != null) {
    //   setState(() {});
    // }
    // leadDashboard = await HttpService.leadDashboard(
    //     token, fromdate, todate, fromdate1, todate1);
    // setState(() {
    //   notificationCount = leadDashboard!.data.unreadNotification;
    // });
    final prefs = await SharedPreferences.getInstance();
    final dismissedDate = prefs.getString('loginPromptDismissedDate');
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (dismissedDate != today && startAndStopWorkPermission == "true") {
      loginOrNot = await HttpService.getLoginorNot(widget.token);
      if (loginOrNot?.data != true && startAndStopWorkPermission == "true") {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            showLoginPrompt(context);
          }
        });
      }
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _loadWorkStatus() async {
    String? status = await Common.getSharedPref("is_work_started");
    setState(() {
      isWorkStarted = status == "true";
    });
  }

  // Future<String?> generateFaceHash(File faceImageFile) async {
  //   final faceDetector = FaceDetector(
  //     options: FaceDetectorOptions(
  //       enableLandmarks: true,
  //       enableContours: true,
  //       enableClassification: false,
  //     ),
  //   );
  //   final inputImage = InputImage.fromFile(faceImageFile);
  //   final faces = await faceDetector.processImage(inputImage);
  //   if (faces.isEmpty) return null;
  //   final face = faces.first;
  //   final landmarks = face.landmarks;
  //   final serialized = [
  //     landmarks[FaceLandmarkType.leftEye]?.position,
  //     landmarks[FaceLandmarkType.rightEye]?.position,
  //     landmarks[FaceLandmarkType.noseBase]?.position,
  //     landmarks[FaceLandmarkType.leftCheek]?.position,
  //     landmarks[FaceLandmarkType.rightCheek]?.position,
  //   ].map((p) => p != null ? '${p.x.round()},${p.y.round()}' : '0,0').join(';');
  //   final lipPoints = face.contours[FaceContourType.upperLipTop]?.points ?? [];
  //   final lipData =
  //       lipPoints.take(3).map((p) => '${p.x.round()},${p.y.round()}').join(';');

  //   faceDetector.close();

  //   final combined = '$serialized;$lipData';
  //   return base64Encode(utf8.encode(combined));
  // }

  final PageController _pageController = PageController(
    initialPage: 0,
  );

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        bool? result = await _exitApp(context);
        result ??= false;
        return result;
      },
      child: RefreshIndicator(
        onRefresh: () async {
          getData();
          return;
        },
        child: result == true
            ? Scaffold(
                key: _scaffoldKey,
                backgroundColor: Colors.grey.shade200,
                appBar: PreferredSize(
                  preferredSize: Size.fromHeight(
                      MediaQuery.of(context).size.height * 0.08),
                  child: Container(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 10.0, top: 10.0, bottom: 10.0, right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (userDashboard != null)
                                InkWell(
                                    onTap: () => logout(context),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              blurRadius: 2,
                                              color: Colors.grey.shade800,
                                              offset: const Offset(0, 2.0),
                                            )
                                          ],
                                          shape: BoxShape.circle,
                                          color: const Color(0xFF2191ce)),
                                      child: CircleAvatar(
                                        backgroundImage: NetworkImage(
                                          userDashboard!.data.profilePic,
                                        ),
                                      ),
                                    )),
                              const SizedBox(
                                width: 15,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  const SizedBox(
                                    height: 2,
                                  ),
                                  Text(
                                    role,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              userDashboard != null &&
                                      startAndStopWorkPermission == "true"
                                  ?
                                  // StartStopToggle(
                                  //     initialStatus: userDashboard!.data.loginCheck,
                                  //     onToggle: (bool started) {
                                  //       setState(() {
                                  //         userDashboard!.data.loginCheck = started;
                                  //       });
                                  //     },
                                  //   )
                                  StartStopToggle(
                                      initialStatus:
                                          userDashboard!.data.loginCheck,
                                      onToggle: (bool started) {
                                        setState(() {
                                          userDashboard!.data.loginCheck =
                                              started;
                                        });
                                      },
                                      setDashboardLoading: (bool loading) {
                                        setState(() {
                                          isLoading = loading;
                                        });
                                      },
                                    )
                                  : const SizedBox(),
                              const SizedBox(width: 20),
                              InkWell(
                                onTap: () async {
                                  var status =
                                      await Permission.notification.status;
                                  if (status.isPermanentlyDenied) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title:
                                            const Text('Permission Required'),
                                        content: const Text(
                                            'Notification permission is permanently denied. Please enable it in settings to receive updates.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              AppSettings.openAppSettings(
                                                  type: AppSettingsType
                                                      .notification);
                                            },
                                            child: const Text('Open Settings'),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    await Permission.notification.request();
                                  }
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => NotificationPage(
                                            token,
                                            createLeadCategory1,
                                            updateLeadCategory1,
                                            deleteLeadCategory1)),
                                  ).then((r) {
                                    getData();
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 20),
                                  child: Stack(
                                    children: [
                                      Image.asset(
                                          "assets/icons/notification.png",
                                          width: 20,
                                          color: Colors.white),
                                      notificationCount > 0
                                          ? Positioned(
                                              right: 0,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(1),
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                constraints:
                                                    const BoxConstraints(
                                                  minWidth: 12,
                                                  minHeight: 12,
                                                ),
                                              ),
                                            )
                                          : const SizedBox()
                                    ],
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  _scaffoldKey.currentState!.openEndDrawer();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 20),
                                  child: Image.asset("assets/icons/menu.png",
                                      width: 20),
                                ),
                              ),
                            ],
                          ),
                          // InkWell(
                          //   onTap: () {
                          //     _scaffoldKey.currentState!.openEndDrawer();
                          //   },
                          //   child: SizedBox(
                          //     width: 35,
                          //     height: 35,
                          //     child: Padding(
                          //       padding: const EdgeInsets.all(8.0),
                          //       child: Image.asset(
                          //         "assets/icons/menu.png",
                          //       ),
                          //     ),
                          //   ),
                          // )
                        ],
                      ),
                    ),
                  ),
                ),
                body: userDashboard != null && configure != null
                    ? SingleChildScrollView(
                        child: Padding(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, top: 10),
                            child: Column(
                              children: [
                                // Positioned(
                                //   top: 12,
                                //   right: 152,
                                //   child: GestureDetector(
                                //     onTap: () {},
                                //     child: Container(
                                //       padding: const EdgeInsets.all(8),
                                //       decoration: BoxDecoration(
                                //         color: Colors.white.withOpacity(0.8),
                                //         shape: BoxShape.circle,
                                //       ),
                                //       child: Icon(
                                //         Icons.search,
                                //         color: Colors.blue.shade700,
                                //         size: 20,
                                //       ),
                                //     ),
                                //   ),
                                // ),
                                SizedBox(
                                  height: 220,
                                  child: Stack(
                                    children: [
                                      PageView.builder(
                                        scrollDirection: Axis.horizontal,
                                        controller: _pageController,
                                        itemCount:
                                            userDashboard!.data.slides.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return GestureDetector(
                                            onLongPress: () {
                                              setState(() {
                                                isLongPress = true;
                                              });
                                            },
                                            onLongPressEnd: (details) {
                                              setState(() {
                                                isLongPress = false;
                                              });
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                    userDashboard!.data
                                                        .slides[index].imageUrl
                                                        .toString(),
                                                  ),
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),

                                      // Search Button positioned at top-right corner
                                      Positioned(
                                        top: 12,
                                        right: 12,
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => Search(
                                                        token: widget.token!,
                                                        editLead:
                                                            updateLeadPermission1,
                                                        deleteLead:
                                                            deleteLeadPermission1,
                                                        cloudCall:
                                                            cloudCallPermission1,
                                                        leadType: '',
                                                      )),
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.search,
                                              color: Colors.blue.shade700,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Center(
                                  child: SmoothPageIndicator(
                                    controller: _pageController,
                                    count: userDashboard!.data.slides.length,
                                    effect: const WormEffect(
                                      dotHeight: 8,
                                      dotWidth: 8,
                                      type: WormType.thin,
                                      // strokeWidth: 5,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                TextScroll(
                                  userDashboard!.data.scrollingText.toString(),
                                  velocity: const Velocity(
                                      pixelsPerSecond: Offset(40, 0)),
                                  intervalSpaces: 10,
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                // Positioned(
                                //   top: 12,
                                //   right: 12,
                                //   child: GestureDetector(
                                //     onTap: () {
                                //     },
                                //     child: Container(
                                //       padding: const EdgeInsets.all(8),
                                //       decoration: BoxDecoration(
                                //         color: Colors.white.withOpacity(0.8),
                                //         shape: BoxShape.circle,
                                //       ),
                                //       child: Icon(
                                //         Icons.search,
                                //         color: Colors.blue.shade700,
                                //         size: 20,
                                //       ),
                                //     ),
                                //   ),
                                // ),
                                Visibility(
                                  visible: role == "Company Admin",
                                  child: Card(
                                    // Set the shape of the card using a rounded rectangle border with a 8 pixel radius
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    // Set the clip behavior of the card
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    // Define the child widgets of the card
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        // Display an image at the top of the card that fills the width of the card and has a height of 160 pixels
                                        Image.network(
                                          userDashboard!.data.image1.toString(),
                                          height: 160,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                        // Add a container with padding that contains the card's title, text, and buttons
                                        Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              15, 15, 15, 0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              // Display the card's title using a font size of 24 and a dark grey color
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    userDashboard!
                                                        .data.packageName
                                                        .toString(),
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      color: Colors.grey[800],
                                                    ),
                                                  ),
                                                  userDashboard!.data
                                                              .expireSoon ==
                                                          true
                                                      ? Container(
                                                          decoration: BoxDecoration(
                                                              color: const Color(
                                                                  0xFFd6ebff),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5)),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 8,
                                                                    right: 5,
                                                                    top: 4,
                                                                    bottom: 4),
                                                            child: Text(
                                                              userDashboard!
                                                                  .data
                                                                  .expireSoonContent
                                                                  .toString(),
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 11,
                                                                color:
                                                                    Colors.red,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              softWrap: false,
                                                            ),
                                                          ),
                                                        )
                                                      : const SizedBox(),
                                                ],
                                              ),
                                              // Add a space between the title and the text
                                              Container(height: 10),
                                              // Display the card's text using a font size of 15 and a light grey color
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Start Date',
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color:
                                                              Colors.grey[700],
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      Text(
                                                        userDashboard!
                                                            .data.startDate
                                                            .toString(),
                                                        style: const TextStyle(
                                                            fontSize: 15,
                                                            color: Colors.red,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'End Date',
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color:
                                                              Colors.grey[700],
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      Text(
                                                        userDashboard!
                                                            .data.endDate
                                                            .toString(),
                                                        style: const TextStyle(
                                                            fontSize: 15,
                                                            color: Colors.red,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                'Staff Count ( ${userDashboard!.data.currentStaff}/${userDashboard!.data.staffCount} )',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              StepProgressIndicator(
                                                selectedColor: Colors.green,
                                                totalSteps: userDashboard!
                                                    .data.staffCount,
                                                currentStep: userDashboard!
                                                    .data.currentStaff,
                                              ),
                                              // Add a row with two buttons spaced apart and aligned to the right side of the card
                                              Row(
                                                children: <Widget>[
                                                  // Add a spacer to push the buttons to the right side of the card
                                                  const Spacer(),
                                                  // Add a text button labeled "SHARE" with transparent foreground color and an accent color for the text

                                                  // Add a text button labeled "EXPLORE" with transparent foreground color and an accent color for the text
                                                  TextButton(
                                                    child: const Text(
                                                      "UPGRADE",
                                                    ),
                                                    onPressed: () {
                                                      _upgrade(context);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Add a small space between the card and the next widget
                                        Container(height: 5),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                GridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          crossAxisSpacing: 4,
                                          childAspectRatio: 1.3),
                                  padding: EdgeInsets.zero,
                                  itemCount: userDashboard!.data.modules.length,
                                  itemBuilder: (BuildContext context, i) {
                                    return Card(
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          side: const BorderSide(
                                            width: 1,
                                            color: Color(0xff5ecea8),
                                          )),
                                      child: InkWell(
                                        onTap: () async {
                                          if (configure!.data!.isExpired ==
                                              true) {
                                            _upgrade(context);
                                          } else {
                                            if (userDashboard!
                                                    .data.modules[i].menuName ==
                                                'call_management') {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        DashboardLeadNewUpdatedTwo(
                                                            widget.token)),
                                              );
                                            } else if (userDashboard!
                                                    .data.modules[i].menuName ==
                                                'Staff_management') {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ViewUsers(
                                                            widget.token)),
                                              );
                                            } else if (userDashboard!
                                                    .data.modules[i].menuName ==
                                                'Service') {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        DashboardPage()),
                                              );
                                            } else if (userDashboard!
                                                    .data.modules[i].menuName ==
                                                'Rent') {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        RentalDashboard(
                                                            name: name,
                                                            token:
                                                                widget.token!,
                                                            userId: userId,
                                                            phoneCallLogPermission:
                                                                phoneCallLogPermission,
                                                            custId: "")),
                                              );
                                            } else if (userDashboard!
                                                    .data.modules[i].menuName ==
                                                'Stock') {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        StockDashboard(
                                                            name: name,
                                                            token:
                                                                widget.token!,
                                                            userId: userId,
                                                            phoneCallLogPermission:
                                                                phoneCallLogPermission,
                                                            custId: "")),
                                              );
                                            } else if (userDashboard!
                                                    .data.modules[i].menuName ==
                                                'Purchase') {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        PurchaseDashboard(
                                                          name: name,
                                                          token: widget.token!,
                                                          userId: userId,
                                                          phoneCallLogPermission:
                                                              phoneCallLogPermission,
                                                          // custId: ""
                                                        )),
                                              );
                                            }
                                            //  else if (userDashboard!.data!
                                            //         .modules![i].menuName ==
                                            //     'messages') {
                                            //   Navigator.push(
                                            //     context,
                                            //     MaterialPageRoute(
                                            //         builder: (context) =>
                                            //             const ChatHomeScreen()),
                                            //   );
                                            // showDialog(
                                            //     barrierColor: Colors.grey
                                            //         .withOpacity(.5),
                                            //     context: context,
                                            //     builder:
                                            //         (BuildContext context) {
                                            //       return WillPopScope(
                                            //         onWillPop: () async {
                                            //           return true;
                                            //         },
                                            //         child: Material(
                                            //           type: MaterialType
                                            //               .transparency,
                                            //           child: Padding(
                                            //             padding:
                                            //                 const EdgeInsets
                                            //                     .only(
                                            //                     bottom: 50),
                                            //             child: Center(
                                            //               child: Container(
                                            //                 decoration:
                                            //                     BoxDecoration(
                                            //                   borderRadius:
                                            //                       BorderRadius
                                            //                           .circular(
                                            //                               10),
                                            //                   color: Colors
                                            //                       .white,
                                            //                 ),
                                            //                 width: MediaQuery.of(
                                            //                             context)
                                            //                         .size
                                            //                         .width *
                                            //                     0.9,
                                            //                 height: 250,
                                            //                 child: Padding(
                                            //                   padding:
                                            //                       const EdgeInsets
                                            //                           .only(
                                            //                           left:
                                            //                               20,
                                            //                           right:
                                            //                               20),
                                            //                   child: Column(
                                            //                     mainAxisAlignment:
                                            //                         MainAxisAlignment
                                            //                             .center,
                                            //                     crossAxisAlignment:
                                            //                         CrossAxisAlignment
                                            //                             .center,
                                            //                     children: [
                                            //                       Image.asset(
                                            //                         'assets/icons/official_whatsapp.png',
                                            //                         width: 80,
                                            //                       ),
                                            //                       const SizedBox(
                                            //                         height:
                                            //                             10,
                                            //                       ),
                                            //                       const Text(
                                            //                         'Whatsapp',
                                            //                         style: TextStyle(
                                            //                             fontSize:
                                            //                                 18,
                                            //                             fontWeight:
                                            //                                 FontWeight.w400),
                                            //                       ),
                                            //                       const SizedBox(
                                            //                         height: 5,
                                            //                       ),
                                            //                       const Text(
                                            //                         'Choose WhatsApp',
                                            //                         style: TextStyle(
                                            //                             fontSize:
                                            //                                 15,
                                            //                             fontWeight:
                                            //                                 FontWeight.w400),
                                            //                       ),
                                            //                       const SizedBox(
                                            //                         height:
                                            //                             15,
                                            //                       ),
                                            //                       Row(
                                            //                         mainAxisAlignment:
                                            //                             MainAxisAlignment
                                            //                                 .spaceBetween,
                                            //                         children: [
                                            //                           officialWhatsapp ==
                                            //                                   'true'
                                            //                               ? InkWell(
                                            //                                   onTap: () {
                                            //                                     Navigator.push(
                                            //                                       context,
                                            //                                       MaterialPageRoute(builder: (context) => const ChatHomeScreen()),
                                            //                                     );
                                            //                                   },
                                            //                                   child: Container(
                                            //                                     width: MediaQuery.of(context).size.width * 0.35,
                                            //                                     //  color: RandomColorModel().getColor(),
                                            //                                     decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(10)),
                                            //                                     child: const Padding(
                                            //                                       padding: EdgeInsets.all(5),
                                            //                                       child: Text('Official', style: TextStyle(fontSize: 13, color: Colors.black), textAlign: TextAlign.center),
                                            //                                     ),
                                            //                                   ),
                                            //                                 )
                                            //                               : const SizedBox(),
                                            //                           unOfficialWhatsapp ==
                                            //                                   'true'
                                            //                               ? InkWell(
                                            //                                   onTap: () {
                                            //                                     Navigator.push(
                                            //                                       context,
                                            //                                       MaterialPageRoute(builder: (context) => GroupList(widget.token)),
                                            //                                     );
                                            //                                   },
                                            //                                   child: Container(
                                            //                                     width: MediaQuery.of(context).size.width * 0.35,
                                            //                                     decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(10)),
                                            //                                     child: const Padding(
                                            //                                       padding: EdgeInsets.all(5),
                                            //                                       child: Text('Un Official', style: TextStyle(fontSize: 13, color: Colors.black), textAlign: TextAlign.center),
                                            //                                     ),
                                            //                                   ),
                                            //                                 )
                                            //                               : const SizedBox()
                                            //                         ],
                                            //                       ),
                                            //                       const SizedBox(
                                            //                         height: 8,
                                            //                       ),
                                            //                     ],
                                            //                   ),
                                            //                 ),
                                            //               ),
                                            //             ),
                                            //           ),
                                            //         ),
                                            //       );
                                            //     });
                                            // }
                                            else if (userDashboard!
                                                    .data.modules[i].menuName ==
                                                'Settings') {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        WhatsappSettings(
                                                            widget.token)),
                                              );
                                            } else if (userDashboard!.data
                                                        .modules[i].menuName ==
                                                    'Work' &&
                                                viewWorkReportPermission ==
                                                    "true") {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const ProjectDashboard(),
                                                ),
                                              );
                                            } else if (userDashboard!
                                                    .data.modules[i].menuName ==
                                                'file_manager') {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        FileMangerList(
                                                            widget.token)),
                                              );
                                            } else if (userDashboard!
                                                    .data.modules[i].menuName ==
                                                'customers') {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        CustomerDashboardHome(
                                                            token: widget.token!,
                                                            scaffoldKey: _scaffoldKey)),
                                              );
                                            } else if (userDashboard!
                                                    .data.modules[i].menuName ==
                                                'invoices') {
                                              // Navigator.push(
                                              //     context,
                                              //     MaterialPageRoute(
                                              //       builder: (context) =>
                                              //           AccountsDashboard(
                                              //         token: widget.token
                                              //             .toString(),
                                              //       ),
                                              //     ));
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        AccountsDashboardNew(
                                                      token: widget.token
                                                          .toString(),
                                                    ),
                                                  ));
                                            }

                                            // else if (userDashboard!
                                            //         .data.modules[i].menuName ==
                                            //     'quotation') {
                                            //   Navigator.push(
                                            //       context,
                                            //       MaterialPageRoute(
                                            //         builder: (context) =>
                                            //             QuotationPage(),
                                            //       ));
                                            //}
                                            else if (userDashboard!
                                                    .data.modules[i].menuName ==
                                                'quotation') {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        QuotationDashboard(),
                                                  ));
                                            } else if (userDashboard!
                                                    .data.modules[i].menuName ==
                                                'Staff Report') {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        StaffReport(
                                                            // token: widget.token
                                                            //     .toString(),
                                                            ),
                                                  ));
                                            } else if (userDashboard!
                                                    .data.modules[i].menuName ==
                                                'Target Report') {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ViewAllTargetReportPage(
                                                            id: userId),
                                                  ));
                                            } else if (userDashboard!
                                                    .data.modules[i].menuName ==
                                                'Total Lead Report') {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        AllReport(
                                                          widget.token!,
                                                          true,
                                                          true,
                                                          true,
                                                          pageName: 'AllLeads',
                                                        )),
                                              );
                                            } else if (userDashboard!
                                                    .data.modules[i].menuName ==
                                                'reports') {
                                              showDialog(
                                                  barrierColor: Colors.white
                                                      .withOpacity(.2),
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return WillPopScope(
                                                      onWillPop: () async {
                                                        return true;
                                                      },
                                                      child: Material(
                                                        type: MaterialType
                                                            .transparency,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 50),
                                                          child: Center(
                                                            child: Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.9,
                                                              height: 400,
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            20,
                                                                        right:
                                                                            20),
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Image.asset(
                                                                      'assets/icons/check.png',
                                                                      width: 80,
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          10,
                                                                    ),
                                                                    const Text(
                                                                      'Reports',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              18,
                                                                          fontWeight:
                                                                              FontWeight.w400),
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    const Text(
                                                                      'Choose Report',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              15,
                                                                          fontWeight:
                                                                              FontWeight.w400),
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          15,
                                                                    ),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        InkWell(
                                                                          onTap:
                                                                              () {
                                                                            Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(
                                                                                builder: (context) => ViewLeadsNew(
                                                                                  widget.token,
                                                                                  updateLeadPermission1,
                                                                                  deleteLeadPermission1,
                                                                                  cloudCallPermission1,
                                                                                  pageName: 'All Leads',
                                                                                  isAllLeads: "1",
                                                                                  fromDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                                                                                  toDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                                                                                ),
                                                                              ),
                                                                              // MaterialPageRoute(
                                                                              //     builder: (context) => AllReportNew(
                                                                              //           widget.token!,
                                                                              //           true,
                                                                              //           true,
                                                                              //           true,
                                                                              //           pageName: 'AllLeads',
                                                                              //         )),
                                                                            );
                                                                            // Navigator.of(
                                                                            //     context)
                                                                            //     .push(
                                                                            //   MaterialPageRoute(
                                                                            //       builder: (context) =>
                                                                            //           Dashboard(widget.token)),
                                                                            // );
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            width:
                                                                                MediaQuery.of(context).size.width * 0.38,
                                                                            //  color: RandomColorModel().getColor(),
                                                                            decoration:
                                                                                BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(10)),
                                                                            child:
                                                                                const Padding(
                                                                              padding: EdgeInsets.all(5),
                                                                              child: Column(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                children: [
                                                                                  Icon(
                                                                                    Icons.dashboard,
                                                                                    size: 15,
                                                                                  ),
                                                                                  SizedBox(
                                                                                    height: 5,
                                                                                  ),
                                                                                  Text('Lead Report', style: TextStyle(fontSize: 13, color: Colors.black), textAlign: TextAlign.center),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        InkWell(
                                                                          onTap:
                                                                              () {
                                                                            Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(
                                                                                  builder: (context) => ViewLeadsNew(
                                                                                        widget.token!,
                                                                                        true,
                                                                                        true,
                                                                                        true,
                                                                                        pageName: 'transferLeads',
                                                                                        status: '0',
                                                                                        leadType: '2',
                                                                                        callStatus: '-2',
                                                                                      )),
                                                                            );
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            width:
                                                                                MediaQuery.of(context).size.width * 0.38,
                                                                            decoration:
                                                                                BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(10)),
                                                                            child:
                                                                                const Padding(
                                                                              padding: EdgeInsets.all(5),
                                                                              child: Column(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                children: [
                                                                                  Icon(
                                                                                    Icons.list_alt,
                                                                                    size: 15,
                                                                                  ),
                                                                                  SizedBox(
                                                                                    height: 5,
                                                                                  ),
                                                                                  Text('Transfer Report', style: TextStyle(fontSize: 13, color: Colors.black), textAlign: TextAlign.center),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),

                                                                        // InkWell(
                                                                        //   onTap:
                                                                        //       () {
                                                                        //     Navigator.push(
                                                                        //       context,
                                                                        //       MaterialPageRoute(
                                                                        //           builder: (context) => TransferLeadReport(
                                                                        //                 widget.token!,
                                                                        //                 true,
                                                                        //                 true,
                                                                        //                 true,
                                                                        //                 pageName: 'transferLeads',
                                                                        //               )),
                                                                        //     );
                                                                        //   },
                                                                        //   child:
                                                                        //       Container(
                                                                        //     width:
                                                                        //         MediaQuery.of(context).size.width * 0.38,
                                                                        //     decoration:
                                                                        //         BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(10)),
                                                                        //     child:
                                                                        //         const Padding(
                                                                        //       padding: EdgeInsets.all(5),
                                                                        //       child: Column(
                                                                        //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                        //         children: [
                                                                        //           Icon(
                                                                        //             Icons.list_alt,
                                                                        //             size: 15,
                                                                        //           ),
                                                                        //           SizedBox(
                                                                        //             height: 5,
                                                                        //           ),
                                                                        //           Text('Lead Category Report', style: TextStyle(fontSize: 13, color: Colors.black), textAlign: TextAlign.center),
                                                                        //         ],
                                                                        //       ),
                                                                        //     ),
                                                                        //   ),
                                                                        // ),
                                                                        // InkWell(
                                                                        //   onTap:
                                                                        //       () {
                                                                        //     Navigator.push(
                                                                        //       context,
                                                                        //       MaterialPageRoute(
                                                                        //           builder: (context) => TransferLeadReport(
                                                                        //                 widget.token!,
                                                                        //                 true,
                                                                        //                 true,
                                                                        //                 true,
                                                                        //                 pageName: 'transferLeads',
                                                                        //               )),
                                                                        //     );
                                                                        //   },
                                                                        //   child:
                                                                        //       Container(
                                                                        //     width:
                                                                        //         MediaQuery.of(context).size.width * 0.38,
                                                                        //     decoration:
                                                                        //         BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(10)),
                                                                        //     child:
                                                                        //         const Padding(
                                                                        //       padding: EdgeInsets.all(5),
                                                                        //       child: Column(
                                                                        //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                        //         children: [
                                                                        //           Icon(
                                                                        //             Icons.list_alt,
                                                                        //             size: 15,
                                                                        //           ),
                                                                        //           SizedBox(
                                                                        //             height: 5,
                                                                        //           ),
                                                                        //           Text('Lead Status Staffwise', style: TextStyle(fontSize: 13, color: Colors.black), textAlign: TextAlign.center),
                                                                        //         ],
                                                                        //       ),
                                                                        //     ),
                                                                        //   ),
                                                                        // ),
                                                                        // InkWell(
                                                                        //   onTap:
                                                                        //       () {
                                                                        //     Navigator.push(
                                                                        //       context,
                                                                        //       MaterialPageRoute(
                                                                        //           builder: (context) => TransferLeadReport(
                                                                        //                 widget.token!,
                                                                        //                 true,
                                                                        //                 true,
                                                                        //                 true,
                                                                        //                 pageName: 'transferLeads',
                                                                        //               )),
                                                                        //     );
                                                                        //   },
                                                                        //   child:
                                                                        //       Container(
                                                                        //     width:
                                                                        //         MediaQuery.of(context).size.width * 0.38,
                                                                        //     decoration:
                                                                        //         BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(10)),
                                                                        //     child:
                                                                        //         const Padding(
                                                                        //       padding: EdgeInsets.all(5),
                                                                        //       child: Column(
                                                                        //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                        //         children: [
                                                                        //           Icon(
                                                                        //             Icons.list_alt,
                                                                        //             size: 15,
                                                                        //           ),
                                                                        //           SizedBox(
                                                                        //             height: 5,
                                                                        //           ),
                                                                        //           Text('Rejected Reason Staffwise', style: TextStyle(fontSize: 13, color: Colors.black), textAlign: TextAlign.center),
                                                                        //         ],
                                                                        //       ),
                                                                        //     ),
                                                                        //   ),
                                                                        // ),
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                      height: 8,
                                                                    ),
                                                                    Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          InkWell(
                                                                            onTap:
                                                                                () {
                                                                              Navigator.push(
                                                                                  context,
                                                                                  MaterialPageRoute(
                                                                                    builder: (context) => StaffReport(
                                                                                        // token: widget.token
                                                                                        //     .toString(),
                                                                                        ),
                                                                                  ));
                                                                            },
                                                                            child:
                                                                                Container(
                                                                              width: MediaQuery.of(context).size.width * 0.38,
                                                                              decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(10)),
                                                                              child: const Padding(
                                                                                padding: EdgeInsets.all(5),
                                                                                child: Column(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                  children: [
                                                                                    Icon(
                                                                                      Icons.list_alt,
                                                                                      size: 15,
                                                                                    ),
                                                                                    SizedBox(
                                                                                      height: 5,
                                                                                    ),
                                                                                    Text('Staff Report', style: TextStyle(fontSize: 13, color: Colors.black), textAlign: TextAlign.center),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                15,
                                                                          ),
                                                                          InkWell(
                                                                            onTap:
                                                                                () {
                                                                              Navigator.push(
                                                                                context,
                                                                                MaterialPageRoute(
                                                                                  builder: (context) => ViewAllTargetReportPage(id: userId),
                                                                                ),
                                                                              );
                                                                            },
                                                                            child:
                                                                                Container(
                                                                              width: MediaQuery.of(context).size.width * 0.38,
                                                                              decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(10)),
                                                                              child: const Padding(
                                                                                padding: EdgeInsets.all(5),
                                                                                child: Column(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                  children: [
                                                                                    Icon(
                                                                                      Icons.track_changes,
                                                                                      size: 15,
                                                                                    ),
                                                                                    SizedBox(
                                                                                      height: 5,
                                                                                    ),
                                                                                    Text('Target Report', style: TextStyle(fontSize: 13, color: Colors.black), textAlign: TextAlign.center),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          // InkWell(
                                                                          //   onTap:
                                                                          //       () {
                                                                          //     Navigator.push(
                                                                          //       context,
                                                                          //       MaterialPageRoute(
                                                                          //         builder: (context) => DetailedReportsPage(
                                                                          //           token: widget.token!,
                                                                          //           fromDate: fromdate,
                                                                          //           toDate: todate,
                                                                          //           fromDate1: fromdate1,
                                                                          //           toDate1: todate1,
                                                                          //           updateLeadPermission1: updateLeadPermission1,
                                                                          //           deleteLeadPermission1: deleteLeadPermission1,
                                                                          //           cloudCallPermission1: cloudCallPermission1,
                                                                          //           viewLeadPermission: viewLeadPermission,
                                                                          //         ),
                                                                          //       ),
                                                                          //     );
                                                                          //   },
                                                                          //   child:
                                                                          //       Container(
                                                                          //     width: MediaQuery.of(context).size.width * 0.38,
                                                                          //     decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(10)),
                                                                          //     child: const Padding(
                                                                          //       padding: EdgeInsets.all(5),
                                                                          //       child: Column(
                                                                          //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                          //         children: [
                                                                          //           Icon(
                                                                          //             Icons.list_alt,
                                                                          //             size: 15,
                                                                          //           ),
                                                                          //           SizedBox(
                                                                          //             height: 5,
                                                                          //           ),
                                                                          //           Text('Detailed Report', style: TextStyle(fontSize: 13, color: Colors.black), textAlign: TextAlign.center),
                                                                          //         ],
                                                                          //       ),
                                                                          //     ),
                                                                          //   ),
                                                                          // ),
                                                                        ]),
                                                                    // const SizedBox(
                                                                    //   height: 8,
                                                                    // ),
                                                                    // Row(
                                                                    //     mainAxisAlignment:
                                                                    //         MainAxisAlignment.spaceBetween,
                                                                    //     children: [
                                                                    //       InkWell(
                                                                    //         onTap:
                                                                    //             () {
                                                                    //           Navigator.push(
                                                                    //               context,
                                                                    //               MaterialPageRoute(
                                                                    //                 builder: (context) => FollowupCalendarPage(
                                                                    //                     // token: widget.token
                                                                    //                     //     .toString(),
                                                                    //                     ),
                                                                    //               ));
                                                                    //         },
                                                                    //         child:
                                                                    //             Container(
                                                                    //           width: MediaQuery.of(context).size.width * 0.38,
                                                                    //           decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(10)),
                                                                    //           child: const Padding(
                                                                    //             padding: EdgeInsets.all(5),
                                                                    //             child: Column(
                                                                    //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                    //               children: [
                                                                    //                 Icon(
                                                                    //                   Icons.calendar_month,
                                                                    //                   size: 15,
                                                                    //                 ),
                                                                    //                 SizedBox(
                                                                    //                   height: 5,
                                                                    //                 ),
                                                                    //                 Text('Followup Calendar', style: TextStyle(fontSize: 13, color: Colors.black), textAlign: TextAlign.center),
                                                                    //               ],
                                                                    //             ),
                                                                    //           ),
                                                                    //         ),
                                                                    //       ),
                                                                    //       SizedBox(
                                                                    //         width:
                                                                    //             15,
                                                                    //       ),
                                                                    //       InkWell(
                                                                    //         onTap:
                                                                    //             () {
                                                                    //           Navigator.push(
                                                                    //               context,
                                                                    //               MaterialPageRoute(
                                                                    //                 builder: (context) => StaffWiseCallReport(),
                                                                    //               ));
                                                                    //         },
                                                                    //         child:
                                                                    //             Container(
                                                                    //           width: MediaQuery.of(context).size.width * 0.38,
                                                                    //           decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(10)),
                                                                    //           child: const Padding(
                                                                    //             padding: EdgeInsets.all(5),
                                                                    //             child: Column(
                                                                    //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                    //               children: [
                                                                    //                 Icon(
                                                                    //                   Icons.call,
                                                                    //                   size: 15,
                                                                    //                 ),
                                                                    //                 SizedBox(
                                                                    //                   height: 5,
                                                                    //                 ),
                                                                    //                 Text('Call Report', style: TextStyle(fontSize: 13, color: Colors.black), textAlign: TextAlign.center),
                                                                    //               ],
                                                                    //             ),
                                                                    //           ),
                                                                    //         ),
                                                                    //       ),
                                                                    //       //  SizedBox(
                                                                    //       //   width:
                                                                    //       //       15,
                                                                    //       // ),
                                                                    //     ]),
                                                                    // const SizedBox(
                                                                    //   height: 8,
                                                                    // ),
                                                                    // Row(
                                                                    //     mainAxisAlignment:
                                                                    //         MainAxisAlignment.spaceBetween,
                                                                    //     children: [
                                                                    //       InkWell(
                                                                    //         onTap:
                                                                    //             () {
                                                                    //           Navigator.push(
                                                                    //             context,
                                                                    //             MaterialPageRoute(
                                                                    //               builder: (context) => ViewAllTargetReportPage(id: userId),
                                                                    //             ),
                                                                    //           );
                                                                    //         },
                                                                    //         child:
                                                                    //             Container(
                                                                    //           width: MediaQuery.of(context).size.width * 0.38,
                                                                    //           decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(10)),
                                                                    //           child: const Padding(
                                                                    //             padding: EdgeInsets.all(5),
                                                                    //             child: Column(
                                                                    //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                    //               children: [
                                                                    //                 Icon(
                                                                    //                   Icons.track_changes,
                                                                    //                   size: 15,
                                                                    //                 ),
                                                                    //                 SizedBox(
                                                                    //                   height: 5,
                                                                    //                 ),
                                                                    //                 Text('Target Report', style: TextStyle(fontSize: 13, color: Colors.black), textAlign: TextAlign.center),
                                                                    //               ],
                                                                    //             ),
                                                                    //           ),
                                                                    //         ),
                                                                    //       ),
                                                                    //     ]),
                                                                    // const SizedBox(
                                                                    //   height: 8,
                                                                    // ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  });
                                            } else if (userDashboard!
                                                    .data.modules[i].menuName ==
                                                'complaints') {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const ComplaintListScreen()));
                                            } else if (userDashboard!
                                                    .data.modules[i].menuName ==
                                                'Attendance') {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return Dialog(
                                                    elevation: 8,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.85,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 24,
                                                          horizontal: 16),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Stack(
                                                            children: [
                                                              const Center(
                                                                child: Text(
                                                                  "Attendance Options",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        20,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Color(
                                                                        0xFF1E293B),
                                                                  ),
                                                                ),
                                                              ),
                                                              Positioned(
                                                                right: 0,
                                                                child:
                                                                    GestureDetector(
                                                                  onTap: () =>
                                                                      Navigator.pop(
                                                                          context),
                                                                  child:
                                                                      Container(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            4),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                          .grey
                                                                          .shade200,
                                                                      shape: BoxShape
                                                                          .circle,
                                                                    ),
                                                                    child:
                                                                        const Icon(
                                                                      Icons
                                                                          .close,
                                                                      size: 18,
                                                                      color: Color(
                                                                          0xFF64748B),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              height: 24),

                                                          // Animated options
                                                          TweenAnimationBuilder(
                                                            tween:
                                                                Tween<double>(
                                                                    begin: 0,
                                                                    end: 1),
                                                            duration:
                                                                const Duration(
                                                                    milliseconds:
                                                                        400),
                                                            curve: Curves
                                                                .easeOutCubic,
                                                            builder: (context,
                                                                double value,
                                                                child) {
                                                              return Opacity(
                                                                opacity: value,
                                                                child: Transform
                                                                    .translate(
                                                                  offset: Offset(
                                                                      0,
                                                                      20 *
                                                                          (1 -
                                                                              value)),
                                                                  child: child,
                                                                ),
                                                              );
                                                            },
                                                            child: Column(
                                                              children: [
                                                                // Salary Report Option
                                                                _buildOptionCard(
                                                                  icon: Icons
                                                                      .receipt_long,
                                                                  iconColor:
                                                                      Colors
                                                                          .blue,
                                                                  title:
                                                                      "Salary Report",
                                                                  subtitle:
                                                                      "View your salary details and history",
                                                                  onTap: () {
                                                                    Navigator.pop(
                                                                        context);
                                                                    Navigator
                                                                        .push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                const SalaryReportPage(),
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                                const SizedBox(
                                                                    height: 12),

                                                                // Leave Request Option
                                                                _buildOptionCard(
                                                                  icon: Icons
                                                                      .calendar_month,
                                                                  iconColor:
                                                                      Colors
                                                                          .green,
                                                                  title:
                                                                      "Leave Request",
                                                                  subtitle:
                                                                      "Apply for leave or check status",
                                                                  onTap: () {
                                                                    Navigator.pop(
                                                                        context);
                                                                    Navigator
                                                                        .push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                const LeaveRequestListPage(),
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            } else if (userDashboard!
                                                    .data.modules[i].menuName ==
                                                'renewal') {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const RenewalDashboard()));
                                            } else if (userDashboard!
                                                    .data.modules[i].menuName ==
                                                'room_management') {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const RoomDashboard()));
                                            } else if (userDashboard!
                                                    .data.modules[i].menuName ==
                                                'products') {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProductList(
                                                      catId: "widget.catId",
                                                      subCatId: "11",
                                                      title: "",
                                                      subCat: " widget.title",
                                                    ),
                                                  ));
                                            } else if (userDashboard!
                                                    .data.modules[i].menuName ==
                                                'whatsapp') {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const ChatHomeScreen()),
                                              );
                                            } else {
                                              _dialogue(context,
                                                  'Access ${userDashboard!.data.modules[i].categoryName}');
                                            }
                                          }
                                        },
                                        child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            child: CachedNetworkImage(
                                              fit: BoxFit.fill,
                                              imageUrl: userDashboard!
                                                  .data.modules[i].image
                                                  .toString(),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(Icons.error),
                                            )),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                              ],
                            )),
                      )
                    : Center(
                        child: Lottie.asset('assets/main/loading.json',
                            fit: BoxFit.fill),
                      ),
                endDrawer: DraweScreen(widget.token!),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerDocked,
                floatingActionButton: FloatingActionButton(
                  backgroundColor: Color(0xFF2a86c9),
                  onPressed: () {
                    // MenuDashboard =="true"?
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //       builder: (context) => HomePage(widget.token)),
                    // ): Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //       builder: (context) => Dashboard(widget.token)),
                    // );
                    ProjectDashboardPermission == "true"
                        ? Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProjectDashboard()),
                          )
                        : AccountsDashboardPermission == "true"
                            ? Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        AccountsDashboard(token: token)),
                              )
                            : MenuDashboard == "true"
                                ? Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => HomePage(token)),
                                  )
                                : RenewalDashboardPermission == "true"
                                    ? Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                RenewalDashboard()),
                                      )
                                    : NewleadDashboardPermission == "true"
                                        ? Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    MinimalDashboard(token)),
                                          )
                                        : Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    DashboardLeadNewUpdatedTwo(
                                                        token)),
                                          );
                  },
                  child: Image.asset("assets/icons/menu.png",
                      width: 25), //icon inside button
                ),
                bottomNavigationBar: configure != null
                    ? BottomNavigation(widget.token!,
                        phoneCallLogPermission: phoneCallLogPermission)
                    : const SizedBox())
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
                      const Text(
                        'No Network Found !',
                        style: TextStyle(
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
                )),
      ),
    );
  }

  void showLoginPrompt(BuildContext context) {
    String? faceBase64;
    String faceDetection = "true";
    String companyLocation = "true";

    // Future<void> captureFace() async {
    //   final faceImage = await Navigator.of(context).push<File>(
    //     MaterialPageRoute(
    //       builder: (_) => FaceDetectionCamera(
    //         onFaceCaptured: (File imageFile) {
    //           Navigator.of(context).pop(imageFile);
    //         },
    //       ),
    //     ),
    //   );

    //   if (faceImage != null && context.mounted) {
    //     final faceHash = await generateFaceHash(faceImage);
    //     if (faceHash == null) {
    //       Common.toastMessaage('Face hash failed', Colors.red);
    //       return;
    //     }
    //     faceBase64 = faceHash;
    //   }
    // }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Not logged in today"),
          content: const Text("Do you want to log in now?"),
          actions: [
            TextButton(
              child: const Text("Not now"),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                final today = DateTime.now().toIso8601String().substring(0, 10);
                await prefs.setString('loginPromptDismissedDate', today);
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, foregroundColor: Colors.white),
              child: const Text("Yes"),
              onPressed: () async {
                Navigator.of(dialogContext).pop();

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  barrierColor: Colors.black.withOpacity(0.3), // Dim background
                  builder: (_) => Dialog(
                    backgroundColor:
                        Colors.white.withOpacity(0.8), // Transparent white
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 50,
                            width: 50,
                            child: Lottie.asset(
                              'assets/lottie/location_loader.json',
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            "Logging In...",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );

                try {
                  faceDetection =
                      await Common.getSharedPref("faceDetection") ?? "false";
                  companyLocation =
                      await Common.getSharedPref("companyLocation") ?? "false";
                  LocationPermission permission =
                      await Geolocator.checkPermission();
                  if (permission == LocationPermission.denied) {
                    permission = await Geolocator.requestPermission();
                    if (permission == LocationPermission.denied) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Location permission denied.")),
                      );
                      return;
                    }
                  }
                  if (permission == LocationPermission.deniedForever) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              "Location permission permanently denied. Please enable from settings.")),
                    );
                    return;
                  }

                  final position = await Geolocator.getCurrentPosition(
                    desiredAccuracy: LocationAccuracy.high,
                  );
                  if (companyLocation == "true") {
                    final companyResponse =
                        await HttpService.getCompanyLocations();
                    if (companyResponse == null ||
                        companyResponse.status != true) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text("Failed to fetch company locations.")),
                      );
                      return;
                    }

                    final String rawLocations = companyResponse.data.location;
                    final List<String> locationStrings = rawLocations
                        .replaceAll('{', '')
                        .split('},')
                        .map((e) => e.replaceAll('}', '').trim())
                        .where((e) => e.isNotEmpty)
                        .toList();

                    bool isWithinRange = false;
                    const double maxDistanceMeters = 100;

                    for (final locStr in locationStrings) {
                      final parts = locStr.split(',');
                      if (parts.length == 2) {
                        final double? lat = double.tryParse(parts[0].trim());
                        final double? lng = double.tryParse(parts[1].trim());
                        if (lat != null && lng != null) {
                          final double distance = Geolocator.distanceBetween(
                              position.latitude, position.longitude, lat, lng);
                          if (distance <= maxDistanceMeters) {
                            isWithinRange = true;
                            break;
                          }
                        }
                      }
                    }

                    if (!isWithinRange) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                "You are not within $maxDistanceMeters meters of company location.")),
                      );
                      return;
                    }
                  }
                  // if (faceDetection == "true") {
                  //   await captureFace();
                  //   if (faceBase64 == null || faceBase64!.isEmpty) {
                  //     Navigator.of(context).pop();
                  //     Common.toastMessaage(
                  //         'Face capture required for login', Colors.red);
                  //     return;
                  //   }
                  // }
                  final now = DateTime.now();
                  final res = await HttpService.startWork(
                    now,
                    latitude: position.latitude,
                    longitude: position.longitude,
                    faceData: faceBase64,
                  );
                  Navigator.of(context).pop();
                  if (res != null && res.status == true) {
                    await Common.saveSharedPref("is_work_started", "true");

                    setState(() => isWorkStarted = true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            "Log in at ${DateFormat('hh:mm a').format(now)}"),
                        backgroundColor: Colors.green,
                      ),
                    );
                    if (!context.mounted) return;
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //       builder: (_) => Dashboard(widget.token)),
                    // );
                    ProjectDashboardPermission == "true"
                        ? Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProjectDashboard()),
                          )
                        : AccountsDashboardPermission == "true"
                            ? Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AccountsDashboard(
                                        token: widget.token!)),
                              )
                            : MenuDashboard == "true"
                                ? Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            HomePage(widget.token)),
                                  )
                                : RenewalDashboardPermission == "true"
                                    ? Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                RenewalDashboard()),
                                      )
                                    : NewleadDashboardPermission == "true"
                                        ? Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    MinimalDashboard(
                                                        widget.token)),
                                          )
                                        : Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    DashboardLeadNewUpdatedTwo(
                                                        widget.token)),
                                          );
                  } else {
                    showError(res?.message ?? "Failed to start work");
                  }
                } catch (e) {
                  Navigator.of(context).pop();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: $e")),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _dialogue(BuildContext context, title) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text('Alert !!!'),
            content: const Text(
                'You have no permission to access the feature please contact the support team'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close')),
            ],
          );
        });
  }

  void _upgrade(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text('Upgrade Package !!!'),
            content: const Text(
                'Please contact the support team to upgrade your current plan'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close')),
              TextButton(
                  onPressed: () async {
                    String url = 'tel:${configure!.data!.supportTeamNumber}';
                    await launch(url);
                  },
                  child: const Text('Call'))
            ],
          );
        });
  }

  // Helper widget for option cards
  Widget _buildOptionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Icon with background
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow icon
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _exitApp(BuildContext context) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Warning"),
        content: const Text("Are you sure to exit app?"),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
            },
            child: const Text("No"),
          ),
          ElevatedButton(
            onPressed: () {
              exit(0);
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
    return null;
  }
}

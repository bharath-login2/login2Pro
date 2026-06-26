import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:call_e_log/call_log.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:login2/hive/call_logs/HiveCaallHistoryModel.dart';
import 'package:login2/hive/call_logs/call_logs_hive_functions.dart';
import 'package:login2/models/callLogs/callLogUploadModel.dart';
import 'package:login2/models/expense/account_dashboard.dart';
import 'package:login2/models/lead_management/leadCategoryStaffWiseModel.dart';
import 'package:login2/models/lead_management/newLeadDashboardModel.dart';
import 'package:login2/models/renewal/renewal_dashboard_model.dart';
import 'package:login2/screens/accounts/dashboard/account_head.dart';
import 'package:login2/screens/accounts/dashboard/accounts_dashboard.dart';
import 'package:login2/screens/accounts/dashboard/bank_account.dart';
import 'package:login2/screens/accounts/expense/advance&expense.dart';
import 'package:login2/screens/accounts/expense/expense_list.dart';
import 'package:login2/screens/accounts/renewal_mannagement/custom_renewal.dart';
import 'package:login2/screens/accounts/renewal_mannagement/renewal_followup_list.dart';
import 'package:login2/screens/accounts/renewal_mannagement/renewal_list.dart';
import 'package:login2/screens/authentication/face_detection_camera.dart';
import 'package:login2/screens/complaints/complaint_list_screen.dart';
import 'package:login2/screens/homePage.dart';
import 'package:login2/screens/leadManagement/AssignReport.dart';
import 'package:login2/screens/leadManagement/ViewAllTargetReportPage.dart';
import 'package:login2/screens/leadManagement/addWork_page.dart';
import 'package:login2/screens/leadManagement/allReport.dart';
import 'package:login2/screens/accounts/renewal_mannagement/renewal_dashboard.dart';
import 'package:login2/screens/leadManagement/attendanceCalendar.dart';
import 'package:login2/screens/leadManagement/pendingWorkPage.dart';
import 'package:login2/screens/leadManagement/projectDashboard.dart';
import 'package:login2/screens/leadManagement/salaryReportPage.dart';
import 'package:login2/screens/leadManagement/transferLeadReport.dart';
import 'package:login2/screens/leadManagement/viewallcompanyworks.dart';
import 'package:login2/screens/leadManagement/viewwork_page.dart';
import 'package:login2/screens/officialWhatsapp/colorConst.dart';
import 'package:login2/screens/product_mannagement/product_list.dart';
import 'package:login2/screens/search/search.dart';
import 'package:login2/screens/staff_reports/staff_dashboard.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:app_settings/app_settings.dart';
import '../../core/common.dart';
import '../../models/commonConfigureModel.dart';
import '../../models/dashboardModel.dart';
import '../../models/expense/expense_post.dart';
import '../../models/lead_management/leadDashboardModel.dart';
import '../../models/lead_management/leadProgressbarModel.dart';
import '../../models/lead_management/projectList_model.dart';
import '../../models/lead_management/workstatus_model.dart';
import '../../models/loginCheckModel.dart';
import '../../screens/authentication/login.dart';
import '../../widgets/renewal_grid_widget.dart';
import '../../widgets/togglebutton_start.dart';
import '../bottom_navigation_bar.dart';
import '../../screens/drawerScreen.dart';
import '../staff_reports/timeline_page.dart';
import 'add_leads.dart';
import '../../screens/leadManagement/callHistoryPage.dart';
import '../../screens/leadManagement/viewLeadCategory.dart';
import '../../screens/leadManagement/viewLeads.dart';
import '../../screens/settings/notificationTemplateSettings.dart';
import '../../screens/settings/whatsappSettings.dart';
import '../../service/service.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../callLogs/callLogs.dart';
import '../accounts/clients/clientList.dart';
import '../accounts/clients/invoiceList.dart';
import '../accounts/clients/pendingInvoice.dart';
import '../accounts/clients/receiptList.dart';
import '../fileManager/fileManagerList.dart';
import '../officialWhatsapp/chat_home_screen.dart';
import '../userManagement/viewUsers.dart';
import 'notification_page.dart';
import '../authentication/deep_link_handler.dart';

// ignore: must_be_immutable
class MinimalDashboard extends StatefulWidget {
  String? token;
  final GlobalKey<_MinimalDashboardState>? dashboardKey;
  MinimalDashboard(this.token, {super.key, this.dashboardKey});

  @override
  State<MinimalDashboard> createState() => _MinimalDashboardState();
}

class _MinimalDashboardState extends State<MinimalDashboard> {
  final _toolTipKey = GlobalKey<State<Tooltip>>();
  final _toolTipKey1 = GlobalKey<State<Tooltip>>();
  final _toolTipKey2 = GlobalKey<State<Tooltip>>();
  final _toolTipKey3 = GlobalKey<State<Tooltip>>();
  final _toolTipKey4 = GlobalKey<State<Tooltip>>();
  final _toolTipKey5 = GlobalKey<State<Tooltip>>();
  bool? result = true;
  bool? result1 = true;
  bool timeOut = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, double> data = {};
  LeadDashboardModel? leadDashboard;
  // NewLeadDashboard? leadDashboardNew;
  NewLeadDashboard? newLeadsDashboard;
  NewLeadDashboard? followupLeadsDashboard;
  NewLeadDashboard? closedLeadsDashboard;
  NewLeadDashboard? totalCalledDashboard;
  NewLeadDashboard? transferredLeadsDashboard;
  NewLeadDashboard? missedLeadsDashboard;

  CommonConfigureModel? configure;
  LeadCategoryStaffWiseModel? staffWise;
  DashboardModel? userDashboard;
  RenewalDashboardModel? renewalDashboard;
  ProjectList? projectList;
  WorkStatusModel? workStatus;
  CommonResponse? loginOrNot;
  DateTime? createdAt;
  bool isExpired = false;
  String accPermission = "";
  String renewalPermission = "true";
  bool isWorkStarted = false;
  String startOrStop = "";
  String loggedinOnce = "";

  var fromdate = DateTime.now();
  var todate = DateTime.now();
  var fromdate1 =
      DateTime(DateTime.now().year, DateTime.now().month, 1).toString();
  var todate1 = DateTime.now();
  var outputFormat = DateFormat('dd-MM-yyyy');
  String name = '';
  String role = '';
  String userId = '';
  String staffId = '';
  String callLogPermission = '';
  bool _showClosedLeadsCount = false;
  bool _showTotalCalledCount = false;
  bool _showTransferredLeadsCount = false;
  bool _showMissedLeadsCount = false;
  bool _isLoadingFollowupLeads = false;
  bool _isLoadingClosedLeads = false;
  bool _isLoadingTotalCalled = false;
  bool _isLoadingTransferredLeads = false;
  int id = 0;
  String navigationActionId = 'id_3';
  String createLeadPermission = '';
  String viewLeadPermission = '';
  String viewAllWorkPermission = '';
  String viewTargetReportPermission = '';
  String addWorkPermission = '';
  String startAndStopWorkPermission = '';
  String adminCheckPermission = '';
  String multipleUsersCheck = '';
  String multipleWorksCheck = '';
  String viewWorkReportPermission = '';
  String hasPhonecallAccess = '';
  String updateLeadPermission = '';
  String deleteLeadPermission = '';
  String phoneCallLogPermission = '';
  String accessCallHistoryPermission = '';
  String viewLeadCategoryPermission = '';
  String cloudCallPermission = '';
  String createLeadCategory = '';
  String updateLeadCategory = '';
  String deleteLeadCategory = '';
  String startAndStopWork = '';
  String accessCallRecordingPermission = '';
  String visibleP = '';
  bool updateLeadPermission1 = false;
  bool deleteLeadPermission1 = false;
  bool cloudCallPermission1 = false;
  bool createLeadCategory1 = false;
  bool updateLeadCategory1 = false;
  bool deleteLeadCategory1 = false;
  bool accessCallRecordingPermission1 = false;
  bool isVisible = true;
  bool loadmore = false;
  bool moreloading = false;
  // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  //     FlutterLocalNotificationsPlugin();
  final StreamController<String?> selectNotificationStream =
      StreamController<String?>.broadcast();
  String sound = '';
  int notificationCount = 0;
  String? firebaseToken;
  String officialWhatsapp = '';
  String unOfficialWhatsapp = '';
  int catNew = 0;
  int catPending = 0;
  int catFollowup = 0;
  int catRejected = 0;
  int catClosed = 0;
  int stfNew = 0;
  int stfPending = 0;
  int stfFollowup = 0;
  int stfRejected = 0;
  int stfClosed = 0;
  String thisMonth = "";
  String prevMonth = "";
  String? _faceBase64;
  LeadProgressbarModel? object1;
  bool isLoading = true;
  AccountDashboardModel? accountDashboard;
  String? ProjectDashboardPermission;
  String? AccountsDashboardPermission;
  String? MenuDashboard;
  bool _showNewLeadsCount = false;
  bool _showFollowupLeadsCount = false;
  //bool _showMissedLeadsCount = false;

  bool _isLoadingNewLeads = false;

  bool _isLoadingMissedLeads = false;
  String? RenewalDashboardPermission;
  String fDate = DateFormat('dd-MM-yyyy')
      .format(DateTime(DateTime.now().year, DateTime.now().month, 1));
  String tDate = DateFormat('dd-MM-yyyy')
      .format(DateTime(DateTime.now().year, DateTime.now().month + 1, 0));
  bool toggle = false;
  List list = [
    "Invoices",
    "Pending Invoices",
    "Receipts",
    "Expense",
    "Customers",
    "Account Head"
  ];
  List tabColors = [
    Colors.green,
    Colors.orange,
    Colors.blue,
    Colors.red,
    Colors.teal,
    Colors.purple,
  ];
  List colorList = [
    const Color(0xFFddd8f5),
    const Color(0xFFf0ebef),
    const Color(0xFFd7e9f4),
    const Color(0xFFf5e6d7),
    const Color(0xFFdbe4e8),
    const Color(0xFFf3d6d5),
    const Color(0xFFe0f0c8),
    const Color(0xFFf3e8d3),
  ];

  final List<Color> _colors = [
    Colors.redAccent,
    Colors.teal,
    Colors.blueAccent,
    Colors.purple,
    Colors.indigo,
    Colors.brown,
    Colors.teal,
    Colors.black,
    Colors.green,
    Colors.blueGrey,
    Colors.lightGreen,
    Colors.grey,
    Colors.cyan,
    Colors.teal,
    Colors.blueAccent,
    Colors.purple,
    Colors.teal,
    Colors.indigo,
    Colors.black,
    Colors.green,
    Colors.blueGrey,
    Colors.brown,
    Colors.lightGreen,
    Colors.orange,
    Colors.grey,
    Colors.cyan,
    Colors.blueAccent,
    Colors.purple,
    Colors.indigo,
    Colors.teal,
    Colors.brown,
    Colors.black,
    Colors.green,
    Colors.teal,
    Colors.blueAccent,
    Colors.purple,
    Colors.indigo,
    Colors.brown,
    Colors.teal,
    Colors.black,
    Colors.green,
    Colors.blueGrey,
    Colors.lightGreen,
    Colors.grey,
    Colors.cyan,
    Colors.teal,
    Colors.blueAccent,
    Colors.purple,
    Colors.teal,
    Colors.indigo,
    Colors.black,
    Colors.green,
    Colors.blueGrey,
    Colors.brown,
    Colors.lightGreen,
    Colors.orange,
    Colors.grey,
    Colors.cyan,
    Colors.blueAccent,
    Colors.purple,
    Colors.indigo,
    Colors.teal,
    Colors.brown,
    Colors.black,
    Colors.green,
    Colors.redAccent,
    Colors.teal,
    Colors.blueAccent,
    Colors.purple,
    Colors.indigo,
    Colors.brown,
    Colors.teal,
    Colors.black,
    Colors.green,
    Colors.blueGrey,
    Colors.lightGreen,
    Colors.grey,
    Colors.cyan,
    Colors.teal,
    Colors.blueAccent,
    Colors.purple,
    Colors.teal,
    Colors.indigo,
    Colors.black,
    Colors.green,
    Colors.blueGrey,
    Colors.brown,
    Colors.lightGreen,
    Colors.orange,
    Colors.grey,
    Colors.cyan,
    Colors.blueAccent,
    Colors.purple,
    Colors.indigo,
    Colors.teal,
    Colors.brown,
    Colors.black,
    Colors.green,
    Colors.teal,
    Colors.blueAccent,
    Colors.purple,
    Colors.indigo,
    Colors.brown,
    Colors.teal,
    Colors.black,
    Colors.green,
    Colors.blueGrey,
    Colors.lightGreen,
    Colors.grey,
    Colors.cyan,
    Colors.teal,
    Colors.blueAccent,
    Colors.purple,
    Colors.teal,
    Colors.indigo,
    Colors.black,
    Colors.green,
    Colors.blueGrey,
    Colors.brown,
    Colors.lightGreen,
    Colors.orange,
    Colors.grey,
    Colors.cyan,
    Colors.blueAccent,
    Colors.purple,
    Colors.indigo,
    Colors.teal,
    Colors.brown,
    Colors.black,
    Colors.green,
  ];

  @override
  void initState() {
    super.initState();

    getData(widget.token, fromdate, todate);
    _loadWorkStatus();

    // Consume pending deep links if any
    WidgetsBinding.instance.addPostFrameCallback((_) {
      deepLinkHandler.getPendingDeepLink().then((data) {
        if (data != null && mounted) {
          log('[DEEPLINK] MinimalDashboard: Consuming pending deep link: $data');
          deepLinkHandler.validateAndNavigate(context, data);
        }
      });
    });
  }

  void _loadWorkStatus() async {
    String? status = await Common.getSharedPref("is_work_started");
    setState(() {
      isWorkStarted = status == "true";
    });
  }

  getLeadProgressbar(token, fromDate, toDate, callStatus) async {
    object1 =
        await HttpService.leadProgressbar(token, fromDate, toDate, callStatus);
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

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Future<void> captureFace() async {
  //   final faceImage = await Navigator.of(context).push<File>(
  //     MaterialPageRoute(
  //       builder: (context) => FaceDetectionCamera(
  //         onFaceCaptured: (File imageFile) {
  //           Navigator.of(context).pop(imageFile);
  //         },
  //       ),
  //     ),
  //   );
  //   if (faceImage != null && mounted) {
  //     final faceHash = await generateFaceHash(faceImage);
  //     if (faceHash == null) {
  //       Common.toastMessaage('Face hash failed', Colors.red);
  //       return;
  //     }
  //     _faceBase64 = faceHash;
  //     setState(() {});
  //   }
  // }

  getData(token, fromDate, toDate) async {
    renewalPermission = await Common.getSharedPref("renewalPermission");
    accPermission = await Common.getSharedPref("accPermission");
    String tog = await Common.getSharedPref("acc_toggle") ?? "";
    toggle = tog == "true" ? true : false;
    setState(() {
      timeOut = false;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final dismissedDate = prefs.getString('loginPromptDismissedDate');
      final today = DateTime.now().toIso8601String().substring(0, 10);

      final connectivityResult = await (Connectivity().checkConnectivity());
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
      // leadDashboardNew = await HttpService.leadDashboardNew(
      //     token, fromdate, todate, fromdate1, todate1, "");
      name = await Common.getSharedPref("name");
      role = await Common.getSharedPref("role");
      userId = await Common.getSharedPref("userId");
      officialWhatsapp = await Common.getSharedPref("officialWhatsApp");
      unOfficialWhatsapp = await Common.getSharedPref("unofficialWhatsApp");
      createLeadPermission = await Common.getSharedPref("createLeadPermission");
      viewLeadPermission = await Common.getSharedPref("viewLeadPermission");
      viewAllWorkPermission =
          await Common.getSharedPref("viewAllWorkPermission");
      viewTargetReportPermission =
          await Common.getSharedPref("viewTargetReportPermission");
      addWorkPermission = await Common.getSharedPref("addWorkPermission");
      viewWorkReportPermission =
          await Common.getSharedPref("viewWorkReportPermission");
      startAndStopWorkPermission =
          await Common.getSharedPref("startAndStopWorkPermission");
      adminCheckPermission = await Common.getSharedPref("adminCheckPermission");
      multipleUsersCheck = await Common.getSharedPref("multipleUsers");
      multipleWorksCheck = await Common.getSharedPref("multipleWorks");
      hasPhonecallAccess = await Common.getSharedPref("hasPhonecallAccess");
      updateLeadPermission = await Common.getSharedPref("updateLeadPermission");
      deleteLeadPermission = await Common.getSharedPref("deleteLeadPermission");
      //  startAndStopWork = await Common.getSharedPref("startAndStopWork");
      phoneCallLogPermission =
          await Common.getSharedPref("phoneCallLogPermission");
      accessCallHistoryPermission =
          await Common.getSharedPref("accessCallHistoryPermission");
      viewLeadCategoryPermission =
          await Common.getSharedPref("viewLeadCategoryPermission");
      cloudCallPermission = await Common.getSharedPref("cloudCallPermission");
      createLeadCategory = await Common.getSharedPref("createLeadCategory");
      updateLeadCategory = await Common.getSharedPref("updateLeadCategory");
      deleteLeadCategory = await Common.getSharedPref("deleteLeadCategory");
      ProjectDashboardPermission =
          await Common.getSharedPref("ProjectDashboardPermission");
      AccountsDashboardPermission =
          await Common.getSharedPref("AccountsDashboardPermission");
      MenuDashboard = await Common.getSharedPref("MenuDashboard");
      RenewalDashboardPermission =
          await Common.getSharedPref("RenewalDashboardPermission");
      accessCallRecordingPermission =
          await Common.getSharedPref("accessCallRecordingPermission");
      visibleP = await Common.getSharedPref("isVisible");

      if (visibleP == 'true') {
        // isVisible = true;
        isVisible = false;
      } else {
        isVisible = false;
      }
      // if(userDashboard!.data.modules.length <2){
      //   isVisible =false;
      // }
      if (updateLeadPermission == 'true') {
        updateLeadPermission1 = true;
      }
      if (deleteLeadPermission == 'true') {
        deleteLeadPermission1 = true;
      }
      if (cloudCallPermission == 'true') {
        cloudCallPermission1 = true;
      }
      if (createLeadCategory == 'true') {
        createLeadCategory1 = true;
      }
      if (updateLeadCategory == 'true') {
        updateLeadCategory1 = true;
      }
      if (deleteLeadCategory == 'true') {
        deleteLeadCategory1 = true;
      }
      if (accessCallRecordingPermission == 'true') {
        accessCallRecordingPermission1 = true;
      }
      firebaseToken = await FirebaseMessaging.instance.getToken();

      LoginCheckModel? loginCheck =
          await HttpService.loginCheck(token, firebaseToken!);
      log(firebaseToken.toString());
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
        leadDashboard = await HttpService.leadDashboard(
            token, fromdate, todate, fromdate1, todate1);

        projectList = await HttpService.getProjectList();
        workStatus = await HttpService.getWorkStatus();
        if (workStatus!.data.isNotEmpty) {
          createdAt = DateTime.parse(workStatus!.data.first.createdAt);
        } else {
          print("No work status data available.");
        }

        userDashboard = await HttpService.mainDashboard(widget.token);
        loginOrNot = await HttpService.getLoginorNot(widget.token);
        Common.saveSharedPref("profile_pic", userDashboard!.data.profilePic);
        setState(() {
          notificationCount = leadDashboard!.data.unreadNotification;
        });
        Common.saveSharedPref(
            "whatsapp", userDashboard!.data.isWhatsappConfigured.toString());
        if (dismissedDate != today && startAndStopWorkPermission == "true") {
          loginOrNot = await HttpService.getLoginorNot(widget.token);
          if (loginOrNot?.data != true &&
              startAndStopWorkPermission == "true") {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                showLoginPrompt(context);
              }
            });
          }
        }
        getAccountDash();
        getRenewalDashboard();
        await Permission.notification.request();
      }
      setState(() {
        timeOut = false;
      });
    } catch (e) {
      log("error: $e");
      setState(() {
        timeOut = true;
        // timeOut = false;
      });
    }
  }

  getAccountDash() async {
    accountDashboard = await HttpService.accountsDashboard(fDate, tDate);
    if (accountDashboard != null && accountDashboard!.status == true) {
      setState(() {});
    } else {
      setState(() {});
    }
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => MinimalDashboard(widget.token)),
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

  getRenewalDashboard() async {
    renewalDashboard = await HttpService.renewalDashboard();
    if (renewalDashboard != null && renewalDashboard!.status == true) {
      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  getProjectList() async {
    projectList = await HttpService.getProjectList();
    if (projectList != null && projectList!.status == true) {
      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  getStaffwise() async {
    setState(() {
      moreloading = true;
    });
    staffWise = await HttpService.leadDashboard1(
        widget.token, fromdate, todate, fromdate1, todate1);
    setState(() {
      data.clear();
      for (int i = 0; i < staffWise!.data!.categoryGraph!.length; i++) {
        data.addAll({
          staffWise!.data!.categoryGraph![i].categoryName.toString():
              staffWise!.data!.categoryGraph![i].categoryCount!.toDouble(),
        });
      }
      catNew = 0;
      catPending = 0;
      catFollowup = 0;
      catRejected = 0;
      catClosed = 0;
      stfNew = 0;
      stfPending = 0;
      stfFollowup = 0;
      stfRejected = 0;
      stfClosed = 0;
      for (int i = 0; i < staffWise!.data!.categoryLeads!.length; i++) {
        catNew = int.parse(catNew.toString()) +
            int.parse(staffWise!.data!.categoryLeads![i].newCount.toString());
        catPending = int.parse(catPending.toString()) +
            int.parse(
                staffWise!.data!.categoryLeads![i].pendingCount.toString());
        catFollowup = int.parse(catFollowup.toString()) +
            int.parse(
                staffWise!.data!.categoryLeads![i].followupCount.toString());
        catRejected = int.parse(catRejected.toString()) +
            int.parse(
                staffWise!.data!.categoryLeads![i].rejectedCount.toString());
        catClosed = int.parse(catClosed.toString()) +
            int.parse(
                staffWise!.data!.categoryLeads![i].confirmedCount.toString());
      }
      for (int i = 0; i < staffWise!.data!.staffLeads!.length; i++) {
        stfNew = int.parse(stfNew.toString()) +
            int.parse(staffWise!.data!.staffLeads![i].newCount.toString());
        stfPending = int.parse(stfPending.toString()) +
            int.parse(staffWise!.data!.staffLeads![i].pendingCount.toString());
        stfFollowup = int.parse(stfFollowup.toString()) +
            int.parse(staffWise!.data!.staffLeads![i].followupCount.toString());
        stfRejected = int.parse(stfRejected.toString()) +
            int.parse(staffWise!.data!.staffLeads![i].rejectedCount.toString());
        stfClosed = int.parse(stfClosed.toString()) +
            int.parse(
                staffWise!.data!.staffLeads![i].confirmedCount.toString());
      }
    });
    setState(() {
      moreloading = false;
      loadmore = true;
    });
  }

  //!

  getSharedData() async {
    log('getSharedData called');
    try {
      // refresh = true;
      String permissionAccess = await Common.getSharedPref("callLogPermission");
      // uploadPermission = await Common.getSharedPref("uploadCallLog");
      // roleId = await Common.getSharedPref("roleId");
      // var sim = await Common.getSharedPref("simName");
      // if (sim != null) {
      //   selectedSim = await Common.getSharedPref("simName");
      //   selectedSimId = await Common.getSharedPref("simId");
      // } else {
      //   selectedSim = "Tap to select";
      //   selectedSimId = "";
      // }
      // if (uploadPermission != "true" && Platform.isIOS) {
      //   selectedIndex = -1;
      // }
      int from = DateTime.now()
          .subtract(const Duration(days: 3))
          .millisecondsSinceEpoch;
      int to = DateTime.now().millisecondsSinceEpoch;

      setState(() {});
      if (permissionAccess == 'true') {
        if (await Permission.phone.request().isGranted) {
          final List<CallLogToggleEvent> toggleHistory =
              await ToggleStorage.getToggleHistory();

          final Iterable<CallLogEntry> result = await CallLog.query(
            dateFrom: from,
            dateTo: to,
          );
          final filteredLogs = result.where((entry) {
            return isLogAllowed(
                entry.timestamp ?? 0, entry.callType!, toggleHistory);
          }).toList();

          // getSimDetails();
          final List<HiveCaallHistoryModel> hiveData =
              await HiveUtil.getAllCallLogs();
          log('hiveData 1: $hiveData');
          log('hiveData 0: ${hiveData.length}');
          log('================================== HIVE DATA IN GET SHARED DATA ========================================');
          log('hiveData LENGTH 1 : ${hiveData.length}');
          for (var datassss in hiveData) {
            log('hiveData LENGTH 2 : ${datassss.name} || ${datassss.phoneNumber} || ${datassss.isUploaded}');
          }

          // setState(() {
          //     fullHiveData=hiveData;
          //   _callLogEntries = filteredLogs;
          //   refresh = false;
          // });
        }
      }
      // !   UPDATE MISSING CALL LOG
      final int callLogCount = await HiveUtil.getCallLogCount();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<HiveCaallHistoryModel> callLogData = <HiveCaallHistoryModel>[];
      callLogData.clear();
      final String dateTimeFrom =
          prefs.getString('callLogsStartingTime').toString();
      //  List<String> callTypesQ = prefs.getStringList('callTypes') ?? [];
      //       log('callTypes : $callTypesQ');
      if (callLogCount == 0) {
        log('No call logs found in Hive.');

        final DateTime startingTime = DateTime.parse(dateTimeFrom);
        final List<CallLogToggleEvent> toggleHistory =
            await ToggleStorage.getToggleHistory();

        final Iterable<CallLogEntry> result = await CallLog.query(
          dateFrom: from,
          dateTo: to,
        );
        final List<CallLogEntry> filteredLogs = result.where((entry) {
          final DateTime callTime =
              DateTime.fromMillisecondsSinceEpoch(entry.timestamp ?? 0);

          // Only logs AFTER startingTime + pass your custom toggle filter
          return callTime.isAfter(startingTime);
        }).toList();
        log('filteredLogs : ${filteredLogs.length}');
        if (filteredLogs.isNotEmpty) {
          List<String> callTypesQ = prefs.getStringList('callTypes') ?? [];
          log('callTypes : $callTypesQ');
          List<HiveCaallHistoryModel> listOfCallLogNeedToAddHive = [];
          for (var callLog in filteredLogs) {
            bool isAllowed = false;

            if (callTypesQ.contains('Incoming') &&
                callLog.callType.toString().contains('incoming')) {
              isAllowed = true;
            } else if (callTypesQ.contains('Outgoing') &&
                callLog.callType.toString().contains('outgoing')) {
              isAllowed = true;
            }

            log('isAllowed : $isAllowed');

            HiveCaallHistoryModel hiveCallLog = HiveCaallHistoryModel(
                id: callLog.timestamp.toString(),
                name: callLog.name.toString(),
                phoneNumber: callLog.number.toString(),
                callType: callLog.callType
                    .toString()
                    .substring(callLog.callType.toString().indexOf('.') + 1),
                duration: callLog.duration.toString(),
                timeStamp: callLog.timestamp!.toString(),
                // timeStamp: '${DateTime.fromMillisecondsSinceEpoch(callLog.timestamp!)}',
                simSlot: callLog.simDisplayName ?? "NIL",
                callRecordFilePath: "",
                isUploaded: false,
                isDeleted: false,
                isEnabled: isAllowed);
            listOfCallLogNeedToAddHive.add(hiveCallLog);
          }

          log('listOfCallLogNeedToAddHive : $listOfCallLogNeedToAddHive');
          log('listOfCallLogNeedToAddHive : ${listOfCallLogNeedToAddHive.length}');
          // Filter list to include only allowed call logs
          List<HiveCaallHistoryModel> allowedCallLogs =
              listOfCallLogNeedToAddHive
                  .where((log) => log.isEnabled == true)
                  .toList();

          // Debug
          log('allowedCallLogs (for upload): ${allowedCallLogs.length}');

          // Proceed with upload only for allowed items
          if (allowedCallLogs.isNotEmpty) {
            await uploadMissingLogsToServer(allowedCallLogs);
          }

          // callLogData.add(hiveCallLog);
          if (listOfCallLogNeedToAddHive.isNotEmpty) {
            //  await uploadMissingLogsToServer(listOfCallLogNeedToAddHive);
            await HiveUtil.addCallLogs(listOfCallLogNeedToAddHive);
            Fluttertoast.showToast(
              msg: 'Synced Call Logs',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: ColorConstant.black,
              textColor: ColorConstant.white,
            );
          }

          return;
        } else {
          log('No call logs found');
          return;
        }
      } else {
        log('call logs found in Hive.');

        callLogData.clear();
        final String dateTimeFrom =
            prefs.getString('callLogsStartingTime').toString();
        final DateTime startingTime = DateTime.parse(dateTimeFrom);

        // final List<CallLogToggleEvent> toggleHistory = await ToggleStorage.getToggleHistory();

        final Iterable<CallLogEntry> result = await CallLog.query(
          dateFrom: from,
          dateTo: to,
        );
        //!
        final List<CallLogEntry> callLogsFromDevice = result.where((entry) {
          final DateTime callTime =
              DateTime.fromMillisecondsSinceEpoch(entry.timestamp ?? 0);

          // Only logs AFTER startingTime + pass your custom toggle filter
          return callTime.isAfter(startingTime);
        }).toList();
        // final List<CallLogEntry> callLogsFromDevice = result.where((entry) {
        //   final DateTime callTime = DateTime.fromMillisecondsSinceEpoch(entry.timestamp ?? 0);

        //   // Only logs AFTER startingTime + pass your custom toggle filter
        //   return callTime.isAfter(startingTime) &&
        //         isLogAllowed(entry.timestamp ?? 0, entry.callType!, toggleHistory);
        // }).toList();
        //!
        // todo :  callLogsFromDevice from this
        // todo : get current status of call permission (incoming and out going)
        // todo :based on filter from callLogsFromDevice
        log('Call logs from device : $callLogsFromDevice');
        log('Call logs from length : ${callLogsFromDevice.length}');
        if (callLogsFromDevice.isEmpty) {
          log('no call logs in device');
          return;
        }

        final deviceLatestCallLogTime =
            parseCallLogTime(callLogsFromDevice.first.timestamp.toString());

        final List<HiveCaallHistoryModel> hiveData =
            await HiveUtil.getAllCallLogs();

        final HiveCaallHistoryModel latestHiveCallLog2 =
            await HiveUtil.getLatestCallLogByTime() ?? hiveData.first;
        log('latestHiveCallLog2 : ${latestHiveCallLog2.name} || ${latestHiveCallLog2.phoneNumber} || ${latestHiveCallLog2.isUploaded} || ${latestHiveCallLog2.isEnabled}');

        final hiveLatestDateTime =
            parseCallLogTime(latestHiveCallLog2.timeStamp);

        if (hiveLatestDateTime == deviceLatestCallLogTime) {
          log('Latest Hive Call Log and Device Call Log are same.');
          log('first call log : ${latestHiveCallLog2.isUploaded}');
          Fluttertoast.showToast(
            msg: 'Call Logs alredy Sync',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: ColorConstant.black,
            textColor: ColorConstant.white,
          );
          return;
        } else {
          log('Latest Hive Call Log and Device Call Log are not same.');
          // List<CallLogEntry> allCallLogsAfterHiveLatestData = await getFilteredCallLogs(hiveLatestDateTime);
          final DateTime startingTime = DateTime.parse(dateTimeFrom);
          // final List<CallLogToggleEvent> toggleHistory = await ToggleStorage.getToggleHistory();

          final Iterable<CallLogEntry> result = await CallLog.query(
            dateFrom: from,
            dateTo: to,
          );
          log('result : ${result.length}');
          final List<CallLogEntry> allCallLogsAfterHiveLatestData =
              result.where((entry) {
            final DateTime callTime =
                DateTime.fromMillisecondsSinceEpoch(entry.timestamp ?? 0);

            // Only logs AFTER startingTime + pass your custom toggle filter
            return callTime.isAfter(startingTime);
          }).toList();
          // final List<CallLogEntry> allCallLogsAfterHiveLatestData = result.where((entry) {
          //   final DateTime callTime = DateTime.fromMillisecondsSinceEpoch(entry.timestamp ?? 0);

          //   // Only logs AFTER startingTime + pass your custom toggle filter
          //   return callTime.isAfter(startingTime) &&
          //         isLogAllowed(entry.timestamp ?? 0, entry.callType!, toggleHistory);
          // }).toList();
          log('Call logs from device after latest hive data : $allCallLogsAfterHiveLatestData');
          log('Call logs from length after latest hive data : ${allCallLogsAfterHiveLatestData.length}');
          // callLogData.addAll(hiveData);
          // history.clear();
          callLogData.clear();
          // todo : get prefs data of incoming and out going

          if (allCallLogsAfterHiveLatestData.isNotEmpty) {
            List<String> callTypesQ = prefs.getStringList('callTypes') ?? [];
            log('callTypes : $callTypesQ');

            for (var callLog in allCallLogsAfterHiveLatestData) {
              bool isAllowed = false;

              if (callTypesQ.contains('Incoming') &&
                  callLog.callType.toString().contains('incoming')) {
                isAllowed = true;
              } else if (callTypesQ.contains('Outgoing') &&
                  callLog.callType.toString().contains('outgoing')) {
                isAllowed = true;
              }

              log('isAllowed : $isAllowed');
              HiveCaallHistoryModel hiveCallLog = HiveCaallHistoryModel(
                id: callLog.timestamp.toString(),
                name: callLog.name.toString(),
                phoneNumber: callLog.number.toString(),
                callType: callLog.callType
                    .toString()
                    .substring(callLog.callType.toString().indexOf('.') + 1),
                duration: callLog.duration.toString(),
                timeStamp: callLog.timestamp!
                    .toString(), //'${DateTime.fromMillisecondsSinceEpoch(callLog.timestamp!)}',
                simSlot: callLog.simDisplayName ?? "NIL",
                callRecordFilePath: "",
                isUploaded: false,
                isDeleted: false,
                isEnabled: isAllowed,
              );
              // await HiveUtil.addCallLog(hiveCallLog); // add to hive
              callLogData.add(hiveCallLog);
              // todo : add to DB also this case
            }

            log('callLogData : $callLogData');
            log('callLogData : ${callLogData.length}');
            // got all call logs
            // get hive call logs
            // get missing call logs from callLogData list
            final List<HiveCaallHistoryModel> hiveData =
                await HiveUtil.getAllCallLogs();
            log('hiveData 1: $hiveData');
            log('hiveData 0: ${hiveData.length}');

            Map<String, bool> existingItems = {};

            for (var item in hiveData) {
              // Create a unique key using phone number and timestamp
              String uniqueKey = "${item.phoneNumber}_${item.timeStamp}";
              existingItems[uniqueKey] = true;
            }

            log('existingItems: $existingItems');
            log('existingItems length: ${existingItems.length}');

            List<HiveCaallHistoryModel> nonDuplicates = [];

            for (var item in callLogData) {
              String uniqueKey = "${item.phoneNumber}_${item.timeStamp}";
              if (!existingItems.containsKey(uniqueKey)) {
                log('Unique item found: ${item.phoneNumber} - ${item.timeStamp}');
                nonDuplicates.add(item);
              } else {
                log('Duplicate item found: ${item.phoneNumber} - ${item.timeStamp}');
              }
            }

            log('nonDuplicates: $nonDuplicates');
            log('nonDuplicates length: ${nonDuplicates.length}');
            for (var item in callLogData) {
              log('item main : ${item.name} || ${item.isDeleted} || ${item.isUploaded}');
            }

            nonDuplicates =
                nonDuplicates.where((log) => log.isDeleted != true).toList();
            //  callLogData = callLogData.where((log) => log.isDeleted != true).toList();
            nonDuplicates =
                nonDuplicates.where((log) => log.isUploaded != true).toList();
            nonDuplicates = nonDuplicates.reversed.toList();

            log('callLogData        : $callLogData');
            log('callLogData length : ${callLogData.length}');

            List<HiveCaallHistoryModel> notUploadedCallLogs =
                callLogData.where((log) => log.isUploaded != true).toList();
            log('notUploadedCallLogs : ${notUploadedCallLogs.length}');

            List<HiveCaallHistoryModel> allowedCallLogs =
                nonDuplicates.where((log) => log.isEnabled == true).toList();

            // Debug
            log('allowedCallLogs (for upload): ${allowedCallLogs.length}');

            // Proceed with upload only for allowed items
            if (allowedCallLogs.isNotEmpty) {
              await uploadMissingLogsToServer(allowedCallLogs);
            }

            if (nonDuplicates.isNotEmpty) {
              //  todo : update in HIve
              await HiveUtil.addCallLogs(nonDuplicates);
              Fluttertoast.showToast(
                msg: 'Synced Call Logs',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: ColorConstant.black,
                textColor: ColorConstant.white,
              );
            }

            return;
          } else {
            log('No NEW Call Logs found in device.');
            Fluttertoast.showToast(
              msg: 'No New Call Logs found in device to Sync.',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: ColorConstant.black,
              textColor: ColorConstant.white,
            );
            return;
          }
        }
      }
    } catch (e) {
      log(e.toString());
    }
    setState(() {});
  }

  void start_work(DateTime startTime, double latitude, double longitude) {
    print("Work started at: $startTime");
    HttpService.startWork(
      startTime,
      latitude: latitude,
      longitude: longitude,
      faceData: _faceBase64,
    );
  }

  Future<void> uploadMissingLogsToServer(
      List<HiveCaallHistoryModel> callLogData) async {
    log("uploadMissingLogsToServer function called");

    List<Map<String, dynamic>> missingLogs = callLogData
        .map((log) => {
              "name": log.name,
              "phone_number": log.phoneNumber,
              "callTypes": log.callType
                  .toString()
                  .substring(log.callType.toString().indexOf('.') + 1),
              "time":
                  DateTime.fromMillisecondsSinceEpoch(int.parse(log.timeStamp))
                      .toString(),
              "duration": log.duration,
              "simName": log.simSlot ?? "NIL",
              "timeStamp": log.timeStamp,
            })
        .toList();

    log("⚠️ Found ${missingLogs.length} missing logs.");

    if (missingLogs.isNotEmpty) {
      log('~~ OUTGOING CALL missingLogs : $missingLogs ~~~');
      log('~~ OUTGOING CALL length : ${missingLogs.length} ~~~');

      Map<String, dynamic> body = {
        "token": await Common.getSharedPref("token"),
        'log': missingLogs,
      };
      log('~~ OUTGOING CALL BODY : $body ~~~');

      CallLogUploadModel object1 = await HttpService.callLogUpload(body);
      log('~~ OUTGOING CALL missingLogs object : ${object1.data} ~~~');
      // await HiveUtil.saveCallLog(missingLogs.last);
      if (object1.data == true) {
        log('~~ OUTGOING CALL success ~~~');
        log('success');
      } else {
        log('~~ OUTGOING CALL failure ~~~');
        log('failure');
      }
    }
  }

  //!

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool? result = await _exitApp(context);
        result ??= false;
        return result;
      },
      child: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            leadDashboard = null;
          });
          getData(widget.token, fromdate, todate);
          return;
        },
        child: result == true && timeOut == false
            ? DefaultTabController(
                initialIndex: renewalPermission == "true" ? 1 : 0,
                length: renewalPermission == "true" && accPermission == "true"
                    ? 3
                    : 2,
                child: Scaffold(
                    key: _scaffoldKey,
                    backgroundColor: Colors.white,
                    body: renewalPermission == "true" || accPermission == "true"
                        ? TabBarView(children: [
                            if (renewalPermission == "true")
                              isLoading == true
                                  ? accDashShimmer()
                                  : renewalDashboardView(context),
                            leadDashboardView(context),
                            if (accPermission == "true")
                              isLoading == true
                                  ? accDashShimmer()
                                  : accountDashboardView(context),
                          ])
                        : leadDashboardView(context),
                    endDrawer: DraweScreen(widget.token!),
                    floatingActionButtonLocation:
                        FloatingActionButtonLocation.centerDocked,
                    floatingActionButton: FloatingActionButton(
                      backgroundColor: Colors.black,
                      onPressed: () {
                        // Navigator.push(
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
                                        : Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    MinimalDashboard(
                                                        widget.token)),
                                          );
                      },
                      child: Image.asset("assets/icons/menu.png", width: 25),
                    ),
                    bottomNavigationBar: configure != null
                        ? BottomNavigation(widget.token!,
                            phoneCallLogPermission: phoneCallLogPermission,
                            name: name,
                            userId: userId)
                        : const SizedBox()),
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
                            ? 'There seems to be a temporary issue !, \n Please retry to continue'
                            : 'No Network Found !',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 35,
                      ),
                      InkWell(
                        onTap: () {
                          getData(widget.token, fromdate, todate);
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

  SafeArea renewalDashboardView(BuildContext context) {
    return SafeArea(
        child: RefreshIndicator(
      onRefresh: () async {
        getRenewalDashboard();
      },
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RenewalFollowupList(
                          clientId: "",
                          clientName: "",
                        ),
                      )).then((_) {
                    getData(widget.token, fromdate, todate);
                    if (loadmore == true) {
                      getStaffwise();
                    }
                  });
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * .95,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 2,
                          color: Colors.grey.shade600,
                          offset: const Offset(0, 2.0),
                        )
                      ]),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Upcoming Renewals :",
                                style: TextStyle(
                                    color: Colors.blue.shade900,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold)),
                            Text(
                              renewalDashboard!.data.upcomingRenewals,
                              style: TextStyle(
                                  color: Colors.blue.shade900,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CustomRenewal(),
                                )).then((_) {
                              getData(widget.token, fromdate, todate);
                              if (loadmore == true) {
                                getStaffwise();
                              }
                            });
                          },
                          label: const Text(
                            "Add Renewal",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                              elevation: 1, backgroundColor: Colors.blue),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * .2,
                width: MediaQuery.of(context).size.width,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  // gridDelegate:
                  //     const SliverGridDelegateWithFixedCrossAxisCount(
                  //   crossAxisCount: 2,
                  //   crossAxisSpacing: 10.0,
                  //   mainAxisSpacing: 10.0,
                  //   childAspectRatio: 1.2,
                  // ),
                  shrinkWrap: true,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RenewalList(
                                custId: "",
                                title: "Current Month",
                                searchKey: "current_month",
                                searchMonth: "",
                                renewed: int.parse(renewalDashboard!
                                    .data.currentMonthData.paidCount),
                              ),
                            ));
                      },
                      child: RenewalGridItem(
                        title: "Current Month",
                        paidAmount: renewalDashboard!
                            .data.currentMonthData.paidAmount
                            .toString(),
                        paidCount: renewalDashboard!
                            .data.currentMonthData.paidCount
                            .toString(),
                        totalAmount: renewalDashboard!
                            .data.currentMonthData.totalAmount
                            .toString(),
                        totalCount: renewalDashboard!
                            .data.currentMonthData.totalCount
                            .toString(),
                        color: const Color(0xFF2a86c9),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RenewalList(
                                custId: "",
                                title: "Next Month",
                                searchKey: "next_month",
                                searchMonth: "",
                                renewed: int.parse(renewalDashboard!
                                    .data.nextMonthData.paidCount),
                              ),
                            ));
                      },
                      child: RenewalGridItem(
                        title: "Next Month",
                        paidAmount: renewalDashboard!
                            .data.nextMonthData.paidAmount
                            .toString(),
                        paidCount: renewalDashboard!
                            .data.nextMonthData.paidCount
                            .toString(),
                        totalAmount: renewalDashboard!
                            .data.nextMonthData.totalAmount
                            .toString(),
                        totalCount: renewalDashboard!
                            .data.nextMonthData.totalCount
                            .toString(),
                        color: const Color(0xFF2a86c9),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RenewalList(
                                custId: "",
                                title: "Current Year",
                                searchKey: "current_year",
                                searchMonth: "",
                                renewed: int.parse(
                                    renewalDashboard!.data.allData.paidCount),
                              ),
                            ));
                      },
                      child: RenewalGridItem(
                        title: "Current Year",
                        paidAmount: renewalDashboard!.data.allData.paidAmount
                            .toString(),
                        paidCount:
                            renewalDashboard!.data.allData.paidCount.toString(),
                        totalAmount: renewalDashboard!.data.allData.totalAmount
                            .toString(),
                        totalCount: renewalDashboard!.data.allData.totalCount
                            .toString(),
                        color: const Color(0xFF2a86c9),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RenewalList(
                                custId: "",
                                title: "Expired",
                                searchMonth: "",
                                searchKey: "expired",
                                renewed: int.parse(renewalDashboard!
                                    .data.expiredData.paidCount),
                              ),
                            ));
                      },
                      child: RenewalGridItem(
                          title: "Expired",
                          paidAmount: renewalDashboard!
                              .data.expiredData.paidAmount
                              .toString(),
                          paidCount: renewalDashboard!
                              .data.expiredData.paidCount
                              .toString(),
                          totalAmount: renewalDashboard!
                              .data.expiredData.totalAmount
                              .toString(),
                          totalCount: renewalDashboard!
                              .data.expiredData.totalCount
                              .toString(),
                          color: Colors.red.shade200),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 2,
                          color: Colors.grey.shade600,
                          offset: const Offset(0, 2.0),
                        )
                      ]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              Colors.blue.shade600,
                              Colors.blue.shade500,
                            ]),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            )),
                        child: const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              "Renewal Reports",
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0, top: 16.0),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * .9,
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount:
                                renewalDashboard!.data.monthReport.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RenewalList(
                                          custId: "",
                                          title: renewalDashboard!
                                              .data.monthReport[index].label,
                                          searchKey: "",
                                          searchMonth: renewalDashboard!.data
                                              .monthReport[index].searchMonth
                                              .toString(),
                                          renewed: 0,
                                        ),
                                      ));
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10.0,
                                      bottom: 10.0,
                                      left: 20.0,
                                      right: 20.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(renewalDashboard!
                                              .data.monthReport[index].label),
                                          Text(
                                            " ${renewalDashboard!.data.monthReport[index].amount.toString()}",
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      LinearProgressIndicator(
                                        borderRadius: BorderRadius.circular(8),
                                        backgroundColor: Colors.grey,
                                        value: renewalDashboard!.data
                                                .monthReport[index].percentage /
                                            100,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.blue.shade400),
                                        minHeight: 6,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
      ),
    ));
  }

  SafeArea accountDashboardView(BuildContext context) {
    return SafeArea(
      top: true,
      child: RefreshIndicator(
        onRefresh: () async {
          getAccountDash();
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20.0, horizontal: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        toggle = !toggle;
                      });
                      Common.saveSharedPref("acc_toggle", toggle.toString());
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                            colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
                      ),
                      child: Column(
                        children: [
                          // Container(
                          //   height: MediaQuery.of(context).size.height * .2,
                          //   decoration: BoxDecoration(
                          //       borderRadius: BorderRadius.circular(12),
                          //       image: DecorationImage(
                          //           image: AssetImage("assets/main/funriders.png"))),
                          // ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                width: 20,
                              ),
                              Text(
                                "Account Management",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(2.0, 2.0),
                                        blurRadius: 5.0,
                                        color: Colors.grey,
                                      ),
                                    ]),
                              ),
                              Icon(
                                Icons.arrow_drop_down_circle_outlined,
                                color: Colors.white,
                                size: 25,
                              )
                            ],
                          ),
                          toggle
                              ? SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * .95,
                                  height:
                                      MediaQuery.of(context).size.height * .3,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: GridView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: list.length,
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              mainAxisSpacing: 15,
                                              crossAxisSpacing: 15,
                                              childAspectRatio: 3),
                                      itemBuilder: (context, i) {
                                        return InkWell(
                                          onTap: () {
                                            if (list[i] == "Expense") {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ExpenseList(),
                                                  ));
                                            } else if (list[i] == "Invoices") {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        InvoiceList(
                                                            widget.token
                                                                .toString(),
                                                            "",
                                                            "",
                                                            "")),
                                              );
                                            } else if (list[i] ==
                                                "Pending Invoices") {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        PendingInvoice(widget
                                                            .token
                                                            .toString(),'')),
                                              );
                                            } else if (list[i] == "Receipts") {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ReceiptList(widget.token
                                                            .toString())),
                                              );
                                            } else if (list[i] ==
                                                "Account Head") {
                                              if (accountDashboard!
                                                  .data.isViewAccHead) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const AccountHead()),
                                                );
                                              } else {
                                                Common.toastMessaage(
                                                    "No permission",
                                                    Colors.red);
                                              }
                                            } else {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ClientList(
                                                            widget.token!,
                                                            _scaffoldKey)),
                                              );
                                            }
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFf0ebef),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Center(
                                              child: Text(
                                                list[i],
                                                style: TextStyle(
                                                    color: tabColors[i],
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                )
                              : const SizedBox(
                                  height: 20,
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * .9,
                  height: MediaQuery.of(context).size.height * .63,
                  child: GridView(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 15,
                            crossAxisSpacing: 15,
                            childAspectRatio: 1.5),
                    children: [
                      InkWell(
                        onTap: () {
                          if (accountDashboard!.data.bankAccCount == "1") {
                            if (accountDashboard!.data.isViewBankAcc) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BankAccount(
                                      accId:
                                          accountDashboard!.data.bankAccountId,
                                      accName: accountDashboard!
                                          .data.bankAccountName,
                                    ),
                                  ));
                            } else {
                              Common.toastMessaage("No permission", Colors.red);
                            }
                          } else if (accountDashboard!.data.bankAccCount ==
                              "0") {
                            Common.toastMessaage(
                                "Please add a 'BANK ACCOUNT'", Colors.red);
                          } else {
                            if (accountDashboard!.data.isViewBankAcc) {
                              if (accountDashboard!.data.isViewPendingExpense) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PendingExpense(
                                        status: "1",
                                      ),
                                    ));
                              } else {
                                Common.toastMessaage(
                                    "No permission", Colors.red);
                              }
                            } else {}
                          }
                        },
                        child: gridItem(
                            "BANK ACCOUNT",
                            accountDashboard!.data.bankAccount,
                            Colors.green,
                            colorList[0]),
                      ),
                      InkWell(
                        onTap: () {
                          if (accountDashboard!.data.isViewPendingExpense) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PendingExpense(
                                    status: "2",
                                  ),
                                ));
                          } else {
                            Common.toastMessaage("No permission", Colors.red);
                          }
                        },
                        child: gridItem(
                            "PENDING EXPENSE",
                            accountDashboard!.data.pendingExpense,
                            Colors.red,
                            colorList[1]),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReceiptList(
                                widget.token!,
                                // fdate: DateFormat('dd-MM-yyyy')
                                //     .format(DateTime.now()),
                                // tdate: DateFormat('dd-MM-yyyy')
                                //     .format(DateTime.now()),
                                fdate: DateFormat('yyyy-MM-dd')
                                    .format(DateTime.now()),
                                tdate: DateFormat('yyyy-MM-dd')
                                    .format(DateTime.now()),
                              ),
                            ),
                          );
                        },
                        child: gridItem(
                          "TODAYS INCOME",
                          accountDashboard!.data.todaysIncome,
                          Colors.black,
                          colorList[2],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ExpenseList(
                                  // fdate: DateFormat('dd-MM-yyyy')
                                  fdate: DateFormat('yyyy-MM-dd')
                                      .format(DateTime.now()),
                                  // tdate: DateFormat('dd-MM-yyyy')
                                  tdate: DateFormat('yyyy-MM-dd')
                                      .format(DateTime.now()),
                                ),
                              ));
                        },
                        child: gridItem(
                            "TODAYS EXPENSE",
                            accountDashboard!.data.todayExpense,
                            Colors.black,
                            colorList[3]),
                      ),
                      // InkWell(
                      //   onTap: () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //         builder: (context) => ReceiptList(
                      //           widget.token!,
                      //           // fdate: DateFormat('dd-MM-yyyy')
                      //           //     .format(DateTime.now()),
                      //           // tdate: DateFormat('dd-MM-yyyy')
                      //           //     .format(DateTime.now()),
                      //            fdate: DateFormat('yyyy-MM-dd')
                      //               .format(DateTime.now()),
                      //           tdate: DateFormat('yyyy-MM-dd')
                      //               .format(DateTime.now()),
                      //         ),
                      //       ),
                      //     );
                      //   },
                      //   child: gridItem(
                      //     "TODAYS INCOME",
                      //     accountDashboard!.data.todaysIncome,
                      //     Colors.black,
                      //     colorList[2],
                      //   ),
                      // ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReceiptList(
                                  widget.token!,
                                  fdate: DateFormat('dd-MM-yyyy').format(
                                      DateTime(DateTime.now().year,
                                          DateTime.now().month, 1)),
                                  tdate: DateFormat('dd-MM-yyyy')
                                      .format(DateTime.now()),
                                ),
                              ));
                        },
                        child: gridItem(
                            "THIS MONTH INCOME",
                            accountDashboard!.data.monthlyIncome,
                            Colors.black,
                            colorList[4]),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ExpenseList(
                                  // fdate: DateFormat('dd-MM-yyyy').format(
                                  fdate: DateFormat('yyyy-MM-dd').format(
                                      DateTime(DateTime.now().year,
                                          DateTime.now().month, 1)),
                                  // tdate: DateFormat('dd-MM-yyyy')
                                  tdate: DateFormat('yyyy-MM-dd')
                                      .format(DateTime.now()),
                                ),
                              ));
                        },
                        child: gridItem(
                            "THIS MONTH EXPENSE",
                            accountDashboard!.data.monthlyExpense,
                            Colors.black,
                            colorList[5]),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PendingInvoice(widget.token!,''),
                              ));
                        },
                        child: gridItem(
                            "PENDING INVOICE",
                            accountDashboard!.data.pendingIncome,
                            Colors.black,
                            colorList[6]),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PendingExpense(
                                  status: "3",
                                ),
                              ));
                        },
                        child: gridItem(
                            "ADVANCE AMOUNT",
                            accountDashboard!.data.advanceAmount,
                            Colors.green,
                            colorList[7]),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 12.0,
                    right: 12.0,
                    bottom: 25.0,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFf0ebef),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 26.0, bottom: 16, left: 16.0, right: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  final selctedDatetimetemp =
                                      await showDatePicker(
                                    context: context,
                                    initialDate: DateTime(DateTime.now().year,
                                        DateTime.now().month, 1),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime.now(),
                                  );
                                  fDate = DateFormat('dd-MM-yyyy')
                                      .format(selctedDatetimetemp!);
                                  getAccountDash();
                                  setState(() {});
                                },
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.37,
                                  height: 45,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      boxShadow: [
                                        BoxShadow(
                                            blurRadius: 0.5,
                                            color: Colors.grey.shade300,
                                            offset: const Offset(2.5, 2.5))
                                      ],
                                      color: Colors.white),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: Text(
                                          fDate,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(2),
                                          color: Colors.white,
                                        ),
                                        child: const Icon(
                                          Icons.calendar_month,
                                          color: Colors.grey,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward,
                                size: 16,
                              ),
                              GestureDetector(
                                onTap: () async {
                                  final toDateSelectTemp = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  tDate = DateFormat('dd-MM-yyyy')
                                      .format(toDateSelectTemp!);
                                  getAccountDash();
                                  setState(() {});
                                },
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.37,
                                  height: 45,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                            blurRadius: 0.5,
                                            color: Colors.grey.shade300,
                                            offset: const Offset(2.5, 2.5))
                                      ]),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: Text(
                                          tDate,
                                        ),
                                      ),
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: Colors.white,
                                        ),
                                        child: const Icon(
                                          Icons.calendar_month,
                                          color: Colors.grey,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(
                                  bottom: 16.0, left: 16.0, right: 16.0),
                              child: Text(
                                "Income",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25),
                              ),
                            ),
                            if (accountDashboard!.data.incomeGraph.isNotEmpty)
                              ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount:
                                      accountDashboard!.data.incomeGraph.length,
                                  itemBuilder: (context, i) {
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ReceiptList(
                                                    widget.token.toString(),
                                                    type: accountDashboard!.data
                                                        .incomeGraph[i].type,
                                                    fdate: fDate,
                                                    tdate: tDate,
                                                  )),
                                        );
                                      },
                                      child: progressItem(
                                          accountDashboard!
                                              .data.incomeGraph[i].category,
                                          accountDashboard!
                                              .data.incomeGraph[i].totalExpense,
                                          double.parse(accountDashboard!
                                              .data.incomeGraph[i].perc)),
                                    );
                                  })
                            else
                              const Padding(
                                padding: EdgeInsets.only(bottom: 26.0),
                                child: Text(
                                  "Empty",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                          ],
                        ),
                        if (accountDashboard!.data.expenseGraph.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 16.0, horizontal: 16.0),
                                child: Text(
                                  "Expense",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25),
                                ),
                              ),
                              ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: accountDashboard!
                                      .data.expenseGraph.length,
                                  itemBuilder: (context, i) {
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ExpenseList(
                                                catId: accountDashboard!.data
                                                    .expenseGraph[i].expCatid,
                                                catName: accountDashboard!.data
                                                    .expenseGraph[i].expCatName,
                                                fdate: fDate,
                                                tdate: tDate,
                                              ),
                                            ));
                                      },
                                      child: progressItem(
                                          accountDashboard!
                                              .data.expenseGraph[i].expCatName,
                                          accountDashboard!.data.expenseGraph[i]
                                              .totalExpense,
                                          double.parse(accountDashboard!
                                              .data.expenseGraph[i].perc)),
                                    );
                                  }),
                            ],
                          )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SafeArea leadDashboardView(BuildContext context) {
    return SafeArea(
      top: false,
      child: RefreshIndicator(
        onRefresh: () async {
          getData(widget.token, fromdate, todate);
          if (loadmore == true) {
            getStaffwise();
          }
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              appBarWidget(context, "lead"),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      workStatus != null && workStatus!.data.isNotEmpty
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    blurRadius: 3,
                                    offset: const Offset(1, 1),
                                  )
                                ],
                              ),
                              // child: StreamBuilder<DateTime>(
                              //   stream: Stream.periodic(Duration(seconds: 1),
                              //       (_) => DateTime.now()),
                              //   builder: (context, snapshot) {
                              //     if (!snapshot.hasData) return SizedBox();

                              //     final now = snapshot.data!;
                              //     final createdAt = DateTime.parse(
                              //         workStatus!.data.first.createdAt);
                              //     final diff = now.difference(createdAt);

                              //     String timeSince =
                              //         "${diff.inHours}h ${diff.inMinutes % 60}m ${diff.inSeconds % 60}s";

                              //     return Text(
                              //       timeSince,
                              //       style: TextStyle(
                              //         fontSize: 14,
                              //         fontWeight: FontWeight.w500,
                              //         color:
                              //             const Color.fromARGB(255, 255, 5, 5),
                              //       ),
                              //     );
                              //   },
                              // )
                              child:
                                  //  StreamBuilder<DateTime>(

                                  //     stream: Stream.periodic(Duration(seconds: 1), (_) => DateTime.now()),
                                  //     builder: (context, snapshot) {
                                  //       if (!snapshot.hasData || createdAt == null) return SizedBox();

                                  //       final now = snapshot.data!;
                                  //       final diff = now.difference(createdAt!);

                                  //       String timeSince =
                                  //           "${diff.inHours}h ${diff.inMinutes % 60}m ${diff.inSeconds % 60}s";

                                  //       return Text(
                                  //         timeSince,
                                  //         style: TextStyle(
                                  //           fontSize: 14,
                                  //           fontWeight: FontWeight.w500,
                                  //           color: const Color.fromARGB(255, 255, 5, 5),
                                  //         ),
                                  //       );
                                  //     },
                                  //   )
                                  StreamBuilder<DateTime>(
                                stream: Stream.periodic(
                                    const Duration(seconds: 1),
                                    (_) => DateTime.now()),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData || createdAt == null) {
                                    return const SizedBox();
                                  }

                                  final now = snapshot.data!;
                                  final diff = now.difference(createdAt!);

                                  String timeSince =
                                      "${diff.inHours}h ${diff.inMinutes % 60}m ${diff.inSeconds % 60}s";

                                  return GestureDetector(
                                    onTap: () async {
                                      final workStatusModel =
                                          await HttpService.getWorkStatus();

                                      WorkStatus? existingWork;
                                      if (workStatusModel != null &&
                                          workStatusModel.data.isNotEmpty) {
                                        existingWork =
                                            workStatusModel.data.first;
                                      }
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AddWorkPage(
                                            workId: "",
                                            existingWork: existingWork,
                                            onSuccess: () {
                                              setState(() {
                                                getData(widget.token, fromdate,
                                                    todate);
                                              });
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      timeSince,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color.fromARGB(255, 255, 5, 5),
                                      ),
                                    ),
                                  );
                                },
                              ))
                          : const SizedBox(),
                      const SizedBox(width: 10),
                      // startAndStopWorkPermission =="true" && userDashboard != null
                      //     ? InkWell(
                      //         onTap: () async {
                      //           final now = DateTime.now();

                      //           if (userDashboard!.data.loginCheck == false) {
                      //             // Start Work
                      //             final response =
                      //                 await HttpService.startWork(now);
                      //             if (response != null &&
                      //                 response.status == true) {
                      //               setState(() {
                      //                 userDashboard!.data.loginCheck = true;
                      //               });
                      //               await Common.saveSharedPref(
                      //                   "is_work_started", "true");
                      //               ScaffoldMessenger.of(context).showSnackBar(
                      //                 SnackBar(
                      //                   content: Text(
                      //                     "Work started at ${now.toLocal()}",
                      //                     style: TextStyle(color: Colors.white),
                      //                   ),
                      //                   backgroundColor: Colors.green,
                      //                 ),
                      //               );
                      //             } else {
                      //               ScaffoldMessenger.of(context).showSnackBar(
                      //                 SnackBar(
                      //                   content: Text(response?.message ??
                      //                       "Failed to start work"),
                      //                   backgroundColor: Colors.red,
                      //                 ),
                      //               );
                      //             }
                      //           } else {
                      //             final response =
                      //                 await HttpService.stopWork(now);
                      //             if (response != null &&
                      //                 response.status == true) {
                      //               setState(() {
                      //                 userDashboard!.data.loginCheck = false;
                      //               });
                      //               await Common.saveSharedPref(
                      //                   "is_work_started", "false");
                      //               ScaffoldMessenger.of(context).showSnackBar(
                      //                 SnackBar(
                      //                   content: Text(
                      //                     "Work stopped at ${now.toLocal()}",
                      //                     style: TextStyle(color: Colors.white),
                      //                   ),
                      //                   backgroundColor: Colors.green,
                      //                 ),
                      //               );
                      //             } else {
                      //               ScaffoldMessenger.of(context).showSnackBar(
                      //                 SnackBar(
                      //                   content: Text("Failed to stop work"),
                      //                   backgroundColor: Colors.red,
                      //                 ),
                      //               );
                      //             }
                      //           }
                      //         },
                      //         child: Container(
                      //           width: 50,
                      //           height: 32,
                      //           padding: EdgeInsets.symmetric(
                      //               horizontal: 15, vertical: 5),
                      //           decoration: BoxDecoration(
                      //             border:
                      //                 Border.all(color: Colors.white, width: 0),
                      //             boxShadow: [
                      //               BoxShadow(
                      //                 color: Colors.grey,
                      //                 blurRadius: 5,
                      //                 offset: Offset(1, 1),
                      //               ),
                      //             ],
                      //             color: userDashboard!.data.loginCheck
                      //                 ? Colors.red
                      //                 : const Color.fromARGB(255, 24, 158, 64),
                      //             borderRadius:
                      //                 BorderRadius.all(Radius.circular(5)),
                      //           ),
                      //           child: Icon(
                      //             userDashboard!.data.loginCheck
                      //                 ? Icons.stop
                      //                 : Icons.play_arrow,
                      //             color: Colors.white,
                      //           ),
                      //         ),
                      //       )
                      //     : const SizedBox(),
                      // startAndStopWorkPermission == "true" &&
                      //         userDashboard != null
                      //     ? StartStopToggle(
                      //         initialStatus: userDashboard!.data.loginCheck,
                      //         onToggle: (bool started) {
                      //           setState(() {
                      //             userDashboard!.data.loginCheck = started;
                      //           });
                      //         },
                      //       )
                      //     : SizedBox(),

                      const SizedBox(width: 10),
                      InkWell(
                        onTap: () async {
                          setState(() {
                            // Toggle visibility
                            _showNewLeadsCount = !_showNewLeadsCount;
                            _showFollowupLeadsCount = !_showFollowupLeadsCount;
                            _showClosedLeadsCount = !_showClosedLeadsCount;
                            _showTotalCalledCount = !_showTotalCalledCount;
                            _showTransferredLeadsCount =
                                !_showTransferredLeadsCount;
                            _showMissedLeadsCount = !_showMissedLeadsCount;

                            // Start loaders only if we are showing counts
                            if (_showNewLeadsCount) _isLoadingNewLeads = true;
                            if (_showFollowupLeadsCount)
                              _isLoadingFollowupLeads = true;
                            if (_showClosedLeadsCount)
                              _isLoadingClosedLeads = true;
                            if (_showTotalCalledCount)
                              _isLoadingTotalCalled = true;
                            if (_showTransferredLeadsCount)
                              _isLoadingTransferredLeads = true;
                            if (_showMissedLeadsCount)
                              _isLoadingMissedLeads = true;
                          });

                          // Fetch data only if toggled to show
                          if (_showNewLeadsCount ||
                              _showFollowupLeadsCount ||
                              _showClosedLeadsCount ||
                              _showTotalCalledCount ||
                              _showTransferredLeadsCount ||
                              _showMissedLeadsCount) {
                            try {
                              var result = await HttpService.leadDashboardNew(
                                widget.token,
                                fromdate,
                                todate,
                                fromdate1,
                                todate1,
                                "all",
                              );

                              if (result != null) {
                                setState(() {
                                  newLeadsDashboard = result;
                                  followupLeadsDashboard = result;
                                  closedLeadsDashboard = result;
                                  totalCalledDashboard = result;
                                  transferredLeadsDashboard = result;
                                  missedLeadsDashboard = result;

                                  // Stop loaders
                                  _isLoadingNewLeads = false;
                                  _isLoadingFollowupLeads = false;
                                  _isLoadingClosedLeads = false;
                                  _isLoadingTotalCalled = false;
                                  _isLoadingTransferredLeads = false;
                                  _isLoadingMissedLeads = false;
                                });
                              }
                            } catch (e) {
                              setState(() {
                                _isLoadingNewLeads = false;
                                _isLoadingFollowupLeads = false;
                                _isLoadingClosedLeads = false;
                                _isLoadingTotalCalled = false;
                                _isLoadingTransferredLeads = false;
                                _isLoadingMissedLeads = false;
                              });
                              print("Error fetching all lead counts: $e");
                            }
                          }
                        },
                        child: Container(
                          width: 50,
                          height: 32,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 5),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 0),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 5,
                                offset: Offset(1, 1),
                              ),
                            ],
                            color: Colors.white,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5)),
                          ),
                          child: Icon(
                            Icons.visibility,
                            color: Colors.grey.shade700,
                            size: 20,
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),
                      InkWell(
                        onTap: () {
                          if (isVisible == true) {
                            Common.saveSharedPref("isVisible", 'false');
                            isVisible = false;
                          } else {
                            Common.saveSharedPref("isVisible", 'true');
                            isVisible = true;
                          }
                          setState(() {});
                        },
                        child: Container(
                          width: 50,
                          height: 39,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 5),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 0),
                              boxShadow: const [
                                BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 5,
                                    offset: Offset(1, 1)),
                              ],
                              color: Colors.white,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5))),
                          child: Icon(isVisible == true
                              ? Icons.keyboard_arrow_down
                              : Icons.keyboard_arrow_up),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              isExpired == false
                  ? Visibility(
                      visible: isVisible,
                      maintainAnimation: true,
                      maintainState: true,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.fastOutSlowIn,
                        opacity: isVisible ? 1 : 0,
                        child: SizedBox(
                          height: 100,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 1),
                              itemCount: userDashboard != null
                                  ? userDashboard!.data.modules.length
                                  : 5,
                              itemBuilder: (BuildContext context, int i) {
                                return GestureDetector(
                                  onTap: () async {
                                    log(userDashboard!.data.modules[i].menuName
                                        .toString());
                                    if (isExpired == true) {
                                      _upgrade(context);
                                    } else {
                                      if (userDashboard!
                                              .data.modules[i].menuName ==
                                          'call_management') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  MinimalDashboard(
                                                      widget.token)),
                                        );
                                      } else if (userDashboard!
                                              .data.modules[i].menuName ==
                                          'Staff_management') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ViewUsers(widget.token)),
                                        );
                                      } else if (userDashboard!
                                              .data.modules[i].menuName ==
                                          'whatsapp') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const ChatHomeScreen()),
                                        );
                                      } else if (userDashboard!
                                              .data.modules[i].menuName ==
                                          'Settings') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  WhatsappSettings(
                                                      widget.token)),
                                        );
                                      } else if (userDashboard!
                                              .data.modules[i].menuName ==
                                          'file_manager') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  FileMangerList(widget.token)),
                                        );
                                      } else if (userDashboard!
                                              .data.modules[i].menuName ==
                                          'customers') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ClientList(
                                                  widget.token!, _scaffoldKey)),
                                        );
                                      } else if (userDashboard!
                                              .data.modules[i].menuName ==
                                          'invoices') {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  AccountsDashboard(
                                                token: widget.token.toString(),
                                              ),
                                            )).then((_) {
                                          getData(
                                              widget.token, fromdate, todate);
                                          if (loadmore == true) {
                                            getStaffwise();
                                          }
                                        });
                                      } else if (userDashboard!
                                              .data.modules[i].menuName ==
                                          'reports') {
                                        viewReportsDialog(context);
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
                                              'Work' &&
                                          adminCheckPermission == "true") {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ViewCompanyWorkPage(),
                                            settings: const RouteSettings(
                                              arguments: {
                                                //  "staffId": staffId
                                              },
                                            ),
                                          ),
                                        );
                                      } else if (userDashboard!
                                                  .data.modules[i].menuName ==
                                              'Work' &&
                                          adminCheckPermission == "false") {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ViewWorkPage(
                                              staffId: '',
                                            ),
                                            settings: RouteSettings(
                                              arguments: {"staffId": staffId},
                                            ),
                                          ),
                                        );
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
                                          'products') {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ProductList(
                                                catId: "widget.catId",
                                                subCatId: "11",
                                                title: "",
                                                subCat: " widget.title",
                                              ),
                                            ));
                                      } else {
                                        _dialogue(context,
                                            'Access ${userDashboard!.data.modules[i].categoryName}');
                                      }
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 15),
                                    child: Container(
                                      constraints: const BoxConstraints(
                                        maxHeight: 81,
                                      ),
                                      child: Column(
                                        children: [
                                          Container(
                                              constraints: const BoxConstraints(
                                                minHeight: 60,
                                                minWidth: 60,
                                                maxHeight: 70,
                                                maxWidth: 70,
                                              ),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.white,
                                                    width: 0),
                                                boxShadow: const [
                                                  BoxShadow(
                                                      color: Colors.grey,
                                                      blurRadius: 5,
                                                      offset: Offset(1, 1)),
                                                ],
                                                color: Colors.white,
                                                shape: BoxShape.rectangle,

                                                // image: AssetImage(
                                                //     'assets/images/img.jpeg')),
                                              ),
                                              // child: userDashboard != null
                                              //     ? CachedNetworkImage(
                                              //         fit: BoxFit.fill,
                                              //         imageUrl: userDashboard!
                                              //             .data.modules[i].image
                                              //             .toString(),
                                              //         placeholder:
                                              //             (context, url) =>
                                              //                 const Padding(
                                              //           padding: EdgeInsets.all(
                                              //               25.0),
                                              //           child:
                                              //               CircularProgressIndicator(
                                              //             color: Colors.grey,
                                              //           ),
                                              //         ),
                                              //         errorWidget: (context,
                                              //                 url, error) =>
                                              //             const Icon(
                                              //                 Icons.error),
                                              //       )
                                              //     : const SizedBox()),
                                              child: userDashboard != null
                                                  ? ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      child: CachedNetworkImage(
                                                        fit: BoxFit.cover,
                                                        imageUrl: userDashboard!
                                                            .data
                                                            .modules[i]
                                                            .image
                                                            .toString(),
                                                        placeholder:
                                                            (context, url) =>
                                                                const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  25.0),
                                                          child:
                                                              CircularProgressIndicator(
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            const Icon(
                                                                Icons.error),
                                                      ),
                                                    )
                                                  : const SizedBox()),
                                          const SizedBox(
                                            height: 4,
                                          ),
                                          const Expanded(
                                            child: Text(
                                              '',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        ),
                      ))
                  : const SizedBox(),
              if (isExpired != false)
                Padding(
                  padding: const EdgeInsets.only(top: 100.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(0.1),
                          child: Card(
                            // Set the shape of the card using a rounded rectangle border with a 8 pixel radius
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            // Set the clip behavior of the card
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            // Define the child widgets of the card
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                // Display an image at the top of the card that fills the width of the card and has a height of 160 pixels
                                Image.asset(
                                  'assets/main/packageimage.png',
                                  height: 160,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                                // Add a container with padding that contains the card's title, text, and buttons
                                Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(15, 15, 15, 0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      const Text(
                                        'Package Expired..',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.red,
                                        ),
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
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
                                    createLeadPermission == 'true'
                                        ? Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    AddLeads(widget.token)),
                                          ).then((r) {
                                            getData(
                                                widget.token, fromdate, todate);
                                            if (loadmore == true) {
                                              getStaffwise();
                                            }
                                          })
                                        : _dialogue(context, 'Add Leads');
                                  },
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * .3,
                                    height: 30,
                                    decoration: const BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey,
                                            offset: Offset(0, 2.0),
                                          )
                                        ],
                                        color: Color(0xFFf7f7f7),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(6))),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: const BoxDecoration(
                                              color: Color(0xFFe7e7e7),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(6))),
                                          child: const Icon(
                                            Icons.add,
                                            color: Color(0xFF7a7a7a),
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        const Text(
                                          'Add Leads',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Row(
                                  children: [
                                    // accessCallHistoryPermission == 'true'
                                    //     ?
                                    Row(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            // Navigator.push(
                                            //   context,
                                            //   MaterialPageRoute(builder: (context) => SearchPage(widget.token, updateLeadPermission1, deleteLeadPermission1, cloudCallPermission1, '')),
                                            // ).then((r) {
                                            //   getData(widget.token, fromdate, todate);
                                            //   if (loadmore == true) {
                                            //     getStaffwise();
                                            //   }
                                            // });
                                            // Navigator.push(
                                            //   context,
                                            //   PageRouteBuilder(
                                            //     pageBuilder: (context,
                                            //             animation,
                                            //             secondaryAnimation) =>
                                            //         Search(
                                            //       token: widget.token!,
                                            //       editLead:
                                            //           updateLeadPermission1,
                                            //       deleteLead:
                                            //           deleteLeadPermission1,
                                            //       cloudCall:
                                            //           cloudCallPermission1,
                                            //     ),
                                            //     transitionsBuilder:
                                            //         (context,
                                            //             animation,
                                            //             secondaryAnimation,
                                            //             child) {
                                            //       const begin = Offset(0.0, 1.0); // Slide from the right
                                            //       const end = Offset.zero;
                                            //       const curve =
                                            //           Curves.easeInOut;

                                            //       var tween = Tween(
                                            //               begin: begin,
                                            //               end: end)
                                            //           .chain(CurveTween(
                                            //               curve: curve));
                                            //       var offsetAnimation =
                                            //           animation
                                            //               .drive(tween);

                                            //       return SlideTransition(
                                            //         position:
                                            //             offsetAnimation,
                                            //         child: child,
                                            //       );
                                            //     },
                                            //   ),
                                            // ).then((r) {
                                            //   getData(widget.token,
                                            //       fromdate, todate);
                                            //   if (loadmore == true) {
                                            //     getStaffwise();
                                            //   }
                                            // });
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
                                            ).then((r) {
                                              getData(widget.token, fromdate,
                                                  todate);
                                              if (loadmore == true) {
                                                getStaffwise();
                                              }
                                            });
                                          },
                                          child: Container(
                                              width: 50,
                                              height: 32,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 15,
                                                      vertical: 5),
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.white,
                                                      width: 0),
                                                  boxShadow: const [
                                                    BoxShadow(
                                                        color: Colors.grey,
                                                        blurRadius: 5,
                                                        offset: Offset(1, 1)),
                                                  ],
                                                  color: Colors.white,
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(5))),
                                              child: const Icon(Icons.search)),
                                        ),
                                        const SizedBox(width: 10),
                                        InkWell(
                                          onTap: () {
                                            // Navigator.push(
                                            //   context,
                                            //   MaterialPageRoute(
                                            //       builder: (context) =>
                                            //           CallHistoryPage(
                                            //               widget.token!,
                                            //               name,
                                            //               userId,
                                            //               accessCallRecordingPermission1)),
                                            // );

                                            accessCallHistoryPermission ==
                                                    'true'
                                                ? Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            CallHistoryPage(
                                                                widget.token!,
                                                                name,
                                                                userId,
                                                                accessCallRecordingPermission1)),
                                                  )
                                                : _dialogue(
                                                    context, 'Call History');
                                          },
                                          child: Container(
                                              width: 50,
                                              height: 32,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 15,
                                                      vertical: 5),
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.white,
                                                      width: 0),
                                                  boxShadow: const [
                                                    BoxShadow(
                                                        color: Colors.grey,
                                                        blurRadius: 5,
                                                        offset: Offset(1, 1)),
                                                  ],
                                                  color: Colors.white,
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(5))),
                                              child: const Icon(
                                                Icons.phone_in_talk_rounded,
                                                size: 20,
                                              )),
                                        ),
                                      ],
                                    )
                                    // : const SizedBox(),

                                    // InkWell(
                                    //     onTap: () {
                                    //       // Navigator.push(
                                    //       //   context,
                                    //       //   MaterialPageRoute(
                                    //       //       builder: (context) => SearchPage(
                                    //       //           widget.token,
                                    //       //           updateLeadPermission1,
                                    //       //           deleteLeadPermission1,
                                    //       //           cloudCallPermission1,
                                    //       //           '')),
                                    //       // ).then((r) {
                                    //       //   getData(widget.token, fromdate,
                                    //       //       todate);
                                    //       //   if (loadmore == true) {
                                    //       //     getStaffwise();
                                    //       //   }
                                    //       // });
                                    //     },
                                    //     child: Container(
                                    //         width: 110,
                                    //         height: 32,
                                    //         padding:
                                    //             const EdgeInsets.symmetric(
                                    //                 horizontal: 15,
                                    //                 vertical: 5),
                                    //         decoration: BoxDecoration(
                                    //             border: Border.all(
                                    //                 color: Colors.white,
                                    //                 width: 0),
                                    //             boxShadow: const [
                                    //               BoxShadow(
                                    //                   color: Colors.grey,
                                    //                   blurRadius: 5,
                                    //                   offset: Offset(1, 1)),
                                    //             ],
                                    //             color: Colors.white,
                                    //             borderRadius:
                                    //                 const BorderRadius.all(
                                    //                     Radius.circular(
                                    //                         5))),
                                    //         child: Row(
                                    //           mainAxisAlignment:
                                    //               MainAxisAlignment.start,
                                    //           children: [
                                    //             const Icon(Icons.search),
                                    //             Expanded(
                                    //               child: Container(
                                    //                 margin: const EdgeInsets
                                    //                     .only(left: 10),
                                    //                 child: const Text(
                                    //                     'Search'),
                                    //               ),
                                    //             ),
                                    //           ],
                                    //         )),
                                    //   ),
                                    ,
                                    const SizedBox(width: 10),
                                    InkWell(
                                      onTap: () {
                                        showGeneralDialog(
                                          barrierLabel: "showGeneralDialog",
                                          barrierDismissible: true,
                                          barrierColor:
                                              Colors.black.withOpacity(0.6),
                                          transitionDuration:
                                              const Duration(milliseconds: 400),
                                          context: context,
                                          pageBuilder: (context, _, __) {
                                            return Align(
                                              alignment: Alignment.bottomCenter,
                                              child: IntrinsicHeight(
                                                child: Container(
                                                  width: double.maxFinite,
                                                  clipBehavior: Clip.antiAlias,
                                                  padding:
                                                      const EdgeInsets.all(16),
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(16),
                                                      topRight:
                                                          Radius.circular(16),
                                                    ),
                                                  ),
                                                  child: Material(
                                                    child: Column(
                                                      children: [
                                                        const SizedBox(
                                                            height: 20),
                                                        const Text(
                                                          'Filter By Date Range',
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 20),
                                                        Row(
                                                          children: [
                                                            SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.25,
                                                                child:
                                                                    const Text(
                                                                  'From Date',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                )),
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            SizedBox(
                                                              height: 50,
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.6,
                                                              child: Center(
                                                                child:
                                                                    DateTimePicker(
                                                                  decoration: InputDecoration(
                                                                      filled: true,
                                                                      //<-- SEE HERE
                                                                      fillColor: Colors.white,
                                                                      prefixIcon: const Icon(
                                                                        Icons
                                                                            .arrow_right,
                                                                        color: Colors
                                                                            .grey,
                                                                      ),
                                                                      counterText: "",
                                                                      hintText: 'From Date',
                                                                      isDense: true,
                                                                      border: OutlineInputBorder(borderSide: BorderSide(color: Colors.purple.shade100), borderRadius: BorderRadius.circular(5))),
                                                                  initialValue:
                                                                      fromdate
                                                                          .toString(),
                                                                  type:
                                                                      DateTimePickerType
                                                                          .date,

                                                                  //controller: fromDate,
                                                                  firstDate:
                                                                      DateTime(
                                                                          1995),
                                                                  lastDate: DateTime
                                                                          .now()
                                                                      .add(const Duration(
                                                                          days:
                                                                              365)),
                                                                  // This will add one year from current date
                                                                  validator:
                                                                      (value) {
                                                                    return null;
                                                                  },
                                                                  onChanged:
                                                                      (value) {
                                                                    if (value
                                                                        .isNotEmpty) {
                                                                      setState(
                                                                          () {
                                                                        fromdate =
                                                                            DateTime.parse(value);
                                                                      });
                                                                    }
                                                                  },
                                                                  // We can also use onSaved
                                                                  onSaved:
                                                                      (value) {
                                                                    if (value!
                                                                        .isNotEmpty) {
                                                                      fromdate =
                                                                          DateTime.parse(
                                                                              value);
                                                                    }
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        Row(
                                                          children: [
                                                            SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.25,
                                                                child:
                                                                    const Text(
                                                                  'To Date',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                )),
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            SizedBox(
                                                              height: 50,
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.6,
                                                              child: Center(
                                                                child:
                                                                    DateTimePicker(
                                                                  decoration: InputDecoration(
                                                                      filled: true,
                                                                      //<-- SEE HERE
                                                                      fillColor: Colors.white,
                                                                      prefixIcon: const Icon(
                                                                        Icons
                                                                            .arrow_right,
                                                                        color: Colors
                                                                            .grey,
                                                                      ),
                                                                      counterText: "",
                                                                      hintText: 'To date',
                                                                      isDense: true,
                                                                      border: OutlineInputBorder(borderSide: BorderSide(color: Colors.purple.shade100), borderRadius: BorderRadius.circular(5))),
                                                                  initialValue:
                                                                      todate
                                                                          .toString(),
                                                                  type:
                                                                      DateTimePickerType
                                                                          .date,

                                                                  //controller: fromDate,
                                                                  firstDate:
                                                                      DateTime(
                                                                          1995),
                                                                  lastDate: DateTime
                                                                          .now()
                                                                      .add(const Duration(
                                                                          days:
                                                                              365)),
                                                                  // This will add one year from current date
                                                                  validator:
                                                                      (value) {
                                                                    return null;
                                                                  },
                                                                  onChanged:
                                                                      (value) {
                                                                    if (value
                                                                        .isNotEmpty) {
                                                                      setState(
                                                                          () {
                                                                        todate =
                                                                            DateTime.parse(value);
                                                                      });
                                                                    }
                                                                  },
                                                                  // We can also use onSaved
                                                                  onSaved:
                                                                      (value) {
                                                                    if (value!
                                                                        .isNotEmpty) {
                                                                      todate = DateTime
                                                                          .parse(
                                                                              value);
                                                                    }
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                            height: 16),
                                                        Container(
                                                          height: 40,
                                                          width:
                                                              double.maxFinite,
                                                          decoration:
                                                              const BoxDecoration(
                                                            color: Color(
                                                                0xFF3375e0),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            8)),
                                                          ),
                                                          child:
                                                              RawMaterialButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                data.remove(
                                                                    data);
                                                              });
                                                              getStaffwise();
                                                              getData(
                                                                  widget.token,
                                                                  fromdate,
                                                                  todate);
                                                              Navigator.of(
                                                                      context,
                                                                      rootNavigator:
                                                                          true)
                                                                  .pop();
                                                            },
                                                            child: const Center(
                                                              child: Text(
                                                                'Continue',
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          transitionBuilder:
                                              (_, animation1, __, child) {
                                            return SlideTransition(
                                              position: Tween(
                                                begin: const Offset(0, 1),
                                                end: const Offset(0, 0),
                                              ).animate(animation1),
                                              child: child,
                                            );
                                          },
                                        );
                                      },
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        child: Center(
                                          child: Center(
                                              child: Image.asset(
                                                  "assets/icons/calendar.png",
                                                  width: 32)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    if (configure != null)
                                      isExpired == false &&
                                              leadDashboard != null
                                          ? PopupMenuButton(
                                              child: Container(
                                                width: 35,
                                                height: 35,
                                                decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                        blurRadius: 3,
                                                        color: Colors
                                                            .grey.shade800,
                                                      )
                                                    ],
                                                    shape: BoxShape.circle,
                                                    color: Colors.white),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Image.asset(
                                                    "assets/icons/settings.png",
                                                  ),
                                                ),
                                              ),
                                              itemBuilder: (context) {
                                                return [
                                                  const PopupMenuItem<int>(
                                                      value: 11,
                                                      child: Row(
                                                        children: [
                                                          SizedBox(
                                                            width: 20,
                                                            height: 20,
                                                            child: Icon(
                                                              Icons
                                                                  .upload_outlined,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text('Upload Logs'),
                                                        ],
                                                      )),
                                                  PopupMenuItem<int>(
                                                      value: 9,
                                                      child: Row(
                                                        children: [
                                                          SizedBox(
                                                            width: 20,
                                                            height: 20,
                                                            child: Image.asset(
                                                              "assets/icons/all_reports.png",
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          const Text(
                                                              'All Report'),
                                                        ],
                                                      )),
                                                  PopupMenuItem<int>(
                                                      value: 2,
                                                      child: Row(
                                                        children: [
                                                          SizedBox(
                                                            width: 20,
                                                            height: 20,
                                                            child: Image.asset(
                                                              "assets/icons/leadCategory.png",
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          const Text(
                                                              'Lead Category'),
                                                        ],
                                                      )),
                                                  PopupMenuItem<int>(
                                                      value: 6,
                                                      child: Row(
                                                        children: [
                                                          SizedBox(
                                                            width: 20,
                                                            height: 20,
                                                            child: Image.asset(
                                                              "assets/icons/callHistory.png",
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          const Text(
                                                              'Call History'),
                                                        ],
                                                      )),

                                                  // PopupMenuItem<int>(
                                                  //   // value: 6,
                                                  //   // onTap: () {
                                                  //   //   Future.delayed(
                                                  //   //       Duration.zero, () {
                                                  //   //     showAddWorkDialog(
                                                  //   //         context);
                                                  //   //   });
                                                  //   // },
                                                  //   onTap: () async {
                                                  //     final workStatusModel =
                                                  //         await HttpService
                                                  //             .getWorkStatus();

                                                  //     WorkStatus? existingWork;
                                                  //     if (workStatusModel !=
                                                  //             null &&
                                                  //         workStatusModel.data
                                                  //             .isNotEmpty) {
                                                  //       existingWork =
                                                  //           workStatusModel
                                                  //               .data.first;
                                                  //     }

                                                  //     Navigator.push(
                                                  //       context,
                                                  //       MaterialPageRoute(
                                                  //         builder: (context) =>
                                                  //             AddWorkPage(
                                                  //           existingWork:
                                                  //               existingWork, // null if no work in progress
                                                  //           onSuccess: () {
                                                  //             setState(() {
                                                  //               getData(
                                                  //                   widget
                                                  //                       .token,
                                                  //                   fromdate,
                                                  //                   todate);
                                                  //             });
                                                  //           },
                                                  //         ),
                                                  //       ),
                                                  //     );
                                                  //   },

                                                  //   child: Row(
                                                  //     children: const [
                                                  //       Icon(
                                                  //           Icons
                                                  //               .call_made_outlined,
                                                  //           size: 20),
                                                  //       SizedBox(width: 10),
                                                  //       Text('Add Work'),
                                                  //     ],
                                                  //   ),
                                                  // ),

                                                  adminCheckPermission == "true"
                                                      ? PopupMenuItem<int>(
                                                          // value: 6,
                                                          // onTap: () {
                                                          //   Future.delayed(
                                                          //       Duration.zero, () {
                                                          //     showAddWorkDialog(
                                                          //         context);
                                                          //   });
                                                          // },
                                                          onTap: () async {
                                                            final workStatusModel =
                                                                await HttpService
                                                                    .getWorkStatus();

                                                            WorkStatus?
                                                                existingWork;
                                                            if (workStatusModel !=
                                                                    null &&
                                                                workStatusModel
                                                                    .data
                                                                    .isNotEmpty) {
                                                              existingWork =
                                                                  workStatusModel
                                                                      .data
                                                                      .first;
                                                            }

                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        const ViewCompanyWorkPage(),
                                                                settings:
                                                                    const RouteSettings(
                                                                  arguments: {
                                                                    //  "staffId": staffId
                                                                  },
                                                                ),
                                                              ),
                                                            );
                                                          },

                                                          child: const Row(
                                                            children: [
                                                              Icon(
                                                                  Icons
                                                                      .view_agenda,
                                                                  size: 20),
                                                              SizedBox(
                                                                  width: 10),
                                                              Text(
                                                                  'View Works'),
                                                            ],
                                                          ),
                                                        )
                                                      : const PopupMenuItem<
                                                          int>(
                                                          enabled: false,
                                                          height: 0,
                                                          child:
                                                              SizedBox.shrink(),
                                                        ),

                                                  PopupMenuItem<int>(
                                                    onTap: () async {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              const ViewCalendarPage(),
                                                        ),
                                                      );
                                                    },
                                                    child: const Row(
                                                      children: [
                                                        Icon(
                                                            Icons
                                                                .calendar_month,
                                                            size: 20),
                                                        SizedBox(width: 10),
                                                        Text('Add Attendance'),
                                                      ],
                                                    ),
                                                  ),

                                                  PopupMenuItem<int>(
                                                    onTap: () async {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              const SalaryReportPage(),
                                                        ),
                                                      );
                                                    },
                                                    child: const Row(
                                                      children: [
                                                        Icon(Icons.attach_money,
                                                            size: 20),
                                                        SizedBox(width: 10),
                                                        Text('Salary Report'),
                                                      ],
                                                    ),
                                                  ),

                                                  PopupMenuItem<int>(
                                                    onTap: () async {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              const PendingWorkPage(),
                                                        ),
                                                      );
                                                    },
                                                    child: const Row(
                                                      children: [
                                                        Icon(
                                                            Icons
                                                                .pending_actions,
                                                            size: 20),
                                                        SizedBox(width: 10),
                                                        Text('Pending Works'),
                                                      ],
                                                    ),
                                                  ),
                                                  PopupMenuItem<int>(
                                                    onTap: () async {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              AssignReport(
                                                                  workId: "",
                                                                  sectionId:
                                                                      ""),
                                                        ),
                                                      );
                                                    },
                                                    child: const Row(
                                                      children: [
                                                        Icon(Icons.assignment,
                                                            size: 20),
                                                        SizedBox(width: 10),
                                                        Text('Assigned Works'),
                                                      ],
                                                    ),
                                                  ),
                                                  viewTargetReportPermission ==
                                                          'true'
                                                      ? PopupMenuItem<int>(
                                                          onTap: () async {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (context) =>
                                                                    ViewAllTargetReportPage(
                                                                        id: userId),
                                                              ),
                                                            );
                                                          },
                                                          child: const Row(
                                                            children: [
                                                              Icon(
                                                                  Icons
                                                                      .track_changes,
                                                                  size: 20),
                                                              SizedBox(
                                                                  width: 10),
                                                              Text(
                                                                  'View Target Report'),
                                                            ],
                                                          ),
                                                        )
                                                      : const PopupMenuItem<
                                                          int>(
                                                          enabled: false,
                                                          height: 0,
                                                          child:
                                                              SizedBox.shrink(),
                                                        ),
                                                  //        PopupMenuItem<int>(
                                                  //   onTap: () async {
                                                  //     Navigator.push(
                                                  //       context,
                                                  //       MaterialPageRoute(
                                                  //         builder: (context) =>
                                                  //             SetDashboardPage(
                                                  //                 id: userId),
                                                  //       ),
                                                  //     );
                                                  //   },
                                                  //   child: const Row(
                                                  //     children: [
                                                  //       Icon(
                                                  //           Icons.dashboard_customize,
                                                  //           size: 20),
                                                  //       SizedBox(width: 10),
                                                  //       Text(
                                                  //           'Set Dashboard'),
                                                  //     ],
                                                  //   ),
                                                  // ),
                                                  // PopupMenuItem<int>(
                                                  //   onTap: () async {
                                                  //     Navigator.push(
                                                  //       context,
                                                  //       MaterialPageRoute(
                                                  //         builder: (context) =>
                                                  //             const PendingWorkPage(),
                                                  //       ),
                                                  //     );
                                                  //   },
                                                  //   child: const Row(
                                                  //     children: [
                                                  //       Icon(Icons.attach_money,
                                                  //           size: 20),
                                                  //       SizedBox(width: 10),
                                                  //       Text('Pending Report'),
                                                  //     ],
                                                  //   ),
                                                  // ),
                                                  adminCheckPermission ==
                                                          "false"
                                                      ? PopupMenuItem<int>(
                                                          // onTap: () async {
                                                          //   final workStatusModel =
                                                          //       await HttpService
                                                          //           .getWorkStatus();
                                                          //   WorkStatus?
                                                          //       existingWork;
                                                          //   if (workStatusModel !=
                                                          //           null &&
                                                          //       workStatusModel
                                                          //           .data
                                                          //           .isNotEmpty) {
                                                          //     existingWork =
                                                          //         workStatusModel
                                                          //             .data
                                                          //             .first;
                                                          //   }
                                                          //   Navigator.push(
                                                          //     context,
                                                          //     MaterialPageRoute(
                                                          //       builder:
                                                          //           (context) =>
                                                          //               const ViewWorkPage(
                                                          //         staffId: '',
                                                          //       ),
                                                          //       settings:
                                                          //           RouteSettings(
                                                          //         arguments: {
                                                          //           "staffId":
                                                          //               staffId
                                                          //         },
                                                          //       ),
                                                          //     ),
                                                          //   );
                                                          // },
                                                          onTap: () async {
                                                            final workStatusModel =
                                                                await HttpService
                                                                    .getWorkStatus();
                                                            WorkStatus?
                                                                existingWork;
                                                            if (workStatusModel !=
                                                                    null &&
                                                                workStatusModel
                                                                    .data
                                                                    .isNotEmpty) {
                                                              existingWork =
                                                                  workStatusModel
                                                                      .data
                                                                      .first;
                                                            }

                                                            if (multipleWorksCheck ==
                                                                "true") {
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) {
                                                                  return AlertDialog(
                                                                    title: const Text(
                                                                        "Phone Call Log"),
                                                                    content:
                                                                        const Text(
                                                                            "Choose an action below"),
                                                                    actions: [
                                                                      TextButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pop(
                                                                              context);
                                                                          Navigator
                                                                              .push(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                              builder: (_) => ViewWorkPage(staffId: staffId),
                                                                            ),
                                                                          );
                                                                        },
                                                                        child: const Text(
                                                                            "Works"),
                                                                      ),
                                                                      TextButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pop(
                                                                              context);
                                                                          Navigator
                                                                              .push(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                              builder: (_) => const TimelinePage(),
                                                                              settings: RouteSettings(
                                                                                arguments: {
                                                                                  "staffId": userId
                                                                                },
                                                                              ),
                                                                            ),
                                                                          );
                                                                        },
                                                                        child: const Text(
                                                                            "Call Log"),
                                                                      ),
                                                                    ],
                                                                  );
                                                                },
                                                              );
                                                            } else if (multipleWorksCheck ==
                                                                "phone") {
                                                              // case: "phone"
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (_) =>
                                                                      const TimelinePage(),
                                                                  settings:
                                                                      RouteSettings(
                                                                          arguments: {
                                                                        "staffId":
                                                                            staffId
                                                                      }),
                                                                ),
                                                              );
                                                            } else {
                                                              // case: "work"
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (_) =>
                                                                      ViewWorkPage(
                                                                          staffId:
                                                                              staffId),
                                                                ),
                                                              );
                                                            }
                                                          },

                                                          child: const Row(
                                                            children: [
                                                              Icon(
                                                                  Icons
                                                                      .view_agenda,
                                                                  size: 20),
                                                              SizedBox(
                                                                  width: 10),
                                                              Text('View Work'),
                                                            ],
                                                          ),
                                                        )
                                                      : const PopupMenuItem<
                                                          int>(
                                                          enabled: false,
                                                          height: 0,
                                                          child:
                                                              SizedBox.shrink(),
                                                        ),

                                                  viewWorkReportPermission ==
                                                              "true" &&
                                                          adminCheckPermission !=
                                                              "true"
                                                      ? PopupMenuItem<int>(
                                                          onTap: () {
                                                            Future.delayed(
                                                                Duration.zero,
                                                                () {
                                                              print(
                                                                  "Navigating with staffId: $userId");
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          const TimelinePage(),
                                                                  settings:
                                                                      RouteSettings(
                                                                    arguments: {
                                                                      "staffId":
                                                                          userId,
                                                                    },
                                                                  ),
                                                                ),
                                                              );
                                                            });
                                                          },
                                                          child: Row(
                                                            children: const [
                                                              Icon(Icons.report,
                                                                  size: 20),
                                                              SizedBox(
                                                                  width: 10),
                                                              Text(
                                                                  'View Work Report'),
                                                            ],
                                                          ),
                                                        )
                                                      : const PopupMenuItem<
                                                          int>(
                                                          enabled: false,
                                                          height: 0,
                                                          child:
                                                              SizedBox.shrink(),
                                                        ),
                                                ];
                                              },
                                              onSelected: (value) async {
                                                if (value == 11) {
                                                  // todo : show loader
                                                  // todo : upload call logs
                                                  // todo : hide loader

                                                  setState(() {
                                                    isLoading = true;
                                                  });
                                                  await getSharedData();
                                                  setState(() {
                                                    isLoading = false;
                                                  });
                                                }
                                                if (value == 1) {}
                                                if (value == 2) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ViewLeadCategory(
                                                                widget.token!,
                                                                createLeadCategory1,
                                                                updateLeadCategory1,
                                                                deleteLeadCategory1)),
                                                  );
                                                }
                                                if (value == 3) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            WhatsappSettings(
                                                                widget.token)),
                                                  );
                                                }
                                                if (value == 4) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            const NotificationTemplateSettings()),
                                                  );
                                                }
                                                if (value == 5) {
                                                  Common.saveSharedPref(
                                                      "statusWise", 'no');
                                                  viewLeadPermission == 'true'
                                                      ? Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      ViewLeads(
                                                                        widget
                                                                            .token,
                                                                        updateLeadPermission1,
                                                                        deleteLeadPermission1,
                                                                        cloudCallPermission1,
                                                                        pageName:
                                                                            'View Leads',
                                                                        fromDate:
                                                                            fromdate.toString(),
                                                                        toDate:
                                                                            todate.toString(),
                                                                      )),
                                                        ).then((r) {
                                                          getData(widget.token,
                                                              fromdate, todate);
                                                          if (loadmore ==
                                                              true) {
                                                            getStaffwise();
                                                          }
                                                        })
                                                      : _dialogue(context,
                                                          'View Leads');
                                                }
                                                if (value == 6) {
                                                  accessCallHistoryPermission ==
                                                          'true'
                                                      ? Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  CallHistoryPage(
                                                                      widget
                                                                          .token!,
                                                                      name,
                                                                      userId,
                                                                      accessCallRecordingPermission1)),
                                                        )
                                                      : _dialogue(context,
                                                          'Call History');
                                                }
                                                if (value == 7) {
                                                  Common.saveSharedPref(
                                                      "statusWise", 'no');
                                                  viewLeadPermission == 'true'
                                                      ? Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      ViewLeads(
                                                                        widget
                                                                            .token,
                                                                        updateLeadPermission1,
                                                                        deleteLeadPermission1,
                                                                        cloudCallPermission1,
                                                                        pageName:
                                                                            'Missed Leads',
                                                                        fromDate:
                                                                            fromdate.toString(),
                                                                        toDate:
                                                                            todate.toString(),
                                                                        leadType:
                                                                            '1',
                                                                        callStatus:
                                                                            "-1",
                                                                      )),
                                                        ).then((r) {
                                                          getData(widget.token,
                                                              fromdate, todate);
                                                          if (loadmore ==
                                                              true) {
                                                            getStaffwise();
                                                          }
                                                        })
                                                      : _dialogue(context,
                                                          'View Leads');
                                                }
                                                if (value == 8) {
                                                  Common.saveSharedPref(
                                                      "statusWise", 'no');
                                                  viewLeadPermission == 'true'
                                                      ? Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) => ViewLeads(
                                                                  widget.token,
                                                                  updateLeadPermission1,
                                                                  deleteLeadPermission1,
                                                                  cloudCallPermission1,
                                                                  pageName:
                                                                      'Transfer Leads',
                                                                  fromDate: fromdate
                                                                      .toString(),
                                                                  toDate: todate
                                                                      .toString(),
                                                                  leadType:
                                                                      '2')),
                                                        ).then((r) {
                                                          getData(widget.token,
                                                              fromdate, todate);
                                                          if (loadmore ==
                                                              true) {
                                                            getStaffwise();
                                                          }
                                                        })
                                                      : _dialogue(context,
                                                          'View Leads');
                                                }
                                                if (value == 9) {
                                                  Common.saveSharedPref(
                                                      "statusWise", 'no');
                                                  viewLeadPermission == 'true'
                                                      ? Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      AllReport(
                                                                        widget
                                                                            .token!,
                                                                        updateLeadPermission1,
                                                                        deleteLeadPermission1,
                                                                        cloudCallPermission1,
                                                                        pageName:
                                                                            'AllLeads',
                                                                      )),
                                                        )
                                                      : _dialogue(context,
                                                          'View Leads');
                                                }
                                                if (value == 10) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            CallLogs(
                                                              widget.token,
                                                              name,
                                                              userId,
                                                            )),
                                                  ).then((r) {
                                                    getData(widget.token,
                                                        fromdate, todate);
                                                    if (loadmore == true) {
                                                      getStaffwise();
                                                    }
                                                  });
                                                }
                                              })
                                          : const SizedBox()
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                // ────────────── New Leads ──────────────
                                InkWell(
                                  onTap: () {
                                    Common.saveSharedPref("statusWise", 'no');
                                    if (viewLeadPermission == 'true') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ViewLeads(
                                            widget.token,
                                            updateLeadPermission1,
                                            deleteLeadPermission1,
                                            cloudCallPermission1,
                                            pageName: 'New Leads',
                                            fromDate: fromdate.toString(),
                                            toDate: todate.toString(),
                                            status: '1',
                                          ),
                                        ),
                                      ).then((r) {
                                        getData(widget.token, fromdate, todate);
                                        if (loadmore == true) getStaffwise();
                                      });
                                    } else {
                                      _dialogue(context, 'View Leads');
                                    }
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.42,
                                    height: MediaQuery.of(context).size.height *
                                        0.15,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFf0ebef),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          top: 10,
                                          left: 10,
                                          right: 10,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                "New Leads",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 13,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  dynamic toolTip =
                                                      _toolTipKey.currentState;
                                                  toolTip
                                                      .ensureTooltipVisible();
                                                },
                                                child: Tooltip(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  message:
                                                      'The combined count of new leads \n and unattended leads',
                                                  key: _toolTipKey,
                                                  child: Container(
                                                    width: 20,
                                                    height: 20,
                                                    decoration:
                                                        const BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.white,
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        '?',
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors
                                                              .grey.shade700,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          top: 35,
                                          left: 0,
                                          right: 35,
                                          child: GestureDetector(
                                            onTap: () async {
                                              if (!_showNewLeadsCount) {
                                                setState(() {
                                                  _isLoadingNewLeads =
                                                      true; // start loader
                                                });

                                                var result = await HttpService
                                                    .leadDashboardNew(
                                                  widget.token,
                                                  fromdate,
                                                  todate,
                                                  fromdate1,
                                                  todate1,
                                                  "1",
                                                );

                                                if (result != null) {
                                                  setState(() {
                                                    newLeadsDashboard = result;
                                                    _showNewLeadsCount = true;
                                                    _isLoadingNewLeads =
                                                        false; // stop loader
                                                  });
                                                } else {
                                                  setState(() {
                                                    _isLoadingNewLeads =
                                                        false; // stop loader on failure
                                                  });
                                                }
                                              } else {
                                                setState(() {
                                                  _showNewLeadsCount = false;
                                                });
                                              }
                                            },
                                            child: Container(
                                              height: 40,
                                              alignment: Alignment.center,
                                              child: _isLoadingNewLeads
                                                  ? SizedBox(
                                                      height: 20,
                                                      width: 20,
                                                      child:
                                                          CircularProgressIndicator(
                                                              strokeWidth: 2),
                                                    )
                                                  : _showNewLeadsCount &&
                                                          newLeadsDashboard !=
                                                              null
                                                      ? Text(
                                                          newLeadsDashboard!
                                                              .data.newLeads
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                            fontSize: 20,
                                                          ),
                                                        )
                                                      : Icon(
                                                          Icons.visibility,
                                                          size: 22,
                                                          color: Colors
                                                              .grey.shade700,
                                                        ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 10,
                                          left: 10,
                                          right: 10,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              const Text(
                                                "View Leads",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () async {
                                                  Common.saveSharedPref(
                                                      "statusWise", 'no');
                                                  await getLeadProgressbar(
                                                    widget.token,
                                                    fromdate,
                                                    todate,
                                                    '1',
                                                  );
                                                  if (object1!.status == true &&
                                                      context.mounted) {
                                                    Navigator.pop(context);
                                                    leadProgressbarDialog(
                                                        context,
                                                        "New Leads",
                                                        "1",
                                                        "");
                                                  }
                                                },
                                                child: Container(
                                                  width: 30,
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors
                                                            .grey.shade500,
                                                        offset: const Offset(
                                                            0, 2.0),
                                                        blurRadius: 2,
                                                      ),
                                                    ],
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    child: Center(
                                                      child: Image.asset(
                                                          "assets/icons/lineSegment.png"),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 15),

                                // ────────────── Followup Leads ──────────────
                                InkWell(
                                  onTap: () {
                                    Common.saveSharedPref("statusWise", 'no');
                                    if (viewLeadPermission == 'true') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ViewLeads(
                                            widget.token,
                                            updateLeadPermission1,
                                            deleteLeadPermission1,
                                            cloudCallPermission1,
                                            pageName: 'Followup Leads',
                                            fromDate: DateTime(
                                                    DateTime.now().year,
                                                    DateTime.now().month - 3,
                                                    DateTime.now().day)
                                                .toString(),
                                            toDate: todate.toString(),
                                            status: '2',
                                          ),
                                        ),
                                      ).then((r) {
                                        getData(widget.token, fromdate, todate);
                                        if (loadmore == true) getStaffwise();
                                      });
                                    } else {
                                      _dialogue(context, 'View Leads');
                                    }
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.42,
                                    height: MediaQuery.of(context).size.height *
                                        0.15,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 204, 211, 224),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          top: 10,
                                          left: 10,
                                          right: 10,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                "Followup Leads",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 13,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  dynamic toolTip1 =
                                                      _toolTipKey1.currentState;
                                                  toolTip1
                                                      .ensureTooltipVisible();
                                                },
                                                child: Tooltip(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  message:
                                                      'The current count of leads \n assigned for today including \n missed follow up leads',
                                                  key: _toolTipKey1,
                                                  child: Container(
                                                    width: 20,
                                                    height: 20,
                                                    decoration:
                                                        const BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.white,
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        '?',
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors
                                                              .grey.shade700,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          top: 35,
                                          left: 0,
                                          right: 45,
                                          child: GestureDetector(
                                            onTap: () async {
                                              if (!_showFollowupLeadsCount) {
                                                setState(() {
                                                  _isLoadingFollowupLeads =
                                                      true; // start loader
                                                });

                                                var result = await HttpService
                                                    .leadDashboardNew(
                                                  widget.token,
                                                  fromdate,
                                                  todate,
                                                  fromdate1,
                                                  todate1,
                                                  "2",
                                                );

                                                if (result != null) {
                                                  setState(() {
                                                    followupLeadsDashboard =
                                                        result;
                                                    _showFollowupLeadsCount =
                                                        true;
                                                    _isLoadingFollowupLeads =
                                                        false; // stop loader
                                                  });
                                                } else {
                                                  setState(() {
                                                    _isLoadingFollowupLeads =
                                                        false; // stop loader on failure
                                                  });
                                                }
                                              } else {
                                                setState(() {
                                                  _showFollowupLeadsCount =
                                                      false;
                                                });
                                              }
                                            },
                                            child: Container(
                                              height: 40,
                                              alignment: Alignment.center,
                                              child: _isLoadingFollowupLeads
                                                  ? SizedBox(
                                                      height: 20,
                                                      width: 20,
                                                      child:
                                                          CircularProgressIndicator(
                                                              strokeWidth: 2),
                                                    )
                                                  : _showFollowupLeadsCount &&
                                                          followupLeadsDashboard !=
                                                              null
                                                      ? Text(
                                                          followupLeadsDashboard!
                                                              .data
                                                              .followupLeads
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                            fontSize: 20,
                                                          ),
                                                        )
                                                      : Icon(
                                                          Icons.visibility,
                                                          size: 22,
                                                          color: Colors
                                                              .grey.shade700,
                                                        ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 10,
                                          left: 10,
                                          right: 10,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              const Text(
                                                "View Leads",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () async {
                                                  Common.showProgressDialog(
                                                      context, "Loading..");
                                                  Common.saveSharedPref(
                                                      "statusWise", 'no');
                                                  await getLeadProgressbar(
                                                    widget.token,
                                                    fromdate,
                                                    todate,
                                                    '2',
                                                  );
                                                  if (object1!.status == true &&
                                                      context.mounted) {
                                                    Navigator.pop(context);
                                                    leadProgressbarDialog(
                                                      context,
                                                      "Followup Leads",
                                                      "2",
                                                      "",
                                                    );
                                                  }
                                                },
                                                child: Container(
                                                  width: 30,
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors
                                                            .grey.shade500,
                                                        offset: const Offset(
                                                            0, 2.0),
                                                        blurRadius: 2,
                                                      ),
                                                    ],
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    child: Center(
                                                      child: Image.asset(
                                                          "assets/icons/lineSegment.png"),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                // ────────────── Closed Leads ──────────────
                                InkWell(
                                  onTap: () {
                                    Common.saveSharedPref("statusWise", 'no');
                                    if (viewLeadPermission == 'true') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ViewLeads(
                                            widget.token,
                                            updateLeadPermission1,
                                            deleteLeadPermission1,
                                            cloudCallPermission1,
                                            pageName: 'Closed Leads',
                                            fromDate: fromdate.toString(),
                                            toDate: todate.toString(),
                                            status: '4',
                                          ),
                                        ),
                                      ).then((r) {
                                        getData(widget.token, fromdate, todate);
                                        if (loadmore == true) getStaffwise();
                                      });
                                    } else {
                                      _dialogue(context, 'View Leads');
                                    }
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.42,
                                    height: MediaQuery.of(context).size.height *
                                        0.15,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 206, 243, 240),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Stack(
                                      children: [
                                        // Header with tooltip
                                        Positioned(
                                          top: 10,
                                          left: 10,
                                          right: 10,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                "Closed Leads",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 13,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  dynamic toolTip2 =
                                                      _toolTipKey2.currentState;
                                                  toolTip2
                                                      .ensureTooltipVisible();
                                                },
                                                child: Tooltip(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  message:
                                                      'Closed leads can be filtered \n using a specific date range to \n determine the count of closed \n leads within that period',
                                                  key: _toolTipKey2,
                                                  child: Container(
                                                    width: 20,
                                                    height: 20,
                                                    decoration:
                                                        const BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.white,
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        '?',
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors
                                                              .grey.shade700,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Count
                                        Positioned(
                                          top: 35,
                                          left: 0,
                                          right: 35,
                                          child: GestureDetector(
                                            onTap: () async {
                                              if (!_showClosedLeadsCount) {
                                                setState(() {
                                                  _isLoadingClosedLeads =
                                                      true; // start loader
                                                });

                                                var result = await HttpService
                                                    .leadDashboardNew(
                                                  widget.token,
                                                  fromdate,
                                                  todate,
                                                  fromdate1,
                                                  todate1,
                                                  "3", // leadType = 3 for Closed Leads
                                                );

                                                if (result != null) {
                                                  setState(() {
                                                    closedLeadsDashboard =
                                                        result;
                                                    _showClosedLeadsCount =
                                                        true;
                                                    _isLoadingClosedLeads =
                                                        false; // stop loader
                                                  });
                                                } else {
                                                  setState(() {
                                                    _isLoadingClosedLeads =
                                                        false; // stop loader on failure
                                                  });
                                                }
                                              } else {
                                                setState(() {
                                                  _showClosedLeadsCount = false;
                                                });
                                              }
                                            },
                                            child: Container(
                                              height: 40,
                                              alignment: Alignment.center,
                                              child: _isLoadingClosedLeads
                                                  ? SizedBox(
                                                      height: 20,
                                                      width: 20,
                                                      child:
                                                          CircularProgressIndicator(
                                                              strokeWidth: 2),
                                                    )
                                                  : _showClosedLeadsCount &&
                                                          closedLeadsDashboard !=
                                                              null
                                                      ? Text(
                                                          closedLeadsDashboard!
                                                              .data.closedLeads
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                            fontSize: 20,
                                                          ),
                                                        )
                                                      : Icon(
                                                          Icons.visibility,
                                                          size: 22,
                                                          color: Colors
                                                              .grey.shade700,
                                                        ),
                                            ),
                                          ),
                                        ),

                                        // View Leads button
                                        Positioned(
                                          bottom: 10,
                                          left: 10,
                                          right: 10,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              const Text(
                                                "View Leads",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () async {
                                                  Common.showProgressDialog(
                                                      context, "Loading..");
                                                  Common.saveSharedPref(
                                                      "statusWise", 'no');
                                                  await getLeadProgressbar(
                                                    widget.token,
                                                    fromdate,
                                                    todate,
                                                    '4',
                                                  );
                                                  if (object1!.status == true &&
                                                      context.mounted) {
                                                    Navigator.pop(context);
                                                    leadProgressbarDialog(
                                                      context,
                                                      "Closed Leads",
                                                      "4",
                                                      "",
                                                    );
                                                  }
                                                },
                                                child: Container(
                                                  width: 30,
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors
                                                            .grey.shade500,
                                                        offset: const Offset(
                                                            0, 2.0),
                                                        blurRadius: 2,
                                                      ),
                                                    ],
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    child: Center(
                                                      child: Image.asset(
                                                          "assets/icons/lineSegment.png"),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 15),

                                // ────────────── Total Called ──────────────
                                InkWell(
                                  onTap: () {
                                    Common.saveSharedPref("statusWise", 'no');
                                    if (viewLeadPermission == 'true') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ViewLeads(
                                            widget.token,
                                            updateLeadPermission1,
                                            deleteLeadPermission1,
                                            cloudCallPermission1,
                                            pageName: 'Total Called',
                                            fromDate: fromdate.toString(),
                                            toDate: todate.toString(),
                                            leadType: "-1",
                                            callStatus: "1",
                                            status: '0',
                                          ),
                                        ),
                                      ).then((r) {
                                        getData(widget.token, fromdate, todate);
                                        if (loadmore == true) getStaffwise();
                                      });
                                    } else {
                                      _dialogue(context, 'View Leads');
                                    }
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.42,
                                    height: MediaQuery.of(context).size.height *
                                        0.15,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFb4c2dd),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Stack(
                                      children: [
                                        // Header + tooltip
                                        Positioned(
                                          top: 10,
                                          left: 10,
                                          right: 10,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                "Total Called",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 13,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  dynamic toolTip3 =
                                                      _toolTipKey3.currentState;
                                                  toolTip3
                                                      .ensureTooltipVisible();
                                                },
                                                child: Tooltip(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  message:
                                                      'Total called can be filtered \n using a specific date range to \n determine the count of total leads \n within that period',
                                                  key: _toolTipKey3,
                                                  child: Container(
                                                    width: 20,
                                                    height: 20,
                                                    decoration:
                                                        const BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.white,
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        '?',
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Count
                                        Positioned(
                                          top: 35,
                                          left: 0,
                                          right: 35,
                                          child: GestureDetector(
                                            onTap: () async {
                                              if (!_showTotalCalledCount) {
                                                setState(() {
                                                  _isLoadingTotalCalled =
                                                      true; // start loader
                                                });

                                                var result = await HttpService
                                                    .leadDashboardNew(
                                                  widget.token,
                                                  fromdate,
                                                  todate,
                                                  fromdate1,
                                                  todate1,
                                                  "4", // leadType = 4 for Total Called
                                                );

                                                if (result != null) {
                                                  setState(() {
                                                    totalCalledDashboard =
                                                        result;
                                                    _showTotalCalledCount =
                                                        true;
                                                    _isLoadingTotalCalled =
                                                        false; // stop loader
                                                  });
                                                } else {
                                                  setState(() {
                                                    _isLoadingTotalCalled =
                                                        false; // stop loader on failure
                                                  });
                                                }
                                              } else {
                                                setState(() {
                                                  _showTotalCalledCount = false;
                                                });
                                              }
                                            },
                                            child: Container(
                                              height: 40,
                                              alignment: Alignment.center,
                                              child: _isLoadingTotalCalled
                                                  ? SizedBox(
                                                      height: 20,
                                                      width: 20,
                                                      child:
                                                          CircularProgressIndicator(
                                                              strokeWidth: 2),
                                                    )
                                                  : _showTotalCalledCount &&
                                                          totalCalledDashboard !=
                                                              null
                                                      ? Text(
                                                          totalCalledDashboard!
                                                              .data.totalCalled
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                            fontSize: 20,
                                                          ),
                                                        )
                                                      : Icon(
                                                          Icons.visibility,
                                                          size: 22,
                                                          color: Colors
                                                              .grey.shade700,
                                                        ),
                                            ),
                                          ),
                                        ),

                                        // View Leads button
                                        Positioned(
                                          bottom: 10,
                                          left: 10,
                                          right: 10,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              const Text(
                                                "View Leads",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () async {
                                                  Common.showProgressDialog(
                                                      context, "Loading..");
                                                  Common.saveSharedPref(
                                                      "statusWise", 'no');
                                                  await getLeadProgressbar(
                                                    widget.token,
                                                    fromdate,
                                                    todate,
                                                    '-1',
                                                  );
                                                  if (object1!.status == true &&
                                                      context.mounted) {
                                                    Navigator.pop(context);
                                                    leadProgressbarDialog(
                                                      context,
                                                      "Total Called",
                                                      "",
                                                      "-1",
                                                    );
                                                  }
                                                },
                                                child: Container(
                                                  width: 30,
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors
                                                            .grey.shade500,
                                                        offset: const Offset(
                                                            0, 2.0),
                                                        blurRadius: 2,
                                                      ),
                                                    ],
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    child: Center(
                                                      child: Image.asset(
                                                          "assets/icons/lineSegment.png"),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                // ────────────── Transferred Leads ──────────────
                                InkWell(
                                  onTap: () {
                                    Common.saveSharedPref("statusWise", 'no');
                                    if (viewLeadPermission == 'true') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ViewLeads(
                                            widget.token,
                                            updateLeadPermission1,
                                            deleteLeadPermission1,
                                            cloudCallPermission1,
                                            pageName: 'Transferred Leads',
                                            leadType: "2",
                                            callStatus: "-2",
                                          ),
                                        ),
                                      ).then((r) {
                                        getData(widget.token, fromdate, todate);
                                        if (loadmore == true) getStaffwise();
                                      });
                                    } else {
                                      _dialogue(context, 'View Leads');
                                    }
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.42,
                                    height: MediaQuery.of(context).size.height *
                                        0.15,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 189, 226, 249),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Stack(
                                      children: [
                                        // Header + tooltip
                                        Positioned(
                                          top: 10,
                                          left: 10,
                                          right: 10,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                "Transferred Leads",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 13,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  dynamic toolTip4 =
                                                      _toolTipKey4.currentState;
                                                  toolTip4
                                                      .ensureTooltipVisible();
                                                },
                                                child: Tooltip(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  message:
                                                      'Transferred leads can be filtered \n using a specific date range to \n determine the count of Transferred \n leads within that period',
                                                  key: _toolTipKey4,
                                                  child: Container(
                                                    width: 20,
                                                    height: 20,
                                                    decoration:
                                                        const BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.white,
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        '?',
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        Positioned(
                                          top: 35,
                                          left: 0,
                                          right: 35,
                                          child: GestureDetector(
                                            onTap: () async {
                                              if (!_showTransferredLeadsCount) {
                                                setState(() {
                                                  _isLoadingTransferredLeads =
                                                      true; // start loader
                                                });

                                                var result = await HttpService
                                                    .leadDashboardNew(
                                                  widget.token,
                                                  fromdate,
                                                  todate,
                                                  fromdate1,
                                                  todate1,
                                                  "6", // leadType = 6 for Transferred Leads
                                                );

                                                if (result != null) {
                                                  setState(() {
                                                    transferredLeadsDashboard =
                                                        result;
                                                    _showTransferredLeadsCount =
                                                        true;
                                                    _isLoadingTransferredLeads =
                                                        false; // stop loader
                                                  });
                                                } else {
                                                  setState(() {
                                                    _isLoadingTransferredLeads =
                                                        false; // stop loader on failure
                                                  });
                                                }
                                              } else {
                                                setState(() {
                                                  _showTransferredLeadsCount =
                                                      false;
                                                });
                                              }
                                            },
                                            child: Container(
                                              height: 40,
                                              alignment: Alignment.center,
                                              child: _isLoadingTransferredLeads
                                                  ? SizedBox(
                                                      height: 20,
                                                      width: 20,
                                                      child:
                                                          CircularProgressIndicator(
                                                              strokeWidth: 2),
                                                    )
                                                  : _showTransferredLeadsCount &&
                                                          transferredLeadsDashboard !=
                                                              null
                                                      ? Text(
                                                          transferredLeadsDashboard!
                                                              .data
                                                              .transferLeads
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                            fontSize: 20,
                                                          ),
                                                        )
                                                      : Icon(
                                                          Icons.visibility,
                                                          size: 22,
                                                          color: Colors
                                                              .grey.shade700,
                                                        ),
                                            ),
                                          ),
                                        ),

                                        // View Leads button
                                        Positioned(
                                          bottom: 10,
                                          left: 10,
                                          right: 10,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              const Text(
                                                "View Leads",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () async {
                                                  Common.showProgressDialog(
                                                      context, "Loading..");
                                                  Common.saveSharedPref(
                                                      "statusWise", 'no');
                                                  await getLeadProgressbar(
                                                    widget.token,
                                                    fromdate,
                                                    todate,
                                                    '-2',
                                                  );
                                                  if (object1!.status == true &&
                                                      context.mounted) {
                                                    Navigator.pop(context);
                                                    leadProgressbarDialog(
                                                      context,
                                                      "Transferred Leads",
                                                      "",
                                                      "2",
                                                    );
                                                  }
                                                },
                                                child: Container(
                                                  width: 30,
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors
                                                            .grey.shade500,
                                                        offset: const Offset(
                                                            0, 2.0),
                                                        blurRadius: 2,
                                                      ),
                                                    ],
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    child: Center(
                                                      child: Image.asset(
                                                          "assets/icons/lineSegment.png"),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 15),

                                // ────────────── Missed Leads ──────────────
                                InkWell(
                                  onTap: () {
                                    Common.saveSharedPref("statusWise", 'no');
                                    if (viewLeadPermission == 'true') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ViewLeads(
                                            widget.token,
                                            updateLeadPermission1,
                                            deleteLeadPermission1,
                                            cloudCallPermission1,
                                            pageName: 'Missed Leads',
                                            leadType: "1",
                                            callStatus: "-1",
                                          ),
                                        ),
                                      ).then((r) {
                                        getData(widget.token, fromdate, todate);
                                        if (loadmore == true) getStaffwise();
                                      });
                                    } else {
                                      _dialogue(context, 'View Leads');
                                    }
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.42,
                                    height: MediaQuery.of(context).size.height *
                                        0.15,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 239, 210, 214),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Stack(
                                      children: [
                                        // Header + tooltip
                                        Positioned(
                                          top: 10,
                                          left: 10,
                                          right: 10,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                "Missed Leads",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 13,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  dynamic toolTip5 =
                                                      _toolTipKey5.currentState;
                                                  toolTip5
                                                      .ensureTooltipVisible();
                                                },
                                                child: Tooltip(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  key: _toolTipKey5,
                                                  message:
                                                      'Missed Leads can be filtered \n using a specific date range to \n determine the count of missed \n leads within that period',
                                                  child: Container(
                                                    width: 20,
                                                    height: 20,
                                                    decoration:
                                                        const BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.white,
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        '?',
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        Positioned(
                                          top: 35,
                                          left: 0,
                                          right: 35,
                                          child: GestureDetector(
                                            onTap: () async {
                                              if (!_showMissedLeadsCount) {
                                                setState(() {
                                                  _isLoadingMissedLeads =
                                                      true; // start loader
                                                });

                                                var result = await HttpService
                                                    .leadDashboardNew(
                                                  widget.token,
                                                  fromdate,
                                                  todate,
                                                  fromdate1,
                                                  todate1,
                                                  "5",
                                                );

                                                if (result != null) {
                                                  setState(() {
                                                    missedLeadsDashboard =
                                                        result;
                                                    _showMissedLeadsCount =
                                                        true;
                                                  });
                                                }

                                                setState(() {
                                                  _isLoadingMissedLeads =
                                                      false; // stop loader
                                                });
                                              } else {
                                                setState(() {
                                                  _showMissedLeadsCount = false;
                                                });
                                              }
                                            },
                                            child: Container(
                                              height: 40,
                                              alignment: Alignment.center,
                                              child: _isLoadingMissedLeads
                                                  ? const SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                      ),
                                                    )
                                                  : _showMissedLeadsCount &&
                                                          missedLeadsDashboard !=
                                                              null
                                                      ? Text(
                                                          missedLeadsDashboard!
                                                              .data.missedLeads
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                            fontSize: 20,
                                                          ),
                                                        )
                                                      : Icon(
                                                          Icons.visibility,
                                                          size: 22,
                                                          color: Colors
                                                              .grey.shade700,
                                                        ),
                                            ),
                                          ),
                                        ),

                                        // View Leads button
                                        Positioned(
                                          bottom: 10,
                                          left: 10,
                                          right: 10,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              const Text(
                                                "View Leads",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () async {
                                                  Common.showProgressDialog(
                                                      context, "Loading..");
                                                  Common.saveSharedPref(
                                                      "statusWise", 'no');
                                                  await getLeadProgressbar(
                                                    widget.token,
                                                    fromdate,
                                                    todate,
                                                    '-3',
                                                  );
                                                  if (object1!.status == true &&
                                                      context.mounted) {
                                                    Navigator.pop(context);
                                                    leadProgressbarDialog(
                                                      context,
                                                      "Missed Leads",
                                                      "",
                                                      "1",
                                                    );
                                                  }
                                                },
                                                child: Container(
                                                  width: 30,
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors
                                                            .grey.shade500,
                                                        offset: const Offset(
                                                            0, 2.0),
                                                        blurRadius: 2,
                                                      ),
                                                    ],
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    child: Center(
                                                      child: Image.asset(
                                                          "assets/icons/lineSegment.png"),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        )),
                    Visibility(
                      visible: loadmore == false,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: InkWell(
                          onTap: () async {
                            getStaffwise();
                          },
                          child: Visibility(
                            visible: false,
                            child: Container(
                                height: 32,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 5),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.white, width: 0),
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Colors.grey,
                                          blurRadius: 5,
                                          offset: Offset(1, 1)),
                                    ],
                                    color: Colors.blue,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(5))),
                                child: Text(
                                  moreloading == true
                                      ? " Loading... "
                                      : "Show more",
                                  //  : "Show more",
                                  style: const TextStyle(color: Colors.white),
                                )),
                          ),
                        ),
                      ),
                    ),
                    loadmore == false ? const SizedBox() : const SizedBox()
                    //  Padding(
                    //     padding: const EdgeInsets.only(left: 20, right: 20),
                    //     child: Column(
                    //       children: [
                    //         Container(
                    //           decoration: BoxDecoration(
                    //             color: Colors.grey.shade100,
                    //             borderRadius: BorderRadius.circular(15),
                    //             boxShadow: const [
                    //               BoxShadow(
                    //                 color: Colors.grey,
                    //                 offset: Offset(0, 2.0),
                    //               )
                    //             ],
                    //           ),
                    //           child: Center(
                    //             child: Column(
                    //               mainAxisAlignment:
                    //                   MainAxisAlignment.start,
                    //               crossAxisAlignment:
                    //                   CrossAxisAlignment.start,
                    //               children: <Widget>[
                    //                 const SizedBox(
                    //                   height: 20,
                    //                 ),
                    //                 Padding(
                    //                   padding: const EdgeInsets.only(
                    //                       left: 20, right: 20),
                    //                   child: Row(
                    //                     mainAxisAlignment:
                    //                         MainAxisAlignment.spaceBetween,
                    //                     crossAxisAlignment:
                    //                         CrossAxisAlignment.center,
                    //                     children: [
                    //                       Row(
                    //                         children: [
                    //                           const Text(
                    //                             'Category Wise Report',
                    //                             style: TextStyle(
                    //                                 fontSize: 15,
                    //                                 fontWeight:
                    //                                     FontWeight.bold),
                    //                           ),
                    //                           const SizedBox(
                    //                             width: 15,
                    //                           ),
                    //                           viewLeadCategoryPermission ==
                    //                                   'true'
                    //                               ? InkWell(
                    //                                   onTap: () {
                    //                                     Navigator.push(
                    //                                       context,
                    //                                       MaterialPageRoute(
                    //                                           builder: (context) => ViewLeadCategory(
                    //                                               widget
                    //                                                   .token!,
                    //                                               createLeadCategory1,
                    //                                               updateLeadCategory1,
                    //                                               deleteLeadCategory1)),
                    //                                     );
                    //                                   },
                    //                                   child: Icon(
                    //                                     Icons.settings,
                    //                                     color: Colors
                    //                                         .blue.shade800,
                    //                                     size: 15,
                    //                                   ),
                    //                                 )
                    //                               : const SizedBox()
                    //                         ],
                    //                       ),
                    //                       InkWell(
                    //                         onTap: () {
                    //                           showGeneralDialog(
                    //                             barrierLabel:
                    //                                 "showGeneralDialog",
                    //                             barrierDismissible: true,
                    //                             barrierColor: Colors.black
                    //                                 .withOpacity(0.6),
                    //                             transitionDuration:
                    //                                 const Duration(
                    //                                     milliseconds: 400),
                    //                             context: context,
                    //                             pageBuilder:
                    //                                 (context, _, __) {
                    //                               return Align(
                    //                                 alignment: Alignment
                    //                                     .bottomCenter,
                    //                                 child: IntrinsicHeight(
                    //                                   child: Container(
                    //                                     width: double
                    //                                         .maxFinite,
                    //                                     clipBehavior:
                    //                                         Clip.antiAlias,
                    //                                     padding:
                    //                                         const EdgeInsets
                    //                                             .all(16),
                    //                                     decoration:
                    //                                         const BoxDecoration(
                    //                                       color:
                    //                                           Colors.white,
                    //                                       borderRadius:
                    //                                           BorderRadius
                    //                                               .only(
                    //                                         topLeft: Radius
                    //                                             .circular(
                    //                                                 16),
                    //                                         topRight: Radius
                    //                                             .circular(
                    //                                                 16),
                    //                                       ),
                    //                                     ),
                    //                                     child: Material(
                    //                                       child:
                    //                                           SingleChildScrollView(
                    //                                         child: Column(
                    //                                           children: [
                    //                                             const SizedBox(
                    //                                                 height:
                    //                                                     20),
                    //                                             const Text(
                    //                                               'Filter By Date Range',
                    //                                               style:
                    //                                                   TextStyle(
                    //                                                 fontSize:
                    //                                                     18,
                    //                                                 fontWeight:
                    //                                                     FontWeight.w500,
                    //                                               ),
                    //                                             ),
                    //                                             const SizedBox(
                    //                                                 height:
                    //                                                     20),
                    //                                             Row(
                    //                                               children: [
                    //                                                 SizedBox(
                    //                                                     width: MediaQuery.of(context).size.width *
                    //                                                         0.25,
                    //                                                     child:
                    //                                                         const Text(
                    //                                                       'From Date',
                    //                                                       style: TextStyle(
                    //                                                         fontSize: 15,
                    //                                                         fontWeight: FontWeight.w500,
                    //                                                       ),
                    //                                                     )),
                    //                                                 const SizedBox(
                    //                                                   width:
                    //                                                       10,
                    //                                                 ),
                    //                                                 SizedBox(
                    //                                                   height:
                    //                                                       50,
                    //                                                   width:
                    //                                                       MediaQuery.of(context).size.width * 0.6,
                    //                                                   child:
                    //                                                       Center(
                    //                                                     child:
                    //                                                         DateTimePicker(
                    //                                                       decoration: InputDecoration(
                    //                                                           filled: true,
                    //                                                           //<-- SEE HERE
                    //                                                           fillColor: Colors.white,
                    //                                                           prefixIcon: const Icon(
                    //                                                             Icons.arrow_right,
                    //                                                             color: Colors.grey,
                    //                                                           ),
                    //                                                           counterText: "",
                    //                                                           hintText: 'From Date',
                    //                                                           isDense: true,
                    //                                                           border: OutlineInputBorder(borderSide: BorderSide(color: Colors.purple.shade100), borderRadius: BorderRadius.circular(5))),
                    //                                                       initialValue: fromdate1.toString(),
                    //                                                       type: DateTimePickerType.date,

                    //                                                       //controller: fromDate,
                    //                                                       firstDate: DateTime(1995),
                    //                                                       lastDate: DateTime.now().add(const Duration(days: 365)),
                    //                                                       // This will add one year from current date
                    //                                                       validator: (value) {
                    //                                                         return null;
                    //                                                       },
                    //                                                       onChanged: (value) {
                    //                                                         if (value.isNotEmpty) {
                    //                                                           setState(() {
                    //                                                             fromdate1 = DateTime.parse(value).toString();
                    //                                                           });
                    //                                                         }
                    //                                                       },
                    //                                                       // We can also use onSaved
                    //                                                       onSaved: (value) {
                    //                                                         if (value!.isNotEmpty) {
                    //                                                           fromdate1 = DateTime.parse(value).toString();
                    //                                                         }
                    //                                                       },
                    //                                                     ),
                    //                                                   ),
                    //                                                 ),
                    //                                               ],
                    //                                             ),
                    //                                             const SizedBox(
                    //                                               height:
                    //                                                   10,
                    //                                             ),
                    //                                             Row(
                    //                                               children: [
                    //                                                 SizedBox(
                    //                                                     width: MediaQuery.of(context).size.width *
                    //                                                         0.25,
                    //                                                     child:
                    //                                                         const Text(
                    //                                                       'To Date',
                    //                                                       style: TextStyle(
                    //                                                         fontSize: 15,
                    //                                                         fontWeight: FontWeight.w500,
                    //                                                       ),
                    //                                                     )),
                    //                                                 const SizedBox(
                    //                                                   width:
                    //                                                       10,
                    //                                                 ),
                    //                                                 SizedBox(
                    //                                                   height:
                    //                                                       50,
                    //                                                   width:
                    //                                                       MediaQuery.of(context).size.width * 0.6,
                    //                                                   child:
                    //                                                       Center(
                    //                                                     child:
                    //                                                         DateTimePicker(
                    //                                                       decoration: InputDecoration(
                    //                                                           filled: true,
                    //                                                           //<-- SEE HERE
                    //                                                           fillColor: Colors.white,
                    //                                                           prefixIcon: const Icon(
                    //                                                             Icons.arrow_right,
                    //                                                             color: Colors.grey,
                    //                                                           ),
                    //                                                           counterText: "",
                    //                                                           hintText: 'To date',
                    //                                                           isDense: true,
                    //                                                           border: OutlineInputBorder(borderSide: BorderSide(color: Colors.purple.shade100), borderRadius: BorderRadius.circular(5))),
                    //                                                       initialValue: todate1.toString(),
                    //                                                       type: DateTimePickerType.date,

                    //                                                       //controller: fromDate,
                    //                                                       firstDate: DateTime(1995),
                    //                                                       lastDate: DateTime.now().add(const Duration(days: 365)),
                    //                                                       // This will add one year from current date
                    //                                                       validator: (value) {
                    //                                                         return null;
                    //                                                       },
                    //                                                       onChanged: (value) {
                    //                                                         if (value.isNotEmpty) {
                    //                                                           setState(() {
                    //                                                             todate1 = DateTime.parse(value);
                    //                                                           });
                    //                                                         }
                    //                                                       },
                    //                                                       // We can also use onSaved
                    //                                                       onSaved: (value) {
                    //                                                         if (value!.isNotEmpty) {
                    //                                                           todate1 = DateTime.parse(value);
                    //                                                         }
                    //                                                       },
                    //                                                     ),
                    //                                                   ),
                    //                                                 ),
                    //                                               ],
                    //                                             ),
                    //                                             const SizedBox(
                    //                                                 height:
                    //                                                     16),
                    //                                             Container(
                    //                                               height:
                    //                                                   40,
                    //                                               width: double
                    //                                                   .maxFinite,
                    //                                               decoration:
                    //                                                   const BoxDecoration(
                    //                                                 color: Color(
                    //                                                     0xFF3375e0),
                    //                                                 borderRadius:
                    //                                                     BorderRadius.all(Radius.circular(8)),
                    //                                               ),
                    //                                               child:
                    //                                                   RawMaterialButton(
                    //                                                 onPressed:
                    //                                                     () {
                    //                                                   setState(
                    //                                                       () {
                    //                                                     data.remove(data);
                    //                                                   });
                    //                                                   getStaffwise();
                    //                                                   getData(
                    //                                                       widget.token,
                    //                                                       fromdate,
                    //                                                       todate);
                    //                                                   Navigator.of(context, rootNavigator: true)
                    //                                                       .pop();
                    //                                                 },
                    //                                                 child:
                    //                                                     const Center(
                    //                                                   child:
                    //                                                       Text(
                    //                                                     'Continue',
                    //                                                     style:
                    //                                                         TextStyle(
                    //                                                       color: Colors.white,
                    //                                                       fontWeight: FontWeight.w500,
                    //                                                     ),
                    //                                                   ),
                    //                                                 ),
                    //                                               ),
                    //                                             ),
                    //                                           ],
                    //                                         ),
                    //                                       ),
                    //                                     ),
                    //                                   ),
                    //                                 ),
                    //                               );
                    //                             },
                    //                             transitionBuilder: (_,
                    //                                 animation1, __, child) {
                    //                               return SlideTransition(
                    //                                 position: Tween(
                    //                                   begin: const Offset(
                    //                                       0, 1),
                    //                                   end: const Offset(
                    //                                       0, 0),
                    //                                 ).animate(animation1),
                    //                                 child: child,
                    //                               );
                    //                             },
                    //                           );
                    //                         },
                    //                         child: Container(
                    //                           width: 30,
                    //                           height: 30,
                    //                           decoration: BoxDecoration(
                    //                               color:
                    //                                   Colors.grey.shade100,
                    //                               borderRadius:
                    //                                   BorderRadius.circular(
                    //                                       5)),
                    //                           child: Center(
                    //                             child: Center(
                    //                                 child: Image.asset(
                    //                                     "assets/icons/calendar.png",
                    //                                     width: 25)),
                    //                           ),
                    //                         ),
                    //                       )
                    //                     ],
                    //                   ),
                    //                 ),
                    //                 Padding(
                    //                   padding:
                    //                       const EdgeInsets.only(left: 20),
                    //                   child: Text(
                    //                       'From ${DateFormat("dd-MM-yyyy").format(DateTime.parse(fromdate1))} To ${DateFormat("dd-MM-yyyy").format(todate1)}'),
                    //                 ),
                    //                 const SizedBox(
                    //                   height: 10,
                    //                 ),
                    //                 Divider(
                    //                   color: Colors.grey.shade300,
                    //                   thickness: 1.0,
                    //                 ),
                    //                 const SizedBox(
                    //                   height: 10,
                    //                 ),
                    //                 if (leadDashboard != null)
                    //                   data.isNotEmpty
                    //                       ? Padding(
                    //                           padding:
                    //                               const EdgeInsets.only(
                    //                                   left: 10),
                    //                           child: PieChart(
                    //                             dataMap: data,
                    //                             animationDuration:
                    //                                 const Duration(
                    //                                     milliseconds: 800),
                    //                             chartLegendSpacing: 20,
                    //                             chartRadius:
                    //                                 MediaQuery.of(context)
                    //                                         .size
                    //                                         .width /
                    //                                     2.5,
                    //                             colorList: _colors,
                    //                             initialAngleInDegree: 0,
                    //                             chartType: ChartType.ring,
                    //                             ringStrokeWidth: 25,
                    //                             centerText: leadDashboard!
                    //                                 .data
                    //                                 .currentLeadsCount
                    //                                 .total,
                    //                             centerTextStyle:
                    //                                 const TextStyle(
                    //                                     fontSize: 20,
                    //                                     color:
                    //                                         Colors.black),
                    //                             legendOptions:
                    //                                 const LegendOptions(
                    //                               legendShape:
                    //                                   BoxShape.rectangle,
                    //                               showLegendsInRow: false,
                    //                               legendPosition:
                    //                                   LegendPosition.right,
                    //                               showLegends: true,
                    //                               legendTextStyle:
                    //                                   TextStyle(
                    //                                 fontWeight:
                    //                                     FontWeight.w500,
                    //                               ),
                    //                             ),
                    //                             chartValuesOptions:
                    //                                 const ChartValuesOptions(
                    //                               showChartValueBackground:
                    //                                   false,
                    //                               showChartValues: false,
                    //                               showChartValuesInPercentage:
                    //                                   false,
                    //                               showChartValuesOutside:
                    //                                   true,
                    //                               decimalPlaces: 1,
                    //                             ),
                    //                             // gradientList: ---To add gradient colors---
                    //                             // emptyColorGradient: ---Empty Color gradient---
                    //                           ),
                    //                         )
                    //                       : Column(
                    //                           children: [
                    //                             Row(
                    //                               mainAxisAlignment:
                    //                                   MainAxisAlignment
                    //                                       .center,
                    //                               crossAxisAlignment:
                    //                                   CrossAxisAlignment
                    //                                       .center,
                    //                               children: [
                    //                                 Image.asset(
                    //                                   'assets/icons/nodatafound.png',
                    //                                   width: 100,
                    //                                   height: 100,
                    //                                 ),
                    //                               ],
                    //                             ),
                    //                             const Text(
                    //                               'Result Not Found',
                    //                               style: TextStyle(
                    //                                   fontSize: 15,
                    //                                   fontWeight:
                    //                                       FontWeight.bold),
                    //                             ),
                    //                             const SizedBox(
                    //                               height: 10,
                    //                             ),
                    //                             const Text(
                    //                               'Whoops... this information is \n not available for a moment',
                    //                               style: TextStyle(
                    //                                   fontSize: 13),
                    //                             ),
                    //                             const SizedBox(
                    //                               height: 15,
                    //                             ),
                    //                           ],
                    //                         ),
                    //                 const SizedBox(
                    //                   height: 10,
                    //                 ),
                    //                 const Divider(),
                    //                 data.isNotEmpty
                    //                     ? Column(
                    //                         children: [
                    //                           Table(columnWidths: const {
                    //                             0: FlexColumnWidth(10),
                    //                             1: FlexColumnWidth(5),
                    //                             2: FlexColumnWidth(5),
                    //                             3: FlexColumnWidth(5),
                    //                             4: FlexColumnWidth(5),
                    //                             5: FlexColumnWidth(5),
                    //                           }, children: [
                    //                             const TableRow(
                    //                                 // decoration: new BoxDecoration(
                    //                                 //     color: Colors.greenAccent),
                    //                                 children: [
                    //                                   Padding(
                    //                                     padding:
                    //                                         EdgeInsets.only(
                    //                                             top: 10,
                    //                                             bottom: 10),
                    //                                     child: Center(
                    //                                         child: Text(
                    //                                       "",
                    //                                       style: TextStyle(
                    //                                           fontSize: 17,
                    //                                           fontWeight:
                    //                                               FontWeight
                    //                                                   .bold),
                    //                                     )),
                    //                                   ),
                    //                                   Padding(
                    //                                     padding:
                    //                                         EdgeInsets.only(
                    //                                             top: 10,
                    //                                             bottom: 10),
                    //                                     child: Center(
                    //                                         child: Text(
                    //                                       'New',
                    //                                       style: TextStyle(
                    //                                           fontSize: 10,
                    //                                           fontWeight:
                    //                                               FontWeight
                    //                                                   .bold),
                    //                                     )),
                    //                                   ),
                    //                                   Padding(
                    //                                     padding:
                    //                                         EdgeInsets.only(
                    //                                             top: 10,
                    //                                             bottom: 10),
                    //                                     child: Center(
                    //                                         child: Text(
                    //                                       'Pending',
                    //                                       style: TextStyle(
                    //                                           fontSize: 10,
                    //                                           fontWeight:
                    //                                               FontWeight
                    //                                                   .bold),
                    //                                     )),
                    //                                   ),
                    //                                   Padding(
                    //                                     padding:
                    //                                         EdgeInsets.only(
                    //                                             top: 10,
                    //                                             bottom: 10),
                    //                                     child: Center(
                    //                                         child: Text(
                    //                                       'Followup',
                    //                                       style: TextStyle(
                    //                                           fontSize: 10,
                    //                                           color: Colors
                    //                                               .black,
                    //                                           fontWeight:
                    //                                               FontWeight
                    //                                                   .bold),
                    //                                     )),
                    //                                   ),
                    //                                   Padding(
                    //                                     padding:
                    //                                         EdgeInsets.only(
                    //                                             top: 10,
                    //                                             bottom: 10),
                    //                                     child: Center(
                    //                                         child: Text(
                    //                                       'Rejected',
                    //                                       style: TextStyle(
                    //                                           fontSize: 10,
                    //                                           color: Colors
                    //                                               .red,
                    //                                           fontWeight:
                    //                                               FontWeight
                    //                                                   .bold),
                    //                                     )),
                    //                                   ),
                    //                                   Padding(
                    //                                     padding:
                    //                                         EdgeInsets.only(
                    //                                             top: 10,
                    //                                             bottom: 10),
                    //                                     child: Center(
                    //                                         child: Text(
                    //                                       'Closed',
                    //                                       style: TextStyle(
                    //                                           fontSize: 10,
                    //                                           fontWeight:
                    //                                               FontWeight
                    //                                                   .bold),
                    //                                     )),
                    //                                   ),
                    //                                 ]),
                    //                             for (int i = 0;
                    //                                 i <
                    //                                     staffWise!
                    //                                         .data!
                    //                                         .categoryLeads!
                    //                                         .length;
                    //                                 i++)
                    //                               TableRow(children: [
                    //                                 Padding(
                    //                                   padding:
                    //                                       const EdgeInsets
                    //                                           .only(
                    //                                           top: 0,
                    //                                           bottom: 10,
                    //                                           left: 10),
                    //                                   child: Text(
                    //                                     staffWise!
                    //                                         .data!
                    //                                         .categoryLeads![
                    //                                             i]
                    //                                         .categoryName
                    //                                         .toString(),
                    //                                     style: TextStyle(
                    //                                         fontSize: 10,
                    //                                         fontWeight:
                    //                                             FontWeight
                    //                                                 .bold,
                    //                                         color:
                    //                                             _colors[i]),
                    //                                   ),
                    //                                 ),
                    //                                 InkWell(
                    //                                   onTap: () {
                    //                                     Common
                    //                                         .saveSharedPref(
                    //                                             "statusWise",
                    //                                             'yes');
                    //                                     Common.saveSharedPref(
                    //                                         "statusWisId",
                    //                                         '1');
                    //                                     Common
                    //                                         .saveSharedPref(
                    //                                             "type",
                    //                                             'category');
                    //                                     Common.saveSharedPref(
                    //                                         "statusCatId",
                    //                                         staffWise!
                    //                                             .data!
                    //                                             .categoryLeads![
                    //                                                 i]
                    //                                             .categoryid
                    //                                             .toString());
                    //                                     viewLeadPermission ==
                    //                                             'true'
                    //                                         ? Navigator
                    //                                             .push(
                    //                                             context,
                    //                                             MaterialPageRoute(
                    //                                                 builder: (context) =>
                    //                                                     ViewLeads(
                    //                                                       widget.token,
                    //                                                       updateLeadPermission1,
                    //                                                       deleteLeadPermission1,
                    //                                                       cloudCallPermission1,
                    //                                                       pageName: 'New Leads',
                    //                                                       fromDate: fromdate1.toString(),
                    //                                                       toDate: todate1.toString(),
                    //                                                     )),
                    //                                           ).then((r) {
                    //                                             getData(
                    //                                                 widget
                    //                                                     .token,
                    //                                                 fromdate,
                    //                                                 todate);
                    //                                             if (loadmore ==
                    //                                                 true) {
                    //                                               getStaffwise();
                    //                                             }
                    //                                           })
                    //                                         : _dialogue(
                    //                                             context,
                    //                                             'View Leads');
                    //                                   },
                    //                                   child: Padding(
                    //                                     padding:
                    //                                         const EdgeInsets
                    //                                             .only(
                    //                                             top: 0,
                    //                                             bottom: 10),
                    //                                     child: Center(
                    //                                         child: Text(
                    //                                       textAlign:
                    //                                           TextAlign.end,
                    //                                       staffWise!
                    //                                           .data!
                    //                                           .categoryLeads![
                    //                                               i]
                    //                                           .newCount
                    //                                           .toString(),
                    //                                       style: const TextStyle(
                    //                                           fontSize: 10,
                    //                                           fontWeight:
                    //                                               FontWeight
                    //                                                   .bold),
                    //                                     )),
                    //                                   ),
                    //                                 ),
                    //                                 InkWell(
                    //                                   onTap: () {
                    //                                     Common
                    //                                         .saveSharedPref(
                    //                                             "statusWise",
                    //                                             'yes');
                    //                                     Common.saveSharedPref(
                    //                                         "statusWisId",
                    //                                         '2');
                    //                                     Common
                    //                                         .saveSharedPref(
                    //                                             "type",
                    //                                             'category');
                    //                                     Common.saveSharedPref(
                    //                                         "statusCatId",
                    //                                         staffWise!
                    //                                             .data!
                    //                                             .categoryLeads![
                    //                                                 i]
                    //                                             .categoryid
                    //                                             .toString());
                    //                                     viewLeadPermission ==
                    //                                             'true'
                    //                                         ? Navigator
                    //                                             .push(
                    //                                             context,
                    //                                             MaterialPageRoute(
                    //                                                 builder: (context) =>
                    //                                                     ViewLeads(
                    //                                                       widget.token,
                    //                                                       updateLeadPermission1,
                    //                                                       deleteLeadPermission1,
                    //                                                       cloudCallPermission1,
                    //                                                       pageName: 'Pending Leads',
                    //                                                       fromDate: fromdate1.toString(),
                    //                                                       toDate: todate1.toString(),
                    //                                                     )),
                    //                                           ).then((r) {
                    //                                             getData(
                    //                                                 widget
                    //                                                     .token,
                    //                                                 fromdate,
                    //                                                 todate);
                    //                                             if (loadmore ==
                    //                                                 true) {
                    //                                               getStaffwise();
                    //                                             }
                    //                                           })
                    //                                         : _dialogue(
                    //                                             context,
                    //                                             'View Leads');
                    //                                   },
                    //                                   child: Padding(
                    //                                     padding:
                    //                                         const EdgeInsets
                    //                                             .only(
                    //                                             top: 0,
                    //                                             bottom: 10),
                    //                                     child: Center(
                    //                                         child: Text(
                    //                                       textAlign:
                    //                                           TextAlign.end,
                    //                                       staffWise!
                    //                                           .data!
                    //                                           .categoryLeads![
                    //                                               i]
                    //                                           .pendingCount
                    //                                           .toString(),
                    //                                       style: const TextStyle(
                    //                                           fontSize: 10,
                    //                                           fontWeight:
                    //                                               FontWeight
                    //                                                   .bold),
                    //                                     )),
                    //                                   ),
                    //                                 ),
                    //                                 InkWell(
                    //                                   onTap: () {
                    //                                     Common
                    //                                         .saveSharedPref(
                    //                                             "statusWise",
                    //                                             'yes');
                    //                                     Common.saveSharedPref(
                    //                                         "statusWisId",
                    //                                         '3');
                    //                                     Common
                    //                                         .saveSharedPref(
                    //                                             "type",
                    //                                             'category');
                    //                                     Common.saveSharedPref(
                    //                                         "statusCatId",
                    //                                         staffWise!
                    //                                             .data!
                    //                                             .categoryLeads![
                    //                                                 i]
                    //                                             .categoryid
                    //                                             .toString());
                    //                                     viewLeadPermission ==
                    //                                             'true'
                    //                                         ? Navigator
                    //                                             .push(
                    //                                             context,
                    //                                             MaterialPageRoute(
                    //                                                 builder: (context) =>
                    //                                                     ViewLeads(
                    //                                                       widget.token,
                    //                                                       updateLeadPermission1,
                    //                                                       deleteLeadPermission1,
                    //                                                       cloudCallPermission1,
                    //                                                       pageName: 'Followup Leads',
                    //                                                       fromDate: fromdate1.toString(),
                    //                                                       toDate: todate1.toString(),
                    //                                                     )),
                    //                                           ).then((r) {
                    //                                             getData(
                    //                                                 widget
                    //                                                     .token,
                    //                                                 fromdate,
                    //                                                 todate);
                    //                                             if (loadmore ==
                    //                                                 true) {
                    //                                               getStaffwise();
                    //                                             }
                    //                                           })
                    //                                         : _dialogue(
                    //                                             context,
                    //                                             'View Leads');
                    //                                   },
                    //                                   child: Padding(
                    //                                     padding:
                    //                                         const EdgeInsets
                    //                                             .only(
                    //                                             top: 0,
                    //                                             bottom: 10),
                    //                                     child: Center(
                    //                                         child: Text(
                    //                                       textAlign:
                    //                                           TextAlign.end,
                    //                                       staffWise!
                    //                                           .data!
                    //                                           .categoryLeads![
                    //                                               i]
                    //                                           .followupCount
                    //                                           .toString(),
                    //                                       style: const TextStyle(
                    //                                           fontSize: 10,
                    //                                           fontWeight:
                    //                                               FontWeight
                    //                                                   .bold),
                    //                                     )),
                    //                                   ),
                    //                                 ),
                    //                                 InkWell(
                    //                                   onTap: () {
                    //                                     Common
                    //                                         .saveSharedPref(
                    //                                             "statusWise",
                    //                                             'yes');
                    //                                     Common.saveSharedPref(
                    //                                         "statusWisId",
                    //                                         '4');
                    //                                     Common
                    //                                         .saveSharedPref(
                    //                                             "type",
                    //                                             'category');
                    //                                     Common.saveSharedPref(
                    //                                         "statusCatId",
                    //                                         staffWise!
                    //                                             .data!
                    //                                             .categoryLeads![
                    //                                                 i]
                    //                                             .categoryid
                    //                                             .toString());
                    //                                     viewLeadPermission ==
                    //                                             'true'
                    //                                         ? Navigator
                    //                                             .push(
                    //                                             context,
                    //                                             MaterialPageRoute(
                    //                                                 builder: (context) =>
                    //                                                     ViewLeads(
                    //                                                       widget.token,
                    //                                                       updateLeadPermission1,
                    //                                                       updateLeadPermission1,
                    //                                                       cloudCallPermission1,
                    //                                                       pageName: 'Rejected Leads',
                    //                                                       fromDate: fromdate1.toString(),
                    //                                                       toDate: todate1.toString(),
                    //                                                     )),
                    //                                           ).then((r) {
                    //                                             getData(
                    //                                                 widget
                    //                                                     .token,
                    //                                                 fromdate,
                    //                                                 todate);
                    //                                             if (loadmore ==
                    //                                                 true) {
                    //                                               getStaffwise();
                    //                                             }
                    //                                           })
                    //                                         : _dialogue(
                    //                                             context,
                    //                                             'View Leads');
                    //                                   },
                    //                                   child: Padding(
                    //                                     padding:
                    //                                         const EdgeInsets
                    //                                             .only(
                    //                                             top: 0,
                    //                                             bottom: 10),
                    //                                     child: Center(
                    //                                         child: Text(
                    //                                       textAlign:
                    //                                           TextAlign.end,
                    //                                       staffWise!
                    //                                           .data!
                    //                                           .categoryLeads![
                    //                                               i]
                    //                                           .rejectedCount
                    //                                           .toString(),
                    //                                       style: const TextStyle(
                    //                                           fontSize: 10,
                    //                                           color: Colors
                    //                                               .red,
                    //                                           fontWeight:
                    //                                               FontWeight
                    //                                                   .bold),
                    //                                     )),
                    //                                   ),
                    //                                 ),
                    //                                 InkWell(
                    //                                   onTap: () {
                    //                                     Common
                    //                                         .saveSharedPref(
                    //                                             "statusWise",
                    //                                             'yes');
                    //                                     Common
                    //                                         .saveSharedPref(
                    //                                             "type",
                    //                                             'category');
                    //                                     Common.saveSharedPref(
                    //                                         "statusWisId",
                    //                                         '5');
                    //                                     Common.saveSharedPref(
                    //                                         "statusCatId",
                    //                                         staffWise!
                    //                                             .data!
                    //                                             .categoryLeads![
                    //                                                 i]
                    //                                             .categoryid
                    //                                             .toString());
                    //                                     viewLeadPermission ==
                    //                                             'true'
                    //                                         ? Navigator
                    //                                             .push(
                    //                                             context,
                    //                                             MaterialPageRoute(
                    //                                                 builder: (context) =>
                    //                                                     ViewLeads(
                    //                                                       widget.token,
                    //                                                       updateLeadPermission1,
                    //                                                       deleteLeadPermission1,
                    //                                                       cloudCallPermission1,
                    //                                                       pageName: 'Closed Leads',
                    //                                                       fromDate: fromdate1.toString(),
                    //                                                       toDate: todate1.toString(),
                    //                                                     )),
                    //                                           ).then((r) {
                    //                                             getData(
                    //                                                 widget
                    //                                                     .token,
                    //                                                 fromdate,
                    //                                                 todate);
                    //                                             if (loadmore ==
                    //                                                 true) {
                    //                                               getStaffwise();
                    //                                             }
                    //                                           })
                    //                                         : _dialogue(
                    //                                             context,
                    //                                             'View Leads');
                    //                                   },
                    //                                   child: Padding(
                    //                                     padding:
                    //                                         const EdgeInsets
                    //                                             .only(
                    //                                             top: 0,
                    //                                             bottom: 10),
                    //                                     child: Center(
                    //                                         child: Text(
                    //                                       textAlign:
                    //                                           TextAlign.end,
                    //                                       staffWise!
                    //                                           .data!
                    //                                           .categoryLeads![
                    //                                               i]
                    //                                           .confirmedCount
                    //                                           .toString(),
                    //                                       style: const TextStyle(
                    //                                           fontSize: 10,
                    //                                           fontWeight:
                    //                                               FontWeight
                    //                                                   .bold),
                    //                                     )),
                    //                                   ),
                    //                                 ),
                    //                               ]),
                    //                           ]),
                    //                           const Divider(
                    //                             endIndent: 8,
                    //                             indent: 8,
                    //                           ),
                    //                           Padding(
                    //                             padding:
                    //                                 const EdgeInsets.only(
                    //                                     top: 8.0,
                    //                                     bottom: 12.0),
                    //                             child: Table(
                    //                               columnWidths: const {
                    //                                 0: FlexColumnWidth(10),
                    //                                 1: FlexColumnWidth(5),
                    //                                 2: FlexColumnWidth(5),
                    //                                 3: FlexColumnWidth(5),
                    //                                 4: FlexColumnWidth(5),
                    //                                 5: FlexColumnWidth(5),
                    //                               },
                    //                               children: [
                    //                                 TableRow(
                    //                                     // decoration: new BoxDecoration(
                    //                                     //     color: Colors.greenAccent),
                    //                                     children: [
                    //                                       const Center(
                    //                                           child: Text(
                    //                                         "Total Leads",
                    //                                         style: TextStyle(
                    //                                             fontSize:
                    //                                                 11,
                    //                                             fontWeight:
                    //                                                 FontWeight
                    //                                                     .bold),
                    //                                       )),
                    //                                       InkWell(
                    //                                         onTap: () {
                    //                                           Common.saveSharedPref(
                    //                                               "statusWise",
                    //                                               'yes');
                    //                                           Common.saveSharedPref(
                    //                                               "statusWisId",
                    //                                               '1');
                    //                                           Common.saveSharedPref(
                    //                                               "type",
                    //                                               'category');
                    //                                           Common.saveSharedPref(
                    //                                               "statusCatId",
                    //                                               "-1");
                    //                                           viewLeadPermission ==
                    //                                                   'true'
                    //                                               ? Navigator
                    //                                                   .push(
                    //                                                   context,
                    //                                                   MaterialPageRoute(
                    //                                                       builder: (context) => ViewLeads(
                    //                                                             widget.token,
                    //                                                             updateLeadPermission1,
                    //                                                             deleteLeadPermission1,
                    //                                                             cloudCallPermission1,
                    //                                                             pageName: 'New Leads',
                    //                                                             // fromDate: fromdate1.toString(),
                    //                                                             // toDate: todate1.toString(),
                    //                                                           )),
                    //                                                 ).then(
                    //                                                   (r) {
                    //                                                   getData(
                    //                                                       widget.token,
                    //                                                       fromdate,
                    //                                                       todate);
                    //                                                   if (loadmore ==
                    //                                                       true) {
                    //                                                     getStaffwise();
                    //                                                   }
                    //                                                 })
                    //                                               : _dialogue(
                    //                                                   context,
                    //                                                   'View Leads');
                    //                                         },
                    //                                         child: Center(
                    //                                             child: Text(
                    //                                           catNew
                    //                                               .toString(),
                    //                                           style: const TextStyle(
                    //                                               fontSize:
                    //                                                   10,
                    //                                               fontWeight:
                    //                                                   FontWeight
                    //                                                       .bold),
                    //                                         )),
                    //                                       ),
                    //                                       InkWell(
                    //                                         onTap: () {
                    //                                           Common.saveSharedPref(
                    //                                               "statusWise",
                    //                                               'yes');
                    //                                           Common.saveSharedPref(
                    //                                               "statusWisId",
                    //                                               '2');
                    //                                           Common.saveSharedPref(
                    //                                               "type",
                    //                                               'category');
                    //                                           Common.saveSharedPref(
                    //                                               "statusCatId",
                    //                                               "-1");
                    //                                           viewLeadPermission ==
                    //                                                   'true'
                    //                                               ? Navigator
                    //                                                   .push(
                    //                                                   context,
                    //                                                   MaterialPageRoute(
                    //                                                       builder: (context) => ViewLeads(
                    //                                                             widget.token,
                    //                                                             updateLeadPermission1,
                    //                                                             deleteLeadPermission1,
                    //                                                             cloudCallPermission1,
                    //                                                             pageName: 'Pending Leads',
                    //                                                             fromDate: fromdate1.toString(),
                    //                                                             toDate: todate1.toString(),
                    //                                                           )),
                    //                                                 ).then(
                    //                                                   (r) {
                    //                                                   getData(
                    //                                                       widget.token,
                    //                                                       fromdate,
                    //                                                       todate);
                    //                                                   if (loadmore ==
                    //                                                       true) {
                    //                                                     getStaffwise();
                    //                                                   }
                    //                                                 })
                    //                                               : _dialogue(
                    //                                                   context,
                    //                                                   'View Leads');
                    //                                         },
                    //                                         child: Center(
                    //                                             child: Text(
                    //                                           catPending
                    //                                               .toString(),
                    //                                           style: const TextStyle(
                    //                                               fontSize:
                    //                                                   10,
                    //                                               fontWeight:
                    //                                                   FontWeight
                    //                                                       .bold),
                    //                                         )),
                    //                                       ),
                    //                                       InkWell(
                    //                                         onTap: () {
                    //                                           Common.saveSharedPref(
                    //                                               "statusWise",
                    //                                               'yes');
                    //                                           Common.saveSharedPref(
                    //                                               "statusWisId",
                    //                                               '3');
                    //                                           Common.saveSharedPref(
                    //                                               "type",
                    //                                               'category');
                    //                                           Common.saveSharedPref(
                    //                                               "statusCatId",
                    //                                               "-1");
                    //                                           viewLeadPermission ==
                    //                                                   'true'
                    //                                               ? Navigator
                    //                                                   .push(
                    //                                                   context,
                    //                                                   MaterialPageRoute(
                    //                                                       builder: (context) => ViewLeads(
                    //                                                             widget.token,
                    //                                                             updateLeadPermission1,
                    //                                                             deleteLeadPermission1,
                    //                                                             cloudCallPermission1,
                    //                                                             pageName: 'Followup Leads',
                    //                                                             fromDate: fromdate1.toString(),
                    //                                                             toDate: todate1.toString(),
                    //                                                           )),
                    //                                                 ).then(
                    //                                                   (r) {
                    //                                                   getData(
                    //                                                       widget.token,
                    //                                                       fromdate,
                    //                                                       todate);
                    //                                                   if (loadmore ==
                    //                                                       true) {
                    //                                                     getStaffwise();
                    //                                                   }
                    //                                                 })
                    //                                               : _dialogue(
                    //                                                   context,
                    //                                                   'View Leads');
                    //                                         },
                    //                                         child: Center(
                    //                                             child: Text(
                    //                                           catFollowup
                    //                                               .toString(),
                    //                                           style: const TextStyle(
                    //                                               fontSize:
                    //                                                   10,
                    //                                               color: Colors
                    //                                                   .black,
                    //                                               fontWeight:
                    //                                                   FontWeight
                    //                                                       .bold),
                    //                                         )),
                    //                                       ),
                    //                                       InkWell(
                    //                                         onTap: () {
                    //                                           Common.saveSharedPref(
                    //                                               "statusWise",
                    //                                               'yes');
                    //                                           Common.saveSharedPref(
                    //                                               "statusWisId",
                    //                                               '4');
                    //                                           Common.saveSharedPref(
                    //                                               "type",
                    //                                               'category');
                    //                                           Common.saveSharedPref(
                    //                                               "statusCatId",
                    //                                               "-1");
                    //                                           viewLeadPermission ==
                    //                                                   'true'
                    //                                               ? Navigator
                    //                                                   .push(
                    //                                                   context,
                    //                                                   MaterialPageRoute(
                    //                                                       builder: (context) => ViewLeads(
                    //                                                             widget.token,
                    //                                                             updateLeadPermission1,
                    //                                                             updateLeadPermission1,
                    //                                                             cloudCallPermission1,
                    //                                                             pageName: 'Rejected Leads',
                    //                                                             fromDate: fromdate1.toString(),
                    //                                                             toDate: todate1.toString(),
                    //                                                           )),
                    //                                                 ).then(
                    //                                                   (r) {
                    //                                                   getData(
                    //                                                       widget.token,
                    //                                                       fromdate,
                    //                                                       todate);
                    //                                                   if (loadmore ==
                    //                                                       true) {
                    //                                                     getStaffwise();
                    //                                                   }
                    //                                                 })
                    //                                               : _dialogue(
                    //                                                   context,
                    //                                                   'View Leads');
                    //                                         },
                    //                                         child: Center(
                    //                                             child: Text(
                    //                                           catRejected
                    //                                               .toString(),
                    //                                           style: const TextStyle(
                    //                                               fontSize:
                    //                                                   10,
                    //                                               color: Colors
                    //                                                   .red,
                    //                                               fontWeight:
                    //                                                   FontWeight
                    //                                                       .bold),
                    //                                         )),
                    //                                       ),
                    //                                       InkWell(
                    //                                         onTap: () {
                    //                                           Common.saveSharedPref(
                    //                                               "statusWise",
                    //                                               'yes');
                    //                                           Common.saveSharedPref(
                    //                                               "type",
                    //                                               'category');
                    //                                           Common.saveSharedPref(
                    //                                               "statusCatId",
                    //                                               "-1");
                    //                                           Common.saveSharedPref(
                    //                                               "statusWisId",
                    //                                               '5');
                    //                                           viewLeadPermission ==
                    //                                                   'true'
                    //                                               ? Navigator
                    //                                                   .push(
                    //                                                   context,
                    //                                                   MaterialPageRoute(
                    //                                                       builder: (context) => ViewLeads(
                    //                                                             widget.token,
                    //                                                             updateLeadPermission1,
                    //                                                             deleteLeadPermission1,
                    //                                                             cloudCallPermission1,
                    //                                                             pageName: 'Closed Leads',
                    //                                                             fromDate: fromdate1.toString(),
                    //                                                             toDate: todate1.toString(),
                    //                                                           )),
                    //                                                 ).then(
                    //                                                   (r) {
                    //                                                   getData(
                    //                                                       widget.token,
                    //                                                       fromdate,
                    //                                                       todate);
                    //                                                   if (loadmore ==
                    //                                                       true) {
                    //                                                     getStaffwise();
                    //                                                   }
                    //                                                 })
                    //                                               : _dialogue(
                    //                                                   context,
                    //                                                   'View Leads');
                    //                                         },
                    //                                         child: Center(
                    //                                             child: Text(
                    //                                           catClosed
                    //                                               .toString(),
                    //                                           style: const TextStyle(
                    //                                               fontSize:
                    //                                                   10,
                    //                                               fontWeight:
                    //                                                   FontWeight
                    //                                                       .bold),
                    //                                         )),
                    //                                       ),
                    //                                     ]),
                    //                               ],
                    //                             ),
                    //                           )
                    //                         ],
                    //                       )
                    //                     : const SizedBox(),
                    //               ],
                    //             ),
                    //           ),
                    //         ),
                    //         const SizedBox(
                    //           height: 20,
                    //         ),
                    //         Container(
                    //             decoration: BoxDecoration(
                    //               color: Colors.grey.shade100,
                    //               borderRadius: BorderRadius.circular(10),
                    //               boxShadow: const [
                    //                 BoxShadow(
                    //                   color: Colors.grey,
                    //                   offset: Offset(0, 2.0),
                    //                 )
                    //               ],
                    //             ),
                    //             child: Column(
                    //               mainAxisAlignment:
                    //                   MainAxisAlignment.start,
                    //               crossAxisAlignment:
                    //                   CrossAxisAlignment.start,
                    //               children: <Widget>[
                    //                 const SizedBox(
                    //                   height: 20,
                    //                 ),
                    //                 const Padding(
                    //                   padding: EdgeInsets.only(left: 20),
                    //                   child: Row(
                    //                     children: [
                    //                       Text(
                    //                         'Staff Wise Report',
                    //                         style: TextStyle(
                    //                             fontSize: 15,
                    //                             fontWeight:
                    //                                 FontWeight.bold),
                    //                       ),
                    //                     ],
                    //                   ),
                    //                 ),
                    //                 const SizedBox(
                    //                   height: 10,
                    //                 ),
                    //                 Padding(
                    //                   padding:
                    //                       const EdgeInsets.only(left: 20),
                    //                   child: Text(
                    //                       'From ${DateFormat("dd-MM-yyyy").format(DateTime.parse(fromdate1))} To ${DateFormat("dd-MM-yyyy").format(todate1)}'),
                    //                 ),
                    //                 Divider(
                    //                   color: Colors.grey.shade300,
                    //                   thickness: 1.0,
                    //                 ),
                    //                 const SizedBox(
                    //                   height: 10,
                    //                 ),
                    //                 Padding(
                    //                   padding:
                    //                       const EdgeInsets.only(left: 20),
                    //                   child: Column(
                    //                     crossAxisAlignment:
                    //                         CrossAxisAlignment.start,
                    //                     children: [
                    //                       const Text(
                    //                         ' Total Leads ',
                    //                         textAlign: TextAlign.center,
                    //                         style: TextStyle(
                    //                             fontWeight: FontWeight.bold,
                    //                             color: Colors.black,
                    //                             fontSize: 16),
                    //                       ),
                    //                       Row(
                    //                         mainAxisAlignment:
                    //                             MainAxisAlignment
                    //                                 .spaceBetween,
                    //                         children: [
                    //                           Container(
                    //                             width:
                    //                                 MediaQuery.of(context)
                    //                                         .size
                    //                                         .width *
                    //                                     .25,
                    //                             decoration: BoxDecoration(
                    //                                 borderRadius:
                    //                                     BorderRadius
                    //                                         .circular(8),
                    //                                 color: Colors.lightBlue
                    //                                     .shade100),
                    //                             child: Padding(
                    //                               padding:
                    //                                   const EdgeInsets.all(
                    //                                       8.0),
                    //                               child: Column(
                    //                                 mainAxisAlignment:
                    //                                     MainAxisAlignment
                    //                                         .start,
                    //                                 crossAxisAlignment:
                    //                                     CrossAxisAlignment
                    //                                         .center,
                    //                                 children: [
                    //                                   // const Text(
                    //                                   //   ' Current \nMonth',
                    //                                   //   textAlign:
                    //                                   //       TextAlign.center,
                    //                                   //   style: TextStyle(
                    //                                   //       fontWeight: FontWeight.bold,
                    //                                   //       color: Colors.black,
                    //                                   //       fontSize: 14),
                    //                                   // ),
                    //                                   if (leadDashboard !=
                    //                                       null)
                    //                                     Text(
                    //                                       leadDashboard!
                    //                                           .data
                    //                                           .currentLeadsCount
                    //                                           .month,
                    //                                       textAlign:
                    //                                           TextAlign
                    //                                               .center,
                    //                                       style: const TextStyle(
                    //                                           fontWeight:
                    //                                               FontWeight
                    //                                                   .bold,
                    //                                           color: Colors
                    //                                               .black,
                    //                                           fontSize: 14),
                    //                                     ),
                    //                                   if (leadDashboard !=
                    //                                       null)
                    //                                     Text(
                    //                                       leadDashboard!
                    //                                           .data
                    //                                           .currentLeadsCount
                    //                                           .date,
                    //                                       textAlign:
                    //                                           TextAlign
                    //                                               .center,
                    //                                       style: const TextStyle(
                    //                                           fontWeight:
                    //                                               FontWeight
                    //                                                   .normal,
                    //                                           color: Colors
                    //                                               .black87,
                    //                                           fontSize: 9),
                    //                                     ),
                    //                                   const SizedBox(
                    //                                     height: 5,
                    //                                   ),
                    //                                   if (leadDashboard !=
                    //                                       null)
                    //                                     Text(
                    //                                       leadDashboard!
                    //                                           .data
                    //                                           .currentLeadsCount
                    //                                           .total
                    //                                           .toString(),
                    //                                       style: TextStyle(
                    //                                           fontWeight:
                    //                                               FontWeight
                    //                                                   .bold,
                    //                                           color: Colors
                    //                                               .grey
                    //                                               .shade900,
                    //                                           fontSize: 16),
                    //                                     ),
                    //                                 ],
                    //                               ),
                    //                             ),
                    //                           ),
                    //                           Container(
                    //                             width:
                    //                                 MediaQuery.of(context)
                    //                                         .size
                    //                                         .width *
                    //                                     .25,
                    //                             decoration: BoxDecoration(
                    //                                 borderRadius:
                    //                                     BorderRadius
                    //                                         .circular(8),
                    //                                 color: Colors
                    //                                     .orange.shade100),
                    //                             child: Padding(
                    //                               padding:
                    //                                   const EdgeInsets.all(
                    //                                       8.0),
                    //                               child: Column(
                    //                                 mainAxisAlignment:
                    //                                     MainAxisAlignment
                    //                                         .start,
                    //                                 crossAxisAlignment:
                    //                                     CrossAxisAlignment
                    //                                         .center,
                    //                                 children: [
                    //                                   // const Text(
                    //                                   //   ' Previous \nMonth ',
                    //                                   //   textAlign:
                    //                                   //       TextAlign.center,
                    //                                   //   style: TextStyle(
                    //                                   //       fontWeight: FontWeight.bold,
                    //                                   //       color: Colors.black,
                    //                                   //       fontSize: 14),
                    //                                   // ),
                    //                                   if (leadDashboard !=
                    //                                       null)
                    //                                     Text(
                    //                                       leadDashboard!
                    //                                           .data
                    //                                           .previousLeadsCount
                    //                                           .month,
                    //                                       textAlign:
                    //                                           TextAlign
                    //                                               .center,
                    //                                       style: const TextStyle(
                    //                                           fontWeight:
                    //                                               FontWeight
                    //                                                   .bold,
                    //                                           color: Colors
                    //                                               .black,
                    //                                           fontSize: 14),
                    //                                     ),
                    //                                   if (leadDashboard !=
                    //                                       null)
                    //                                     Text(
                    //                                       leadDashboard!
                    //                                           .data
                    //                                           .previousLeadsCount
                    //                                           .date,
                    //                                       textAlign:
                    //                                           TextAlign
                    //                                               .center,
                    //                                       style: const TextStyle(
                    //                                           fontWeight:
                    //                                               FontWeight
                    //                                                   .normal,
                    //                                           color: Colors
                    //                                               .black87,
                    //                                           fontSize: 9),
                    //                                     ),
                    //                                   const SizedBox(
                    //                                     height: 5,
                    //                                   ),
                    //                                   if (leadDashboard !=
                    //                                       null)
                    //                                     Text(
                    //                                       leadDashboard!
                    //                                           .data
                    //                                           .previousLeadsCount
                    //                                           .total
                    //                                           .toString(),
                    //                                       style: TextStyle(
                    //                                           fontWeight:
                    //                                               FontWeight
                    //                                                   .bold,
                    //                                           color: Colors
                    //                                               .grey
                    //                                               .shade900,
                    //                                           fontSize: 16),
                    //                                     ),
                    //                                 ],
                    //                               ),
                    //                             ),
                    //                           ),
                    //                           Container(
                    //                             height: 90,
                    //                             width: 100,
                    //                             decoration:
                    //                                 const BoxDecoration(
                    //                               image: DecorationImage(
                    //                                 image: AssetImage(
                    //                                     'assets/main/lead.png'),
                    //                                 fit: BoxFit.fill,
                    //                               ),
                    //                             ),
                    //                           )
                    //                         ],
                    //                       ),
                    //                     ],
                    //                   ),
                    //                 ),
                    //                 const SizedBox(
                    //                   height: 10,
                    //                 ),
                    //                 Padding(
                    //                   padding: const EdgeInsets.only(
                    //                       left: 10, right: 10),
                    //                   child: Align(
                    //                       alignment: Alignment.center,
                    //                       child: Container(
                    //                         height: 15,
                    //                         decoration: BoxDecoration(
                    //                             borderRadius:
                    //                                 BorderRadius.circular(
                    //                                     10)),
                    //                         child: Row(
                    //                           crossAxisAlignment:
                    //                               CrossAxisAlignment
                    //                                   .stretch,
                    //                           children: [
                    //                             for (var i = 0;
                    //                                 i <
                    //                                     staffWise!
                    //                                         .data!
                    //                                         .staffLeads!
                    //                                         .length;
                    //                                 i++)
                    //                               Expanded(
                    //                                   flex: staffWise!
                    //                                       .data!
                    //                                       .staffLeads![i]
                    //                                       .staffPercentage!,
                    //                                   child: Container(
                    //                                     decoration:
                    //                                         BoxDecoration(
                    //                                       borderRadius: staffWise!
                    //                                                   .data!
                    //                                                   .staffLeads!
                    //                                                   .length ==
                    //                                               1
                    //                                           ? const BorderRadius
                    //                                               .only(
                    //                                               topLeft:
                    //                                                   Radius.circular(
                    //                                                       5),
                    //                                               bottomLeft:
                    //                                                   Radius.circular(
                    //                                                       5),
                    //                                               topRight:
                    //                                                   Radius.circular(
                    //                                                       5),
                    //                                               bottomRight:
                    //                                                   Radius.circular(
                    //                                                       5))
                    //                                           : i == 0
                    //                                               ? const BorderRadius
                    //                                                   .only(
                    //                                                   topLeft:
                    //                                                       Radius.circular(5),
                    //                                                   bottomLeft:
                    //                                                       Radius.circular(5),
                    //                                                 )
                    //                                               : i ==
                    //                                                       staffWise!.data!.staffLeads!.length -
                    //                                                           1
                    //                                                   ? const BorderRadius.only(
                    //                                                       topRight: Radius.circular(5),
                    //                                                       bottomRight: Radius.circular(5))
                    //                                                   : BorderRadius.circular(0),
                    //                                       color: staffWise!
                    //                                                   .data!
                    //                                                   .staffLeads!
                    //                                                   .length >
                    //                                               _colors
                    //                                                   .length
                    //                                           ? Colors.red
                    //                                           : _colors[i],
                    //                                     ),
                    //                                     child: const Align(
                    //                                         alignment:
                    //                                             Alignment
                    //                                                 .center,
                    //                                         child: Text('',
                    //                                             style: TextStyle(
                    //                                                 fontSize:
                    //                                                     10,
                    //                                                 color: Colors
                    //                                                     .white))),
                    //                                   )),
                    //                           ],
                    //                         ),
                    //                       )),
                    //                 ),
                    //                 const SizedBox(
                    //                   height: 10,
                    //                 ),
                    //                 Table(columnWidths: const {
                    //                   0: FlexColumnWidth(10),
                    //                   1: FlexColumnWidth(5),
                    //                   2: FlexColumnWidth(5),
                    //                   3: FlexColumnWidth(5),
                    //                   4: FlexColumnWidth(5),
                    //                   5: FlexColumnWidth(5),
                    //                 }, children: [
                    //                   const TableRow(
                    //                       // decoration: new BoxDecoration(
                    //                       //     color: Colors.greenAccent),
                    //                       children: [
                    //                         Padding(
                    //                           padding: EdgeInsets.only(
                    //                               top: 10, bottom: 10),
                    //                           child: Center(
                    //                               child: Text(
                    //                             "",
                    //                             style: TextStyle(
                    //                                 fontSize: 17,
                    //                                 fontWeight:
                    //                                     FontWeight.bold),
                    //                           )),
                    //                         ),
                    //                         Padding(
                    //                           padding: EdgeInsets.only(
                    //                               top: 10, bottom: 10),
                    //                           child: Center(
                    //                               child: Text(
                    //                             'New',
                    //                             style: TextStyle(
                    //                                 fontSize: 10,
                    //                                 fontWeight:
                    //                                     FontWeight.bold),
                    //                           )),
                    //                         ),
                    //                         Padding(
                    //                           padding: EdgeInsets.only(
                    //                               top: 10, bottom: 10),
                    //                           child: Center(
                    //                               child: Text(
                    //                             'Pending',
                    //                             style: TextStyle(
                    //                                 fontSize: 10,
                    //                                 fontWeight:
                    //                                     FontWeight.bold),
                    //                           )),
                    //                         ),
                    //                         Padding(
                    //                           padding: EdgeInsets.only(
                    //                               top: 10, bottom: 10),
                    //                           child: Center(
                    //                               child: Text(
                    //                             'Followup',
                    //                             style: TextStyle(
                    //                                 fontSize: 10,
                    //                                 color: Colors.black,
                    //                                 fontWeight:
                    //                                     FontWeight.bold),
                    //                           )),
                    //                         ),
                    //                         Padding(
                    //                           padding: EdgeInsets.only(
                    //                               top: 10, bottom: 10),
                    //                           child: Center(
                    //                               child: Text(
                    //                             'Rejected',
                    //                             style: TextStyle(
                    //                                 fontSize: 10,
                    //                                 color: Colors.red,
                    //                                 fontWeight:
                    //                                     FontWeight.bold),
                    //                           )),
                    //                         ),
                    //                         Padding(
                    //                           padding: EdgeInsets.only(
                    //                               top: 10, bottom: 10),
                    //                           child: Center(
                    //                               child: Text(
                    //                             'Closed',
                    //                             style: TextStyle(
                    //                                 fontSize: 10,
                    //                                 fontWeight:
                    //                                     FontWeight.bold),
                    //                           )),
                    //                         ),
                    //                       ]),
                    //                   for (int j = 0;
                    //                       j <
                    //                           staffWise!
                    //                               .data!.staffLeads!.length;
                    //                       j++)
                    //                     TableRow(
                    //                         // decoration: new BoxDecoration(
                    //                         //     color: Colors.greenAccent),
                    //                         children: [
                    //                           InkWell(
                    //                             onTap: () {
                    //                               Navigator.of(context).push(MaterialPageRoute(
                    //                                   builder: (context) =>
                    //                                       StaffDashboard(
                    //                                           widget.token,
                    //                                           staffWise!
                    //                                               .data!
                    //                                               .staffLeads![
                    //                                                   j]
                    //                                               .staffId
                    //                                               .toString(),
                    //                                           staffWise!
                    //                                               .data!
                    //                                               .staffLeads![
                    //                                                   j]
                    //                                               .staffName
                    //                                               .toString())));
                    //                             },
                    //                             child: Padding(
                    //                               padding:
                    //                                   const EdgeInsets.only(
                    //                                       top: 0,
                    //                                       bottom: 10,
                    //                                       left: 15),
                    //                               child: Text(
                    //                                 staffWise!
                    //                                     .data!
                    //                                     .staffLeads![j]
                    //                                     .staffName
                    //                                     .toString(),
                    //                                 style: TextStyle(
                    //                                     fontSize: 10,
                    //                                     fontWeight:
                    //                                         FontWeight.bold,
                    //                                     color: staffWise!
                    //                                                 .data!
                    //                                                 .staffLeads!
                    //                                                 .length >
                    //                                             _colors
                    //                                                 .length
                    //                                         ? Colors.red
                    //                                         : _colors[j]),
                    //                               ),
                    //                             ),
                    //                           ),
                    //                           InkWell(
                    //                             onTap: () {
                    //                               Common.saveSharedPref(
                    //                                   "statusWise", 'yes');
                    //                               Common.saveSharedPref(
                    //                                   "statusWisId", '1');
                    //                               Common.saveSharedPref(
                    //                                   "type", 'staff');
                    //                               Common.saveSharedPref(
                    //                                   "statusCatId",
                    //                                   staffWise!
                    //                                       .data!
                    //                                       .staffLeads![j]
                    //                                       .staffId
                    //                                       .toString());
                    //                               viewLeadPermission ==
                    //                                       'true'
                    //                                   ? Navigator.push(
                    //                                       context,
                    //                                       MaterialPageRoute(
                    //                                           builder:
                    //                                               (context) =>
                    //                                                   ViewLeads(
                    //                                                     widget.token,
                    //                                                     updateLeadPermission1,
                    //                                                     deleteLeadPermission1,
                    //                                                     cloudCallPermission1,
                    //                                                     pageName:
                    //                                                         'New Leads',
                    //                                                     fromDate:
                    //                                                         fromdate1.toString(),
                    //                                                     toDate:
                    //                                                         todate1.toString(),
                    //                                                   )),
                    //                                     ).then((r) {
                    //                                       getData(
                    //                                           widget.token,
                    //                                           fromdate,
                    //                                           todate);
                    //                                       if (loadmore ==
                    //                                           true) {
                    //                                         getStaffwise();
                    //                                       }
                    //                                     })
                    //                                   : _dialogue(context,
                    //                                       'View Leads');
                    //                             },
                    //                             child: Padding(
                    //                               padding:
                    //                                   const EdgeInsets.only(
                    //                                       top: 0,
                    //                                       bottom: 10),
                    //                               child: Center(
                    //                                   child: Text(
                    //                                 staffWise!
                    //                                     .data!
                    //                                     .staffLeads![j]
                    //                                     .newCount
                    //                                     .toString(),
                    //                                 style: const TextStyle(
                    //                                     fontSize: 10,
                    //                                     fontWeight:
                    //                                         FontWeight
                    //                                             .bold),
                    //                               )),
                    //                             ),
                    //                           ),
                    //                           InkWell(
                    //                             onTap: () {
                    //                               Common.saveSharedPref(
                    //                                   "statusWise", 'yes');
                    //                               Common.saveSharedPref(
                    //                                   "statusWisId", '2');
                    //                               Common.saveSharedPref(
                    //                                   "type", 'staff');
                    //                               Common.saveSharedPref(
                    //                                   "statusCatId",
                    //                                   staffWise!
                    //                                       .data!
                    //                                       .staffLeads![j]
                    //                                       .staffId
                    //                                       .toString());
                    //                               viewLeadPermission ==
                    //                                       'true'
                    //                                   ? Navigator.push(
                    //                                       context,
                    //                                       MaterialPageRoute(
                    //                                           builder:
                    //                                               (context) =>
                    //                                                   ViewLeads(
                    //                                                     widget.token,
                    //                                                     updateLeadPermission1,
                    //                                                     deleteLeadPermission1,
                    //                                                     cloudCallPermission1,
                    //                                                     pageName:
                    //                                                         'Pending Leads',
                    //                                                     fromDate:
                    //                                                         fromdate1.toString(),
                    //                                                     toDate:
                    //                                                         todate1.toString(),
                    //                                                   )),
                    //                                     ).then((r) {
                    //                                       getData(
                    //                                           widget.token,
                    //                                           fromdate,
                    //                                           todate);
                    //                                       if (loadmore ==
                    //                                           true) {
                    //                                         getStaffwise();
                    //                                       }
                    //                                     })
                    //                                   : _dialogue(context,
                    //                                       'View Leads');
                    //                             },
                    //                             child: Padding(
                    //                               padding:
                    //                                   const EdgeInsets.only(
                    //                                       top: 0,
                    //                                       bottom: 10),
                    //                               child: Center(
                    //                                   child: Text(
                    //                                 staffWise!
                    //                                     .data!
                    //                                     .staffLeads![j]
                    //                                     .pendingCount
                    //                                     .toString(),
                    //                                 style: const TextStyle(
                    //                                     fontSize: 10,
                    //                                     fontWeight:
                    //                                         FontWeight
                    //                                             .bold),
                    //                               )),
                    //                             ),
                    //                           ),
                    //                           InkWell(
                    //                             onTap: () {
                    //                               Common.saveSharedPref(
                    //                                   "statusWise", 'yes');
                    //                               Common.saveSharedPref(
                    //                                   "statusWisId", '3');
                    //                               Common.saveSharedPref(
                    //                                   "type", 'staff');
                    //                               Common.saveSharedPref(
                    //                                   "statusCatId",
                    //                                   staffWise!
                    //                                       .data!
                    //                                       .staffLeads![j]
                    //                                       .staffId
                    //                                       .toString());
                    //                               viewLeadPermission ==
                    //                                       'true'
                    //                                   ? Navigator.push(
                    //                                       context,
                    //                                       MaterialPageRoute(
                    //                                           builder:
                    //                                               (context) =>
                    //                                                   ViewLeads(
                    //                                                     widget.token,
                    //                                                     updateLeadPermission1,
                    //                                                     deleteLeadPermission1,
                    //                                                     cloudCallPermission1,
                    //                                                     pageName:
                    //                                                         'Followup Leads',
                    //                                                     fromDate:
                    //                                                         fromdate1.toString(),
                    //                                                     toDate:
                    //                                                         todate1.toString(),
                    //                                                   )),
                    //                                     ).then((r) {
                    //                                       getData(
                    //                                           widget.token,
                    //                                           fromdate,
                    //                                           todate);
                    //                                       if (loadmore ==
                    //                                           true) {
                    //                                         getStaffwise();
                    //                                       }
                    //                                     })
                    //                                   : _dialogue(context,
                    //                                       'View Leads');
                    //                             },
                    //                             child: Padding(
                    //                               padding:
                    //                                   const EdgeInsets.only(
                    //                                       top: 0,
                    //                                       bottom: 10),
                    //                               child: Center(
                    //                                   child: Text(
                    //                                 staffWise!
                    //                                     .data!
                    //                                     .staffLeads![j]
                    //                                     .followupCount
                    //                                     .toString(),
                    //                                 style: const TextStyle(
                    //                                     fontSize: 10,
                    //                                     fontWeight:
                    //                                         FontWeight
                    //                                             .bold),
                    //                               )),
                    //                             ),
                    //                           ),
                    //                           InkWell(
                    //                             onTap: () {
                    //                               Common.saveSharedPref(
                    //                                   "statusWise", 'yes');
                    //                               Common.saveSharedPref(
                    //                                   "statusWisId", '4');
                    //                               Common.saveSharedPref(
                    //                                   "type", 'staff');
                    //                               Common.saveSharedPref(
                    //                                   "statusCatId",
                    //                                   staffWise!
                    //                                       .data!
                    //                                       .staffLeads![j]
                    //                                       .staffId
                    //                                       .toString());
                    //                               viewLeadPermission ==
                    //                                       'true'
                    //                                   ? Navigator.push(
                    //                                       context,
                    //                                       MaterialPageRoute(
                    //                                           builder:
                    //                                               (context) =>
                    //                                                   ViewLeads(
                    //                                                     widget.token,
                    //                                                     updateLeadPermission1,
                    //                                                     deleteLeadPermission1,
                    //                                                     cloudCallPermission1,
                    //                                                     pageName:
                    //                                                         'Rejected Leads',
                    //                                                     fromDate:
                    //                                                         fromdate1.toString(),
                    //                                                     toDate:
                    //                                                         todate1.toString(),
                    //                                                   )),
                    //                                     ).then((r) {
                    //                                       getData(
                    //                                           widget.token,
                    //                                           fromdate,
                    //                                           todate);
                    //                                       if (loadmore ==
                    //                                           true) {
                    //                                         getStaffwise();
                    //                                       }
                    //                                     })
                    //                                   : _dialogue(context,
                    //                                       'View Leads');
                    //                             },
                    //                             child: Padding(
                    //                               padding:
                    //                                   const EdgeInsets.only(
                    //                                       top: 0,
                    //                                       bottom: 10),
                    //                               child: Center(
                    //                                   child: Text(
                    //                                 staffWise!
                    //                                     .data!
                    //                                     .staffLeads![j]
                    //                                     .rejectedCount
                    //                                     .toString(),
                    //                                 style: const TextStyle(
                    //                                     fontSize: 10,
                    //                                     color: Colors.red,
                    //                                     fontWeight:
                    //                                         FontWeight
                    //                                             .bold),
                    //                               )),
                    //                             ),
                    //                           ),
                    //                           InkWell(
                    //                             onTap: () {
                    //                               Common.saveSharedPref(
                    //                                   "statusWise", 'yes');
                    //                               Common.saveSharedPref(
                    //                                   "statusWisId", '5');
                    //                               Common.saveSharedPref(
                    //                                   "type", 'staff');
                    //                               Common.saveSharedPref(
                    //                                   "statusCatId",
                    //                                   staffWise!
                    //                                       .data!
                    //                                       .staffLeads![j]
                    //                                       .staffId
                    //                                       .toString());
                    //                               viewLeadPermission ==
                    //                                       'true'
                    //                                   ? Navigator.push(
                    //                                       context,
                    //                                       MaterialPageRoute(
                    //                                           builder:
                    //                                               (context) =>
                    //                                                   ViewLeads(
                    //                                                     widget.token,
                    //                                                     updateLeadPermission1,
                    //                                                     deleteLeadPermission1,
                    //                                                     cloudCallPermission1,
                    //                                                     pageName:
                    //                                                         'Closed Leads',
                    //                                                     fromDate:
                    //                                                         fromdate1.toString(),
                    //                                                     toDate:
                    //                                                         todate1.toString(),
                    //                                                   )),
                    //                                     ).then((r) {
                    //                                       getData(
                    //                                           widget.token,
                    //                                           fromdate,
                    //                                           todate);
                    //                                       if (loadmore ==
                    //                                           true) {
                    //                                         getStaffwise();
                    //                                       }
                    //                                     })
                    //                                   : _dialogue(context,
                    //                                       'View Leads');
                    //                             },
                    //                             child: Padding(
                    //                               padding:
                    //                                   const EdgeInsets.only(
                    //                                       top: 0,
                    //                                       bottom: 10),
                    //                               child: Center(
                    //                                   child: Text(
                    //                                 staffWise!
                    //                                     .data!
                    //                                     .staffLeads![j]
                    //                                     .confirmedCount
                    //                                     .toString(),
                    //                                 style: const TextStyle(
                    //                                     fontSize: 10,
                    //                                     fontWeight:
                    //                                         FontWeight
                    //                                             .bold),
                    //                               )),
                    //                             ),
                    //                           ),
                    //                         ]),
                    //                 ]),
                    //                 const Divider(
                    //                   endIndent: 8,
                    //                   indent: 8,
                    //                 ),
                    //                 Padding(
                    //                   padding: const EdgeInsets.only(
                    //                       top: 5.0, bottom: 12.0),
                    //                   child: Table(
                    //                     columnWidths: const {
                    //                       0: FlexColumnWidth(10),
                    //                       1: FlexColumnWidth(5),
                    //                       2: FlexColumnWidth(5),
                    //                       3: FlexColumnWidth(5),
                    //                       4: FlexColumnWidth(5),
                    //                       5: FlexColumnWidth(5),
                    //                     },
                    //                     children: [
                    //                       TableRow(
                    //                           // decoration: new BoxDecoration(
                    //                           //     color: Colors.greenAccent),
                    //                           children: [
                    //                             const Center(
                    //                                 child: Text(
                    //                               "Total Leads",
                    //                               style: TextStyle(
                    //                                   fontSize: 11,
                    //                                   fontWeight:
                    //                                       FontWeight.bold),
                    //                             )),
                    //                             InkWell(
                    //                               onTap: () {
                    //                                 Common.saveSharedPref(
                    //                                     "statusWise",
                    //                                     'yes');
                    //                                 Common.saveSharedPref(
                    //                                     "statusWisId", '1');
                    //                                 Common.saveSharedPref(
                    //                                     "type", 'staff');
                    //                                 Common.saveSharedPref(
                    //                                     "statusCatId",
                    //                                     "-1");
                    //                                 viewLeadPermission ==
                    //                                         'true'
                    //                                     ? Navigator.push(
                    //                                         context,
                    //                                         MaterialPageRoute(
                    //                                             builder:
                    //                                                 (context) =>
                    //                                                     ViewLeads(
                    //                                                       widget.token,
                    //                                                       updateLeadPermission1,
                    //                                                       deleteLeadPermission1,
                    //                                                       cloudCallPermission1,
                    //                                                       pageName: 'New Leads',
                    //                                                       fromDate: fromdate1.toString(),
                    //                                                       toDate: todate1.toString(),
                    //                                                     )),
                    //                                       ).then((r) {
                    //                                         getData(
                    //                                             widget
                    //                                                 .token,
                    //                                             fromdate,
                    //                                             todate);
                    //                                         if (loadmore ==
                    //                                             true) {
                    //                                           getStaffwise();
                    //                                         }
                    //                                       })
                    //                                     : _dialogue(context,
                    //                                         'View Leads');
                    //                               },
                    //                               child: Center(
                    //                                   child: Text(
                    //                                 stfNew.toString(),
                    //                                 style: const TextStyle(
                    //                                     fontSize: 10,
                    //                                     fontWeight:
                    //                                         FontWeight
                    //                                             .bold),
                    //                               )),
                    //                             ),
                    //                             InkWell(
                    //                               onTap: () {
                    //                                 Common.saveSharedPref(
                    //                                     "statusWise",
                    //                                     'yes');
                    //                                 Common.saveSharedPref(
                    //                                     "statusWisId", '2');
                    //                                 Common.saveSharedPref(
                    //                                     "type", 'staff');
                    //                                 Common.saveSharedPref(
                    //                                     "statusCatId",
                    //                                     "-1");
                    //                                 viewLeadPermission ==
                    //                                         'true'
                    //                                     ? Navigator.push(
                    //                                         context,
                    //                                         MaterialPageRoute(
                    //                                             builder:
                    //                                                 (context) =>
                    //                                                     ViewLeads(
                    //                                                       widget.token,
                    //                                                       updateLeadPermission1,
                    //                                                       deleteLeadPermission1,
                    //                                                       cloudCallPermission1,
                    //                                                       pageName: 'Pending Leads',
                    //                                                       fromDate: fromdate1.toString(),
                    //                                                       toDate: todate1.toString(),
                    //                                                     )),
                    //                                       ).then((r) {
                    //                                         getData(
                    //                                             widget
                    //                                                 .token,
                    //                                             fromdate,
                    //                                             todate);
                    //                                         if (loadmore ==
                    //                                             true) {
                    //                                           getStaffwise();
                    //                                         }
                    //                                       })
                    //                                     : _dialogue(context,
                    //                                         'View Leads');
                    //                               },
                    //                               child: Center(
                    //                                   child: Text(
                    //                                 stfPending.toString(),
                    //                                 style: const TextStyle(
                    //                                     fontSize: 10,
                    //                                     fontWeight:
                    //                                         FontWeight
                    //                                             .bold),
                    //                               )),
                    //                             ),
                    //                             InkWell(
                    //                               onTap: () {
                    //                                 Common.saveSharedPref(
                    //                                     "statusWise",
                    //                                     'yes');
                    //                                 Common.saveSharedPref(
                    //                                     "statusWisId", '3');
                    //                                 Common.saveSharedPref(
                    //                                     "type", 'staff');
                    //                                 Common.saveSharedPref(
                    //                                     "statusCatId",
                    //                                     "-1");
                    //                                 viewLeadPermission ==
                    //                                         'true'
                    //                                     ? Navigator.push(
                    //                                         context,
                    //                                         MaterialPageRoute(
                    //                                             builder:
                    //                                                 (context) =>
                    //                                                     ViewLeads(
                    //                                                       widget.token,
                    //                                                       updateLeadPermission1,
                    //                                                       deleteLeadPermission1,
                    //                                                       cloudCallPermission1,
                    //                                                       pageName: 'Followup Leads',
                    //                                                       fromDate: fromdate1.toString(),
                    //                                                       toDate: todate1.toString(),
                    //                                                     )),
                    //                                       ).then((r) {
                    //                                         getData(
                    //                                             widget
                    //                                                 .token,
                    //                                             fromdate,
                    //                                             todate);
                    //                                         if (loadmore ==
                    //                                             true) {
                    //                                           getStaffwise();
                    //                                         }
                    //                                       })
                    //                                     : _dialogue(context,
                    //                                         'View Leads');
                    //                               },
                    //                               child: Center(
                    //                                   child: Text(
                    //                                 stfFollowup.toString(),
                    //                                 style: const TextStyle(
                    //                                     fontSize: 10,
                    //                                     color: Colors.black,
                    //                                     fontWeight:
                    //                                         FontWeight
                    //                                             .bold),
                    //                               )),
                    //                             ),
                    //                             InkWell(
                    //                               onTap: () {
                    //                                 Common.saveSharedPref(
                    //                                     "statusWise",
                    //                                     'yes');
                    //                                 Common.saveSharedPref(
                    //                                     "statusWisId", '4');
                    //                                 Common.saveSharedPref(
                    //                                     "type", 'staff');
                    //                                 Common.saveSharedPref(
                    //                                     "statusCatId",
                    //                                     "-1");
                    //                                 viewLeadPermission ==
                    //                                         'true'
                    //                                     ? Navigator.push(
                    //                                         context,
                    //                                         MaterialPageRoute(
                    //                                             builder:
                    //                                                 (context) =>
                    //                                                     ViewLeads(
                    //                                                       widget.token,
                    //                                                       updateLeadPermission1,
                    //                                                       updateLeadPermission1,
                    //                                                       cloudCallPermission1,
                    //                                                       pageName: 'Rejected Leads',
                    //                                                       fromDate: fromdate1.toString(),
                    //                                                       toDate: todate1.toString(),
                    //                                                     )),
                    //                                       ).then((r) {
                    //                                         getData(
                    //                                             widget
                    //                                                 .token,
                    //                                             fromdate,
                    //                                             todate);
                    //                                         if (loadmore ==
                    //                                             true) {
                    //                                           getStaffwise();
                    //                                         }
                    //                                       })
                    //                                     : _dialogue(context,
                    //                                         'View Leads');
                    //                               },
                    //                               child: Center(
                    //                                   child: Text(
                    //                                 stfRejected.toString(),
                    //                                 style: const TextStyle(
                    //                                     fontSize: 10,
                    //                                     color: Colors.red,
                    //                                     fontWeight:
                    //                                         FontWeight
                    //                                             .bold),
                    //                               )),
                    //                             ),
                    //                             InkWell(
                    //                               onTap: () {
                    //                                 Common.saveSharedPref(
                    //                                     "statusWise",
                    //                                     'yes');
                    //                                 Common.saveSharedPref(
                    //                                     "type", 'staff');
                    //                                 Common.saveSharedPref(
                    //                                     "statusCatId",
                    //                                     "-1");
                    //                                 Common.saveSharedPref(
                    //                                     "statusWisId", '5');
                    //                                 viewLeadPermission ==
                    //                                         'true'
                    //                                     ? Navigator.push(
                    //                                         context,
                    //                                         MaterialPageRoute(
                    //                                             builder:
                    //                                                 (context) =>
                    //                                                     ViewLeads(
                    //                                                       widget.token,
                    //                                                       updateLeadPermission1,
                    //                                                       deleteLeadPermission1,
                    //                                                       cloudCallPermission1,
                    //                                                       pageName: 'Closed Leads',
                    //                                                       fromDate: fromdate1.toString(),
                    //                                                       toDate: todate1.toString(),
                    //                                                     )),
                    //                                       ).then((r) {
                    //                                         getData(
                    //                                             widget
                    //                                                 .token,
                    //                                             fromdate,
                    //                                             todate);
                    //                                         if (loadmore ==
                    //                                             true) {
                    //                                           getStaffwise();
                    //                                         }
                    //                                       })
                    //                                     : _dialogue(context,
                    //                                         'View Leads');
                    //                               },
                    //                               child: Center(
                    //                                   child: Text(
                    //                                 stfClosed.toString(),
                    //                                 style: const TextStyle(
                    //                                     fontSize: 10,
                    //                                     fontWeight:
                    //                                         FontWeight
                    //                                             .bold),
                    //                               )),
                    //                             ),
                    //                           ]),
                    //                     ],
                    //                   ),
                    //                 )
                    //               ],
                    //             )),
                    //       ],
                    //     ),
                    //   )
                  ],
                ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> viewReportsDialog(BuildContext context) {
    return showDialog(
        barrierColor: Colors.white.withOpacity(.4),
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async {
              return true;
            },
            child: Material(
              type: MaterialType.transparency,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: 300,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/icons/check.png',
                            width: 80,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            'Reports',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w400),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          const Text(
                            'Choose Report',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w400),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => AllReport(
                                                  widget.token!,
                                                  true,
                                                  true,
                                                  true,
                                                  pageName: 'AllLeads',
                                                )),
                                      );
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.38,
                                      //  color: RandomColorModel().getColor(),
                                      decoration: BoxDecoration(
                                          color: Colors.green.shade100,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: const Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Icon(
                                              Icons.dashboard,
                                              size: 15,
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text('Lead Report',
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.black),
                                                textAlign: TextAlign.center),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                TransferLeadReport(
                                                  widget.token!,
                                                  true,
                                                  true,
                                                  true,
                                                  pageName: 'transferLeads',
                                                )),
                                      );
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.38,
                                      decoration: BoxDecoration(
                                          color: Colors.green.shade100,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: const Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Icon(
                                              Icons.list_alt,
                                              size: 15,
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text('Transfer Report',
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.black),
                                                textAlign: TextAlign.center),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            StaffReportDashboard(
                                              id: userId,
                                            )),
                                  );
                                },
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.38,
                                  decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: const Padding(
                                    padding: EdgeInsets.all(5),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Icon(
                                          Icons.person,
                                          size: 15,
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text('Staff Dashboard',
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.black),
                                            textAlign: TextAlign.center),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  Container appBarWidget(BuildContext context, String type) {
    return Container(
      decoration: const BoxDecoration(color: Colors.blue),
      child: Padding(
        padding: EdgeInsets.only(
            left: 20, top: type == "lead" ? 55 : 15, bottom: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InkWell(
                    //   onTap: () => logout(context),
                    onTap: () async {
                      try {
                        final result = await HttpService.getWorkStatus();
                        if (result != null && result.data.isNotEmpty) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Logout Blocked'),
                              content: const Text(
                                  'Work is in progress. Please close all work before logging out.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        } else {
                          logout(context);
                        }
                      } catch (e) {
                        print('Error checking work status: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Failed to check work status')),
                        );
                      }
                    },
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
                      child: userDashboard != null
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(
                                userDashboard!.data.profilePic,
                              ),
                            )
                          : Shimmer.fromColors(
                              enabled: true,
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade100,
                              child: const CircleAvatar()),
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
                userDashboard != null && startAndStopWorkPermission == "true"
                    ?
                    //  StartStopToggle(
                    //     initialStatus: userDashboard!.data.loginCheck,
                    //     onToggle: (bool started) {
                    //       setState(() {
                    //         userDashboard!.data.loginCheck = started;
                    //       });
                    //     },
                    //   )
                    StartStopToggle(
                        initialStatus: userDashboard!.data.loginCheck,
                        onToggle: (bool started) {
                          setState(() {
                            userDashboard!.data.loginCheck = started;
                          });
                        },
                        setDashboardLoading: (bool loading) {
                          setState(() {
                            isLoading =
                                true; // This changes the dashboard loader state
                          });
                        },
                      )
                    : const SizedBox(),
                const SizedBox(
                  width: 20,
                ),
                InkWell(
                  onTap: () async {
                    var status = await Permission.notification.status;
                    if (status.isPermanentlyDenied) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Permission Required'),
                          content: const Text(
                              'Notification permission is permanently denied. Please enable it in settings to receive updates.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                AppSettings.openAppSettings(
                                    type: AppSettingsType.notification);
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
                              widget.token,
                              createLeadCategory1,
                              updateLeadCategory1,
                              deleteLeadCategory1)),
                    ).then((r) {
                      getData(widget.token, fromdate, todate);
                      if (loadmore == true) {
                        getStaffwise();
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Stack(
                      children: [
                        Image.asset("assets/icons/notification.png",
                            width: 20, color: Colors.white),
                        notificationCount > 0
                            ? Positioned(
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(1),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  constraints: const BoxConstraints(
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
                    child: Image.asset("assets/icons/menu.png", width: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<Object?> leadProgressbarDialog(
      BuildContext context, String title, String status, String type) {
    return showGeneralDialog(
      barrierLabel: "showGeneralDialog",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 400),
      context: context,
      pageBuilder: (context, _, __) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: IntrinsicHeight(
            child: SingleChildScrollView(
              child: Container(
                width: double.maxFinite,
                clipBehavior: Clip.antiAlias,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Material(
                  color: Colors.white,
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(
                            width: 25,
                          ),
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          InkWell(
                            onTap: () => {
                              Navigator.pop(context),
                            },
                            child: Container(
                              width: 25,
                              height: 25,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all()),
                              child: const Center(
                                child: Icon(
                                  Icons.close,
                                  color: Colors.black,
                                  size: 15,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        object1!.data!.totalCount.toString(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.green.shade900,
                        ),
                      ),
                      object1!.data!.staffLeads!.isNotEmpty
                          ? const Padding(
                              padding: EdgeInsets.only(bottom: 20),
                              child: Row(
                                children: [
                                  Text(
                                    'Staff Wise Lead',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox(),
                      object1!.data!.staffLeads!.isNotEmpty
                          ? SizedBox(
                              height: 60 *
                                  double.parse(object1!.data!.staffLeads!.length
                                      .toString()),
                              // 70% height
                              child: MediaQuery.removePadding(
                                context: context,
                                removeTop: true,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: object1!.data!.staffLeads!.length,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, i) {
                                    return InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ViewLeads(
                                                  widget.token,
                                                  updateLeadPermission1,
                                                  deleteLeadPermission1,
                                                  cloudCallPermission1,
                                                  pageName: title,
                                                  fromDate: fromdate.toString(),
                                                  toDate: todate.toString(),
                                                  status: status,
                                                  leadType: type,
                                                  staffName: object1!.data!
                                                      .staffLeads![i].staffName,
                                                  staff: object1!.data!
                                                      .staffLeads![i].staffId)),
                                        ).then((r) async {
                                          // await getLeadProgressbar(widget.token,
                                          //     fromdate, todate, '1');
                                          getData(
                                              widget.token, fromdate, todate);
                                          if (loadmore == true) {
                                            getStaffwise();
                                          }
                                          // setState(() {});
                                        });
                                      },
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 15, right: 15),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  object1!.data!.staffLeads![i]
                                                      .staffName
                                                      .toString(),
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                Text(
                                                  'Count : ${object1!.data!.staffLeads![i].staffCount}',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 15, right: 15, top: 5),
                                            child: LinearPercentIndicator(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.82,
                                              animation: true,
                                              lineHeight: 15.0,
                                              animationDuration: 2500,
                                              percent: double.parse(object1!
                                                  .data!
                                                  .staffLeads![i]
                                                  .staffPercentage
                                                  .toString()),
                                              progressColor: object1!.data!
                                                          .staffLeads!.length >
                                                      _colors.length
                                                  ? Colors.red
                                                  : _colors[i],
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 15,
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )
                          : const SizedBox(),
                      object1!.data!.categoryLeads!.isNotEmpty
                          ? const Padding(
                              padding: EdgeInsets.only(bottom: 20),
                              child: Row(
                                children: [
                                  Text(
                                    'Category Wise Lead',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox(),
                      object1!.data!.categoryLeads!.isNotEmpty
                          ? SizedBox(
                              height: 60 *
                                  double.parse(object1!
                                      .data!.categoryLeads!.length
                                      .toString()),
                              child: MediaQuery.removePadding(
                                context: context,
                                removeTop: true,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount:
                                      object1!.data!.categoryLeads!.length,
                                  itemBuilder: (context, i) {
                                    return InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ViewLeads(
                                                  widget.token,
                                                  updateLeadPermission1,
                                                  deleteLeadPermission1,
                                                  cloudCallPermission1,
                                                  pageName: title,
                                                  fromDate: fromdate.toString(),
                                                  toDate: todate.toString(),
                                                  leadType: type,
                                                  status: status,
                                                  categoryName: object1!
                                                      .data!
                                                      .categoryLeads![i]
                                                      .categoryName,
                                                  category: object1!
                                                      .data!
                                                      .categoryLeads![i]
                                                      .categoryId
                                                      .toString())),
                                        ).then((r) {
                                          getData(
                                              widget.token, fromdate, todate);
                                          if (loadmore == true) {
                                            getStaffwise();
                                          }
                                        });
                                      },
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 15, right: 15),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  object1!
                                                      .data!
                                                      .categoryLeads![i]
                                                      .categoryName
                                                      .toString(),
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                Text(
                                                  'Count : ${object1!.data!.categoryLeads![i].categoryCount}',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 15, right: 15, top: 5),
                                            child: LinearPercentIndicator(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.82,
                                              animation: true,
                                              lineHeight: 15.0,
                                              animationDuration: 2500,
                                              percent: double.parse(object1!
                                                  .data!
                                                  .categoryLeads![i]
                                                  .categoryPercentage
                                                  .toString()),
                                              progressColor: object1!
                                                          .data!
                                                          .categoryLeads!
                                                          .length >
                                                      _colors.length
                                                  ? Colors.red
                                                  : _colors[i],
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 15,
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )
                          : const SizedBox(),
                      object1!.data!.missedLeads!.isNotEmpty
                          ? const Padding(
                              padding: EdgeInsets.only(bottom: 20),
                              child: Row(
                                children: [
                                  Text(
                                    'Missed Leads',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox(),
                      object1!.data!.missedLeads!.isNotEmpty
                          ? SizedBox(
                              height: 60 *
                                  double.parse(object1!
                                      .data!.missedLeads!.length
                                      .toString()),
                              // 70% height
                              child: MediaQuery.removePadding(
                                context: context,
                                removeTop: true,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: object1!.data!.missedLeads!.length,
                                  itemBuilder: (context, i) {
                                    return InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ViewLeads(
                                                  widget.token,
                                                  updateLeadPermission1,
                                                  deleteLeadPermission1,
                                                  cloudCallPermission1,
                                                  pageName: title,
                                                  // leadType: type,
                                                  leadType: '1',
                                                  fromDate: fromdate.toString(),
                                                  toDate: DateTime(
                                                          DateTime.now().year,
                                                          DateTime.now().month,
                                                          DateTime.now().day -
                                                              1)
                                                      .toString(),
                                                  status: status,
                                                  staff: object1!
                                                      .data!
                                                      .missedLeads![i]
                                                      .missedstaffId
                                                      .toString())),
                                        ).then((r) {
                                          getData(
                                              widget.token, fromdate, todate);
                                          if (loadmore == true) {
                                            getStaffwise();
                                          }
                                        });
                                      },
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 15, right: 15),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  object1!.data!.missedLeads![i]
                                                      .missedstaffName
                                                      .toString(),
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                Text(
                                                  'Count : ${object1!.data!.missedLeads![i].missedstaffCount}',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 15, right: 15, top: 5),
                                            child: LinearPercentIndicator(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.82,
                                              animation: true,
                                              lineHeight: 15.0,
                                              animationDuration: 2500,
                                              percent: double.parse(object1!
                                                  .data!
                                                  .missedLeads![i]
                                                  .missedstaffPercentage
                                                  .toString()),
                                              progressColor: object1!.data!
                                                          .missedLeads!.length >
                                                      _colors.length
                                                  ? Colors.red
                                                  : _colors[i],
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 15,
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )
                          : const SizedBox(),
                      object1!.data!.statusLeads!.isNotEmpty
                          ? const Padding(
                              padding: EdgeInsets.only(bottom: 20),
                              child: Row(
                                children: [
                                  Text(
                                    'Status Wise Lead',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox(),
                      object1!.data!.statusLeads!.isNotEmpty
                          ? SizedBox(
                              height: 60 *
                                  double.parse(object1!
                                      .data!.statusLeads!.length
                                      .toString()),
                              // 70% height
                              child: MediaQuery.removePadding(
                                context: context,
                                removeTop: true,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: object1!.data!.statusLeads!.length,
                                  itemBuilder: (context, i) {
                                    return Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 15, right: 15),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                object1!.data!.statusLeads![i]
                                                    .statusName
                                                    .toString(),
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              Text(
                                                'Count : ${object1!.data!.statusLeads![i].statusCount}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 15, right: 15, top: 5),
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => ViewLeads(
                                                        widget.token,
                                                        updateLeadPermission1,
                                                        deleteLeadPermission1,
                                                        cloudCallPermission1,
                                                        pageName:
                                                            'Total Called',
                                                        fromDate:
                                                            fromdate.toString(),
                                                        toDate:
                                                            todate.toString(),
                                                        callStatus: "1",
                                                        status: "0")),
                                              ).then((r) {
                                                getData(widget.token, fromdate,
                                                    todate);
                                                if (loadmore == true) {
                                                  getStaffwise();
                                                }
                                              });
                                            },
                                            child: LinearPercentIndicator(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.82,
                                              animation: true,
                                              lineHeight: 15.0,
                                              animationDuration: 2500,
                                              percent: double.parse(object1!
                                                  .data!
                                                  .statusLeads![i]
                                                  .statusPercentage
                                                  .toString()),
                                              progressColor: object1!.data!
                                                          .statusLeads!.length >
                                                      _colors.length
                                                  ? Colors.red
                                                  : _colors[i],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        )
                                      ],
                                    );
                                  },
                                ),
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, animation1, __, child) {
        return SlideTransition(
          position: Tween(
            begin: const Offset(0, 1),
            end: const Offset(0, 0),
          ).animate(animation1),
          child: child,
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

// return false;
  }

  bool toBoolean(String val) {
    return (val == "true" || val == "1") ? true : false;
  }

  Container progressItem(String name, String amount, double value) {
    return Container(
      color: const Color(0xFFf0ebef),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 26.0, left: 20.0, right: 20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.blue.shade900,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  amount,
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue.shade900,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            LinearProgressIndicator(
              borderRadius: BorderRadius.circular(8),
              backgroundColor: Colors.grey,
              value: value / 100,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade900),
              minHeight: 6,
            ),
          ],
        ),
      ),
    );
  }

  Container gridItem(
      String name, String value, Color amountColor, Color backGround) {
    return Container(
      decoration: BoxDecoration(
          color: backGround,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
                blurRadius: 0.5,
                color: Colors.grey.shade300,
                offset: const Offset(2.5, 2.5))
          ]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            name,
            style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.normal,
                fontSize: 13),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            value,
            style: TextStyle(
                color: amountColor, fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ],
      ),
    );
  }

  Widget accDashShimmer() {
    return Shimmer.fromColors(
        enabled: true,
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 30.0, left: 10, right: 10),
                child: Container(
                  width: MediaQuery.of(context).size.width * .95,
                  height: MediaQuery.of(context).size.height * .25,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.black),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * .9,
                height: MediaQuery.of(context).size.height * .64,
                child: GridView(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 15,
                      childAspectRatio: 1.5),
                  children: [
                    gridItem("", "", Colors.black, Colors.black),
                    gridItem("", "", Colors.black, Colors.black),
                    gridItem("", "", Colors.black, Colors.black),
                    gridItem("", "", Colors.black, Colors.black),
                    gridItem("", "", Colors.black, Colors.black),
                    gridItem("", "", Colors.black, Colors.black),
                    gridItem("", "", Colors.black, Colors.black),
                    gridItem("", "", Colors.black, Colors.black),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

//not using right now ///////////// working code below////////////////////////
  void showAddWorkDialog(BuildContext context,
      {WorkStatus? existingWork}) async {
    WorkStatusModel? workStatus;
    if (existingWork == null) {
      workStatus = await HttpService.getWorkStatus();
    }

    final initialWork = existingWork ??
        (workStatus?.data.isNotEmpty == true ? workStatus!.data.first : null);

    final titleController =
        TextEditingController(text: initialWork?.title ?? '');
    final List<Map<String, dynamic>> tasks = initialWork != null
        ? initialWork.tasks
            .map((task) => {
                  'controller': TextEditingController(text: task.taskName),
                  'status': task.status,
                  'task_id': task.taskId,
                })
            .toList()
        : [
            {'controller': TextEditingController(), 'status': null}
          ];

    final workData = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        String? selectedProjectId;
        String? selectedProjectName;
        List<Projects> projectList = [];
        bool isLoading = true;
        if (initialWork != null) {
          selectedProjectId = initialWork.projectId;
        }

        return StatefulBuilder(
          builder: (context, setState) {
            if (isLoading) {
              Future.microtask(() async {
                try {
                  final response = await HttpService.getProjectList();
                  setState(() {
                    projectList = response!.data;
                    final uniqueProjects = <String, Projects>{};
                    for (var project in projectList) {
                      uniqueProjects[project.id] = project;
                    }
                    projectList = uniqueProjects.values.toList();
                    if (selectedProjectId != null) {
                      final projectExists =
                          projectList.any((p) => p.id == selectedProjectId);
                      if (!projectExists) {
                        selectedProjectId = null;
                      }
                    }

                    if (initialWork != null && selectedProjectId != null) {
                      selectedProjectName = projectList
                          .firstWhere((p) => p.id == selectedProjectId)
                          .name;
                    }
                    isLoading = false;
                  });
                } catch (e) {
                  setState(() {
                    isLoading = false;
                    selectedProjectId = null;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to load projects: $e')),
                  );
                }
              });
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            initialWork != null ? 'Stop Work' : 'Start Work',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: isLoading ? null : selectedProjectId,
                              items: [
                                if (isLoading)
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text('Loading projects...'),
                                  )
                                else
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text('Select Project'),
                                  ),
                                ...projectList
                                    .map((project) => DropdownMenuItem(
                                          value: project.id,
                                          child: Text(project.name),
                                        ))
                              ],
                              onChanged: (value) {
                                setState(() {
                                  selectedProjectId = value;
                                  if (value != null) {
                                    selectedProjectName = projectList
                                        .firstWhere((p) => p.id == value)
                                        .name;
                                  }
                                });
                              },
                              decoration: const InputDecoration(
                                labelText: 'Project',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: titleController,
                              decoration: const InputDecoration(
                                labelText: 'Title',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Column(
                        children: [
                          for (int i = 0; i < tasks.length; i++)
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: TextField(
                                          controller: tasks[i]['controller'],
                                          decoration: const InputDecoration(
                                            labelText: 'Task',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        flex: 4,
                                        child: DropdownButtonFormField<String>(
                                          value: tasks[i]['status'],
                                          items: ['New', 'Pending', 'Complete']
                                              .map((status) => DropdownMenuItem(
                                                    value: status,
                                                    child: Text(status),
                                                  ))
                                              .toList(),
                                          onChanged: (value) => setState(() {
                                            tasks[i]['status'] = value;
                                          }),
                                          decoration: const InputDecoration(
                                            labelText: 'Status',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      if (i == 0)
                                        IconButton(
                                          icon: const Icon(Icons.add),
                                          onPressed: () => setState(() {
                                            tasks.add({
                                              'controller':
                                                  TextEditingController(),
                                              'status': null,
                                            });
                                          }),
                                        ),
                                      if (i > 0)
                                        IconButton(
                                          icon: const Icon(Icons.close,
                                              color: Colors.red),
                                          onPressed: () => setState(() {
                                            tasks.removeAt(i);
                                          }),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      DateFormat('hh:mm a')
                                          .format(DateTime.now()),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              initialWork != null ? Colors.red : Colors.green,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: () {
                          if (selectedProjectId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select a project'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          final workData = {
                            'work_id': initialWork?.id,
                            'project_id': selectedProjectId,
                            'project_name': selectedProjectName,
                            'title': titleController.text,
                            'tasks': tasks
                                .map((task) => {
                                      'task_id': task['task_id'],
                                      'description': task['controller'].text,
                                      'status': task['status'],
                                    })
                                .toList(),
                          };

                          Navigator.pop(context, workData);
                        },
                        child: Text(initialWork != null ? 'Stop' : 'Start'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (workData != null) {
      try {
        final response = initialWork != null
            ? await HttpService.updateWorkData(workData)
            : await HttpService.submitWorkData(workData);

        if (response.status) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(initialWork != null
                  ? 'Work stopped successfully!'
                  : 'Work started successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              getData(widget.token, fromdate, todate);
            });
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Operation failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  //not using right now ///////////// working code below////////////////////////
}

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_settings/app_settings.dart';
import 'package:login2/screens/leadManagement/dashboardLeadsNewUpdated2.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/commonConfigureModel.dart';
import 'package:login2/models/dashboardModel.dart';
import 'package:login2/models/departmentModel.dart';
import 'package:login2/models/expense/expense_post.dart';
import 'package:login2/models/lead_management/leadDashboardModel.dart';
import 'package:login2/models/lead_management/leadProgressbarModel.dart';
import 'package:login2/models/lead_management/projectList_model.dart';
import 'package:login2/models/lead_management/workstatus_model.dart';
import 'package:login2/models/loginCheckModel.dart';
import 'package:login2/models/projectCountModel.dart';
import 'package:login2/models/staff_report/AttendanceStaffwiseModel.dart';
import 'package:login2/screens/accounts/dashboard/accounts_dashboard.dart';
import 'package:login2/screens/accounts/renewal_mannagement/renewal_dashboard.dart';
import 'package:login2/screens/authentication/login.dart';
import 'package:login2/screens/bottom_navigation_bar.dart';
import 'package:login2/screens/drawerScreen.dart';
import 'package:login2/screens/homePage.dart';
import 'package:login2/screens/leadManagement/AddProjectPage.dart';
import 'package:login2/screens/leadManagement/AssignReport.dart';
import 'package:login2/screens/leadManagement/StaffCalendarPage.dart';
import 'package:login2/screens/leadManagement/addWork_page.dart';
import 'package:login2/screens/leadManagement/assignWorkPage.dart';
import 'package:login2/screens/leadManagement/attendanceCalendar.dart';
import 'package:login2/screens/leadManagement/completedWorkPageNew.dart';
import 'package:login2/screens/leadManagement/dashboard.dart';
import 'package:login2/screens/leadManagement/minimalDashboard.dart';
import 'package:login2/screens/leadManagement/notification_page.dart';
import 'package:login2/screens/leadManagement/pendingWorkPage.dart';
import 'package:login2/screens/leadManagement/pendingWorkPageNew.dart';
import 'package:login2/screens/leadManagement/salaryReportPage.dart';
import 'package:login2/screens/leadManagement/totalSummeryPage.dart';
import 'package:login2/screens/leadManagement/viewallcompanyworks.dart';
import 'package:login2/screens/leave_request_list_page.dart';
import 'package:login2/service/service.dart';
import 'package:login2/widgets/togglebutton_start.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../authentication/deep_link_handler.dart';

class ProjectDashboard extends StatefulWidget {
  const ProjectDashboard({super.key});

  @override
  State<ProjectDashboard> createState() => _ProjectDashboardState();
}

class _ProjectDashboardState extends State<ProjectDashboard> {
  String multipleWorksCheck = '';
  String staffId = '';
  String userId = '';
  String token = '';

  bool? isLoggedIn;
  bool? result = true;
  bool timeOut = false;
  String? ProjectDashboardPermission;
  String? AccountsDashboardPermission;
  String? MenuDashboard;
  String? RenewalDashboardPermission;
  String? NewleadDashboardPermission;
  String? assignWork;
  String? viewWorkReport;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  LeadDashboardModel? leadDashboard;
  CommonConfigureModel? configure;
  DashboardModel? userDashboard;
  WorkStatus? existingWork;
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
  String? firebaseToken;
  String? adminCheckPermission;
  var fromdate = DateTime.now();
  var todate = DateTime.now();
  var fromdate1 =
      DateTime(DateTime.now().year, DateTime.now().month, 1).toString();
  var todate1 = DateTime.now();
  var outputFormat = DateFormat('dd-MM-yyyy');
  String name = '';
  String role = '';
  String callLogPermission = '';
  int id = 0;
  String createLeadPermission = '';
  String viewLeadPermission = '';
  String viewAllWorkPermission = '';
  String viewTargetReportPermission = '';
  String addWorkPermission = '';
  String startAndStopWorkPermission = '';
  //String adminCheckPermission = '';
  String multipleUsersCheck = '';
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
  String officialWhatsapp = '';
  String unOfficialWhatsapp = '';
  List<ProCount> projectCounts = [];
  String? _faceBase64;
  LeadProgressbarModel? object1;
  bool toggle = false;
  int notificationCount = 0;
  String? viewAttendanceForPayrollMenu;
  String? addAttendanceForAttendanceAll;

  bool isLoading = false;
  Map<String, dynamic> assignedStaffData = {
    'pending': [],
    'completed': [],
    'totalPending': 0,
    'totalCompleted': 0,
  };
  bool isAssignedDataLoading = false;

  List<DepartmentData> departmentsList = [];
  DepartmentData? selectedDepartment;
  List<DepartmentStaffData> staffList = [];
  DepartmentStaffData? selectedStaff;
  final DepartmentStaffData unassignedStaff =
      DepartmentStaffData(userId: "0", staffName: "Unassigned");
  bool isDepartmentsLoading = false;
  bool isStaffLoading = false;

  Future<void> fetchDepartments() async {
    if (mounted) setState(() => isDepartmentsLoading = true);
    final res = await HttpService.getDepartments();
    if (mounted) {
      setState(() {
        isDepartmentsLoading = false;
        if (res != null && res.status) {
          departmentsList = res.data;
        } else {
          departmentsList = [];
        }
      });
    }
  }

  Future<void> fetchStaff([String departmentId = ""]) async {
    if (mounted) setState(() => isStaffLoading = true);
    final res = await HttpService.getStaffByDepartment(departmentId);
    if (mounted) {
      setState(() {
        isStaffLoading = false;
        if (res != null && res.status) {
          staffList = res.data;
        } else {
          staffList = [];
        }
      });
    }
  }

  Future<void> onDepartmentChanged(DepartmentData? department) async {
    setState(() {
      selectedDepartment = department;
      selectedStaff = null;
    });
    // Always fetch staff: pass department id or empty string for all staff
    await fetchStaff(department?.id ?? "");
    await _refetchFilteredData();
  }

  void onStaffChanged(DepartmentStaffData? staff) {
    setState(() {
      selectedStaff = staff;
    });
    _refetchFilteredData();
  }

  Future<void> _refetchFilteredData() async {
    await dashboardCounts();
    await loadAssignedData();
  }

  @override
  void initState() {
    super.initState();
    loadPrefs();
    loginorNot();
    fetchDepartments();
    fetchStaff("");
    dashboardCounts();

    _loadWorkStatus();
    loadAssignedData();

    // Consume pending deep links if any
    WidgetsBinding.instance.addPostFrameCallback((_) {
      deepLinkHandler.getPendingDeepLink().then((data) {
        if (data != null && mounted) {
          log('[DEEPLINK] ProjectDashboard: Consuming pending deep link: $data');
          deepLinkHandler.validateAndNavigate(context, data);
        }
      });
    });
  }

  // Refresh method for pull-to-refresh
  Future<void> _refreshDashboard() async {
    await fetchDepartments();
    await fetchStaff(selectedDepartment?.id ?? "");
    await loginorNot();
    await dashboardCounts();
    await checkExistingWorkStatus();
    await loadAssignedData();
    _loadWorkStatus();
  }

  Future<void> loadAssignedData() async {
    if (mounted) {
      setState(() {
        isAssignedDataLoading = true;
      });
    }

    try {
      final httpService = HttpService();
      // Don't send staffId=0 (Unassigned) to API — it's a UI-only filter
      final bool isUnassignedSelected = selectedStaff?.userId == "0" ||
          selectedStaff?.staffName.toLowerCase() == "unassigned";
      final worksCountModel = await httpService.getCountsWorks(
        departmentId: selectedDepartment?.id,
        staffId: (selectedStaff != null && !isUnassignedSelected)
            ? selectedStaff!.userId
            : null,
      );

      if (worksCountModel != null && worksCountModel.status) {
        if (mounted) {
          setState(() {
            assignedStaffData = {
              'pending': worksCountModel.data.pending.staffList.map((staff) {
                return {
                  'staff_id': staff.staffId,
                  'staff_name': staff.staffName,
                  'task_count': staff.taskCount,
                  'work_count': staff.workCount,
                  'name': staff.staffName,
                  'count': int.tryParse(staff.taskCount) ?? 0,
                };
              }).toList(),
              'completed':
                  worksCountModel.data.completedToday.staffList.map((staff) {
                return {
                  'staff_id': staff.staffId,
                  'staff_name': staff.staffName,
                  'task_count': staff.taskCount,
                  'work_count': staff.workCount,
                  'name': staff.staffName,
                  'count': int.tryParse(staff.taskCount) ?? 0,
                };
              }).toList(),
              'totalPending': worksCountModel.data.pending.taskCount,
              'totalCompleted': worksCountModel.data.completedToday.taskCount,
              'pendingWorks': worksCountModel.data.pending.workCount,
              'completedWorks': worksCountModel.data.completedToday.workCount,
            };
            isAssignedDataLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            assignedStaffData = {
              'pending': [],
              'completed': [],
              'totalPending': 0,
              'totalCompleted': 0,
              'pendingWorks': 0,
              'completedWorks': 0,
            };
            isAssignedDataLoading = false;
          });
        }
      }
    } catch (e) {
      log("Error fetching assigned staff data: $e");
      if (mounted) {
        setState(() {
          assignedStaffData = {
            'pending': [],
            'completed': [],
            'totalPending': 0,
            'totalCompleted': 0,
            'pendingWorks': 0,
            'completedWorks': 0,
          };
          isAssignedDataLoading = false;
        });
      }
    }
  }

  Future<void> checkExistingWorkStatus() async {
    final workStatusModel = await HttpService.getWorkStatus();
    setState(() {
      if (workStatusModel != null && workStatusModel.data.isNotEmpty) {
        existingWork = workStatusModel.data.first;
      } else {
        existingWork = null;
      }
    });
  }

  Future<void> loadPrefs() async {
    final value = await Common.getSharedPref("multipleWorks");
    userId = await Common.getSharedPref("userId");
    token = await Common.getSharedPref("token");
      viewWorkReport = await Common.getSharedPref("viewWorkReport");
    ProjectDashboardPermission =
        await Common.getSharedPref("ProjectDashboardPermission");
    AccountsDashboardPermission =
        await Common.getSharedPref("AccountsDashboardPermission");
    MenuDashboard = await Common.getSharedPref("MenuDashboard");
    RenewalDashboardPermission =
        await Common.getSharedPref("RenewalDashboardPermission");
    NewleadDashboardPermission =
        await Common.getSharedPref("NewleadDashboardPermission");
    adminCheckPermission = await Common.getSharedPref("adminCheckPermission");

    viewAttendanceForPayrollMenu =
      await Common.getSharedPref("viewAttendanceForPayrollMenu");

    addAttendanceForAttendanceAll =
        await Common.getSharedPref("addAttendanceForAttendanceAll");
    setState(() {
      multipleWorksCheck = value ?? '';
    });
    getData(token, fromdate, todate);
  }

  Future<Map<String, dynamic>> getAssignedStaffData() async {
    try {
      final token = await Common.getSharedPref("token");
      return {
        'pending': [
          {'name': 'Sarath', 'count': 3, 'staffId': '101'},
          {'name': 'aNJU', 'count': 5, 'staffId': '102'},
          {'name': 'sKAYY', 'count': 2, 'staffId': '103'},
          {'name': 'sKAYY', 'count': 2, 'staffId': '103'},
          {'name': 'sKAYY', 'count': 2, 'staffId': '103'},
          {'name': 'sKAYY', 'count': 2, 'staffId': '103'},
        ],
        'completed': [
          {'name': 'Sarath', 'count': 8, 'staffId': '101'},
          {'name': 'aNJU', 'count': 12, 'staffId': '102'},
          {'name': 'Skayy', 'count': 6, 'staffId': '104'},
        ],
        'totalPending': 10,
        'totalCompleted': 26,
      };
    } catch (e) {
      log("Error fetching assigned staff data: $e");
      return {
        'pending': [],
        'completed': [],
        'totalPending': 0,
        'totalCompleted': 0,
      };
    }
  }

  void _loadWorkStatus() async {
    String? status = await Common.getSharedPref("is_work_started");
    assignWork = await Common.getSharedPref("assignWork");
    setState(() {
      isWorkStarted = status == "true";
    });
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
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

      if (dismissedDate != today && startAndStopWorkPermission == "true") {
        loginOrNot = await HttpService.getLoginorNot(token);
        if (loginOrNot?.data != true && startAndStopWorkPermission == "true") {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              showLoginPrompt(context);
            }
          });
        }
      }

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
      accessCallRecordingPermission =
          await Common.getSharedPref("accessCallRecordingPermission");
      visibleP = await Common.getSharedPref("isVisible");

      isVisible = visibleP == 'true' ? false : false;

      updateLeadPermission1 = updateLeadPermission == 'true';
      deleteLeadPermission1 = deleteLeadPermission == 'true';
      cloudCallPermission1 = cloudCallPermission == 'true';
      createLeadCategory1 = createLeadCategory == 'true';
      updateLeadCategory1 = updateLeadCategory == 'true';
      deleteLeadCategory1 = deleteLeadCategory == 'true';
      accessCallRecordingPermission1 = accessCallRecordingPermission == 'true';

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

      setState(() {
        timeOut = false;
      });
    } catch (e) {
      log("error: $e");
      setState(() {
        timeOut = true;
      });
    }
  }

  Future<void> dashboardCounts() async {
    final token = await Common.getSharedPref("token");
    // Don't send staffId when Unassigned (userId=0) is selected — it's a UI filter only
    final bool isUnassignedSelected = selectedStaff?.userId == "0" ||
        selectedStaff?.staffName.toLowerCase() == "unassigned";
    final response = await HttpService.dashboardCounts(
      token: token,
      departmentId: selectedDepartment?.id,
      staffId: (selectedStaff != null && !isUnassignedSelected)
          ? selectedStaff!.userId
          : null,
    );

    if (response != null && response.status == true) {
      if (mounted) {
        setState(() {
          isLoggedIn = true;
          projectCounts = response.data;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          isLoggedIn = false;
        });
      }
    }
  }

  Future<void> loginorNot() async {
    final token = await Common.getSharedPref("token");
    final response = await HttpService.getLoginorNot(token);

    setState(() {
      if (response != null && response.data == true) {
        isLoggedIn = true;
      } else {
        isLoggedIn = false;
      }
    });
  }

  // void showLoginPrompt(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext dialogContext) {
  //       return AlertDialog(
  //         title: const Text("Not logged in today"),
  //         content: const Text("Do you want to log in now?"),
  //         actions: [
  //           TextButton(
  //             child: const Text("Not now"),
  //             onPressed: () async {
  //               final prefs = await SharedPreferences.getInstance();
  //               final today = DateTime.now().toIso8601String().substring(0, 10);
  //               await prefs.setString('loginPromptDismissedDate', today);
  //               Navigator.of(dialogContext).pop();
  //             },
  //           ),
  //           ElevatedButton(
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: Colors.green,
  //             ),
  //             child: const Text("Yes"),
  //             onPressed: () async {
  //               Navigator.of(dialogContext).pop();
  //               showDialog(
  //                 context: context,
  //                 barrierDismissible: false,
  //                 builder: (_) => const AlertDialog(
  //                   content: Row(
  //                     children: [
  //                       CircularProgressIndicator(),
  //                       SizedBox(width: 16),
  //                       Text("Fetching Location..."),
  //                     ],
  //                   ),
  //                 ),
  //               );

  //               try {
  //                 LocationPermission permission =
  //                     await Geolocator.checkPermission();
  //                 if (permission == LocationPermission.denied) {
  //                   permission = await Geolocator.requestPermission();
  //                   if (permission == LocationPermission.denied) {
  //                     Navigator.of(context).pop();
  //                     ScaffoldMessenger.of(context).showSnackBar(
  //                       const SnackBar(
  //                           content: Text("Location permission denied.")),
  //                     );
  //                     return;
  //                   }
  //                 }

  //                 if (permission == LocationPermission.deniedForever) {
  //                   Navigator.of(context).pop();
  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     const SnackBar(
  //                         content: Text(
  //                             "Location permission permanently denied. Please enable it from settings.")),
  //                   );
  //                   return;
  //                 }
  //                 final position = await Geolocator.getCurrentPosition(
  //                   desiredAccuracy: LocationAccuracy.high,
  //                 );

  //                 final now = DateTime.now();
  //                 final res = await HttpService.startWork(
  //                   now,
  //                   latitude: position.latitude,
  //                   longitude: position.longitude,
  //                   faceData: _faceBase64,
  //                 );

  //                 Navigator.of(context).pop();

  //                 if (res != null && res.status == true) {
  //                   if (!context.mounted) return;
  //                   Navigator.push(
  //                     context,
  //                     MaterialPageRoute(
  //                       builder: (_) => Dashboard(token),
  //                     ),
  //                   );
  //                 } else {
  //                   if (!context.mounted) return;
  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     const SnackBar(content: Text("Failed to start work.")),
  //                   );
  //                 }
  //               } catch (e) {
  //                 Navigator.of(context).pop();
  //                 if (!context.mounted) return;
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   SnackBar(content: Text("Location error: $e")),
  //                 );
  //               }
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
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
                      MaterialPageRoute(builder: (_) => ProjectDashboard()),
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

  // Replace your current build method with this updated version
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (ProjectDashboardPermission == "true") {
          await _exitApp(context);
          return false;
        } else {
          return true;
        }
      },
      child: DefaultTabController(
        initialIndex: renewalPermission == "true" ? 1 : 0,
        length: renewalPermission == "true" && accPermission == "true" ? 3 : 2,
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.blue.shade50,
          appBar: appBarWidget(context, "lead"),
          body: TabBarView(
            children: [
              RefreshIndicator(
                onRefresh: _refreshDashboard,
                color: Colors.blue,
                backgroundColor: Colors.white,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () async {
                                if (isLoggedIn == true) {
                                  final workStatusModel =
                                      await HttpService.getWorkStatus();
                                  WorkStatus? newExistingWork;

                                  if (workStatusModel != null &&
                                      workStatusModel.data.isNotEmpty) {
                                    newExistingWork =
                                        workStatusModel.data.first;
                                  }
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddWorkPage(
                                        workId: "",
                                        existingWork: newExistingWork,
                                        // isAssigned: 1,
                                        onSuccess: () {},
                                      ),
                                    ),
                                  );
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Login Required'),
                                        content: const Text(
                                            'Please login to add work.'),
                                        actions: [
                                          TextButton(
                                            child: const Text('OK'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              },
                              icon: const Icon(Icons.add),
                              label: const Text("Add"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shadowColor: Colors.black26,
                                elevation: 4,
                              ),
                            ),
                            //  const SizedBox(width: 2),
                            assignWork == "true"
                                ? ElevatedButton.icon(
                                    onPressed: () async {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AssignWorkPage(
                                            onSuccess: () {
                                              setState(() {
                                                checkExistingWorkStatus();
                                              });
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.add),
                                    label: const Text("Assign"),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      shadowColor: Colors.black26,
                                      elevation: 4,
                                      minimumSize: const Size(40, 40),
                                    ),
                                  )
                                : const SizedBox(width: 0),
                            const SizedBox(width: 10),
                            Visibility(
                              visible: workStatus != null &&
                                  workStatus!.data.isNotEmpty,
                              maintainSize: true,
                              maintainAnimation: true,
                              maintainState: true,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      blurRadius: 5,
                                      spreadRadius: 1,
                                      offset: const Offset(0, 2),
                                    )
                                  ],
                                  border: Border.all(
                                    color: Colors.red.shade100,
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.timer,
                                      size: 15,
                                      color: Colors.red.shade400,
                                    ),
                                    const SizedBox(width: 6),
                                    StreamBuilder<DateTime>(
                                      stream: Stream.periodic(
                                          const Duration(seconds: 1),
                                          (_) => DateTime.now()),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData ||
                                            createdAt == null) {
                                          return const SizedBox();
                                        }

                                        final now = snapshot.data!;
                                        final diff = now.difference(createdAt!);

                                        String timeSince =
                                            "${diff.inHours}h ${diff.inMinutes % 60}m ${diff.inSeconds % 60}s";

                                        return GestureDetector(
                                          onTap: () async {
                                            final workStatusModel =
                                                await HttpService
                                                    .getWorkStatus();

                                            WorkStatus? existingWork;
                                            if (workStatusModel != null &&
                                                workStatusModel
                                                    .data.isNotEmpty) {
                                              existingWork =
                                                  workStatusModel.data.first;
                                            }
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AddWorkPage(
                                                  workId: "",
                                                  existingWork: existingWork,
                                                   isAssigned: 1,
                                                  onSuccess: () {
                                                    setState(() {
                                                      getData(token, fromdate,
                                                          todate);
                                                    });
                                                  },
                                                ),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            timeSince,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.red.shade700,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildFilterSection(),
                        Wrap(
                          spacing: 29,
                          runSpacing: 12,
                          children: projectCounts.map((countData) {
                            Color bgColor;
                            switch (countData.label.toLowerCase()) {
                              case 'to do':
                                bgColor = Colors.purple.shade100;
                                break;
                              case 'pending':
                                bgColor = Colors.orange.shade100;
                                break;
                              case 'unassigned':
                                bgColor = Colors.green.shade100;
                                break;
                              case 'overdue':
                                bgColor = Colors.pink.shade100;
                                break;
                              default:
                                bgColor = Colors.grey.shade200;
                            }

                            final String labelLower =
                                countData.label.toLowerCase();

                            // Unassigned card is enabled when:
                            //   - All Staff is selected (null), OR
                            //   - "Unassigned" option is selected.
                            // Disabled ONLY when a specific real staff member is picked.
                            final bool isUnassignedOrAllSelected =
                                selectedStaff == null ||
                                selectedStaff?.userId == "0" ||
                                selectedStaff?.staffName.toLowerCase() ==
                                    "unassigned";
                            final bool isCardDisabled =
                                labelLower == 'unassigned' &&
                                    !isUnassignedOrAllSelected;

                            return IgnorePointer(
                              ignoring: isCardDisabled,
                              child: Opacity(
                                opacity: isCardDisabled ? 0.4 : 1.0,
                                child: GestureDetector(
                                  onTap: () {
                                    if (countData.staffWiseCounts.isNotEmpty) {
                                      _showStaffCountPopup(countData);
                                    } else {
                                      _navigateToStatusPage(countData.label,
                                          countData.id.toString());
                                    }
                                  },
                                  child: _buildStatusCard(
                                    countData.label,
                                    countData.count.toString(),
                                    bgColor,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        // Wrap(
                        //   spacing: 29,
                        //   runSpacing: 12,
                        //   children: projectCounts.map((countData) {
                        //     Color bgColor;
                        //     switch (countData.label.toLowerCase()) {
                        //       case 'to do':
                        //         bgColor = Colors.purple.shade100;
                        //         break;
                        //       case 'pending':
                        //         bgColor = Colors.orange.shade100;
                        //         break;
                        //       case 'Unassigned':
                        //         bgColor = Colors.green.shade100;
                        //         break;
                        //       case 'overdue':
                        //         bgColor = Colors.pink.shade100;
                        //         break;
                        //       default:
                        //         bgColor = Colors.grey.shade200;
                        //     }

                        //     return GestureDetector(
                        //       // onTap: () {
                        //       //   Navigator.push(
                        //       //     context,
                        //       //     MaterialPageRoute(
                        //       //       builder: (_) => AssignReport(
                        //       //         workId: "",
                        //       //         sectionId: countData.id.toString(),
                        //       //       ),
                        //       //     ),
                        //       //   );
                        //       // },
                        //       onTap: () {
                        //         Widget targetPage;

                        //         switch (countData.label.toLowerCase()) {
                        //           case 'to do':
                        //             targetPage = AssignReport(
                        //               workId: "",
                        //               sectionId: countData.id.toString(),
                        //               selectedStatus: 'todo',
                        //             );
                        //             break;
                        //           case 'pending':
                        //             targetPage = PendingWorkPage();
                        //             break;
                        //           case 'unassigned':
                        //             targetPage = AssignReport(
                        //               workId: "",
                        //               sectionId: countData.id.toString(),
                        //               selectedStatus: 'unassigned',
                        //             );
                        //             break;
                        //           case 'overdue':
                        //             targetPage = PendingWorkPage();
                        //             break;
                        //           default:
                        //             targetPage = AssignReport(
                        //               workId: "",
                        //               sectionId: countData.id.toString(),
                        //             );
                        //         }

                        //         Navigator.push(
                        //           context,
                        //           MaterialPageRoute(builder: (_) => targetPage),
                        //         );
                        //       },

                        //       child: _buildStatusCard(
                        //         countData.label,
                        //         countData.count.toString(),
                        //         bgColor,
                        //       ),
                        //     );
                        //   }).toList(),
                        // ),
                        const SizedBox(height: 24),
                        assignWork == "true"
                            ? _buildAssignedByMeSection()
                            : const SizedBox(),
                        const SizedBox(height: 16),
                        
                        // Recent Projects Section
                        if (projectList != null && projectList!.data.isNotEmpty) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Recent Projects",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const AddProjectPage(),
                                    ),
                                  );
                                },
                                child: const Row(
                                  children: [
                                    Text(
                                      'View More',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 12,
                                      color: Colors.blue,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: projectList!.data.length > 5 ? 5 : projectList!.data.length,
                            itemBuilder: (context, index) {
                              final project = projectList!.data[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                  border: Border.all(color: Colors.grey.shade100),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.blue.shade50,
                                    child: Icon(Icons.rocket_launch_rounded, color: Colors.blue.shade400, size: 20),
                                  ),
                                  title: Text(
                                    project.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "Project ID: ${project.id}",
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                        ],

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 12),
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade400,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  "Quick Links",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              GridView.count(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                childAspectRatio: 2.8,
                                children: [
                                  _buildQuickLinkCard(
                                    "Assigned Works",
                                    const Color.fromARGB(255, 204, 169, 236),
                                    () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => AssignReport(
                                                workId: "", sectionId: ""))),
                                  ),
                                  // _buildQuickLinkCard(
                                  //   "Pending Works",
                                  //   const Color.fromARGB(255, 241, 186, 223),
                                  //   () => Navigator.push(
                                  //       context,
                                  //       MaterialPageRoute(
                                  //           builder: (_) => AssignReport(
                                  //               workId: "",
                                  //               sectionId: "",
                                  //               selectedStatus: "pending"))),
                                  // ),
                                  _buildQuickLinkCard(
                                    "Pending Works",
                                    const Color.fromARGB(255, 241, 186, 223),
                                    () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => PendingWorkPageNew(
                                                workId: "",
                                                sectionId: "",
                                                selectedStatus: "pending",
                                                staffId: ""))),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              GridView.count(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                childAspectRatio: 2.8,
                                children: [
                                  _buildQuickLinkCard(
                                    "Work Summery All",
                                    Colors.cyan.shade100,
                                    
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const TotalSummeryPage(),
                                      ),
                                    ),
                                  ),
                                  _buildQuickLinkCard(
                                    "Staffwise Work",
                                    Colors.red.shade100,
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ViewCompanyWorkPage(),
                                      ),
                                    ),
                                  ),
                                  
                                  if (addAttendanceForAttendanceAll == "true")
                                    _buildQuickLinkCard(
                                      "Attendance All",
                                      Colors.purple.shade100,
                                      () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const ViewCalendarPage(),
                                        ),
                                      ),
                                    ),
                                    if (viewAttendanceForPayrollMenu == "true")
                                  _buildQuickLinkCard("Attendance Staffwise",
                                      Colors.amber.shade100, () async {
                                    _showStaffSelectionPopup(context);
                                  }),
                                  _buildQuickLinkCard(
                                    "Project",
                                    Colors.blue.shade100,
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const AddProjectPage(),
                                      ),
                                    ),
                                  ),
                                  if (viewAttendanceForPayrollMenu == "true")
                                  _buildQuickLinkCard(
                                    "Payroll",
                                    Colors.green.shade100,
                                    () => _showPayrollOptionsPopup(context),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          endDrawer: DraweScreen(token),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.black,
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => ProjectDashboard()),
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
                                      builder: (context) => RenewalDashboard()),
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
            child: Image.asset("assets/icons/menu.png", width: 25),
          ),
          bottomNavigationBar: configure != null
              ? BottomNavigation(
                  token,
                  phoneCallLogPermission: phoneCallLogPermission,
                  name: name,
                  userId: userId,
                )
              : const SizedBox(),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 6,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Department Dropdown
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Department",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade50,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<DepartmentData>(
                      isExpanded: true,
                      hint: const Text(
                        "All Departments",
                        style: TextStyle(fontSize: 13),
                      ),
                      value: selectedDepartment,
                      icon: isDepartmentsLoading
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.arrow_drop_down, size: 20),
                      items: [
                        const DropdownMenuItem<DepartmentData>(
                          value: null,
                          child: Text("All Departments",
                              style: TextStyle(fontSize: 13)),
                        ),
                        ...departmentsList.map((dept) {
                          return DropdownMenuItem<DepartmentData>(
                            value: dept,
                            child: Text(
                              dept.departmentName,
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }),
                      ],
                      onChanged: (dept) => onDepartmentChanged(dept),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Staff Dropdown
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Staff",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade50,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<DepartmentStaffData>(
                      isExpanded: true,
                      hint: const Text(
                        "All Staff",
                        style: TextStyle(fontSize: 13),
                      ),
                      value: selectedStaff,
                      icon: isStaffLoading
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.arrow_drop_down, size: 20),
                      items: [
                        const DropdownMenuItem<DepartmentStaffData>(
                          value: null,
                          child:
                              Text("All Staff", style: TextStyle(fontSize: 13)),
                        ),
                        DropdownMenuItem<DepartmentStaffData>(
                          value: unassignedStaff,
                          child: const Text(
                            "Unassigned",
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                        ...staffList
                            .where((staff) =>
                                staff.userId != "0" &&
                                staff.staffName.toLowerCase() != "unassigned")
                            .map((staff) {
                          return DropdownMenuItem<DepartmentStaffData>(
                            value: staff,
                            child: Text(
                              staff.staffName,
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }),
                      ],
                      onChanged: (staff) => onStaffChanged(staff),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String title, String count, Color color) {
    return Container(
      width: 150,
      height: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(count,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              const Icon(Icons.work_outline),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAssignedByMeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title OUTSIDE the container
        const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            "Assigned By Me",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),

        // White container
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isAssignedDataLoading)
                const SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child:
                          //  _buildStaffColumn(
                          //   title: "Pending Tasks",
                          //   count: assignedStaffData['totalPending']?.toString() ??
                          //       '0',
                          //   subtitles: "3 Works",
                          //   color: Colors.orange.shade100,
                          //   textColor: Colors.orange.shade800,
                          //   icon: Icons.pending_actions,
                          //   onTap: () => _showStaffDetailsDialog(
                          //     "Pending Tasks",
                          //     List<Map<String, dynamic>>.from(
                          //         assignedStaffData['pending'] ?? []),
                          //     const Color.fromARGB(255, 93, 185, 228),
                          //   ),
                          // ),
                          _buildStaffColumn(
                        title: "Pending Tasks",
                        count: assignedStaffData['totalPending']?.toString() ??
                            '0',
                        subtitles:
                            "${assignedStaffData['pendingWorks']?.toString() ?? '0'} Works",
                        color: Colors.orange.shade100,
                        textColor: Colors.orange.shade800,
                        icon: Icons.pending_actions,
                        onTap: () => _showStaffDetailsDialog(
                          "Pending Tasks",
                          List<Map<String, dynamic>>.from(
                              assignedStaffData['pending'] ?? []),
                          const Color.fromARGB(255, 93, 185, 228),
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 100,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      color: Colors.grey.shade300,
                    ),
                    Expanded(
                      child:
                          // _buildStaffColumn(
                          //   title: "Completed Today",
                          //   count:
                          //       assignedStaffData['totalCompleted']?.toString() ??
                          //           '0',
                          //   subtitles: "3 Works",
                          //   color: Colors.green.shade100,
                          //   textColor: Colors.green.shade800,
                          //   icon: Icons.check_circle_outline,
                          //   onTap: () => _showStaffDetailsDialog(
                          //     "Completed Tasks",
                          //     List<Map<String, dynamic>>.from(
                          //         assignedStaffData['completed'] ?? []),
                          //     Colors.green,
                          //   ),
                          // ),
                          _buildStaffColumn(
                        title: "Completed Today",
                        count:
                            assignedStaffData['totalCompleted']?.toString() ??
                                '0',
                        subtitles:
                            "${assignedStaffData['completedWorks']?.toString() ?? '0'} Works",
                        color: Colors.green.shade100,
                        textColor: Colors.green.shade800,
                        icon: Icons.check_circle_outline,
                        onTap: () => _showStaffDetailsDialog(
                          "Completed Tasks",
                          List<Map<String, dynamic>>.from(
                              assignedStaffData['completed'] ?? []),
                          Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStaffColumn({
    required String title,
    required String count,
    required String subtitles,
    required Color color,
    required Color textColor,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: textColor),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Task Count
            Text(
              count,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),

            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  subtitles,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showStaffSelectionPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const StaffSelectionSheet();
      },
    );
  }

  void _showStaffCountPopup(ProCount countData) {
    Color getStatusColor() {
      switch (countData.label.toLowerCase()) {
        case 'to do':
          return Colors.blue;
        case 'pending':
          return Colors.orange;
        case 'unassigned':
          return Colors.green;
        case 'overdue':
          return const Color.fromARGB(255, 248, 16, 16);
        default:
          return Colors.blue;
      }
    }

    final primaryColor = getStatusColor();
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      countData.label,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (countData.staffWiseCounts.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    alignment: Alignment.center,
                    child: Text(
                      "No staff found",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                else
                  Container(
                    constraints: const BoxConstraints(maxHeight: 300),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: countData.staffWiseCounts.length,
                      itemBuilder: (context, index) {
                        final staff = countData.staffWiseCounts[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            _navigateToStatusPageWithStaff(
                              countData.label,
                              countData.id.toString(),
                              staff.staffId,
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: primaryColor.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        staff.staffName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    staff.count.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToStatusPage(
                      countData.label,
                      countData.id.toString(),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: primaryColor.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total ${countData.label} Tasks",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                            fontSize: 14,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            countData.count.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToStatusPage(String status, String sectionId) {
    switch (status.toLowerCase()) {
      case 'to do':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AssignReport(
              workId: "",
              sectionId: sectionId,
              selectedStatus: 'todo',
              assignedToMyself: '1',
            ),
          ),
        );
        break;
      case 'pending':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PendingWorkPageNew(
              workId: "",
              sectionId: sectionId,
              selectedStatus: 'pending',
              staffId: '',
              assignedByMyself: "1",
            ),
          ),
        );
        break;
      case 'unassigned':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AssignReport(
              workId: "",
              sectionId: sectionId,
              selectedStatus: 'unassigned',
              assignedToMyself: '1',
              isUnassigned: '1',
            ),
          ),
        );
        break;
      case 'overdue':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PendingWorkPageNew(
              workId: "",
              sectionId: sectionId,
              selectedStatus: 'pending',
              staffId: '',
              assignedByMyself: "1",
            ),
          ),
        );
        break;
      default:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AssignReport(
              workId: "",
              sectionId: sectionId,
              assignedToMyself: '1',
            ),
          ),
        );
    }
  }

  void _navigateToStatusPageWithStaff(
      String status, String sectionId, String staffId) {
    switch (status.toLowerCase()) {
      case 'to do':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AssignReport(
              workId: "",
              sectionId: sectionId,
              selectedStatus: 'todo',
              staffId: staffId,
              assignedToMyself: '1',
            ),
          ),
        );
        break;
      case 'pending':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PendingWorkPageNew(
              workId: "",
              sectionId: sectionId,
              selectedStatus: 'todo,pending,in-progress',
              staffId: staffId,
              assignedToMyself: '1',
            ),
          ),
        );
        break;
      case 'unassigned':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AssignReport(
              workId: "",
              sectionId: sectionId,
              selectedStatus: 'unassigned',
              staffId: staffId,
              assignedToMyself: '1',
              isUnassigned: '1',
            ),
          ),
        );
        break;
      case 'overdue':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PendingWorkPageNew(
              workId: "",
              sectionId: sectionId,
              selectedStatus: 'todo,pending,in-progress',
              staffId: staffId,
              assignedToMyself: '1',
              isOverdue: '1',
            ),
          ),
        );
        break;
      default:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AssignReport(
              workId: "",
              sectionId: sectionId,
              staffId: staffId,
              assignedToMyself: '1',
            ),
          ),
        );
    }
  }

  void _showStaffDetailsDialog(
    String title,
    List<Map<String, dynamic>> staffList,
    Color primaryColor,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: GestureDetector(
            onTap: () {
              title == "Pending Tasks"
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PendingWorkPageNew(
                          workId: "",
                          sectionId: "",
                          staffId: "",
                          assignedByMyself: "1",
                        ),
                      ),
                    )
                  : Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CompletedWorkPageNew(
                          workId: "",
                          sectionId: "",
                          staffId: "",
                          assignedByMyself: "1",
                        ),
                      ),
                    );
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (staffList.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      alignment: Alignment.center,
                      child: Text(
                        "No staff found",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  else
                    Container(
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: staffList.length,
                        itemBuilder: (context, index) {
                          final staff = staffList[index];
                          return GestureDetector(
                            onTap: () {
                              title == "Completed Tasks"
                                  ? Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CompletedWorkPageNew(
                                          workId: "",
                                          sectionId: "",
                                          staffId: staff['staff_id'],
                                          assignedToMyself: "",
                                          assignedByMyself: "1",
                                        ),
                                      ),
                                    )
                                  : Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PendingWorkPageNew(
                                          workId: "",
                                          sectionId: "",
                                          staffId: staff['staff_id'],
                                          assignedToMyself: "",
                                          assignedByMyself: "1",
                                        ),
                                      ),
                                    );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: primaryColor.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          staff['name']?.toString() ?? 'N/A',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        if (staff['role'] != null)
                                          Text(
                                            staff['role'].toString(),
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: primaryColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      staff['count']?.toString() ?? '0',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total ${title.split(' ').first} Tasks",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                        Text(
                          staffList
                              .fold<int>(
                                  0,
                                  (sum, staff) =>
                                      sum +
                                      ((staff['count'] as num?)?.toInt() ?? 0))
                              .toString(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget appBarWidget(BuildContext context, String type) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: Container(
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
                    ),
                  ),
                  const SizedBox(width: 15),
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
                      const SizedBox(height: 2),
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
                      // StartStopToggle(
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
                                  loading; // This changes the dashboard loader state
                            });
                          },
                        )
                      : const SizedBox(),
                  const SizedBox(width: 20),
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
                                token,
                                createLeadCategory1,
                                updateLeadCategory1,
                                deleteLeadCategory1)),
                      ).then((r) {
                        getData(token, fromdate, todate);
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
      ),
    );
  }

  Widget _buildQuickLinkCard(String title, Color color, VoidCallback onTap) {
    IconData getIcon() {
      switch (title) {
        case 'Assigned Works':
          return Icons.assignment_turned_in_outlined;
        case 'Pending Works':
          return Icons.pending_actions;
        case 'Work Summery All':
          return Icons.work;
        case 'Staffwise Work':
          return Icons.work_history;
        case 'Attendance All':
          return Icons.present_to_all;
        case 'Attendance Staffwise':
          return Icons.present_to_all_sharp;
        case 'Project':
          return Icons.analytics_outlined;
        case 'Payroll':
          return Icons.payment_rounded;
        case 'Settings':
          return Icons.settings_outlined;
        case 'Chat':
          return Icons.chat_bubble_outline;
        case 'Notifications':
          return Icons.notifications_outlined;
        case 'Calendar':
          return Icons.calendar_today_outlined;
        case 'Tasks':
          return Icons.task_outlined;
        case 'Projects':
          return Icons.work_outline;
        case 'Team':
          return Icons.groups_outlined;
        case 'Files':
          return Icons.folder_open_outlined;
        case 'Profile':
          return Icons.person_outline;
        case 'Logout':
          return Icons.logout_outlined;
        case 'Help':
          return Icons.help_outline;
        default:
          return Icons.description_outlined; // Default icon
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Icon(getIcon()),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 13),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14),
          ],
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

  void _showPayrollOptionsPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    const Center(
                      child: Text(
                        "Payroll Options",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  builder: (context, double value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      _buildOptionCard(
                        icon: Icons.receipt_long,
                        iconColor: Colors.blue,
                        title: "Salary Report",
                        subtitle: "View your salary details and history",
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SalaryReportPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildOptionCard(
                        icon: Icons.calendar_month,
                        iconColor: Colors.green,
                        title: "Leave Request",
                        subtitle: "Apply for leave or check status",
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
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
  }

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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StaffSelectionSheet extends StatefulWidget {
  const StaffSelectionSheet({super.key});

  @override
  State<StaffSelectionSheet> createState() => _StaffSelectionSheetState();
}

class _StaffSelectionSheetState extends State<StaffSelectionSheet> {
  late Future<AttendanceStaffwiseModel?> _staffFuture;
  final TextEditingController _searchController = TextEditingController();
  List<Staff> _allStaff = [];
  List<Staff> _filteredStaff = [];
  int _totalWorkingDays = 0;

  @override
  void initState() {
    super.initState();
    _staffFuture = HttpService().getStaffwiseWorkedDays();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterStaff(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredStaff = List.from(_allStaff);
      });
    } else {
      final filtered = _allStaff.where((staff) {
        final staffName = staff.staffName?.toLowerCase() ?? '';
        final searchQuery = query.toLowerCase();
        return staffName.contains(searchQuery);
      }).toList();

      setState(() {
        _filteredStaff = filtered;
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _filterStaff('');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: FutureBuilder<AttendanceStaffwiseModel?>(
        future: _staffFuture,
        builder: (context, snapshot) {
          // Handle loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Handle error state
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            );
          }

          // Handle empty data state
          if (!snapshot.hasData ||
              snapshot.data!.data.isEmpty ||
              snapshot.data!.data.first.staffList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people_outline,
                      color: Colors.grey, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'No attendance data available',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          if (_allStaff.isEmpty) {
            final attendanceData = snapshot.data!;
            _totalWorkingDays = attendanceData.data.first.totalWorkingDays ?? 0;
            _allStaff = attendanceData.data.first.staffList;
            _filteredStaff = List.from(_allStaff);
          }

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.people, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Attendance",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            "Total Work Days ($_totalWorkingDays)",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  autofocus: false,
                  decoration: InputDecoration(
                    hintText: 'Search staff by name...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _clearSearch,
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    _filterStaff(value);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Staff List',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      '${_filteredStaff.length} staff found',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Staff List
              Expanded(
                child: _filteredStaff.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off,
                                color: Colors.grey, size: 48),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isEmpty
                                  ? 'No staff available'
                                  : 'No staff found for "${_searchController.text}"',
                              style: const TextStyle(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 20),
                        itemCount: _filteredStaff.length,
                        itemBuilder: (context, index) {
                          final staff = _filteredStaff[index];
                          final staffName = staff.staffName ?? 'Unknown';
                          final workedDays = staff.workedDays ?? 0;

                          Color textColor = Colors.green;
                          String workedDaysText = workedDays.toString();

                          if (workedDays >= (_totalWorkingDays * 0.8)) {
                            textColor = Colors.green;
                          } else if (workedDays >= (_totalWorkingDays * 0.5)) {
                            textColor = Colors.orange;
                          } else {
                            textColor = Colors.red;
                          }

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              child: Text(
                                staffName.isNotEmpty
                                    ? staffName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              staffName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: textColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: textColor.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    workedDaysText,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.chevron_right,
                                    color: Colors.grey),
                              ],
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StaffCalendarPage(
                                    staffId: staff.staffId ?? '',
                                    selectedDate: DateTime.now(),
                                    staffName: staffName,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

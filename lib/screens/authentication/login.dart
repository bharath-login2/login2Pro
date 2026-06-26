import 'dart:developer';
import 'dart:io';
import 'dart:math' hide log;
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:device_marketing_names/device_marketing_names.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:login2/hive/call_logs/call_logs_hive_functions.dart';
import 'package:login2/main.dart';
import 'package:login2/models/userPermissionModel.dart';
import 'package:login2/screens/accounts/dashboard/accounts_dashboard.dart';
import 'package:login2/screens/accounts/renewal_mannagement/renewal_dashboard.dart';
import 'package:login2/screens/authentication/forgot_password.dart';
import 'package:login2/screens/homePage.dart';
import 'package:login2/screens/leadManagement/dashboardLeadsNewUpdated2.dart';
import 'package:login2/screens/leadManagement/projectDashboard.dart';
import 'package:login2/screens/leadManagement/quotationDashboard.dart';
import 'package:login2/service/backgroundService.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';
import '../../core/common.dart';
import '../../models/loginModel.dart';
import '../../models/updateModel.dart';
import '../../service/service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../widgets/size_config.dart';
import 'package:google_fonts/google_fonts.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late AnimationController _floatController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatAnimation;

  static const Color primaryBlue = Color(0xFF1E88E5);
  static const Color lightBlue = Color(0xFF90CAF9);
  static const Color gradientStart = Color(0xFF2196F3);
  static const Color gradientEnd = Color(0xFF1976D2);

  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  String? firebaseToken;

  bool _loading = false;
  bool timeOut = false;
  bool obSecure = true;
  bool? result = true;
  UpdateModel? updatedata;
  bool serverChoose = false;
  String selectedUrl = "";
  final MethodChannel _channel =
      const MethodChannel('onreBootInitFunctionChannel');
  final GlobalKey popupMenuKey = GlobalKey();
  File? _faceImageFile;
  String? _faceBase64;
  bool _notificationAsked = false;

  Future<void> askNotificationPermissionSafe() async {
    // if (!Platform.isAndroid) return;

    // final androidInfo = await DeviceInfoPlugin().androidInfo;
    // if (androidInfo.version.sdkInt < 33) return; // Android 13+

    // final status = await Permission.notification.status;

    // if (!status.isGranted) {
    //   final result = await Permission.notification.request();

    //   if (result.isPermanentlyDenied) {
    //     openAppSettings();
    //   }
    // }
  }

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

  // Future<Map<String, String>> getDeviceInfo() async {
  //   String deviceName = '';
  //   String platform = '';
  //   String osVersion = '';

  //   try {
  //     if (Platform.isAndroid) {
  //       final androidInfo = await DeviceInfoPlugin().androidInfo;
  //       deviceName = androidInfo.model ?? 'Unknown';
  //       platform = 'Android';
  //       osVersion = androidInfo.version.release ?? 'Unknown';
  //     } else if (Platform.isIOS) {
  //       final iosInfo = await DeviceInfoPlugin().iosInfo;
  //       deviceName = iosInfo.utsname.machine ?? iosInfo.model ?? 'Unknown';
  //       platform = 'iOS';
  //       osVersion = iosInfo.systemVersion ?? 'Unknown';
  //     }
  //   } catch (e) {
  //     log('Error getting device info: $e');
  //   }

  //   return {
  //     'deviceName': deviceName,
  //     'platform': platform,
  //     'osVersion': osVersion,
  //   };
  // }

  handleAsync() async {
    try {
      // await FirebaseMessaging.instance.requestPermission(
      //   alert: true,
      //   announcement: false,
      //   badge: true,
      //   carPlay: false,
      //   criticalAlert: false,
      //   provisional: false,
      //   sound: true,
      // );
      firebaseToken = await FirebaseMessaging.instance.getToken();
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
  //     setState(() {
  //       if (updatedata!.data!.server!.length == 1) {
  //         Common.saveSharedPref(
  //             "url", updatedata!.data!.server![0].url.toString());
  //         serverChoose = true;
  //       }
  //     });
  //   } catch (e) {
  //     setState(() {
  //       timeOut = true;
  //       _loading = false;
  //     });
  //   }
  // }
  getData() async {
    setState(() {
      timeOut = false;
    });
    try {
      final connectivityResult = await (Connectivity().checkConnectivity());
      // if (connectivityResult == ConnectivityResult.mobile ||
      //     connectivityResult == ConnectivityResult.wifi) {
      //   result = true;
      // } else {
      //   result = false;
      // }
      if (connectivityResult is List<ConnectivityResult>) {
        if (connectivityResult.contains(ConnectivityResult.mobile) ||
            connectivityResult.contains(ConnectivityResult.wifi)) {
          result = true;
        }
      } else {
        setState(() {
          result = false;
        });
      }
      updatedata = await HttpService.forceUpdate();
      String? savedUrl = await Common.getSharedPref("url");
      // setState(() {
      //   if (updatedata!.data!.server!.length == 1) {
      //     Common.saveSharedPref(
      //         "url", updatedata!.data!.server![0].url.toString());
      //     selectedUrl = updatedata!.data!.server![0].url.toString();
      //     serverChoose = true;
      //   } else if (savedUrl != null && savedUrl.isNotEmpty) {
      //     selectedUrl = savedUrl;
      //     serverChoose = true;
      //   } else {
      //     serverChoose = false;
      //   }
      // });
      setState(() {
        selectedUrl = updatedata!.data!.server![0].url.toString();

        Common.saveSharedPref(
          "url",
          selectedUrl,
        );

        serverChoose = true;
      });
    } catch (e) {
      setState(() {
        timeOut = true;
        _loading = false;
      });
    }
  }

// Future<void> captureFace() async {
//   var status = await Permission.camera.request();
// if (!status.isGranted) {
//   Common.toastMessaage('Camera permission denied.', Colors.red);
//   return;
// }
//   final cameras = await availableCameras();
//   final frontCamera = cameras.firstWhere(
//     (camera) => camera.lensDirection == CameraLensDirection.front,
//   );

//   final faceImage = await Navigator.of(context).push<File>(
//     MaterialPageRoute(
//       builder: (context) => Scaffold(
//         backgroundColor: Colors.black,
//         body: FaceDetectionCamera(
//           onFaceCaptured: (File imageFile) {
//             Navigator.of(context).pop(imageFile);
//           },
//         ),
//       ),
//     ),
//   );

//   if (faceImage != null) {
//     final faceDetector = FaceDetector(options: FaceDetectorOptions());
//     final inputImage = InputImage.fromFilePath(faceImage.path);
//     final faces = await faceDetector.processImage(inputImage);

//     if (faces.isNotEmpty) {
//       _faceImageFile = faceImage;
//       final bytes = await _faceImageFile!.readAsBytes();
//       _faceBase64 = base64Encode(bytes);
//       setState(() {});
//     } else {
//       Common.toastMessaage('No face detected. Please try again.', Colors.red);
//     }
//     faceDetector.close();
//   } else {
//     Common.toastMessaage('No image captured', Colors.red);
//   }
// }

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

  //   // Serialize key landmarks
  //   final serialized = [
  //     landmarks[FaceLandmarkType.leftEye]?.position,
  //     landmarks[FaceLandmarkType.rightEye]?.position,
  //     landmarks[FaceLandmarkType.noseBase]?.position,
  //     landmarks[FaceLandmarkType.leftCheek]?.position,
  //     landmarks[FaceLandmarkType.rightCheek]?.position,
  //   ].map((p) => p != null ? '${p.x.round()},${p.y.round()}' : '0,0').join(';');

  //   // Add lip contours (optional but increases uniqueness)
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

  login() async {
    try {
      final connectivityResult = await (Connectivity().checkConnectivity());
      // if (connectivityResult == ConnectivityResult.mobile ||
      //     connectivityResult == ConnectivityResult.wifi) {
      if (connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi)) {
        if (username.text.isEmpty) {
          Common.premiumToast(
            context,
            'Username cannot be empty',
            Icons.person_outline_rounded,
            color: Colors.orange,
          );
        } else if (password.text.isEmpty) {
          Common.premiumToast(
            context,
            'Password cannot be empty',
            Icons.lock_outline_rounded,
            color: Colors.orange,
          );
        // } else if (serverChoose == false) {
        //   Common.premiumToast(
        //     context,
        //     updatedata!.data!.server!.length > 1
        //         ? 'Please select a server'
        //         : 'Server configuration error',
        //     Icons.dns_outlined,
        //     color: Colors.red,
        //   );
        //   if (updatedata!.data!.server!.length > 1) {
        //     openPopupMenu();
        //   }
        } else {
          setState(() {
            _loading = true;
          });

          //      await captureFace();
          // if (_faceBase64 == null || _faceBase64!.isEmpty) {
          //   Common.toastMessaage('Face capture required for login', Colors.red);
          //   return;
          // }
          final deviceInfo = await getDeviceInfo();
          LoginModel? object = await HttpService.login(
            username.text,
            password.text,
            firebaseToken!,
            _faceBase64,
            deviceName: deviceInfo['deviceName'],
            platform: deviceInfo['platform'],
            osVersion: deviceInfo['osVersion'],
            mobileName: deviceInfo['mobileName'],
          );
          if (object!.status == true) {
            Common.saveSharedPref(
                "accountName", object.data!.accountName.toString());
            Common.saveSharedPref(
                "accountId", object.data!.accountId.toString());
            UserPermissionModel? object1 =
                await HttpService.userPermissionCheck(object.data!.token);
            if (object1 != null &&
                object1.status == true &&
                object1.data != null) {
              Common.saveSharedPref("isVisible", 'true');
              Common.saveSharedPref(
                  "accPermission", object1.data!.readAccount.toString());
              Common.saveSharedPref(
                  "renewalPermission", object1.data!.readRenewal.toString());
              Common.saveSharedPref(
                  "createLeadPermission", object1.data!.createLead.toString());
              Common.saveSharedPref(
                  "viewLeadPermission", object1.data!.viewLead.toString());
              Common.saveSharedPref(
                  "addWorkPermission", object1.data!.addWorks.toString());
              Common.saveSharedPref("viewAllWorkPermission",
                  object1.data!.viewAllWorks.toString());
              Common.saveSharedPref("viewWorkReportPermission",
                  object1.data!.viewWorkReport.toString());
              Common.saveSharedPref("startAndStopWorkPermission",
                  object1.data!.startAndStopWork.toString());
              Common.saveSharedPref(
                  "adminCheckPermission", object1.data!.adminCheck.toString());
              Common.saveSharedPref(
                  "multipleUsers", object1.data!.multipleUsers.toString());
              Common.saveSharedPref(
                  "multipleWorks", object1.data!.multipleWorks.toString());
              Common.saveSharedPref("hasPhonecallAccess",
                  object1.data!.hasPhonecallAccess.toString());
              Common.saveSharedPref(
                  "updateLeadPermission", object1.data!.updateLead.toString());
              Common.saveSharedPref(
                  "deleteLeadPermission", object1.data!.deleteLead.toString());
              Common.saveSharedPref("phoneCallLogPermission",
                  object1.data!.phoneCallLog.toString());
              Common.saveSharedPref("accessCallHistoryPermission",
                  object1.data!.accessCallHistory.toString());
              Common.saveSharedPref("viewLeadCategoryPermission",
                  object1.data!.viewLeadCategory.toString());
              Common.saveSharedPref(
                  "cloudCallPermission", object1.data!.cloudCall.toString());
              Common.saveSharedPref("createLeadCategory",
                  object1.data!.createLeadCategory.toString());
              Common.saveSharedPref("updateLeadCategory",
                  object1.data!.updateLeadCategory.toString());
              Common.saveSharedPref("deleteLeadCategory",
                  object1.data!.deleteLeadCategory.toString());
              Common.saveSharedPref("accessCallRecordingPermission",
                  object1.data!.accessCallRecording.toString());
              Common.saveSharedPref("createStaffPermission",
                  object1.data!.createStaff.toString());
              Common.saveSharedPref(
                  "viewStaffPermission", object1.data!.viewStaff.toString());
              Common.saveSharedPref("updateStaffPermission",
                  object1.data!.updateStaff.toString());
              Common.saveSharedPref("deleteStaffPermission",
                  object1.data!.deleteStaff.toString());
              Common.saveSharedPref("viewStaffReportPermission",
                  object1.data!.viewStaffReport.toString());
              Common.saveSharedPref("viewTargetReportPermission",
                  object1.data!.viewTargetReport.toString());
              Common.saveSharedPref("createStaffDesignationPermission",
                  object1.data!.viewStaffReport.toString());
              Common.saveSharedPref("viewStaffDesignationPermission",
                  object1.data!.viewStaffDesignation.toString());
              Common.saveSharedPref("updateStaffDesignationPermission",
                  object1.data!.updateStaffDesignation.toString());
              Common.saveSharedPref("deleteStaffDesignationPermission",
                  object1.data!.deleteStaffDesignation.toString());
              Common.saveSharedPref("updateStaffPasswordPermission",
                  object1.data!.updateStaffPassword.toString());
              Common.saveSharedPref("officialWhatsApp",
                  object1.data!.whatsappOfficial.toString());
              Common.saveSharedPref("unofficialWhatsApp",
                  object1.data!.whatsappUnofficial.toString());
              Common.saveSharedPref(
                  "transferLeads", object1.data!.transferLead.toString());
              Common.saveSharedPref("addAttendanceRemarks",
                  object1.data!.addAttendanceRemarks.toString());
              Common.saveSharedPref(
                  "uploadCallLog", object1.data!.uploadCallLog.toString());
              Common.saveSharedPref("addApproveLeavePermission",
                  object1.data!.addApproveLeave.toString());
              Common.saveSharedPref("rejectRequestLeavePermission",
                  object1.data!.rejectRequestLeave.toString());
              Common.saveSharedPref("editLeaveRequestPermission",
                  object1.data!.editLeaveRequest.toString());
              Common.saveSharedPref("deleteLeaveRequestPermission",
                  object1.data!.deleteLeaveRequest.toString());
              Common.saveSharedPref("sound", 'slow_spring_board');
              Common.saveSharedPref("token", object.data!.token.toString());
              Common.saveSharedPref(
                  "name", object.data!.name.toString().toUpperCase());
              Common.saveSharedPref("userId", object.data!.userId.toString());
              Common.saveSharedPref("role", object.data!.role.toString());
              Common.saveSharedPref("roleId", object.data!.roleId.toString());
              Common.saveSharedPref(
                  "staffType", object.data!.staffType.toString());
              Common.saveSharedPref(
                  "multiBranch", object.data!.isMultiBranch.toString());
              Common.saveSharedPref(
                  "faceDetection", object1.data!.faceDetection.toString());
              Common.saveSharedPref(
                  "companyLocation", object1.data!.companyLocation.toString());
              Common.saveSharedPref(
                  "assignWork", object1.data!.assignWork.toString());
                   Common.saveSharedPref(
                  "editAssignWork", object1.data!.editassignWork.toString());
                   Common.saveSharedPref(
                  "deleteAssignWork", object1.data!.deleteassignWork.toString());
              Common.saveSharedPref(
                  "markAttendance", object1.data!.markAttendance.toString());
              Common.saveSharedPref("ProjectDashboardPermission",
                  object1.data!.ProjectDashboard.toString());
              Common.saveSharedPref(
                  "LeadDashboard", object1.data!.LeadDashboard.toString());
              Common.saveSharedPref("AccountsDashboardPermission",
                  object1.data!.AccountsDashboard.toString());
              Common.saveSharedPref("QuotationDashboardPermission",
                  object1.data!.QuotationDashboard.toString());
              Common.saveSharedPref(
                  "RoomDashboard", object1.data!.RoomDashboard.toString());
              Common.saveSharedPref(
                  "JobCard", object1.data!.JobCard.toString());
              //////////////Modules permissions /////////////////////////////////////////
              Common.saveSharedPref(
                  "RoomModule", object1.data!.roomModule.toString());
              Common.saveSharedPref("workWithoutLogin",
                  object1.data!.workWithoutLogin.toString());
              Common.saveSharedPref(
                  "quotationModule", object1.data!.quotationModule.toString());
              Common.saveSharedPref(
                  "workModule", object1.data!.workModule.toString());
              Common.saveSharedPref(
                  "renewalModule", object1.data!.renewalModule.toString());
              Common.saveSharedPref(
                  "accountsModule", object1.data!.accountsModule.toString());
              Common.saveSharedPref(
                  "leadModule", object1.data!.leadModule.toString());

              ///      Modulessss eNDSSSS ///////////////////////////////////////
              Common.saveSharedPref(
                  "MenuDashboard", object1.data!.MenuDashboard.toString());
              Common.saveSharedPref("RenewalDashboardPermission",
                  object1.data!.RenewalDashboard.toString());
              Common.saveSharedPref("NewleadDashboardPermission",
                  object1.data!.NewleadDashboard.toString());
              Common.saveSharedPref(
                  "addWorkModule", object1.data!.addWorkModule.toString());
              Common.saveSharedPref("viewAttendanceSection",
                  object1.data!.viewAttendanceSection.toString());
              Common.saveSharedPref(
                  "approvePayroll", object1.data!.approvePayroll.toString());
              Common.saveSharedPref("proformaInvoiceMenu",
                  object1.data!.proformaInvoiceMenu.toString());
              Common.saveSharedPref(
                  "gstInvoiceMenu", object1.data!.gstInvoiceMenu.toString());
              Common.saveSharedPref(
                  "receiptMenu", object1.data!.receiptMenu.toString());
              Common.saveSharedPref("pendingInvoiceMenu",
                  object1.data!.pendingInvoiceMenu.toString());
              Common.saveSharedPref("createLeadCategory",
                  object1.data!.createLeadCategory.toString());
              Common.saveSharedPref(
                  "addLeadSource", object1.data!.addLeadSource.toString());
              Common.saveSharedPref(
                  "updateDashboard", object1.data!.updateDashboard.toString());
              Common.saveSharedPref("viewPendingWorks",
                  object1.data!.viewPendingWorks.toString());

              ///////////////////nnnnnnnnnnnnnnnnnnneeeeeeeeeeeeeeeeeeeeeewwwwwwwwwwwwwwwwwwwwwwwwwww/////////////////
              Common.saveSharedPref("voiceListeningPermission",
                  object1.data!.voiceListerningPermission.toString());
              Common.saveSharedPref("voiceUploadPermission",
                  object1.data!.voiceUploadPermission.toString());
              Common.saveSharedPref("createCustomerInvoice",
                  object1.data!.createCustomerInvoice.toString());
              Common.saveSharedPref("createRenewalPermission",
                  object1.data!.createRenewal.toString());
              Common.saveSharedPref("createInstallmentPermission",
                  object1.data!.createInstallment.toString());
              Common.saveSharedPref("customerAddPermission",
                  object1.data!.customerAddPermission.toString());
              Common.saveSharedPref("customerAddInvoicePermission",
                  object1.data!.customerAddInvoicePermission.toString());

              Common.saveSharedPref("viewLeadCategoryOnly",
                  object1.data!.viewLeadCategoryOnly.toString());

              Common.saveSharedPref(
                  "viewAllCategory", object1.data!.viewAllCategory.toString());
              // Common.saveSharedPref("callLogPermission", 'false');
              //  Common.saveSharedPref(
              //  "callLogPermission", 'true');
              String? projectDash = object1.data!.ProjectDashboard.toString();
              String? leadDash = object1.data!.LeadDashboard.toString();
              String? accountsDash = object1.data!.AccountsDashboard.toString();
              String? menuDash = object1.data!.MenuDashboard.toString();
              String? renewalDash = object1.data!.RenewalDashboard.toString();
              String? quotationDash =
                  object1.data!.QuotationDashboard.toString();
              Widget dashboardToOpen;
              if (projectDash == "true") {
                dashboardToOpen = ProjectDashboard();
              } else if (leadDash == "true") {
                // dashboardToOpen = Dashboard(object.data!.token.toString());
                dashboardToOpen =
                    DashboardLeadNewUpdatedTwo(object.data!.token.toString());
              } else if (accountsDash == "true") {
                dashboardToOpen =
                    AccountsDashboard(token: object.data!.token.toString());
              } else if (menuDash == "true") {
                dashboardToOpen = HomePage(object.data!.token.toString());
              } else if (renewalDash == "true") {
                dashboardToOpen = RenewalDashboard();
              } else if (quotationDash == "true") {
                dashboardToOpen = QuotationDashboard();
              } else {
                // dashboardToOpen =
                //     Dashboard(object.data!.token.toString()); // fallback
                dashboardToOpen = HomePage(object.data!.token.toString());
              }

              if (object.status == true) {
                if (mounted) {
                  // Navigator.of(context).push(
                  //   MaterialPageRoute(
                  //       builder: (context) =>
                  //           Dashboard(object.data!.token.toString())),
                  // );
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => dashboardToOpen),
                  );
                }
              } else {}

              Common.toastMessaage(object.message, Colors.green);
            }
          } else {
            setState(() {
              _loading = false;
              Common.premiumToast(
                context,
                object.message ?? 'Login Failed',
                Icons.error_outline_rounded,
                color: Colors.red,
              );
            });
          }
        }
      } else {
        setState(() {
          _loading = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No Network Found..Try Again Later..'),
              backgroundColor: Colors.redAccent,
              elevation: 10,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(10),
            ),
          );
        });
      }
      if (Platform.isAndroid) {
        _channel.setMethodCallHandler((call) async {
          if (call.method == 'setAsBackgroundService') {
            initService();
            FlutterBackgroundService().invoke('setAsBackground');
          }
        });
        Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
      }
    } catch (e) {
      setState(() {
        timeOut = true;
      });
    }
    setState(() {
      _loading = false;
    });
  }

  void openPopupMenu() {
    final dynamic popupMenuState = popupMenuKey.currentState;
    popupMenuState?.showButtonMenu();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _pulseAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _floatAnimation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: Curves.easeInOut,
      ),
    );

    _fadeController.forward();
  }

  @override
  void initState() {
    super.initState();
    _initAnimations();
    handleAsync();
    getData();
    HiveUtil.clearAllCallLogs();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    _floatController.dispose();
    username.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return result == true && timeOut == false
        ? Scaffold(
            backgroundColor: Colors.white,
            body: updatedata != null
                ? SafeArea(
                    child: Stack(
                      children: [
                        // Animated background with blue waves
                        Positioned.fill(
                          child: CustomPaint(
                            painter: BlueWavePainter(),
                          ),
                        ),

                        // Floating blue circles for decoration
                        Positioned(
                          top: -50,
                          right: -30,
                          child: TweenAnimationBuilder(
                            tween: Tween<double>(begin: 0, end: 1),
                            duration: const Duration(seconds: 3),
                            curve: Curves.easeInOut,
                            builder: (context, double value, child) {
                              return Transform.translate(
                                offset: Offset(0, sin(value * pi * 2) * 10),
                                child: Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: lightBlue.withOpacity(0.15),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        Positioned(
                          bottom: -40,
                          left: -40,
                          child:
                              Container(), // Placeholder or removed animation
                        ),

                        Positioned(
                          bottom: -40,
                          left: -40,
                          child:
                              Container(), // Placeholder or removed animation
                        ),

                        SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Container(
                                width: double.infinity,
                                color: Colors.transparent,
                                child: Column(children: [
                                  // Server selector at top right (only if multiple servers)
                                  // if (updatedata!.data!.server!.length > 1)
                                  //   Container(
                                  //     alignment: Alignment.centerRight,
                                  //     padding: const EdgeInsets.only(
                                  //         right: 20, top: 10),
                                  //     child: PopupMenuButton(
                                  //       key: popupMenuKey,
                                  //       elevation: 8,
                                  //       shape: RoundedRectangleBorder(
                                  //         borderRadius:
                                  //             BorderRadius.circular(12),
                                  //       ),
                                  //       child: Container(
                                  //         padding: const EdgeInsets.symmetric(
                                  //             horizontal: 12, vertical: 6),
                                  //         decoration: BoxDecoration(
                                  //           color: Colors.blue.shade50,
                                  //           borderRadius:
                                  //               BorderRadius.circular(20),
                                  //           border: Border.all(
                                  //               color: Colors.blue.shade200),
                                  //         ),
                                  //         child: Row(
                                  //           mainAxisSize: MainAxisSize.min,
                                  //           children: [
                                  //             Icon(
                                  //               Icons.dns_rounded,
                                  //               size: 18,
                                  //               color: Colors.blue.shade700,
                                  //             ),
                                  //             const SizedBox(width: 6),
                                  //             Text(
                                  //               serverChoose &&
                                  //                       selectedUrl.isNotEmpty
                                  //                   ? _getServerDisplayName()
                                  //                   : 'Select Server',
                                  //               style: TextStyle(
                                  //                 fontSize: 13,
                                  //                 fontWeight: FontWeight.w500,
                                  //                 color: Colors.blue.shade700,
                                  //               ),
                                  //             ),
                                  //             const SizedBox(width: 4),
                                  //             Icon(
                                  //               Icons.arrow_drop_down_rounded,
                                  //               color: Colors.blue.shade700,
                                  //             ),
                                  //           ],
                                  //         ),
                                  //       ),
                                  //       itemBuilder: (context) {
                                  //         return updatedata!.data!.server!
                                  //             .map((data) {
                                  //           return PopupMenuItem<String>(
                                  //             value: data.url,
                                  //             child: Row(
                                  //               mainAxisAlignment:
                                  //                   MainAxisAlignment
                                  //                       .spaceBetween,
                                  //               children: [
                                  //                 Text(
                                  //                   data.name.toString(),
                                  //                   style: const TextStyle(
                                  //                       fontSize: 14),
                                  //                 ),
                                  //                 if (selectedUrl == data.url)
                                  //                   Icon(
                                  //                     Icons
                                  //                         .check_circle_rounded,
                                  //                     color:
                                  //                         Colors.green.shade600,
                                  //                     size: 18,
                                  //                   ),
                                  //               ],
                                  //             ),
                                  //           );
                                  //         }).toList();
                                  //       },
                                  //       onSelected: (value) {
                                  //         Common.saveSharedPref("url", value);
                                  //         selectedUrl = value;
                                  //         serverChoose = true;
                                  //         setState(() {});
                                  //       },
                                  //     ),
                                  //   ),

                                  // Main content
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24),
                                    child: Column(
                                      children: [
                                        const SizedBox(height: 20),

                                        // Animated Logo Section - NOW IN FULL COLOR
                                        FadeTransition(
                                          opacity: _fadeAnimation,
                                          child: AnimatedBuilder(
                                            animation: _floatAnimation,
                                            builder: (context, child) {
                                              return Transform.translate(
                                                offset: Offset(
                                                    0, _floatAnimation.value),
                                                child: ScaleTransition(
                                                  scale: _pulseAnimation,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            15),
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.white,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: primaryBlue
                                                              .withOpacity(
                                                                  0.25),
                                                          blurRadius: 30,
                                                          offset: const Offset(
                                                              0, 15),
                                                          spreadRadius: 8,
                                                        ),
                                                        BoxShadow(
                                                          color: lightBlue
                                                              .withOpacity(
                                                                  0.15),
                                                          blurRadius: 50,
                                                          offset: const Offset(
                                                              0, 20),
                                                          spreadRadius: 10,
                                                        ),
                                                      ],
                                                    ),
                                                    child: ClipOval(
                                                      child: Image.asset(
                                                        'assets/main/funriders.png',
                                                        width: 100,
                                                        height: 100,
                                                        fit: BoxFit.contain,
                                                        errorBuilder: (context,
                                                            error, stackTrace) {
                                                          return Container(
                                                            width: 100,
                                                            height: 100,
                                                            decoration:
                                                                BoxDecoration(
                                                              gradient:
                                                                  LinearGradient(
                                                                begin: Alignment
                                                                    .topLeft,
                                                                end: Alignment
                                                                    .bottomRight,
                                                                colors: [
                                                                  gradientStart,
                                                                  gradientEnd
                                                                ],
                                                              ),
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                            child: Center(
                                                              child: Text(
                                                                "Logo",
                                                                style:
                                                                    GoogleFonts
                                                                        .inter(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),

                                        const SizedBox(height: 10),

                                        // Welcome text
                                        const Text(
                                          "Welcome Back",
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF1A1F36),
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Sign in to access your account",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),

                                        const SizedBox(height: 40),

                                        // Username field
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.shade200,
                                                blurRadius: 20,
                                                offset: const Offset(0, 5),
                                              ),
                                            ],
                                          ),
                                          child: TextFormField(
                                            controller: username,
                                            style:
                                                const TextStyle(fontSize: 16),
                                            decoration: InputDecoration(
                                              hintText: 'Enter your username',
                                              hintStyle: TextStyle(
                                                  color: Colors.grey.shade400),
                                              prefixIcon: Icon(
                                                Icons.person_outline_rounded,
                                                color: Colors.blue.shade700,
                                                size: 22,
                                              ),
                                              filled: true,
                                              fillColor: Colors.white,
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                borderSide: BorderSide.none,
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                borderSide: BorderSide(
                                                    color: Colors.grey.shade200,
                                                    width: 1.5),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                borderSide: BorderSide(
                                                    color: Colors.blue.shade700,
                                                    width: 2),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 16),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 18),

                                        // Password field
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.shade200,
                                                blurRadius: 20,
                                                offset: const Offset(0, 5),
                                              ),
                                            ],
                                          ),
                                          child: TextFormField(
                                            obscureText: obSecure,
                                            controller: password,
                                            style:
                                                const TextStyle(fontSize: 16),
                                            decoration: InputDecoration(
                                              hintText: 'Enter your password',
                                              hintStyle: TextStyle(
                                                  color: Colors.grey.shade400),
                                              prefixIcon: Icon(
                                                Icons.lock_outline_rounded,
                                                color: Colors.blue.shade700,
                                                size: 22,
                                              ),
                                              suffixIcon: IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    obSecure = !obSecure;
                                                  });
                                                },
                                                icon: Icon(
                                                  obSecure
                                                      ? Icons
                                                          .visibility_outlined
                                                      : Icons
                                                          .visibility_off_outlined,
                                                  color: Colors.grey.shade600,
                                                  size: 22,
                                                ),
                                              ),
                                              filled: true,
                                              fillColor: Colors.white,
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                borderSide: BorderSide.none,
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                borderSide: BorderSide(
                                                    color: Colors.grey.shade200,
                                                    width: 1.5),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                borderSide: BorderSide(
                                                    color: Colors.blue.shade700,
                                                    width: 2),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 16),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 30),

                                        // Login button
                                        InkWell(
                                          onTap: () async {
                                            FocusScope.of(context).unfocus();
                                            login();
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            height: 55,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.blue.shade700,
                                                  Colors.blue.shade500,
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.blue.shade200,
                                                  blurRadius: 20,
                                                  offset: const Offset(0, 8),
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: _loading
                                                  ? const SizedBox(
                                                      height: 30,
                                                      width: 30,
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 3,
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                                    Color>(
                                                                Colors.white),
                                                      ),
                                                    )
                                                  : const Text(
                                                      "Sign In",
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.white,
                                                        letterSpacing: 0.5,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 20),

                                        // Forgot password
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const ForgotPassword(),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            "Forgot Password?",
                                            style: TextStyle(
                                              color: Colors.blue.shade700,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 30),
                                        Text(
                                          "Version 3.0.6",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ]))),
                      ],
                    ),
                  )
                : const SizedBox(),
          )
        : Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade100,
                      ),
                      child: Icon(
                        timeOut == true
                            ? Icons.timer_off_rounded
                            : Icons.wifi_off_rounded,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      timeOut == true
                          ? "Connection Timeout"
                          : "No Internet Connection",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1F36),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      timeOut == true
                          ? "Unable to reach the server. Please try again."
                          : "Please check your internet connection and try again.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    InkWell(
                      onTap: () {
                        getData();
                      },
                      child: Container(
                        width: 160,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade700,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.shade200,
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Try Again',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  // Helper method to get server display name
  String _getServerDisplayName() {
    try {
      final selectedServer = updatedata!.data!.server!.firstWhere(
        (server) => server.url == selectedUrl,
      );
      return selectedServer.name ?? 'Server';
    } catch (e) {
      return 'Server';
    }
  }
}

// Custom painter for blue wave background
class BlueWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE3F2FD).withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height * 0.3)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.2,
        size.width * 0.5,
        size.height * 0.3,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.4,
        size.width,
        size.height * 0.25,
      )
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();

    canvas.drawPath(path, paint);

    // Draw second wave with lighter blue
    final paint2 = Paint()
      ..color = const Color(0xFFBBDEFB).withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final path2 = Path()
      ..moveTo(0, size.height * 0.4)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.25,
        size.width * 0.6,
        size.height * 0.4,
      )
      ..quadraticBezierTo(
        size.width * 0.8,
        size.height * 0.5,
        size.width,
        size.height * 0.35,
      )
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();

    canvas.drawPath(path2, paint2);

    // Add blue dots for decoration
    final dotPaint = Paint()
      ..color = const Color(0xFF42A5F5).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
        Offset(size.width * 0.8, size.height * 0.7), 30, dotPaint);
    canvas.drawCircle(
        Offset(size.width * 0.1, size.height * 0.8), 50, dotPaint);
    canvas.drawCircle(
        Offset(size.width * 0.9, size.height * 0.2), 20, dotPaint);

    // Add sparkles
    final sparklePaint = Paint()
      ..color = const Color(0xFF64B5F6).withOpacity(0.2)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 5; i++) {
      double x = size.width * (0.1 + i * 0.2);
      double y = size.height * (0.1 + sin(i * 1.5) * 0.1);
      canvas.drawCircle(Offset(x, y), 3, sparklePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

import 'dart:developer';

import 'package:call_e_log/call_log.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:login2/screens/accounts/dashboard/accounts_dashboard.dart';
import 'package:login2/screens/accounts/renewal_mannagement/renewal_dashboard.dart';
import 'package:login2/screens/homePage.dart';
import 'package:login2/screens/leadManagement/dashboard.dart';
import 'package:login2/screens/leadManagement/dashboardLeadsNewUpdated2.dart';
import 'package:login2/screens/leadManagement/projectDashboard.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/common.dart';
import '../../hive/call_logs/HiveCaallHistoryModel.dart';
import '../../hive/call_logs/call_logs_hive_functions.dart';
import '../../models/callLogs/callLogUploadModel.dart';
import '../../models/lead_management/timeDetailsModel.dart';
import '../../models/lead_management/workstatus_model.dart';
import 'package:login2/service/call_recording_service.dart';
import '../../service/service.dart';

class InfoCardExample extends StatefulWidget {
  const InfoCardExample({super.key});

  @override
  State<InfoCardExample> createState() => _InfoCardExampleState();
}

class _InfoCardExampleState extends State<InfoCardExample> {
  WorkStatusModel? workStatus;
  TimeDetailsModel? timeDetails;
  bool isLoading = true;
  bool isSyncingCallLogs = false;
  late String token;
  String? ideal_time;
  String? work_time;
  String? ProjectDashboardPermission;
  String? AccountsDashboardPermission;
  String? MenuDashboard;
  String? RenewalDashboardPermission;
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    token = await Common.getSharedPref("token") ?? "";
    ProjectDashboardPermission =
        await Common.getSharedPref("ProjectDashboardPermission");
    AccountsDashboardPermission =
        await Common.getSharedPref("AccountsDashboardPermission");
    MenuDashboard = await Common.getSharedPref("MenuDashboard");
    RenewalDashboardPermission =
        await Common.getSharedPref("RenewalDashboardPermission");
    await Future.wait([
      _fetchWorkStatus(),
      _fetchTimeDetails(),
    ]);
  }

  Future<void> _fetchWorkStatus() async {
    try {
      final result = await HttpService.getWorkStatus();
      setState(() => workStatus = result);
    } catch (e) {
      print('Error fetching work status: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _fetchTimeDetails() async {
    try {
      final result = await HttpService.getimeDetails();
      setState(() => timeDetails = result);
    } catch (e) {
      print('Error fetching time details: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    final now = DateTime.now();
    ideal_time = timeDetails?.data.totalGapDuration;
    work_time = timeDetails?.data.totalWorkDuration;
    try {
      final result = await HttpService.getWorkStatus();
      if (result != null && result.data.isNotEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Logout Blocked'),
            content: const Text(
              'Work is in progress. Please close all work before logging out.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }
      setState(() => isSyncingCallLogs = true);
      await _getSharedData();
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Location permission denied.")),
          );
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                "Location permission permanently denied. Please enable it from settings."),
          ),
        );
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final response = await HttpService.stopWork(
        now,
        latitude: position.latitude,
        longitude: position.longitude,
        ideal_time: ideal_time,
        work_time: work_time,
      );
      if (response != null && response.status == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Log out at ${DateFormat('hh:mm a').format(now)}"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 10, left: 16, right: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );

        ProjectDashboardPermission == "true"
            ? Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ProjectDashboard()),
              )
            : AccountsDashboardPermission == "true"
                ? Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AccountsDashboard(token: token)),
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
                        : Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    DashboardLeadNewUpdatedTwo(token)),
                          );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response?.message ?? "Failed to log out."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isSyncingCallLogs = false);
    }
  }

  Future<void> _getSharedData() async {
    try {
      String permissionAccess = await Common.getSharedPref("callLogPermission");
      int from = DateTime.now()
          .subtract(const Duration(days: 3))
          .millisecondsSinceEpoch;
      int to = DateTime.now().millisecondsSinceEpoch;

      if (permissionAccess == 'true') {
        if (await Permission.phone.request().isGranted) {
          final List<CallLogToggleEvent> toggleHistory =
              await ToggleStorage.getToggleHistory();
          final Iterable<CallLogEntry> result =
              await CallLog.query(dateFrom: from, dateTo: to);

          final filteredLogs = result.where((entry) {
            return isLogAllowed(
                entry.timestamp ?? 0, entry.callType!, toggleHistory);
          }).toList();

          final List<HiveCaallHistoryModel> hiveData =
              await HiveUtil.getAllCallLogs();

          final int callLogCount = await HiveUtil.getCallLogCount();
          SharedPreferences prefs = await SharedPreferences.getInstance();
          List<HiveCaallHistoryModel> callLogData = <HiveCaallHistoryModel>[];
          final String dateTimeFrom =
              prefs.getString('callLogsStartingTime').toString();

          if (callLogCount == 0) {
            log('No call logs found in Hive.');
            final DateTime startingTime = DateTime.parse(dateTimeFrom);
            final List<CallLogEntry> filteredLogs = result.where((entry) {
              final DateTime callTime =
                  DateTime.fromMillisecondsSinceEpoch(entry.timestamp ?? 0);
              return callTime.isAfter(startingTime);
            }).toList();

            if (filteredLogs.isNotEmpty) {
              List<String> callTypesQ = prefs.getStringList('callTypes') ?? [];
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

                HiveCaallHistoryModel hiveCallLog = HiveCaallHistoryModel(
                    id: callLog.timestamp.toString(),
                    name: callLog.name.toString(),
                    phoneNumber: callLog.number.toString(),
                    callType: callLog.callType.toString().substring(
                        callLog.callType.toString().indexOf('.') + 1),
                    duration: callLog.duration.toString(),
                    timeStamp: callLog.timestamp!.toString(),
                    simSlot: callLog.simDisplayName ?? "NIL",
                    callRecordFilePath: "",
                    isUploaded: false,
                    isDeleted: false,
                    isEnabled: isAllowed);
                listOfCallLogNeedToAddHive.add(hiveCallLog);
              }

              List<HiveCaallHistoryModel> allowedCallLogs =
                  listOfCallLogNeedToAddHive
                      .where((log) => log.isEnabled == true)
                      .toList();

              if (allowedCallLogs.isNotEmpty) {
                await uploadMissingLogsToServer(allowedCallLogs);
              }

              if (listOfCallLogNeedToAddHive.isNotEmpty) {
                await HiveUtil.addCallLogs(listOfCallLogNeedToAddHive);
                _showToast('Synced Call Logs');
              }
            }
          } else {
            log('call logs found in Hive.');
            final DateTime startingTime = DateTime.parse(dateTimeFrom);
            final List<CallLogEntry> callLogsFromDevice = result.where((entry) {
              final DateTime callTime =
                  DateTime.fromMillisecondsSinceEpoch(entry.timestamp ?? 0);
              return callTime.isAfter(startingTime);
            }).toList();

            if (callLogsFromDevice.isNotEmpty) {
              final deviceLatestCallLogTime = parseCallLogTime(
                  callLogsFromDevice.first.timestamp.toString());
              final HiveCaallHistoryModel latestHiveCallLog2 =
                  await HiveUtil.getLatestCallLogByTime() ?? hiveData.first;
              final hiveLatestDateTime =
                  parseCallLogTime(latestHiveCallLog2.timeStamp);

              if (hiveLatestDateTime != deviceLatestCallLogTime) {
                log('Latest Hive Call Log and Device Call Log are not same.');
                final List<CallLogEntry> allCallLogsAfterHiveLatestData =
                    result.where((entry) {
                  final DateTime callTime =
                      DateTime.fromMillisecondsSinceEpoch(entry.timestamp ?? 0);
                  return callTime.isAfter(startingTime);
                }).toList();

                if (allCallLogsAfterHiveLatestData.isNotEmpty) {
                  List<String> callTypesQ =
                      prefs.getStringList('callTypes') ?? [];

                  for (var callLog in allCallLogsAfterHiveLatestData) {
                    bool isAllowed = false;
                    if (callTypesQ.contains('Incoming') &&
                        callLog.callType.toString().contains('incoming')) {
                      isAllowed = true;
                    } else if (callTypesQ.contains('Outgoing') &&
                        callLog.callType.toString().contains('outgoing')) {
                      isAllowed = true;
                    }

                    HiveCaallHistoryModel hiveCallLog = HiveCaallHistoryModel(
                      id: callLog.timestamp.toString(),
                      name: callLog.name.toString(),
                      phoneNumber: callLog.number.toString(),
                      callType: callLog.callType.toString().substring(
                          callLog.callType.toString().indexOf('.') + 1),
                      duration: callLog.duration.toString(),
                      timeStamp: callLog.timestamp!.toString(),
                      simSlot: callLog.simDisplayName ?? "NIL",
                      callRecordFilePath: "",
                      isUploaded: false,
                      isDeleted: false,
                      isEnabled: isAllowed,
                    );
                    callLogData.add(hiveCallLog);
                  }

                  Map<String, bool> existingItems = {};
                  for (var item in hiveData) {
                    String uniqueKey = "${item.phoneNumber}_${item.timeStamp}";
                    existingItems[uniqueKey] = true;
                  }

                  List<HiveCaallHistoryModel> nonDuplicates = [];
                  for (var item in callLogData) {
                    String uniqueKey = "${item.phoneNumber}_${item.timeStamp}";
                    if (!existingItems.containsKey(uniqueKey)) {
                      nonDuplicates.add(item);
                    }
                  }

                  nonDuplicates = nonDuplicates
                      .where((log) => log.isDeleted != true)
                      .where((log) => log.isUploaded != true)
                      .toList()
                      .reversed
                      .toList();

                  List<HiveCaallHistoryModel> allowedCallLogs = nonDuplicates
                      .where((log) => log.isEnabled == true)
                      .toList();

                  if (allowedCallLogs.isNotEmpty) {
                    await uploadMissingLogsToServer(allowedCallLogs);
                  }

                  if (nonDuplicates.isNotEmpty) {
                    await HiveUtil.addCallLogs(nonDuplicates);
                    _showToast('Synced Call Logs');
                  }
                }
              }
            }
          }
        }
      }
    } catch (e) {
      log(e.toString());
      //_showToast('Error syncing call logs');
    }
  }

  // Future<void> _uploadMissingLogsToServer(
  //     List<HiveCaallHistoryModel> callLogData) async {
  //   try {
  //     List<Map<String, dynamic>> missingLogs = callLogData
  //         .map((log) => {
  //               "name": log.name,
  //               "phone_number": log.phoneNumber,
  //               "callTypes": log.callType
  //                   .toString()
  //                   .substring(log.callType.toString().indexOf('.') + 1),
  //               "time": DateTime.fromMillisecondsSinceEpoch(
  //                       int.parse(log.timeStamp))
  //                   .toString(),
  //               "duration": log.duration,
  //               "simName": log.simSlot ?? "NIL",
  //               "timeStamp": log.timeStamp,
  //             })
  //         .toList();

  //     if (missingLogs.isNotEmpty) {
  //       Map<String, dynamic> body = {
  //         "token": await Common.getSharedPref("token"),
  //         'log': missingLogs,
  //       };

  //       CallLogUploadModel object1 = await HttpService.callLogUpload(body);
  //       if (object1.data == true) {
  //         log('Call logs uploaded successfully');
  //       } else {
  //         log('Failed to upload call logs');
  //       }
  //     }
  //   } catch (e) {
  //     log('Error uploading call logs: $e');
  //   }
  // }

  Future<bool> uploadMissingLogsToServer(
    List<HiveCaallHistoryModel> callLogData) async {
  log("uploadMissingLogsToServer function called");

  List<Map<String, dynamic>> missingLogs = callLogData
      .map((log) => {
            "name": log.name,
            "phone_number": log.phoneNumber,
            "callTypes": log.callType
                .toString()
                .substring(log.callType.toString().indexOf('.') + 1),
            // "time": DateTime.parse(log.timeStamp).toString(),
            "time":
                DateTime.fromMillisecondsSinceEpoch(int.parse(log.timeStamp))
                    .toString(), // log.timestamp,
            // "time": log.timeStamp.toString(), // log.timestamp,
            "duration": log.duration,
            "simName": log.simSlot,
            "timeStamp": log.timeStamp,
          })
      .toList();

  log("⚠️ Found ${missingLogs.length} missing logs.");

  if (missingLogs.isEmpty) {
    return false;
  }

  log('~~ OUTGOING CALL missingLogs : $missingLogs ~~~');
  log('~~ OUTGOING CALL length : ${missingLogs.length} ~~~');

  Map<String, dynamic> body = {
    "token": await Common.getSharedPref("token"),
    'log': missingLogs,
  };
  log('~~ OUTGOING CALL BODY : $body ~~~');

  // --- OPTION A PRE-UPLOAD SCAN ---
  HiveCaallHistoryModel? targetCall;
  if (callLogData.isNotEmpty) {
    targetCall = callLogData.reduce((a, b) {
      final tsA = int.tryParse(a.timeStamp) ?? 0;
      final tsB = int.tryParse(b.timeStamp) ?? 0;
      return tsA >= tsB ? a : b;
    });
  }

  Map<String, dynamic>? initialMatch;
  if (targetCall != null) {
    try {
      print(
          'AUTO RECORDING [OPTION A]: Pre-upload scan started for target phone: ${targetCall.phoneNumber}');
      initialMatch =
          await CallRecordingService.findMatchingRecordingForTargetCall(
        targetCall,
        attemptNumber: 0,
      );
    } catch (e) {
      print('AUTO RECORDING [OPTION A]: Pre-upload scan error: $e');
    }
  }

  String? recordingPath;
  if (initialMatch != null) {
    recordingPath = initialMatch['recordingPath']?.toString();
    print('AUTO: initial request type multipart');
    print(
        'AUTO RECORDING [OPTION A]: MATCH FOUND! Uploading MULTIPART (call log + audio recording file together) to $recordingPath');
  } else {
    print('AUTO: initial request type json');
    print(
        'AUTO RECORDING [OPTION A]: No matching recording available before initial upload. Uploading JSON-ONLY call log immediately.');
  }

  CallLogUploadModel object1 = await HttpService.callLogUpload(
    body,
    recordingPath: recordingPath,
  );
  print(
      'AUTO: API response status=${object1.status}, data=${object1.data}, message=${object1.message}');
  log('~~ OUTGOING CALL missingLogs object : ${object1.data} ~~~');

  if (object1.data == true || object1.status == true) {
    log('~~ OUTGOING CALL success ~~~');
    if (initialMatch != null && recordingPath != null) {
      await CallRecordingService.markRecordingUploadedLocally(
        recordingPath,
        initialMatch['recordingTime'],
      );
      print(
          'AUTO RECORDING [OPTION A]: Initial multipart upload SUCCESS! Recording marked uploaded.');
      return true;
    }
    return false;
  } else {
    log('~~ OUTGOING CALL failure ~~~');
    return false;
  }

}


  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
  }

  DateTime parseCallLogTime(String timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp));
  }

  bool isLogAllowed(int timestamp, CallType callType,
      List<CallLogToggleEvent> toggleHistory) {
    // Implement your logic for filtering call logs based on toggle history
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : timeDetails == null
              ?
              // const Center(child: Text("No work data found"))
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      timeDetails?.data.totalGapDuration != ""
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Work Summery",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    DummyInfoCard(
                                      title: "Login Time",
                                      content:
                                          timeDetails?.data.loginTime ?? "--",
                                      icon: Icons.login,
                                      iconColor: Colors.green,
                                    ),
                                    DummyInfoCard(
                                      title: "Logout Time",
                                      content:
                                          timeDetails?.data.logoutTime ?? "--",
                                      icon: Icons.logout,
                                      iconColor: Colors.red,
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : const SizedBox(),
                      const SizedBox(height: 10),
                      timeDetails?.data.totalGapDuration != ""
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                DummyInfoCard(
                                  title: "Idle Time",
                                  content: timeDetails?.data.totalGapDuration ??
                                      "--",
                                  icon: Icons.hourglass_empty,
                                  iconColor: Colors.orange,
                                ),
                                DummyInfoCard(
                                  title: "Work Time",
                                  content:
                                      timeDetails?.data.totalWorkDuration ??
                                          "--",
                                  icon: Icons.timer,
                                  iconColor: Colors.purple,
                                ),
                              ],
                            )
                          : const SizedBox(),
                      const SizedBox(height: 10),
                      timeDetails?.data.totalWorkDuration == ""
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Call Summery",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    DummyInfoCard(
                                      title: "Login Time",
                                      content:
                                          timeDetails?.data.startTime ?? "--",
                                      icon: Icons.login,
                                      iconColor: Colors.green,
                                    ),
                                    DummyInfoCard(
                                      title: "Logout Time",
                                      content:
                                          timeDetails?.data.endTime ?? "N/A",
                                      icon: Icons.logout,
                                      iconColor: Colors.red,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    DummyInfoCard(
                                      title: "Incoming Call Duration",
                                      content: timeDetails
                                              ?.data.totalIncomingDuration ??
                                          "--",
                                      icon: Icons.call_received,
                                      iconColor: Colors.orange,
                                    ),
                                    DummyInfoCard(
                                      title: "Outgoing Call Duration",
                                      content: timeDetails
                                              ?.data.totalOutgoingDuration ??
                                          "N/A",
                                      icon: Icons.call_made_outlined,
                                      iconColor: Colors.purple,
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    DummyInfoCard(
                                      title: "Total Ideal Time",
                                      content:
                                          timeDetails?.data.totalIdealTime ??
                                              "--",
                                      icon: Icons.hourglass_empty,
                                      iconColor: Colors.orange,
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : const SizedBox(),
                      const Spacer(),
                      isSyncingCallLogs
                          ? const CircularProgressIndicator()
                          : Center(
                              child: ElevatedButton.icon(
                                onPressed: _handleLogout,
                                icon: const Icon(Icons.logout,
                                    color: Colors.white),
                                label: const Text('LOGOUT'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  textStyle: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      timeDetails?.data.totalGapDuration != ""
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Work Summery",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    DummyInfoCard(
                                      title: "Login Time",
                                      content:
                                          timeDetails?.data.loginTime ?? "N/A",
                                      icon: Icons.login,
                                      iconColor: Colors.green,
                                    ),
                                    DummyInfoCard(
                                      title: "Logout Time",
                                      content:
                                          timeDetails?.data.logoutTime ?? "N/A",
                                      icon: Icons.logout,
                                      iconColor: Colors.red,
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : const SizedBox(),
                      const SizedBox(height: 10),
                      timeDetails?.data.totalGapDuration != ""
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                DummyInfoCard(
                                  title: "Idle Time",
                                  content: timeDetails?.data.totalGapDuration ??
                                      "N/A",
                                  icon: Icons.hourglass_empty,
                                  iconColor: Colors.orange,
                                ),
                                DummyInfoCard(
                                  title: "Work Time",
                                  content:
                                      timeDetails?.data.totalWorkDuration ??
                                          "N/A",
                                  icon: Icons.timer,
                                  iconColor: Colors.purple,
                                ),
                              ],
                            )
                          : const SizedBox(),
                      const SizedBox(height: 10),
                      timeDetails?.data.totalWorkDuration == ""
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Call Summery",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    DummyInfoCard(
                                      title: "Login Time",
                                      content:
                                          timeDetails?.data.startTime ?? "N/A",
                                      icon: Icons.login,
                                      iconColor: Colors.green,
                                    ),
                                    DummyInfoCard(
                                      title: "Logout Time",
                                      content:
                                          timeDetails?.data.endTime ?? "N/A",
                                      icon: Icons.logout,
                                      iconColor: Colors.red,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    DummyInfoCard(
                                      title: "Incoming Call Duration",
                                      content: timeDetails
                                              ?.data.totalIncomingDuration ??
                                          "N/A",
                                      icon: Icons.call_received,
                                      iconColor: Colors.orange,
                                    ),
                                    DummyInfoCard(
                                      title: "Outgoing Call Duration",
                                      content: timeDetails
                                              ?.data.totalOutgoingDuration ??
                                          "N/A",
                                      icon: Icons.call_made_outlined,
                                      iconColor: Colors.purple,
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    DummyInfoCard(
                                      title: "Total Ideal Time",
                                      content:
                                          timeDetails?.data.totalIdealTime ??
                                              "N/A",
                                      icon: Icons.hourglass_empty,
                                      iconColor: Colors.orange,
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : const SizedBox(),
                      const Spacer(),
                      isSyncingCallLogs
                          ? const CircularProgressIndicator()
                          : Center(
                              child: ElevatedButton.icon(
                                onPressed: _handleLogout,
                                icon: const Icon(Icons.logout,
                                    color: Colors.white),
                                label: const Text('LOGOUT'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  textStyle: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
    );
  }
}

class DummyInfoCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color iconColor;

  const DummyInfoCard({
    super.key,
    required this.title,
    required this.content,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: iconColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  content,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

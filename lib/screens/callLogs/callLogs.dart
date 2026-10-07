// ignore_for_file: must_be_immutable

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:call_e_log/call_log.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
// import 'package:flutter_dialpad/flutter_dialpad.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/config.dart';
import 'package:login2/hive/call_logs/HiveCaallHistoryModel.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:login2/hive/call_logs/call_logs_hive_functions.dart';
import 'package:login2/screens/leadManagement/add_leads.dart';
import 'package:login2/screens/leadManagement/add_leads_new.dart';
import 'package:login2/screens/leadManagement/dashboardLeadsNewUpdated2.dart';
import 'package:login2/service/backgroundService.dart';
import 'package:lottie/lottie.dart';
// import 'package:mobile_number/mobile_number.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sim_data/sim_data.dart';
import '../../core/common.dart';
import '../../models/callLogUploadPermissionModel.dart';
import '../../models/callLogs/callLogHistoryModel.dart';
import '../../models/callLogs/callLogUploadModel.dart';
import '../../models/callLogs/callLogUploadPermissionUpdateModel.dart';
import '../../models/callLogs/deleteCallHistoryModel.dart';
import '../../models/lead_management/addLeadCommonDataModel.dart';
import '../../service/service.dart';
import '../leadManagement/dashboard.dart';
import 'dart:math' hide log;

class CallLogs extends StatefulWidget {
  String? token;
  String? name;
  String? userId;

  CallLogs(this.token, this.name, this.userId, {super.key});

  @override
  State<CallLogs> createState() => _CallLogsState();
}

class _CallLogsState extends State<CallLogs> {
  int selectedIndex = Platform.isAndroid ? 0 : 1;
  List<Map<String, dynamic>> history = [];
  List historyIndex = [];
  bool onLongPress = false;
  bool selectAll = false;
  bool refresh = false;
  CallLogHistoryModel? logHistory;
  String? permissionAccess = '';
  String? uploadPermission = '';
  String? permissionValue = '';
  late bool deleteAccess;
  List deleteHistoryIds = [];
  bool onLongPressHistory = false;
  String fromdate = DateFormat('dd-MM-yyyy').format(DateTime.now());
  String todate = DateFormat('dd-MM-yyyy').format(DateTime.now());
  bool isSearch = true;
  bool search = false;
  AddLeadCommonDataModel? commonDetails;
  String assignStaff = 'Assign Staff';
  String assignStaffId = '';
  int from =
      DateTime.now().subtract(const Duration(days: 3)).millisecondsSinceEpoch;
  // int to = DateTime.now().millisecondsSinceEpoch;
  bool displayOverApps = false;
  CallLogUploadPermissionModel? callUploadPermission;
  String roleId = "";
  // String selectedSim = "";
  // String selectedSimId = "";
  String _selectedSimFilter = 'SIM 1';
  List<Map<dynamic, dynamic>> _activeSims = [];
  List<Map<String, dynamic>> simList = [];
  String phoneNumber = "";
  String callType = 'All';
  String callTypeValue = '';

  Future<void> checkPermission() async {
    final bool status = await FlutterOverlayWindow.isPermissionGranted();
    setState(() {
      displayOverApps = status;
    });
  }

  Future<void> checkBackgroundServiceStatus() async {
    final service = FlutterBackgroundService();
    final isRunning = await service.isRunning();
    log('🔍 Background Service Status:');
    log('   Is Running: $isRunning');

    if (isRunning) {
      log('   ✅ Service is ACTIVE');
      service.invoke('test', {'message': 'Hello from app'});

      // Show status
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Service Status'),
            content: Text('✅ Background Service is RUNNING'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } else {
      log('   ❌ Service is NOT running');

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Service Status'),
            content: Text('❌ Background Service is NOT running'),
            actions: [
              TextButton(
                onPressed: () async {
                  // Try to start it
                  await initService();
                  Navigator.pop(context);
                },
                child: Text('Start Service'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
            ],
          ),
        );
      }
    }
  }

  void dialNumber(String number) {
    setState(() {
      phoneNumber += number;
    });
  }

  void deleteLastDigit() {
    if (phoneNumber.isNotEmpty) {
      setState(() {
        phoneNumber = phoneNumber.substring(0, phoneNumber.length - 1);
      });
    }
  }

  List<String> dialPadNumbers = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '*',
    '0',
    '#'
  ];

  @override
  void initState() {
    super.initState();
    assignStaff = widget.name?.toString() ?? 'Assign Staff';
    assignStaffId = widget.userId?.toString() ?? '';
    if (Platform.isAndroid) {
      getSharedData();
      getPermission();
    } else {
      getData();
    }
    checkPermission();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      askUserNeeds(context, false);
      deleteHiveData();
    });
// loadHiveData();
  }

  void toggleSelectAll() {
    setState(() {
      if (selectAll) {
        // Deselect all
        selectAll = false;
        history.clear();
        historyIndex.clear();
        onLongPress = false;
      } else {
        // Select all
        selectAll = true;
        onLongPress = true;

        // Clear previous selections
        history.clear();
        historyIndex.clear();

        // Add all call log entries to history
        for (int i = 0; i < _filteredCallLogEntries.length; i++) {
          final entry = _filteredCallLogEntries.elementAt(i);

          // Skip if already uploaded
          bool isUploaded = fullHiveData.any((item) =>
              item.id == entry.timestamp.toString() && item.isUploaded == true);

          if (!isUploaded) {
            history.add({
              "name": entry.name ?? "",
              "phone_number": entry.number,
              "callTypes": entry.callType
                  .toString()
                  .substring(entry.callType.toString().indexOf('.') + 1),
              "time":
                  '${DateTime.fromMillisecondsSinceEpoch(entry.timestamp!)}',
              "duration": entry.duration,
              "simName": entry.simDisplayName ?? "NIL",
              "timeStamp": entry.timestamp,
            });
            historyIndex.add(i);
          }
        }
      }
    });
  }

  Future<void> bulkUploadAll() async {
    if (history.isEmpty && selectAll) {
      history.clear();
      historyIndex.clear();

      for (int i = 0; i < _filteredCallLogEntries.length; i++) {
          final entry = _filteredCallLogEntries.elementAt(i);

        // Skip if already uploaded
        bool isUploaded = fullHiveData.any((item) =>
            item.id == entry.timestamp.toString() && item.isUploaded == true);

        if (!isUploaded) {
          history.add({
            "name": entry.name ?? "",
            "phone_number": entry.number,
            "callTypes": entry.callType
                .toString()
                .substring(entry.callType.toString().indexOf('.') + 1),
            "time": '${DateTime.fromMillisecondsSinceEpoch(entry.timestamp!)}',
            "duration": entry.duration,
            "simName": entry.simDisplayName ?? "NIL",
            "timeStamp": entry.timestamp,
          });
          historyIndex.add(i);
        }
      }
    }

    if (history.isEmpty) {
      Common.toastMessaage("All logs are already uploaded", Colors.blue);
      return;
    }

    Map<String, dynamic> body = {
      "token": widget.token,
      'log': history,
      'is_mannual': 1,
    };

    if (context.mounted) {
      Common.showProgressDialog(context, "Uploading ${history.length} logs...");
    }

    CallLogUploadModel object1 = await HttpService.callLogUpload(body);

    if (object1.data == true) {
      Common.toastMessaage(
          "${object1.message} (${history.length} logs)", Colors.green);

      // Mark as uploaded in Hive
      for (var entry in _callLogEntries) {
        bool existsInHive = await HiveUtil.isCallLogWithIdAndNumberExists(
            entry.timestamp.toString(), entry.number.toString());

        if (existsInHive) {
          await HiveUtil.markCallLogAsUploaded(entry.timestamp.toString());
        } else {
          HiveCaallHistoryModel hiveCallLog = HiveCaallHistoryModel(
              id: entry.timestamp.toString(),
              name: entry.name.toString(),
              phoneNumber: entry.number.toString(),
              callType: entry.callType
                  .toString()
                  .substring(entry.callType.toString().indexOf('.') + 1),
              duration: entry.duration.toString(),
              timeStamp: entry.timestamp!.toString(),
              simSlot: entry.simDisplayName ?? "NIL",
              callRecordFilePath: "",
              isUploaded: true,
              isDeleted: false,
              isEnabled: false);
          await HiveUtil.addCallLog(hiveCallLog);
        }
      }

      if (context.mounted) {
        Navigator.pop(context);
        getSharedData();
        getData();
      }
    } else {
      Common.toastMessaage(object1.message, Colors.red);
      if (context.mounted) {
        Navigator.pop(context);
      }
    }

    setState(() {
      history.clear();
      historyIndex.clear();
      selectAll = false;
      onLongPress = false;
    });
  }

  Future<void> deleteHiveData() async {
    log('delete hive data function called');
    final List<HiveCaallHistoryModel> hiveDataLength =
        await HiveUtil.getAllCallLogs();
    log('hiveDataLength : ${hiveDataLength.length}');
    // if (hiveDataLength.length > 250) {
    if (hiveDataLength.length > 1000) {
      List<HiveCaallHistoryModel> allLogs = await HiveUtil.getAllCallLogs();
      allLogs.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));
      // List<HiveCaallHistoryModel> logsToKeep = allLogs.take(250).toList();
      List<HiveCaallHistoryModel> logsToKeep = allLogs.take(1000).toList();
      List<String> idsToKeep = logsToKeep.map((e) => e.id).toList();
      List<String> idsToDelete = allLogs
          .where((log) => !idsToKeep.contains(log.id))
          .map((log) => log.id)
          .toList();
      log('IDs to delete: $idsToDelete');
      for (var id in idsToDelete) {
        await HiveUtil.deleteCallLog(id);
      }
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String fifthTimeStamp = logsToKeep.last.timeStamp;
      log('5th item timestamp to use later: $fifthTimeStamp');
      prefs.setString('callLogsStartingTime', fifthTimeStamp);
      log('Old call logs deleted, only 5 kept');
    } else {
      log('No need to delete old call logs, less than 5 entries found');
    }
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //    getSharedData();
  // }

  Future<void> loadHiveData() async {
    fullHiveData.clear();
    final List<HiveCaallHistoryModel> hiveData =
        await HiveUtil.getAllCallLogs();
    log('hiveData LENGTH MAIN: ${hiveData.length}');
    for (var entry in hiveData) {
      log('Entry 1 MAIN : ${entry.name} || ${entry.phoneNumber} || ${entry.isUploaded} || ${entry.timeStamp}');
    }
    setState(() {
      fullHiveData = hiveData;
      // You might also refresh _callLogEntries here if needed
      refresh = false;
    });
  }

  void askUserNeedsOld(BuildContext context, bool showPopUp) async {
    askUserNeeds(context, showPopUp);
  }

  void askUserNeeds(BuildContext context, bool showPopUp) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> callTypes = prefs.getStringList('callTypes') ?? [];
    if (await Permission.phone.status.isDenied) {
      await Permission.phone.request();
    }
    if (_activeSims.isEmpty) {
      try {
        final result = await _simChannel.invokeMethod('getActiveSims');
        if (result != null) {
          _activeSims = List<Map<dynamic, dynamic>>.from(result);
        }
      } catch (e) {
        log('Error getting active SIMs for dialog: $e');
      }
    }

    final hasSim2 = _activeSims.any((s) => s['simSlotIndex'] == 1 || s['simSlotIndex'] == '1') || _activeSims.length >= 2;
    List<String> simOptions = ['SIM 1'];
    if (hasSim2) {
      simOptions.add('SIM 2');
    }

    String? savedSim = prefs.getString('selectedSim');
    String selectedDialogSim = (savedSim == 'SIM 2' && hasSim2) ? 'SIM 2' : 'SIM 1';
    if (_selectedSimFilter == 'SIM 2' && hasSim2) {
      selectedDialogSim = 'SIM 2';
    } else if (_selectedSimFilter == 'SIM 1') {
      selectedDialogSim = 'SIM 1';
    }

    if (callTypes.isEmpty || showPopUp) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: StatefulBuilder(
              builder: (context, setDialogState) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Center(child: Text('Permission Required')),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        //! Call Type Selection
                        const Text('Select Call Type',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setDialogState(() {
                                  if (callTypes.contains('Incoming')) {
                                    callTypes.remove('Incoming');
                                  } else {
                                    callTypes.add('Incoming');
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                decoration: BoxDecoration(
                                  color: callTypes.contains('Incoming')
                                      ? Colors.green
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.call_received,
                                        color: Colors.red),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Incoming',
                                      style: TextStyle(
                                        color: callTypes.contains('Incoming')
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {
                                setDialogState(() {
                                  if (callTypes.contains('Outgoing')) {
                                    callTypes.remove('Outgoing');
                                  } else {
                                    callTypes.add('Outgoing');
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                decoration: BoxDecoration(
                                  color: callTypes.contains('Outgoing')
                                      ? Colors.green
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.call_made,
                                        color: Colors.blue),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Outgoing',
                                      style: TextStyle(
                                        color: callTypes.contains('Outgoing')
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),
                        const Text('Select SIM',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: simOptions.map((simName) {
                            final isSelected = selectedDialogSim == simName;
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: GestureDetector(
                                onTap: () {
                                  setDialogState(() {
                                    selectedDialogSim = simName;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 15),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.green
                                        : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.sim_card,
                                          size: 18,
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.blueGrey),
                                      const SizedBox(width: 5),
                                      Text(
                                        simName,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.black,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 15),

                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'We collect and upload your call logs (duration & timestamps) to secure servers. '
                            'This helps your company’s admin track activities. Your data is encrypted and handled securely under our privacy policy.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                  actions: [
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        DashboardLeadNewUpdatedTwo(
                                            widget.token)),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: const Text(
                              'Deny',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              await prefs.setStringList('callTypes', callTypes);
                              await prefs.setString('callLogsStartingTime',
                                  DateTime.now().toString());
                              await prefs.setString('selectedSim', selectedDialogSim);
                              await Permission.phone.request();
                              await Common.saveSharedPref(
                                  "callLogPermission", 'true');
                              if (mounted) {
                                setState(() {
                                  _selectedSimFilter = selectedDialogSim;
                                  refresh = true;
                                });
                                Navigator.of(context).pop();
                                getSharedData();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: const Text(
                              'Submit & Allow',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          );
        },
      );
    }
  }

  List<HiveCaallHistoryModel> fullHiveData = [];

  static const MethodChannel _simChannel = MethodChannel('com.login2Pro/sim_info');

  Future<Iterable<CallLogEntry>> _queryAndDebugCallLogs(
      int? dateFrom, int? dateTo) async {
    try {
      final result = await _simChannel.invokeMethod('getActiveSims');
      if (result != null) {
        _activeSims = List<Map<dynamic, dynamic>>.from(result);
      }
    } catch (e) {
      log('Error getting active SIMs: $e');
    }

    // Reset filter if selected SIM is no longer available
    final hasSim2 = _activeSims.any((s) => s['simSlotIndex'] == 1 || s['simSlotIndex'] == '1') || _activeSims.length >= 2;
    if (_selectedSimFilter == 'SIM 2' && !hasSim2) {
      _selectedSimFilter = 'SIM 1';
    }

    final Iterable<CallLogEntry> callResult = await CallLog.query(
      dateFrom: dateFrom,
      dateTo: dateTo,
    );
    return callResult;
  }

  /// Returns the simSlotIndex for a call log entry by matching
  /// entry.phoneAccountId against native active SIM subscriptionId.
  /// Returns 0 for SIM 1, 1 for SIM 2, -1 for unknown/unmatched.
  int _getSimSlotForEntry(CallLogEntry entry) {
    final phoneAccountId = entry.phoneAccountId;
    if (phoneAccountId == null || phoneAccountId.isEmpty) return -1;
    for (var sim in _activeSims) {
      final subId = sim['subscriptionId']?.toString();
      if (subId != null && subId.isNotEmpty && phoneAccountId == subId) {
        final slotIdx = sim['simSlotIndex'];
        if (slotIdx is int) return slotIdx;
        return int.tryParse(slotIdx?.toString() ?? '') ?? -1;
      }
    }
    return -1;
  }

  /// Returns 'SIM 1' or 'SIM 2' based on the call's resolved simSlotIndex.
  /// Preserves entry.simDisplayName ?? 'NIL' if the SIM slot cannot be determined.
  String _getSimNameForEntry(CallLogEntry entry) {
    final slot = _getSimSlotForEntry(entry);
    if (slot == 0) return 'SIM 1';
    if (slot == 1) return 'SIM 2';
    if (slot > 1) return 'SIM ${slot + 1}';
    return entry.simDisplayName ?? 'NIL';
  }

  /// Returns the filtered call log entries based on the current SIM filter.
  /// 'All' shows everything, 'SIM 1' shows simSlotIndex == 0,
  /// 'SIM 2' shows simSlotIndex == 1.
  /// Unknown/unmatched entries are shown under 'All' only.
  /// Returns the filtered call log entries based on the current SIM filter.
  /// 'SIM 1' shows simSlotIndex == 0,
  /// 'SIM 2' shows simSlotIndex == 1.
  /// If SIM detection has no data, falls back to all call logs safely.
  List<CallLogEntry> get _filteredCallLogEntries {
    if (_activeSims.isEmpty) {
      return _callLogEntries.toList();
    }
    final targetSlot = _selectedSimFilter == 'SIM 2' ? 1 : 0;
    return _callLogEntries.where((entry) {
      return _getSimSlotForEntry(entry) == targetSlot;
    }).toList();
  }

  /// Filters CallLogEntry list by the selected SIM for automatic upload.
  /// SIM 1 -> simSlotIndex == 0
  /// SIM 2 -> simSlotIndex == 1
  /// If SIM detection has no data, returns entries unchanged.
  List<CallLogEntry> _filterBySelectedSim(List<CallLogEntry> entries) {
    if (_activeSims.isEmpty) {
      return entries;
    }
    final targetSlot = _selectedSimFilter == 'SIM 2' ? 1 : 0;
    return entries.where((entry) {
      return _getSimSlotForEntry(entry) == targetSlot;
    }).toList();
  }

  /// Filters Hive call log records by the selected SIM for automatic upload (Path B).
  /// 1. First tries matching each Hive record with device CallLogEntry by phoneNumber + timeStamp or timeStamp.
  /// 2. If matched, resolves SIM using _getSimSlotForEntry().
  /// 3. Fallback: checks if hiveLog.simSlot matches a uniquely identifiable active SIM name.
  /// If SIM detection has no data, returns hiveLogs unchanged.
  List<HiveCaallHistoryModel> _filterHiveLogsBySelectedSim(
      List<HiveCaallHistoryModel> hiveLogs, Iterable<CallLogEntry> deviceLogs) {
    if (_activeSims.isEmpty) {
      return hiveLogs;
    }
    final targetSlot = _selectedSimFilter == 'SIM 2' ? 1 : 0;

    // Build lookup map of device entries
    Map<String, CallLogEntry> deviceMap = {};
    for (var entry in deviceLogs) {
      if (entry.number != null && entry.timestamp != null) {
        deviceMap["${entry.number}_${entry.timestamp}"] = entry;
      }
      if (entry.timestamp != null) {
        deviceMap["${entry.timestamp}"] = entry;
      }
    }

    // Determine distinct SIM names for slot 0 vs slot 1 for safe fallback
    Set<String> slot0Names = {};
    Set<String> slot1Names = {};
    for (var sim in _activeSims) {
      final slotIdx = sim['simSlotIndex'] is int
          ? sim['simSlotIndex'] as int
          : int.tryParse(sim['simSlotIndex']?.toString() ?? '') ?? -1;
      final disp = sim['displayName']?.toString().trim();
      final carrier = sim['carrierName']?.toString().trim();
      if (slotIdx == 0) {
        if (disp != null && disp.isNotEmpty) slot0Names.add(disp.toLowerCase());
        if (carrier != null && carrier.isNotEmpty) slot0Names.add(carrier.toLowerCase());
      } else if (slotIdx == 1) {
        if (disp != null && disp.isNotEmpty) slot1Names.add(disp.toLowerCase());
        if (carrier != null && carrier.isNotEmpty) slot1Names.add(carrier.toLowerCase());
      }
    }
    bool hasDistinctSimNames = slot0Names.isNotEmpty &&
        slot1Names.isNotEmpty &&
        slot0Names.intersection(slot1Names).isEmpty;

    return hiveLogs.where((hiveLog) {
      // Step 1: Match against device entries
      CallLogEntry? matchedDeviceEntry =
          deviceMap["${hiveLog.phoneNumber}_${hiveLog.timeStamp}"] ??
              deviceMap[hiveLog.timeStamp] ??
              deviceMap[hiveLog.id];

      if (matchedDeviceEntry != null) {
        final slot = _getSimSlotForEntry(matchedDeviceEntry);
        if (slot != -1) {
          return slot == targetSlot;
        }
      }

      // Step 2: Fallback to simSlot if uniquely identifiable and distinct
      if (hasDistinctSimNames &&
          hiveLog.simSlot.isNotEmpty &&
          hiveLog.simSlot != "NIL") {
        final cleanSimSlot = hiveLog.simSlot.trim().toLowerCase();
        final inSlot0 = slot0Names.contains(cleanSimSlot);
        final inSlot1 = slot1Names.contains(cleanSimSlot);
        if (inSlot0 && !inSlot1) {
          return targetSlot == 0;
        } else if (inSlot1 && !inSlot0) {
          return targetSlot == 1;
        }
      }

      // Step 3: Cannot reliably resolve - do not guess slot
      return false;
    }).toList();
  }


  
  getSharedData() async {
    log('getSharedData called');
    try {
      refresh = true;
      permissionAccess = await Common.getSharedPref("callLogPermission");
      final isAllowed = permissionAccess == 'true';
      debugPrint("callLogPermission now: $isAllowed");
      uploadPermission = await Common.getSharedPref("uploadCallLog");
      String? deleteAccessStr =
          await Common.getSharedPref("accessCallHistoryPermission");
      roleId = await Common.getSharedPref("roleId");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedSimPref = prefs.getString('selectedSim');
      if (savedSimPref != null && (savedSimPref == 'SIM 1' || savedSimPref == 'SIM 2')) {
        _selectedSimFilter = savedSimPref;
      }
      if (uploadPermission != "true" && Platform.isIOS) {
        selectedIndex = -1;
      }
      setState(() {
        deleteAccess = deleteAccessStr == "true";
      });
      if (permissionAccess == 'true') {
        if (await Permission.phone.request().isGranted) {
          final List<CallLogToggleEvent> toggleHistory =
              await ToggleStorage.getToggleHistory();
          int to = DateTime.now().millisecondsSinceEpoch;

          final Iterable<CallLogEntry> result =
              await _queryAndDebugCallLogs(from, to);
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

          setState(() {
            fullHiveData = hiveData;
            _callLogEntries = filteredLogs;
            refresh = false;
          });
        }
      }
      // !   UPDATE MISSING CALL LOG
      final int callLogCount = await HiveUtil.getCallLogCount();
      prefs = await SharedPreferences.getInstance();
      List<HiveCaallHistoryModel> callLogData = <HiveCaallHistoryModel>[];
      callLogData.clear();
      final String dateTimeFrom =
          prefs.getString('callLogsStartingTime').toString();
      //  List<String> callTypesQ = prefs.getStringList('callTypes') ?? [];
      //       log('callTypes : $callTypesQ');
      if (callLogCount == 0) {
        log('No call logs found in Hive.');

        final DateTime startingTime = DateTime.parse(dateTimeFrom);
        // final List<CallLogToggleEvent> toggleHistory = await ToggleStorage.getToggleHistory();
        int to = DateTime.now().millisecondsSinceEpoch;
        final Iterable<CallLogEntry> result =
            await _queryAndDebugCallLogs(from, to);
        List<CallLogEntry> filteredLogs = result.where((entry) {
          final DateTime callTime =
              DateTime.fromMillisecondsSinceEpoch(entry.timestamp ?? 0);

          // Only logs AFTER startingTime + pass your custom toggle filter
          return callTime.isAfter(startingTime);
        }).toList();
        filteredLogs = _filterBySelectedSim(filteredLogs);
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
            } else if (callTypesQ.contains('Incoming') &&
                callLog.callType.toString().contains('missed')) {
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
                simSlot: _getSimNameForEntry(callLog),
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
          }
          await loadHiveData();
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
        int to = DateTime.now().millisecondsSinceEpoch;
        final Iterable<CallLogEntry> result =
            await _queryAndDebugCallLogs(from, to);

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

        // final List<HiveCaallHistoryModel> hiveData =
        //     await HiveUtil.getAllCallLogs();

        // final HiveCaallHistoryModel latestHiveCallLog2 =
        //     await HiveUtil.getLatestCallLogByTime() ?? hiveData.first;
        // log('latestHiveCallLog2 : ${latestHiveCallLog2.name} || ${latestHiveCallLog2.phoneNumber} || ${latestHiveCallLog2.isUploaded} || ${latestHiveCallLog2.isEnabled}');
        // final HiveCaallHistoryModel latestHiveCallLog2 =
        //     await HiveUtil.getLatestCallLogByTime() ?? hiveData.first;
        // log('latestHiveCallLog2 : ${latestHiveCallLog2.name} || ${latestHiveCallLog2.phoneNumber} || ${latestHiveCallLog2.isUploaded} || ${latestHiveCallLog2.isEnabled}');
        // final List<HiveCaallHistoryModel> unuploadedHiveLogs = hiveData
        //     .where((log) =>
        //         log.isUploaded == false &&
        //         log.isEnabled == false &&
        //         log.isDeleted == false)
        //     .toList();

        // if (unuploadedHiveLogs.isNotEmpty) {
        //   log('Found ${unuploadedHiveLogs.length} unuploaded logs in Hive');
        //   await uploadMissingLogsToServer(unuploadedHiveLogs);
        //   for (var log in unuploadedHiveLogs) {
        //     await HiveUtil.markCallLogAsUploaded(log.id);
        //   }

        //   log('Uploaded ${unuploadedHiveLogs.length} previously unuploaded logs from Hive');
        // }
        // final HiveCaallHistoryModel latestHiveCallLog2 =
        //     await HiveUtil.getLatestCallLogByTime() ?? hiveData.first;
        // log('latestHiveCallLog2 : ${latestHiveCallLog2.name} || ${latestHiveCallLog2.phoneNumber} || ${latestHiveCallLog2.isUploaded} || ${latestHiveCallLog2.isEnabled}');

        // final List<HiveCaallHistoryModel> unuploadedHiveLogs = hiveData
        //     .where((log) =>
        //         log.isUploaded == false &&
        //         log.isEnabled == false &&
        //         log.isDeleted == false)
        //     .toList();

        final List<HiveCaallHistoryModel> hiveData =
            await HiveUtil.getAllCallLogs();

        final HiveCaallHistoryModel latestHiveCallLog2 =
            await HiveUtil.getLatestCallLogByTime() ?? hiveData.first;
        log('latestHiveCallLog2 : ${latestHiveCallLog2.name} || ${latestHiveCallLog2.phoneNumber} || ${latestHiveCallLog2.isUploaded} || ${latestHiveCallLog2.isEnabled}');

        List<HiveCaallHistoryModel> unuploadedHiveLogs = hiveData
            .where((log) =>
                log.isUploaded == false &&
                log.isEnabled == true &&
                log.isDeleted == false)
            .toList();
        unuploadedHiveLogs =
            _filterHiveLogsBySelectedSim(unuploadedHiveLogs, result);

        if (unuploadedHiveLogs.isNotEmpty) {
          log('Found ${unuploadedHiveLogs.length} unuploaded logs in Hive');
          setState(() {
            refresh = true;
          });
          bool uploadSuccess =
              await uploadMissingLogsToServer(unuploadedHiveLogs);
          if (uploadSuccess) {
            log('Uploaded ${unuploadedHiveLogs.length} previously unuploaded logs from Hive');
            if (mounted) {
              Common.toastMessaage(
                  "Successfully uploaded ${unuploadedHiveLogs.length} call logs",
                  Colors.green);
              await getSharedData();
              if (selectedIndex == 1) {
                getData();
              }
              printLastUploadedData();
            }
          } else {
            log('Failed to upload logs');
            setState(() {
              refresh = false;
            });
          }
        }

        final hiveLatestDateTime =
            parseCallLogTime(latestHiveCallLog2.timeStamp);
        // final hiveLatestDateTime =
        //     parseCallLogTime(latestHiveCallLog2.timeStamp);

        if (hiveLatestDateTime == deviceLatestCallLogTime) {
          log('Latest Hive Call Log and Device Call Log are same.');
          log('first call log : ${latestHiveCallLog2.isUploaded}');
          return;
        } else {
          log('Latest Hive Call Log and Device Call Log are not same.');
          // List<CallLogEntry> allCallLogsAfterHiveLatestData = await getFilteredCallLogs(hiveLatestDateTime);
          final DateTime startingTime = DateTime.parse(dateTimeFrom);
          // final List<CallLogToggleEvent> toggleHistory = await ToggleStorage.getToggleHistory();

          final Iterable<CallLogEntry> result =
              await _queryAndDebugCallLogs(from, to);
          log('result : ${result.length}');
          List<CallLogEntry> allCallLogsAfterHiveLatestData =
              result.where((entry) {
            final DateTime callTime =
                DateTime.fromMillisecondsSinceEpoch(entry.timestamp ?? 0);

            // Only logs AFTER startingTime + pass your custom toggle filter
            return callTime.isAfter(startingTime);
          }).toList();
          allCallLogsAfterHiveLatestData =
              _filterBySelectedSim(allCallLogsAfterHiveLatestData);
          // final List<CallLogEntry> allCallLogsAfterHiveLatestData = result.where((entry) {
          //   final DateTime callTime = DateTime.fromMillisecondsSinceEpoch(entry.timestamp ?? 0);

          //   // Only logs AFTER startingTime + pass your custom toggle filter
          //   return callTime.isAfter(startingTime) &&
          //         isLogAllowed(entry.timestamp ?? 0, entry.callType!, toggleHistory);
          // }).toList();
          log('Call logs from device after latest hive data : $allCallLogsAfterHiveLatestData');
          log('Call logs from length after latest hive data : ${allCallLogsAfterHiveLatestData.length}');
          // callLogData.addAll(hiveData);
          history.clear();
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
              } else if (callTypesQ.contains('Incoming') &&
                  callLog.callType.toString().contains('missed')) {
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
                simSlot: _getSimNameForEntry(callLog),
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
              log('=== UPLOAD COMPLETED ===');
              printLastUploadedData();
            }

            if (nonDuplicates.isNotEmpty) {
              //  todo : update in HIve
              await HiveUtil.addCallLogs(nonDuplicates);
            }

            await loadHiveData();
            return;
          } else {
            log('No NEW Call Logs found in device.');
          }
        }
      }
    } catch (e) {
      log(e.toString());
      if (mounted) {
        setState(() {
          refresh = false;
        });
      }
    }
  }

  void printLastUploadedData() async {
    log('===== LAST UPLOADED DATA FROM HIVE =====');

    final List<HiveCaallHistoryModel> hiveData =
        await HiveUtil.getAllCallLogs();

    if (hiveData.isEmpty) {
      log('No data in Hive');
      return;
    }

    // Sort by timestamp to get the most recent
    hiveData.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));

    // Get uploaded items only
    final uploadedLogs = hiveData.where((log) => log.isUploaded).toList();

    if (uploadedLogs.isEmpty) {
      log('No uploaded logs found');
      return;
    }

    log('Total uploaded logs: ${uploadedLogs.length}');
    log('Most recent uploaded logs (last 5):');

    // Show last 5 uploaded logs
    for (var i = 0; i < min(5, uploadedLogs.length); i++) {
      final entry = uploadedLogs[i];
      log('[$i] ${DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(int.parse(entry.timeStamp)))}');
      log('     Name: ${entry.name}');
      log('     Phone: ${entry.phoneNumber}');
      log('     Call Type: ${entry.callType}');
      log('     Duration: ${entry.duration}s');
      log('     Is Enabled: ${entry.isEnabled}');
      log('     Sim: ${entry.simSlot}');
      log('---------------------------------');
    }

    // Show the VERY last one in detail
    final lastEntry = uploadedLogs.first;
    log('=== VERY LAST UPLOADED ENTRY ===');
    log('ID: ${lastEntry.id}');
    log('Timestamp: ${lastEntry.timeStamp}');
    log('Date: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(int.parse(lastEntry.timeStamp)))}');
    log('Full Details:');
    log('  - Name: ${lastEntry.name}');
    log('  - Phone: ${lastEntry.phoneNumber}');
    log('  - Call Type: ${lastEntry.callType}');
    log('  - Duration: ${lastEntry.duration} seconds');
    log('  - Sim: ${lastEntry.simSlot}');
    log('  - Is Deleted: ${lastEntry.isDeleted}');
    log('  - Is Enabled: ${lastEntry.isEnabled}');
    log('===============================');
  }

  // Future<void> uploadMissingLogsToServer(
  //     List<HiveCaallHistoryModel> callLogData) async {
  //   log("uploadMissingLogsToServer function called");

  //   List<Map<String, dynamic>> missingLogs = callLogData
  //       .map((log) => {
  //             "name": log.name,
  //             "phone_number": log.phoneNumber,
  //             "callTypes": log.callType
  //                 .toString()
  //                 .substring(log.callType.toString().indexOf('.') + 1),
  //             // "time": DateTime.parse(log.timeStamp).toString(),
  //             "time":
  //                 DateTime.fromMillisecondsSinceEpoch(int.parse(log.timeStamp))
  //                     .toString(), // log.timestamp,
  //             // "time": log.timeStamp.toString(), // log.timestamp,
  //             "duration": log.duration,
  //             "simName": log.simSlot ?? "NIL",
  //             "timeStamp": log.timeStamp,
  //           })
  //       .toList();

  //   log("⚠️ Found ${missingLogs.length} missing logs.");

  //   if (missingLogs.isNotEmpty) {
  //     log('~~ OUTGOING CALL missingLogs : $missingLogs ~~~');
  //     log('~~ OUTGOING CALL length : ${missingLogs.length} ~~~');

  //     Map<String, dynamic> body = {
  //       "token": await Common.getSharedPref("token"),
  //       'log': missingLogs,
  //     };
  //     log('~~ OUTGOING CALL BODY : $body ~~~');

  //     CallLogUploadModel object1 = await HttpService.callLogUpload(body);
  //     log('~~ OUTGOING CALL missingLogs object : ${object1.data} ~~~');
  //     // await HiveUtil.saveCallLog(missingLogs.last);
  //     if (object1.data == true) {
  //       log('~~ OUTGOING CALL success ~~~');
  //       log('success');
  //     } else {
  //       log('~~ OUTGOING CALL failure ~~~');
  //       log('failure');
  //     }
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
      log('~~ UPLOADING LOGS : $missingLogs ~~~');
      log('~~ UPLOADING LOGS length : ${missingLogs.length} ~~~');
      Map<String, dynamic> body = {
        "token": await Common.getSharedPref("token"),
        'log': missingLogs,
      };
      CallLogUploadModel object1 = await HttpService.callLogUpload(body);
      if (object1.data == true) {
        log('~~ UPLOAD SUCCESS ~~~');
        for (var log in callLogData) {
          await HiveUtil.markCallLogAsUploaded(log.id);
        }
        return true;
      } else {
        log('~~ UPLOAD FAILURE ~~~');
        return false;
      }
    }
    return true;
  }

  getData() async {
    commonDetails = await HttpService.addLeadCommonData(widget.token);
    if (commonDetails != null) {
      setState(() {});
    }
    logHistory = await HttpService.callLogHistory(
        widget.token, fromdate, todate, assignStaffId,
        callType: callTypeValue);
    if (logHistory != null) {
      setState(() {
        if (isSearch == false) {
          Navigator.of(context).pop();
        }
      });
    }
  }
  // getData() async {
  //   commonDetails = await HttpService.addLeadCommonData(widget.token);
  //   if (commonDetails != null) {
  //     setState(() {});
  //   }

  //   logHistory = await HttpService.callLogHistory(
  //       widget.token, fromdate, todate, assignStaffId);

  //   if (logHistory != null) {
  //     setState(() {
  //       if (isSearch == false && Navigator.canPop(context)) {
  //         Navigator.of(context).pop();
  //       }
  //     });
  //   }
  // }

  // void getSimDetails() async {
  //   try {
  //     simList.clear();
  //     // SimData simData = await SimDataPlugin.getSimData();
  //     final List<SimCard>? simData = await MobileNumber.getSimCards;
  //     for (var s in simData!.reversed) {
  //       log('id: ${s.slotIndex! + 1}');
  //       simList.add({"id": s.slotIndex! + 1, "name": s.displayName});
  //     }
  //     if (simList.length > 1) {
  //       simList.add({"id": "", "name": "Both"});
  //     } else if (simList.length == 1) {
  //       selectedSimId = simList[0]["id"].toString();
  //       selectedSim = simList[0]["name"].toString();
  //     }
  //   } on PlatformException catch (e) {
  //     log("error! code: ${e.code} - message: ${e.message}");
  //   }
  // }

  getPermission() async {
    Map<String, dynamic> body2 = {
      "token": await Common.getSharedPref("token"),
    };
    callUploadPermission = await HttpService.callLogUploadPermission(body2);
    if (callUploadPermission != null) {
      setState(() {});
    }
  }

  Iterable<CallLogEntry> _callLogEntries = <CallLogEntry>[];
  @override
  Widget build(BuildContext context) {
    int to = DateTime.now().millisecondsSinceEpoch;
    return RefreshIndicator(
      onRefresh: () async {
        await deleteHiveData();
        getSharedData();
        getPermission();
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade200,
        appBar: PreferredSize(
          preferredSize:
              Size.fromHeight(MediaQuery.of(context).size.height * 0.08),
          child: Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 10.0, top: 10.0, bottom: 10.0, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          height: 25,
                          width: 25,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              shape: BoxShape.circle),
                          child: const Icon(
                            Icons.arrow_back_ios_outlined,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 25),
                      const Text(
                        'Call Logs',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Select All Checkbox - Only show when in call logs tab (selectedIndex == 0)
                      if (selectedIndex == 0 && permissionAccess == 'true')
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                toggleSelectAll();
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    selectAll
                                        ? Icons.check_box
                                        : Icons.check_box_outline_blank,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Select All',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                ],
                              ),
                            ),
                            if (historyIndex.isNotEmpty || selectAll)
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 13,
                                    backgroundColor: Colors.white,
                                    child: Text(
                                      selectAll
                                          ? _callLogEntries.length.toString()
                                          : history.length.toString(),
                                      style: const TextStyle(
                                          color: Colors.blue, fontSize: 17),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  if (uploadPermission == "true")
                                    InkWell(
                                      onTap: () async {
                                        if (selectAll) {
                                          await bulkUploadAll();
                                        } else {
                                          bulkUpload();
                                        }
                                      },
                                      child: const Icon(
                                        Icons.upload,
                                        size: 30,
                                        color: Colors.white,
                                      ),
                                    ),
                                ],
                              ),
                          ],
                        ),

                      deleteHistoryIds.isNotEmpty
                          ? InkWell(
                              onTap: () {
                                if (deleteAccess) {
                                  deleteDialog(context);
                                } else {
                                  Common.toastMessaage(
                                      "Permission required to delete call history",
                                      Colors.red);
                                }
                              },
                              child: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ))
                          : const SizedBox(),

                      // Settings menu
                      callUploadPermission != null
                          ? Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: GestureDetector(
                                onTap: () async {
                                  displayOverApps = await Permission
                                      .systemAlertWindow.isGranted;
                                  if (mounted) {
                                    mainPopupButton(context)
                                        .then((value) async {
                                      if (value != null) {
                                        if (value == '1') {
                                          Map<String, dynamic> body = {
                                            "token": await Common.getSharedPref(
                                                "token"),
                                            "type": "incoming"
                                          };
                                          CallLogUploadPermissionUpdateModel
                                              perm = await HttpService
                                                  .callLogUploadPermissionUpdate(
                                                      body);
                                          Common.toastMessaage(
                                              perm.message, Colors.green);
                                          getPermission();
                                          setState(() {});
                                        } else if (value == '2') {
                                          Map<String, dynamic> body = {
                                            "token": await Common.getSharedPref(
                                                "token"),
                                            "type": "outgoing"
                                          };
                                          CallLogUploadPermissionUpdateModel
                                              perm = await HttpService
                                                  .callLogUploadPermissionUpdate(
                                                      body);
                                          Common.toastMessaage(
                                              perm.message, Colors.green);
                                          getPermission();
                                          setState(() {});
                                        } else if (value == '3') {
                                          if (await Permission
                                              .systemAlertWindow.isGranted) {
                                            openAppSettings();
                                          } else {
                                            Config.requestPermission();
                                          }
                                        } else if (value == '4') {
                                          selectSim(context);
                                        } else if (value == '6') {
                                          askUserNeedsOld(context, true);
                                        }
                                      }
                                    });
                                  }
                                },
                                child: const Icon(
                                  Icons.more_vert_rounded,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : const SizedBox()
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
        // appBar: PreferredSize(
        //   preferredSize:
        //       Size.fromHeight(MediaQuery.of(context).size.height * 0.08),
        //   child: Container(
        //     padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        //     decoration: const BoxDecoration(
        //       gradient: LinearGradient(
        //           colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
        //     ),
        //     child: Padding(
        //       padding: const EdgeInsets.only(
        //           left: 10.0, top: 10.0, bottom: 10.0, right: 10),
        //       child: Row(
        //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //         children: [
        //           Row(
        //             mainAxisAlignment: MainAxisAlignment.center,
        //             crossAxisAlignment: CrossAxisAlignment.center,
        //             children: [
        //               InkWell(
        //                 onTap: () {
        //                   Navigator.pop(context);
        //                 },
        //                 child: Container(
        //                   height: 25,
        //                   width: 25,
        //                   decoration: BoxDecoration(
        //                       border: Border.all(color: Colors.white),
        //                       shape: BoxShape.circle),
        //                   child: const Icon(
        //                     Icons.arrow_back_ios_outlined,
        //                     color: Colors.white,
        //                     size: 16,
        //                   ),
        //                 ),
        //               ),
        //               const SizedBox(
        //                 width: 25,
        //               ),
        //               const Text(
        //                 'Call Logs',
        //                 style: TextStyle(color: Colors.white, fontSize: 18),
        //               ),
        //             ],
        //           ),
        //           Row(
        //             children: [
        //               uploadPermission == "true" && onLongPress
        //                   ? Row(
        //                       children: [
        //                         CircleAvatar(
        //                           radius: 13,
        //                           backgroundColor: Colors.white,
        //                           child: Text(
        //                             history.length.toString(),
        //                             style: const TextStyle(
        //                                 color: Colors.blue, fontSize: 17),
        //                           ),
        //                         ),
        //                         const SizedBox(
        //                           width: 15,
        //                         ),
        //                         InkWell(
        //                           onTap: () async {
        //                             bulkUpload();
        //                           },
        //                           child: const Icon(
        //                             Icons.upload,
        //                             size: 30,
        //                           ),
        //                         ),
        //                       ],
        //                     )
        //                   : const SizedBox(),
        //               deleteHistoryIds.isNotEmpty
        //                   ? InkWell(
        //                       onTap: () {
        //                         if (deleteAccess) {
        //                           deleteDialog(context);
        //                         } else {
        //                           Common.toastMessaage(
        //                               "Permission required to delete call history",
        //                               Colors.red);
        //                         }
        //                       },
        //                       child: const Icon(
        //                         Icons.delete,
        //                         color: Colors.red,
        //                       ))
        //                   : const SizedBox(),
        //               callUploadPermission != null
        //                   ? Padding(
        //                       padding:
        //                           const EdgeInsets.only(left: 10, right: 10),
        //                       child: GestureDetector(
        //                         onTap: () async {
        //                           displayOverApps = await Permission
        //                               .systemAlertWindow.isGranted;
        //                           if (mounted) {
        //                             mainPopupButton(context)
        //                                 .then((value) async {
        //                               if (value != null) {
        //                                 if (value == '1') {
        //                                   Map<String, dynamic> body = {
        //                                     "token": await Common.getSharedPref(
        //                                         "token"),
        //                                     "type": "incoming"
        //                                   };
        //                                   CallLogUploadPermissionUpdateModel
        //                                       perm = await HttpService
        //                                           .callLogUploadPermissionUpdate(
        //                                               body);
        //                                   Common.toastMessaage(
        //                                       perm.message, Colors.green);
        //                                   getPermission();
        //                                   setState(() {});
        //                                 } else if (value == '2') {
        //                                   Map<String, dynamic> body = {
        //                                     "token": await Common.getSharedPref(
        //                                         "token"),
        //                                     "type": "outgoing"
        //                                   };
        //                                   CallLogUploadPermissionUpdateModel
        //                                       perm = await HttpService
        //                                           .callLogUploadPermissionUpdate(
        //                                               body);
        //                                   Common.toastMessaage(
        //                                       perm.message, Colors.green);
        //                                   getPermission();
        //                                   setState(() {});
        //                                 } else if (value == '3') {
        //                                   if (await Permission
        //                                       .systemAlertWindow.isGranted) {
        //                                     openAppSettings();
        //                                   } else {
        //                                     Config.requestPermission();
        //                                   }
        //                                 } else if (value == '4') {
        //                                   selectSim(context);
        //                                 } else if (value == '6') {
        //                                   askUserNeedsOld(context, true);
        //                                 }
        //                               }
        //                             });
        //                           }
        //                         },
        //                         child: const Icon(
        //                           Icons.more_vert_rounded,
        //                           color: Colors.white,
        //                         ),
        //                       ),
        //                     )
        //                   : const SizedBox()
        //             ],
        //           )
        //         ],
        //       ),
        //     ),
        //   ),
        // ),
        body: permissionAccess == 'true' || Platform.isIOS
            ? SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              if (Platform.isAndroid) {
                                setState(() {
                                  selectedIndex = 0;
                                  deleteHistoryIds.clear();
                                  onLongPress = false;
                                  selectAll = false;
                                  history.clear();
                                  historyIndex.clear();
                                  isSearch = true;
                                });
                              } else {
                                Common.toastMessaage(
                                    "i phone can't access call logs",
                                    Colors.red);
                              }
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * .45,
                              height: 30,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: selectedIndex == 0
                                          ? Colors.grey
                                          : Colors.white,
                                      width: 0),
                                  color: selectedIndex == 0
                                      ? const Color(0xFFd5f5f4)
                                      : Colors.white,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(6))),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Call Logs',
                                      style: TextStyle(
                                        color: Platform.isIOS
                                            ? Colors.grey.shade300
                                            : selectedIndex == 0
                                                ? const Color(0xFF3c9f9a)
                                                : const Color(0xFF717171),
                                      ),
                                    ),
                                    Text(
                                      ' (${_filteredCallLogEntries.length})',
                                      style: TextStyle(
                                        color: Platform.isIOS
                                            ? Colors.grey.shade300
                                            : selectedIndex == 0
                                                ? const Color(0xFF3c9f9a)
                                                : const Color(0xFF717171),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              if (uploadPermission == "true") {
                                setState(() {
                                  selectedIndex = 1;
                                  history.clear();
                                  historyIndex.clear();
                                });
                                getData();
                              } else {
                                Common.toastMessaage(
                                    "Permission required to access call history",
                                    Colors.red);
                              }
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * .45,
                              height: 30,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: selectedIndex == 1
                                          ? Colors.grey
                                          : Colors.white,
                                      width: 0),
                                  color: selectedIndex == 1
                                      ? const Color(0xFFd5f5f4)
                                      : Colors.white,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(6))),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Call History',
                                      style: TextStyle(
                                        color: selectedIndex == 1
                                            ? const Color(0xFF3c9f9a)
                                            : const Color(0xFF717171),
                                      ),
                                    ),
                                    if (logHistory != null)
                                      Text(
                                        ' (${logHistory!.data!.lists!.length})',
                                        style: TextStyle(
                                          color: selectedIndex == 1
                                              ? const Color(0xFF3c9f9a)
                                              : const Color(0xFF717171),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    selectedIndex == 0
                        ? Column(
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              //Text(_callLogEntries as String),
                              refresh == false
                                  ? Column(
                                      children: [
                                        Text(
                                          '${DateFormat('dd-M-yyyy').format(DateTime.fromMillisecondsSinceEpoch(from))} - ${DateFormat('dd-M-yyyy').format(DateTime.fromMillisecondsSinceEpoch(to))} (Last 3 Days)',
                                          style: const TextStyle(
                                            fontSize: 16,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(
                                            height: 10,
                                          ),
                                        _filteredCallLogEntries.isNotEmpty
                                            ? ListView.builder(
                                                shrinkWrap: true,
                                                itemCount:
                                                    _filteredCallLogEntries.length,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemBuilder:
                                                    (context, indexStaff) {
                                                  final entry = _filteredCallLogEntries
                                                      .elementAt(indexStaff);
                                                  //  bool isUploaded = fullHiveData.any((item) => item.id == entry.timestamp.toString());
                                                  bool isUploaded =
                                                      fullHiveData.any((item) =>
                                                          item.id ==
                                                              entry.timestamp
                                                                  .toString() &&
                                                          item.isUploaded ==
                                                              true);
                                                  //  log('isUploaded :  ${entry.name} || $isUploaded');
                                                  //  for (var item in fullHiveData) {
                                                  //    log('item : ${item.name} || ${item.phoneNumber} || ${item.isUploaded} || ${item.isEnabled}');
                                                  //  }
                                                  //   log('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');

                                                  return Visibility(
                                                    // visible: selectedSimId ==
                                                    //         "" ||
                                                    //     selectedSimId ==
                                                    //         _callLogEntries
                                                    //             .elementAt(
                                                    //                 indexStaff)
                                                    //             .phoneAccountId,
                                                    child: Dismissible(
                                                      key: const Key('0'),
                                                      background: Container(
                                                        color: Colors.green,
                                                        child: const Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: <Widget>[
                                                              SizedBox(
                                                                width: 20,
                                                              ),
                                                              Icon(
                                                                Icons.call,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              Text(
                                                                " Call",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .left,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      secondaryBackground:
                                                          Container(
                                                        color: Colors.blue,
                                                        child: const Align(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: <Widget>[
                                                              Icon(
                                                                Icons.add,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              Text(
                                                                "Add Lead",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .right,
                                                              ),
                                                              SizedBox(
                                                                width: 20,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      confirmDismiss:
                                                          (direction) async {
                                                        if (direction ==
                                                            DismissDirection
                                                                .startToEnd) {
                                                          // await FlutterPhoneDirectCaller
                                                          //     .callNumber(_callLogEntries
                                                          //         .elementAt(
                                                          //             indexStaff)
                                                          //         .number
                                                          //         .toString());
                                                          Common.dialPad(
                                                              _callLogEntries
                                                                  .elementAt(
                                                                      indexStaff)
                                                                  .number
                                                                  .toString());
                                                        } else {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        AddLeadsNew(
                                                                  widget.token,
                                                                  clientName: _callLogEntries
                                                                      .elementAt(
                                                                          indexStaff)
                                                                      .name,
                                                                  phoneNumber: _callLogEntries
                                                                      .elementAt(
                                                                          indexStaff)
                                                                      .number,
                                                                ),
                                                              ));
                                                        }

                                                        return null;
                                                      },
                                                      child: InkWell(
                                                          onLongPress: () {
                                                            log(_callLogEntries
                                                                .elementAt(
                                                                    indexStaff)
                                                                .phoneAccountId
                                                                .toString());
                                                            if (historyIndex
                                                                .contains(
                                                                    indexStaff)) {
                                                              historyIndex.remove(
                                                                  indexStaff);
                                                              history
                                                                  .removeWhere(
                                                                (item) =>
                                                                    mapEquals(
                                                                        item,
                                                                        ({
                                                                          "name": _callLogEntries
                                                                              .elementAt(indexStaff)
                                                                              .name,
                                                                          "phone_number": _callLogEntries
                                                                              .elementAt(indexStaff)
                                                                              .number,
                                                                          "callTypes": _callLogEntries
                                                                              .elementAt(indexStaff)
                                                                              .callType
                                                                              .toString()
                                                                              .substring(_filteredCallLogEntries.elementAt(indexStaff).callType.toString().indexOf('.') + 1),
                                                                          "time":
                                                                              '${DateTime.fromMillisecondsSinceEpoch(_filteredCallLogEntries.elementAt(indexStaff).timestamp!)}',
                                                                          "duration": _callLogEntries
                                                                              .elementAt(indexStaff)
                                                                              .duration,
                                                                          "simName":
                                                                              _filteredCallLogEntries.elementAt(indexStaff).simDisplayName ?? "NIL",
                                                                          "timeStamp": _callLogEntries
                                                                              .elementAt(indexStaff)
                                                                              .timestamp,
                                                                        })),
                                                              );
                                                            } else {
                                                              setState(() {
                                                                onLongPress =
                                                                    true;
                                                                history.add({
                                                                  "name": _callLogEntries
                                                                          .elementAt(
                                                                              indexStaff)
                                                                          .name ??
                                                                      "",
                                                                  "phone_number":
                                                                      _callLogEntries
                                                                          .elementAt(
                                                                              indexStaff)
                                                                          .number,
                                                                  "callTypes": _callLogEntries
                                                                      .elementAt(
                                                                          indexStaff)
                                                                      .callType
                                                                      .toString()
                                                                      .substring(_callLogEntries
                                                                              .elementAt(indexStaff)
                                                                              .callType
                                                                              .toString()
                                                                              .indexOf('.') +
                                                                          1),
                                                                  "time":
                                                                      '${DateTime.fromMillisecondsSinceEpoch(_filteredCallLogEntries.elementAt(indexStaff).timestamp!)}',
                                                                  "duration": _callLogEntries
                                                                      .elementAt(
                                                                          indexStaff)
                                                                      .duration,
                                                                  "simName": _callLogEntries
                                                                          .elementAt(
                                                                              indexStaff)
                                                                          .simDisplayName ??
                                                                      "NIL",
                                                                  "timeStamp": _callLogEntries
                                                                      .elementAt(
                                                                          indexStaff)
                                                                      .timestamp,
                                                                });
                                                                historyIndex.add(
                                                                    indexStaff);
                                                              });
                                                            }
                                                          },
                                                          onTap: () {
                                                            if (onLongPress ==
                                                                true) {
                                                              if (historyIndex
                                                                  .contains(
                                                                      indexStaff)) {
                                                                historyIndex.remove(
                                                                    indexStaff);
                                                                history
                                                                    .removeWhere(
                                                                  (item) =>
                                                                      mapEquals(
                                                                          item,
                                                                          ({
                                                                            "name":
                                                                                _filteredCallLogEntries.elementAt(indexStaff).name,
                                                                            "phone_number":
                                                                                _filteredCallLogEntries.elementAt(indexStaff).number,
                                                                            "callTypes":
                                                                                _filteredCallLogEntries.elementAt(indexStaff).callType.toString().substring(_filteredCallLogEntries.elementAt(indexStaff).callType.toString().indexOf('.') + 1),
                                                                            "time":
                                                                                '${DateTime.fromMillisecondsSinceEpoch(_filteredCallLogEntries.elementAt(indexStaff).timestamp!)}',
                                                                            "duration":
                                                                                _filteredCallLogEntries.elementAt(indexStaff).duration,
                                                                            "simName":
                                                                                _filteredCallLogEntries.elementAt(indexStaff).simDisplayName,
                                                                            "timeStamp":
                                                                                _filteredCallLogEntries.elementAt(indexStaff).timestamp,
                                                                          })),
                                                                );
                                                              } else {
                                                                history.add({
                                                                  "name": _callLogEntries
                                                                          .elementAt(
                                                                              indexStaff)
                                                                          .name ??
                                                                      "",
                                                                  "phone_number":
                                                                      _callLogEntries
                                                                          .elementAt(
                                                                              indexStaff)
                                                                          .number,
                                                                  "callTypes": _callLogEntries
                                                                      .elementAt(
                                                                          indexStaff)
                                                                      .callType
                                                                      .toString()
                                                                      .substring(_callLogEntries
                                                                              .elementAt(indexStaff)
                                                                              .callType
                                                                              .toString()
                                                                              .indexOf('.') +
                                                                          1),
                                                                  "time":
                                                                      '${DateTime.fromMillisecondsSinceEpoch(_filteredCallLogEntries.elementAt(indexStaff).timestamp!)}',
                                                                  "duration": _callLogEntries
                                                                      .elementAt(
                                                                          indexStaff)
                                                                      .duration,
                                                                  "simName": _callLogEntries
                                                                          .elementAt(
                                                                              indexStaff)
                                                                          .simDisplayName ??
                                                                      "NIL",
                                                                  "timeStamp": _callLogEntries
                                                                      .elementAt(
                                                                          indexStaff)
                                                                      .timestamp,
                                                                });
                                                                historyIndex.add(
                                                                    indexStaff);
                                                              }
                                                            }
                                                            if (historyIndex
                                                                .isEmpty) {
                                                              onLongPress =
                                                                  false;
                                                            }
                                                            setState(() {});
                                                          },
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 10,
                                                                    right: 10,
                                                                    bottom: 10),
                                                            child: Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  1,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: historyIndex.contains(
                                                                        indexStaff)
                                                                    ? Colors
                                                                        .blueGrey
                                                                        .shade200
                                                                    : Colors
                                                                        .white,
                                                                boxShadow: const [
                                                                  BoxShadow(
                                                                    color: Colors
                                                                        .grey,
                                                                    offset:
                                                                        Offset(
                                                                            2.0,
                                                                            2.0),
                                                                  )
                                                                ],
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                              ),
                                                              child: Column(
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        top: 10,
                                                                        right:
                                                                            10,
                                                                        left:
                                                                            10),
                                                                    child:
                                                                        Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        // Text(
                                                                        //     'F. NUMBER  : ${_filteredCallLogEntries.elementAt(indexStaff).formattedNumber}'),
                                                                        // Text(
                                                                        //     'C.M. NUMBER: ${_filteredCallLogEntries.elementAt(indexStaff).cachedMatchedNumber}'),
                                                                        Row(
                                                                          children: [
                                                                            Container(
                                                                              constraints: const BoxConstraints(
                                                                                maxHeight: 60,
                                                                              ),
                                                                              child: Container(
                                                                                constraints: const BoxConstraints(
                                                                                  minHeight: 20,
                                                                                  minWidth: 20,
                                                                                  maxHeight: 50,
                                                                                  maxWidth: 50,
                                                                                ),
                                                                                decoration: BoxDecoration(
                                                                                  border: Border.all(color: Colors.white, width: 0),
                                                                                  boxShadow: const [
                                                                                    BoxShadow(color: Colors.grey, blurRadius: 5, offset: Offset(1, 1)),
                                                                                  ],
                                                                                  color: Colors.white,
                                                                                  shape: BoxShape.circle,
                                                                                  image: const DecorationImage(fit: BoxFit.cover, image: AssetImage('assets/main/avatar.png')),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            const SizedBox(
                                                                              width: 20,
                                                                            ),
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              children: [
                                                                                SizedBox(
                                                                                  width: MediaQuery.of(context).size.width * 0.6,
                                                                                  child: Column(
                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: [
                                                                                      Text(
                                                                                        _filteredCallLogEntries.elementAt(indexStaff).name ?? "Unknown",
                                                                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                                                                      ),
                                                                                      const SizedBox(
                                                                                        height: 3,
                                                                                      ),
                                                                                      Text(
                                                                                        _filteredCallLogEntries.elementAt(indexStaff).number.toString(),
                                                                                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                                uploadPermission == "true" && onLongPress != true && isUploaded == false
                                                                                    ? InkWell(
                                                                                        onTap: () async {
                                                                                          Common.showProgressDialog(context, "Loading..");
                                                                                          history.clear();
                                                                                          history.add({
                                                                                            "name": _filteredCallLogEntries.elementAt(indexStaff).name ?? "",
                                                                                            "phone_number": _filteredCallLogEntries.elementAt(indexStaff).number,
                                                                                            "callTypes": _filteredCallLogEntries.elementAt(indexStaff).callType.toString().substring(_filteredCallLogEntries.elementAt(indexStaff).callType.toString().indexOf('.') + 1),
                                                                                            "time": '${DateTime.fromMillisecondsSinceEpoch(_filteredCallLogEntries.elementAt(indexStaff).timestamp!)}',
                                                                                            "duration": _filteredCallLogEntries.elementAt(indexStaff).duration,
                                                                                            "simName": _filteredCallLogEntries.elementAt(indexStaff).simDisplayName ?? "NIL",
                                                                                            "timeStamp": _filteredCallLogEntries.elementAt(indexStaff).timestamp,
                                                                                          });
                                                                                          historyIndex.add(indexStaff);
                                                                                          Map<String, dynamic> body = {
                                                                                            "token": widget.token,
                                                                                            'log': history,
                                                                                          };
                                                                                          CallLogUploadModel object1 = await HttpService.callLogUpload(body);
                                                                                          if (object1.data == true) {
                                                                                            Common.toastMessaage(object1.message, Colors.green);
                                                                                            bool isThisAlreadyInHiveCallLogDb = await HiveUtil.isCallLogWithIdAndNumberExists(_filteredCallLogEntries.elementAt(indexStaff).timestamp.toString(), _filteredCallLogEntries.elementAt(indexStaff).number.toString());
                                                                                            log('isThisAlreadyInHiveCallLogDb : $isThisAlreadyInHiveCallLogDb');
                                                                                            if (isThisAlreadyInHiveCallLogDb) {
                                                                                              log('already in hive');
                                                                                              await HiveUtil.markCallLogAsUploaded(_filteredCallLogEntries.elementAt(indexStaff).timestamp.toString());
                                                                                              log('updated in hive');
                                                                                            } else {
                                                                                              log('not in hive');
                                                                                              try {
                                                                                                HiveCaallHistoryModel hiveCallLog = HiveCaallHistoryModel(
                                                                                                    id: _filteredCallLogEntries.elementAt(indexStaff).timestamp.toString(),
                                                                                                    name: _filteredCallLogEntries.elementAt(indexStaff).name.toString(),
                                                                                                    phoneNumber: _filteredCallLogEntries.elementAt(indexStaff).number.toString(),
                                                                                                    callType: _filteredCallLogEntries.elementAt(indexStaff).callType.toString().substring(_filteredCallLogEntries.elementAt(indexStaff).callType.toString().indexOf('.') + 1),
                                                                                                    duration: _filteredCallLogEntries.elementAt(indexStaff).duration.toString(),
                                                                                                    // timeStamp: '${DateTime.fromMillisecondsSinceEpoch( int.parse(_filteredCallLogEntries.elementAt(indexStaff).timestamp))}',
                                                                                                    // timeStamp: _filteredCallLogEntries.elementAt(indexStaff).timestamp.toString(),
                                                                                                    timeStamp: _filteredCallLogEntries.elementAt(indexStaff).timestamp!.toString(),
                                                                                                    //   DateTime.fromMillisecondsSinceEpoch(
                                                                                                    // _filteredCallLogEntries.elementAt(indexStaff).timestamp!  ).toIso8601String(),
                                                                                                    simSlot: _filteredCallLogEntries.elementAt(indexStaff).simDisplayName ?? "NIL",
                                                                                                    callRecordFilePath: "",
                                                                                                    isUploaded: true,
                                                                                                    isDeleted: false,
                                                                                                    isEnabled: false);
                                                                                                await HiveUtil.addCallLog(hiveCallLog);
                                                                                              } catch (e) {
                                                                                                log('error : ${e.toString()}');
                                                                                              }
                                                                                            }
                                                                                            if (context.mounted) {
                                                                                              Navigator.pop(context);
                                                                                              getSharedData();
                                                                                              getData();
                                                                                            }
                                                                                          } else {
                                                                                            Common.toastMessaage(object1.message, Colors.red);
                                                                                            if (context.mounted) {
                                                                                              Navigator.pop(context);
                                                                                            }
                                                                                          }
                                                                                          //!

                                                                                          //!

                                                                                          setState(() {
                                                                                            history.clear();
                                                                                            historyIndex.clear();
                                                                                          });
                                                                                        },
                                                                                        child: const Icon(Icons.upload))
                                                                                    : isUploaded == true
                                                                                        ? const Icon(
                                                                                            Icons.check_circle,
                                                                                            color: Colors.green,
                                                                                          )
                                                                                        : const Icon(Icons.upload, color: Colors.grey),
                                                                              ],
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              10,
                                                                        ),
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Row(
                                                                              children: [
                                                                                Image.asset("assets/icons/calendar.png", width: 20),
                                                                                const SizedBox(
                                                                                  width: 15,
                                                                                ),
                                                                                Text(
                                                                                  DateFormat('dd-M-yyyy HH:mm a').format(DateTime.fromMillisecondsSinceEpoch(_filteredCallLogEntries.elementAt(indexStaff).timestamp!)),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            Row(
                                                                              children: [
                                                                                const Icon(Icons.timer_outlined),
                                                                                const SizedBox(
                                                                                  width: 10,
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(right: 10),
                                                                                  child: Text(
                                                                                    '${(Duration(seconds: _filteredCallLogEntries.elementAt(indexStaff).duration!))}'.split('.')[0].padLeft(8, '0'),
                                                                                    style: const TextStyle(fontSize: 15, color: Colors.green),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              5,
                                                                        ),
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Text(
                                                                              'Type  : ${_filteredCallLogEntries.elementAt(indexStaff).callType.toString().substring(_filteredCallLogEntries.elementAt(indexStaff).callType.toString().indexOf('.') + 1)}',
                                                                            ),
                                                                            const SizedBox()
                                                                            // Container(
                                                                            //   decoration: BoxDecoration(
                                                                            //       color: Colors.grey.shade300,
                                                                            //       borderRadius: BorderRadius.circular(5)),
                                                                            //   child:
                                                                            //       Padding(
                                                                            //     padding: const EdgeInsets.only(
                                                                            //         left: 10,
                                                                            //         right: 10,
                                                                            //         top: 5,
                                                                            //         bottom: 5),
                                                                            //     child:
                                                                            //         Text(
                                                                            //       '${_filteredCallLogEntries.elementAt(indexStaff).simDisplayName}',
                                                                            //     ),
                                                                            //   ),
                                                                            // ),
                                                                          ],
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              10,
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          )),
                                                    ),
                                                  );
                                                })
                                            : Center(
                                                child: Column(
                                                  children: [
                                                    const SizedBox(
                                                      height: 100,
                                                    ),
                                                    Image.asset(
                                                        'assets/main/noCallLog.png',
                                                        width: 100,
                                                        height: 100,
                                                        fit: BoxFit.fill),
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    const Text(
                                                      'No Calls Found',
                                                      style: TextStyle(
                                                          fontSize: 18),
                                                    )
                                                  ],
                                                ),
                                              ),
                                      ],
                                    )
                                  : Center(
                                      child: Lottie.asset(
                                          'assets/main/loading.json',
                                          fit: BoxFit.fill),
                                    )
                            ],
                          )
                        : Column(
                            children: [
                              logHistory != null && commonDetails != null
                                  ? Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, right: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              GestureDetector(
                                                onTap: () async {
                                                  final selctedDatetimetemp =
                                                      await showDatePicker(
                                                    context: context,
                                                    initialDate: DateTime.now(),
                                                    firstDate: DateTime(2000),
                                                    lastDate: DateTime.now(),
                                                  );
                                                  fromdate = DateFormat(
                                                          'dd-MM-yyyy')
                                                      .format(
                                                          selctedDatetimetemp!);
                                                  setState(() {});
                                                },
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.45,
                                                  height: 45,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      color: Colors.white),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 10),
                                                        child: Text(
                                                          fromdate,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        width: 40,
                                                        height: 40,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(2),
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
                                              GestureDetector(
                                                onTap: () async {
                                                  final toDateSelectTemp =
                                                      await showDatePicker(
                                                    context: context,
                                                    initialDate: DateTime.now(),
                                                    firstDate: DateTime(2000),
                                                    lastDate: DateTime(2100),
                                                  );
                                                  todate = DateFormat(
                                                          'dd-MM-yyyy')
                                                      .format(
                                                          toDateSelectTemp!);
                                                  setState(() {});
                                                },
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.45,
                                                  height: 45,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    color: Colors.white,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 10),
                                                        child: Text(
                                                          todate,
                                                        ),
                                                      ),
                                                      Container(
                                                        width: 40,
                                                        height: 40,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
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
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, right: 10),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    showModalBottomSheet(
                                                      context: context,
                                                      shape:
                                                          const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.vertical(
                                                                top: Radius
                                                                    .circular(
                                                                        20)),
                                                      ),
                                                      builder: (context) {
                                                        return Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(16),
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Container(
                                                                width: 40,
                                                                height: 4,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                          .grey[
                                                                      300],
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              2),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 16),
                                                              const Text(
                                                                'Select Call Type',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 16),
                                                              _buildCallLogTypeOption(
                                                                  'All', ''),
                                                              _buildCallLogTypeOption(
                                                                  'Incoming',
                                                                  'Inbound'),
                                                              _buildCallLogTypeOption(
                                                                  'Outgoing',
                                                                  'Outbound'),
                                                              const SizedBox(
                                                                  height: 16),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: Container(
                                                    height: 45,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      color: Colors.white,
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 10),
                                                          child: Text(
                                                            callType,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                        ),
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  right: 10),
                                                          child: Icon(
                                                            Icons
                                                                .arrow_drop_down,
                                                            color: Colors.grey,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: TextFormField(
                                                    onTap: () {
                                                      staffDialog(context);
                                                    },
                                                    maxLines: 1,
                                                    readOnly: true,
                                                    keyboardType:
                                                        TextInputType.text,
                                                    decoration: InputDecoration(
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .all(3),
                                                        filled: true,
                                                        fillColor: Colors.white,
                                                        prefixIcon: const Icon(
                                                          Icons
                                                              .arrow_drop_down_circle,
                                                          color: Colors.grey,
                                                        ),
                                                        counterText: "",
                                                        hintText: assignStaff ??
                                                            widget.name ??
                                                            'Select Staff',
                                                        hintStyle:
                                                            const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.black,
                                                        ),
                                                        isDense: true,
                                                        border: OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide.none,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5)))),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 15),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, right: 10),
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                search = true;
                                                isSearch = false;
                                              });
                                              Common.showProgressDialog(
                                                  context, "Loading..");
                                              getData();
                                            },
                                            child: Container(
                                              width: double.infinity,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: Colors.black,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: const Center(
                                                child: Text('Search',
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        (logHistory?.data?.lists?.isNotEmpty ??
                                                false)
                                            ? Column(
                                                children: [
                                                  if (logHistory?.data
                                                          ?.totalDuration !=
                                                      null)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10.0),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 15,
                                                                vertical: 10),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .blue.shade50,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          border: Border.all(
                                                              color: Colors.blue
                                                                  .shade200),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            const Text(
                                                              'Total Call Duration:',
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    Colors.blue,
                                                              ),
                                                            ),
                                                            Text(
                                                              logHistory!.data!
                                                                  .totalDuration!,
                                                              style:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 16,
                                                                color:
                                                                    Colors.blue,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ListView.builder(
                                                      shrinkWrap: true,
                                                      itemCount: logHistory!
                                                          .data!.lists!.length,
                                                      physics:
                                                          const NeverScrollableScrollPhysics(),
                                                      itemBuilder:
                                                          (context, index) {
                                                        return Dismissible(
                                                          key: const Key('0'),
                                                          background: Container(
                                                            color: Colors.green,
                                                            child: const Align(
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: <Widget>[
                                                                  SizedBox(
                                                                    width: 20,
                                                                  ),
                                                                  Icon(
                                                                    Icons.call,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  Text(
                                                                    " Call",
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                    ),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          secondaryBackground:
                                                              Container(
                                                            color: Colors.blue,
                                                            child: const Align(
                                                              alignment: Alignment
                                                                  .centerRight,
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: <Widget>[
                                                                  Icon(
                                                                    Icons.add,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  Text(
                                                                    "Add Lead",
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                    ),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .right,
                                                                  ),
                                                                  SizedBox(
                                                                    width: 20,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          confirmDismiss:
                                                              (direction) async {
                                                            if (direction ==
                                                                DismissDirection
                                                                    .startToEnd) {
                                                              Common.dialPad(
                                                                  logHistory!
                                                                      .data!
                                                                      .lists![
                                                                          index]
                                                                      .phoneNumber
                                                                      .toString());
                                                            } else {
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            AddLeadsNew(
                                                                      widget
                                                                          .token,
                                                                      clientName: logHistory!
                                                                          .data!
                                                                          .lists![
                                                                              index]
                                                                          .name,
                                                                      phoneNumber: logHistory!
                                                                          .data!
                                                                          .lists![
                                                                              index]
                                                                          .phoneNumber,
                                                                    ),
                                                                  ));
                                                            }

                                                            return null;
                                                          },
                                                          child: InkWell(
                                                              onLongPress: () {
                                                                setState(() {
                                                                  onLongPressHistory =
                                                                      true;
                                                                  deleteHistoryIds.add(logHistory!
                                                                      .data!
                                                                      .lists![
                                                                          index]
                                                                      .id
                                                                      .toString());
                                                                });
                                                              },
                                                              onTap: () {
                                                                if (onLongPressHistory ==
                                                                    true) {
                                                                  if (deleteHistoryIds.contains(logHistory!
                                                                      .data!
                                                                      .lists![
                                                                          index]
                                                                      .id
                                                                      .toString())) {
                                                                    deleteHistoryIds.remove(logHistory!
                                                                        .data!
                                                                        .lists![
                                                                            index]
                                                                        .id
                                                                        .toString());
                                                                  } else {
                                                                    deleteHistoryIds.add(logHistory!
                                                                        .data!
                                                                        .lists![
                                                                            index]
                                                                        .id
                                                                        .toString());
                                                                  }
                                                                }
                                                                setState(() {});
                                                              },
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            10,
                                                                        right:
                                                                            10,
                                                                        bottom:
                                                                            10),
                                                                child:
                                                                    Container(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      1,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: deleteHistoryIds.contains(logHistory!
                                                                            .data!
                                                                            .lists![
                                                                                index]
                                                                            .id
                                                                            .toString())
                                                                        ? Colors
                                                                            .blueGrey
                                                                            .shade200
                                                                        : logHistory!.data!.lists![index].isMannual ==
                                                                                "1"
                                                                            ? const Color.fromARGB(
                                                                                255,
                                                                                224,
                                                                                248,
                                                                                223)
                                                                            : Colors.white,
                                                                    boxShadow: const [
                                                                      BoxShadow(
                                                                        color: Colors
                                                                            .grey,
                                                                        offset: Offset(
                                                                            2.0,
                                                                            2.0),
                                                                      )
                                                                    ],
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                  ),
                                                                  child: Column(
                                                                    children: [
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            top:
                                                                                10,
                                                                            right:
                                                                                10,
                                                                            left:
                                                                                10),
                                                                        child:
                                                                            Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Row(
                                                                              children: [
                                                                                Container(
                                                                                  constraints: const BoxConstraints(
                                                                                    maxHeight: 60,
                                                                                  ),
                                                                                  child: Container(
                                                                                    constraints: const BoxConstraints(
                                                                                      minHeight: 20,
                                                                                      minWidth: 20,
                                                                                      maxHeight: 50,
                                                                                      maxWidth: 50,
                                                                                    ),
                                                                                    decoration: BoxDecoration(
                                                                                      border: Border.all(color: Colors.white, width: 0),
                                                                                      boxShadow: const [
                                                                                        BoxShadow(color: Colors.grey, blurRadius: 5, offset: Offset(1, 1)),
                                                                                      ],
                                                                                      color: Colors.white,
                                                                                      shape: BoxShape.circle,
                                                                                      image: const DecorationImage(fit: BoxFit.cover, image: AssetImage('assets/main/avatar.png')),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(
                                                                                  width: 20,
                                                                                ),
                                                                                Column(
                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Text(
                                                                                      logHistory!.data!.lists![index].name.toString() == "" || logHistory!.data!.lists![index].name.toString() == "null" ? "Unknown" : logHistory!.data!.lists![index].name.toString(),
                                                                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                                                                    ),
                                                                                    const SizedBox(
                                                                                      height: 3,
                                                                                    ),
                                                                                    Text(
                                                                                      logHistory!.data!.lists![index].phoneNumber.toString(),
                                                                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            const SizedBox(
                                                                              height: 10,
                                                                            ),
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              children: [
                                                                                Row(
                                                                                  children: [
                                                                                    Image.asset("assets/icons/calendar.png", width: 20),
                                                                                    const SizedBox(
                                                                                      width: 15,
                                                                                    ),
                                                                                    Text(
                                                                                      logHistory!.data!.lists![index].dateTime.toString(),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                Row(
                                                                                  children: [
                                                                                    const Icon(Icons.timer_outlined),
                                                                                    const SizedBox(
                                                                                      width: 10,
                                                                                    ),
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(right: 10),
                                                                                      child: Text(
                                                                                        logHistory!.data!.lists![index].duration.toString().split('.')[0].padLeft(8, '0'),
                                                                                        style: const TextStyle(fontSize: 15, color: Colors.green),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            const SizedBox(
                                                                              height: 5,
                                                                            ),
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              children: [
                                                                                Text(
                                                                                  'Type  : ${logHistory!.data!.lists![index].callType}',
                                                                                ),
                                                                                const SizedBox()
                                                                                // Container(
                                                                                //   decoration: BoxDecoration(
                                                                                //       color: Colors.grey.shade300,
                                                                                //       borderRadius: BorderRadius.circular(5)),
                                                                                //   child:
                                                                                //       Padding(
                                                                                //     padding: const EdgeInsets.only(
                                                                                //         left: 10,
                                                                                //         right: 10,
                                                                                //         top: 5,
                                                                                //         bottom: 5),
                                                                                //     child:
                                                                                //         Text(
                                                                                //       "${logHistory!.data!.lists![index].simName}",
                                                                                //     ),
                                                                                //   ),
                                                                                // ),
                                                                              ],
                                                                            ),
                                                                            const SizedBox(
                                                                              height: 10,
                                                                            )
                                                                            // Text(
                                                                            //     'ACCOUNT ID : ${_filteredCallLogEntries.elementAt(indexStaff).phoneAccountId}',
                                                                            //     ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              )),
                                                        );
                                                      }),
                                                ],
                                              )
                                            : Center(
                                                child: Lottie.asset(
                                                    'assets/main/no_history.json',
                                                    fit: BoxFit.fill),
                                              )
                                      ],
                                    )
                                  : Center(
                                      child: Lottie.asset(
                                          'assets/main/loading.json',
                                          fit: BoxFit.fill),
                                    )
                            ],
                          )
                  ],
                ),
              )
            : const SizedBox(),
        // : Material(
        //     type: MaterialType.transparency,
        //     child: Padding(
        //       padding: const EdgeInsets.only(bottom: 50),
        //       child: Center(
        //         child: Container(
        //           decoration: BoxDecoration(
        //             borderRadius: BorderRadius.circular(10),
        //             color: Colors.grey,
        //           ),
        //           width: MediaQuery.of(context).size.width * 0.9,
        //           height: MediaQuery.of(context).size.height * 0.5,
        //           child: Padding(
        //             padding: const EdgeInsets.only(left: 20, right: 20),
        //             child: Column(
        //               mainAxisAlignment: MainAxisAlignment.center,
        //               crossAxisAlignment: CrossAxisAlignment.center,
        //               children: [
        //                 const Text(
        //                   "Permission",
        //                   style: TextStyle(
        //                     fontSize: 18,
        //                     fontWeight: FontWeight.w700,
        //                     color: Colors.black,
        //                     // decoration: TextDecoration.none,
        //                     //fontFamily: Theme.of(context).textTheme,
        //                   ),
        //                 ),
        //                 const SizedBox(
        //                   height: 10,
        //                 ),
        //                 const Text(
        //                   "We want to inform you that our app collects and uploads your call logs, including call duration and timestamps, to our secure servers. This data is shared with your company's super admin to enable them to track call activities.Your privacy is important to us, and we want to assure you that all data is handled with the utmost care and in accordance with our privacy policy. The information uploaded is encrypted to ensure its security during transmission and storage.",
        //                   style: TextStyle(
        //                     fontSize: 14,
        //                     fontWeight: FontWeight.w500,
        //                     color: Colors.black,
        //                     decoration: TextDecoration.none,
        //                   ),
        //                 ),
        //                 const SizedBox(
        //                   height: 20,
        //                 ),
        //                 Row(
        //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                   children: [
        //                     InkWell(
        //                       onTap: () {
        //                         Navigator.push(
        //                           context,
        //                           MaterialPageRoute(
        //                               builder: (context) =>
        //                                   Dashboard(widget.token)),
        //                         );
        //                       },
        //                       child: Container(
        //                         width: MediaQuery.of(context).size.width *
        //                             0.35,
        //                         height: 30,
        //                         decoration: BoxDecoration(
        //                             borderRadius: BorderRadius.circular(5),
        //                             color: const Color(0xffe94040)),
        //                         child: const Center(
        //                           child: Text("Deny",
        //                               style: TextStyle(
        //                                   fontSize: 18,
        //                                   fontWeight: FontWeight.w700,
        //                                   decoration: TextDecoration.none,
        //                                   color: Colors.white)),
        //                         ),
        //                       ),
        //                     ),
        //                     InkWell(
        //                       // onTap: () async {
        //                       //   await Permission.phone.request();
        //                       //   setState(() {
        //                       //     Common.saveSharedPref(
        //                       //         "callLogPermission", 'true');
        //                       //     refresh = true;
        //                       //     getSharedData();
        //                       //   });
        //                       // },
        //                       onTap: () async {
        //                         await Permission.phone.request();
        //                         await Common.saveSharedPref(
        //                             "callLogPermission", 'true');
        //                         Navigator.pop(context);
        //                         setState(() {
        //                           refresh = true;
        //                         });
        //                         getSharedData();
        //                       },

        //                       child: Container(
        //                         width: MediaQuery.of(context).size.width *
        //                             0.35,
        //                         height: 30,
        //                         decoration: BoxDecoration(
        //                             borderRadius: BorderRadius.circular(5),
        //                             color: Colors.green),
        //                         child: const Center(
        //                           child: Text("Allow",
        //                               style: TextStyle(
        //                                   fontSize: 18,
        //                                   fontWeight: FontWeight.w700,
        //                                   decoration: TextDecoration.none,
        //                                   color: Colors.white)),
        //                         ),
        //                       ),
        //                     ),
        //                   ],
        //                 )
        //               ],
        //             ),
        //           ),
        //         ),
        //       ),
        //     ),
        //   ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.green,
          onPressed: () {
            dialPad(context);
          },
          child: const Icon(
            Icons.call,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<Object?> dialPad(BuildContext context) {
    return showGeneralDialog(
      barrierLabel: "showGeneralDialog",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 400),
      context: context,
      pageBuilder: (context, _, __) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.maxFinite,
                height: MediaQuery.of(context).size.height * 0.82,
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
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width * .8,
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              phoneNumber.isEmpty
                                  ? "Enter Number"
                                  : phoneNumber,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1.5,
                            mainAxisSpacing: 20,
                          ),
                          itemCount: dialPadNumbers.length,
                          itemBuilder: (context, index) {
                            return ElevatedButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                setState(
                                    () => dialNumber(dialPadNumbers[index]));
                              },
                              style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(20),
                                  elevation: 2,
                                  shape: const CircleBorder(),
                                  backgroundColor: Colors.white),
                              child: Text(
                                dialPadNumbers[index],
                                style: const TextStyle(
                                  fontSize: 24,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          /// Delete Button
                          InkWell(
                            child: const Icon(Icons.backspace,
                                size: 30, color: Colors.grey),
                            onTap: () {
                              HapticFeedback.lightImpact();
                              if (phoneNumber.isNotEmpty) {
                                setState(() => deleteLastDigit());
                              }
                            },
                            onLongPress: () {
                              HapticFeedback.lightImpact();
                              setState(() {
                                phoneNumber = "";
                              });
                            },
                          ),

                          /// Call Button
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(20),
                                elevation: 5,
                                shape: const CircleBorder(),
                                backgroundColor: Colors.green),
                            onPressed: phoneNumber.isEmpty
                                ? null
                                : () async {
                                    Common.dialPad(phoneNumber);
                                  },
                            child: const Icon(
                              Icons.call,
                              color: Colors.white,
                              size: 35,
                            ),
                          ),
                          // ElevatedButton(
                          //   style: ElevatedButton.styleFrom(
                          //     padding: const EdgeInsets.all(20),
                          //     elevation: 5,
                          //     shape: const CircleBorder(),
                          //     backgroundColor: Colors.green,
                          //   ),
                          //   onPressed: phoneNumber.isEmpty
                          //       ? null
                          //       : () async {
                          //           await FlutterPhoneDirectCaller.callNumber(
                          //               phoneNumber);
                          //         },
                          //   child: const Icon(
                          //     Icons.call,
                          //     color: Colors.white,
                          //     size: 35,
                          //   ),
                          // ),

                          const SizedBox(
                            width: 30,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
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

  Future<String?> mainPopupButton(BuildContext context) {
    return showMenu(
      color: Colors.white,
      context: context,
      position: const RelativeRect.fromLTRB(1000.0, 0.0, 1000.0, 0.0),
      items: [
        PopupMenuItem<String>(
          value: '6',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.settings_suggest_outlined),
                  SizedBox(
                    width: 5,
                  ),
                  Text('Settings'),
                ],
              ),
              displayOverApps == true
                  ? const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    )
                  : const SizedBox()
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: '3',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.display_settings),
                  SizedBox(
                    width: 5,
                  ),
                  Text('Display Over App'),
                ],
              ),
              displayOverApps == true
                  ? const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    )
                  : const SizedBox()
            ],
          ),
        ),
        // if (simList.length > 1)
        // PopupMenuItem<String>(
        //   value: '4',
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       Row(
        //         children: [
        //           const Icon(Icons.sim_card),
        //           const SizedBox(
        //             width: 5,
        //           ),
        //           Row(
        //             children: [
        //               const Text('Sim: '),
        //               Text(
        //                 selectedSim,
        //                 style: const TextStyle(color: Colors.green),
        //               ),
        //             ],
        //           ),
        //         ],
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }

  Future<String?> selectSim(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
              title: const Center(child: Text("Select Sim")),
              content: SizedBox(
                height: simList.length * 50,
                width: MediaQuery.of(context).size.width * .2,
                child: ListView.builder(
                  itemCount: simList.length,
                  physics: const ScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return ListTile(
                        // onTap: () {
                        //   selectedSimId = simList[index]["id"].toString();
                        //   selectedSim = simList[index]["name"].toString();
                        //   Common.saveSharedPref(
                        //       "simName", simList[index]["name"]);
                        //   Common.saveSharedPref(
                        //       "simId", simList[index]["id"].toString());
                        //   Navigator.pop(context);
                        // },
                        title:
                            Text("${index + 1} : ${simList[index]["name"]}"));
                  },
                ),
              ));
        });
      },
    );
  }

  Widget _buildCallLogTypeOption(String label, String value) {
    bool isSelected = callType == label;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.blue : Colors.black,
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: Colors.blue)
            : null,
        onTap: () {
          setState(() {
            callType = label;
            callTypeValue = value;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<dynamic> staffDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: const Text('Staffs'),
            content: SizedBox(
              height: MediaQuery.of(context).size.height * .35,
              width: MediaQuery.of(context).size.width * .7,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: commonDetails!.data.staff.length,
                itemBuilder: (context, ind) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        assignStaff =
                            commonDetails!.data.staff[ind].staffName.toString();
                        assignStaffId =
                            commonDetails!.data.staff[ind].userId.toString();
                        Navigator.pop(context, true);
                      });
                    },
                    child: SizedBox(
                      height: 50,
                      child: Text(
                        commonDetails!.data.staff[ind].staffName.toString(),
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        });
  }

  Future<dynamic> deleteDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: const Text('Please Confirm'),
            content: const Text('Are you sure to Delete?'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('No')),
              TextButton(
                  onPressed: () async {
                    Map<String, dynamic> body = {
                      "token": widget.token,
                      'deletedIds': deleteHistoryIds,
                    };
                    DeleteCallHistoryModel delete =
                        await HttpService.deleteCallHistoryLogs(body);
                    if (delete.data == true) {
                      deleteHistoryIds.clear();
                      Common.toastMessaage(delete.message, Colors.green);
                      getData();
                    } else {
                      Common.toastMessaage(delete.message, Colors.red);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    }
                  },
                  child: const Text('Yes')),
            ],
          );
        });
  }

  bulkUpload() async {
    if (history.isEmpty) {
      Common.toastMessaage("No logs selected to upload", Colors.blue);
      return;
    }
    Map<String, dynamic> body = {
      "token": widget.token,
      'log': history,
      'is_mannual': "1",
    };
    if (context.mounted) {
      Common.showProgressDialog(context, "Uploading ${history.length} logs...");
    }
    CallLogUploadModel object1 = await HttpService.callLogUpload(body);
    if (object1.data == true) {
      Common.toastMessaage(
          "${object1.message} (${history.length} logs)", Colors.green);
      for (var item in history) {
        for (var entry in _callLogEntries) {
          if (entry.timestamp.toString() == item["timeStamp"]?.toString() &&
              entry.number == item["phone_number"]) {
            bool existsInHive = await HiveUtil.isCallLogWithIdAndNumberExists(
                entry.timestamp.toString(), entry.number.toString());

            if (existsInHive) {
              await HiveUtil.markCallLogAsUploaded(entry.timestamp.toString());
            } else {
              HiveCaallHistoryModel hiveCallLog = HiveCaallHistoryModel(
                  id: entry.timestamp.toString(),
                  name: entry.name.toString(),
                  phoneNumber: entry.number.toString(),
                  callType: entry.callType
                      .toString()
                      .substring(entry.callType.toString().indexOf('.') + 1),
                  duration: entry.duration.toString(),
                  timeStamp: entry.timestamp!.toString(),
                  simSlot: entry.simDisplayName ?? "NIL",
                  callRecordFilePath: "",
                  isUploaded: true,
                  isDeleted: false,
                  isEnabled: false);
              await HiveUtil.addCallLog(hiveCallLog);
            }
            break;
          }
        }
      }

      if (context.mounted) {
        Navigator.pop(context);
        getSharedData();
        getData();
      }
    } else {
      Common.toastMessaage(object1.message, Colors.red);
      if (context.mounted) {
        Navigator.pop(context);
      }
    }

    setState(() {
      history.clear();
      historyIndex.clear();
      selectAll = false;
      onLongPress = false;
    });
  }

  // bulkUpload() async {
  //   Map<String, dynamic> body = {
  //     "token": widget.token,
  //     'log': history,
  //   };
  //   if (context.mounted) {
  //     Common.showProgressDialog(context, "Uploading..");
  //   }
  //   CallLogUploadModel object1 = await HttpService.callLogUpload(body);
  //   if (object1.data == true) {
  //     Common.toastMessaage(object1.message, Colors.green);
  //     if (context.mounted) {
  //       Navigator.pop(context);
  //       getData();
  //     }
  //   } else {
  //     Common.toastMessaage(object1.message, Colors.red);
  //     if (context.mounted) {
  //       Navigator.pop(context);
  //     }
  //   }
  //   setState(() {
  //     history.clear();
  //     historyIndex.clear();
  //   });
  // }
}

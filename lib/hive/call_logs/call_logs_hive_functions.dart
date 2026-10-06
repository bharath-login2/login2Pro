import 'dart:convert';
import 'dart:developer';
import 'package:call_e_log/call_log.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:login2/hive/call_logs/HiveCaallHistoryModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HiveUtil {
  static const String CALL_HISTORY_BOX = 'callHistoryBox';
  static bool _initialized = false;
  static bool _adapterRegistered = false;

  //! Initialize Hive
  static Future<void> init() async {
    if (!_initialized) {
      log('>> Initializing Hive');
      await Hive.initFlutter();
      _initialized = true;
      log('>> Hive initialized successfully');
    }
    if (!_adapterRegistered) {
      registerAdapter();
    }
  }

  static bool get isInitialized => _initialized;

  static Box<HiveCaallHistoryModel> getBox() {
    return Hive.box<HiveCaallHistoryModel>(CALL_HISTORY_BOX);
  }

  static Future<void> ensureInitialized() async {
    if (!_initialized) {
      await init();
    }
    if (!_adapterRegistered) {
      registerAdapter();
    }
  }

  /// Opens a box, performs an operation, and ensures it's properly closed
  static Future<T> withBox<T>(String boxName,
      Future<T> Function(Box<HiveCaallHistoryModel> box) operation) async {
    await ensureInitialized();

    // Important: Use the same capitalization throughout your app
    // Convert boxName to lowercase to standardize it
    String standardBoxName = boxName.toLowerCase();

    Box<HiveCaallHistoryModel>? box;
    try {
      box = await safeOpenBox<HiveCaallHistoryModel>(CALL_HISTORY_BOX);

      final result = await operation(box);
      await box.flush();
      return result;
    } catch (e) {
      log('Error with Hive box operation: $e');
      rethrow;
    }
  }

  //! close box
  static Future<void> closeBox(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      log('Closing previously opened box: $boxName');
      await Hive.box(boxName).close();
    }
  }

  /// Add a new call log entry with duplicate checking
  static Future<void> addCallLog(HiveCaallHistoryModel callLog) async {
    await withBox(CALL_HISTORY_BOX, (box) async {
      log('>> Checking if call log exists: ${callLog.name} | ${callLog.id} | ${callLog.isUploaded}');

      // Check if this log already exists using its ID
      bool exists =
          box.values.any((existingLog) => existingLog.id == callLog.id);

      if (!exists) {
        log('>> Adding new call log: ${callLog.id}');
        await box.add(callLog);
        await markCallLogAsUploaded(callLog.id);

        log('>> Call log added successfully');
      } else {
        log('>> Call log ${callLog.id} already exists, skipping');
      }
      return;
    });
  }

  /// Register the HiveCaallHistoryModel adapter safely
  static void registerAdapter() {
    if (!_adapterRegistered) {
      try {
        // Check if adapter is already registered to avoid the error
        if (!Hive.isAdapterRegistered(1)) {
          log('Registering HiveCaallHistoryModelAdapter');
          Hive.registerAdapter(HiveCaallHistoryModelAdapter());
          log('Adapter registered successfully');
        } else {
          log('Adapter already registered with typeId 1');
        }
        _adapterRegistered = true;
      } catch (e) {
        log('Error registering adapter: $e');
      }
    }
  }

  static Future<Box<T>> safeOpenBox<T>(String boxName) async {
    await ensureInitialized();

    int retryCount = 0;
    const int maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        if (Hive.isBoxOpen(boxName)) {
          return Hive.box<T>(boxName);
        } else {
          return await Hive.openBox<T>(boxName);
        }
      } catch (e) {
        retryCount++;
        log('Error opening box $boxName (attempt $retryCount/$maxRetries): $e');

        if (retryCount >= maxRetries) {
          log('Max retries reached for box $boxName. Rethrowing.');
          rethrow;
        }

        // Wait a bit before retrying to allow locks to be released
        await Future.delayed(Duration(milliseconds: 100 * retryCount));
      }
    }

    // Fallback although while loop should throw or return
    return await Hive.openBox<T>(boxName);
  }

  /// Add multiple call logs at once with duplicate checking
  static Future<void> addCallLogs(List<HiveCaallHistoryModel> callLogs) async {
    await withBox(CALL_HISTORY_BOX, (box) async {
      try {
        log('>> Processing ${callLogs.length} call logs');

        // Get existing log IDs for faster duplicate checking
        final existingIds = box.values.map((log) => log.id).toSet();
        int newCount = 0;

        for (var log in callLogs) {
          print('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
          print(
              'call log 990 : ${log.name} || ${log.isUploaded} || ${log.timeStamp}');
          // Check if this log already exists by ID
          if (!existingIds.contains(log.id)) {
            await box.add(log);
            if (log.isEnabled) {
              await markCallLogAsUploaded(log.id);
            } else {
              await updateCallLogField(log.id, isUploaded: false);
            }

            existingIds.add(log.id); // Add to our tracking set
            newCount++;
            HiveCaallHistoryModel? logmain = await getCallLogById(log.id);
            print(
                '>> Added new call log: ${logmain?.name} | ${logmain?.id} | ${logmain?.isUploaded} | ${logmain?.isEnabled}');
          }
        }

        log('>> Added $newCount new call logs (${callLogs.length - newCount} duplicates skipped)');
      } catch (e) {
        log('getting some error while adding data to hive : ${e.toString()}');
      }

      return;
    });
  }

  static Future<List<HiveCaallHistoryModel>> getAllCallLogs() async {
    // Ensure the box is open before proceeding
    await safeOpenBox<HiveCaallHistoryModel>(CALL_HISTORY_BOX);

    return await withBox(CALL_HISTORY_BOX, (box) async {
      if (box.isEmpty) {
        log('>> Call history box is empty');
        return [];
      }

      final callLogs = box.values.toList();
      log('>> Retrieved ${callLogs.length} call logs');
      return callLogs;
    });
  }

  /// Get call logs by a specific filter
  static Future<List<HiveCaallHistoryModel>> getCallLogsByFilter({
    String? callType,
    String? simSlot,
    bool? isUploaded,
  }) async {
    return await withBox(CALL_HISTORY_BOX, (box) async {
      if (box.isEmpty) {
        log('>> Call history box is empty');
        return [];
      }

      final allLogs = box.values.toList();

      // Apply filters
      final filteredLogs = allLogs.where((log) {
        bool match = true;

        if (callType != null) {
          match = match && log.callType == callType;
        }

        if (simSlot != null) {
          match = match && log.simSlot == simSlot;
        }

        if (isUploaded != null) {
          match = match && log.isUploaded == isUploaded;
        }

        return match;
      }).toList();

      log('>> Retrieved ${filteredLogs.length} filtered call logs');
      return filteredLogs;
    });
  }

  /// Get a specific call log by ID
  static Future<HiveCaallHistoryModel?> getCallLogById(String id) async {
    return await withBox(CALL_HISTORY_BOX, (box) async {
      if (box.isEmpty) {
        log('>> Call history box is empty');
        return null;
      }

      for (int i = 0; i < box.length; i++) {
        final log = box.getAt(i);
        if (log != null && log.id == id) {
          return log;
        }
      }

      log('>> Call log with ID $id not found');
      return null;
    });
  }

  /// Update a specific call log
  static Future<bool> updateCallLog(
      String id, HiveCaallHistoryModel updatedLog) async {
    return await withBox(CALL_HISTORY_BOX, (box) async {
      if (box.isEmpty) {
        log('>> Call history box is empty');
        return false;
      }

      for (int i = 0; i < box.length; i++) {
        final log = box.getAt(i);
        if (log != null && log.id == id) {
          await box.putAt(i, updatedLog);
          print('>> Call log with ID $id updated successfully');
          return true;
        }
      }

      log('>> Call log with ID $id not found for update');
      return false;
    });
  }

  /// Update a specific field for a call log
  static Future<bool> updateCallLogField(String id,
      {String? name,
      String? phoneNumber,
      String? callType,
      String? duration,
      String? timeStamp,
      String? simSlot,
      String? callRecordFilePath,
      bool? isUploaded,
      bool? isDeleted,
      bool? isEnabled}) async {
    return await withBox(CALL_HISTORY_BOX, (box) async {
      if (box.isEmpty) {
        log('>> Call history box is empty');
        return false;
      }

      for (int i = 0; i < box.length; i++) {
        final log = box.getAt(i);
        if (log != null && log.id == id) {
          // Create a new log with updated fields
          final updatedLog = HiveCaallHistoryModel(
            id: log.id,
            name: name ?? log.name,
            phoneNumber: phoneNumber ?? log.phoneNumber,
            callType: callType ?? log.callType,
            duration: duration ?? log.duration,
            timeStamp: timeStamp ?? log.timeStamp,
            simSlot: simSlot ?? log.simSlot,
            callRecordFilePath: callRecordFilePath ?? log.callRecordFilePath,
            isUploaded: isUploaded ?? log.isUploaded,
            isDeleted: isDeleted ?? log.isDeleted,
            isEnabled: isEnabled ?? log.isEnabled,
          );

          await box.putAt(i, updatedLog);
          print('>> Call log field updated for ID $id');
          return true;
        }
      }

      log('>> Call log with ID $id not found for field update');
      return false;
    });
  }

  /// Delete a specific call log by ID
  static Future<bool> deleteCallLog(String id) async {
    return await withBox(CALL_HISTORY_BOX, (box) async {
      if (box.isEmpty) {
        log('>> Call history box is empty');
        return false;
      }

      for (int i = 0; i < box.length; i++) {
        final log = box.getAt(i);
        if (log != null && log.id == id) {
          await box.deleteAt(i);
          print('>> Call log with ID $id deleted successfully');
          return true;
        }
      }

      log('>> Call log with ID $id not found for deletion');
      return false;
    });
  }

  /// Clear all call logs
  static Future<void> clearAllCallLogs() async {
    await withBox(CALL_HISTORY_BOX, (box) async {
      await box.clear();
      log('>> All call logs cleared');
      return;
    });
  }

  //! Check if any call logs exist
  static Future<bool> hasCallLogs() async {
    return await withBox(CALL_HISTORY_BOX, (box) async {
      return box.isNotEmpty;
    });
  }

  //! Get the count of call logs
  static Future<int> getCallLogCount() async {
    return await withBox(CALL_HISTORY_BOX, (box) async {
      return box.length;
    });
  }

  /// Get call logs for a specific time range
  static Future<List<HiveCaallHistoryModel>> getCallLogsByTimeRange(
    DateTime startTime,
    DateTime endTime,
  ) async {
    return await withBox(CALL_HISTORY_BOX, (box) async {
      if (box.isEmpty) {
        log('>> Call history box is empty');
        return [];
      }

      final allLogs = box.values.toList();

      final filteredLogs = allLogs.where((log) {
        try {
          final logTime = DateTime.parse(log.timeStamp);
          return logTime.isAfter(startTime) && logTime.isBefore(endTime);
        } catch (e) {
          print('>> Error parsing timestamp: ${log.timeStamp}');
          return false;
        }
      }).toList();

      log('>> Retrieved ${filteredLogs.length} call logs within time range');
      return filteredLogs;
    });
  }

  /// Mark a call log as uploaded
  static Future<bool> markCallLogAsUploaded(String id) async {
    return await updateCallLogField(id, isUploaded: true);
  }

  //! delete based on ID
  static Future<bool> markCallLogsAsDeleted(List<dynamic> ids) async {
    int successCount = 0;

    // Process each ID and update the isDeleted field
    for (String id in ids) {
      bool success = await updateCallLogField(id, isDeleted: true);
      if (success) {
        successCount++;
      }
    }

    log('>> Marked $successCount/${ids.length} call logs as deleted');
    return successCount > 0; // Return true if at least one log was updated
  }

  /// Get all call logs that haven't been uploaded
  static Future<List<HiveCaallHistoryModel>> getNotUploadedCallLogs() async {
    return await getCallLogsByFilter(isUploaded: false);
  }

  // check data is in hive or not
  static Future<bool> isCallLogWithIdAndNumberExists(
      String id, String phoneNumber) async {
    return await HiveUtil.withBox<bool>(HiveUtil.CALL_HISTORY_BOX, (box) async {
      if (box.isEmpty) {
        log('>> Call history box is empty');
        return false;
      }

      // Normalize the phone number for comparison
      String normalizedSearchNumber =
          phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');

      // Check if any call log has this ID and phone number
      bool exists = box.values.any((callLog) {
        String normalizedLogNumber =
            callLog.phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
        return callLog.id == id &&
            normalizedLogNumber == normalizedSearchNumber;
      });

      log('>> Call log with ID $id and phone number ${exists ? "found" : "not found"}');
      return exists;
    });
  }

// Get the most recent call log by timestamp
  static Future<HiveCaallHistoryModel?> getLatestCallLogByTime() async {
    return await withBox(CALL_HISTORY_BOX, (box) async {
      if (box.isEmpty) {
        log('>> Call history box is empty');
        return null;
      }

      final allLogs = box.values.toList();

      // Sort logs by timestamp in descending order (most recent first)
      allLogs.sort((a, b) {
        try {
          // Parse timestamps to DateTime for comparison
          final timeA = parseCallLogTime(a.timeStamp);
          final timeB = parseCallLogTime(b.timeStamp);

          // Compare in reverse order for descending sort
          return timeB.compareTo(timeA);
        } catch (e) {
          log('>> Error comparing timestamps: $e');
          return 0; // Keep original order in case of parsing errors
        }
      });

      // Return the first item (most recent by timestamp)
      if (allLogs.isNotEmpty) {
        log('>> Retrieved latest call log by time with ID: ${allLogs.first.id}');
        return allLogs.first;
      }

      return null;
    });
  }
}

//! filterd call logs
// filterinfunction based on sime & calltype
// Future<List<CallLogEntry>> getFilteredCallLogs(DateTime startingTime) async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   await prefs.reload();

//   List<String> callTypes = prefs.getStringList('callTypes') ?? [];
//   // List<String> simOptions = prefs.getStringList('simOptions') ?? [];

//   log('+ callTypes  : $callTypes');
//   // log('+ dateTimeFrom : ${dateTimeFrom}');

//   Iterable<CallLogEntry> allLogs = await CallLog.query(
//     dateTimeFrom: startingTime,
//   );
//   // log('all calls : ${allLogs.length}');
//   //  final List<CallLogToggleEvent> toggleHistory = await ToggleStorage.getToggleHistory();
//   // final filteredLogs = allLogs.where((entry) {
//   //         return isLogAllowed(entry.timestamp ?? 0, entry.callType!, toggleHistory);
//   //       }).toList();

//   List<CallLogEntry> filteredLogs = allLogs.where((log) {
//     // --- Filter Call Type ---
//     bool isValidType = false;
//     print('all calls : ${log.callType}');
//     print('all calls : ${log.name}');
//     print('all calls : ${log.number}');
//     if (callTypes.contains('Incoming') &&
//         (log.callType == CallType.incoming ||
//             log.callType == CallType.missed)) {
//       isValidType = true;
//     }
//     if (callTypes.contains('Outgoing') && log.callType == CallType.outgoing) {
//       isValidType = true;
//     }
//     print('+ isValidType : $isValidType');

//     // --- Filter SIM Selection ---
//     // bool isValidSim = false;
//     // String? simId = log.phoneAccountId?.toLowerCase(); // Normalize for comparison

//     print('name                : ${log.name}');
//     print('number              : ${log.number}');
//     print('phoneAccountId      : ${log.phoneAccountId}');
//     print('simDisplayName      : ${log.simDisplayName}');
//     print('formattedNumber     : ${log.formattedNumber}');
//     print('cachedNumberType    : ${log.cachedNumberType}');
//     print('cachedNumberLabel   : ${log.cachedNumberLabel}');
//     print('cachedMatchedNumber : ${log.cachedMatchedNumber}');
//     print('callType            : ${log.callType}');
//     print('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');

//     return isValidType;
//   }).toList();

//   log('filteredLogs : $filteredLogs');
//   return filteredLogs;
// }

//! filtered call logs
Future<List<CallLogEntry>> getFilteredCallLogs(DateTime startingTime) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.reload();

  List<String> callTypes = prefs.getStringList('callTypes') ?? [];

  log('+ callTypes from prefs: $callTypes');

  Iterable<CallLogEntry> allLogs = await CallLog.query(
    dateTimeFrom: startingTime,
  );

  await debugLogSimInfo(allLogs);

  log('+ Total logs from device: ${allLogs.length}');

  List<CallLogEntry> filteredLogs = allLogs.where((log) {
    String callTypeStr = _parseCallTypeToString(log);
    bool isValidType = false;
    print('Checking call: ${log.name} - ${log.number} - Type: $callTypeStr');
    if (callTypes.contains('Incoming')) {
      if (callTypeStr.contains('incoming') ||
          callTypeStr.contains('wifiIncoming') ||
          callTypeStr.contains('missed')) {
        isValidType = true;
        print('✓ Allowed as Incoming');
      }
    }

    if (callTypes.contains('Outgoing')) {
      if (callTypeStr.contains('outgoing') ||
          callTypeStr.contains('wifiOutgoing')) {
        isValidType = true;
        print('✓ Allowed as Outgoing');
      }
    }

    return isValidType;
  }).toList();

  log('+ Filtered logs count: ${filteredLogs.length}');

  return filteredLogs;
}

// Helper function to parse call type to string
String _parseCallTypeToString(CallLogEntry entry) {
  final typeStr = entry.callType.toString().toLowerCase();

  if (typeStr.contains('wifiincoming')) {
    return 'wifiIncoming';
  } else if (typeStr.contains('wifioutgoing')) {
    return 'wifiOutgoing';
  } else if (typeStr.contains('incoming')) {
    return 'incoming';
  } else if (typeStr.contains('outgoing')) {
    return 'outgoing';
  } else if (typeStr.contains('missed')) {
    return 'missed';
  } else {
    // Extract just the type name after the last dot
    final dotIndex = typeStr.lastIndexOf('.');
    if (dotIndex != -1) {
      return typeStr.substring(dotIndex + 1);
    }
    return typeStr;
  }
}

//
DateTime parseCallLogTime(String callTimeString) {
  try {
    if (callTimeString.contains('-') && callTimeString.contains('PM')) {
      // Format like "06-04-2025 03:09 PM"
      final DateFormat format = DateFormat("dd-MM-yyyy hh:mm a");
      return format.parse(callTimeString);
    } else if (callTimeString.contains('-') || callTimeString.contains(':')) {
      // ISO format like "2025-04-06 16:29:44.555"
      return DateTime.parse(callTimeString);
    } else {
      // Unix timestamp in milliseconds
      return DateTime.fromMillisecondsSinceEpoch(int.parse(callTimeString));
    }
  } catch (e) {
    // Handle invalid formats gracefully
    print('Error parsing callTimeString: $callTimeString -> $e');
    return DateTime.now(); // or return null if you prefer nullable
  }
}

String formatDurationFromString(String? durationStr) {
  if (durationStr == null || durationStr.isEmpty) return '00:00:00';

  final seconds = int.tryParse(durationStr) ?? 0;
  final duration = Duration(seconds: seconds);

  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final hours = twoDigits(duration.inHours);
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final secs = twoDigits(duration.inSeconds.remainder(60));

  return '$hours:$minutes:$secs';
}

//! below call log filter functions
void onToggleChanged(String type, bool isEnabled) async {
  await ToggleStorage.addToggleEvent(CallLogToggleEvent(
    type: type,
    isEnabled: isEnabled,
    timestamp: DateTime.now().millisecondsSinceEpoch,
  ));
}

bool isLogAllowed(
  int logTime,
  CallType callType,
  List<CallLogToggleEvent> toggles,
) {
  final typeStr = callType == CallType.incoming ? 'Incoming' : 'Outgoing';
  final typeToggles = toggles.where((e) => e.type == typeStr).toList()
    ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

  bool currentEnabled = true;

  for (final toggle in typeToggles) {
    if (logTime < toggle.timestamp) {
      return currentEnabled;
    }
    currentEnabled = toggle.isEnabled;
  }

  return currentEnabled;
}
// bool isLogAllowed(
//     int timestamp, CallType callType, List<CallLogToggleEvent> toggleHistory) {
//   final String callTypeStr = callType.toString().toLowerCase();
//   if (callTypeStr.contains('incoming') ||
//       callTypeStr.contains('wifiincoming') ||
//       callTypeStr.contains('missed')) {
//     return _isCallTypeAllowed(timestamp, "Incoming", toggleHistory);
//   }
//   if (callTypeStr.contains('outgoing') ||
//       callTypeStr.contains('wifioutgoing')) {
//     return _isCallTypeAllowed(timestamp, "Outgoing", toggleHistory);
//   }

//   return false;
// }

bool _isCallTypeAllowed(
    int timestamp, String type, List<CallLogToggleEvent> toggleHistory) {
  toggleHistory.sort((a, b) => a.timestamp.compareTo(b.timestamp));

  bool isCurrentlyEnabled = false;

  for (var event in toggleHistory) {
    if (event.timestamp <= timestamp && event.type == type) {
      isCurrentlyEnabled = event.isEnabled;
    }
  }

  return isCurrentlyEnabled;
}

class CallLogToggleEvent {
  final String type; // 'incoming' or 'outgoing'
  final bool isEnabled;
  final int timestamp;

  CallLogToggleEvent({
    required this.type,
    required this.isEnabled,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'isEnabled': isEnabled,
        'timestamp': timestamp,
      };

  factory CallLogToggleEvent.fromJson(Map<String, dynamic> json) {
    return CallLogToggleEvent(
      type: json['type'],
      isEnabled: json['isEnabled'],
      timestamp: json['timestamp'],
    );
  }
}

class ToggleStorage {
  static const String key = 'callLogToggleHistory';

  static Future<List<CallLogToggleEvent>> getToggleHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(key) ?? [];
    return raw.map((e) => CallLogToggleEvent.fromJson(json.decode(e))).toList();
  }

  static Future<void> addToggleEvent(CallLogToggleEvent event) async {
    final prefs = await SharedPreferences.getInstance();
    final events = await getToggleHistory();
    events.add(event);
    final encoded = events.map((e) => json.encode(e.toJson())).toList();
    await prefs.setStringList(key, encoded);
  }
}

const MethodChannel _simChannel = MethodChannel('com.login2Pro/sim_info');

Future<void> debugLogSimInfo(Iterable<CallLogEntry> allLogs) async {
  List<Map<dynamic, dynamic>> activeSims = [];
  try {
    final result = await _simChannel.invokeMethod('getActiveSims');
    if (result != null) {
      activeSims = List<Map<dynamic, dynamic>>.from(result);
    }
  } catch (e) {
    log('Error calling MethodChannel getActiveSims: $e');
  }

  for (var entry in allLogs) {
    String phoneAccountId = entry.phoneAccountId ?? 'null';
    String simDisplayName = entry.simDisplayName ?? 'NIL';
    String subscriptionId = 'Unknown';
    String simSlotIndex = 'Unknown';
    String resolvedSim = 'Unknown';

    for (var sim in activeSims) {
      String subId = sim['subscriptionId']?.toString() ?? '';
      String slotIdx = sim['simSlotIndex']?.toString() ?? '';
      String dispName = sim['displayName']?.toString() ?? '';
      String carrierName = sim['carrierName']?.toString() ?? '';

      if (subId.isNotEmpty && phoneAccountId == subId) {
        subscriptionId = subId;
        simSlotIndex = slotIdx;
        resolvedSim = slotIdx == '0' ? 'SIM 1' : (slotIdx == '1' ? 'SIM 2' : 'SIM ${int.parse(slotIdx) + 1}');
        break;
      } else if (phoneAccountId == slotIdx) {
        subscriptionId = subId;
        simSlotIndex = slotIdx;
        resolvedSim = slotIdx == '0' ? 'SIM 1' : (slotIdx == '1' ? 'SIM 2' : 'SIM ${int.parse(slotIdx) + 1}');
        break;
      } else if (simDisplayName != 'NIL' &&
          (simDisplayName.toLowerCase() == dispName.toLowerCase() ||
           simDisplayName.toLowerCase() == carrierName.toLowerCase())) {
        subscriptionId = subId;
        simSlotIndex = slotIdx;
        resolvedSim = slotIdx == '0' ? 'SIM 1' : (slotIdx == '1' ? 'SIM 2' : 'SIM ${int.parse(slotIdx) + 1}');
        break;
      }
    }

    log('''
CALL LOG SIM DEBUG
phoneAccountId: $phoneAccountId
simDisplayName: $simDisplayName
subscriptionId: $subscriptionId
simSlotIndex: $simSlotIndex
resolvedSim: $resolvedSim''');
  }
}


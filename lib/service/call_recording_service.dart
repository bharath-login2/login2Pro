// ignore_for_file: avoid_print, unnecessary_brace_in_string_interps

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:login2/core/common.dart';
import 'package:login2/hive/call_logs/HiveCaallHistoryModel.dart';
import 'package:login2/hive/call_logs/call_logs_hive_functions.dart';
import 'package:login2/models/callLogs/callLogUploadModel.dart';
import 'package:login2/service/service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CallRecordingNative {
  static const MethodChannel _channel =
      MethodChannel('com.login2Pro/call_recording');

  static Future<List<dynamic>> getNewRecordings() async {
    print(
      'AUTO RECORDING DEBUG: Calling native getNewRecordings '
      'on com.login2Pro/call_recording',
    );

    final result = await _channel.invokeMethod('getNewRecordings');

    print(
      'AUTO RECORDING DEBUG: Native response type=${result.runtimeType}, '
      'count=${result is List ? result.length : 'not a list'}',
    );

    if (result == null) return [];
    return List<dynamic>.from(result);
  }
}

class CallRecordingService {
  static final Set<String> _inMemoryUploadedKeys = {};

  static String normalizePhoneNumber(String number) {
    final digits = number.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length >= 10) {
      return digits.substring(digits.length - 10);
    }
    return digits;
  }

  static String _getRecordingKey(String path, dynamic lastModified) {
    return '${path}_$lastModified';
  }

  static Future<bool> _isRecordingUploaded(String key) async {
    if (_inMemoryUploadedKeys.contains(key)) {
      return true;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final uploadedList = prefs.getStringList('uploaded_recording_keys') ?? [];
      return uploadedList.contains(key);
    } catch (e) {
      log('Error reading uploaded_recording_keys: $e');
      return false;
    }
  }

  static Future<void> _markRecordingAsUploaded(String key) async {
    _inMemoryUploadedKeys.add(key);
    try {
      final prefs = await SharedPreferences.getInstance();
      final uploadedList = prefs.getStringList('uploaded_recording_keys') ?? [];
      if (!uploadedList.contains(key)) {
        uploadedList.add(key);
        await prefs.setStringList('uploaded_recording_keys', uploadedList);
      }
    } catch (e) {
      log('Error saving uploaded_recording_keys: $e');
    }
  }

  /// Exposes recording key mark as uploaded for initial multipart upload paths
  static Future<void> markRecordingUploadedLocally(
      String path, dynamic lastModified) async {
    final key = _getRecordingKey(path, lastModified);
    await _markRecordingAsUploaded(key);
  }

  /// Option A: Initial pre-upload search for a matching recording for [targetCall].
  /// Returns match result map if a candidate is available now, or null if not yet available.
  static Future<Map<String, dynamic>?> findMatchingRecordingForTargetCall(
    HiveCaallHistoryModel targetCall, {
    int attemptNumber = 0,
  }) async {
    try {
      print(
          'AUTO RECORDING [OPTION A]: Initiating pre-upload scan for target call: ${targetCall.phoneNumber}');
      final recordings = await CallRecordingNative.getNewRecordings();
      print('AUTO: native recording count ${recordings.length}');
      print(
          'AUTO RECORDING [OPTION A]: Native scanner returned ${recordings.length} item(s)');

      if (recordings.isEmpty) {
        print(
            'AUTO RECORDING [OPTION A]: No recordings discovered on device during initial scan.');
        return null;
      }

      for (final rawRecording in recordings) {
        final recording = Map<String, dynamic>.from(rawRecording);
        final recordingPath = recording['path']?.toString() ?? '';
        final recordingTime = recording['lastModified'];
        final recordingKey = _getRecordingKey(recordingPath, recordingTime);

        if (await _isRecordingUploaded(recordingKey)) {
          print(
              'AUTO RECORDING [OPTION A]: Skipping already-uploaded candidate: $recordingKey');
          continue;
        }

        final match =
            matchRecordingWithTargetCall(recording, targetCall, attemptNumber);
        if (match != null) {
          print('AUTO: matched recording ${match["recordingPath"]}');
          print(
              'AUTO RECORDING [OPTION A]: Pre-upload MATCH FOUND! Path: ${match["recordingPath"]}, callId: ${match["callId"]}');
          return match;
        }
      }

      print(
          'AUTO RECORDING [OPTION A]: Initial scan completed — no matching recording found.');
      return null;
    } catch (e) {
      print(
          'AUTO RECORDING [OPTION A]: Exception during initial pre-upload scan: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> matchRecordingWithCallLog(
    Map<String, dynamic> recording,
  ) async {
    final hiveData = await HiveUtil.getAllCallLogs();

    final recordingTime = int.tryParse(
      recording['lastModified']?.toString() ?? '',
    );

    if (recordingTime == null) {
      print('MATCH FAILED: Recording timestamp missing');
      return null;
    }

    // Allow the dialer more time to finish saving the recording.
    const int maxRecordingDelayMs = 5 * 60 * 1000;
    const int earlyToleranceMs = 10 * 1000;

    final candidates = <Map<String, dynamic>>[];

    for (final call in hiveData) {
      final callStart = int.tryParse(call.timeStamp);
      if (callStart == null) continue;

      final durationSeconds = int.tryParse(call.duration) ?? 0;
      final callEnd = callStart + durationSeconds * 1000;

      final difference = recordingTime - callEnd;

      if (difference < -earlyToleranceMs || difference > maxRecordingDelayMs) {
        continue;
      }

      candidates.add({
        'call': call,
        'callStart': callStart,
        'callEnd': callEnd,
        'difference': difference.abs(),
      });
    }

    if (candidates.isEmpty) {
      print('MATCH FAILED: No call near recording timestamp');
      return null;
    }

    candidates.sort(
      (a, b) => (a['difference'] as int).compareTo(b['difference'] as int),
    );

    // Do not guess when two calls have similarly plausible times.
    if (candidates.length > 1) {
      final bestDifference = candidates[0]['difference'] as int;
      final secondDifference = candidates[1]['difference'] as int;

      if (secondDifference - bestDifference < 60 * 1000) {
        print('MATCH PENDING: Multiple calls are plausible');
        return null;
      }
    }

    final best = candidates.first;
    final call = best['call'] as HiveCaallHistoryModel;
    final callStart = best['callStart'] as int;
    final callEnd = best['callEnd'] as int;

    return {
      'recordingPath': recording['path']?.toString() ?? '',
      'recordingUri': recording['uri']?.toString() ?? '',
      'recordingPhone': recording['phoneNumber']?.toString() ?? '',
      'recordingTime': recordingTime,
      'recordingName': recording['name']?.toString() ?? '',
      'recordingSize': recording['size'],
      'recordingMimeType': recording['mimeType']?.toString() ?? '',
      'callId': call.id,
      'callPhone': call.phoneNumber,
      'callType': call.callType,
      'callStart': callStart,
      'callEnd': callEnd,
      'duration': call.duration,
      'simSlot': call.simSlot,
      'timeDifference': recordingTime - callEnd,
      'matchConfidence': 'time_only',
    };
  }

  // static Future<Map<String, dynamic>?> matchRecordingWithCallLog(
  //   Map<String, dynamic> recording,
  // ) async {
  //   final List<HiveCaallHistoryModel> hiveData =
  //       await HiveUtil.getAllCallLogs();

  //   final recordingPhone = recording['phoneNumber']?.toString() ?? '';
  //   final recordingLastModified =
  //       int.tryParse(recording['lastModified']?.toString() ?? '');

  //   print('');
  //   print('========== RECORDING MATCH RESULT ==========');
  //   print('Recording phone: $recordingPhone');
  //   print('Recording time: $recordingLastModified');

  //   if (recordingPhone.isEmpty || recordingLastModified == null) {
  //     print('MATCH FAILED: Recording phone/time is missing');
  //     print('============================================');
  //     return null;
  //   }

  //   final normalizedRecordingPhone = normalizePhoneNumber(recordingPhone);
  //   print('Normalized recording phone: $normalizedRecordingPhone');

  //   final matchingPhoneCalls = hiveData.where((call) {
  //     final normalizedCallPhone = normalizePhoneNumber(call.phoneNumber);
  //     return normalizedCallPhone == normalizedRecordingPhone;
  //   }).toList();

  //   if (matchingPhoneCalls.isEmpty) {
  //     print('MATCH FAILED: No call found with same phone number');
  //     print('============================================');
  //     return null;
  //   }

  //   const int maxRecordingDelayMs = 30 * 1000;
  //   HiveCaallHistoryModel? bestMatch;
  //   int? bestDifference;

  //   for (final call in matchingPhoneCalls) {
  //     final callStart = int.tryParse(call.timeStamp);
  //     final durationSeconds = int.tryParse(call.duration) ?? 0;

  //     if (callStart == null) {
  //       continue;
  //     }

  //     final callEnd = callStart + (durationSeconds * 1000);
  //     final difference = recordingLastModified - callEnd;

  //     print('');
  //     print('Checking call: ${call.phoneNumber}');
  //     print('Call start: $callStart');
  //     print('Call end: $callEnd');
  //     print('Recording time: $recordingLastModified');
  //     print('Difference: ${difference} ms');

  //     if (difference < 0) {
  //       print('Rejected: recording is before call end');
  //       continue;
  //     }

  //     if (difference > maxRecordingDelayMs) {
  //       print('Rejected: recording is more than 30 seconds after call end');
  //       continue;
  //     }

  //     if (bestDifference == null || difference < bestDifference) {
  //       bestDifference = difference;
  //       bestMatch = call;
  //     }
  //   }

  //   if (bestMatch == null || bestDifference == null) {
  //     print('');
  //     print('MATCH FAILED: No call found within 30 seconds of recording time');
  //     print('============================================');
  //     return null;
  //   }

  //   final callStart = int.tryParse(bestMatch.timeStamp);
  //   final durationSeconds = int.tryParse(bestMatch.duration) ?? 0;

  //   if (callStart == null) {
  //     print('MATCH FAILED: Invalid call timestamp');
  //     print('============================================');
  //     return null;
  //   }

  //   final callEnd = callStart + (durationSeconds * 1000);

  //   final Map<String, dynamic> matchResult = {
  //     'recordingPath': recording['path']?.toString() ?? '',
  //     'recordingUri': recording['uri']?.toString() ?? '',
  //     'recordingPhone': normalizedRecordingPhone,
  //     'recordingTime': recordingLastModified,
  //     'recordingName': recording['name']?.toString() ?? '',
  //     'recordingSize': recording['size'],
  //     'recordingMimeType': recording['mimeType']?.toString() ?? '',
  //     'callId': bestMatch.id,
  //     'callPhone': bestMatch.phoneNumber,
  //     'callType': bestMatch.callType,
  //     'callStart': callStart,
  //     'callEnd': callEnd,
  //     'duration': bestMatch.duration,
  //     'simSlot': bestMatch.simSlot,
  //     'timeDifference': bestDifference,
  //   };

  //   print('');
  //   print('MATCH FOUND');
  //   print('Matched call phone: ${bestMatch.phoneNumber}');
  //   print('Call type: ${bestMatch.callType}');
  //   print('Call start: $callStart');
  //   print('Call end: $callEnd');
  //   print('SIM: ${bestMatch.simSlot}');
  //   print('Time difference: ${bestDifference} ms');
  //   print('Recording path: ${recording['path']}');
  //   print('');
  //   print('MATCH RESULT OBJECT:');
  //   print(matchResult);
  //   print('============================================');

  //   return matchResult;
  // }

  static Future<bool> uploadSingleRecording(
    Map<String, dynamic> matchResult, {
    String? token,
  }) async {
    final recordingPath = matchResult['recordingPath']?.toString() ?? '';
    final recordingTime = matchResult['recordingTime'];
    final recordingKey = _getRecordingKey(recordingPath, recordingTime);

    if (await _isRecordingUploaded(recordingKey)) {
      print(
          'CallRecordingService: Recording $recordingKey already uploaded, skipping.');
      return false;
    }

    final authToken = token ?? await Common.getSharedPref("token");
    if (authToken == null || authToken.toString().isEmpty) {
      print(
          'CallRecordingService: Auth token is null or empty, cannot upload recording.');
      return false;
    }
    print('========== MATCHED CALL DETAILS ==========');
    print('Recording path: $recordingPath');
    print('Call ID: ${matchResult['callId']}');
    print('Contact name: ${matchResult['callName']}');
    print('Phone: ${matchResult['callPhone']}');
    print('Call type: ${matchResult['callType']}');
    print('Call start: ${matchResult['callStart']}');
    print('Duration: ${matchResult['duration']}');
    print('SIM: ${matchResult['simSlot']}');
    print('==========================================');
    final body = {
      'token': authToken,
      'log': jsonEncode([
        {
          'name': matchResult['callPhone'],
          'phone_number': matchResult['callPhone'],
          'callTypes': matchResult['callType'],
          'time': matchResult['callStart'].toString(),
          'duration': matchResult['duration'].toString(),
          'simName': matchResult['simSlot'] ?? 'NIL',
          'timeStamp': matchResult['callStart'].toString(),
        }
      ]),
      'is_mannual': 0,
    };

    print(
        'CallRecordingService: Uploading recording for ${matchResult['callPhone']} at $recordingPath');

    try {
      final CallLogUploadModel? result = await HttpService.callLogUpload(
        body,
        recordingPath: recordingPath,
      );

      if (result != null && (result.data == true || result.status == true)) {
        await _markRecordingAsUploaded(recordingKey);
        print('CallRecordingService: Recording upload SUCCESS: $recordingKey');
        return true;
      } else {
        print(
            'CallRecordingService: Recording upload response indicated failure: ${result?.message}');
        return false;
      }
    } catch (e) {
      print('CallRecordingService: Exception uploading recording: $e');
      return false;
    }
  }

  /// Returns a match result map if [recording] matches [targetCall], or null
  /// with a detailed log of the rejection reason.
  // static Map<String, dynamic>? matchRecordingWithTargetCall(
  //   Map<String, dynamic> recording,
  //   HiveCaallHistoryModel targetCall,
  //   int attemptNumber,
  // ) {
  //   final recordingName = recording['name']?.toString() ?? '(unnamed)';
  //   final recordingPath = recording['path']?.toString() ?? '';
  //   final recordingPhone = recording['phoneNumber']?.toString() ?? '';
  //   final rawLastModified = recording['lastModified'];
  //   final recordingLastModified =
  //       int.tryParse(rawLastModified?.toString() ?? '');

  //   print(
  //       'AUTO RECORDING: [attempt $attemptNumber] Checking recording "$recordingName"');

  //   if (recordingPath.isNotEmpty) {
  //     final file = File(recordingPath);
  //     if (!file.existsSync()) {
  //       print(
  //           'AUTO RECORDING:   Rejected "$recordingName" — file does not exist on disk ($recordingPath)');
  //       return null;
  //     }
  //     if (file.lengthSync() == 0) {
  //       print(
  //           'AUTO RECORDING:   Rejected "$recordingName" — file is 0 bytes ($recordingPath)');
  //       return null;
  //     }
  //   }

  //   if (recordingLastModified == null) {
  //     print(
  //         'AUTO RECORDING:   Rejected "$recordingName" — lastModified missing or non-numeric (raw: $rawLastModified)');
  //     return null;
  //   }

  //   if (recordingPhone.isEmpty) {
  //     print(
  //         'AUTO RECORDING:   Rejected "$recordingName" — phoneNumber field is empty');
  //     return null;
  //   }

  //   final normalizedRecordingPhone = normalizePhoneNumber(recordingPhone);
  //   final normalizedTargetPhone = normalizePhoneNumber(targetCall.phoneNumber);

  //   if (normalizedRecordingPhone != normalizedTargetPhone) {
  //     print('AUTO RECORDING:   Rejected "$recordingName" — phone mismatch'
  //         ' (recording: $normalizedRecordingPhone, target: $normalizedTargetPhone)');
  //     return null;
  //   }

  //   // SIM check: only enforce when both sides have reliable SIM info.
  //   final targetSim = targetCall.simSlot.trim();
  //   final recordingSim = (recording['simSlot']?.toString() ?? '').trim();
  //   if (targetSim.isNotEmpty &&
  //       targetSim != 'NIL' &&
  //       recordingSim.isNotEmpty &&
  //       recordingSim != 'NIL' &&
  //       targetSim.toLowerCase() != recordingSim.toLowerCase()) {
  //     print('AUTO RECORDING:   Rejected "$recordingName" — SIM mismatch'
  //         ' (recording: $recordingSim, target: $targetSim)');
  //     return null;
  //   }

  //   final callStart = int.tryParse(targetCall.timeStamp);
  //   if (callStart == null) {
  //     print(
  //         'AUTO RECORDING:   Rejected "$recordingName" — target call timeStamp non-numeric: ${targetCall.timeStamp}');
  //     return null;
  //   }

  //   final durationSeconds = int.tryParse(targetCall.duration) ?? 0;
  //   final callEnd = callStart + (durationSeconds * 1000);
  //   final difference = recordingLastModified - callEnd;

  //   print(
  //       'AUTO RECORDING:   "$recordingName" — callEnd: $callEnd, recordingTime: $recordingLastModified, diff: ${difference}ms');

  //   if (difference < 0) {
  //     print(
  //         'AUTO RECORDING:   Rejected "$recordingName" — recording modified BEFORE call ended'
  //         ' (recording was ${(-difference)}ms too early)');
  //     return null;
  //   }

  //   const int maxRecordingDelayMs = 30 * 1000;
  //   if (difference > maxRecordingDelayMs) {
  //     print(
  //         'AUTO RECORDING:   Rejected "$recordingName" — recording modified >30s after call ended'
  //         ' (diff: ${difference}ms)');
  //     return null;
  //   }

  //   print('AUTO RECORDING:   MATCHED "$recordingName" (diff: ${difference}ms)');

  //   return {
  //     'recordingPath': recordingPath,
  //     'recordingUri': recording['uri']?.toString() ?? '',
  //     'recordingPhone': normalizedRecordingPhone,
  //     'recordingTime': recordingLastModified,
  //     'recordingName': recordingName,
  //     'recordingSize': recording['size'],
  //     'recordingMimeType': recording['mimeType']?.toString() ?? '',
  //     'callId': targetCall.id,
  //     'callPhone': targetCall.phoneNumber,
  //     'callType': targetCall.callType,
  //     'callStart': callStart,
  //     'callEnd': callEnd,
  //     'duration': targetCall.duration,
  //     'simSlot': targetCall.simSlot,
  //     'timeDifference': difference,
  //   };
  // }

  static Map<String, dynamic>? matchRecordingWithTargetCall(
    Map<String, dynamic> recording,
    HiveCaallHistoryModel targetCall,
    int attemptNumber,
  ) {
    final recordingName = recording['name']?.toString() ?? '(unnamed)';
    final recordingPath = recording['path']?.toString() ?? '';
    final recordingUri = recording['uri']?.toString() ?? '';

    final recordingTime = int.tryParse(
      recording['lastModified']?.toString() ?? '',
    );

    print(
      'AUTO RECORDING: [attempt $attemptNumber] '
      'Checking "$recordingName"',
    );

    if (recordingPath.isEmpty && recordingUri.isEmpty) {
      print('MATCH FAILED: No accessible path or URI');
      return null;
    }

    if (recordingPath.isNotEmpty) {
      final file = File(recordingPath);

      if (file.existsSync() && file.lengthSync() == 0) {
        print('MATCH FAILED: Recording is empty');
        return null;
      }

      // A missing filesystem path does not automatically reject a
      // MediaStore content URI.
    }

    if (recordingTime == null) {
      print('MATCH FAILED: Recording timestamp missing');
      return null;
    }

    final callStart = int.tryParse(targetCall.timeStamp);
    if (callStart == null) {
      print('MATCH FAILED: Invalid call timestamp');
      return null;
    }

    final durationSeconds = int.tryParse(targetCall.duration) ?? 0;
    final callEnd = callStart + durationSeconds * 1000;
    final difference = recordingTime - callEnd;

    const int earlyToleranceMs = 10 * 1000;
    const int maxRecordingDelayMs = 5 * 60 * 1000;

    if (difference < -earlyToleranceMs || difference > maxRecordingDelayMs) {
      print(
        'MATCH FAILED: Timestamp outside accepted window '
        '(difference: ${difference}ms)',
      );
      return null;
    }

    final targetSim = targetCall.simSlot.trim();
    final recordingSim = (recording['simSlot']?.toString() ?? '').trim();

    if (targetSim.isNotEmpty &&
        targetSim.toUpperCase() != 'NIL' &&
        recordingSim.isNotEmpty &&
        recordingSim.toUpperCase() != 'NIL' &&
        targetSim.toLowerCase() != recordingSim.toLowerCase()) {
      print('MATCH FAILED: SIM mismatch');
      return null;
    }

    print(
      'TIME CANDIDATE: "$recordingName"; '
      'phone number from filename was not used',
    );

    return {
      'recordingPath': recordingPath,
      'recordingUri': recordingUri,
      'recordingPhone': recording['phoneNumber']?.toString() ?? '',
      'recordingTime': recordingTime,
      'recordingName': recordingName,
      'recordingSize': recording['size'],
      'recordingMimeType': recording['mimeType']?.toString() ?? '',
      'callId': targetCall.id,
      'callPhone': targetCall.phoneNumber,
      'callType': targetCall.callType,
      'callStart': callStart,
      'callEnd': callEnd,
      'duration': targetCall.duration,
      'simSlot': targetCall.simSlot,
      'timeDifference': difference,
      'matchConfidence': 'time_only',
    };
  }

  /// One scan attempt: fetch all recordings, skip already-uploaded ones,
  /// try to match each against [targetCall]. Returns true if an upload succeeds.
  static Future<bool> processAutomaticRecordingForTargetCall({
    required HiveCaallHistoryModel targetCall,
    required int attemptNumber,
    String? token,
  }) async {
    try {
      final recordings = await CallRecordingNative.getNewRecordings();
      print(
          'AUTO RECORDING: [attempt $attemptNumber] getNewRecordings returned ${recordings.length} recording(s)');

      if (recordings.isEmpty) {
        print(
            'AUTO RECORDING: [attempt $attemptNumber] No recordings found on device');
        return false;
      }

      for (final rawRecording in recordings) {
        final recording = Map<String, dynamic>.from(rawRecording);
        final recordingPath = recording['path']?.toString() ?? '';
        final recordingTime = recording['lastModified'];
        final recordingKey = _getRecordingKey(recordingPath, recordingTime);

        if (await _isRecordingUploaded(recordingKey)) {
          print(
              'AUTO RECORDING: [attempt $attemptNumber] Skipping already-uploaded: $recordingKey');
          continue;
        }

        final match =
            matchRecordingWithTargetCall(recording, targetCall, attemptNumber);
        if (match != null) {
          print('AUTO RECORDING: MATCH RESULT: $match');
          print('AUTO RECORDING: TARGET CALL NAME: ${targetCall.name}');
          print('AUTO RECORDING: TARGET CALL PHONE: ${targetCall.phoneNumber}');
          print('AUTO RECORDING: TARGET CALL TYPE: ${targetCall.callType}');
          print(
              'AUTO RECORDING: TARGET CALL TIMESTAMP: ${targetCall.timeStamp}');
          print('AUTO RECORDING: TARGET CALL DURATION: ${targetCall.duration}');
          print('AUTO RECORDING: TARGET CALL SIM: ${targetCall.simSlot}');

          final success = await uploadSingleRecording(match, token: token);
          if (success) {
            print(
                'AUTO RECORDING: [attempt $attemptNumber] Upload SUCCEEDED for callId: ${match["callId"]}');
            return true;
          } else {
            print(
                'AUTO RECORDING: [attempt $attemptNumber] Upload FAILED for callId: ${match["callId"]}');
          }
        }
      }

      print(
          'AUTO RECORDING: [attempt $attemptNumber] No matching recording found in this scan');
      return false;
    } catch (e) {
      print('AUTO RECORDING: [attempt $attemptNumber] Error: $e');
      return false;
    }
  }

  static Future<int> processAndUploadRecordings({String? token}) async {
    try {
      final recordings = await CallRecordingNative.getNewRecordings();
      print(
          'MANUAL RECORDING: getNewRecordings returned ${recordings.length} recording(s)');

      if (recordings.isEmpty) {
        return 0;
      }

      int uploadedCount = 0;

      for (final rawRecording in recordings) {
        final recording = Map<String, dynamic>.from(rawRecording);
        final recordingPath = recording['path']?.toString() ?? '';
        final recordingTime = recording['lastModified'];
        final recordingKey = _getRecordingKey(recordingPath, recordingTime);

        if (await _isRecordingUploaded(recordingKey)) {
          print(
              'CallRecordingService: Skipping already uploaded recording: $recordingKey');
          continue;
        }

        final match = await matchRecordingWithCallLog(recording);
        if (match != null) {
          final success = await uploadSingleRecording(match, token: token);
          if (success) {
            uploadedCount++;
          }
        } else {
          print(
              'CallRecordingService: No match found for recording: $recordingPath');
        }
      }

      return uploadedCount;
    } catch (e) {
      print('CallRecordingService: Error processing recordings: $e');
      return 0;
    }
  }

  static Future<void> processAutomaticRecordingUploadWithRetry({
    required HiveCaallHistoryModel targetCall,
    String? token,
  }) async {
    print(
        'AUTO RECORDING: >>> ENTERED processAutomaticRecordingUploadWithRetry <<<');
    print(
        'AUTO RECORDING TARGET DETAILS: ID=${targetCall.id}, Phone=${targetCall.phoneNumber}, Start=${targetCall.timeStamp}, Duration=${targetCall.duration}s, SIM=${targetCall.simSlot}');

    const int maxAttempts = 4;
    const Duration retryDelay = Duration(seconds: 3);

    final callStart = int.tryParse(targetCall.timeStamp) ?? 0;
    final durationSec = int.tryParse(targetCall.duration) ?? 0;
    final callEnd = callStart + (durationSec * 1000);

    print(
        'AUTO RECORDING: Target start  : $callStart (${DateTime.fromMillisecondsSinceEpoch(callStart)})');
    print(
        'AUTO RECORDING: Target end    : $callEnd (${DateTime.fromMillisecondsSinceEpoch(callEnd)})');
    print(
        'AUTO RECORDING: Max attempts  : $maxAttempts, retry interval: ${retryDelay.inSeconds}s');
    print(
        'AUTO RECORDING: Waiting ${retryDelay.inSeconds}s before attempt 1 (giving dialer time to save file)');

    // Initial delay so the dialer has time to close and write the audio file.
    await Future.delayed(retryDelay);

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      print('AUTO RECORDING: >>> BEGIN ATTEMPT $attempt of $maxAttempts <<<');
      bool uploaded = false;
      try {
        uploaded = await processAutomaticRecordingForTargetCall(
          targetCall: targetCall,
          attemptNumber: attempt,
          token: token,
        );
      } catch (e) {
        print('AUTO RECORDING: [attempt $attempt] Unexpected error: $e');
      }

      print(
          'AUTO RECORDING: >>> END ATTEMPT $attempt of $maxAttempts (result: uploaded=$uploaded) <<<');

      if (uploaded) {
        print('AUTO: recording upload success');
        print(
            'AUTO RECORDING: Recording upload completed successfully on attempt $attempt');
        print('AUTO RECORDING: ========================================');
        return;
      }

      if (attempt < maxAttempts) {
        print(
            'AUTO RECORDING: [attempt $attempt] Not found yet. Waiting ${retryDelay.inSeconds}s before attempt ${attempt + 1}');
        await Future.delayed(retryDelay);
      }
    }

    print('AUTO: recording upload failure');
    print(
        'AUTO RECORDING: All $maxAttempts attempts exhausted — no matching recording found.');
    print(
        'AUTO RECORDING: Recording remains eligible for a later manual upload.');
    print('AUTO RECORDING: ========================================');
  }

  static Future<void> uploadCallRecordingManually(
    BuildContext context, {
    String? token,
  }) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Checking and uploading call recordings...'),
          duration: Duration(seconds: 2),
        ),
      );

      final uploadedCount = await processAndUploadRecordings(token: token);

      if (uploadedCount > 0) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '$uploadedCount call recording(s) uploaded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No new matching call recordings to upload.'),
            ),
          );
        }
      }
    } catch (e) {
      log('CallRecordingService [MANUAL]: Error during manual upload: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading call recordings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static Future<int> processAutomaticRecordingsForTargetCalls({
    required List<HiveCaallHistoryModel> targetCalls,
    String? token,
    required int attemptNumber,
  }) async {
    if (targetCalls.isEmpty) {
      print('No eligible calls available for recording matching.');
      return 0;
    }

    final recordings = await CallRecordingNative.getNewRecordings();

    print('Recordings found: ${recordings.length}');
    print('Calls available for matching: ${targetCalls.length}');

    if (recordings.isEmpty) {
      return 0;
    }

    final calls = List<HiveCaallHistoryModel>.from(targetCalls)
      ..sort((a, b) {
        final timeA = int.tryParse(a.timeStamp) ?? 0;
        final timeB = int.tryParse(b.timeStamp) ?? 0;
        return timeA.compareTo(timeB);
      });

    int uploadedCount = 0;

    for (final rawRecording in recordings) {
      try {
        if (rawRecording is! Map) {
          continue;
        }

        final recording = Map<String, dynamic>.from(rawRecording);

        final path = recording['recordingPath']?.toString() ??
            recording['path']?.toString() ??
            '';

        final lastModified = recording['lastModified'];

        if (path.isEmpty || lastModified == null) {
          print('Skipping recording: missing path or lastModified.');
          continue;
        }

        final recordingKey = _getRecordingKey(path, lastModified);

        if (await _isRecordingUploaded(recordingKey)) {
          print('Recording already uploaded: $path');
          continue;
        }

        Map<String, dynamic>? bestMatch;
        int bestDifference = 1 << 62;

        // Check this recording against every eligible call.
        for (final targetCall in calls) {
          final match = await matchRecordingWithTargetCall(
            recording,
            targetCall,
            attemptNumber,
          );

          if (match == null) {
            continue;
          }

          final difference =
              int.tryParse(match['timeDifference']?.toString() ?? '') ??
                  (1 << 62);

          if (bestMatch == null || difference < bestDifference) {
            bestMatch = match;
            bestDifference = difference;
          }
        }

        if (bestMatch == null) {
          print('No matching call found for recording: $path');
          continue;
        }

        print(
          'Matched recording ${bestMatch['recordingName']} '
          'to call ID ${bestMatch['callId']}',
        );

        final uploaded = await uploadSingleRecording(
          bestMatch,
          token: token,
        );

        if (uploaded) {
          uploadedCount++;
          print('Recording uploaded successfully: $path');
        } else {
          print('Recording upload failed: $path');
        }
      } catch (e, stackTrace) {
        print('Error processing recording: $e');
        print(stackTrace);
      }
    }

    print('Recordings uploaded in this attempt: $uploadedCount');
    return uploadedCount;
  }

  static Future<void> processAutomaticRecordingsForTargetCallsWithRetry({
    required List<HiveCaallHistoryModel> targetCalls,
    String? token,
  }) async {
    if (targetCalls.isEmpty) {
      print('No eligible calls to process recordings for.');
      return;
    }

    const maxAttempts = 4;
    const retryDelay = Duration(seconds: 3);

    // Allow the phone's dialer time to finish saving recordings.
    await Future.delayed(retryDelay);

    int totalUploaded = 0;

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      print(
        'Automatic recording scan: attempt $attempt/$maxAttempts',
      );

      final uploadedThisAttempt =
          await processAutomaticRecordingsForTargetCalls(
        targetCalls: targetCalls,
        token: token,
        attemptNumber: attempt,
      );

      totalUploaded += uploadedThisAttempt;

      // Do not stop after the first successful upload.
      // Later attempts may discover recordings that were saved late.
      if (attempt < maxAttempts) {
        await Future.delayed(retryDelay);
      }
    }

    print(
      'Automatic recording processing completed. '
      'Total successful uploads across attempts: $totalUploaded',
    );
  }
  //manual auto upload
  // static Future<bool> uploadManualCallWithRecording({
  //   required HiveCaallHistoryModel targetCall,
  //   required Map<String, dynamic> callLog,
  //   String? token,
  // }) async {
  //   try {
  //     final recordings = await CallRecordingNative.getNewRecordings();

  //     for (final rawRecording in recordings) {
  //       final recording = Map<String, dynamic>.from(rawRecording);
  //       final recordingPath = recording['path']?.toString() ?? '';
  //       final recordingTime = recording['lastModified'];
  //       final recordingKey = _getRecordingKey(recordingPath, recordingTime);

  //       if (await _isRecordingUploaded(recordingKey)) {
  //         continue;
  //       }

  //       final match = matchRecordingWithTargetCall(
  //         recording,
  //         targetCall,
  //         0,
  //       );

  //       if (match == null) continue;

  //       final authToken = token ?? await Common.getSharedPref('token');
  //       if (authToken == null || authToken.toString().isEmpty) {
  //         print('Manual upload: missing auth token');
  //         return false;
  //       }

  //       final body = <String, dynamic>{
  //         'token': authToken,
  //         'log': jsonEncode([callLog]),
  //         'is_mannual': 1,
  //       };

  //       final result = await HttpService.callLogUpload(
  //         body,
  //         recordingPath: recordingPath,
  //       );

  //       if (result != null && (result.data == true || result.status == true)) {
  //         await _markRecordingAsUploaded(recordingKey);
  //         return true;
  //       }

  //       print('Manual upload failed: ${result?.message}');
  //       return false;
  //     }

  //     print('Manual upload: no matching, not-yet-uploaded recording found');
  //     return false;
  //   } catch (e, stackTrace) {
  //     print('Manual upload with recording error: $e');
  //     print(stackTrace);
  //     return false;
  //   }
  // }

  //manual upload using file picker

  static Future<bool> uploadManualRecording({
    required String id,
    String? token,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return false;
      }

      final recordingPath = result.files.single.path;
      if (recordingPath == null) return false;

      final authToken = token ?? await Common.getSharedPref('token');

      if (authToken == null || authToken.toString().isEmpty) {
        return false;
      }

      final response = await HttpService.uploadManualRecording(
        recordingPath: recordingPath,
        id: id,
      
      );

      print('Manual upload response: $response');

      // Replace with your API's actual success condition.
      return response != null;
    } catch (e, stackTrace) {
      print('Manual recording upload error: $e');
      print(stackTrace);
      return false;
    }
  }
}

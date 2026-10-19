class CallLogHistoryModel {
  bool? status;
  String? message;
  Data? data;

  CallLogHistoryModel({this.status, this.message, this.data});

  CallLogHistoryModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  List<CallLogData>? lists;
  String? totalDuration;

  Data({this.lists, this.totalDuration});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['lists'] != null) {
      lists = <CallLogData>[];
      json['lists'].forEach((v) {
        lists!.add(CallLogData.fromJson(v));
      });
    }
    totalDuration = json['total_duration'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (lists != null) {
      data['lists'] = lists!.map((v) => v.toJson()).toList();
    }
    data['total_duration'] = totalDuration;
    return data;
  }
}

// class CallLogData {
//   String? id;
//   String? name;
//   String? phoneNumber;
//   String? callType;
//   String? duration;
//   String? simName;
//   String? dateTime;
//   String? userId;
//   String? staffName;
//   String? isMannual;
//   String? resourceUrl;

//   CallLogData(
//       {this.id,
//       this.name,
//       this.phoneNumber,
//       this.callType,
//       this.duration,
//       this.simName,
//       this.dateTime,
//       this.userId,
//       this.staffName,
//       this.isMannual,
//       this.resourceUrl});

//   CallLogData.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     name = json['name']?.toString();
//     phoneNumber = json['phone_number'];
//     callType = json['callType'];
//     duration = json['duration'];
//     simName = json['SimName'];
//     dateTime = json['date_time'];
//     userId = json['user_id'];
//     staffName = json['staff_name'];
//     isMannual = json['is_mannual']?.toString();
//     resourceUrl = json['ResourceURL'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = id;
//     data['name'] = name;
//     data['phone_number'] = phoneNumber;
//     data['callType'] = callType;
//     data['duration'] = duration;
//     data['SimName'] = simName;
//     data['date_time'] = dateTime;
//     data['user_id'] = userId;
//     data['staff_name'] = staffName;
//     data['is_mannual'] = isMannual;
//     data['ResourceURL'] = resourceUrl;
//     return data;
//   }
// }

class CallLogData {
  String? id;
  String? name;
  String? phoneNumber;
  String? callType;
  String? duration;
  String? simName;
  String? dateTime;
  String? userId;
  String? staffName;
  String? isMannual;

  // Recording-related fields from the new API response
  String? recording;
  String? recordingUrl;
  String? driveFileId;
  String? callMasterId;

  CallLogData({
    this.id,
    this.name,
    this.phoneNumber,
    this.callType,
    this.duration,
    this.simName,
    this.dateTime,
    this.userId,
    this.staffName,
    this.isMannual,
    this.recording,
    this.recordingUrl,
    this.driveFileId,
    this.callMasterId,
  });

  CallLogData.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    name = json['name']?.toString();
    phoneNumber = json['phone_number']?.toString();
    callType = json['callType']?.toString();
    duration = json['duration']?.toString();
    simName = json['SimName']?.toString();
    dateTime = json['date_time']?.toString();
    userId = json['user_id']?.toString();
    staffName = json['staff_name']?.toString();
    isMannual = json['is_mannual']?.toString();

    recording = json['recording']?.toString();
    recordingUrl = json['recording_url']?.toString();
    driveFileId = json['drive_file_id']?.toString();
    callMasterId = json['call_master_id']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['id'] = id;
    data['name'] = name;
    data['phone_number'] = phoneNumber;
    data['callType'] = callType;
    data['duration'] = duration;
    data['SimName'] = simName;
    data['date_time'] = dateTime;
    data['user_id'] = userId;
    data['staff_name'] = staffName;
    data['is_mannual'] = isMannual;

    data['recording'] = recording;
    data['recording_url'] = recordingUrl;
    data['drive_file_id'] = driveFileId;
    data['call_master_id'] = callMasterId;

    return data;
  }
}

import 'dart:convert';

LeadFollowupData leadFollowupDataFromJson(String str) =>
    LeadFollowupData.fromJson(json.decode(str));

String leadFollowupDataToJson(LeadFollowupData data) =>
    json.encode(data.toJson());
class LeadFollowupData {
  Data data;
  bool status;
  String message;

  LeadFollowupData({
    required this.data,
    required this.status,
    required this.message,
  });
  factory LeadFollowupData.fromJson(Map<String, dynamic> json) =>
      LeadFollowupData(
        data: json["data"] != null
            ? Data.fromJson(json["data"])
            : Data(followUpData: []),
        status: json["status"] ?? false,
        message: json["message"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "data": data.toJson(),
        "status": status,
        "message": message,
      };
}

class Data {
  List<FollowUpDatum> followUpData;

  Data({
    required this.followUpData,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        followUpData: json["followUpData"] != null
            ? List<FollowUpDatum>.from(
                json["followUpData"].map((x) => FollowUpDatum.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "followUpData": List<dynamic>.from(followUpData.map((x) => x.toJson())),
      };
}

class FollowUpDatum {
  String callDetailsId;
  String scheduledDate;
  String date;
  String calledDate;
  String remarks;
  String callMasterId;
  String callResult;
  String staffName;
  String proPicThumb;
  String callStatusId;
  String callResultId;
  String callResponseId;
  String callResponse;
  String reasonId;
  String reason;
  String productNames;
  bool isCalled;
  bool isEdit;
  bool isDelete;
  String dispalyDate;
  bool isSetReminder;
  bool isReminder;
  String time;
  String voiceFile;
  bool voiceUploadPermission;
  bool playVoicePermission;
  String isNewCall;
  String expectedClosing;
  FollowUpDatum({
    required this.callDetailsId,
    required this.scheduledDate,
    required this.date,
    required this.calledDate,
    required this.remarks,
    required this.callMasterId,
    required this.callResult,
    required this.staffName,
    required this.proPicThumb,
    required this.callStatusId,
    required this.callResultId,
    required this.callResponseId,
    required this.callResponse,
    required this.reasonId,
    required this.reason,
    required this.productNames,
    required this.isCalled,
    required this.isEdit,
    required this.isDelete,
    required this.dispalyDate,
    required this.isSetReminder,
    required this.isReminder,
    required this.time,
    required this.voiceFile,
    required this.voiceUploadPermission,
    required this.playVoicePermission,
    required this.isNewCall,
    required this.expectedClosing,
  });

  factory FollowUpDatum.fromJson(Map<String, dynamic> json) => FollowUpDatum(
        callDetailsId: json["call_details_id"] ?? "",
        scheduledDate: json["scheduled_date"] ?? "",
        date: json["date"] ?? "",
        calledDate: json["called_date"] ?? "",
        remarks: json["remarks"] ?? "",
        callMasterId: json["call_master_id"] ?? "",
        callResult: json["call_result"] ?? "",
        staffName: json["staff_name"] ?? "",
        proPicThumb: json["pro_pic_thumb"] ?? "",
        callStatusId: json["call_status_id"] ?? "",
        callResultId: json["call_result_id"] ?? "",
        callResponseId: json["call_response_id"] ?? "",
        callResponse: json["call_response"] ?? "",
        reasonId: json["reason_id"] ?? "",
        reason: json["reason"] ?? "",
        productNames: json["product_names"] ?? "",
        isCalled: json["is_called"] ?? false,
        isEdit: json["is_edit"] ?? false,
        isDelete: json["is_delete"] ?? false,
        dispalyDate: json["dispaly_date"] ?? "",
        isSetReminder: json["isSetReminder"] ?? false,
        isReminder: json["isReminder"] ?? false,
        time: json["time"] ?? "",
        voiceFile: json["voice_file"] ?? "",
        voiceUploadPermission: json["voiceUploadPermission"] ?? false,
        playVoicePermission: json["playVoicePermission"] ?? false,
        isNewCall: json["is_new_call"] ?? false,
        expectedClosing: json["expected_closing_date"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "call_details_id": callDetailsId,
        "scheduled_date": scheduledDate,
        "date": date,
        "called_date": calledDate,
        "remarks": remarks,
        "call_master_id": callMasterId,
        "call_result": callResult,
        "staff_name": staffName,
        "pro_pic_thumb": proPicThumb,
        "call_status_id": callStatusId,
        "call_result_id": callResultId,
        "call_response_id": callResponseId,
        "call_response": callResponse,
        "reason_id": reasonId,
        "reason": reason,
        "product_names": productNames,
        "is_called": isCalled,
        "is_edit": isEdit,
        "is_delete": isDelete,
        "dispaly_date": dispalyDate,
        "isSetReminder": isSetReminder,
        "isReminder": isReminder,
        "time": time,
        "voice_file": voiceFile,
        "voiceUploadPermission": voiceUploadPermission,
        "playVoicePermission": playVoicePermission,
        "is_new_call": isNewCall,
        "expected_closing_date": expectedClosing,
      };
}

import 'dart:convert';

AttendanceDataModel attendanceDataModelFromJson(String str) =>
    AttendanceDataModel.fromJson(json.decode(str));

String attendanceDataModelToJson(AttendanceDataModel data) =>
    json.encode(data.toJson());

class AttendanceDataModel {
  String status;
  Data data;

  AttendanceDataModel({
    required this.status,
    required this.data,
  });

  factory AttendanceDataModel.fromJson(Map<String, dynamic> json) =>
      AttendanceDataModel(
        status: json["status"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data.toJson(),
      };
}

class Data {
  StaffInfo staffInfo;
  List<CalendarDatum> calendarData;
  MonthlyStats monthlyStats;

  Data({
    required this.staffInfo,
    required this.calendarData,
    required this.monthlyStats,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        staffInfo: StaffInfo.fromJson(json["staff_info"]),
        calendarData: List<CalendarDatum>.from(
            json["calendar_data"].map((x) => CalendarDatum.fromJson(x))),
        monthlyStats: MonthlyStats.fromJson(json["monthly_stats"]),
      );

  Map<String, dynamic> toJson() => {
        "staff_info": staffInfo.toJson(),
        "calendar_data":
            List<dynamic>.from(calendarData.map((x) => x.toJson())),
        "monthly_stats": monthlyStats.toJson(),
      };
}

class CalendarDatum {
  DateTime date;
  String type;
  String title;
  String description;
  String loginTime;
  String logoutTime;
  String idealTime;
  String workTime;
  String totalDuration;
  String reason;

  CalendarDatum({
    required this.date,
    required this.type,
    required this.title,
    required this.description,
    required this.loginTime,
    required this.logoutTime,
    required this.idealTime,
    required this.workTime,
    required this.totalDuration,
    required this.reason,
  });

  factory CalendarDatum.fromJson(Map<String, dynamic> json) => CalendarDatum(
        date: DateTime.parse(json["date"]),
        type: json["type"] ?? "",
        title: json["title"] ?? "",
        description: json["description"] ?? "",
        loginTime: json["login_time"] ?? "",
        logoutTime: json["logout_time"] ?? "",
        idealTime: json["idle_time"] ?? "",
        workTime: json["work_time"] ?? "",
        totalDuration: json["total_duration"] ?? "",
        reason: json["leave_reason"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "date":
            "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "type": type,
        "title": title,
        "description": description,
        "login_time": loginTime,
        "logout_time": logoutTime,
        "idle_time": idealTime,
        "work_time": workTime,
        "total_duration": totalDuration,
        "leave_reason": reason,
      };
}

class MonthlyStats {
  String fullDays;
  String halfDays;
  int leaveDays;

  MonthlyStats({
    required this.fullDays,
    required this.halfDays,
    required this.leaveDays,
  });

  factory MonthlyStats.fromJson(Map<String, dynamic> json) => MonthlyStats(
        fullDays: json["full_days"],
        halfDays: json["half_days"],
        leaveDays: json["leave_days"],
      );

  Map<String, dynamic> toJson() => {
        "full_days": fullDays,
        "half_days": halfDays,
        "leave_days": leaveDays,
      };
}

class StaffInfo {
  String staffId;
  String staffName;
  dynamic designation;

  StaffInfo({
    required this.staffId,
    required this.staffName,
    required this.designation,
  });

  factory StaffInfo.fromJson(Map<String, dynamic> json) => StaffInfo(
        staffId: json["staff_id"],
        staffName: json["staff_name"],
        designation: json["designation"],
      );

  Map<String, dynamic> toJson() => {
        "staff_id": staffId,
        "staff_name": staffName,
        "designation": designation,
      };
}

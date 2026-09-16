// To parse this JSON data, do
//
//     final salaryDetailsModel = salaryDetailsModelFromJson(jsonString);

import 'dart:convert';

SalaryDetailsModel salaryDetailsModelFromJson(String str) =>
    SalaryDetailsModel.fromJson(json.decode(str));

String salaryDetailsModelToJson(SalaryDetailsModel data) =>
    json.encode(data.toJson());

class SalaryDetailsModel {
  bool status;
  Data data;

  SalaryDetailsModel({
    required this.status,
    required this.data,
  });

  factory SalaryDetailsModel.fromJson(Map<String, dynamic> json) =>
      SalaryDetailsModel(
        status: json["status"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data.toJson(),
      };
}

String? _parseRemarks(dynamic input) {
  if (input == null) return null;
  if (input is Map) {
    final val = input["remarks"] ?? input["remark"];
    if (val != null) return _parseRemarks(val);
    return null;
  }
  if (input is List) {
    final list = input
        .map((e) => _parseRemarks(e))
        .where((e) => e != null && e.isNotEmpty)
        .join(", ");
    return list.isEmpty ? null : list;
  }
  final str = input.toString().trim();
  if (str.isEmpty || str == "null" || str == "{}") return null;
  return str;
}

class Data {
  String staffName;
  String? remarks;
  WorkingDetails workingDetails;
  LeaveDetails leaveDetails;
  SalaryDetails salaryDetails;

  Data({
    required this.staffName,
    this.remarks,
    required this.workingDetails,
    required this.leaveDetails,
    required this.salaryDetails,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        staffName: json["staff_name"]?.toString() ?? "",
        remarks: _parseRemarks(json["remarks"]) ??
            _parseRemarks(json["remark"]) ??
            _parseRemarks(json["salary_details"]?["remarks"]) ??
            _parseRemarks(json["salary_details"]?["remark"]),
        workingDetails: WorkingDetails.fromJson(json["working_details"] ?? {}),
        leaveDetails: LeaveDetails.fromJson(json["leave_details"] ?? {}),
        salaryDetails: SalaryDetails.fromJson(json["salary_details"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "staff_name": staffName,
        "remarks": remarks,
        "working_details": workingDetails.toJson(),
        "leave_details": leaveDetails.toJson(),
        "salary_details": salaryDetails.toJson(),
      };
}

class LeaveDetails {
  int availableLeave;
  int casualLeave;
  int saturdayLeave;
  double totalLeave;
  double lop;

  LeaveDetails({
    required this.availableLeave,
    required this.casualLeave,
    required this.saturdayLeave,
    required this.totalLeave,
    required this.lop,
  });

  factory LeaveDetails.fromJson(Map<String, dynamic> json) => LeaveDetails(
        availableLeave: (json["available_leave"] as num).toInt(),
        casualLeave: (json["casual_leave"] as num).toInt(),
        saturdayLeave: (json["saturday_leave"] as num).toInt(),
        totalLeave: json["total_leave"]?.toDouble(),
        lop: json["lop"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "available_leave": availableLeave,
        "casual_leave": casualLeave,
        "saturday_leave": saturdayLeave,
        "total_leave": totalLeave,
        "lop": lop,
      };
}

class SalaryDetails {
  double salaryCreditDays;
  int monthlySalary;
  int perDaySalary;
  int incentives;
  int deductions;
  int netSalary;
  String? remarks;

  SalaryDetails({
    required this.salaryCreditDays,
    required this.monthlySalary,
    required this.perDaySalary,
    required this.incentives,
    required this.deductions,
    required this.netSalary,
    this.remarks,
  });

  factory SalaryDetails.fromJson(Map<String, dynamic> json) => SalaryDetails(
        salaryCreditDays: json["salary_credit_days"]?.toDouble() ?? 0.0,
        monthlySalary: (json["monthly_salary"] as num?)?.toInt() ?? 0,
        perDaySalary: (json["per_day_salary"] as num?)?.toInt() ?? 0,
        incentives: (json["incentives"] as num?)?.toInt() ?? 0,
        deductions: (json["deductions"] as num?)?.toInt() ?? 0,
        netSalary: (json["net_salary"] as num?)?.toInt() ?? 0,
        remarks: _parseRemarks(json["remarks"]) ?? _parseRemarks(json["remark"]),
      );

  Map<String, dynamic> toJson() => {
        "salary_credit_days": salaryCreditDays,
        "monthly_salary": monthlySalary,
        "per_day_salary": perDaySalary,
        "incentives": incentives,
        "deductions": deductions,
        "net_salary": netSalary,
        "remarks": remarks,
      };
}

class WorkingDetails {
  int totalWorkingDays;
  int fullDays;
  int halfDays;
  double totalWorkedDays;

  WorkingDetails({
    required this.totalWorkingDays,
    required this.fullDays,
    required this.halfDays,
    required this.totalWorkedDays,
  });

  factory WorkingDetails.fromJson(Map<String, dynamic> json) => WorkingDetails(
        totalWorkingDays:
            (json["total_working_days"] as num).toInt(), 
        fullDays: (json["full_days"] as num).toInt(), 
        halfDays: (json["half_days"] as num).toInt(),
        totalWorkedDays: json["total_worked_days"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "total_working_days": totalWorkingDays,
        "full_days": fullDays,
        "half_days": halfDays,
        "total_worked_days": totalWorkedDays,
      };
}

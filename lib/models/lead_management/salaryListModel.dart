// To parse this JSON data, do
//
//     final salaryList = salaryListFromJson(jsonString);

import 'dart:convert';

SalaryList salaryListFromJson(String str) =>
    SalaryList.fromJson(json.decode(str));

String salaryListToJson(SalaryList data) => json.encode(data.toJson());

class SalaryList {
  bool status;
  String monthyear;
  List<SalaryOnList> data;

  SalaryList({
    required this.status,
    required this.monthyear,
    required this.data,
  });

  factory SalaryList.fromJson(Map<String, dynamic> json) => SalaryList(
        status: json["status"],
        monthyear: json["monthyear"],
        data: List<SalaryOnList>.from(
            json["data"].map((x) => SalaryOnList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "monthyear": monthyear,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class SalaryOnList {
  String id;
  String staffName;
  String monthlySalary;
  String workedDays;
  String lopDays;
  String remarks;
  String status;

  SalaryOnList({
    required this.id,
    required this.staffName,
    required this.monthlySalary,
    required this.workedDays,
    required this.lopDays,
    required this.remarks,
    required this.status,
  });

  factory SalaryOnList.fromJson(Map<String, dynamic> json) => SalaryOnList(
        id: json["id"] ?? "",
        staffName: json["staff_name"] ?? "",
        monthlySalary: json["monthly_salary"] ?? "",
        workedDays: json["worked_days"] ?? "",
        lopDays: json["lop_days"] ?? "",
        remarks: json["remarks"] ?? "",
        status: json["status"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "staff_name": staffName,
        "monthly_salary": monthlySalary,
        "worked_days": workedDays,
        "lop_days": lopDays,
        "remarks": remarks,
        "status": status,
      };
}

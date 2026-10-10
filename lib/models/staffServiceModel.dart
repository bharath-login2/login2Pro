import 'package:login2/models/expense/staffListModel.dart';
export 'package:login2/models/expense/staffListModel.dart';

class StaffServiceModel {
  final bool status;
  final String message;
  final List<Staff> data;

  StaffServiceModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory StaffServiceModel.fromJson(Map<String, dynamic> json) {
    return StaffServiceModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null && json['data'] is List
          ? (json['data'] as List).map((e) => Staff.fromJson(e)).toList()
          : [],
    );
  }
}

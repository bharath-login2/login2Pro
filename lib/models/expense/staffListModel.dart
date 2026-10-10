class StaffListModel {
  final bool status;
  final String message;
  final List<Staff> data;

  StaffListModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory StaffListModel.fromJson(Map<String, dynamic> json) {
    return StaffListModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null && json['data'] is List
          ? (json['data'] as List).map((e) => Staff.fromJson(e)).toList()
          : [],
    );
  }
}

class Staff {
  final String id;
  final String name;
  final String userIdStaff;
  final String phoneNo;

  Staff({
    required this.id,
    required this.name,
    required this.userIdStaff,
    this.phoneNo = '',
  });

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      userIdStaff: json['user_id']?.toString() ?? '',
      phoneNo: json['phone_no']?.toString() ??
          json['mobile']?.toString() ??
          json['phone']?.toString() ??
          '',
    );
  }
}

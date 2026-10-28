class AttendanceListModel {
  bool? status;
  String? message;
  List<AttendanceRecord>? data;

  AttendanceListModel({
    this.status,
    this.message,
    this.data,
  });

  AttendanceListModel.fromJson(Map<String, dynamic> json) {
    if (json['status'] is bool) {
      status = json['status'];
    } else if (json['status'] != null) {
      final s = json['status'].toString().toLowerCase().trim();
      status = (s == 'true' || s == '1' || s == 'success');
    } else {
      status = false;
    }

    message = json['message']?.toString();

    if (json['data'] != null) {
      if (json['data'] is List) {
        data = <AttendanceRecord>[];
        for (var v in (json['data'] as List)) {
          if (v is Map<String, dynamic>) {
            data!.add(AttendanceRecord.fromJson(v));
          }
        }
      } else if (json['data'] is Map<String, dynamic>) {
        final map = json['data'] as Map<String, dynamic>;
        final dynamic nestedList =
            map['records'] ?? map['list'] ?? map['attendance'] ?? map['data'];
        if (nestedList is List) {
          data = <AttendanceRecord>[];
          for (var v in nestedList) {
            if (v is Map<String, dynamic>) {
              data!.add(AttendanceRecord.fromJson(v));
            }
          }
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['status'] = status;
    map['message'] = message;
    if (data != null) {
      map['data'] = data!.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class AttendanceRecord {
  String? id;
  String? userId;
  String? staffName;
  String? loginTime;
  String? logoutTime;
  String? loginLatitude;
  String? loginLongitude;
  String? locationUrl;
  String? loginImageId;
  String? loginImage;

  AttendanceRecord({
    this.id,
    this.userId,
    this.staffName,
    this.loginTime,
    this.logoutTime,
    this.loginLatitude,
    this.loginLongitude,
    this.locationUrl,
    this.loginImageId,
    this.loginImage,
  });

  AttendanceRecord.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    userId = (json['user_id'] ?? json['userId'])?.toString();
    staffName = (json['staff_name'] ?? json['staffName'])?.toString();
    loginTime = (json['login_time'] ?? json['loginTime'])?.toString();
    logoutTime = (json['logout_time'] ?? json['logoutTime'])?.toString();
    loginLatitude =
        (json['login_latitude'] ?? json['loginLatitude'])?.toString();
    loginLongitude =
        (json['login_longitude'] ?? json['loginLongitude'])?.toString();
    locationUrl = (json['location_url'] ?? json['locationUrl'])?.toString();
    loginImageId =
        (json['login_image_id'] ?? json['loginImageId'])?.toString();
    loginImage = (json['login_image'] ?? json['loginImage'])?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['id'] = id;
    map['user_id'] = userId;
    map['staff_name'] = staffName;
    map['login_time'] = loginTime;
    map['logout_time'] = logoutTime;
    map['login_latitude'] = loginLatitude;
    map['login_longitude'] = loginLongitude;
    map['location_url'] = locationUrl;
    map['login_image_id'] = loginImageId;
    map['login_image'] = loginImage;
    return map;
  }
}

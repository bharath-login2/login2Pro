class GetAttendanceReportModel {
  bool? status;
  String? message;
  Data? data;

  GetAttendanceReportModel({this.status, this.message, this.data});

  GetAttendanceReportModel.fromJson(Map<String, dynamic> json) {
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
  List<ListData>? list;
  Summary? summary;

  Data({this.list, this.summary});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['list'] != null) {
      list = <ListData>[];
      json['list'].forEach((v) {
        list!.add(ListData.fromJson(v));
      });
    }
    summary =
        json['summary'] != null ? Summary.fromJson(json['summary']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (list != null) {
      data['list'] = list!.map((v) => v.toJson()).toList();
    }
    if (summary != null) {
      data['summary'] = summary!.toJson();
    }
    return data;
  }
}

class ListData {
  String? id;
  String? date;
  String? loginTime;
  String? logoutTime;
  String? workingTime;
  String? idleTime;
  String? status;
  String? logoutStatus;
  String? remarks;
  String? leaveReason;
  String? get leave_reason => leaveReason;

  ListData({
    this.id,
    this.date,
    this.loginTime,
    this.logoutTime,
    this.workingTime,
    this.idleTime,
    this.status,
    this.logoutStatus, 
    this.remarks,
    this.leaveReason,
  });

  ListData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    date = json['date'];
    loginTime = json['login_time'];
    logoutTime = json['logout_time'];
    workingTime = json['working_time'];
    idleTime = json['idle_time'];
    status = json['status'];
    logoutStatus = json['logout_status'];
    remarks = json['remark'];
    leaveReason = json['leave_reason'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['date'] = date;
    data['login_time'] = loginTime;
    data['logout_time'] = logoutTime;
    data['working_time'] = workingTime;
    data['idle_time'] = idleTime;
    data['status'] = status;   
    data['logout_status'] = logoutStatus;
    data['remark'] = remarks;
    data['leave_reason'] = leaveReason;
    return data;
  }
}

class Summary {
  String? totalWorkingTime;
  String? totalIdleTime;
  String? totalWorkableTime;
  String? totalAllowedIdleTime;
  String? effectiveTime;

  Summary({
    this.totalWorkingTime,
    this.totalIdleTime,
    this.totalWorkableTime,
    this.totalAllowedIdleTime,
    this.effectiveTime,
  });

  Summary.fromJson(Map<String, dynamic> json) {
    totalWorkingTime = json['total_working_time'];
    totalIdleTime = json['total_idle_time'];
    totalWorkableTime = json['total_workable_time'];
    totalAllowedIdleTime = json['total_allowed_idle_time'];
    effectiveTime = json['effective_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_working_time'] = totalWorkingTime;
    data['total_idle_time'] = totalIdleTime;
    data['total_workable_time'] = totalWorkableTime;
    data['total_allowed_idle_time'] = totalAllowedIdleTime;
    data['effective_time'] = effectiveTime;
    return data;
  }
}

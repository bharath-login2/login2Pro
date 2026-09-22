class ServiceDashboardCountsModel {
  bool? status;
  String? message;
  ServiceDashboardCountsData? data;

  ServiceDashboardCountsModel({this.status, this.message, this.data});

  ServiceDashboardCountsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null
        ? ServiceDashboardCountsData.fromJson(json['data'])
        : null;
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

class ServiceDashboardCountsData {
  int? newOrders;
  int? pendingOrders;
  int? inprogressOrders;
  int? completedOrders;
  int? overdueOrders;
  num? todaysCollection;
  num? thisMonthCollection;
  num? dueCollection;

  ServiceDashboardCountsData({
    this.newOrders,
    this.pendingOrders,
    this.inprogressOrders,
    this.completedOrders,
    this.overdueOrders,
    this.todaysCollection,
    this.thisMonthCollection,
    this.dueCollection,
  });

  ServiceDashboardCountsData.fromJson(Map<String, dynamic> json) {
    newOrders = _parseInt(json['new_orders']);
    pendingOrders = _parseInt(json['pending_orders']);
    inprogressOrders = _parseInt(json['inprogress_orders']);
    completedOrders = _parseInt(json['completed_orders']);
    overdueOrders = _parseInt(json['overdue_orders']);
    todaysCollection = _parseNum(json['todays_collection']);
    thisMonthCollection = _parseNum(json['this_month_collection']);
    dueCollection = _parseNum(json['due_collection']);
  }

  static int? _parseInt(dynamic val) {
    if (val == null) return null;
    if (val is int) return val;
    if (val is double) return val.toInt();
    if (val is String) return int.tryParse(val);
    return null;
  }

  static num? _parseNum(dynamic val) {
    if (val == null) return null;
    if (val is num) return val;
    if (val is String) return num.tryParse(val);
    return null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['new_orders'] = newOrders;
    data['pending_orders'] = pendingOrders;
    data['inprogress_orders'] = inprogressOrders;
    data['completed_orders'] = completedOrders;
    data['overdue_orders'] = overdueOrders;
    data['todays_collection'] = todaysCollection;
    data['this_month_collection'] = thisMonthCollection;
    data['due_collection'] = dueCollection;
    return data;
  }
}

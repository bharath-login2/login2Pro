import 'dart:convert';

CustomerDashboardCountsModel customerDashboardCountsModelFromJson(String str) =>
    CustomerDashboardCountsModel.fromJson(json.decode(str));

String customerDashboardCountsModelToJson(CustomerDashboardCountsModel data) =>
    json.encode(data.toJson());

class CustomerDashboardCountsModel {
  final bool status;
  final String message;
  final CustomerDashboardCountsData? data;

  CustomerDashboardCountsModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory CustomerDashboardCountsModel.fromJson(Map<String, dynamic> json) {
    dynamic dataObj = json["data"];
    if (dataObj is String) {
      try {
        dataObj = jsonDecode(dataObj);
      } catch (_) {}
    }
    return CustomerDashboardCountsModel(
      status: json["status"] == true ||
          json["status"] == 1 ||
          json["status"]?.toString().toLowerCase() == "true",
      message: json["message"]?.toString() ?? "",
      data: dataObj != null && dataObj is Map<String, dynamic>
          ? CustomerDashboardCountsData.fromJson(
              Map<String, dynamic>.from(dataObj))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class CustomerDashboardCountsData {
  final int followupCount;
  final int calledCount;
  final int missedCount;
  final int transferredCount;
  final String fromDate;
  final String toDate;

  CustomerDashboardCountsData({
    required this.followupCount,
    required this.calledCount,
    required this.missedCount,
    required this.transferredCount,
    required this.fromDate,
    required this.toDate,
  });

  factory CustomerDashboardCountsData.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is num) return val.toInt();
      return int.tryParse(val.toString()) ?? 0;
    }

    return CustomerDashboardCountsData(
      followupCount: parseInt(json["followup_count"] ??
          json["followup"] ??
          json["follow_up_count"]),
      calledCount: parseInt(json["called_count"] ??
          json["called"] ??
          json["total_called_count"] ??
          json["total_called"]),
      missedCount: parseInt(json["missed_count"] ?? json["missed"]),
      transferredCount: parseInt(json["transferred_count"] ??
          json["transferred"] ??
          json["transfer_count"]),
      fromDate:
          json["from_date"]?.toString() ?? json["start_date"]?.toString() ?? "",
      toDate: json["to_date"]?.toString() ?? json["end_date"]?.toString() ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "followup_count": followupCount,
        "called_count": calledCount,
        "missed_count": missedCount,
        "transferred_count": transferredCount,
        "from_date": fromDate,
        "to_date": toDate,
      };
}

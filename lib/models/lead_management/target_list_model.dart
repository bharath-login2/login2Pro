import 'dart:convert';

TargetListResponse targetListResponseFromJson(String str) =>
    TargetListResponse.fromJson(json.decode(str));

String targetListResponseToJson(TargetListResponse data) =>
    json.encode(data.toJson());

class TargetListResponse {
  final List<TargetList> data;
  final bool status;
  final String message;

  TargetListResponse({
    required this.data,
    required this.status,
    required this.message,
  });

  factory TargetListResponse.fromJson(Map<String, dynamic> json) =>
      TargetListResponse(
        data: json["data"] == null
            ? []
            : List<TargetList>.from(
                json["data"].map((x) => TargetList.fromJson(x)),
              ),
        status: json["status"] ?? false,
        message: json["message"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "status": status,
        "message": message,
      };
}

class TargetList {
  final String groupName;
  final String maxAmount;
  final String achieved;
  final String progressPercentage;

  TargetList({
    required this.groupName,
    required this.maxAmount,
    required this.achieved,
    required this.progressPercentage,
  });

  factory TargetList.fromJson(Map<String, dynamic> json) => TargetList(
        groupName: json["group_name"] ?? "",
        maxAmount: json["max_amount"] ?? "0.00",
        achieved: json["achieved"] ?? "0.00",
        progressPercentage: json["progress_percentage"] ?? "0.00",
      );

  Map<String, dynamic> toJson() => {
        "group_name": groupName,
        "max_amount": maxAmount,
        "achieved": achieved,
        "progress_percentage": progressPercentage,
      };

  // Optional helper getters if you need numeric values in your UI (e.g., for progress bars)
  double get maxAmountValue =>
      double.tryParse(maxAmount.replaceAll(',', '')) ?? 0.0;

  double get achievedValue =>
      double.tryParse(achieved.replaceAll(',', '')) ?? 0.0;

  double get progressValue => double.tryParse(progressPercentage) ?? 0.0;
}

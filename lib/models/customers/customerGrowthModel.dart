import 'dart:convert';

CustomerGrowthModel customerGrowthModelFromJson(String str) =>
    CustomerGrowthModel.fromJson(json.decode(str));

String customerGrowthModelToJson(CustomerGrowthModel data) =>
    json.encode(data.toJson());

class CustomerGrowthModel {
  final bool status;
  final String message;
  final List<CustomerGrowthItem> data;

  CustomerGrowthModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CustomerGrowthModel.fromJson(Map<String, dynamic> json) {
    return CustomerGrowthModel(
      status: json["status"] == true,
      message: json["message"]?.toString() ?? "",
      data: json["data"] != null && json["data"] is List
          ? List<CustomerGrowthItem>.from(
              (json["data"] as List).map((x) => CustomerGrowthItem.fromJson(
                    x is Map<String, dynamic>
                        ? x
                        : Map<String, dynamic>.from(x as Map),
                  )))
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class CustomerGrowthItem {
  final String date;
  final String month;
  final int totalCustomers;

  CustomerGrowthItem({
    required this.date,
    required this.month,
    required this.totalCustomers,
  });

  factory CustomerGrowthItem.fromJson(Map<String, dynamic> json) {
    return CustomerGrowthItem(
      date: json["date"]?.toString() ?? "",
      month: json["month"]?.toString() ?? "",
      totalCustomers: int.tryParse(json["total_customers"]?.toString() ?? "") ??
          (json["total_customers"] is num
              ? (json["total_customers"] as num).toInt()
              : 0),
    );
  }

  Map<String, dynamic> toJson() => {
        "date": date,
        "month": month,
        "total_customers": totalCustomers,
      };
}

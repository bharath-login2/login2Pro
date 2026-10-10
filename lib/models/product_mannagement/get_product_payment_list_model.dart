import 'dart:convert';

GetProductPaymentListModel getProductPaymentListModelFromJson(String str) =>
    GetProductPaymentListModel.fromJson(json.decode(str));

String getProductPaymentListModelToJson(GetProductPaymentListModel data) =>
    json.encode(data.toJson());

class GetProductPaymentListModel {
  final bool status;
  final String message;
  final PaymentListData? data;

  GetProductPaymentListModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory GetProductPaymentListModel.fromJson(Map<String, dynamic> json) {
    bool parsedStatus = false;
    if (json["status"] is bool) {
      parsedStatus = json["status"];
    } else if (json["status"] != null) {
      parsedStatus = json["status"].toString().toLowerCase() == "true" ||
          json["status"].toString() == "1" ||
          json["status"].toString().toLowerCase() == "success";
    }

    return GetProductPaymentListModel(
      status: parsedStatus,
      message: json["message"]?.toString() ?? "",
      data: json["data"] != null && json["data"] is Map<String, dynamic>
          ? PaymentListData.fromJson(json["data"])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class PaymentListData {
  final AmountSummary amountSummary;
  final List<AmountTransaction> amountTransactions;

  PaymentListData({
    required this.amountSummary,
    required this.amountTransactions,
  });

  factory PaymentListData.fromJson(Map<String, dynamic> json) {
    return PaymentListData(
      amountSummary: json["amount_summary"] != null &&
              json["amount_summary"] is Map<String, dynamic>
          ? AmountSummary.fromJson(json["amount_summary"])
          : AmountSummary.empty(),
      amountTransactions: json["amount_transactions"] != null &&
              json["amount_transactions"] is List
          ? List<AmountTransaction>.from((json["amount_transactions"] as List)
              .map((x) => AmountTransaction.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        "amount_summary": amountSummary.toJson(),
        "amount_transactions":
            List<dynamic>.from(amountTransactions.map((x) => x.toJson())),
      };
}

class AmountSummary {
  final String productName;
  final String productType;
  final double purchaseCost;
  final double salesIncome;
  final double rentalIncome;
  final double serviceCost;
  final double totalExpense;
  final double totalIncome;
  final double netAmount;

  AmountSummary({
    required this.productName,
    required this.productType,
    required this.purchaseCost,
    required this.salesIncome,
    required this.rentalIncome,
    required this.serviceCost,
    required this.totalExpense,
    required this.totalIncome,
    required this.netAmount,
  });

  factory AmountSummary.empty() => AmountSummary(
        productName: "",
        productType: "",
        purchaseCost: 0.0,
        salesIncome: 0.0,
        rentalIncome: 0.0,
        serviceCost: 0.0,
        totalExpense: 0.0,
        totalIncome: 0.0,
        netAmount: 0.0,
      );

  factory AmountSummary.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    return AmountSummary(
      productName: json["product_name"]?.toString() ?? "",
      productType: json["product_type"]?.toString() ?? "",
      purchaseCost: parseDouble(json["purchase_cost"]),
      salesIncome: parseDouble(json["sales_income"]),
      rentalIncome: parseDouble(json["rental_income"]),
      serviceCost: parseDouble(json["service_cost"]),
      totalExpense: parseDouble(json["total_expense"]),
      totalIncome: parseDouble(json["total_income"]),
      netAmount: parseDouble(json["net_amount"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "product_name": productName,
        "product_type": productType,
        "purchase_cost": purchaseCost,
        "sales_income": salesIncome,
        "rental_income": rentalIncome,
        "service_cost": serviceCost,
        "total_expense": totalExpense,
        "total_income": totalIncome,
        "net_amount": netAmount,
      };
}

class AmountTransaction {
  final String rawDate;
  final String date;
  final String type;
  final String description;
  final double amount;
  final String classification;

  AmountTransaction({
    required this.rawDate,
    required this.date,
    required this.type,
    required this.description,
    required this.amount,
    required this.classification,
  });

  factory AmountTransaction.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    return AmountTransaction(
      rawDate: json["raw_date"]?.toString() ?? "",
      date: json["date"]?.toString() ?? "",
      type: json["type"]?.toString() ?? "",
      description: json["description"]?.toString() ?? "",
      amount: parseDouble(json["amount"]),
      classification: json["classification"]?.toString() ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "raw_date": rawDate,
        "date": date,
        "type": type,
        "description": description,
        "amount": amount,
        "classification": classification,
      };
}

import 'dart:convert';

ProdectsByIdModel prodectsByIdModelFromJson(String str) =>
    ProdectsByIdModel.fromJson(json.decode(str));
String prodectsByIdModelToJson(ProdectsByIdModel data) =>
    json.encode(data.toJson());

class ProdectsByIdModel {
  Data data;
  bool status;
  String message;

  ProdectsByIdModel({
    required this.data,
    required this.status,
    required this.message,
  });

  factory ProdectsByIdModel.fromJson(Map<String, dynamic> json) =>
      ProdectsByIdModel(
        data: Data.fromJson(json["data"]),
        status: json["status"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "data": data.toJson(),
        "status": status,
        "message": message,
      };
}

class Data {
  String id;
  String productName;
  String contentId;
  String categoryName;
  String categoryId;
  String subCategoryId;
  String subCategory;
  String productCode;
  String productUCode;
  String productMrp;
  String sellingPrice;
  String purchasePrice;
  String taxPercent;
  String totalAmount;
  String noOfDays;
  String remindBefore;
  String description;
  String productImage;
  String productType;
  String brand;
  String discountPercent;
  String discountAmount;
  String checkStock;
  String openingStock;
  String currentStock;
  String lowStockLimit;
  String stockStatus;
  String isFeatureProduct;
  String isGst;
  String unitId;
  String unitName;
  String publishStatus;
  String visibility;
  String rentalPrice;
  String warranty;
  String expiryDate;
  String warrantyNo;
  String purchaseAmount;
  String barCode;
  List<String> pipelineName;
  String serviceCycle;
  String freeCount;
  String paidCount;
  String serviceNoDays;
  String serviceWeeks;
  String serviceMonthDays;
  String serviceYearDays;
  String serviceYearMonth;

  List<String> complaintType;

  Data({
    required this.id,
    required this.productName,
    required this.contentId,
    required this.categoryName,
    required this.categoryId,
    required this.subCategoryId,
    required this.subCategory,
    required this.productCode,
    required this.productUCode,
    required this.productMrp,
    required this.sellingPrice,
    required this.purchasePrice,
    required this.taxPercent,
    required this.totalAmount,
    required this.noOfDays,
    required this.remindBefore,
    required this.description,
    required this.productImage,
    required this.productType,
    required this.brand,
    required this.discountPercent,
    required this.discountAmount,
    required this.checkStock,
    required this.openingStock,
    required this.currentStock,
    required this.lowStockLimit,
    required this.stockStatus,
    required this.isFeatureProduct,
    required this.isGst,
    required this.unitId,
    required this.unitName,
    required this.publishStatus,
    required this.visibility,
    required this.rentalPrice,
    required this.warranty,
    required this.expiryDate,
    required this.warrantyNo,
    required this.purchaseAmount,
    required this.barCode,
    required this.pipelineName,
    required this.serviceCycle,
    required this.freeCount,
    required this.paidCount,
    required this.serviceNoDays,
    required this.serviceWeeks,
    required this.serviceMonthDays,
    required this.serviceYearDays,
    required this.serviceYearMonth,
    required this.complaintType,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"]?.toString() ?? "",
        productName: json["product_name"]?.toString() ?? "",
        contentId: json["content_id"]?.toString() ?? "",
        categoryName: json["category_name"]?.toString() ?? "",
        categoryId: json["category_id"]?.toString() ?? "",
        subCategoryId: json["sub_category_id"]?.toString() ?? "",
        subCategory: json["sub_category"]?.toString() ?? "",
        productCode: json["product_code"]?.toString() ?? "",
        productUCode: json["product_u_code"]?.toString() ?? "",
        productMrp: json["product_mrp"]?.toString() ?? "",
        sellingPrice: json["selling_price"]?.toString() ?? "",
        purchasePrice: json["purchase_price"]?.toString() ?? "",
        taxPercent: json["tax_percent"]?.toString() ?? "",
        totalAmount: json["total_amount"]?.toString() ?? "",
        noOfDays: json["no_of_days"]?.toString() ?? "",
        remindBefore: json["remind_before"]?.toString() ?? "",
        description: json["description"]?.toString() ?? "",
        productImage: json["product_image"]?.toString() ?? "",
        productType: json["product_type"]?.toString() ?? "",
        brand: json["brand"]?.toString() ?? "",
        discountPercent: json["discount_percent"]?.toString() ?? "",
        discountAmount: json["discount_amount"]?.toString() ?? "",
        checkStock: json["check_stock"]?.toString() ?? "",
        openingStock: json["opening_stock"]?.toString() ?? "",
        currentStock: json["current_stock"]?.toString() ?? "",
        lowStockLimit: json["low_stock_limit"]?.toString() ?? json["low_stock"]?.toString() ?? "",
        stockStatus: json["stock_status"]?.toString() ?? "",
        isFeatureProduct: json["is_feature_product"]?.toString() ?? "",
        isGst: json["is_gst"]?.toString() ?? "",
        unitId: json["unit_id"]?.toString() ?? "",
        unitName: json["unit_name"]?.toString() ?? "",
        publishStatus: json["publish_status"]?.toString() ?? "",
        visibility: json["visibility"]?.toString() ?? "",
        rentalPrice: json["rental_price"]?.toString() ?? "",
        warranty: json["warranty"]?.toString() ?? "",
        expiryDate: json["expiry_date"]?.toString() ?? "",
        warrantyNo: json["warranty_no"]?.toString() ?? "",
        purchaseAmount: json["purchase_amount"]?.toString() ?? "",
        barCode: json["bar_code"]?.toString() ?? "",

        pipelineName: List<String>.from(
          (json["pipeline_name"] ?? []).map((x) => x.toString()),
        ),

        complaintType: List<String>.from(
          (json["complaint_type"] ?? []).map((x) => x.toString()),
        ),

        serviceCycle: json["service_cycle"]?.toString() ?? "",
        freeCount: json["free_count"]?.toString() ?? "",
        paidCount: json["paid_count"]?.toString() ?? "",
        serviceNoDays: json["service_no_days"]?.toString() ?? "",
        serviceWeeks: json["service_weeks"]?.toString() ?? "",
        serviceMonthDays: json["service_month_days"]?.toString() ?? "",
        serviceYearDays: json["service_year_days"]?.toString() ?? "",
        serviceYearMonth: json["service_year_month"]?.toString() ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "product_name": productName,
        "content_id": contentId,
        "category_name": categoryName,
        "category_id": categoryId,
        "sub_category_id": subCategoryId,
        "sub_category": subCategory,
        "product_code": productCode,
        "product_u_code": productUCode,
        "product_mrp": productMrp,
        "selling_price": sellingPrice,
        "purchase_price": purchasePrice,
        "tax_percent": taxPercent,
        "total_amount": totalAmount,
        "no_of_days": noOfDays,
        "remind_before": remindBefore,
        "description": description,
        "product_image": productImage,
        "product_type": productType,
        "brand": brand,
        "discount_percent": discountPercent,
        "discount_amount": discountAmount,
        "check_stock": checkStock,
        "opening_stock": openingStock,
        "current_stock": currentStock,
        "low_stock_limit": lowStockLimit,
        "stock_status": stockStatus,
        "is_feature_product": isFeatureProduct,
        "is_gst": isGst,
        "unit_id": unitId,
        "unit_name": unitName,
        "publish_status": publishStatus,
        "visibility": visibility,
        "rental_price": rentalPrice,
        "warranty": warranty,
        "expiry_date": expiryDate,
        "warranty_no": warrantyNo,
        "purchase_amount": purchaseAmount,
        "bar_code": barCode,
        "pipeline_name": pipelineName,
        "complaint_type": complaintType,
        "service_cycle": serviceCycle,
        "free_count": freeCount,
        "paid_count": paidCount,
        "service_no_days": serviceNoDays,
        "service_weeks": serviceWeeks,
        "service_month_days": serviceMonthDays,
        "service_year_days": serviceYearDays,
        "service_year_month": serviceYearMonth,
      };
}
class ComplaintType {
  String type;
  String remark;

  ComplaintType({
    required this.type,
    required this.remark,
  });

  factory ComplaintType.fromJson(Map<String, dynamic> json) => ComplaintType(
        type: json["type"] ?? "",
        remark: json["remark"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "remark": remark,
      };
}

class ServiceCollectionModel {
  bool? status;
  String? message;
  ServiceCollectionData? data;

  ServiceCollectionModel({this.status, this.message, this.data});

  ServiceCollectionModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message']?.toString();
    data = json['data'] != null
        ? ServiceCollectionData.fromJson(json['data'])
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

class ServiceCollectionData {
  int? type;
  num? collection;
  int? totalRecords;
  List<ServiceCollectionRecord>? records;

  ServiceCollectionData({
    this.type,
    this.collection,
    this.totalRecords,
    this.records,
  });

  ServiceCollectionData.fromJson(Map<String, dynamic> json) {
    type = _parseInt(json['type']);
    collection = _parseNum(json['collection']);
    totalRecords = _parseInt(json['total_records']);
    if (json['records'] != null) {
      records = <ServiceCollectionRecord>[];
      json['records'].forEach((v) {
        records!.add(ServiceCollectionRecord.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['collection'] = collection;
    data['total_records'] = totalRecords;
    if (records != null) {
      data['records'] = records!.map((v) => v.toJson()).toList();
    }
    return data;
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
}

class ServiceCollectionRecord {
  String? invoiceId;
  String? invoiceNumber;
  String? invoiceDate;
  String? clientId;
  String? customerName;
  String? customerPhone;
  num? totalAmount;
  num? paidAmount;
  num? dueAmount;
  String? paymentStatus;
  String? createdByName;
  String? createdAt;

  ServiceCollectionRecord({
    this.invoiceId,
    this.invoiceNumber,
    this.invoiceDate,
    this.clientId,
    this.customerName,
    this.customerPhone,
    this.totalAmount,
    this.paidAmount,
    this.dueAmount,
    this.paymentStatus,
    this.createdByName,
    this.createdAt,
  });

  ServiceCollectionRecord.fromJson(Map<String, dynamic> json) {
    invoiceId = json['invoice_id']?.toString();
    invoiceNumber = json['invoice_number']?.toString();
    invoiceDate = json['invoice_date']?.toString();
    clientId = json['client_id']?.toString();
    customerName = json['customer_name']?.toString();
    customerPhone = json['customer_phone']?.toString();
    totalAmount = _parseNum(json['total_amount']);
    paidAmount = _parseNum(json['paid_amount']);
    dueAmount = _parseNum(json['due_amount']);
    paymentStatus = json['payment_status']?.toString();
    createdByName = json['created_by_name']?.toString();
    createdAt = json['created_at']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['invoice_id'] = invoiceId;
    data['invoice_number'] = invoiceNumber;
    data['invoice_date'] = invoiceDate;
    data['client_id'] = clientId;
    data['customer_name'] = customerName;
    data['customer_phone'] = customerPhone;
    data['total_amount'] = totalAmount;
    data['paid_amount'] = paidAmount;
    data['due_amount'] = dueAmount;
    data['payment_status'] = paymentStatus;
    data['created_by_name'] = createdByName;
    data['created_at'] = createdAt;
    return data;
  }

  static num? _parseNum(dynamic val) {
    if (val == null) return null;
    if (val is num) return val;
    if (val is String) return num.tryParse(val);
    return null;
  }
}

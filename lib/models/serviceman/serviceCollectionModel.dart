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
    collection = _parseNum(json['collection']) ??
        _parseNum(json['due_collection']) ??
        _parseNum(json['total_due']) ??
        _parseNum(json['balance']);
    totalRecords = _parseInt(json['total_records']) ??
        _parseInt(json['totalRecords']);
    if (json['records'] != null) {
      records = <ServiceCollectionRecord>[];
      json['records'].forEach((v) {
        records!.add(ServiceCollectionRecord.fromJson(v));
      });
    }
    totalRecords ??= records?.length;
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
  String? recieptNumber;
  String? amount;
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
    this.recieptNumber,
    this.amount,
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
    invoiceId = json['invoice_id']?.toString() ?? json['invoiceId']?.toString();
    invoiceNumber = json['invoice_number']?.toString() ?? json['invoiceNumber']?.toString();
    recieptNumber = json['receipt_number']?.toString() ??
        json['reciept_number']?.toString() ??
        json['receipt_no']?.toString() ??
        json['receiptNumber']?.toString();
    amount = json['amount']?.toString();
    invoiceDate = json['invoice_date']?.toString() ?? json['invoiceDate']?.toString();
    clientId = json['client_id']?.toString() ?? json['clientId']?.toString();
    customerName = json['customer_name']?.toString() ?? json['customerName']?.toString();
    customerPhone = json['customer_phone']?.toString() ?? json['customerPhone']?.toString();
    totalAmount = _parseNum(json['total_amount']) ??
        _parseNum(json['totalAmount']) ??
        _parseNum(json['grand_total']);
    paidAmount = _parseNum(json['paid_amount']) ??
        _parseNum(json['paidAmount']) ??
        _parseNum(json['total_paid_amount']) ??
        _parseNum(json['amount_paid']) ??
        _parseNum(json['amount']);
    dueAmount = _parseNum(json['due_amount']) ??
        _parseNum(json['dueAmount']) ??
        _parseNum(json['balance_amount']) ??
        _parseNum(json['balance']);
    if (dueAmount == null && totalAmount != null && paidAmount != null) {
      dueAmount = (totalAmount! - paidAmount!).clamp(0, double.infinity);
    }
    if (totalAmount == null && paidAmount != null && dueAmount != null) {
      totalAmount = paidAmount! + dueAmount!;
    }
    paymentStatus = json['payment_status']?.toString() ?? json['paymentStatus']?.toString();
    createdByName = json['created_by_name']?.toString() ?? json['createdByName']?.toString();
    createdAt = json['created_at']?.toString() ?? json['createdAt']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['invoice_id'] = invoiceId;
    data['invoice_number'] = invoiceNumber;
    data['receipt_number'] = recieptNumber;
    data['recieptNumber'] = recieptNumber;
    data['amount'] = amount;
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

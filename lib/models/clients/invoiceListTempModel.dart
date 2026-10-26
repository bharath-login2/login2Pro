// // To parse this JSON data, do
// //
// //     final invoiceListModel = invoiceListModelFromJson(jsonString);

// import 'dart:convert';

// InvoiceListModelTemp invoiceListModelFromJson(String str) =>
//     InvoiceListModelTemp.fromJson(json.decode(str));

// class InvoiceListModelTemp {
//   Data data;
//   bool status;
//   String message;

//   InvoiceListModelTemp({
//     required this.data,
//     required this.status,
//     required this.message,
//   });

//   factory InvoiceListModelTemp.fromJson(Map<String, dynamic> json) =>
//       InvoiceListModelTemp(
//         data: Data.fromJson(json["data"]),
//         status: json["status"],
//         message: json["message"],
//       );
// }

// class Data {
//   List<ListElement> lists;
//   String totalInvoiceAmount;
//   String totalInvoicePaid;
//   String balanceAmount;

//   Data({
//     required this.lists,
//     required this.totalInvoiceAmount,
//     required this.totalInvoicePaid,
//     required this.balanceAmount,
//   });

//   factory Data.fromJson(Map<String, dynamic> json) => Data(
//         lists: List<ListElement>.from(
//             json["lists"].map((x) => ListElement.fromJson(x))),
//         totalInvoiceAmount: json["total_invoice_amount"],
//         totalInvoicePaid: json["total_invoice_paid"],
//         balanceAmount: json["balance_amount"],
//       );
// }

// class ListElement {
//   String id;
//   String invType;
//   String renewalId;
//   String renewalType;
//   String createdBy;
//   String installmentId;
//   String invoiceNumber;
//   String invoiceDate;
//   String invoiceAt;
//   String customerName;
//   String paymentMode;
//   String totalAmount;
//   String totalPaid;
//   String balance;
//   String status;
//   bool isPaid;
//   String clientId;
//     String isApproved;
//       String isRejected;
//   List<ProductTemp> products;
//   String invoiceCreated;

//   ListElement({
//     required this.id,
//     required this.invType,
//     required this.invoiceNumber,
//     required this.invoiceDate,
//     required this.invoiceAt,
//     required this.customerName,
//     required this.paymentMode,
//     required this.totalAmount,
//     required this.totalPaid,
//     required this.balance,
//     required this.status,
//     required this.isPaid,
//     required this.clientId,
//     required this.renewalId,
//     required this.renewalType,
//     required this.installmentId,
//     required this.createdBy,
//      required this.isApproved,
//       required this.isRejected,
//     required this.products,
//     required this.invoiceCreated,
//   });

//   factory ListElement.fromJson(Map<String, dynamic> json) => ListElement(
//         id: json["id"] ?? "",
//         invType: json["inv_type"] ?? "",
//         invoiceNumber: json["invoice_number"] ?? "",
//         invoiceDate: json["invoice_date"] ?? "",
//         invoiceAt: json["created_at"] ?? "",
//         customerName: json["customer_name"] ?? "",
//         paymentMode: json["payment_mode"] ?? "",
//         totalAmount: json["total_amount"] ?? "",
//         totalPaid: json["total_paid"] ?? "",
//         balance: json["balance"] ?? "",
//         status: json["status"] ?? "",
//         isPaid: json["is_paid"] ?? "",
//         clientId: json["client_id"] ?? "",
//         renewalId: json["renewal_id"] ?? "",
//         renewalType: json["renewal_id"] ?? "",
//         installmentId: json["installment_id"] ?? "",
//         createdBy: json["created_by"] ?? "",
//          isApproved: json["is_approved"] ?? "",
//           isRejected: json["is_rejected"] ?? "",
//         products: List<ProductTemp>.from(
//             json["products"].map((x) => ProductTemp.fromJson(x))),
//         invoiceCreated: json["invoice_created"],
//       );
// }

// class ProductTemp {
//   String productId;
//   String qty;
//   String amount;
//    String taxAmount;
//     String taxPercentage;
//   String productName;
//   final String? discountAmount;
//   final String? shippingAmount;

//   ProductTemp({
//     required this.productId,
//     required this.qty,
//     required this.amount,
//         required this.taxAmount,
//             required this.taxPercentage,
//     required this.productName,
//     required this.discountAmount,
//     required this.shippingAmount,
//   });

//   factory ProductTemp.fromJson(Map<String, dynamic> json) => ProductTemp(
//         productId: json["product_id"],
//         qty: json["qty"],
//         amount: json["amount"],
//         taxAmount: json["tax_amount"],
//         taxPercentage: json["tax_percentage"],
//         productName: json["product_name"],
//         discountAmount: json["discount_amount"]?.toString() ?? "0.00",
//         shippingAmount: json["shipping_amount"]?.toString() ?? "0.00",
//       );

//   Map<String, dynamic> toJson() => {
//         "product_id": productId,
//         "qty": qty,
//         "amount": amount,
//         "tax_amount": taxAmount,
//         "tax_percentage": taxPercentage,
//         "product_name": productName,
//         "discount_amount": discountAmount,
//         "shipping_amount": shippingAmount,
//       };
// }
import 'dart:convert';

InvoiceListModelTemp invoiceListModelFromJson(String str) =>
    InvoiceListModelTemp.fromJson(json.decode(str));

// ---- safe helpers ----------------------------------------------------------
String _s(dynamic v, [String def = ""]) => v == null ? def : v.toString();

bool _b(dynamic v) {
  if (v is bool) return v;
  final s = v?.toString().toLowerCase();
  return s == "1" || s == "true" || s == "y" || s == "yes";
}

Map<String, dynamic> _m(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

List _l(dynamic v) => v is List ? v : const [];

// ---- models ----------------------------------------------------------------
class InvoiceListModelTemp {
  Data data;
  bool status;
  String message;

  InvoiceListModelTemp({
    required this.data,
    required this.status,
    required this.message,
  });

  factory InvoiceListModelTemp.fromJson(Map<String, dynamic> json) =>
      InvoiceListModelTemp(
        data: Data.fromJson(_m(json["data"])),
        status: _b(json["status"]),
        message: _s(json["message"]),
      );
}

class Data {
  List<ListElement> lists;
  String totalInvoiceAmount;
  String totalInvoicePaid;
  String balanceAmount;

  Data({
    required this.lists,
    required this.totalInvoiceAmount,
    required this.totalInvoicePaid,
    required this.balanceAmount,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        lists: _l(json["lists"]).map((x) => ListElement.fromJson(_m(x))).toList(),
        totalInvoiceAmount: _s(json["total_invoice_amount"], "0"),
        totalInvoicePaid: _s(json["total_invoice_paid"], "0"),
        balanceAmount: _s(json["balance_amount"], "0.00"),
      );
}

class ListElement {
  String id;
  String invType;
  String renewalId;
  String renewalType;
  String createdBy;
  String installmentId;
  String invoiceNumber;
  String invoiceDate;
  String invoiceAt;
  String customerName;
  String paymentMode;
  String totalAmount;
  String totalPaid;
  String balance;
  String status;
  bool isPaid;
  String clientId;
  String isApproved;
  String isRejected;
  List<ProductTemp> products;
  String invoiceCreated;

  ListElement({
    required this.id,
    required this.invType,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.invoiceAt,
    required this.customerName,
    required this.paymentMode,
    required this.totalAmount,
    required this.totalPaid,
    required this.balance,
    required this.status,
    required this.isPaid,
    required this.clientId,
    required this.renewalId,
    required this.renewalType,
    required this.installmentId,
    required this.createdBy,
    required this.isApproved,
    required this.isRejected,
    required this.products,
    required this.invoiceCreated,
  });

  factory ListElement.fromJson(Map<String, dynamic> json) => ListElement(
        id: _s(json["id"]),
        invType: _s(json["inv_type"]),
        invoiceNumber: _s(json["invoice_number"]),
        invoiceDate: _s(json["invoice_date"]),
        invoiceAt: _s(json["created_at"]),
        customerName: _s(json["customer_name"]),
        paymentMode: _s(json["payment_mode"]),
        totalAmount: _s(json["total_amount"]),
        totalPaid: _s(json["total_paid"]),
        balance: _s(json["balance"]),
        status: _s(json["status"]),
        isPaid: _b(json["is_paid"]),
        clientId: _s(json["client_id"]),
        renewalId: _s(json["renewal_id"]),
        renewalType: _s(json["renewal_type"]), // was reading renewal_id
        installmentId: _s(json["installment_id"]),
        createdBy: _s(json["created_by"]),
        isApproved: _s(json["is_approved"]),
        isRejected: _s(json["is_rejected"]),
        products:
            _l(json["products"]).map((x) => ProductTemp.fromJson(_m(x))).toList(),
        invoiceCreated: _s(json["invoice_created"], "0"),
      );
}

class ProductTemp {
  String productId;
  String qty;
  String amount;
  String taxAmount;
  String taxPercentage;
  String productName;
  final String? discountAmount;
  final String? shippingAmount;

  ProductTemp({
    required this.productId,
    required this.qty,
    required this.amount,
    required this.taxAmount,
    required this.taxPercentage,
    required this.productName,
    required this.discountAmount,
    required this.shippingAmount,
  });

  factory ProductTemp.fromJson(Map<String, dynamic> json) => ProductTemp(
        productId: _s(json["product_id"]),
        qty: _s(json["qty"]),
        amount: _s(json["amount"]),
        taxAmount: _s(json["tax_amount"]),
        taxPercentage: _s(json["tax_percentage"]),
        productName: _s(json["product_name"]),
        discountAmount: _s(json["discount_amount"], "0.00"),
        shippingAmount: _s(json["shipping_amount"], "0.00"),
      );

  Map<String, dynamic> toJson() => {
        "product_id": productId,
        "qty": qty,
        "amount": amount,
        "tax_amount": taxAmount,
        "tax_percentage": taxPercentage,
        "product_name": productName,
        "discount_amount": discountAmount,
        "shipping_amount": shippingAmount,
      };
}
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:login2/core/common.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:login2/models/lead_management/purchaseBillModel.dart';
import 'package:login2/models/lead_management/materialModel.dart';
import 'package:login2/models/lead_management/getSupplierListMode.dart';
import 'package:login2/models/expense/account_head_model.dart';
import 'package:login2/service/service.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:login2/models/lead_management/getPurchaseOrderDetailsModel.dart'
    as order_details_model;
import 'package:flutter/services.dart';
import 'package:login2/models/rental/rentalLocationModel.dart';

class BillItem {
  MaterialData material;
  double quantity;
  double unitPrice;
  double purchasePrice;
  double gstPercentage;
  double cgst;
  double sgst;
  double igst;
  late TextEditingController unitPriceController;
  late TextEditingController gstController;

  BillItem({
    required this.material,
    this.quantity = 1.0,
    this.unitPrice = 0.0,
      this.purchasePrice = 0.0,
    this.gstPercentage = 0.0,
    this.cgst = 0.0,
    this.sgst = 0.0,
    this.igst = 0.0,
  }) {
    unitPriceController = TextEditingController(text: unitPrice.toString());
    gstController = TextEditingController(text: gstPercentage.toString());
  }

  double get subTotal => quantity * unitPrice;
  double get gstAmount => subTotal * (gstPercentage / 100);
  double get total => subTotal + gstAmount;

  void dispose() {
    unitPriceController.dispose();
    gstController.dispose();
  }
}

class PaymentItem {
  DateTime paidDate;
  double paidAmount;

  String debitAccountId;
  String debitAccountName;

  String paymentMode;
  String trRefNo;
  DateTime? trRefDate;
  String remarks;

  PaymentItem({
    required this.paidDate,
    required this.paidAmount,
    required this.debitAccountId,
    required this.debitAccountName,
    required this.paymentMode,
    this.trRefNo = "",
    this.trRefDate,
    this.remarks = "",
  });
}

class PurchaseBillPage extends StatefulWidget {
  final String token;
  final String name;
  final String userId;
  final order_details_model.PurchaseOrderData? createFromOrder;
  final bool showAddDialogOnArrive;
  final String? initialSearchQuery;
  final MaterialData? initialProductToCart;
  
  const PurchaseBillPage({
    super.key,
    required this.token,
    required this.name,
    required this.userId,
    this.createFromOrder,
    this.showAddDialogOnArrive = false,
    this.initialSearchQuery,
    this.initialProductToCart,
  });

  @override
  State<PurchaseBillPage> createState() => _PurchaseBillPageState();
}

class _PurchaseBillPageState extends State<PurchaseBillPage> {
  bool isLoading = true;
  List<PurchaseBillData> bills = [];
  List<PurchaseBillData> filteredBills = [];
  
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  String? locationId;
String? locationName;
List<RetailLocation> _locations = [];
  DateTime? fromDate;
  DateTime? toDate;
  Supplier? selectedSupplier;
  List<Supplier> suppliers = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialSearchQuery != null) {
      searchQuery = widget.initialSearchQuery!;
      _searchController.text = searchQuery;
    }
    _fetchBills();
    _fetchSuppliers();
    _fetchLocations();
    if (widget.createFromOrder != null || widget.showAddDialogOnArrive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAddBillDialog(
          createFromOrder: widget.createFromOrder,
          initialProductToCart: widget.initialProductToCart,
        );
      });
    }
  }
Future<void> _fetchLocations() async {
  try {
    final response = await HttpService.getRentalLocation();

    if (response != null && response.status) {
      setState(() {
        _locations = response.data;
      });

      print("========= LOCATIONS =========");
      print("Count : ${_locations.length}");

      for (var loc in _locations) {
        print("${loc.id} - ${loc.locationName}");
      }
    } else {
      Common.toastMessaage(
        response?.message ?? "No locations found",
        Colors.red,
      );
    }
  } catch (e) {
    debugPrint("Location Error : $e");
  }
}
  
  Future<void> _fetchSuppliers() async {
    try {
      final response = await HttpService.getSupplierList({});
      if (response != null && response.data != null) {
        setState(() {
          suppliers = response.data;
        });
      }
    } catch (e) {
      print("Error fetching suppliers: $e");
    }
  }

  Color _getPaymentStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'paid':
    case 'complete':
    case 'completed':
      return Colors.green;
    case 'partial':
      return Colors.orange;
    case 'pending':
      return Colors.red;
    case 'cancelled':
    case 'canceled':
      return Colors.grey;
    default:
      return Colors.grey;
  }
}
  Future<void> _fetchBills() async {
    setState(() => isLoading = true);
    try {
      Map<String, dynamic> data = {};
      if (fromDate != null) {
        data['from_date'] = DateFormat('yyyy-MM-dd').format(fromDate!);
      }
      if (toDate != null) {
        data['to_date'] = DateFormat('yyyy-MM-dd').format(toDate!);
      }
      if (selectedSupplier != null) {
        data['supplier_id'] = selectedSupplier!.supplierId;
      }

      final response = await HttpService.purchaseBillList(data);
      if (response != null && response.data != null) {
        setState(() {
          bills = response.data!;
          _applySearch();
          isLoading = false;
        });
      } else {
        setState(() {
          bills = [];
          filteredBills = [];
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching purchase bills: $e");
      setState(() => isLoading = false);
    }
  }

  void _applySearch() {
    setState(() {
      filteredBills = bills.where((bill) {
        final query = searchQuery.toLowerCase();
        return (bill.billNo?.toLowerCase().contains(query) ?? false) ||
            (bill.supplierName?.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2a86c9),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Purchase Bills',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: Colors.white),
            onPressed: _showFilterSheet,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredBills.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _fetchBills,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          itemCount: filteredBills.length,
                          itemBuilder: (context, index) {
                            return _buildBillCard(filteredBills[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddBillDialog(),
        backgroundColor: const Color(0xFF2a86c9),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('ADD BILL',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Filter Purchase Bills",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                                context: context,
                                initialDate: fromDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100));
                            if (picked != null)
                              setSheetState(() => fromDate = picked);
                          },
                          child: _buildFilterBox(
                              "From Date",
                              fromDate != null
                                  ? DateFormat('dd-MM-yyyy').format(fromDate!)
                                  : "Select Date"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                                context: context,
                                initialDate: toDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100));
                            if (picked != null)
                              setSheetState(() => toDate = picked);
                          },
                          child: _buildFilterBox(
                              "To Date",
                              toDate != null
                                  ? DateFormat('dd-MM-yyyy').format(toDate!)
                                  : "Select Date"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text("Supplier",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownSearch<Supplier>(
                      items: (filter, loadProps) {
                        if (filter.isEmpty) return suppliers;
                        return suppliers
                            .where((s) => s.supplierName
                                .toLowerCase()
                                .contains(filter.toLowerCase()))
                            .toList();
                      },
                      itemAsString: (c) => c.supplierName,
                      compareFn: (item, selectedItem) =>
                          item.supplierId == selectedItem?.supplierId,
                      selectedItem: selectedSupplier,
                      onChanged: (val) =>
                          setSheetState(() => selectedSupplier = val),
                      popupProps: const PopupProps.menu(
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            hintText: "Search Supplier...",
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      decoratorProps: const DropDownDecoratorProps(
                        decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          border: InputBorder.none,
                          hintText: "Select Supplier",
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              fromDate = null;
                              toDate = null;
                              selectedSupplier = null;
                            });
                            Navigator.pop(context);
                            _fetchBills();
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                          ),
                          child: const Text("Reset"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _fetchBills();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2a86c9),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                          ),
                          child: const Text("Apply Filter",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterBox(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today,
                  size: 14, color: Color(0xFF2a86c9)),
              const SizedBox(width: 8),
              Text(value,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 25),
      decoration: const BoxDecoration(
        color: Color(0xFF2a86c9),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(15),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            searchQuery = value;
            _applySearch();
          },
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search purchase bills...',
            hintStyle:
                TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
            prefixIcon: const Icon(Icons.search, color: Colors.white),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildBillCard(PurchaseBillData bill) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: InkWell(
            onTap: () => _showViewDetails(bill),
            child: Row(
              children: [
                Container(
                  width: 6,
                  color: const Color(0xFF2a86c9),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bill No: ${bill.billNo ?? 'N/A'}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Color(0xFF2a86c9),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  bill.billDate ?? 'N/A',
                                  style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined,
                                      color: Colors.blue, size: 20),
                                  onPressed: () =>
                                      _showAddBillDialog(editBill: bill),
                                ),
                                // IconButton(
                                //   icon: const Icon(Icons.delete_outline,
                                //       color: Colors.red, size: 20),
                                //   onPressed: () => _confirmDelete(bill),
                                // ),
                              ],
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.person,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                bill.supplierName ?? 'Unknown Supplier',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getPaymentStatusColor(
                                        bill.paymentStatus ?? 'Partial')
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                bill.paymentStatus ?? 'Partial',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: _getPaymentStatusColor(
                                      bill.paymentStatus ?? 'Partial'),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildBillDetail(
                                'Grand Total', '₹${bill.itemTotal ?? '0'}'),
                            _buildBillDetail(
                                'Paid Amount', '₹${bill.paidAmount ?? '0'}'),
                            _buildBillDetail('Balance Amount',
                                '₹${bill.balanceAmount ?? '0'}',
                                isHighlight: true),
                          ],
                        ),
                        if ((double.tryParse(bill.balanceAmount ?? '0') ?? 0) >
                            0) ...[
                          const Divider(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: () => _openPaymentDialog(bill),
                              icon: const Icon(Icons.payment, size: 16),
                              label: const Text("Add Payment"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openPaymentDialog(PurchaseBillData bill) async {
    Common.showProgressDialog(context, "Loading accounts...");
    final accRes = await HttpService.getAccountHead();
    Navigator.pop(context);
    if (accRes != null && accRes.data != null) {
     _showAddPaymentPopup(
  context,
  accRes.data!.lists,
  (PaymentItem payment) async {
    Map<String, dynamic> body = {
      "bill_id": bill.billId,
      "paid_date":
          DateFormat('yyyy-MM-dd').format(payment.paidDate),
      "paid_amount": payment.paidAmount.toString(),

      // Send account ID
      "debit_account": payment.debitAccountId,

      "payment_mode": payment.paymentMode,
      "tr_ref_no": payment.trRefNo,
      "payment_remarks": payment.remarks,
    };

    if (payment.trRefDate != null) {
      body["tr_ref_date"] =
          DateFormat('yyyy-MM-dd').format(payment.trRefDate!);
    }

    Common.showProgressDialog(context, "Saving payment...");

    final res = await HttpService.postPurchaseBillPayment(body);

    Navigator.pop(context);

    if (res != null &&
        (res['status'] == true ||
            res['status'] == 'success')) {
      Common.toastMessaage(
        res['message'] ?? "Payment added successfully",
        Colors.green,
      );

      _fetchBills();
    } else {
      Common.toastMessaage(
        res?['message'] ?? "Failed to add payment",
        Colors.red,
      );
    }
  },
  totalAmount: bill.itemTotal ?? '0',
  paidAmount: bill.paidAmount ?? '0',
  balanceAmount: bill.balanceAmount ?? '0',
);
    } else {
      Common.toastMessaage("Failed to load accounts", Colors.red);
    }
  }

  void _confirmDelete(PurchaseBillData bill) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Bill"),
        content: Text("Are you sure you want to delete bill ${bill.billNo}?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => isLoading = true);
              final res = await HttpService.deletePurchaseBill(bill.id!);
              if (res != null) {
                Common.toastMessaage("Bill deleted successfully", Colors.green);
                _fetchBills();
              } else {
                setState(() => isLoading = false);
                Common.toastMessaage("Failed to delete bill", Colors.red);
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showViewDetails(PurchaseBillData bill) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final response = await HttpService.viewPurcahseBillDetails(
      billId: bill.id ?? bill.id ?? '',
    );

    Navigator.pop(context);

    if (response == null || response.data == null) {
      Common.toastMessaage("Failed to load bill details", Colors.red);
      return;
    }

    final billData = response.data!;
    final items = billData.items ?? [];
    final payments = billData.paymentList ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2a86c9),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(25)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Bill Details",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Bill Info Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            children: [
                              _buildInfoRow(
                                  "Bill No:", billData.billNo ?? 'N/A'),
                              // const SizedBox(height: 12),
                              // _buildInfoRow(
                              //     "Bill Date:", billData.billDate ?? 'N/A'),
                              // const SizedBox(height: 12),
                              // _buildInfoRow(
                              //     "Invoice No:", billData.invoiceNo ?? 'N/A'),
                              const SizedBox(height: 12),
                              _buildInfoRow("Bill Date:",
                                  billData.billDate ?? 'N/A'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.business,
                                      size: 18, color: Color(0xFF2a86c9)),
                                  SizedBox(width: 8),
                                  Text(
                                    "Supplier Information",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 20),
                              _buildInfoRow("Supplier Name:",
                                  billData.supplierName ?? 'N/A'),
                              // const SizedBox(height: 12),
                              // _buildInfoRow(
                              //     "Supplier ID:", billData.supplierId ?? 'N/A'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Items Table
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.shopping_cart,
                                      size: 18, color: Color(0xFF2a86c9)),
                                  SizedBox(width: 8),
                                  Text(
                                    "Items Details",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    columnSpacing: 16,
                                    headingRowColor: WidgetStateProperty.all(
                                      const Color(0xFF2a86c9).withOpacity(0.1),
                                    ),
                                    headingTextStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    columns: const [
                                      DataColumn(label: Text("#")),
                                      DataColumn(label: Text("Product")),
                                      DataColumn(label: Text("Qty")),
                                      DataColumn(label: Text("Unit Price")),
                                      DataColumn(label: Text("GST %")),
                                      DataColumn(label: Text("GST Amt")),
                                      DataColumn(label: Text("Total")),
                                    ],
                                    rows: List.generate(items.length, (index) {
                                      final item = items[index];
                                      return DataRow(cells: [
                                        DataCell(Text("${index + 1}")),
                                        DataCell(
                                          SizedBox(
                                            width: 120,
                                            child: Text(
                                              item.productName ?? 'N/A',
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                          ),
                                        ),
                                        DataCell(Text(item.quantity ?? '0',
                                            style:
                                                const TextStyle(fontSize: 12))),
                                        DataCell(Text(
                                            "₹${item.unitPrice ?? '0'}",
                                            style:
                                                const TextStyle(fontSize: 12))),
                                        DataCell(Text("${item.gst ?? '0'}%",
                                            style:
                                                const TextStyle(fontSize: 12))),
                                        DataCell(Text("₹${item.gstAmt ?? '0'}",
                                            style:
                                                const TextStyle(fontSize: 12))),
                                        DataCell(
                                          Text(
                                            "₹${item.itemTotal ?? '0'}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ]);
                                    }),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // final payments = billData.paymentList ?? [];

Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.grey.shade50,
    borderRadius: BorderRadius.circular(15),
    border: Border.all(color: Colors.grey.shade200),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Row(
        children: [
          Icon(
            Icons.payment,
            size: 18,
            color: Color(0xFF2a86c9),
          ),
          SizedBox(width: 8),
          Text(
            "Payment Information",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
      const Divider(height: 20),

      if (payments.isNotEmpty)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 20,
            headingRowColor: WidgetStateProperty.all(
              const Color(0xFF2a86c9).withOpacity(0.1),
            ),
            columns: const [
              DataColumn(label: Text("#")),
              DataColumn(label: Text("Paid Date")),
              DataColumn(label: Text("Amount")),
              DataColumn(label: Text("Mode")),
              DataColumn(label: Text("Reference Date")),
              DataColumn(label: Text("Reference No")),
              DataColumn(label: Text("Remarks")),
              DataColumn(label: Text("Account")),
            ],
            rows: List.generate(
              payments.length,
              (index) {
                final payment = payments[index];

                return DataRow(
                  cells: [
                    DataCell(Text("${index + 1}")),

                    DataCell(
                      Text(payment.paidDate ?? "-"),
                    ),

                    DataCell(
                      Text(
                        "₹${payment.advanceAmountPaid ?? '0'}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    DataCell(
                      Text(payment.paymentMode ?? "-"),
                    ),

                    DataCell(
                      Text(
                        (payment.trReferenceDate?.isNotEmpty ?? false)
                            ? payment.trReferenceDate!
                            : "-",
                      ),
                    ),

                    DataCell(
                      Text(
                        (payment.trReferenceNo?.isNotEmpty ?? false)
                            ? payment.trReferenceNo!
                            : "-",
                      ),
                    ),

                    DataCell(
                      SizedBox(
                        width: 150,
                        child: Text(
                          (payment.transactionRemarks?.isNotEmpty ?? false)
                              ? payment.transactionRemarks!
                              : "-",
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),

                    DataCell(
                      SizedBox(
                        width: 120,
                        child: Text(
                          (payment.accountName?.isNotEmpty ?? false)
                              ? payment.accountName!
                              : "-",
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        )
      else
        const Center(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              "No payment history available",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
    ],
  ),
),
                        const SizedBox(height: 20),
                        
                        // Bill Document Card
                        if (billData.file != null && billData.file!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.insert_drive_file,
                                        color: Color(0xFF2a86c9), size: 18),
                                    SizedBox(width: 8),
                                    Text("Payment Copy",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                  ],
                                ),
                                InkWell(
                                  onTap: () {
                                    _launchExistingBill(billData.file!);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Colors.blue.shade200),
                                    ),
                                    child: const Text("View File",
                                        style: TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                            const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF2a86c9).withOpacity(0.15),
                                const Color(0xFF2a86c9).withOpacity(0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                                color:
                                    const Color(0xFF2a86c9).withOpacity(0.3)),
                          ),
                          
                          child: Column(
                            children: [
                                const Divider(thickness: 2),
                              _buildSummaryRow(
                                "Payment Status:",
                                billData.paymentStatus ?? 'Partial',
                                isBold: true,
                                isLarge: true,
                              ),
                               if (double.tryParse(billData.discount ?? '0') !=
                                      null &&
                                  double.parse(billData.discount ?? '0') >
                                      0) ...[
                                const Divider(),
                                _buildSummaryRow("Discount:",
                                    "₹${billData.discount ?? '0'}"),
                              ],
                              if (double.tryParse(billData.tdsAmt ?? '0') !=
                                      null &&
                                  double.parse(billData.tdsAmt ?? '0') > 0) ...[
                                const Divider(),
                                _buildSummaryRow("TDS Amount:",
                                    "₹${billData.tdsAmt ?? '0'}"),
                             ],
                              if (double.tryParse(billData.otherCharges ?? '0') !=
                                      null &&
                                  double.parse(billData.otherCharges ?? '0') > 0) ...[
                                const Divider(),
                                _buildSummaryRow("Other Charges:",
                                    "₹${billData.otherCharges ?? '0'}"),
                             ],
                              const Divider(thickness: 2),
                              // _buildSummaryRow(
                              //   "Other Charges:",
                              //   "₹${billData.otherCharges ?? '0'}",
                              //   isBold: true,
                              //   isLarge: true,
                              // ),
                              // const SizedBox(height: 8),
                              // Container(
                              //   padding: const EdgeInsets.all(12),
                              //   decoration: BoxDecoration(
                              //     color: Colors.green.shade50,
                              //     borderRadius: BorderRadius.circular(10),
                              //     border:
                              //         Border.all(color: Colors.green.shade200),
                              //   ),
                              //   child: Row(
                              //     mainAxisAlignment:
                              //         MainAxisAlignment.spaceBetween,
                              //     children: [
                              //       const Text(
                              //         "Balance Amount:",
                              //         style: TextStyle(
                              //           fontWeight: FontWeight.bold,
                              //           fontSize: 14,
                              //         ),
                              //       ),
                              //       Text(
                              //         "₹${billData.balancePaidAmount ?? '0'}",
                              //         style: TextStyle(
                              //           fontWeight: FontWeight.bold,
                              //           fontSize: 16,
                              //           color: Colors.green.shade700,
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                            
                              _buildSummaryRow(
                                "Grand Total:",
                                "₹${((double.tryParse(billData.subTotal ?? '0') ?? 0) + (double.tryParse(billData.gstAmt ?? '0') ?? 0) + (double.tryParse(billData.tdsAmt ?? '0') ?? 0)).toStringAsFixed(2)}",
                                isBold: true,
                                isLarge: true,
                              ),
                              const Divider(thickness: 2),
                              _buildSummaryRow(
                                "Paid Amount:",
                                "₹${billData.paidAmount ?? '0'}",
                                isBold: true,
                                isLarge: true,
                              ),
                              const Divider(thickness: 2),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                      Border.all(color: Colors.green.shade200),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Balance Amount:",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      "₹${billData.balancePaidAmount ?? '0'}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(thickness: 2),
                              // _buildSummaryRow(
                              //     "Sub Total:", "₹${billData.subTotal ?? '0'}"),
                              // const Divider(),
                              // _buildSummaryRow(
                              //     "GST Amount:", "₹${billData.gstAmt ?? '0'}"),
                             
                            ],
                          ),
                        ),
                      
                        // Created Date
                        if (billData.createddt != null &&
                            billData.createddt!.isNotEmpty)
                          Center(
                            child: Text(
                              "Created on: ${billData.createddt}",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                
                ),
              
              ],
            ),
          );
        },
      ),
    );
  }

// Helper widgets
  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isBold = false, bool isLarge = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isLarge ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isBold ? Colors.black87 : Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isLarge ? 18 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isBold ? const Color(0xFF2a86c9) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Future<void> _launchExistingBill(String filePath) async {
    String fullUrl = filePath;
    if (!filePath.startsWith('http')) {
      String? baseUrl = await Common.getSharedPref("url");
      if (baseUrl != null) {
        if (baseUrl.contains('index.php')) {
          baseUrl = baseUrl.replaceAll('index.php', '');
        }
        if (!baseUrl.endsWith('/')) {
          baseUrl += '/';
        }
        if (filePath.startsWith('/')) {
          filePath = filePath.substring(1);
        }
        fullUrl = "$baseUrl$filePath";
      }
    }

    try {
      final uri = Uri.parse(fullUrl);
      bool launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        Common.toastMessaage("Could not open file", Colors.red);
      }
    } catch (e) {
      Common.toastMessaage("Could not open file", Colors.red);
    }
  }

  void _showAddBillDialog({
    PurchaseBillData? editBill,
    order_details_model.PurchaseOrderData? createFromOrder,
    MaterialData? initialProductToCart,
  }) {
    List<BillItem> cartItems = [];
    List<PaymentItem> paymentItems = [];
    DateTime billDate = DateTime.now();
    DateTime invoiceDate = DateTime.now();
    Supplier? selectedSupplier;
    MaterialData? selectedMaterial;
    PlatformFile? billCopyFile;
    String? existingBillFile;
    final ImagePicker picker = ImagePicker();
    final TextEditingController billIdController = TextEditingController(
        text: editBill?.id ??
            "#${DateFormat('HHmm').format(DateTime.now())}");
    final TextEditingController invoiceNoController = TextEditingController();
    final TextEditingController tdsController = TextEditingController();
    final TextEditingController othersController = TextEditingController();
    final TextEditingController discountController = TextEditingController();
    final TextEditingController paidAmtController = TextEditingController();
    final TextEditingController trRefNoController = TextEditingController();
    final TextEditingController remarkController = TextEditingController();
    final TextEditingController billAddressController = TextEditingController();
    String taxType = 'Intrastate';

    if (createFromOrder != null) {
      if (createFromOrder.orderDetails != null) {
        final details = createFromOrder.orderDetails!;
        remarkController.text = details.remarks ?? "";
        if (suppliers.any((s) => s.supplierId == details.supplierId)) {
          selectedSupplier =
              suppliers.firstWhere((s) => s.supplierId == details.supplierId);
        }
      }
      if (createFromOrder.items != null) {
        cartItems = createFromOrder.items!.map((item) {
          return BillItem(
            material: MaterialData(
              materialId: item.materialId,
              materialName: item.materialName,
              unitName: item.unitName,
            ),
            quantity: double.tryParse(item.quantity ?? "1") ?? 1.0,
            unitPrice: double.tryParse(item.unitPrice ?? "0") ?? 0.0,
            gstPercentage: 0.0,
          );
        }).toList();
      }
    }

    bool deductFromAdvance = false;

    List<MaterialData> dialogMaterials = [];
    List<ListElement> accountHeads = [];
    bool isFetching = false;
    bool isFetchingAccounts = false;
    bool isDetailsFetched = false;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "AddPurchaseBill",
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {

        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            if (createFromOrder != null &&
                selectedSupplier == null &&
                suppliers.isNotEmpty) {
              final details = createFromOrder.orderDetails;
              if (details != null &&
                  suppliers.any((s) => s.supplierId == details.supplierId)) {
                selectedSupplier = suppliers
                    .firstWhere((s) => s.supplierId == details.supplierId);
              }
            }
            if (dialogMaterials.isEmpty && !isFetching) {
              isFetching = true;
              HttpService.getMaterials().then((val) {
                if (val != null && val.data != null && dialogContext.mounted) {
                  setDialogState(() {
                    dialogMaterials = val.data!;
                    isFetching = false;
                    
                    if (createFromOrder != null && cartItems.isNotEmpty) {
                      for (var item in cartItems) {
                        try {
                          final match = dialogMaterials.firstWhere(
                            (m) => m.materialId == item.material.materialId,
                          );
                          item.material = match;
                          double newGst = double.tryParse(match.gstPercentage ?? "0") ?? 0.0;
                          item.gstPercentage = newGst;
                          item.gstController.text = newGst.toString();
                          
                          if (item.unitPrice == 0.0) {
                            double newPrice = double.tryParse(match.purchasePrice?.isNotEmpty == true ? match.purchasePrice! : (match.unitPrice ?? "0")) ?? 0.0;
                            item.unitPrice = newPrice;
                            item.unitPriceController.text = newPrice.toString();
                          }
                        } catch (e) {}
                      }
                    }

                    if (initialProductToCart != null && cartItems.isEmpty) {
                      final match = dialogMaterials.firstWhere(
                        (m) => m.materialId == initialProductToCart.materialId,
                        orElse: () => initialProductToCart,
                      );
                      cartItems.add(BillItem(
                        material: match,
                        quantity: 1.0,
                        unitPrice: double.tryParse(match.purchasePrice?.isNotEmpty == true ? match.purchasePrice! : (match.unitPrice ?? "0")) ?? 0.0,
                        gstPercentage: double.tryParse(match.gstPercentage ?? "0") ?? 0.0,
                      ));
                    }
                  });
                }
              });
            }

            if (accountHeads.isEmpty && !isFetchingAccounts) {
              isFetchingAccounts = true;
              HttpService.getAccountHead().then((val) {
                if (val != null && val.data != null && dialogContext.mounted) {
                  setDialogState(() {
                    accountHeads = val.data!.lists;
                    isFetchingAccounts = false;
                  });
                }
              });
            }

            if (editBill != null && !isDetailsFetched) {
              isDetailsFetched = true;
              HttpService.getPurchaseBillDetailsEdit(editBill.id!).then((val) {
                print("Purchase Bill Details for Edit Response: $val");
                if (val != null && val.data != null && dialogContext.mounted) {
                  setDialogState(() {
                    final d = val.data!;
                    if (d.billDetails != null) {
                      billIdController.text = d.billDetails!.purchaseBillId ?? "";
                      invoiceNoController.text = d.billDetails!.invoiceNo ?? "";
                      final tdsStr = d.billDetails!.tdsAmount ?? "";
                        final otherStr = d.billDetails!.otherAmt ?? "";
                      othersController.text =
                          (otherStr == "0" || otherStr == "0.00") ? "" : otherStr;
                      final discountStr = d.billDetails!.discountAmt ?? "";
                      discountController.text =
                          (discountStr == "0" || discountStr == "0.00") ? "" : discountStr;
                      tdsController.text =
                          (tdsStr == "0" || tdsStr == "0.00") ? "" : tdsStr;
                      remarkController.text =
                          d.billDetails!.remarks ?? "";
                      billAddressController.text =
                          d.billDetails!.billAddress ?? "";
                      if (d.billDetails!.taxType != null &&
                          d.billDetails!.taxType!.isNotEmpty) {
                        taxType = d.billDetails!.taxType!;
                      }
                      try {
                        billDate = DateFormat('dd-MM-yyyy')
                            .parse(d.billDetails!.billDate ?? "");
                      } catch (e) {
                        billDate = DateTime.now();
                      }
                      try {
                        if (d.billDetails!.invoiceDate != null &&
                            d.billDetails!.invoiceDate!.isNotEmpty) {
                          invoiceDate = DateFormat('dd-MM-yyyy')
                              .parse(d.billDetails!.invoiceDate!);
                        }
                      } catch (e) {
                        invoiceDate = DateTime.now();
                      }
                      if (d.billDetails!.billFile != null &&
                          d.billDetails!.billFile!.isNotEmpty) {
                        existingBillFile = d.billDetails!.billFile;
                      }
                      if (suppliers.any(
                          (s) => s.supplierId == d.billDetails!.supplierId)) {
                        selectedSupplier = suppliers.firstWhere(
                            (s) => s.supplierId == d.billDetails!.supplierId);
                      }
                    }

                    // Load payment details
                    // Load payment details
if (d.paymentDetails != null && d.paymentDetails!.isNotEmpty) {
  paymentItems.clear();

  for (final payment in d.paymentDetails!) {
    try {
      DateTime paidDate = DateTime.now();

      if (payment.paidDate != null &&
          payment.paidDate!.isNotEmpty) {
        paidDate =
            DateFormat('dd-MM-yyyy').parse(payment.paidDate!);
      }

      DateTime? trRefDate;

      if (payment.trReferenceDate != null &&
          payment.trReferenceDate!.isNotEmpty) {
        trRefDate = DateFormat('dd-MM-yyyy')
            .parse(payment.trReferenceDate!);
      }

      paymentItems.add(
        PaymentItem(
          paidDate: paidDate,
          paidAmount:
              double.tryParse(
                    payment.advanceAmountPaid ?? "0",
                  ) ??
                  0.0,

          // Payment/Account ID from API
          debitAccountId: payment.id?.toString() ?? "",

          // Account Name
          debitAccountName:
              payment.accountName ?? "",

          paymentMode:
              (payment.paymentMode?.isNotEmpty ?? false)
                  ? payment.paymentMode!
                  : "Cash",

          trRefNo: payment.trReferenceNo ?? "",
          trRefDate: trRefDate,
          remarks:
              payment.transactionRemarks ?? "",
        ),
      );
    } catch (e) {
      print("Error parsing payment details: $e");
    }
  }
}

                    if (d.items != null) {
                      cartItems = d.items!.map((item) {
                        return BillItem(
                          material: MaterialData(
                            materialId: item.materialId,
                            materialName: item.materialName,
                            unitName: item.unitName,
                          ),
                          quantity: double.tryParse(item.quantity.toString()) ?? 1.0,
                          unitPrice: double.tryParse(item.unitPrice.toString()) ?? 0.0,
                          gstPercentage: double.tryParse(item.gst.toString()) ?? 0.0,
                        );
                      }).toList();
                    }
                  });
                }
              });
            }

            double totalSubtotal =
                cartItems.fold(0, (sum, item) => sum + item.subTotal);
            double totalGst =
                cartItems.fold(0, (sum, item) => sum + item.gstAmount);
            double tds = double.tryParse(tdsController.text) ?? 0.0;
            double others = double.tryParse(othersController.text) ?? 0.0;
            double discount = double.tryParse(discountController.text) ?? 0.0;
            double payableAmount =
                totalSubtotal + totalGst + tds + others - discount;
            double totalPaid =
                paymentItems.fold(0.0, (sum, p) => sum + p.paidAmount);
            double balanceAmount = payableAmount - totalPaid;
            return Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.95,
                  height: MediaQuery.of(context).size.height * 0.95,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          color: const Color(0xFF2a86c9),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  editBill == null
                                      ? "Purchase Bill"
                                      : "Edit Purchase Bill",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                              IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.white),
                                  onPressed: () => Navigator.pop(context)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 16),
                                Row(
                                   children: [
                                     Expanded(
                                       child: _buildInputLabelField(
                                         label: "Requested To *",
                                         child: InkWell(
                                           onTap: () {
                                             if (_locations.isEmpty) {
                                               Common.toastMessaage(
                                                 "No locations available",
                                                 Colors.red,
                                               );
                                               return;
                                             }

                                             _showItemPicker(
                                               "Location",
                                               _locations
                                                   .map((e) => e.locationName)
                                                   .toList(),
                                               (index) {
                                                 setDialogState(() {
                                                   locationId =
                                                       _locations[index].id;
                                                   locationName =
                                                       _locations[index]
                                                           .locationName;
                                                 });
                                               },
                                             );
                                           },
                                           child: Container(
                                             padding: const EdgeInsets.symmetric(
                                                 horizontal: 12, vertical: 12),
                                             decoration: BoxDecoration(
                                               color: Colors.white,
                                               borderRadius:
                                                   BorderRadius.circular(10),
                                               border: Border.all(
                                                   color: Colors.grey.shade300),
                                             ),
                                             child: Row(
                                               children: [
                                                 const Icon(Icons.store_rounded,
                                                     size: 16,
                                                     color: Color(0xFF2a86c9)),
                                                 const SizedBox(width: 8),
                                                 Expanded(
                                                   child: Text(
                                                     locationName ??
                                                         "Select Location",
                                                     maxLines: 1,
                                                     overflow:
                                                         TextOverflow.ellipsis,
                                                     style: TextStyle(
                                                       color: locationName !=
                                                               null
                                                           ? Colors.black87
                                                           : Colors.grey,
                                                       fontSize: 13,
                                                     ),
                                                   ),
                                                 ),
                                                 const Icon(
                                                   Icons
                                                       .keyboard_arrow_down_rounded,
                                                   size: 18,
                                                   color: Colors.grey,
                                                 ),
                                               ],
                                             ),
                                           ),
                                         ),
                                       ),
                                     ),
                                     const SizedBox(width: 8),
                                     Expanded(
                                       child: _buildInputLabelField(
                                         label: "Bill Date",
                                         child: InkWell(
                                           onTap: () async {
                                             final picked = await showDatePicker(
                                                 context: context,
                                                 initialDate: invoiceDate,
                                                 firstDate: DateTime(2000),
                                                 lastDate: DateTime(2100));
                                             if (picked != null)
                                               setDialogState(
                                                   () => invoiceDate = picked);
                                           },
                                           child: Container(
                                             padding: const EdgeInsets.symmetric(
                                                 horizontal: 12, vertical: 12),
                                             decoration: BoxDecoration(
                                                 color: Colors.white,
                                                 borderRadius:
                                                     BorderRadius.circular(10),
                                                 border: Border.all(
                                                     color: Colors.grey.shade300)),
                                             child: Row(
                                               children: [
                                                 const Icon(Icons.calendar_today,
                                                     size: 14, color: Colors.grey),
                                                 const SizedBox(width: 8),
                                                 Text(DateFormat('dd-MM-yyyy')
                                                     .format(invoiceDate)),
                                               ],
                                             ),
                                           ),
                                         ),
                                       ),
                                     ),
                                     if (editBill != null) ...[
                                       const SizedBox(width: 8),
                                       Expanded(
                                         child: _buildInputLabelField(
                                           label: "Invoice Number",
                                           child: TextField(
                                             controller: invoiceNoController,
                                             decoration: _inputDecoration(
                                                 "Invoice Number"),
                                           ),
                                         ),
                                       ),
                                     ],
                                   ],
                                 ),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: _buildInputLabelField(
                                        label: "Supplier Name*",
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    border: Border.all(
                                                        color: Colors
                                                            .grey.shade300)),
                                                child: DropdownSearch<Supplier>(
                                                  items: (filter, loadProps) {
                                                    if (filter.isEmpty)
                                                      return suppliers;
                                                    return suppliers
                                                        .where((supplier) =>
                                                            supplier
                                                                .supplierName
                                                                .toLowerCase()
                                                                .contains(filter
                                                                    .toLowerCase()))
                                                        .toList();
                                                  },
                                                  itemAsString: (s) =>
                                                      s.supplierName,
                                                  compareFn: (item,
                                                          selectedItem) =>
                                                      item?.supplierId ==
                                                      selectedItem?.supplierId,
                                                  selectedItem:
                                                      selectedSupplier,
                                                  onChanged: (val) =>
                                                      setDialogState(() =>
                                                          selectedSupplier =
                                                              val),
                                                  decoratorProps:
                                                      DropDownDecoratorProps(
                                                    decoration: InputDecoration(
                                                      contentPadding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                              horizontal: 12,
                                                              vertical: 14),
                                                      border: InputBorder.none,
                                                      hintText:
                                                          "Select Supplier",
                                                      hintStyle:
                                                          const TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              fontSize: 14),
                                                    ),
                                                  ),
                                                  popupProps:
                                                      const PopupProps.menu(
                                                    showSearchBox: true,
                                                    searchFieldProps:
                                                        TextFieldProps(
                                                      decoration:
                                                          InputDecoration(
                                                        hintText:
                                                            "Search supplier...",
                                                        hintStyle: TextStyle(
                                                            fontSize: 14),
                                                        contentPadding:
                                                            EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        14,
                                                                    vertical:
                                                                        12),
                                                        prefixIcon: Icon(
                                                            Icons.search,
                                                            size: 20),
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          10)),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                              icon: const Icon(Icons.add_circle,
                                                  color: Color(0xFF2a86c9),
                                                  size: 30),
                                              onPressed: () {
                                                _showQuickAddSupplierDialog(
                                                    context, onSupplierAdded:
                                                        (newSupplier) {
                                                  setDialogState(() {
                                                    if (!suppliers.any((s) =>
                                                        s.supplierId ==
                                                        newSupplier
                                                            .supplierId)) {
                                                      suppliers
                                                          .add(newSupplier);
                                                    }
                                                    selectedSupplier =
                                                        newSupplier;
                                                  });
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // const SizedBox(height: 16),
                                // _buildInputLabelField(
                                //   label: "Bill Address",
                                //   child: TextField(
                                //     controller: billAddressController,
                                //     maxLines: 3,
                                //     decoration: InputDecoration(
                                //       hintText: "Enter bill address",
                                //       border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                                //       enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                                //       contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                //       fillColor: Colors.white,
                                //       filled: true,
                                //     ),
                                //   ),
                                // ),
                                // const SizedBox(height: 16),
                                // _buildInputLabelField(
                                //   label: "Tax Type",
                                //   child: Row(
                                //     children: [
                                //       Radio<String>(
                                //         value: 'Intrastate',
                                //         groupValue: taxType,
                                //         activeColor: const Color(0xFF2a86c9),
                                //         onChanged: (val) {
                                //           if (val != null) setDialogState(() => taxType = val);
                                //         },
                                //       ),
                                //       const Text("Intrastate"),
                                //       const SizedBox(width: 20),
                                //       Radio<String>(
                                //         value: 'Interstate',
                                //         groupValue: taxType,
                                //         activeColor: const Color(0xFF2a86c9),
                                //         onChanged: (val) {
                                //           if (val != null) setDialogState(() => taxType = val);
                                //         },
                                //       ),
                                //       const Text("Interstate"),
                                //     ],
                                //   ),
                                // ),
                                const SizedBox(height: 30),
                                const Text("ADD ITEMS TO CART",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.blueGrey)),
                                const SizedBox(height: 16),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: _buildInputLabelField(
                                        label: "Product",
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                                color: Colors.grey.shade300),
                                          ),
                                          child: DropdownSearch<MaterialData>(
                                            items: (filter, loadProps) =>
                                                dialogMaterials,
                                            itemAsString: (m) =>
                                                m.materialName ?? "",
                                            compareFn: (item, selectedItem) =>
                                                item.materialId ==
                                                selectedItem?.materialId,
                                            onChanged: (val) => setDialogState(
                                              () => selectedMaterial = val,
                                            ),
                                            selectedItem: selectedMaterial,
                                            decoratorProps:
                                                DropDownDecoratorProps(
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 14,
                                                ),
                                                border: InputBorder.none,
                                                hintText: "Select Product",
                                                hintStyle: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            popupProps: const PopupProps.menu(
                                              showSearchBox: true,
                                              searchFieldProps: TextFieldProps(
                                                decoration: InputDecoration(
                                                  hintText: "Search product...",
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 12),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 0),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          if (selectedMaterial != null) {
                                            setDialogState(() {
                                              cartItems.add(BillItem(
                                                material: selectedMaterial!,
                                                unitPrice: double.tryParse(
                                                      selectedMaterial!.purchasePrice?.isNotEmpty == true
                                                          ? selectedMaterial!.purchasePrice!
                                                          : (selectedMaterial!.unitPrice ?? "0"),
                                                    ) ??
                                                    0.0,
                                                gstPercentage: double.tryParse(
                                                      selectedMaterial!
                                                              .gstPercentage ??
                                                          "0",
                                                    ) ??
                                                    0.0,
                                              ));
                                              selectedMaterial = null;
                                            });
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF2a86c9),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 12),
                                          minimumSize: const Size(0, 48),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: const Icon(Icons.add,
                                            color: Colors.white, size: 24),
                                      ),
                                    ),
                                    // Padding(
                                    //   padding: const EdgeInsets.only(bottom: 0),
                                    //   child: ElevatedButton.icon(
                                    //     onPressed: () {
                                    //       if (selectedMaterial != null) {
                                    //         setDialogState(() {
                                    //           cartItems.add(BillItem(
                                    //             material: selectedMaterial!,
                                    //             unitPrice: double.tryParse(
                                    //                   selectedMaterial!
                                    //                           .unitPrice ??
                                    //                       "0",
                                    //                 ) ??
                                    //                 0.0,
                                    //             gstPercentage: double.tryParse(
                                    //                   selectedMaterial!
                                    //                           .gstPercentage ??
                                    //                       "0",
                                    //                 ) ??
                                    //                 0.0,
                                    //           ));
                                    //           selectedMaterial = null;
                                    //         });
                                    //       }
                                    //     },
                                    //     icon: const Icon(Icons.add,
                                    //         color: Colors.white, size: 18),
                                    //     label: const Text(
                                    //       "Add",
                                    //       style: TextStyle(color: Colors.white),
                                    //     ),
                                    //     style: ElevatedButton.styleFrom(
                                    //       backgroundColor:
                                    //           const Color(0xFF2a86c9),
                                    //       padding: const EdgeInsets.symmetric(
                                    //           horizontal: 20, vertical: 14),
                                    //       minimumSize: const Size(0, 48),
                                    //       shape: RoundedRectangleBorder(
                                    //         borderRadius:
                                    //             BorderRadius.circular(10),
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),
                                    const SizedBox(width: 8),
                                    Container(
                                      height: 48,
                                      width: 48,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2a86c9),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: IconButton(
                                        onPressed: () async {
                                          var res = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const SimpleBarcodeScannerPage(),
                                            ),
                                          );
                                          if (res is String && res != '-1') {
                                            Common.showProgressDialog(
                                                context, "Fetching product...");
                                            final productRes = await HttpService
                                                .getQrcodeproductDetails(res);
                                            Navigator.pop(
                                                context);
                                            if (productRes != null &&
                                                productRes.data != null) {
                                              final productData =
                                                  productRes.data!;
                                              setDialogState(() {
                                                int existingIndex = cartItems
                                                    .indexWhere((item) =>
                                                        item.material
                                                            .materialId ==
                                                        productData.id);
                                                if (existingIndex != -1) {
                                                  cartItems[existingIndex]
                                                      .quantity += 1;
                                                } else {
                                                  cartItems.add(BillItem(
                                                    material: MaterialData(
                                                      materialId:
                                                          productData.id,
                                                      materialName: productData
                                                          .productName,
                                                      unitName:
                                                          productData.unitName,
                                                      unitPrice: productData
                                                              .purchaseAmount ??
                                                          productData
                                                              .sellingPrice,
                                                      gstPercentage: productData
                                                          .taxPercent,
                                                    ),
                                                    unitPrice: double.tryParse(
                                                            productData
                                                                    .purchaseAmount ??
                                                                productData
                                                                    .sellingPrice ??
                                                                "0") ??
                                                        0.0,
                                                    gstPercentage: double
                                                            .tryParse(productData
                                                                    .taxPercent ??
                                                                "0") ??
                                                        0.0,
                                                  ));
                                                }
                                              });
                                            } else {
                                              Common.toastMessaage(
                                                  "Product not found",
                                                  Colors.red);
                                            }
                                          }
                                        },
                                        icon: const Icon(Icons.qr_code_scanner,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: DataTable(
                                      columnSpacing: 20,
                                      dataRowMaxHeight: double.infinity,
                                      dataRowMinHeight: 60,
                                      headingRowColor: WidgetStateProperty.all(
                                          Colors.grey.shade100),
                                      columns:  [
                                        DataColumn(label: Text("#")),
                                        DataColumn(label: Text("Material")),
                                        DataColumn(label: Text("Quantity")),
                                        DataColumn(label: Text("Unit Price")),
                                        DataColumn(label: Text("Total")),
                                        DataColumn(label: Text("GST %")),
                                        if (taxType == 'Intrastate') ...[
                                          DataColumn(label: Text("CGST (Amt)")),
                                          DataColumn(label: Text("SGST (Amt)")),
                                        ],
                                        if (taxType == 'Interstate')
                                          DataColumn(label: Text("IGST (Amt)")),
                                        DataColumn(label: Text("GST Amount")),
                                        DataColumn(label: Text("Sub Total")),
                                        DataColumn(label: Text("Action")),
                                      ],
                                      rows: List.generate(cartItems.length,
                                          (index) {
                                        final item = cartItems[index];
                                        return DataRow(cells: [
                                          DataCell(Text("${index + 1}")),
                                          DataCell(Text(
                                              item.material.materialName ??
                                                  "")),
                                          DataCell(
                                            SizedBox(
                                              width: 140,
                                              child: Row(
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons
                                                          .remove_circle_outline,
                                                      size: 18,
                                                      color: Colors.red,
                                                    ),
                                                    onPressed: () {
                                                      if (item.quantity > 1) {
                                                        setDialogState(() =>
                                                            item.quantity--);
                                                      }
                                                    },
                                                  ),
                                                  Expanded(
                                                    child: SizedBox(
                                                      height: 38,
                                                      child: TextFormField(
                                                        key: ValueKey(
                                                            '${item.material.materialId}_${item.quantity}'),
                                                        initialValue: item
                                                            .quantity
                                                            .toInt()
                                                            .toString(),
                                                        keyboardType: TextInputType.number,
                                                          inputFormatters: [
                                                            FilteringTextInputFormatter.digitsOnly,
                                                          ],
                                                        textAlign:
                                                            TextAlign.center,
                                                        decoration:
                                                            InputDecoration(
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 6),
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                          isDense: true,
                                                        ),
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 13,
                                                        ),
                                                        onChanged: (value) {
                                                          final qty =
                                                              int.tryParse(
                                                                  value);
                                                          if (qty != null &&
                                                              qty > 0) {
                                                          setDialogState(() {
                                                              item.quantity =
                                                                  qty.toDouble();
                                                            });
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.add_circle_outline,
                                                      size: 18,
                                                      color: Colors.green,
                                                    ),
                                                    onPressed: () {
                                                      setDialogState(() =>
                                                          item.quantity++);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          DataCell(Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                  width: 80,
                                                  child: TextField(
                                                      controller:
                                                          item.unitPriceController,
                                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                      inputFormatters: [
                                                        FilteringTextInputFormatter.allow(
                                                          RegExp(r'^\d*\.?\d*'),
                                                        ),
                                                      ],
                                                      onChanged: (v) =>
                                                          setDialogState(() => item
                                                                  .unitPrice =
                                                              double.tryParse(v) ??
                                                                  0.0),
                                                      decoration: const InputDecoration(
                                                          isDense: true,
                                                          border:
                                                              OutlineInputBorder()))),
                                              if (item.material.lastPurchasePrice != null && item.material.lastPurchasePrice!.isNotEmpty && item.material.lastPurchasePrice != "0" && item.material.lastPurchasePrice != "0.0") ...[
                                                const SizedBox(height: 2),
                                                Text(
                                                  "Last: ₹${item.material.lastPurchasePrice}",
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.red,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ]
                                            ],
                                          )),
                                          DataCell(Text(
                                              "₹${item.subTotal.toStringAsFixed(2)}",
                                              style: const TextStyle(
                                                  fontSize: 12))),
                                          DataCell(SizedBox(
                                              width: 60,
                                              child: TextField(
                                                  controller:
                                                      item.gstController,
                                                   keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter.allow(
                                                        RegExp(r'^\d*\.?\d*'),
                                                      ),
                                                    ],
                                                  onChanged: (v) =>
                                                      setDialogState(() => item
                                                              .gstPercentage =
                                                          double.tryParse(v) ??
                                                              0.0),
                                                  decoration: const InputDecoration(
                                                      isDense: true,
                                                      border:
                                                          OutlineInputBorder())))),
                                          if (taxType == 'Intrastate') ...[
                                            DataCell(Text(
                                                "₹${(item.gstAmount / 2).toStringAsFixed(2)}",
                                                style: const TextStyle(
                                                    fontSize: 12))),
                                            DataCell(Text(
                                                "₹${(item.gstAmount / 2).toStringAsFixed(2)}",
                                                style: const TextStyle(
                                                    fontSize: 12))),
                                          ],
                                          if (taxType == 'Interstate')
                                            DataCell(Text(
                                                "₹${item.gstAmount.toStringAsFixed(2)}",
                                                style: const TextStyle(
                                                    fontSize: 12))),
                                          DataCell(Text(
                                              "₹${item.gstAmount.toStringAsFixed(2)}",
                                              style: const TextStyle(
                                                  fontSize: 12))),
                                          DataCell(Text(
                                              "₹${item.total.toStringAsFixed(2)}",
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight:
                                                      FontWeight.bold))),
                                          DataCell(IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red, size: 18),
                                            onPressed: () async {
                                              if (editBill != null &&
                                                  editBill.billId != null) {
                                                bool? confirm =
                                                    await showDialog(
                                                  context: dialogContext,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    title: const Text(
                                                        'Delete Product'),
                                                    content: Text(
                                                        'Delete "${item.material.materialName}" from this bill?'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context, false),
                                                        child: const Text(
                                                            'Cancel'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context, true),
                                                        style: TextButton
                                                            .styleFrom(
                                                                foregroundColor:
                                                                    Colors.red),
                                                        child: const Text(
                                                            'Delete'),
                                                      ),
                                                    ],
                                                  ),
                                                );

                                                if (confirm == true) {
                                                  showDialog(
                                                    context: dialogContext,
                                                    barrierDismissible: false,
                                                    builder: (context) =>
                                                        const Center(
                                                            child:
                                                                CircularProgressIndicator()),
                                                  );
                                                  final response = await HttpService
                                                      .deletePurchaseOrderBillProduct(
                                                    productId: item
                                                        .material.materialId!,
                                                    billId: editBill.billId!,
                                                  );
                                                  Navigator.pop(dialogContext);

                                                  if (response?.status ==
                                                      true) {
                                                    Common.toastMessaage(
                                                        'Product deleted',
                                                        Colors.green);
                                                    setDialogState(() {
                                                      item.dispose();
                                                      cartItems.removeAt(index);
                                                    });
                                                    if (editBill.id != null) {
                                                      final refreshData =
                                                          await HttpService
                                                              .getPurchaseBillDetailsEdit(
                                                                  editBill.id!);
                                                      if (refreshData?.data
                                                                  ?.items !=
                                                              null &&
                                                          dialogContext
                                                              .mounted) {
                                                        setDialogState(() {
                                                          cartItems.clear();
                                                          cartItems.addAll(
                                                              refreshData!
                                                                  .data!.items!
                                                                  .map((item) =>
                                                                      BillItem(
                                                                        material:
                                                                            MaterialData(
                                                                          materialId:
                                                                              item.materialId,
                                                                          materialName:
                                                                              item.materialName,
                                                                          unitName:
                                                                              item.unitName,
                                                                          unitPrice:
                                                                              item.unitPrice,
                                                                          gstPercentage:
                                                                              item.gst,
                                                                        ),
                                                                        quantity:
                                                                            double.tryParse(item.quantity ?? "1") ??
                                                                                1.0,
                                                                        unitPrice:
                                                                            double.tryParse(item.unitPrice ?? "0") ??
                                                                                0.0,
                                                                        gstPercentage:
                                                                            double.tryParse(item.gst ?? "0") ??
                                                                                0.0,
                                                                      ))
                                                                  .toList());
                                                        });
                                                      }
                                                    }
                                                  } else {
                                                    Common.toastMessaage(
                                                        response?.message ??
                                                            'Delete failed',
                                                        Colors.red);
                                                  }
                                                }
                                              } else {
                                                // For new bill, just remove from cart without API call
                                                setDialogState(() {
                                                  item.dispose();
                                                  cartItems.removeAt(index);
                                                });
                                              }
                                            },
                                          )),
                                        ]);
                                      }),
                                    )),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  color: Colors.grey.shade50,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      const Text("Sub Total: ",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF2a86c9))),
                                      const SizedBox(width: 20),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                            color: const Color(0xFF2a86c9)
                                                .withOpacity(0.1),
                                            border: Border.all(
                                                color: Colors.grey.shade300),
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: Text(
                                            (totalSubtotal + totalGst)
                                                .toStringAsFixed(2),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF2a86c9))),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        _buildFinancialRow("TDS", tdsController,
                                            setDialogState),
                                        _buildFinancialRow("OTHERS",
                                            othersController, setDialogState),
                                        _buildFinancialRow("DISCOUNT",
                                            discountController, setDialogState),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  color: Colors.grey.shade50,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      const Text("Grand Total: ",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF2a86c9))),
                                      const SizedBox(width: 20),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                            color: const Color(0xFF2a86c9)
                                                .withOpacity(0.1),
                                            border: Border.all(
                                                color: Colors.grey.shade300),
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: Text(
                                            (payableAmount).toStringAsFixed(2),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF2a86c9))),
                                      ),
                                    ],
                                  ),
                                ),
                               // const SizedBox(height: 30),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2a86c9)
                                        .withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child:Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Payment Details",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),

                                      if (editBill == null)
                                        ElevatedButton.icon(
                                          onPressed: () => _showAddPaymentPopup(
                                            context,
                                            accountHeads,
                                            (PaymentItem newItem) {
                                              setDialogState(() {
                                                paymentItems.add(newItem);
                                              });
                                            },
                                          ),
                                          icon: const Icon(
                                            Icons.add,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                          label: const Text(
                                            "Add Payment",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF2a86c9),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                    ],
                                  )
                                ),
                                const SizedBox(height: 12),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    columnSpacing: 20,
                                    headingRowHeight: 40,
                                    dataRowHeight: 50,
                                    headingRowColor: WidgetStateProperty.all(
                                        Colors.grey.shade100),
                                    columns: const [
                                      DataColumn(label: Text("#")),
                                      DataColumn(label: Text("Paid Date")),
                                      DataColumn(label: Text("Paid Amount")),
                                      DataColumn(label: Text("Debit Acc")),
                                      DataColumn(label: Text("Payment Mode")),
                                      DataColumn(label: Text("TR Ref No")),
                                      DataColumn(label: Text("TR Ref Date")),
                                      DataColumn(label: Text("Remarks")),
                                      DataColumn(label: Text("Action")),
                                    ],
                                    rows: List.generate(paymentItems.length,
                                        (index) {
                                      final p = paymentItems[index];
                                      return DataRow(cells: [
                                        DataCell(Text("${index + 1}")),
                                        DataCell(Text(DateFormat('dd-MM-yyyy')
                                            .format(p.paidDate))),
                                        DataCell(Text(
                                            p.paidAmount.toStringAsFixed(2))),
                                        DataCell(Text(p.debitAccountName)),
                                        DataCell(Text(p.paymentMode)),
                                        DataCell(Text(p.trRefNo)),
                                        DataCell(Text(p.trRefDate != null
                                            ? DateFormat('dd-MM-yyyy')
                                                .format(p.trRefDate!)
                                            : "-")),
                                        DataCell(Text(p.remarks)),
                                        DataCell(IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red, size: 16),
                                          onPressed: () {
                                            setDialogState(() {
                                              paymentItems.removeAt(index);
                                            });
                                          },
                                        )),
                                      ]);
                                    }),
                                  ),
                                ),
                                const SizedBox(height: 30),
                                Table(
                                  border: TableBorder.all(
                                      color: Colors.grey.shade300),
                                  children: [
                                    TableRow(
                                      // backgroundColor: Colors.grey.shade100,
                                      children: const [
                                        Padding(
                                            padding: EdgeInsets.all(12),
                                            child: Center(
                                                child: Text("PAYABLE AMOUNT",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12)))),
                                        Padding(
                                            padding: EdgeInsets.all(12),
                                            child: Center(
                                                child: Text("TOTAL PAID",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12)))),
                                        Padding(
                                            padding: EdgeInsets.all(12),
                                            child: Center(
                                                child: Text("BALANCE AMOUNT",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12)))),
                                      ],
                                    ),
                                    TableRow(
                                      children: [
                                        Padding(
                                            padding: EdgeInsets.all(12),
                                            child: Center(
                                                child: Text(payableAmount
                                                    .toStringAsFixed(2)))),
                                        Padding(
                                            padding: EdgeInsets.all(12),
                                            child: Center(
                                                child: Text(
                                                    "₹${totalPaid.toStringAsFixed(2)}"))),
                                        Padding(
                                            padding: EdgeInsets.all(12),
                                            child: Center(
                                                child: Text(balanceAmount
                                                    .toStringAsFixed(2)))),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 30),
                                const SizedBox(height: 30),
                                _buildInputLabelField(
                                  label: "Upload Bill Copy",
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          onTap: () async {
                                            FilePickerResult? result =
                                                await FilePicker.platform
                                                    .pickFiles();
                                            if (result != null) {
                                              setDialogState(() =>
                                                  billCopyFile =
                                                      result.files.first);
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: Colors.grey.shade300),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(Icons.upload_file,
                                                    size: 16,
                                                    color: billCopyFile != null
                                                        ? Colors.blue
                                                        : Colors.grey),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    billCopyFile != null
                                                        ? billCopyFile!.name
                                                        : existingBillFile !=
                                                                null
                                                            ? existingBillFile!
                                                                .split('/')
                                                                .last
                                                            : "Choose file from storage",
                                                    style: TextStyle(
                                                      color: (billCopyFile !=
                                                                  null ||
                                                              existingBillFile !=
                                                                  null)
                                                          ? Colors.black
                                                          : Colors.grey,
                                                      fontSize: 13,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (existingBillFile != null) ...[
                                        const SizedBox(width: 8),
                                        InkWell(
                                          onTap: () {
                                            _launchExistingBill(
                                                existingBillFile!);
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: Colors.blue.shade200),
                                            ),
                                            child: const Icon(Icons.visibility,
                                                color: Colors.blue, size: 20),
                                          ),
                                        ),
                                      ],
                                      const SizedBox(width: 8),
                                      InkWell(
                                        onTap: () async {
                                          final XFile? photo =
                                              await picker.pickImage(
                                                  source: ImageSource.camera);
                                          if (photo != null) {
                                            File imageFile = File(photo.path);
                                            setDialogState(() =>
                                                billCopyFile = PlatformFile(
                                                  name: photo.name,
                                                  path: photo.path,
                                                  size: imageFile.lengthSync(),
                                                ));
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF2a86c9)
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                                color: Colors.grey.shade300),
                                          ),
                                          child: const Icon(Icons.camera_alt,
                                              color: Color(0xFF2a86c9),
                                              size: 20),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildInputLabelField(
                                    label: "Transaction Remark",
                                    child: TextField(
                                        controller: remarkController,
                                        maxLines: 2,
                                        decoration:
                                            _inputDecoration("Remarks/Notes"))),
                                const SizedBox(height: 40),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (selectedSupplier == null ||
                                          cartItems.isEmpty) {
                                        Common.toastMessaage(
                                            "Please fill required fields and add items",
                                            Colors.orange);
                                        return;
                                      }
                                      for (var item in cartItems) {
                                        double uprice = double.tryParse(item.unitPriceController.text) ?? 0.0;
                                        if (uprice <= 0) {
                                          Common.toastMessaage(
                                              "Unit price cannot be 0 for ${item.material.materialName ?? 'item'}",
                                              Colors.orange);
                                          return;
                                        }
                                      }
                                      Map<String, dynamic> body = {
                                        "bill_no": billIdController.text,
                                        
                                        "requested_to": locationId,
                                        "bill_date": DateFormat('yyyy-MM-dd')
                                            .format(billDate),
                                        "supplier_id":
                                            selectedSupplier!.supplierId,
                                        "invoice_no": invoiceNoController.text,
                                        "invoice_date": DateFormat('yyyy-MM-dd')
                                            .format(billDate),
                                        "sub_total": totalSubtotal,
                                        "gst_amount": totalGst,
                                        "grand_total": payableAmount,
                                        "paid_amount": totalPaid,
                                        "balance_amount": balanceAmount,
                                        "tds": tdsController.text,
                                        "others": othersController.text,
                                        "discount": discountController.text,
                                        "bill_no": billIdController.text,
                                        "item_total":
                                            totalSubtotal.toStringAsFixed(2),
                                        "gst_total":
                                            totalGst.toStringAsFixed(2),
                                        "tds_amount": tds.toStringAsFixed(2),
                                        "other_charges":
                                            others.toStringAsFixed(2),
                                        "discount_amount":
                                            discount.toStringAsFixed(2),
                                        "grand_total":
                                            payableAmount.toStringAsFixed(2),
                                        "remarks": remarkController.text,
                                        "bill_address": billAddressController.text,
                                        "tax_type": taxType,
                                      };

                                      if (editBill != null) {
                                        body["bill_id"] = editBill.billId;
                                      }

                                      if (billCopyFile != null) {
                                        body["bill_copy"] =
                                            await dio.MultipartFile.fromFile(
                                                billCopyFile!.path!);
                                      }

                                      for (int i = 0;
                                          i < cartItems.length;
                                          i++) {
                                        body["material_id[$i]"] =
                                            cartItems[i].material.materialId;
                                        body["quantity[$i]"] =
                                            cartItems[i].quantity;
                                        body["unit_price[$i]"] =
                                            cartItems[i].unitPrice;
                                        body["gst_percentage[$i]"] =
                                            cartItems[i].gstPercentage;
                                      }

                                      for (int i = 0; i < paymentItems.length; i++) {
                                        body["payments[$i][id]"] =
                                            paymentItems[i].debitAccountId;

                                        body["payments[$i][debit_account]"] =
                                            paymentItems[i].debitAccountName;

                                        body["payments[$i][paid_date]"] =
                                            DateFormat('yyyy-MM-dd').format(
                                                paymentItems[i].paidDate);

                                        body["payments[$i][paid_amount]"] =
                                            paymentItems[i].paidAmount.toString();

                                        body["payments[$i][payment_mode]"] =
                                            paymentItems[i].paymentMode;

                                        body["payments[$i][tr_reference_no]"] =
                                            paymentItems[i].trRefNo;

                                        body["payments[$i][tr_reference_date]"] =
                                            paymentItems[i].trRefDate != null
                                                ? DateFormat('yyyy-MM-dd')
                                                    .format(paymentItems[i].trRefDate!)
                                                : "";

                                        body["payments[$i][transaction_remarks]"] =
                                            paymentItems[i].remarks;
                                      }

                                      Common.showProgressDialog(
                                          context, "Saving bill...");
                                      final res = editBill == null
                                          ? await HttpService.postPurchaseBill(
                                              body)
                                          : await HttpService
                                              .updatePurchaseBill(body);

                                      Navigator.pop(
                                          context); // Pop progress dialog

                                      if (res != null) {
                                        Common.toastMessaage(
                                            "Bill saved successfully",
                                            Colors.green);
                                        Navigator.pop(
                                            context); // Pop add bill dialog
                                        _fetchBills();
                                      } else {
                                        Common.toastMessaage(
                                            "Failed to save bill", Colors.red);
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10))),
                                    child: const Text("SUBMIT",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
  void _showItemPicker(
  String title,
  List<String> items,
  Function(int index) onSelected,
) {
  List<String> filteredItems = List.from(items);
  final searchController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.65,
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    "Select $title",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: "Search $title",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          filteredItems = items
                              .where(
                                (e) => e
                                    .toLowerCase()
                                    .contains(value.toLowerCase()),
                              )
                              .toList();
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  Expanded(
                    child: ListView.separated(
                      itemCount: filteredItems.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(filteredItems[index]),
                          trailing: const Icon(
                            Icons.chevron_right,
                            size: 18,
                          ),
                          onTap: () {
                            final originalIndex =
                                items.indexOf(filteredItems[index]);

                            Navigator.pop(context);

                            onSelected(originalIndex);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _buildFormField({
  required String label,
  required Widget child,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 8),
      child,
    ],
  );
}
Widget _buildClickableField(
  String text,
  IconData icon,
  VoidCallback onTap,
) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF2a86c9),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: text.startsWith("Select")
                    ? Colors.grey
                    : Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.grey,
          ),
        ],
      ),
    ),
  );
}
  
  // Widget _buildFinancialRow(String label, TextEditingController controller,
  //     StateSetter setDialogState) {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 8),
  //     child: Row(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         Container(
  //           width: 100,
  //           padding: const EdgeInsets.all(12),
  //           decoration: BoxDecoration(
  //               color: Colors.white,
  //               border: Border.all(color: Colors.grey.shade300)),
  //           child: Text(label,
  //               style:
  //                   const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
  //         ),
  //         Container(
  //           width: 150,
  //           padding: const EdgeInsets.symmetric(horizontal: 12),
  //           decoration: BoxDecoration(
  //               color: Colors.white,
  //               border: Border.all(color: Colors.grey.shade300)),
  //           child: TextField(
  //             controller: controller,
  //             keyboardType: TextInputType.number,
  //             onChanged: (v) => setDialogState(() {}),
  //             textAlign: TextAlign.right,
  //             decoration: const InputDecoration(
  //                 border: InputBorder.none, prefixText: "₹", hintText: "0"),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
Widget _buildFinancialRow(
  String label,
  TextEditingController controller,
  StateSetter setDialogState,
) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 100,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        Container(
          width: 150,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'^\d*\.?\d*'),
              ),
            ],
            onChanged: (v) {
              setDialogState(() {});
            },
            textAlign: TextAlign.right,
            decoration: const InputDecoration(
              border: InputBorder.none,
              prefixText: "₹",
              hintText: "0",
            ),
          ),
        ),
      ],
    ),
  );
}
  Widget _buildReadOnlyField(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300)),
      child: Text(text, style: const TextStyle(color: Colors.black54)),
    );
  }

  Widget _buildInputLabelField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.blueGrey)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300)),
      filled: true,
      fillColor: Colors.white,
    );
  }

  Widget _buildBillDetail(String label, String value,
      {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              color: const Color.fromARGB(255, 54, 20, 20), fontSize: 10),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
            fontSize: isHighlight ? 14 : 12,
            color: isHighlight ? const Color.fromARGB(255, 187, 71, 71) : Colors.black87,
          ),
        ),
      ],
    );
  }

  void _showAddPaymentPopup(
    BuildContext context,
    List<ListElement> accounts,
    Function(PaymentItem) onAdd, {
    String? totalAmount,
    String? paidAmount,
    String? balanceAmount,
  }) {
    DateTime paidDate = DateTime.now();
    DateTime trRefDate = DateTime.now();
    String paymentMode = "Cash";
    ListElement? selectedAccount;
    final TextEditingController amountController = TextEditingController(text: balanceAmount ?? "");
    final TextEditingController trRefNoController = TextEditingController();
    final TextEditingController remarksController = TextEditingController();
    Supplier? selectedSupplierPopup;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2a86c9),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Add Payment",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                // Scrollable Form Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (totalAmount != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue.shade100),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildBillDetail(
                                    'Total Amount', '₹$totalAmount'),
                                _buildBillDetail('Paid Amount', '₹$paidAmount'),
                                _buildBillDetail('Balance', '₹$balanceAmount',
                                    isHighlight: true),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        // Supplier Name
                        // const Text(
                        //   "Supplier Name",
                        //   style: TextStyle(
                        //     fontWeight: FontWeight.w600,
                        //     fontSize: 14,
                        //     color: Colors.black87,
                        //   ),
                        // ),
                        // const SizedBox(height: 8),
                        // Row(
                        //   children: [
                        //     Expanded(
                        //       child: Container(
                        //         decoration: BoxDecoration(
                        //           color: Colors.white,
                        //           borderRadius: BorderRadius.circular(12),
                        //           border:
                        //               Border.all(color: Colors.grey.shade300),
                        //         ),
                        //         child: DropdownSearch<Supplier>(
                        //           items: (filter, loadProps) {
                        //             if (filter.isEmpty) return suppliers;
                        //             return suppliers
                        //                 .where((supplier) => supplier
                        //                     .supplierName
                        //                     .toLowerCase()
                        //                     .contains(filter.toLowerCase()))
                        //                 .toList();
                        //           },
                        //           itemAsString: (s) => s.supplierName ?? "",
                        //           compareFn: (item, selectedItem) =>
                        //               item?.supplierId ==
                        //               selectedItem?.supplierId,
                        //           selectedItem: selectedSupplierPopup,
                        //           onChanged: (val) => setState(
                        //               () => selectedSupplierPopup = val),
                        //           decoratorProps: DropDownDecoratorProps(
                        //             decoration: InputDecoration(
                        //               contentPadding:
                        //                   const EdgeInsets.symmetric(
                        //                       horizontal: 14, vertical: 14),
                        //               border: InputBorder.none,
                        //               hintText: "Select Supplier",
                        //               hintStyle: const TextStyle(
                        //                   color: Colors.grey, fontSize: 14),
                        //             ),
                        //           ),
                        //           popupProps: const PopupProps.menu(
                        //             showSearchBox: true,
                        //             searchFieldProps: TextFieldProps(
                        //               decoration: InputDecoration(
                        //                 hintText: "Search supplier...",
                        //                 contentPadding: EdgeInsets.symmetric(
                        //                     horizontal: 14, vertical: 12),
                        //                 prefixIcon:
                        //                     Icon(Icons.search, size: 20),
                        //                 border: OutlineInputBorder(
                        //                   borderRadius: BorderRadius.all(
                        //                       Radius.circular(10)),
                        //                 ),
                        //               ),
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //     const SizedBox(width: 10),
                        //     Container(
                        //       decoration: BoxDecoration(
                        //         color: const Color(0xFF2a86c9).withOpacity(0.1),
                        //         borderRadius: BorderRadius.circular(12),
                        //       ),
                        //       child: IconButton(
                        //         padding: EdgeInsets.zero,
                        //         constraints: const BoxConstraints(),
                        //         icon: const Icon(Icons.add_circle,
                        //             color: Color(0xFF2a86c9), size: 32),
                        //         onPressed: () {
                        //           _showQuickAddSupplierDialog(context,
                        //               onSupplierAdded: (newSupplier) {
                        //             setState(() {
                        //               if (!suppliers.any((s) =>
                        //                   s.supplierId ==
                        //                   newSupplier.supplierId)) {
                        //                 suppliers.add(newSupplier);
                        //               }
                        //               selectedSupplierPopup = newSupplier;
                        //             });
                        //           });
                        //         },
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        const SizedBox(height: 20),

                        // Paid Amount
                        const Text(
                          "Paid Amount",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          onChanged: (val) {
                            if (balanceAmount != null && val.isNotEmpty) {
                              double? entered = double.tryParse(val);
                              double maxB = double.tryParse(balanceAmount.replaceAll(',', '')) ?? 0.0;
                              if (entered != null && entered > maxB) {
                                amountController.text = maxB.toString();
                                amountController.selection = TextSelection.fromPosition(
                                  TextPosition(offset: amountController.text.length),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Amount cannot exceed balance"),
                                    backgroundColor: Colors.orange,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            }
                          },
                          decoration: InputDecoration(
                            hintText: "Enter amount",
                            prefixText: "₹ ",
                            prefixStyle: const TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Color(0xFF2a86c9), width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 14),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Paid Date
                        const Text(
                          "Paid Date",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: paidDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null)
                              setState(() => paidDate = picked);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    size: 20, color: Color(0xFF2a86c9)),
                                const SizedBox(width: 12),
                                Text(
                                  DateFormat('dd MMM yyyy').format(paidDate),
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Payment Mode
                        const Text(
                          "Payment Mode",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: paymentMode,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down,
                                  color: Color(0xFF2a86c9), size: 28),
                              items: ["Cash", "Bank", "Cheque", "Online"]
                                  .map((e) => DropdownMenuItem(
                                        value: e,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                          child: Text(e),
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => paymentMode = v!),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Debit Account",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: DropdownSearch<ListElement>(
                            items: (filter, loadProps) {
                              if (filter.isEmpty) return accounts;
                              return accounts
                                  .where((account) => account.accountName
                                      .toLowerCase()
                                      .contains(filter.toLowerCase()))
                                  .toList();
                            },
                            itemAsString: (a) => a.accountName,
                            compareFn: (item, selectedItem) =>
                                item?.accountId == selectedItem?.accountId,
                            onChanged: (val) => setState(() {
                              selectedAccount =
                                  val; // This stores the full ListElement object
                              // If you need just the account ID, you can do:
                              // selectedAccountId = val?.accountId;
                            }),
                            selectedItem: selectedAccount,
                            decoratorProps: DropDownDecoratorProps(
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 14),
                                border: InputBorder.none,
                                hintText: "Select Account",
                                hintStyle: const TextStyle(
                                    color: Colors.grey, fontSize: 14),
                              ),
                            ),
                            popupProps: const PopupProps.menu(
                              showSearchBox: true,
                              searchFieldProps: TextFieldProps(
                                decoration: InputDecoration(
                                  hintText: "Search account...",
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 12),
                                  prefixIcon: Icon(Icons.search, size: 20),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // TR Reference No
                        const Text(
                          "TR Reference No",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: trRefNoController,
                          decoration: InputDecoration(
                            hintText: "Enter reference number",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Color(0xFF2a86c9), width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 14),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // TR Reference Date
                        const Text(
                          "TR Reference Date",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: trRefDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null)
                              setState(() => trRefDate = picked);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    size: 20, color: Color(0xFF2a86c9)),
                                const SizedBox(width: 12),
                                Text(
                                  trRefDate != null
                                      ? DateFormat('dd MMM yyyy')
                                          .format(trRefDate!)
                                      : "Select Date",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: trRefDate != null
                                        ? Colors.black87
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Remarks
                        const Text(
                          "Remarks",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: remarksController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: "Enter remarks (optional)",
                            hintStyle: const TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Color(0xFF2a86c9), width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 14),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                // Action Buttons
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(20)),
                    border:
                        Border(top: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: Colors.grey.shade400),
                            foregroundColor: Colors.grey.shade700,
                          ),
                          child: const Text("Cancel",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (selectedAccount == null) {
                              Common.toastMessaage("Please select a Debit Account", Colors.red);
                              return;
                            }
                            final double? enteredAmt = double.tryParse(amountController.text);
                            final double? maxBalance = balanceAmount != null ? double.tryParse(balanceAmount.replaceAll(',', '')) : null;

                            if (enteredAmt != null && enteredAmt > 0) {
                              if (maxBalance != null && enteredAmt > maxBalance) {
                                Common.toastMessaage("Amount cannot exceed balance (₹$balanceAmount)", Colors.orange);
                                return;
                              }
                             onAdd(
  PaymentItem(
    paidDate: paidDate,
    paidAmount: enteredAmt,

    debitAccountId:
        selectedAccount?.accountId.toString() ?? "",

    debitAccountName:
        selectedAccount?.accountName ?? "N/A",

    paymentMode: paymentMode,

    trRefNo: trRefNoController.text,

    trRefDate: trRefDate,

    remarks: remarksController.text,
  ),
);
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please enter a valid amount"),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2a86c9),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text("Add Payment",
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildReadOnlyField(String value) {
  //   return Container(
  //     width: double.infinity,
  //     padding: const EdgeInsets.all(12),
  //     decoration: BoxDecoration(
  //       color: Colors.grey.shade100,
  //       borderRadius: BorderRadius.circular(10),
  //       border: Border.all(color: Colors.grey.shade300),
  //     ),
  //     child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
  //   );
  // }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 80, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          Text(
            'No Purchase Bills Found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  void _showQuickAddSupplierDialog(BuildContext context,
      {required Function(Supplier) onSupplierAdded}) {
    final TextEditingController nameCtrl = TextEditingController();
    final TextEditingController contactPersonCtrl = TextEditingController();
    final TextEditingController contactNoCtrl = TextEditingController();
    final TextEditingController addressCtrl = TextEditingController();
    final TextEditingController aadharCtrl = TextEditingController();
    final TextEditingController gstCtrl = TextEditingController();
    final TextEditingController accountCtrl = TextEditingController();
    final TextEditingController ifscCtrl = TextEditingController();
    final TextEditingController beneficiaryCtrl = TextEditingController();
    final TextEditingController openingBalanceCtrl = TextEditingController();

    List<MaterialData> selectedMaterials = [];
    List<MaterialData> materialsList = [];
    bool isMaterialsLoading = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            if (materialsList.isEmpty && !isMaterialsLoading) {
              isMaterialsLoading = true;
              HttpService.getMaterials().then((val) {
                if (val != null && val.data != null && dialogCtx.mounted) {
                  setDialogState(() {
                    materialsList = val.data!;
                    isMaterialsLoading = false;
                  });
                }
              }).catchError((e) {
                if (dialogCtx.mounted) {
                  setDialogState(() {
                    isMaterialsLoading = false;
                  });
                }
              });
            }

            Widget _buildCustomField({
              required String label,
              required String hint,
              required TextEditingController controller,
              bool isRequired = false,
              IconData? prefixIcon,
              bool isMultiline = false,
              TextInputType keyboardType = TextInputType.text,
              bool hasSuffixArrows = false,
            }) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      if (isRequired)
                        const Text(
                          " *",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      crossAxisAlignment: isMultiline
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.center,
                      children: [
                        if (prefixIcon != null) ...[
                          Container(
                            width: 42,
                            height: isMultiline ? 80 : 42,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(7),
                                bottomLeft: Radius.circular(7),
                              ),
                              border: Border(
                                right: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            child: Icon(prefixIcon,
                                color: const Color(0xFF64748B), size: 18),
                          ),
                        ],
                        Expanded(
                          child: TextField(
                            controller: controller,
                            maxLines: isMultiline ? 3 : 1,
                            keyboardType: keyboardType,
                            decoration: InputDecoration(
                              hintText: hint,
                              hintStyle: TextStyle(
                                  color: Colors.grey.shade400, fontSize: 13),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(
                                fontSize: 13, color: Colors.black87),
                          ),
                        ),
                        if (hasSuffixArrows) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.keyboard_arrow_up,
                                    size: 14, color: Colors.grey.shade600),
                                Icon(Icons.keyboard_arrow_down,
                                    size: 14, color: Colors.grey.shade600),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            }

            Widget _buildMaterialDropdown() {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Material",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const Text(
                        " *",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    constraints: const BoxConstraints(minHeight: 44),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownSearch<MaterialData>.multiSelection(
                      items: (f, p) => materialsList,
                      itemAsString: (m) => m.materialName ?? "",
                      compareFn: (i, s) => i.materialId == s.materialId,
                      selectedItems: selectedMaterials,
                      onChanged: (val) =>
                          setDialogState(() => selectedMaterials = val),
                      popupProps: PopupPropsMultiSelection.menu(
                        showSearchBox: true,
                        onItemAdded: (selectedItems, addedItem) {
                          setDialogState(() {
                            selectedMaterials = selectedItems;
                          });
                        },
                        onItemRemoved: (selectedItems, removedItem) {
                          setDialogState(() {
                            selectedMaterials = selectedItems;
                          });
                        },
                        validationBuilder: (ctx, selectedItems) =>
                            const SizedBox.shrink(),
                      ),
                      decoratorProps: DropDownDecoratorProps(
                        decoration: InputDecoration(
                          hintText: isMaterialsLoading
                              ? "Loading materials..."
                              : "Choose Material...",
                          hintStyle: TextStyle(
                              color: Colors.grey.shade400, fontSize: 13),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 2),
                          border: InputBorder.none,
                          suffixIcon: isMaterialsLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: Padding(
                                    padding: EdgeInsets.all(12),
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return Dialog(
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 550),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      decoration: const BoxDecoration(
                        color: Color(0xFF2a86c9),
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "ADD SUPPLIER",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 0.5,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(dialogCtx),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 22),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildMaterialDropdown(),
                            const SizedBox(height: 16),
                            _buildCustomField(
                              label: "Supplier Name",
                              hint: "Enter Supplier Name",
                              controller: nameCtrl,
                              isRequired: true,
                              prefixIcon: Icons.business,
                            ),
                            const SizedBox(height: 16),
                            //  Row(
                            //children: [
                            // Expanded(
                            //   child:
                            _buildCustomField(
                              label: "Contact Person",
                              hint: "Enter Contact Person",
                              controller: contactPersonCtrl,
                              prefixIcon: Icons.person,
                            ),
                            //),
                            const SizedBox(width: 16),
                            // Expanded(
                            //   child:

                            _buildCustomField(
                              label: "Contact No",
                              hint: "Enter Contact No",
                              controller: contactNoCtrl,
                              isRequired: true,
                              prefixIcon: Icons.phone,
                              keyboardType: TextInputType.phone,
                              hasSuffixArrows: true,
                            ),
                            // ),
                            // ],
                            // ),
                            const SizedBox(height: 16),
                            _buildCustomField(
                              label: "Supplier Address",
                              hint: "Enter Address",
                              controller: addressCtrl,
                              prefixIcon: Icons.location_on,
                              isMultiline: true,
                            ),
                            const SizedBox(height: 16),
                            //Row(
                            //    children: [
                            // Expanded(
                            //   child:

                            _buildCustomField(
                              label: "Aadhar Number",
                              hint: "Enter Aadhar Number",
                              controller: aadharCtrl,
                              keyboardType: TextInputType.number,
                              hasSuffixArrows: true,
                            ),
                            // ),
                            const SizedBox(width: 16),
                            // Expanded(
                            //   child:

                            _buildCustomField(
                              label: "GST No",
                              hint: "Enter Gst No",
                              controller: gstCtrl,
                            ),
                            //),
                            // ],
                            //),
                            const SizedBox(height: 16),
                            // Row(
                            // children: [
                            // Expanded(
                            //   child:

                            _buildCustomField(
                              label: "Account Number",
                              hint: "Enter Account No",
                              controller: accountCtrl,
                              keyboardType: TextInputType.number,
                              hasSuffixArrows: true,
                            ),
                            // ),
                            const SizedBox(width: 16),
                            // Expanded(
                            //   child:

                            _buildCustomField(
                              label: "IFSC Code",
                              hint: "Enter IFSC Code",
                              controller: ifscCtrl,
                            ),
                            //  ),
                            // ],
                            // ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildCustomField(
                                    label: "Beneficiary Name",
                                    hint: "Enter Beneficiary Name",
                                    controller: beneficiaryCtrl,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildCustomField(
                                    label: "Opening Balance",
                                    hint: "Enter Opening Balance",
                                    controller: openingBalanceCtrl,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(16)),
                        border: Border(
                            top: BorderSide(color: Colors.grey.shade200)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () => Navigator.pop(dialogCtx),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF1F5F9),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                            child: const Text(
                              "Close",
                              style: TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () async {
                              final name = nameCtrl.text.trim();
                              final contactNo = contactNoCtrl.text.trim();

                              if (selectedMaterials.isEmpty) {
                                Common.toastMessaage(
                                    "Please choose a material", Colors.red);
                                return;
                              }
                              if (name.isEmpty) {
                                Common.toastMessaage(
                                    "Please enter supplier name", Colors.red);
                                return;
                              }
                              if (contactNo.isEmpty) {
                                Common.toastMessaage(
                                    "Please enter contact number", Colors.red);
                                return;
                              }
                              if (contactNo.length != 10) {
                                Common.toastMessaage(
                                    "Contact number must be exactly 10 digits", Colors.red);
                                return;
                              }
                              final aadharNo = aadharCtrl.text.trim();
                              if (aadharNo.isNotEmpty && aadharNo.length != 12) {
                                Common.toastMessaage(
                                    "Aadhar number must be exactly 12 digits", Colors.red);
                                return;
                              }

                              showDialog(
                                context: dialogCtx,
                                barrierDismissible: false,
                                builder: (context) => const Center(
                                    child: CircularProgressIndicator()),
                              );

                              try {
                                final response = await HttpService.addSupplier({
                                  "material_id": selectedMaterials
                                      .map((m) => m.materialId)
                                      .join(","),
                                  "supplier_name": name,
                                  "contact_person":
                                      contactPersonCtrl.text.trim(),
                                  "contact_no": contactNo,
                                  "supplier_address": addressCtrl.text.trim(),
                                  "aadhar_no": aadharCtrl.text.trim(),
                                  "gst_no": gstCtrl.text.trim(),
                                  "account_no": accountCtrl.text.trim(),
                                  "ifsc_code": ifscCtrl.text.trim(),
                                  "beneficiary_name":
                                      beneficiaryCtrl.text.trim(),
                                  "opening_balance":
                                      openingBalanceCtrl.text.trim(),
                                });
                                Navigator.pop(dialogCtx);
                                if (response != null &&
                                    (response['status'] == true ||
                                        response['status'] == 'success')) {
                                  final getResponse =
                                      await HttpService.getSupplierList({});
                                  Supplier? newSup;
                                  if (getResponse != null &&
                                      getResponse.data != null) {
                                    try {
                                      newSup = getResponse.data!.firstWhere(
                                          (s) => s.supplierName == name);
                                    } catch (e) {
                                      // If not found, use fallback
                                    }
                                  }

                                  if (newSup == null) {
                                    final newSupId =
                                        response['supplier_id']?.toString() ??
                                            response['id']?.toString() ??
                                            DateTime.now()
                                                .millisecondsSinceEpoch
                                                .toString();

                                    newSup = Supplier(
                                        supplierId: newSupId,
                                        supplierName: name);
                                  }

                                  onSupplierAdded(newSup);
                                  Navigator.pop(dialogCtx);
                                  Common.toastMessaage(
                                      "Supplier added successfully",
                                      Colors.green);
                                } else {
                                  Common.toastMessaage(
                                      response?['message'] ??
                                          "Failed to add supplier",
                                      Colors.red);
                                }
                              } catch (e) {
                                Navigator.pop(dialogCtx);
                                Common.toastMessaage(
                                    "Error adding supplier: $e", Colors.red);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2a86c9),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                            child: const Text(
                              "Submit",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

import 'package:dio/dio.dart' as dio;

import 'package:file_picker/file_picker.dart';

import 'package:login2/core/common.dart';

import 'package:login2/models/lead_management/getPurchseOrderModel.dart';

import 'package:login2/models/lead_management/materialModel.dart';

import 'package:login2/models/lead_management/getSupplierListMode.dart';

import 'package:login2/models/rental/rentalLocationModel.dart';

import 'package:login2/models/expense/account_head_model.dart';

import 'package:login2/models/lead_management/getPurchaseOrderDetailsModel.dart'
    as details;

import 'package:login2/service/service.dart';

import 'package:intl/intl.dart';

import 'package:dropdown_search/dropdown_search.dart';

import 'package:login2/models/lead_management/getPurchaseRequestDetailsModel.dart';

import 'package:login2/screens/purchase/purchaseBillPage.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class PurchaseOrderPage extends StatefulWidget {
  final String token;

  final String name;

  final String userId;

  final List<PurchaseRequestDetail>? createFromRequestItems;

  final String? createFromRequestRemarks;

  const PurchaseOrderPage({
    super.key,
    required this.token,
    required this.name,
    required this.userId,
    this.createFromRequestItems,
    this.createFromRequestRemarks,
  });

  @override
  State<PurchaseOrderPage> createState() => _PurchaseOrderPageState();
}
class TermsConditionItem {
  TextEditingController titleController;
  TextEditingController descriptionController;

  TermsConditionItem({
    String title = "",
    String description = "",
  })  : titleController = TextEditingController(text: title),
        descriptionController =
            TextEditingController(text: description);
}
class _PurchaseOrderPageState extends State<PurchaseOrderPage> {
  bool isLoading = true;

List<RetailLocation> _locations = [];

String? locationId;
String? locationName;

String? purchaseRequestId;
String? pmrId;
String? alreadyOrderedQty;
String? remainingQty;
String? description;
String? unitPrice;
  List<PurchaseOrderData> orders = [];
  
  List<PurchaseOrderData> filteredOrders = [];

  String searchQuery = "";

  DateTime? fromDate;

  DateTime? toDate;

  String selectedStatus = "All";

  Supplier? selectedSupplierFilter;

  List<Supplier> suppliers = [];
String companyAddress = "";

Future<void> _loadCompanyAddress() async {
  print("Loading company address...");

  final address = await HttpService.getCompanyAddress();

  print("Company Address : $address");

  setState(() {
    companyAddress = address ?? "";
  });
}
  @override
  // void initState() {
  //   super.initState();

  //   _fetchOrders();

  //   _fetchSuppliers();
  //   _loadCompanyAddress(); 
  //   if (widget.createFromRequestItems != null) {
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       _showOrderDialog(
  //         createFromRequestItems: widget.createFromRequestItems,
  //         createFromRequestRemarks: widget.createFromRequestRemarks,
  //       );
  //     });
  //   }
  // }
  
@override
void initState() {
  super.initState();
  _initialize();
}

Future<void> _initialize() async {
  await _fetchOrders();
  await _fetchSuppliers();
  await _loadCompanyAddress(); // Wait for address
await _fetchLocations();

  if (widget.createFromRequestItems != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showOrderDialog(
        createFromRequestItems: widget.createFromRequestItems,
        createFromRequestRemarks: widget.createFromRequestRemarks,
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

  Future<void> _fetchOrders() async {
    setState(() => isLoading = true);

    try {
      Map<String, dynamic> data = {};

      if (selectedSupplierFilter != null) {
        data['supplier_id'] = selectedSupplierFilter!.supplierId;
      }

      final response = await HttpService.purchaseOrderList(data);

      if (response != null && response.data != null) {
        setState(() {
          orders = response.data!;

          _applySearch();

          isLoading = false;
        });
      } else {
        setState(() {
          orders = [];

          filteredOrders = [];

          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching purchase orders: $e");

      setState(() => isLoading = false);
    }
  }

  void _applySearch() {
    setState(() {
      filteredOrders = orders.where((order) {
        final query = searchQuery.toLowerCase();

        bool matchesSearch =
            (order.orderId?.toLowerCase().contains(query) ?? false) ||
                (order.supplierName?.toLowerCase().contains(query) ?? false) ||
                (order.billStatus?.toLowerCase().contains(query) ?? false);

        bool matchesStatus = selectedStatus == "All" ||
            (order.billStatus?.toLowerCase() == selectedStatus.toLowerCase());

        bool matchesDate = true;

        if (fromDate != null || toDate != null) {
          try {
            DateTime orderDT = DateFormat("dd-MM-yyyy").parse(order.orderDate!);

            if (fromDate != null && orderDT.isBefore(fromDate!))
              matchesDate = false;

            if (toDate != null &&
                orderDT.isAfter(toDate!.add(const Duration(days: 1))))
              matchesDate = false;
          } catch (e) {}
        }

        return matchesSearch && matchesStatus && matchesDate;
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
          'Purchase Orders',
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
                : filteredOrders.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        itemCount: filteredOrders.length,
                        itemBuilder: (context, index) {
                          return _buildOrderCard(filteredOrders[index]);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showOrderDialog(),
        backgroundColor: const Color(0xFF2a86c9),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('NEW ORDER',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
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
          onChanged: (value) {
            searchQuery = value;

            _applySearch();
          },
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search purchase orders...',
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

  Widget _buildOrderCard(PurchaseOrderData order) {
    bool isBilled = order.billStatus?.toLowerCase() == 'billed';

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
              onTap: () => _showViewDrawer(order),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    color: isBilled ? Colors.green : Colors.orange,
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
                              Text(
                                'Order NO: #${order.orderId ?? 'N/A'}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color(0xFF2a86c9),
                                ),
                              ),
                              Row(
                                children: [
                                  _buildStatusBadge(
                                      order.billStatus ?? 'Pending'),
                                  if (!isBilled) ...[
                                    const SizedBox(width: 8),

                                    Row(
                                      children: [
                                        PopupMenuButton<String>(
                                          icon: const Icon(Icons.more_vert,
                                              size: 20, color: Colors.grey),
                                          onSelected: (value) {
                                            if (value == 'edit') {
                                              _fetchOrderDetailsAndShowDialog(
                                                  order);
                                            } else if (value == 'create_bill') {
                                              _createBillFromOrder(order);
                                            } else if (value == 'delete') {
                                              _confirmDelete(order);
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            const PopupMenuItem(
                                              value: 'edit',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.edit,
                                                      size: 18,
                                                      color: Colors.blue),
                                                  SizedBox(width: 8),
                                                  Text("Edit"),
                                                ],
                                              ),
                                            ),
                                            if (order.billStatus ==
                                                "Bill Not Created")
                                              PopupMenuItem(
                                                value: 'create_bill',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.add,
                                                        size: 18,
                                                        color: Colors.green),
                                                    SizedBox(width: 8),
                                                    Text("Create Bill"),
                                                  ],
                                                ),
                                              ),
                                            PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.delete,
                                                      size: 18,
                                                      color: Colors.red),
                                                  SizedBox(width: 8),
                                                  Text("Delete"),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    // IconButton(

                                    //   icon: const Icon(Icons.edit_outlined,

                                    //       color: Colors.blue, size: 20),

                                    //   onPressed: () =>

                                    //       _fetchOrderDetailsAndShowDialog(

                                    //           order),

                                    //   constraints: const BoxConstraints(),

                                    //   padding: EdgeInsets.zero,

                                    // ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.business,
                                  size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  order.supplierName ?? 'Unknown Supplier',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                order.orderDate ?? 'N/A',
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildAmountColumn(
                                  'Estimated',
                                  '₹${order.estimatedAmt ?? '0'}',
                                  Colors.black87),
                              _buildAmountColumn('Advance',
                                  '₹${order.advanceAmt ?? '0'}', Colors.green),
                              _buildAmountColumn(
                                  'Balance',
                                  '₹${order.balanceAmt ?? '0'}',
                                  Colors.redAccent),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildAmountColumn(String label, String amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 10),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    bool isBilled = status.toLowerCase().contains('bill');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isBilled
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: isBilled ? Colors.green : Colors.orange,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _fetchOrderDetailsAndShowDialog(PurchaseOrderData order) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await HttpService.getPurchaseOrderDetails(order.poId!);

      Navigator.pop(context);

      if (response != null &&
          response.status == true &&
          response.data != null) {
        _showOrderDialog(editData: response.data);
      } else {
        Common.toastMessaage(
            response?.message ?? "Failed to fetch order details", Colors.red);
      }
    } catch (e) {
      Navigator.pop(context);

      Common.toastMessaage("Error fetching details: $e", Colors.red);
    }
  }

  void _confirmDelete(PurchaseOrderData order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Order"),
        content:
            Text("Are you sure you want to delete Order ${order.orderId}?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              setState(() => isLoading = true);

              final res = await HttpService.deletePurchaseOrder(order.poId!);

              if (res != null) {
                Common.toastMessaage(
                    "Order deleted successfully", Colors.green);

                _fetchOrders();
              } else {
                setState(() => isLoading = false);

                Common.toastMessaage("Failed to delete order", Colors.red);
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _createBillFromOrder(PurchaseOrderData order) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await HttpService.getPurchaseOrderDetails(order.poId!);

      Navigator.pop(context);

      if (response != null &&
          response.status == true &&
          response.data != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PurchaseBillPage(
              token: widget.token,
              name: widget.name,
              userId: widget.userId,
              createFromOrder: response.data,
            ),
          ),
        );
      } else {
        Common.toastMessaage(
            response?.message ?? "Failed to fetch order details", Colors.red);
      }
    } catch (e) {
      Navigator.pop(context);

      Common.toastMessaage("Error fetching details: $e", Colors.red);
    }
  }

  void _showOrderDialog({
    details.PurchaseOrderData? editData,
    List<PurchaseRequestDetail>? createFromRequestItems,
    String? createFromRequestRemarks,
  }) {
    List<CartItem> cartItems = [];
String? purchaseRequestId;
String? pmrId;
String? alreadyOrderedQty;
String? remainingQty;
String? unitPrice;
String? description;
    DateTime orderDate = DateTime.now();

    DateTime? paidDate = DateTime.now();

    DateTime? deliveryDate;

    DateTime? trRefDate = DateTime.now();

    MaterialData? selectedMaterial;

    Supplier? selectedSupplier;

    String? selectedAccount;

    String? paymentMode = "Cash";

    PlatformFile? orderCopyFile;
    final TextEditingController refNoController = TextEditingController();

    final TextEditingController addressController =
        TextEditingController(
      text: companyAddress,
    );

    final TextEditingController advancePaidController = TextEditingController();

    final TextEditingController trRefNoController = TextEditingController();

    final TextEditingController transRemarkController = TextEditingController();

    final TextEditingController remarksController = TextEditingController();
      List<TermsConditionItem> termsList = [
        TermsConditionItem(),
      ];
    if (editData != null && editData.orderDetails != null) {
      var d = editData.orderDetails!;

      if (d.orderDate != null && d.orderDate!.isNotEmpty) {
        try {
          orderDate = DateFormat('dd-MM-yyyy').parse(d.orderDate!.split(' ')[0]);
        } catch (e) {
          try {
            orderDate = DateFormat('yyyy-MM-dd').parse(d.orderDate!.split(' ')[0]);
          } catch (e) {}
        }
      }

      selectedSupplier = suppliers.any((s) => s.supplierId == d.supplierId)
          ? suppliers.firstWhere((s) => s.supplierId == d.supplierId)
          : null;

      paymentMode = d.paymentMethod ?? "Cash";

      advancePaidController.text = d.advanceAmount ?? "";

      refNoController.text = d.referenceNo ?? d.refNo ?? "";

      addressController.text = d.billingAddress ?? d.address ?? "";

      remarksController.text = d.remarks ?? "";

      if (d.deliveryDate != null && d.deliveryDate!.isNotEmpty) {
        try {
          deliveryDate = DateFormat('dd-MM-yyyy').parse(d.deliveryDate!.split(' ')[0]);
        } catch (e) {
          try {
            deliveryDate = DateFormat('yyyy-MM-dd').parse(d.deliveryDate!.split(' ')[0]);
          } catch (e) {}
        }
      }
    }

    if (editData != null && editData.items != null) {
      cartItems = editData.items!.map((item) {
        return CartItem(
          material: MaterialData(
            materialId: item.materialId,
            materialName: item.materialName,
            unitPrice: item.unitPrice,
          ),
          quantity: double.tryParse(item.quantity ?? "1") ?? 1.0,
          unitPrice: double.tryParse(item.unitPrice ?? "0") ?? 0.0,
        );
      }).toList();
    }

if (createFromRequestItems != null) {
  remarksController.text = createFromRequestRemarks ?? "";

  cartItems = createFromRequestItems.map((item) {
    return CartItem(
      material: MaterialData(
        materialId: item.materialId,
        materialName: item.materialName,
        unitPrice: item.unitPrice,
        unitName: item.unitName,
      ),

      // Quantity to order (default remaining quantity)
      quantity: double.tryParse(item.remainingQty ?? "0") ?? 1.0,

      // Purchase price
      unitPrice: double.tryParse(item.unitPrice ?? "0") ?? 0.0,

      // Description
      description: item.description,

      // Purchase Request Details
      purchaseRequestId: item.purchaseRequestId,
      purchaseRequestItemId: item.pmrId,

      requestedQty: item.quantity,
      alreadyOrderedQty: item.alreadyOrderedQty,
      remainingQty: item.remainingQty,

      // NEW
      taxPercent: item.taxPercent,
      taxAmountValue: item.taxAmount,
    );
  }).toList();
}
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "AddPurchaseOrder",
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
      pageBuilder: (context, anim1, anim2) {
        List<MaterialData> dialogMaterials = [];

        List<ListElement> accountHeads = [];

        bool isFetching = false;

        bool isFetchingAccounts = false;

        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            if (dialogMaterials.isEmpty && !isFetching) {
              isFetching = true;

              HttpService.getMaterials().then((val) {
                if (val != null && val.data != null && dialogContext.mounted) {
                  setDialogState(() {
                    dialogMaterials = val.data!;

                    isFetching = false;
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

            double totalAmount =
                cartItems.fold(0, (sum, item) => sum + item.total);

            return Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.95,
                  height: MediaQuery.of(context).size.height * 0.9,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10))
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 20),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF2a86c9), Color(0xFF1e6399)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12)),
                                child: const Icon(Icons.shopping_cart_checkout,
                                    color: Colors.white, size: 24),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  editData == null
                                      ? "Purchase Order"
                                      : "Edit Purchase Order",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5),
                                ),
                              ),
                              IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.white, size: 26),
                                  onPressed: () {
                                    if (editData != null && cartItems.isEmpty) {
                                      Common.toastMessaage("Please add at least one product before closing", Colors.red);
                                    } else {
                                      Navigator.pop(context);
                                    }
                                  },
                                ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionHeader(
                                    "Order Details", Icons.assignment_outlined),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildGlassCard(
                                        title: "Order No",
                                        value:
                                            "#${DateFormat('HHmmss').format(DateTime.now())}",
                                        icon: Icons.tag,
                                        color: const Color(0xFF2a86c9),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () async {
                                          final picked = await showDatePicker(
                                            context: context,
                                            initialDate: orderDate,
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2100),
                                          );

                                          if (picked != null)
                                            setDialogState(
                                                () => orderDate = picked);
                                        },
                                        child: _buildGlassCard(
                                          title: "Order Date",
                                          value: DateFormat('dd-MM-yyyy')
                                              .format(orderDate),
                                          icon: Icons.calendar_today,
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: _buildInputLabelField(
                                        label: "Supplier Name*",
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            border: Border.all(
                                                color: Colors.grey.shade200),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: DropdownSearch<Supplier>(
                                                  compareFn: (item,
                                                          selectedItem) =>
                                                      item.supplierId ==
                                                      selectedItem?.supplierId,
                                                  selectedItem:
                                                      selectedSupplier,
                                                  items: (f, p) => suppliers,
                                                  itemAsString: (s) =>
                                                      s.supplierName,
                                                  popupProps:
                                                      const PopupProps.menu(
                                                    showSearchBox: true,
                                                    searchFieldProps:
                                                        TextFieldProps(
                                                      decoration:
                                                          InputDecoration(
                                                        hintText:
                                                            "Search supplier...",
                                                        contentPadding:
                                                            EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        16,
                                                                    vertical:
                                                                        12),
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
                                                  decoratorProps:
                                                      DropDownDecoratorProps(
                                                    decoration: InputDecoration(
                                                      contentPadding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                              horizontal: 16,
                                                              vertical: 8),
                                                      border: InputBorder.none,
                                                      hintText: "Select",
                                                    ),
                                                  ),
                                                  onChanged: (val) =>
                                                      setDialogState(() =>
                                                          selectedSupplier =
                                                              val),
                                                ),
                                              ),
                                              Container(
                                                width: 45,
                                                height: 45,
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    left: BorderSide(
                                                        color: Colors
                                                            .grey.shade200,
                                                        width: 1),
                                                  ),
                                                ),
                                                child: IconButton(
                                                  onPressed: () =>
                                                      _showQuickAddSupplierDialog(
                                                    dialogContext,
                                                    onSupplierAdded:
                                                        (newSupplier) {
                                                      setDialogState(() {
                                                        suppliers
                                                            .add(newSupplier);
                                                        selectedSupplier =
                                                            newSupplier;
                                                      });
                                                    },
                                                  ),
                                                  icon: const Icon(
                                                      Icons.add_circle,
                                                      color: Color(0xFF2a86c9),
                                                      size: 24),
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(),
                                                  tooltip: "Add New Supplier",
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Expanded(

                                    //   flex: 2,

                                    //   child: _buildInputLabelField(

                                    //     label: "Supplier Name*",

                                    //     child: Container(

                                    //       decoration: BoxDecoration(

                                    //         color: Colors.white,

                                    //         borderRadius:

                                    //             BorderRadius.circular(15),

                                    //         border: Border.all(

                                    //             color: Colors.grey.shade200),

                                    //       ),

                                    //       child: DropdownSearch<Supplier>(

                                    //         compareFn: (item, selectedItem) =>

                                    //             item.supplierId ==

                                    //             selectedItem?.supplierId,

                                    //         selectedItem: selectedSupplier,

                                    //         items: (f, p) => suppliers,

                                    //         itemAsString: (s) => s.supplierName,

                                    //         decoratorProps: DropDownDecoratorProps(

                                    //           decoration: InputDecoration(

                                    //             contentPadding:

                                    //                 const EdgeInsets.symmetric(

                                    //                     horizontal: 16,

                                    //                     vertical: 8),

                                    //             border: InputBorder.none,

                                    //             hintText: "Select Supplier",

                                    //             suffixIcon: IconButton(

                                    //               onPressed: () => _showQuickAddSupplierDialog(

                                    //                 dialogContext,

                                    //                 onSupplierAdded: (newSupplier) {

                                    //                   setDialogState(() {

                                    //                     suppliers.add(newSupplier);

                                    //                     selectedSupplier = newSupplier;

                                    //                   });

                                    //                 },

                                    //               ),

                                    //               icon: const Icon(Icons.add_circle, color: Color(0xFF2a86c9), size: 24),

                                    //               padding: EdgeInsets.zero,

                                    //               constraints: const BoxConstraints(),

                                    //             ),

                                    //           ),

                                    //         ),

                                    //         onChanged: (val) => setDialogState(

                                    //             () => selectedSupplier = val),

                                    //       ),

                                    //     ),

                                    //   ),

                                    // ),

                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: _buildInputLabelField(
                                        label: "Reference No",
                                        child: TextField(
                                          controller: refNoController,
                                          decoration: _inputDecoration("Ref #"),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 16),

                              _buildFormField(
                                label: "Requested To *",
                                child: _buildClickableField(
                                  locationName ?? "Select Location",
                                  Icons.store_rounded,
                                  () {
                                    if (_locations.isEmpty) {
                                      Common.toastMessaage(
                                        "No locations available",
                                        Colors.red,
                                      );
                                      return;
                                    }

                                    _showItemPicker(
                                      "Location",
                                      _locations.map((e) => e.locationName).toList(),
                                      (index) {
                                        setDialogState(() {
                                          locationId = _locations[index].id;
                                          locationName = _locations[index].locationName;
                                        });
                                      },
                                    );
                                  },
                                ),
                              ),
                              const Divider(height: 40),
                                _buildInputLabelField(
                                  label: "Billing Address*",
                                  child: TextField(
                                    controller: addressController,
                                    maxLines: 2,
                                    decoration: _inputDecoration(
                                        "Enter full billing address..."),
                                  ),
                                ),
                                const Divider(height: 40),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Cart Items",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                          color: const Color(0xFF2a86c9)
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Text("${cartItems.length} Items",
                                          style: const TextStyle(
                                              color: Color(0xFF2a86c9),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                cartItems.isEmpty
                                    ? _buildEmptyCart()
                                    : Column(
                                        children: List.generate(
                                            cartItems.length, (index) {
                                          return _buildCartItemCard(
                                            cartItems[index],

                                            index,

                                            setDialogState,

                                            () {
                                              setDialogState(() {
                                                cartItems[index].dispose();

                                                cartItems.removeAt(index);
                                              });
                                            },

                                            editData, // Pass editData

                                            dialogContext, // Pass dialogContext
                                          );
                                        }),
                                      ),
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                      color: const Color(0xFF2a86c9)
                                          .withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(15)),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Total Estimated Amount",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text("₹${totalAmount.toStringAsFixed(2)}",
                                          style: const TextStyle(
                                              color: Color(0xFF2a86c9),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18)),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                _buildSectionHeader("Add Items to Cart",
                                    Icons.add_shopping_cart_rounded),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(25),
                                    border:
                                        Border.all(color: Colors.grey.shade100),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black.withOpacity(0.03),
                                          blurRadius: 15,
                                          offset: const Offset(0, 5))
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: DropdownSearch<MaterialData>(
                                              compareFn: (i, s) => i?.materialId == s?.materialId,
                                              items: (f, p) => dialogMaterials
                                                  .where((m) => m.materialName?.toLowerCase().contains(f.toLowerCase()) ?? true)
                                                  .toList(),
                                              itemAsString: (m) => m.materialName ?? "",
                                              decoratorProps: const DropDownDecoratorProps(
                                                decoration: InputDecoration(
                                                  hintText: "Search material",
                                                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                                                  prefixIcon: Icon(Icons.inventory_2_outlined),
                                                ),
                                              ),
                                              popupProps: const PopupProps.menu(showSearchBox: true),
                                              onChanged: (val) => setDialogState(() => selectedMaterial = val),
                                              selectedItem: selectedMaterial,
                                            ),
                                          ),
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
                                                    builder: (context) => const SimpleBarcodeScannerPage(),
                                                  ),
                                                );
                                                if (res is String && res != '-1') {
                                                  Common.showProgressDialog(context, "Fetching product...");
                                                  final productRes = await HttpService.getQrcodeproductDetails(res);
                                                  Navigator.pop(context);
                                                  if (productRes != null && productRes.data != null) {
                                                    final productData = productRes.data!;
                                                    setDialogState(() {
                                                      int existingIndex = cartItems.indexWhere((item) => item.material.materialId == productData.id);
                                                      if (existingIndex != -1) {
                                                        cartItems[existingIndex].quantity += 1;
                                                        cartItems[existingIndex].quantityController.text = cartItems[existingIndex].quantity == cartItems[existingIndex].quantity.toInt() ? cartItems[existingIndex].quantity.toInt().toString() : cartItems[existingIndex].quantity.toString();
                                                      } else {
                                                        cartItems.add(CartItem(
                                                          material: MaterialData(
                                                            materialId: productData.id,
                                                            materialName: productData.productName,
                                                            unitName: productData.unitName,
                                                            unitPrice: productData.purchaseAmount ?? productData.sellingPrice,
                                                            gstPercentage: productData.taxPercent,
                                                          ),
                                                          unitPrice: double.tryParse(productData.purchaseAmount ?? productData.sellingPrice ?? "0") ?? 0.0,
                                                        ));
                                                      }
                                                    });
                                                  } else {
                                                    Common.toastMessaage("Product not found", Colors.red);
                                                  }
                                                }
                                              },
                                              icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                                              tooltip: 'Scan Barcode',
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            if (selectedMaterial != null) {
                                              setDialogState(() {
                                                cartItems.add(CartItem(
                                                  material: selectedMaterial!,
                                                  unitPrice: double.tryParse(
                                                          selectedMaterial!
                                                                  .purchasePrice ??
                                                              "0") ??
                                                      0.0,
                                                ));

                                                selectedMaterial = null;
                                              });
                                            }
                                          },
                                          icon: const Icon(Icons.add,
                                              color: Colors.white),
                                          label: const Text("ADD TO CART",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF2a86c9),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 15),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(height: 40),
                                _buildSectionHeader(
                                    "Payment Details", Icons.payments_outlined),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildInputLabelField(
                                        label: "Advance Paid",
                                        child: TextField(
                                          controller: advancePaidController,
                                          keyboardType: TextInputType.number,
                                          decoration:
                                              _inputDecoration("₹ 0.00"),
                                        ),
                                      ),
                                    ),
                                    if (editData == null) ...[
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () async {
                                            final picked = await showDatePicker(
                                                context: context,
                                                initialDate:
                                                    paidDate ?? DateTime.now(),
                                                firstDate: DateTime(2000),
                                                lastDate: DateTime(2100));

                                            if (picked != null)
                                              setDialogState(
                                                  () => paidDate = picked);
                                          },
                                          child: _buildInputLabelField(
                                            label: "Paid Date",
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 12),
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  border: Border.all(
                                                      color: Colors
                                                          .grey.shade200)),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                      Icons.calendar_today,
                                                      size: 16,
                                                      color: Colors.grey),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                      paidDate != null
                                                          ? DateFormat(
                                                                  'dd-MM-yyyy')
                                                              .format(paidDate!)
                                                          : "Select Date",
                                                      style: const TextStyle(
                                                          fontSize: 13)),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                if (editData == null) ...[
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildInputLabelField(
                                          label: "Paid From Account",
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                border: Border.all(
                                                    color:
                                                        Colors.grey.shade200)),
                                            child: DropdownSearch<ListElement>(
                                              compareFn: (i, s) =>
                                                  i.accountId == s?.accountId,
                                              selectedItem: accountHeads.any(
                                                      (a) =>
                                                          a.accountName ==
                                                          selectedAccount)
                                                  ? accountHeads.firstWhere(
                                                      (a) =>
                                                          a.accountName ==
                                                          selectedAccount)
                                                  : null,
                                              items: (f, p) => accountHeads
                                                  .where((a) => a.accountName
                                                      .toLowerCase()
                                                      .contains(
                                                          f.toLowerCase()))
                                                  .toList(),
                                              itemAsString: (a) =>
                                                  a.accountName,
                                              onChanged: (val) =>
                                                  setDialogState(() =>
                                                      selectedAccount =
                                                          val?.accountName),
                                              decoratorProps:
                                                  const DropDownDecoratorProps(
                                                      decoration: InputDecoration(
                                                          contentPadding:
                                                              EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      16,
                                                                  vertical: 8),
                                                          border:
                                                              InputBorder.none,
                                                          hintText: "Select")),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildInputLabelField(
                                          label: "Payment Mode",
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                border: Border.all(
                                                    color:
                                                        Colors.grey.shade200)),
                                            child: DropdownSearch<String>(
                                              compareFn: (i, s) => i == s,
                                              items: (f, p) => [
                                                "Cash",
                                                "Online",
                                                "Credit By Transfer"
                                              ],
                                              onChanged: (val) =>
                                                  setDialogState(
                                                      () => paymentMode = val),
                                              selectedItem: paymentMode,
                                              decoratorProps:
                                                  const DropDownDecoratorProps(
                                                      decoration: InputDecoration(
                                                          contentPadding:
                                                              EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          16,
                                                                      vertical:
                                                                          8),
                                                          border: InputBorder
                                                              .none)),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildInputLabelField(
                                          label: "TR Reference No",
                                          child: TextField(
                                              controller: trRefNoController,
                                              decoration:
                                                  _inputDecoration("TR #")),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () async {
                                            final picked = await showDatePicker(
                                                context: context,
                                                initialDate:
                                                    trRefDate ?? DateTime.now(),
                                                firstDate: DateTime(2000),
                                                lastDate: DateTime(2100));

                                            if (picked != null)
                                              setDialogState(
                                                  () => trRefDate = picked);
                                          },
                                          child: _buildInputLabelField(
                                            label: "TR Ref Date",
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 12),
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  border: Border.all(
                                                      color: Colors
                                                          .grey.shade200)),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                      Icons.calendar_today,
                                                      size: 16,
                                                      color: Colors.grey),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                      trRefDate != null
                                                          ? DateFormat(
                                                                  'dd-MM-yyyy')
                                                              .format(
                                                                  trRefDate!)
                                                          : "Select Date",
                                                      style: const TextStyle(
                                                          fontSize: 13)),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _buildInputLabelField(
                                    label: "Transaction Remark",
                                    child: TextField(
                                        controller: transRemarkController,
                                        decoration: _inputDecoration(
                                            "Enter remark...")),
                                  ),
                                ],
                                const Divider(height: 40),
                                Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () async {
                                          final picked = await showDatePicker(
                                              context: context,
                                              initialDate: deliveryDate ??
                                                  DateTime.now(),
                                              firstDate: DateTime(2000),
                                              lastDate: DateTime(2100));

                                          if (picked != null)
                                            setDialogState(
                                                () => deliveryDate = picked);
                                        },
                                        child: _buildInputLabelField(
                                          label: "Delivery Date",
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 12),
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                border: Border.all(
                                                    color:
                                                        Colors.grey.shade200)),
                                            child: Row(
                                              children: [
                                                const Icon(
                                                    Icons
                                                        .local_shipping_outlined,
                                                    size: 16,
                                                    color: Colors.grey),
                                                const SizedBox(width: 8),
                                                Text(
                                                    deliveryDate != null
                                                        ? DateFormat(
                                                                'dd-MM-yyyy')
                                                            .format(
                                                                deliveryDate!)
                                                        : "Select Date",
                                                    style: const TextStyle(
                                                        fontSize: 13)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildInputLabelField(
                                        label: "Upload Order Copy",
                                        child: InkWell(
                                          onTap: () async {
                                            FilePickerResult? result =
                                                await FilePicker.platform
                                                    .pickFiles();

                                            if (result != null) {
                                              setDialogState(() =>
                                                  orderCopyFile =
                                                      result.files.first);
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 12),
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                border: Border.all(
                                                    color:
                                                        Colors.grey.shade200)),
                                            child: Row(
                                              children: [
                                                Icon(Icons.upload_file,
                                                    size: 16,
                                                    color: orderCopyFile != null
                                                        ? Colors.blue
                                                        : Colors.grey),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                      orderCopyFile != null
                                                          ? orderCopyFile!.name
                                                          : "Choose File",
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          color:
                                                              orderCopyFile !=
                                                                      null
                                                                  ? Colors.black
                                                                  : Colors.grey,
                                                          overflow: TextOverflow
                                                              .ellipsis)),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildInputLabelField(
                                  label: "Remarks/Notes",
                                  child: TextField(
                                    controller: remarksController,
                                    maxLines: 3,
                                    decoration: _inputDecoration(
                                        "Add any additional notes..."),
                                  ),
                                ),
                                const SizedBox(height: 40),

_buildSectionHeader(
  "Terms & Conditions",
  Icons.description_outlined,
),

const SizedBox(height: 15),

Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(15),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 10,
      ),
    ],
  ),
  child: Column(
    children: [

      /// Header
      Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(15),
          ),
        ),
        child: Row(
          children: [

            const SizedBox(
              width: 50,
              child: Text(
                "Sl.",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const Expanded(
              flex: 2,
              child: Text(
                "Title",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(width: 10),

            const Expanded(
              flex: 4,
              child: Text(
                "Description",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            IconButton(
              icon: const Icon(
                Icons.add,
                color: Colors.green,
              ),
              onPressed: () {
                setDialogState(() {
                  termsList.add(
                    TermsConditionItem(),
                  );
                });
              },
            ),
          ],
        ),
      ),

      ...termsList.asMap().entries.map((entry) {

        int index = entry.key;
        TermsConditionItem item = entry.value;

        return Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              SizedBox(
                width: 50,
                child: Center(
                  child: Text(
                    "${index + 1}",
                  ),
                ),
              ),

              Expanded(
                flex: 2,
                child: TextField(
                  controller:
                      item.titleController,
                  decoration:
                      _inputDecoration("Title"),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                flex: 4,
                child: TextField(
                  controller:
                      item.descriptionController,
                  maxLines: 2,
                  decoration:
                      _inputDecoration(
                          "Description"),
                ),
              ),

              IconButton(
                onPressed: () {
                  setDialogState(() {
                    if (termsList.length > 1) {
                      termsList.removeAt(index);
                    }
                  });
                },
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        );
      }),
    ],
  ),
),

const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, -5))
                            ],
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (selectedSupplier == null) {
                                  Common.toastMessaage(
                                      "Please select a supplier", Colors.red);
                                  return;
                                }

                                // if (addressController.text.trim().isEmpty) {
                                //   Common.toastMessaage(
                                //       "Please enter billing address",
                                //       Colors.red);

                                //   return;
                                // }
                                if (locationId == null || locationId!.isEmpty) {
                                  Common.toastMessaage(
                                    "Please select requested location",
                                    Colors.red,
                                  );
                                  return;
                                }
                                if (cartItems.isEmpty) {
                                  Common.toastMessaage(
                                      "Please add at least one item to cart",
                                      Colors.red);

                                  return;
                                }
                                showDialog(
                                  context: dialogContext,
                                  barrierDismissible: false,
                                  builder: (context) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                                try {
                                  Map<String, dynamic> postData = {};
                                  postData['order_date'] =
                                      DateFormat('yyyy-MM-dd')
                                          .format(orderDate);
                                  postData['supplier_id'] =
                                      selectedSupplier!.supplierId;
                                  postData['ref_no'] =
                                      refNoController.text.trim();
                                  postData['location_id'] = locationId;
                                  postData['address'] =
                                      addressController.text.trim();
                                  List<Map<String, dynamic>> itemsList = [];
                                  for (var item in cartItems) {
                                    itemsList.add({
                                      'material_id': item.material.materialId,
                                      'quantity': item.quantity.toString(),
                                      'unit_price': item.unitPrice.toString(),
                                      'total_price': item.total.toString(),
                                    });
                                  }

                                  postData['items'] = itemsList;

                                  double advancePaid = double.tryParse(
                                          advancePaidController.text.trim()) ??
                                      0;

                                  postData['advance_paid'] =
                                      advancePaid.toString();

                                  postData['paid_date'] = paidDate != null
                                      ? DateFormat('yyyy-MM-dd')
                                          .format(paidDate!)
                                      : '';

                                  postData['paid_from_account'] =
                                      selectedAccount ?? '';

                                  postData['payment_mode'] = paymentMode ?? '';

                                  postData['tr_ref_no'] =
                                      trRefNoController.text.trim();

                                  postData['tr_ref_date'] = trRefDate != null
                                      ? DateFormat('yyyy-MM-dd')
                                          .format(trRefDate!)
                                      : '';

                                  postData['transaction_remark'] =
                                      transRemarkController.text.trim();

                                  postData['delivery_date'] =
                                      deliveryDate != null
                                          ? DateFormat('yyyy-MM-dd')
                                              .format(deliveryDate!)
                                          : '';

                                  postData['remarks'] =
                                      remarksController.text.trim();

                                  if (orderCopyFile != null &&
                                      orderCopyFile!.path != null) {
                                    postData['order_copy'] =
                                        await dio.MultipartFile.fromFile(
                                      orderCopyFile!.path!,
                                      filename: orderCopyFile!.name,
                                    );
                                  }

                                  double totalAmount = cartItems.fold(
                                      0, (sum, item) => sum + item.total);

                                  postData['total_estimated_amt'] =
                                      totalAmount.toString();

                                  postData['user_id'] = widget.userId;

                                  postData['created_by'] = widget.name;

                                  dynamic response;

                                  if (editData != null) {
                                    postData['purchase_order_id'] =
                                        editData.orderDetails!.purchaseOrderId;

                                    response =
                                        await HttpService.updatePurchaseOrder(
                                            postData);
                                  } else {
                                    response =
                                        await HttpService.postPurchaseOrder(
                                            postData);
                                  }

                                  Navigator.pop(dialogContext);

                                  if (response != null &&
                                      response['status'] == true) {
                                    Common.toastMessaage(
                                      response['message'] ??
                                          (editData == null
                                              ? "Purchase Order Submitted Successfully"
                                              : "Purchase Order Updated Successfully"),
                                      Colors.green,
                                    );

                                    Navigator.pop(dialogContext);

                                    _fetchOrders();
                                  } else {
                                    Common.toastMessaage(
                                      response?['message'] ??
                                          "Failed to process purchase order",
                                      Colors.red,
                                    );
                                  }
                                } catch (e) {
                                  Navigator.pop(dialogContext);

                                  Common.toastMessaage(
                                      "Error: ${e.toString()}", Colors.red);

                                  print("Error posting purchase order: $e");
                                }
                              },
                              
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2a86c9),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18)),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.send_rounded,
                                      color: Colors.white, size: 20),
                                  SizedBox(width: 12),
                                  Text(
                                      editData == null
                                          ? "SUBMIT ORDER"
                                          : "UPDATE ORDER",
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          letterSpacing: 1.2)),
                                ],
                              ),
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

  // void _showOrderDialog({details.PurchaseOrderData? editData}) {

  //   List<CartItem> cartItems = [];

  //   DateTime orderDate = DateTime.now();

  //   DateTime? paidDate = DateTime.now();

  //   DateTime? deliveryDate;

  //   DateTime? trRefDate = DateTime.now();

  //   MaterialData? selectedMaterial;

  //   Supplier? selectedSupplier;

  //   String? selectedAccount;

  //   String? paymentMode = "Cash";

  //   PlatformFile? orderCopyFile;

  //   final TextEditingController refNoController = TextEditingController();

  //   final TextEditingController addressController = TextEditingController();

  //   final TextEditingController advancePaidController = TextEditingController();

  //   final TextEditingController trRefNoController = TextEditingController();

  //   final TextEditingController transRemarkController = TextEditingController();

  //   final TextEditingController remarksController = TextEditingController();

  //   if (editData != null && editData.orderDetails != null) {

  //     var d = editData.orderDetails!;

  //     try {

  //       orderDate = DateFormat('yyyy-MM-dd').parse(d.orderDate!);

  //     } catch (e) {}

  //     selectedSupplier = suppliers.any((s) => s.supplierId == d.supplierId)

  //         ? suppliers.firstWhere((s) => s.supplierId == d.supplierId)

  //         : null;

  //     paymentMode = d.paymentMethod ?? "Cash";

  //     advancePaidController.text = d.advanceAmount ?? "";

  //     refNoController.text = d.referenceNo ?? d.refNo ?? "";

  //     addressController.text = d.billingAddress ?? d.address ?? "";

  //     remarksController.text = d.remarks ?? "";

  //     if (d.deliveryDate != null && d.deliveryDate!.isNotEmpty) {

  //       try {

  //         deliveryDate = DateFormat('yyyy-MM-dd').parse(d.deliveryDate!);

  //       } catch (e) {}

  //     }

  //   }

  //   if (editData != null && editData.items != null) {

  //     cartItems = editData.items!.map((item) {

  //       return CartItem(

  //         material: MaterialData(

  //           materialId: item.materialId,

  //           materialName: item.materialName,

  //           unitPrice: item.unitPrice,

  //         ),

  //         quantity: double.tryParse(item.quantity ?? "1") ?? 1.0,

  //         unitPrice: double.tryParse(item.unitPrice ?? "0") ?? 0.0,

  //       );

  //     }).toList();

  //   }

  //   showGeneralDialog(

  //     context: context,

  //     barrierDismissible: true,

  //     barrierLabel: "AddPurchaseOrder",

  //     barrierColor: Colors.black.withOpacity(0.6),

  //     transitionDuration: const Duration(milliseconds: 400),

  //     transitionBuilder: (context, anim1, anim2, child) {

  //       return FadeTransition(

  //         opacity: anim1,

  //         child: ScaleTransition(

  //           scale: Tween<double>(begin: 0.95, end: 1.0).animate(

  //             CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),

  //           ),

  //           child: child,

  //         ),

  //       );

  //     },

  //     pageBuilder: (context, anim1, anim2) {

  //       List<MaterialData> dialogMaterials = [];

  //       List<ListElement> accountHeads = [];

  //       bool isFetching = false;

  //       bool isFetchingAccounts = false;

  //       return StatefulBuilder(

  //         builder: (dialogContext, setDialogState) {

  //           if (dialogMaterials.isEmpty && !isFetching) {

  //             isFetching = true;

  //             HttpService.getMaterials().then((val) {

  //               if (val != null && val.data != null && dialogContext.mounted) {

  //                 setDialogState(() {

  //                   dialogMaterials = val.data!;

  //                   isFetching = false;

  //                 });

  //               }

  //             });

  //           }

  //           if (accountHeads.isEmpty && !isFetchingAccounts) {

  //             isFetchingAccounts = true;

  //             HttpService.getAccountHead().then((val) {

  //               if (val != null && val.data != null && dialogContext.mounted) {

  //                 setDialogState(() {

  //                   accountHeads = val.data!.lists;

  //                   isFetchingAccounts = false;

  //                 });

  //               }

  //             });

  //           }

  //           double totalAmount =

  //               cartItems.fold(0, (sum, item) => sum + item.total);

  //           return Scaffold(

  //             backgroundColor: Colors.transparent,

  //             body: Center(

  //               child: Container(

  //                 width: MediaQuery.of(context).size.width * 0.95,

  //                 height: MediaQuery.of(context).size.height * 0.9,

  //                 decoration: BoxDecoration(

  //                   color: const Color(0xFFF8FAFC),

  //                   borderRadius: BorderRadius.circular(30),

  //                   boxShadow: [

  //                     BoxShadow(

  //                         color: Colors.black.withOpacity(0.2),

  //                         blurRadius: 20,

  //                         offset: const Offset(0, 10))

  //                   ],

  //                 ),

  //                 child: ClipRRect(

  //                   borderRadius: BorderRadius.circular(30),

  //                   child: Column(

  //                     children: [

  //                       Container(

  //                         padding: const EdgeInsets.symmetric(

  //                             horizontal: 24, vertical: 20),

  //                         decoration: const BoxDecoration(

  //                           gradient: LinearGradient(

  //                             colors: [Color(0xFF2a86c9), Color(0xFF1e6399)],

  //                             begin: Alignment.topLeft,

  //                             end: Alignment.bottomRight,

  //                           ),

  //                         ),

  //                         child: Row(

  //                           children: [

  //                             Container(

  //                               padding: const EdgeInsets.all(8),

  //                               decoration: BoxDecoration(

  //                                   color: Colors.white.withOpacity(0.2),

  //                                   borderRadius: BorderRadius.circular(12)),

  //                               child: const Icon(Icons.shopping_cart_checkout,

  //                                   color: Colors.white, size: 24),

  //                             ),

  //                             const SizedBox(width: 16),

  //                             Expanded(

  //                               child: Text(

  //                                 editData == null

  //                                     ? "Purchase Order"

  //                                     : "Edit Purchase Order",

  //                                 style: const TextStyle(

  //                                     color: Colors.white,

  //                                     fontSize: 20,

  //                                     fontWeight: FontWeight.bold,

  //                                     letterSpacing: 0.5),

  //                               ),

  //                             ),

  //                             IconButton(

  //                               icon: const Icon(Icons.close,

  //                                   color: Colors.white, size: 26),

  //                               onPressed: () => Navigator.pop(context),

  //                             ),

  //                           ],

  //                         ),

  //                       ),

  //                       Expanded(

  //                         child: SingleChildScrollView(

  //                           padding: const EdgeInsets.all(24),

  //                           child: Column(

  //                             crossAxisAlignment: CrossAxisAlignment.start,

  //                             children: [

  //                               _buildSectionHeader(

  //                                   "Order Details", Icons.assignment_outlined),

  //                               const SizedBox(height: 16),

  //                               Row(

  //                                 children: [

  //                                   Expanded(

  //                                     child: _buildGlassCard(

  //                                       title: "Order No",

  //                                       value:

  //                                           "#${DateFormat('HHmmss').format(DateTime.now())}",

  //                                       icon: Icons.tag,

  //                                       color: const Color(0xFF2a86c9),

  //                                     ),

  //                                   ),

  //                                   const SizedBox(width: 12),

  //                                   Expanded(

  //                                     child: InkWell(

  //                                       onTap: () async {

  //                                         final picked = await showDatePicker(

  //                                           context: context,

  //                                           initialDate: orderDate,

  //                                           firstDate: DateTime(2000),

  //                                           lastDate: DateTime(2100),

  //                                         );

  //                                         if (picked != null)

  //                                           setDialogState(

  //                                               () => orderDate = picked);

  //                                       },

  //                                       child: _buildGlassCard(

  //                                         title: "Order Date",

  //                                         value: DateFormat('dd-MM-yyyy')

  //                                             .format(orderDate),

  //                                         icon: Icons.calendar_today,

  //                                         color: Colors.orange,

  //                                       ),

  //                                     ),

  //                                   ),

  //                                 ],

  //                               ),

  //                               const SizedBox(height: 20),

  //                               Row(

  //                                 children: [

  //                                   Expanded(

  //                                     flex: 2,

  //                                     child: _buildInputLabelField(

  //                                       label: "Supplier Name*",

  //                                       child: Container(

  //                                         decoration: BoxDecoration(

  //                                           color: Colors.white,

  //                                           borderRadius:

  //                                               BorderRadius.circular(15),

  //                                           border: Border.all(

  //                                               color: Colors.grey.shade200),

  //                                         ),

  //                                           child: DropdownSearch<Supplier>(

  //                                           compareFn: (item, selectedItem) =>

  //                                               item.supplierId ==

  //                                               selectedItem?.supplierId,

  //                                           selectedItem: selectedSupplier,

  //                                           items: (f, p) => suppliers,

  //                                           itemAsString: (s) => s.supplierName,

  //                                           decoratorProps:

  //                                               const DropDownDecoratorProps(

  //                                             decoration: InputDecoration(

  //                                               contentPadding:

  //                                                   EdgeInsets.symmetric(

  //                                                       horizontal: 16,

  //                                                       vertical: 8),

  //                                               border: InputBorder.none,

  //                                               hintText: "Select Supplier",

  //                                             ),

  //                                           ),

  //                                           onChanged: (val) => setDialogState(

  //                                               () => selectedSupplier = val),

  //                                         ),

  //                                       ),

  //                                     ),

  //                                   ),

  //                                   const SizedBox(width: 12),

  //                                   Expanded(

  //                                     child: _buildInputLabelField(

  //                                       label: "Reference No",

  //                                       child: TextField(

  //                                         controller: refNoController,

  //                                         decoration: _inputDecoration("Ref #"),

  //                                       ),

  //                                     ),

  //                                   ),

  //                                 ],

  //                               ),

  //                               const SizedBox(height: 16),

  //                               _buildInputLabelField(

  //                                 label: "Billing Address*",

  //                                 child: TextField(

  //                                   controller: addressController,

  //                                   maxLines: 2,

  //                                   decoration: _inputDecoration(

  //                                       "Enter full billing address..."),

  //                                 ),

  //                               ),

  //                               const Divider(height: 40),

  //                               _buildSectionHeader("Add Items to Cart",

  //                                   Icons.add_shopping_cart_rounded),

  //                               const SizedBox(height: 16),

  //                               Container(

  //                                 padding: const EdgeInsets.all(20),

  //                                 decoration: BoxDecoration(

  //                                   color: Colors.white,

  //                                   borderRadius: BorderRadius.circular(25),

  //                                   border:

  //                                       Border.all(color: Colors.grey.shade100),

  //                                   boxShadow: [

  //                                     BoxShadow(

  //                                         color: Colors.black.withOpacity(0.03),

  //                                         blurRadius: 15,

  //                                         offset: const Offset(0, 5))

  //                                   ],

  //                                 ),

  //                                 child: Column(

  //                                   children: [

  //                                     DropdownSearch<MaterialData>(

  //                                       compareFn: (i, s) =>

  //                                           i?.materialId == s?.materialId,

  //                                       items: (f, p) => dialogMaterials

  //                                           .where((m) =>

  //                                               m.materialName

  //                                                   ?.toLowerCase()

  //                                                   .contains(

  //                                                       f.toLowerCase()) ??

  //                                               true)

  //                                           .toList(),

  //                                       itemAsString: (m) =>

  //                                           m.materialName ?? "",

  //                                       decoratorProps:

  //                                           const DropDownDecoratorProps(

  //                                         decoration: InputDecoration(

  //                                           hintText: "Search material",

  //                                           border: OutlineInputBorder(

  //                                               borderRadius: BorderRadius.all(

  //                                                   Radius.circular(15))),

  //                                           prefixIcon: Icon(

  //                                               Icons.inventory_2_outlined),

  //                                         ),

  //                                       ),

  //                                       popupProps: const PopupProps.menu(

  //                                           showSearchBox: true),

  //                                       onChanged: (val) => setDialogState(

  //                                           () => selectedMaterial = val),

  //                                     ),

  //                                     const SizedBox(height: 16),

  //                                     SizedBox(

  //                                       width: double.infinity,

  //                                       child: ElevatedButton.icon(

  //                                         onPressed: () {

  //                                           if (selectedMaterial != null) {

  //                                             setDialogState(() {

  //                                               cartItems.add(CartItem(

  //                                                 material: selectedMaterial!,

  //                                                 unitPrice: double.tryParse(

  //                                                         selectedMaterial!

  //                                                                 .unitPrice ??

  //                                                             "0") ??

  //                                                     0.0,

  //                                               ));

  //                                               selectedMaterial = null;

  //                                             });

  //                                           }

  //                                         },

  //                                         icon: const Icon(Icons.add,

  //                                             color: Colors.white),

  //                                         label: const Text("ADD TO CART",

  //                                             style: TextStyle(

  //                                                 color: Colors.white,

  //                                                 fontWeight: FontWeight.bold)),

  //                                         style: ElevatedButton.styleFrom(

  //                                           backgroundColor:

  //                                               const Color(0xFF2a86c9),

  //                                           padding: const EdgeInsets.symmetric(

  //                                               vertical: 15),

  //                                           shape: RoundedRectangleBorder(

  //                                               borderRadius:

  //                                                   BorderRadius.circular(15)),

  //                                         ),

  //                                       ),

  //                                     ),

  //                                   ],

  //                                 ),

  //                               ),

  //                               const SizedBox(height: 24),

  //                               Row(

  //                                 mainAxisAlignment:

  //                                     MainAxisAlignment.spaceBetween,

  //                                 children: [

  //                                   const Text("Cart Items",

  //                                       style: TextStyle(

  //                                           fontSize: 16,

  //                                           fontWeight: FontWeight.bold)),

  //                                   Container(

  //                                     padding: const EdgeInsets.symmetric(

  //                                         horizontal: 12, vertical: 4),

  //                                     decoration: BoxDecoration(

  //                                         color: const Color(0xFF2a86c9)

  //                                             .withOpacity(0.1),

  //                                         borderRadius:

  //                                             BorderRadius.circular(20)),

  //                                     child: Text("${cartItems.length} Items",

  //                                         style: const TextStyle(

  //                                             color: Color(0xFF2a86c9),

  //                                             fontWeight: FontWeight.bold,

  //                                             fontSize: 12)),

  //                                   ),

  //                                 ],

  //                               ),

  //                               const SizedBox(height: 12),

  //                               cartItems.isEmpty

  //                                   ? _buildEmptyCart()

  //                                   : Column(

  //                                       children: List.generate(

  //                                           cartItems.length, (index) {

  //                                         return _buildCartItemCard(

  //                                             cartItems[index],

  //                                             index,

  //                                             setDialogState, () {

  //                                           setDialogState(() {

  //                                             cartItems[index].dispose();

  //                                             cartItems.removeAt(index);

  //                                           });

  //                                         });

  //                                       }),

  //                                     ),

  //                               const SizedBox(height: 20),

  //                               Container(

  //                                 padding: const EdgeInsets.all(16),

  //                                 decoration: BoxDecoration(

  //                                     color: const Color(0xFF2a86c9)

  //                                         .withOpacity(0.05),

  //                                     borderRadius: BorderRadius.circular(15)),

  //                                 child: Row(

  //                                   mainAxisAlignment:

  //                                       MainAxisAlignment.spaceBetween,

  //                                   children: [

  //                                     const Text("Total Estimated Amount",

  //                                         style: TextStyle(

  //                                             fontWeight: FontWeight.bold)),

  //                                     Text("₹${totalAmount.toStringAsFixed(2)}",

  //                                         style: const TextStyle(

  //                                             color: Color(0xFF2a86c9),

  //                                             fontWeight: FontWeight.bold,

  //                                             fontSize: 18)),

  //                                   ],

  //                                 ),

  //                               ),

  //                               const Divider(height: 40),

  //                               _buildSectionHeader(

  //                                   "Payment Details", Icons.payments_outlined),

  //                               const SizedBox(height: 16),

  //                               Row(

  //                                 children: [

  //                                   Expanded(

  //                                     child: _buildInputLabelField(

  //                                       label: "Advance Paid",

  //                                       child: TextField(

  //                                         controller: advancePaidController,

  //                                         keyboardType: TextInputType.number,

  //                                         decoration:

  //                                             _inputDecoration("₹ 0.00"),

  //                                       ),

  //                                     ),

  //                                   ),

  //                                   if (editData == null) ...[

  //                                     const SizedBox(width: 12),

  //                                     Expanded(

  //                                       child: InkWell(

  //                                         onTap: () async {

  //                                           final picked = await showDatePicker(

  //                                               context: context,

  //                                               initialDate:

  //                                                   paidDate ?? DateTime.now(),

  //                                               firstDate: DateTime(2000),

  //                                               lastDate: DateTime(2100));

  //                                           if (picked != null)

  //                                             setDialogState(

  //                                                 () => paidDate = picked);

  //                                         },

  //                                         child: _buildInputLabelField(

  //                                           label: "Paid Date",

  //                                           child: Container(

  //                                             padding: const EdgeInsets.symmetric(

  //                                                 horizontal: 16, vertical: 12),

  //                                             decoration: BoxDecoration(

  //                                                 color: Colors.white,

  //                                                 borderRadius:

  //                                                     BorderRadius.circular(15),

  //                                                 border: Border.all(

  //                                                     color:

  //                                                         Colors.grey.shade200)),

  //                                             child: Row(

  //                                               children: [

  //                                                 const Icon(Icons.calendar_today,

  //                                                     size: 16,

  //                                                     color: Colors.grey),

  //                                                 const SizedBox(width: 8),

  //                                                 Text(

  //                                                     paidDate != null

  //                                                         ? DateFormat(

  //                                                                 'dd-MM-yyyy')

  //                                                             .format(paidDate!)

  //                                                         : "Select Date",

  //                                                     style: const TextStyle(

  //                                                         fontSize: 13)),

  //                                               ],

  //                                             ),

  //                                           ),

  //                                         ),

  //                                       ),

  //                                     ),

  //                                   ],

  //                                 ],

  //                               ),

  //                               if (editData == null) ...[

  //                                 const SizedBox(height: 16),

  //                                 Row(

  //                                   children: [

  //                                     Expanded(

  //                                       child: _buildInputLabelField(

  //                                         label: "Paid From Account",

  //                                         child: Container(

  //                                           decoration: BoxDecoration(

  //                                               color: Colors.white,

  //                                               borderRadius:

  //                                                   BorderRadius.circular(15),

  //                                               border: Border.all(

  //                                                   color: Colors.grey.shade200)),

  //                                           child: DropdownSearch<ListElement>(

  //                                             compareFn: (i, s) =>

  //                                                 i.accountId == s?.accountId,

  //                                             selectedItem: accountHeads.any((a) =>

  //                                                     a.accountName ==

  //                                                     selectedAccount)

  //                                                 ? accountHeads.firstWhere((a) =>

  //                                                     a.accountName ==

  //                                                     selectedAccount)

  //                                                 : null,

  //                                             items: (f, p) => accountHeads

  //                                                 .where((a) => a.accountName

  //                                                     .toLowerCase()

  //                                                     .contains(f.toLowerCase()))

  //                                                 .toList(),

  //                                             itemAsString: (a) => a.accountName,

  //                                             onChanged: (val) => setDialogState(

  //                                                 () => selectedAccount =

  //                                                     val?.accountName),

  //                                             decoratorProps:

  //                                                 const DropDownDecoratorProps(

  //                                                     decoration: InputDecoration(

  //                                                         contentPadding:

  //                                                             EdgeInsets

  //                                                                 .symmetric(

  //                                                                     horizontal:

  //                                                                         16,

  //                                                                     vertical:

  //                                                                         8),

  //                                                         border:

  //                                                             InputBorder.none,

  //                                                         hintText: "Select")),

  //                                           ),

  //                                         ),

  //                                       ),

  //                                     ),

  //                                     const SizedBox(width: 12),

  //                                     Expanded(

  //                                       child: _buildInputLabelField(

  //                                         label: "Payment Mode",

  //                                         child: Container(

  //                                           decoration: BoxDecoration(

  //                                               color: Colors.white,

  //                                               borderRadius:

  //                                                   BorderRadius.circular(15),

  //                                               border: Border.all(

  //                                                   color: Colors.grey.shade200)),

  //                                           child: DropdownSearch<String>(

  //                                             compareFn: (i, s) => i == s,

  //                                             items: (f, p) => [

  //                                               "Cash",

  //                                               "Online",

  //                                               "Credit By Transfer"

  //                                             ],

  //                                             onChanged: (val) => setDialogState(

  //                                                 () => paymentMode = val),

  //                                             selectedItem: paymentMode,

  //                                             decoratorProps:

  //                                                 const DropDownDecoratorProps(

  //                                                     decoration: InputDecoration(

  //                                                         contentPadding:

  //                                                             EdgeInsets

  //                                                                 .symmetric(

  //                                                                     horizontal:

  //                                                                         16,

  //                                                                     vertical:

  //                                                                         8),

  //                                                         border:

  //                                                             InputBorder.none)),

  //                                           ),

  //                                         ),

  //                                       ),

  //                                     ),

  //                                   ],

  //                                 ),

  //                                 const SizedBox(height: 16),

  //                                 Row(

  //                                   children: [

  //                                     Expanded(

  //                                       child: _buildInputLabelField(

  //                                         label: "TR Reference No",

  //                                         child: TextField(

  //                                             controller: trRefNoController,

  //                                             decoration:

  //                                                 _inputDecoration("TR #")),

  //                                       ),

  //                                     ),

  //                                     const SizedBox(width: 12),

  //                                     Expanded(

  //                                       child: InkWell(

  //                                         onTap: () async {

  //                                           final picked = await showDatePicker(

  //                                               context: context,

  //                                               initialDate:

  //                                                   trRefDate ?? DateTime.now(),

  //                                               firstDate: DateTime(2000),

  //                                               lastDate: DateTime(2100));

  //                                           if (picked != null)

  //                                             setDialogState(

  //                                                 () => trRefDate = picked);

  //                                         },

  //                                         child: _buildInputLabelField(

  //                                           label: "TR Ref Date",

  //                                           child: Container(

  //                                             padding: const EdgeInsets.symmetric(

  //                                                 horizontal: 16, vertical: 12),

  //                                             decoration: BoxDecoration(

  //                                                 color: Colors.white,

  //                                                 borderRadius:

  //                                                     BorderRadius.circular(15),

  //                                                 border: Border.all(

  //                                                     color:

  //                                                         Colors.grey.shade200)),

  //                                             child: Row(

  //                                               children: [

  //                                                 const Icon(Icons.calendar_today,

  //                                                     size: 16,

  //                                                     color: Colors.grey),

  //                                                 const SizedBox(width: 8),

  //                                                 Text(

  //                                                     trRefDate != null

  //                                                         ? DateFormat(

  //                                                                 'dd-MM-yyyy')

  //                                                             .format(trRefDate!)

  //                                                         : "Select Date",

  //                                                     style: const TextStyle(

  //                                                         fontSize: 13)),

  //                                               ],

  //                                             ),

  //                                           ),

  //                                         ),

  //                                       ),

  //                                     ),

  //                                   ],

  //                                 ),

  //                                 const SizedBox(height: 16),

  //                                 _buildInputLabelField(

  //                                   label: "Transaction Remark",

  //                                   child: TextField(

  //                                       controller: transRemarkController,

  //                                       decoration:

  //                                           _inputDecoration("Enter remark...")),

  //                                 ),

  //                               ],

  //                               const Divider(height: 40),

  //                               Row(

  //                                 children: [

  //                                   Expanded(

  //                                     child: InkWell(

  //                                       onTap: () async {

  //                                         final picked = await showDatePicker(

  //                                             context: context,

  //                                             initialDate: deliveryDate ??

  //                                                 DateTime.now(),

  //                                             firstDate: DateTime(2000),

  //                                             lastDate: DateTime(2100));

  //                                         if (picked != null)

  //                                           setDialogState(

  //                                               () => deliveryDate = picked);

  //                                       },

  //                                       child: _buildInputLabelField(

  //                                         label: "Delivery Date",

  //                                         child: Container(

  //                                           padding: const EdgeInsets.symmetric(

  //                                               horizontal: 16, vertical: 12),

  //                                           decoration: BoxDecoration(

  //                                               color: Colors.white,

  //                                               borderRadius:

  //                                                   BorderRadius.circular(15),

  //                                               border: Border.all(

  //                                                   color:

  //                                                       Colors.grey.shade200)),

  //                                           child: Row(

  //                                             children: [

  //                                               const Icon(

  //                                                   Icons

  //                                                       .local_shipping_outlined,

  //                                                   size: 16,

  //                                                   color: Colors.grey),

  //                                               const SizedBox(width: 8),

  //                                               Text(

  //                                                   deliveryDate != null

  //                                                       ? DateFormat(

  //                                                               'dd-MM-yyyy')

  //                                                           .format(

  //                                                               deliveryDate!)

  //                                                       : "Select Date",

  //                                                   style: const TextStyle(

  //                                                       fontSize: 13)),

  //                                             ],

  //                                           ),

  //                                         ),

  //                                       ),

  //                                     ),

  //                                   ),

  //                                   const SizedBox(width: 12),

  //                                   Expanded(

  //                                     child: _buildInputLabelField(

  //                                       label: "Upload Order Copy",

  //                                       child: InkWell(

  //                                         onTap: () async {

  //                                           FilePickerResult? result =

  //                                               await FilePicker.platform

  //                                                   .pickFiles();

  //                                           if (result != null) {

  //                                             setDialogState(() =>

  //                                                 orderCopyFile =

  //                                                     result.files.first);

  //                                           }

  //                                         },

  //                                         child: Container(

  //                                           padding: const EdgeInsets.symmetric(

  //                                               horizontal: 16, vertical: 12),

  //                                           decoration: BoxDecoration(

  //                                               color: Colors.white,

  //                                               borderRadius:

  //                                                   BorderRadius.circular(15),

  //                                               border: Border.all(

  //                                                   color:

  //                                                       Colors.grey.shade200)),

  //                                           child: Row(

  //                                             children: [

  //                                               Icon(Icons.upload_file,

  //                                                   size: 16,

  //                                                   color: orderCopyFile != null

  //                                                       ? Colors.blue

  //                                                       : Colors.grey),

  //                                               const SizedBox(width: 8),

  //                                               Expanded(

  //                                                 child: Text(

  //                                                     orderCopyFile != null

  //                                                         ? orderCopyFile!.name

  //                                                         : "Choose File",

  //                                                     style: TextStyle(

  //                                                         fontSize: 13,

  //                                                         color: orderCopyFile !=

  //                                                                 null

  //                                                             ? Colors.black

  //                                                             : Colors.grey,

  //                                                         overflow: TextOverflow

  //                                                             .ellipsis)),

  //                                               ),

  //                                             ],

  //                                           ),

  //                                         ),

  //                                       ),

  //                                     ),

  //                                   ),

  //                                 ],

  //                               ),

  //                               const SizedBox(height: 16),

  //                               _buildInputLabelField(

  //                                 label: "Remarks/Notes",

  //                                 child: TextField(

  //                                   controller: remarksController,

  //                                   maxLines: 3,

  //                                   decoration: _inputDecoration(

  //                                       "Add any additional notes..."),

  //                                 ),

  //                               ),

  //                               const SizedBox(height: 40),

  //                             ],

  //                           ),

  //                         ),

  //                       ),

  //                       Container(

  //                         padding: const EdgeInsets.all(24),

  //                         decoration: BoxDecoration(

  //                           color: Colors.white,

  //                           boxShadow: [

  //                             BoxShadow(

  //                                 color: Colors.black.withOpacity(0.05),

  //                                 blurRadius: 10,

  //                                 offset: const Offset(0, -5))

  //                           ],

  //                         ),

  //                         child: SizedBox(

  //                           width: double.infinity,

  //                           child: ElevatedButton(

  //                         onPressed: () async {

  //                           if (selectedSupplier == null) {

  //                             Common.toastMessaage("Please select a supplier", Colors.red);

  //                             return;

  //                           }

  //                           if (addressController.text.trim().isEmpty) {

  //                             Common.toastMessaage("Please enter billing address", Colors.red);

  //                             return;

  //                           }

  //                           if (cartItems.isEmpty) {

  //                             Common.toastMessaage("Please add at least one item to cart", Colors.red);

  //                             return;

  //                           }

  //                           showDialog(

  //                             context: dialogContext,

  //                             barrierDismissible: false,

  //                             builder: (context) => const Center(

  //                               child: CircularProgressIndicator(),

  //                             ),

  //                           );

  //                           try {

  //                             Map<String, dynamic> postData = {};

  //                             postData['order_date'] = DateFormat('yyyy-MM-dd').format(orderDate);

  //                             postData['supplier_id'] = selectedSupplier!.supplierId;

  //                             postData['ref_no'] = refNoController.text.trim();

  //                             postData['address'] = addressController.text.trim();

  //                             List<Map<String, dynamic>> itemsList = [];

  //                             for (var item in cartItems) {

  //                               itemsList.add({

  //                                 'material_id': item.material.materialId,

  //                                 'quantity': item.quantity.toString(),

  //                                 'unit_price': item.unitPrice.toString(),

  //                                 'total_price': item.total.toString(),

  //                               });

  //                             }

  //                             postData['items'] = itemsList;

  //                             double advancePaid = double.tryParse(advancePaidController.text.trim()) ?? 0;

  //                             postData['advance_paid'] = advancePaid.toString();

  //                             postData['paid_date'] = paidDate != null ? DateFormat('yyyy-MM-dd').format(paidDate!) : '';

  //                             postData['paid_from_account'] = selectedAccount ?? '';

  //                             postData['payment_mode'] = paymentMode ?? '';

  //                             postData['tr_ref_no'] = trRefNoController.text.trim();

  //                             postData['tr_ref_date'] = trRefDate != null ? DateFormat('yyyy-MM-dd').format(trRefDate!) : '';

  //                             postData['transaction_remark'] = transRemarkController.text.trim();

  //                             postData['delivery_date'] = deliveryDate != null ? DateFormat('yyyy-MM-dd').format(deliveryDate!) : '';

  //                             postData['remarks'] = remarksController.text.trim();

  //                             if (orderCopyFile != null && orderCopyFile!.path != null) {

  //                               postData['order_copy'] = await dio.MultipartFile.fromFile(

  //                                 orderCopyFile!.path!,

  //                                 filename: orderCopyFile!.name,

  //                               );

  //                             }

  //                             double totalAmount = cartItems.fold(0, (sum, item) => sum + item.total);

  //                             postData['total_estimated_amt'] = totalAmount.toString();

  //                             postData['user_id'] = widget.userId;

  //                             postData['created_by'] = widget.name;

  //                             dynamic response;

  //                             if (editData != null) {

  //                               postData['purchase_order_id'] =

  //                                   editData.orderDetails!.purchaseOrderId;

  //                               response = await HttpService.updatePurchaseOrder(

  //                                   postData);

  //                             } else {

  //                               response =

  //                                   await HttpService.postPurchaseOrder(postData);

  //                             }

  //                             Navigator.pop(dialogContext);

  //                             if (response != null && response['status'] == true) {

  //                               Common.toastMessaage(

  //                                 response['message'] ??

  //                                     (editData == null

  //                                         ? "Purchase Order Submitted Successfully"

  //                                         : "Purchase Order Updated Successfully"),

  //                                 Colors.green,

  //                               );

  //                               Navigator.pop(dialogContext);

  //                               _fetchOrders();

  //                             } else {

  //                               Common.toastMessaage(

  //                                 response?['message'] ??

  //                                     "Failed to process purchase order",

  //                                 Colors.red,

  //                               );

  //                             }

  //                           } catch (e) {

  //                             Navigator.pop(dialogContext);

  //                             Common.toastMessaage("Error: ${e.toString()}", Colors.red);

  //                             print("Error posting purchase order: $e");

  //                           }

  //                         },

  //                             // onPressed: () {

  //                             //   Common.toastMessaage(

  //                             //       "Purchase Order Submitted", Colors.green);

  //                             //   Navigator.pop(context);

  //                             //   _fetchOrders();

  //                             // },

  //                             style: ElevatedButton.styleFrom(

  //                               backgroundColor: const Color(0xFF2a86c9),

  //                               padding:

  //                                   const EdgeInsets.symmetric(vertical: 18),

  //                               shape: RoundedRectangleBorder(

  //                                   borderRadius: BorderRadius.circular(18)),

  //                               elevation: 0,

  //                             ),

  //                             child: Row(

  //                               mainAxisAlignment: MainAxisAlignment.center,

  //                               children: [

  //                                 Icon(Icons.send_rounded,

  //                                     color: Colors.white, size: 20),

  //                                 SizedBox(width: 12),

  //                                 Text(

  //                                     editData == null

  //                                         ? "SUBMIT ORDER"

  //                                         : "UPDATE ORDER",

  //                                     style: const TextStyle(

  //                                         color: Colors.white,

  //                                         fontWeight: FontWeight.bold,

  //                                         fontSize: 16,

  //                                         letterSpacing: 1.2)),

  //                               ],

  //                             ),

  //                           ),

  //                         ),

  //                       ),

  //                     ],

  //                   ),

  //                 ),

  //               ),

  //             ),

  //           );

  //         },

  //       );

  //     },

  //   );

  // }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(builder: (context, setFilterState) {
        return Container(
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Filter Orders',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Date Range',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      child: _buildDatePicker('From', fromDate,
                          (date) => setFilterState(() => fromDate = date))),
                  const SizedBox(width: 15),
                  Expanded(
                      child: _buildDatePicker('To', toDate,
                          (date) => setFilterState(() => toDate = date))),
                ],
              ),
              const SizedBox(height: 25),
              const Text('Approval Status',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: [
                  "All",
                  "Pending",
                  "Approved",
                  "Rejected",
                  "Bill Created"
                ].map((status) {
                  bool isSelected = selectedStatus == status;

                  return ChoiceChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (val) =>
                        setFilterState(() => selectedStatus = status),
                    selectedColor: const Color(0xFF2a86c9).withOpacity(0.1),
                    labelStyle: TextStyle(
                        color: isSelected
                            ? const Color(0xFF2a86c9)
                            : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal),
                    side: BorderSide(
                        color: isSelected
                            ? const Color(0xFF2a86c9)
                            : Colors.grey.shade300),
                  );
                }).toList(),
              ),
              const SizedBox(height: 25),
              const Text('Supplier',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: DropdownSearch<Supplier>(
                  items: (f, p) => suppliers,
                  itemAsString: (s) => s.supplierName,
                  compareFn: (item, selectedItem) =>
                      item.supplierId == selectedItem?.supplierId,
                  onChanged: (val) =>
                      setFilterState(() => selectedSupplierFilter = val),
                  selectedItem: selectedSupplierFilter,
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
                        setFilterState(() {
                          fromDate = null;

                          toDate = null;

                          selectedStatus = "All";

                          selectedSupplierFilter = null;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15))),
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _fetchOrders();

                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2a86c9),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15))),
                      child: const Text('Apply Filter',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  void _showViewDrawer(PurchaseOrderData order) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "ViewPurchaseOrder",
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
      pageBuilder: (dialogContext, anim1, anim2) {
        final hasProducts =
            order.products != null && order.products!.isNotEmpty;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.95,
              height: MediaQuery.of(context).size.height * 0.9,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Column(
                  children: [
                    // Premium Header with Gradient

                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF2a86c9), Color(0xFF1e6091)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close_rounded,
                                color: Colors.white),
                            onPressed: () => Navigator.pop(dialogContext),
                          ),
                          const Expanded(
                            child: Text(
                              'Purchase Order Details',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),

                    // Content

                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2a86c9)
                                        .withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.shopping_bag,
                                      color: Color(0xFF2a86c9)),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Order #${order.orderId ?? 'N/A'}',
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'PO ID: ${order.poId ?? 'N/A'}',
                                        style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                                _buildStatusBadge(
                                    order.billStatus ?? 'Pending'),
                              ],
                            ),

                            const SizedBox(height: 25),

                            // Multi-metric financial cards

                            Row(
                              children: [
                                Expanded(
                                  child: _buildPOFinancialCard(
                                    title: "Estimated",
                                    value: "₹${order.estimatedAmt ?? '0'}",
                                    color: const Color(0xFF2a86c9),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildPOFinancialCard(
                                    title: "Advance",
                                    value: "₹${order.advanceAmt ?? '0'}",
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildPOFinancialCard(
                                    title: "Balance",
                                    value: "₹${order.balanceAmt ?? '0'}",
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            _buildDetailRow(Icons.business, 'Supplier',
                                order.supplierName ?? 'Unknown'),

                            _buildDetailRow(Icons.calendar_today_outlined,
                                'Order Date', order.orderDate ?? 'N/A'),

                            const Divider(height: 30),

                            const Text(
                              'Delivery / Billing Address',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),

                            const SizedBox(height: 10),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Text(
                                order.address ?? 'No address provided',
                                style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic),
                              ),
                            ),

                            const SizedBox(height: 25),

                            // Products Details List

                            if (hasProducts) ...[
                              Row(
                                children: [
                                  const Icon(Icons.inventory_2_outlined,
                                      size: 20, color: Color(0xFF2a86c9)),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Products Details',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2a86c9)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${order.products?.length}',
                                      style: const TextStyle(
                                        color: Color(0xFF2a86c9),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: order.products!.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final prod = order.products![index];

                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                          color: Colors.grey.shade200),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.shade100,
                                          blurRadius: 5,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF2a86c9)
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: const Icon(
                                                  Icons.shopping_bag_outlined,
                                                  size: 18,
                                                  color: Color(0xFF2a86c9)),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                prod.productName ??
                                                    'Unnamed Product',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Qty: ${prod.quantity} ${prod.unitName ?? ""}',
                                              style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 13),
                                            ),
                                            Text(
                                              'Price: ₹${prod.unitPrice}',
                                              style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 13),
                                            ),
                                            Text(
                                              'Amt: ₹${prod.amount}',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Color(0xFF2a86c9)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 25),
                            ],

                            if (order.billStatus == "Bill Not Created")
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(dialogContext);

                                    _createBillFromOrder(order);
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2a86c9),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 15),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15))),
                                  child: const Text('Create Bill',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),

                            const SizedBox(height: 12),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey.shade800,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15))),
                                child: const Text('Close',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
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
  }

  Widget _buildPOFinancialCard(
      {required String title, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 8,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 12, color: color),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined,
              size: 80, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          Text(
            'No Purchase Orders Found',
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

  Widget _buildGlassCard(
      {required String title,
      required String value,
      required IconData icon,
      required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 5))
          ],
          border: Border.all(color: color.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 8),
            Text(title.toUpperCase(),
                style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5))
          ]),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(children: [
      Icon(icon, size: 20, color: const Color(0xFF2a86c9)),
      const SizedBox(width: 12),
      Text(title,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 0.2))
    ]);
  }

  Widget _buildInputLabelField({required String label, required Widget child}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.black87)),
      const SizedBox(height: 8),
      child
    ]);
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade200)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF2a86c9), width: 1.5)),
    );
  }

  Widget _buildEmptyCart() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: Colors.grey.shade200, style: BorderStyle.solid)),
      child: Column(children: [
        Icon(Icons.shopping_cart_outlined,
            size: 40, color: Colors.grey.shade300),
        const SizedBox(height: 12),
        Text("Your cart is empty",
            style: TextStyle(
                color: Colors.grey.shade400, fontWeight: FontWeight.w500))
      ]),
    );
  }

  Widget _buildCartItemCard(
    CartItem item,
    int index,
    StateSetter setDialogState,
    VoidCallback onDelete,
    details.PurchaseOrderData? editData,
    BuildContext dialogContext,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade100)),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(item.material.materialName ?? "Unknown",
                      style: const TextStyle(fontWeight: FontWeight.bold))),

              // Delete button with confirmation for edit mode

              if (editData != null && item.material.materialId != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.red, size: 20),
                  onPressed: () async {
                    // Show confirmation dialog

                    bool? confirm = await showDialog(
                      context: dialogContext,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Product'),
                        content:
                            Text('Delete "${item.material.materialName}"?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.red),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      // Show loading

                      showDialog(
                        context: dialogContext,
                        barrierDismissible: false,
                        builder: (context) =>
                            const Center(child: CircularProgressIndicator()),
                      );

                      // Call API

                      final response =
                          await HttpService.deletePurchaseOrderRealProduct(
                       // productId: item.material.materialId!,
                        purchaseOrderId: editData!.orderDetails!.purchaseOrderId ?? "",
                      );

                      Navigator.pop(dialogContext); // Close loading

                      if (response?.status == true) {
                        Common.toastMessaage('Product deleted', Colors.green);

                        onDelete(); // Remove from cart
                      } else {
                        Common.toastMessaage(
                            response?.message ?? 'Delete failed', Colors.red);
                      }
                    }
                  },
                )
              else
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.red, size: 20),
                  onPressed: onDelete,
                ),
            ],
          ),
          const Divider(height: 24),

//================== First Row ==================
          Row(
            children: [

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.purchaseRequestId.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildInfoTile(
                      "Requested Qty",
                      item.requestedQty,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoTile(
                      "Already Ordered",
                      item.alreadyOrderedQty,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoTile(
                      "Remaining Qty",
                      item.remainingQty,
                    ),
                  ),
                ],
              ),
            ),
          const Text(
            "Ordered Qty",
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 6),

          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                _buildStepperBtn(Icons.remove, () {
                  if (item.quantity > 1) {
                    setDialogState(() {
                      item.quantity--;
                      item.quantityController.text =
                          item.quantity.toString();
                    });
                  }
                }),

                SizedBox(
                  width: 45,
                  child: TextField(
                    controller: item.quantityController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                    onChanged: (v) {
                      setDialogState(() {
                        item.quantity =
                            double.tryParse(v) ?? 1;
                      });
                    },
                  ),
                ),

                _buildStepperBtn(Icons.add, () {
                  setDialogState(() {
                    item.quantity++;
                    item.quantityController.text =
                        item.quantity.toString();
                  });
                }),
              ],
            ),
          ),
        ],
      ),
    ),

    const SizedBox(width: 20),

    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Purchase Price",
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 6),

          TextField(
            controller: item.unitPriceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              prefixText: "₹ ",
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (v) {
              setDialogState(() {
                item.unitPrice =
                    double.tryParse(v) ?? 0;
              });
            },
          ),
        ],
      ),
    ),
  ],
),

const SizedBox(height: 18),

//================== Second Row ==================
Container(
  padding: const EdgeInsets.all(14),
  decoration: BoxDecoration(
    color: Colors.blue.shade50,
    borderRadius: BorderRadius.circular(12),
  ),
  child: Row(
    children: [

      Expanded(
        child: _buildInfoTile(
          "Unit",
          item.material.unitName ?? "-",
        ),
      ),

      Expanded(
        child: _buildInfoTile(
            "Tax %",
            "${item.taxPercent}%",
          ),
      ),

      Expanded(
        child: _buildInfoTile(
          "Tax Amount",
          "₹${item.taxAmountValue}",
        ),
      ),

      Expanded(
        child: _buildInfoTile(
          "Amount",
          "₹${item.total.toStringAsFixed(2)}",
          valueColor: const Color(0xFF2a86c9),
        ),
      ),
    ],
  ),
),

const SizedBox(height: 18),

TextField(
  controller: item.descriptionController,
  maxLines: 2,
  decoration: InputDecoration(
    labelText: "Description",
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  ),
),
        ],
      ),
    );
  }

Widget _buildInfoTile(
  String title,
  String value, {
  Color? valueColor,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          color: Colors.grey,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        value,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: valueColor,
          fontSize: 14,
        ),
      ),
    ],
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
                        validationBuilder: (ctx, selectedItems) => const SizedBox.shrink(),
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
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      decoration: const BoxDecoration(
                        color: Color(
                            0xFF2a86c9), // Blue color matching your app theme
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "ADD SUPPLIER",
                            style: TextStyle(
                              color: Colors.white, // White text
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 0.5,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(dialogCtx),
                            child: const Icon(Icons.close,
                                color: Colors.white,
                                size: 22), // White close icon
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
                            Row(
                              children: [
                                Expanded(child: _buildMaterialDropdown()),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildCustomField(
                                    label: "Supplier Name",
                                    hint: "Enter Supplier Name",
                                    controller: nameCtrl,
                                    isRequired: true,
                                    prefixIcon: Icons.lock,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          //  Row(
                              //children: [
                               // Expanded(
                                //  child:
                                   _buildCustomField(
                                    label: "Contact Person",
                                    hint: "Enter Contact Person",
                                    controller: contactPersonCtrl,
                                    prefixIcon: Icons.person,
                                  ),
                               //// ),
                                const SizedBox(width: 16),
                               // Expanded(
                                 // child: 
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
                           // Row(
                             // children: [
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
                               // ),
                            //  ],
                           // ),
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
                                //),
                            //  ],
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
                    // Footer
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
                                  // "material_ids": selectedMaterials
                                  //     .map((m) => m.materialId)
                                  //     .toList(),
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
                                  final newSupId =
                                      response['supplier_id']?.toString() ??
                                          response['id']?.toString() ??
                                          DateTime.now()
                                              .millisecondsSinceEpoch
                                              .toString();
                                  final newSup = Supplier(
                                      supplierId: newSupId, supplierName: name);
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

  Widget _buildDatePicker(
      String label, DateTime? value, Function(DateTime) onSelect) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
            context: context,
            initialDate: value ?? DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime.now().add(const Duration(days: 365)));

        if (date != null) onSelect(date);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 10),
          Text(value != null ? DateFormat('dd/MM/yy').format(value) : label,
              style: TextStyle(
                  color: value != null ? Colors.black87 : Colors.grey.shade600,
                  fontSize: 12))
        ]),
      ),
    );
  }
Widget _buildStepperBtn(
  IconData icon,
  VoidCallback onTap,
) {
  return InkWell(
    onTap: onTap,
    child: Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        icon,
        size: 16,
        color: Colors.black87,
      ),
    ),
  );
}
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Row(children: [
          Icon(icon, size: 20, color: Colors.grey.shade400),
          const SizedBox(width: 15),
          Text('$label:',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          const SizedBox(width: 10),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                  textAlign: TextAlign.end))
        ]));
  }
}

class CartItem {
  final MaterialData material;

  double quantity;
  double unitPrice;
  String? description;

  String purchaseRequestId;
  String purchaseRequestItemId;

  String requestedQty;
  String alreadyOrderedQty;
  String remainingQty;

  // NEW
  String taxPercent;
  String taxAmountValue;

  late TextEditingController unitPriceController;
  late TextEditingController quantityController;
  late TextEditingController descriptionController;

  CartItem({
    required this.material,
    this.quantity = 1.0,
    this.unitPrice = 0.0,
    this.description,

    this.purchaseRequestId = "",
    this.purchaseRequestItemId = "",

    this.requestedQty = "",
    this.alreadyOrderedQty = "",
    this.remainingQty = "",

    // NEW
    this.taxPercent = "0",
    this.taxAmountValue = "0",
  }) {
    unitPriceController =
        TextEditingController(text: unitPrice > 0 ? unitPrice.toString() : "");

    quantityController = TextEditingController(
      text: quantity == quantity.toInt()
          ? quantity.toInt().toString()
          : quantity.toString(),
    );

    descriptionController =
        TextEditingController(text: description ?? "");
  }

  double get taxAmount =>
      double.tryParse(taxAmountValue) ?? 0;

  double get total =>
      (quantity * unitPrice) + taxAmount;

  void dispose() {
    unitPriceController.dispose();
    quantityController.dispose();
    descriptionController.dispose();
  }
}
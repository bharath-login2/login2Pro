import 'package:flutter/material.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/lead_management/getPurchaseRequestListModel.dart';
import 'package:login2/models/lead_management/materialModel.dart';
import 'package:login2/screens/purchase/showPopupReject.dart';
import 'package:login2/service/service.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:login2/screens/purchase/purchaseOrderPage.dart';
import 'package:login2/screens/purchase/supplierManagementPage.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class PurchaseRequestPage extends StatefulWidget {
  final String token;
  final String name;
  final String userId;

  final String? openRequestId;
  final Map<String, dynamic>? prefillData;

  const PurchaseRequestPage({
    Key? key,
    required this.token,
    required this.name,
    required this.userId,
    this.openRequestId,
    this.prefillData,
  }) : super(key: key);

  @override
  State<PurchaseRequestPage> createState() =>
      _PurchaseRequestPageState();
}

class CartItem {
  MaterialData material;

  double quantity;
  double unitPrice;

  String description;
  String pmrId;

  // Stock Request Details
  String stockRequestQty;
  String alreadyPrQty;
  String remainingQty;
  bool isFromStockRequest;
  String stockRequestItemId;

  late TextEditingController descriptionController;
  late TextEditingController quantityController;
  late TextEditingController unitPriceController;

  CartItem({
    required this.material,
    this.quantity = 1.0,
    this.unitPrice = 0.0,
    this.description = "",
    this.pmrId = "",

    this.stockRequestQty = "",
    this.alreadyPrQty = "",
    this.remainingQty = "",
    this.isFromStockRequest = false,
    this.stockRequestItemId = "",
  }) {
    descriptionController =
        TextEditingController(text: description);

    quantityController = TextEditingController(
      text: quantity > 0
          ? (quantity == quantity.toInt()
              ? quantity.toInt().toString()
              : quantity.toString())
          : "1",
    );

    unitPriceController = TextEditingController(
      text: unitPrice > 0
          ? unitPrice.toString()
          : "",
    );
  }

  double get taxAmount {
    final gst = double.tryParse(
          material.gstPercentage?.toString() ?? "0",
        ) ??
        0;

    return (quantity * unitPrice) * gst / 100;
  }

  double get total => (quantity * unitPrice) + taxAmount;

  void dispose() {
    descriptionController.dispose();
    quantityController.dispose();
    unitPriceController.dispose();
  }
}

class _PurchaseRequestPageState extends State<PurchaseRequestPage> {
  bool isLoading = true;
  List<PurchaseRequestData> requests = [];
  List<PurchaseRequestData> filteredRequests = [];
  String searchQuery = "";

  // Materials for dropdown
  List<MaterialData> materials = [];

  // Filters
  DateTime? fromDate;
  DateTime? toDate;
  String? selectedStatus;
bool _popupOpened = false;

  // @override
  // void initState() {
  //   super.initState();
  //   _fetchRequests();
  //   _fetchMaterials();
  // }
@override
void initState() {
  super.initState();
  _initialize();
}

Future<void> _initialize() async {
  await _fetchRequests();
  await _fetchMaterials();
}
void _showCreateFromStockRequestDialog(
  Map<String, dynamic> data,
) {
  final stock = data["stock_request"];
  final items = data["stock_request_items"] as List;

  final remarksController = TextEditingController(
    text: stock["remarks"] ?? "",
  );

  List<CartItem> cartItems = [];

  for (var item in items) {
    final material = materials.firstWhere(
      (e) =>
          e.materialId.toString() ==
          item["product_id"].toString(),
      orElse: () => MaterialData(
        materialId: item["product_id"],
        materialName: item["product_name"],
        unitName: item["unit_name"],
      ),
    );

    cartItems.add(
      CartItem(
        material: material,

        // Ordered quantity (editable)
        quantity:
            double.tryParse(item["remaining_qty"]?.toString() ?? "0") ?? 0,

        // Purchase price
        unitPrice:
            double.tryParse(item["purchase_price"]?.toString() ?? "0") ?? 0,

        // Description
        description: item["remarks"] ?? "",

        // Stock Request Details
        stockRequestQty: item["quantity"]?.toString() ?? "0",
        alreadyPrQty:
            item["purchase_request_qty"]?.toString() ?? "0",
        remainingQty:
            item["remaining_qty"]?.toString() ?? "0",
        stockRequestItemId:
            item["id"]?.toString() ?? "",
        isFromStockRequest: true,
      ),
    );
  }

  _showRequestDialog(
    requestId: data["new_request_id"]?.toString() ?? "",
    requestDate: DateTime.now(),
    cartItems: cartItems,
    remarksController: remarksController,
    stockRequestId: stock["id"]?.toString(),
  );
}

Future<void> _fetchMaterials() async {
  try {
    final response = await HttpService.getMaterials();

    if (response != null && response.data != null) {
      setState(() {
        materials = response.data!;
      });

      if (widget.prefillData != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showCreateFromStockRequestDialog(widget.prefillData!);
        });
      }
    }
  } catch (e) {
    print(e);
  }
}
Future<void> _fetchRequests() async {
  setState(() => isLoading = true);

  try {
    Map<String, dynamic> data = {};

    if (fromDate != null) {
      data['from_date'] =
          DateFormat('yyyy-MM-dd').format(fromDate!);
    }

    if (toDate != null) {
      data['to_date'] =
          DateFormat('yyyy-MM-dd').format(toDate!);
    }

    if (selectedStatus != null &&
        selectedStatus != "All") {
      data['status'] = selectedStatus;
    }

    final response =
        await HttpService.purchaseRequestList(data);

    if (response != null &&
        response.data != null) {
      setState(() {
        requests = response.data!;
        _applySearch();
        isLoading = false;
      });

      // Auto open newly created Purchase Request
      if (widget.prefillData == null) {
        _openRequestedPurchaseView();
      }
    } else {
      setState(() {
        requests = [];
        filteredRequests = [];
        isLoading = false;
      });
    }
  } catch (e) {
    print("Error fetching purchase requests: $e");

    setState(() => isLoading = false);
  }
}

  void _applySearch() {
    setState(() {
      filteredRequests = requests.where((req) {
        final query = searchQuery.toLowerCase();
        return (req.requestId?.toLowerCase().contains(query) ?? false) ||
            (req.requestedBy?.toLowerCase().contains(query) ?? false) ||
            (req.remarks?.toLowerCase().contains(query) ?? false);
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
          'Purchase Requests',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterSheet,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'view_suppliers') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SupplierManagementPage(token: widget.token),
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'view_suppliers',
                child: Row(
                  children: [
                    Icon(Icons.people_outline, color: Color(0xFF2a86c9)),
                    SizedBox(width: 12),
                    Text('View Suppliers'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredRequests.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _fetchRequests,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          itemCount: filteredRequests.length,
                          itemBuilder: (context, index) {
                            return _buildRequestCard(filteredRequests[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddRequestDialog,
        backgroundColor: const Color(0xFF2a86c9),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('NEW REQUEST',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // Future<void> _submitRequest(BuildContext dialogContext,
  //     List<CartItem> cartItems, DateTime date, String remarks,String? stockRequestId,
  //     {String? editId},String? stockRequestId,) async {
  //   if (cartItems.isEmpty) {
  //     Common.toastMessaage(
  //         "Please add at least one item to the cart", Colors.red);
  //     return;
  //   }
  //   Common.showProgressDialog(
  //       dialogContext, editId == null ? "Submitting..." : "Updating...");
  //   try {
  //     List<Map<String, dynamic>> itemsList = cartItems.map((item) {
  //       return {
  //         "material_id": item.material.materialId,
  //         "unit_amount": item.material.unitPrice,
  //         "quantity": item.quantity.toString(),
  //         "description": item.descriptionController.text,
  //       };
  //     }).toList();
  //     Map<String, dynamic> data = {
  //       "request_date": DateFormat('yyyy-MM-dd').format(date),
  //       "remarks": remarks,
  //       "items": itemsList,
  //     };
  //     dynamic response;
  //     if (editId != null) {
  //       data['id'] = editId;
  //       response = await HttpService.updatePurchaseRequest(data);
  //     } else {
  //       response = await HttpService.postPurchaseRequest(data);
  //     }
  //     Navigator.pop(dialogContext);
  //     if (response != null && response['status'] == true) {
  //       Common.toastMessaage(
  //           response['message'] ??
  //               (editId == null
  //                   ? "Request submitted successfully"
  //                   : "Request updated successfully"),
  //           Colors.green);
  //       Navigator.pop(dialogContext);
  //       _fetchRequests();
  //     } else {
  //       Common.toastMessaage(
  //           response?['message'] ?? "Operation failed", Colors.red);
  //     }
  //   } catch (e) {
  //     Navigator.pop(dialogContext);
  //     Common.toastMessaage("Error: $e", Colors.red);
  //   }
  // }
Future<void> _submitRequest(
  BuildContext dialogContext,
  List<CartItem> cartItems,
  DateTime date,
  String remarks, {
  String? editId,
  String? stockRequestId,
}) async {
  if (cartItems.isEmpty) {
    Common.toastMessaage(
      "Please add at least one item to the cart",
      Colors.red,
    );
    return;
  }

  Common.showProgressDialog(
    dialogContext,
    editId == null ? "Submitting..." : "Updating...",
  );

  try {
    List<Map<String, dynamic>> itemsList = cartItems.map((item) {
      final map = <String, dynamic>{
        "material_id": item.material.materialId,
        "unit_amount": item.material.unitPrice,
        "quantity": item.quantity.toString(),
        "description": item.descriptionController.text,
      };

      // Send only for Stock Request items
      if (item.stockRequestItemId.isNotEmpty) {
        map["stock_request_item_id"] = item.stockRequestItemId;
      }

      return map;
    }).toList();

    Map<String, dynamic> data = {
      "request_date": DateFormat('yyyy-MM-dd').format(date),
      "remarks": remarks,
      "items": itemsList,
    };

    // Add stock request id when creating from stock request
    if (stockRequestId != null && stockRequestId.isNotEmpty) {
      data["stock_request_id"] = stockRequestId;
    }

    dynamic response;

    if (editId != null) {
      data["id"] = editId;
      response = await HttpService.updatePurchaseRequest(data);
    } else {
      response = await HttpService.postPurchaseRequest(data);
    }

    Navigator.pop(dialogContext);

    if (response != null && response["status"] == true) {
      Common.toastMessaage(
        response["message"] ??
            (editId == null
                ? "Request submitted successfully"
                : "Request updated successfully"),
        Colors.green,
      );

      Navigator.pop(dialogContext);
      _fetchRequests();
    } else {
      Common.toastMessaage(
        response?["message"] ?? "Operation failed",
        Colors.red,
      );
    }
  } catch (e) {
    Navigator.pop(dialogContext);
    Common.toastMessaage("Error: $e", Colors.red);
  }
}
  void _showEditRequestDialog(PurchaseRequestData request) async {
    Common.showProgressDialog(context, "Fetching details...");
    final detailsResponse =
        await HttpService.getPurchaseRequestDetails(request.id ?? "");
    Navigator.pop(context);

    if (detailsResponse == null || !detailsResponse.status) {
      Common.toastMessaage("Failed to fetch details", Colors.red);
      return;
    }

    String requestId = request.requestId ?? "";
    DateTime requestDate = request.requestedDate != null
        ? DateFormat('dd-MM-yyyy').parse(request.requestedDate!)
        : DateTime.now();
    final TextEditingController remarksController =
        TextEditingController(text: request.remarks);

    List<CartItem> cartItems = detailsResponse.data.map((detail) {
      MaterialData mat = materials.firstWhere(
        (m) => m.materialId.toString() == detail.materialId,
        orElse: () => MaterialData(
       
          materialId: detail.materialId,
          materialName: detail.materialName,
          unitName: detail.unitName,
        ),
      );
      return CartItem(
        material: mat,
        quantity: double.tryParse(detail.quantity) ?? 1.0,
        description: detail.description,
        pmrId: detail.pmrId,
      );
    }).toList();

    _showRequestDialog(
      requestId: requestId,
      requestDate: requestDate,
      cartItems: cartItems,
      remarksController: remarksController,
      isEdit: true,
      editId: request.id,
    );
  }
void _openRequestedPurchaseView() {
  if (_popupOpened ||
      widget.openRequestId == null ||
      widget.openRequestId!.isEmpty) {
    return;
  }

  try {
    final request = requests.firstWhere(
      (item) =>
          item.id.toString() ==
          widget.openRequestId.toString(),
    );

    _popupOpened = true;

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      _showViewDrawer(request);
    });
  } catch (e) {
    print(
      "Purchase Request not found: ${widget.openRequestId}",
    );
  }
}
  void _showAddRequestDialog() {
    String requestId = "REQ-${DateFormat('HHmmss').format(DateTime.now())}";
    DateTime requestDate = DateTime.now();
    List<CartItem> cartItems = [];
    final TextEditingController remarksController = TextEditingController();

    _showRequestDialog(
      requestId: requestId,
      requestDate: requestDate,
      cartItems: cartItems,
      remarksController: remarksController,
    );
  }

  void _showRequestDialog({
    required String requestId,
    required DateTime requestDate,
    required List<CartItem> cartItems,
    required TextEditingController remarksController,
    bool isEdit = false,
    String? editId,
    String? stockRequestId,
  }) {
    MaterialData? selectedMaterial;
    DateTime internalRequestDate = requestDate;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: isEdit ? "EditPurchaseRequest" : "AddPurchaseRequest",
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
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
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
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 25),
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
                                onPressed: () {
                                  if (isEdit && cartItems.isEmpty) {
                                    Common.toastMessaage(
                                        "Please add at least one product before closing",
                                        Colors.red);
                                  } else {
                                    Navigator.pop(dialogContext);
                                  }
                                },
                              ),
                              Expanded(
                                child: Text(
                                  isEdit
                                      ? "Edit Purchase Request"
                                      : "Purchase Request",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
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
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    // Expanded(
                                    //   child: _buildGlassCard(
                                    //     title: "Request ID",
                                    //     value: requestId,
                                    //     icon: Icons.tag,
                                    //     color: const Color(0xFF2a86c9),
                                    //   ),
                                    // ),
                                    //const SizedBox(width: 16),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () async {
                                          final date = await showDatePicker(
                                            context: dialogContext,
                                            initialDate: internalRequestDate,
                                            firstDate: DateTime(2020),
                                            lastDate: DateTime(2030),
                                            builder: (context, child) {
                                              return Theme(
                                                data:
                                                    Theme.of(context).copyWith(
                                                  colorScheme:
                                                      const ColorScheme.light(
                                                    primary: Color(0xFF2a86c9),
                                                  ),
                                                ),
                                                child: child!,
                                              );
                                            },
                                          );
                                          if (date != null) {
                                            setDialogState(() =>
                                                internalRequestDate = date);
                                          }
                                        },
                                        child: _buildGlassCard(
                                          title: "Request Date",
                                          value: DateFormat('dd MMM yyyy')
                                              .format(internalRequestDate),
                                          icon: Icons.calendar_today_rounded,
                                          color: const Color(0xFF43e97b),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),
                                _buildSectionHeader("Material Selection",
                                    Icons.inventory_2_outlined),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.03),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade50,
                                                borderRadius: BorderRadius.circular(15),
                                                border: Border.all(color: Colors.grey.shade200),
                                              ),
                                              child: DropdownSearch<MaterialData>(
                                                items: (filter, loadProps) => materials
                                                    .where((m) =>
                                                        m.materialName?.toLowerCase().contains(filter.toLowerCase()) ?? true)
                                                    .toList(),
                                                itemAsString: (MaterialData m) => m.materialName ?? "",
                                                compareFn: (i, s) => i.materialId == s?.materialId,
                                                decoratorProps: DropDownDecoratorProps(
                                                  decoration: InputDecoration(
                                                    hintText: "Search and select a material",
                                                    hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                    border: InputBorder.none,
                                                  ),
                                                ),
                                                popupProps: PopupProps.menu(
                                                  showSearchBox: true,
                                                  searchFieldProps: TextFieldProps(
                                                    decoration: InputDecoration(
                                                      hintText: "Search material...",
                                                      prefixIcon: const Icon(Icons.search, size: 20),
                                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                    ),
                                                  ),
                                                  menuProps: const MenuProps(
                                                    elevation: 10,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.all(Radius.circular(20)),
                                                    ),
                                                  ),
                                                ),
                                                onChanged: (val) => setDialogState(() => selectedMaterial = val),
                                                selectedItem: selectedMaterial,
                                              ),
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
                                                      int existingIndex = cartItems.indexWhere((item) =>
                                                          item.material.materialId == productData.id);
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
                                        height: 50,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            if (selectedMaterial != null) {
                                              setDialogState(() {
                                                cartItems.add(CartItem(
                                                    material:
                                                        selectedMaterial!));
                                                selectedMaterial = null;
                                              });
                                            } else {
                                              Common.toastMessaage(
                                                  "Please select a material",
                                                  Colors.orange);
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF2a86c9),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15)),
                                            elevation: 0,
                                          ),
                                          child: const Text(
                                            "Add Item to Cart",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 32),

                                // Cart Items Section
                                _buildSectionHeader(
                                    "Cart Overview (${cartItems.length})",
                                    Icons.shopping_cart_outlined),
                                const SizedBox(height: 16),
                                if (cartItems.isEmpty)
                                  _buildEmptyCart()
                                else
                                  ...cartItems.asMap().entries.map((entry) {
                                    return _buildCartItemCard(
                                      entry.value,
                                      entry.key,
                                      setDialogState,
                                      () {
                                        setDialogState(() {
                                          cartItems[entry.key].dispose();
                                          cartItems.removeAt(entry.key);
                                        });
                                      },
                                      dialogContext,
                                    );
                                  }).toList(),

                                const SizedBox(height: 32),

                                // Remarks Section
                                _buildSectionHeader("Additional Remarks",
                                    Icons.edit_note_rounded),
                                const SizedBox(height: 16),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.03),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: TextField(
                                    controller: remarksController,
                                    maxLines: 4,
                                    decoration: InputDecoration(
                                      hintText:
                                          "Type any specific instructions or remarks here...",
                                      hintStyle: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontSize: 14),
                                      contentPadding: const EdgeInsets.all(20),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide.none,
                                      ),
                                      fillColor: Colors.white,
                                      filled: true,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                    height: 100), // Padding for bottom button
                              ],
                            ),
                          ),
                        ),

                        // Bottom Action Bar
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, -5),
                              ),
                            ],
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: () => _submitRequest(
                                dialogContext,
                                cartItems,
                                internalRequestDate,
                                remarksController.text,
                                editId: editId,
                                stockRequestId: stockRequestId,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2a86c9),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18)),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.send_rounded,
                                      color: Colors.white, size: 20),
                                  const SizedBox(width: 12),
                                  Text(
                                    isEdit
                                        ? "UPDATE REQUEST"
                                        : (stockRequestId != null && stockRequestId.isNotEmpty)
                                            ? "APPROVE & SUBMIT"
                                            : "SUBMIT REQUEST",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
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
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF2a86c9)),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCart() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(25),
        border:
            Border.all(color: Colors.grey.shade200, style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            "Your cart is empty",
            style: TextStyle(
                color: Colors.grey.shade400, fontWeight: FontWeight.w500),
          ),
          Text(
            "Add materials to get started",
            style: TextStyle(color: Colors.grey.shade300, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(
    CartItem item,
    int index,
    StateSetter setDialogState,
    VoidCallback onDelete,
    BuildContext dialogContext,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2a86c9).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.inventory_2_outlined,
                      color: Color(0xFF2a86c9), size: 18),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.material.materialName ?? "Unknown Item",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        "Unit: ${item.material.unitName ?? 'N/A'}",
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: Colors.redAccent),
                  // onPressed: onDelete,
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
                      final response =
                          await HttpService.deletePurchaseOrderProduct(
                        pmrId: item.pmrId,
                      );

                      Navigator.pop(dialogContext); 

                      if (response?.status == true) {
                        Common.toastMessaage('Product deleted', Colors.green);
                        onDelete(); // Remove from cart
                      } else {
                        Common.toastMessaage(
                            response?.message ?? 'Delete failed', Colors.red);
                      }
                    }
                  },
                ),
              ],
            ),
            const Divider(height: 24),

if (item.isFromStockRequest) ...[
  Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.blue.shade50,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Stock Request Qty",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.stockRequestQty,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Already PR Qty",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.alreadyPrQty,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  ),
],

Row(
  children: [
    const Text(
      "Quantity:",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 13,
      ),
    ),
    const Spacer(),
    Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStepperBtn(Icons.remove, () {
            if (item.quantity > 1) {
              setDialogState(() {
                item.quantity--;
                item.quantityController.text =
                    item.quantity == item.quantity.toInt()
                        ? item.quantity.toInt().toString()
                        : item.quantity.toString();
              });
            }
          }),
          SizedBox(
            width: 45,
            child: TextField(
              controller: item.quantityController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textAlign: TextAlign.center,
              onChanged: (v) {
                setDialogState(() {
                  item.quantity = double.tryParse(v) ?? 1.0;
                });
              },
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 4),
                border: InputBorder.none,
              ),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          _buildStepperBtn(Icons.add, () {
            setDialogState(() {
              item.quantity++;
              item.quantityController.text =
                  item.quantity == item.quantity.toInt()
                      ? item.quantity.toInt().toString()
                      : item.quantity.toString();
            });
          }),
        ],
      ),
    ),
  ],
),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: item.descriptionController,
                onChanged: (val) => item.description = val,
                style: const TextStyle(fontSize: 13),
                decoration: const InputDecoration(
                  hintText: "Add specific item description...",
                  hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepperBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 18, color: const Color(0xFF2a86c9)),
      ),
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
                color: Colors.black87)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  // Future<void> _submitRequest(BuildContext dialogContext,
  //     List<CartItem> cartItems, DateTime date, String remarks) async {
  //   if (cartItems.isEmpty) {
  //     Common.toastMessaage(
  //         "Please add at least one item to the cart", Colors.red);
  //     return;
  //   }

  //   Common.showProgressDialog(dialogContext, "Submitting...");

  //   try {
  //     // Prepare items for API
  //     List<Map<String, dynamic>> itemsList = cartItems.map((item) {
  //       return {
  //         "material_id": item.material.materialId,
  //         "quantity": item.quantity.toString(),
  //         "description": item.description,
  //       };
  //     }).toList();

  //     Map<String, dynamic> data = {
  //       "request_date": DateFormat('yyyy-MM-dd').format(date),
  //       "remarks": remarks,
  //       "items":
  //           itemsList, // backend should handle json array or encoded string
  //     };

  //     final response = await HttpService.postPurchaseRequest(data);
  //     Navigator.pop(dialogContext); // Close progress dialog

  //     if (response != null && response['status'] == true) {
  //       Common.toastMessaage(
  //           response['message'] ?? "Request submitted successfully",
  //           Colors.green);
  //       Navigator.pop(dialogContext); // Close Add dialog
  //       _fetchRequests();
  //     } else {
  //       Common.toastMessaage(
  //           response?['message'] ?? "Submission failed", Colors.red);
  //     }
  //   } catch (e) {
  //     Navigator.pop(dialogContext);
  //     Common.toastMessaage("Error: $e", Colors.red);
  //   }
  // }

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
            hintText: 'Search requests...',
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

  Widget _buildRequestCard(PurchaseRequestData request) {
    Color statusColor = _getStatusColor(request.requestStatus ?? '');

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
      child: InkWell(
        onTap: () => _showViewDrawer(request),
        borderRadius: BorderRadius.circular(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 6,
                  color: statusColor,
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
                            if (request.orderStatus != null &&
                                request.orderStatus!.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  request.orderStatus!,
                                  style: const TextStyle(
                                    color: Colors.orange,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            Row(
                              children: [
                                // _buildStatusBadge(
                                //     request.requestStatus ?? 'Pending'),
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert,
                                      size: 20, color: Colors.grey),
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _showEditRequestDialog(request);
                                    } else if (value == 'delete') {
                                      _deleteRequest(request.id ?? "");
                                    } else if (value == 'create_order') {
                                      _createOrderFromRequest(request);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit,
                                              size: 18, color: Colors.blue),
                                          SizedBox(width: 8),
                                          Text("Edit"),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete,
                                              size: 18, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text("Delete"),
                                        ],
                                      ),
                                    ),
                                    // if (request.orderStatus ==
                                    //         "Order Not Created" &&
                                    //     request.requestStatus != "Pending")
                                      PopupMenuItem(
                                        value: 'create_order',
                                        child: Row(
                                          children: [
                                            Icon(Icons.add,
                                                size: 18, color: Colors.green),
                                            SizedBox(width: 8),
                                            Text("Create Order"),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 16,
                              backgroundColor: Color(0xFFF0F2F5),
                              child: Icon(Icons.person,
                                  size: 18, color: Color(0xFF2a86c9)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                   Text(
                                    request.requestId ?? 'Unknown',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    request.requestedDate ?? 'N/A',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 12,
                                    ),
                                  ),
                                    SizedBox(height: 2),
                                  Text(
                                    request.requestedBy ?? 'Unknown',
                                    style: const TextStyle(
                                     // fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Est. Amount',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 10)),
                                Text(
                                  '₹${request.estimatedAmount ?? '0'}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF2a86c9),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            Icon(Icons.notes,
                                size: 14, color: Colors.grey.shade400),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                request.remarks ?? 'No remarks provided',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
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
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _FilterBottomSheet(
        initialFromDate: fromDate,
        initialToDate: toDate,
        initialStatus: selectedStatus,
        onApply: (from, to, status) {
          setState(() {
            fromDate = from;
            toDate = to;
            selectedStatus = status;
          });
          _fetchRequests();
        },
      ),
    );
  }

  void _showViewDrawer(PurchaseRequestData request) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "ViewPurchaseRequest",
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
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: _RequestDetailsDrawer(
                  request: request,
                  onCreateOrder: () => _createOrderFromRequest(request),
                  onRefresh: _fetchRequests,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteRequest(String id) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text(
            "Are you sure you want to delete this purchase request?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final response = await HttpService.deletePurchaseRequest(id);
      if (response != null && response.status == true) {
        Common.toastMessaage(
            response.message ?? "Request deleted successfully", Colors.green);
        _fetchRequests();
      } else {
        Common.toastMessaage(
            response?.message ?? "Failed to delete request", Colors.red);
      }
    }
  }

Future<void> _createOrderFromRequest(PurchaseRequestData request) async {
  Common.showProgressDialog(context, "Fetching request details...");

  final detailsResponse =
      await HttpService.getPurchaseRequestDetails(request.id ?? "");

  Navigator.pop(context);

  if (detailsResponse == null || !detailsResponse.status) {
    Common.toastMessaage(
      "Failed to fetch request details",
      Colors.red,
    );
    return;
  }

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PurchaseOrderPage(
        token: widget.token,
        name: widget.name,
        userId: widget.userId,
        createFromRequestItems: detailsResponse.data,
        createFromRequestRemarks: request.remarks,
      ),
    ),
  );
}
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_late_outlined,
              size: 80, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          Text(
            'No Purchase Requests Found',
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

  Color _getStatusColor(String status) {
    final lowerStatus = status.toLowerCase();

    if (lowerStatus.contains('approved')) {
      return Colors.green;
    } else if (lowerStatus.contains('pending')) {
      return Colors.orange;
    } else if (lowerStatus.contains('rejected')) {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }

  Widget _buildStatusBadge(String status) {
    Color color = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.toUpperCase(),
        style:
            TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final DateTime? initialFromDate;
  final DateTime? initialToDate;
  final String? initialStatus;
  final Function(DateTime?, DateTime?, String?) onApply;

  const _FilterBottomSheet({
    this.initialFromDate,
    this.initialToDate,
    this.initialStatus,
    required this.onApply,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  DateTime? fromDate;
  DateTime? toDate;
  String? selectedStatus;

  @override
  void initState() {
    super.initState();
    fromDate = widget.initialFromDate;
    toDate = widget.initialToDate;
    selectedStatus = widget.initialStatus ?? "All";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.all(25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter Requests',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Date Range',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildDatePicker(
                  'From',
                  fromDate,
                  (date) => setState(() => fromDate = date),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildDatePicker(
                  'To',
                  toDate,
                  (date) => setState(() => toDate = date),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          const Text('Approval Status',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: ["All", "Pending", "Approved", "Rejected"].map((status) {
              bool isSelected = selectedStatus == status;
              return ChoiceChip(
                label: Text(status),
                selected: isSelected,
                onSelected: (val) => setState(() => selectedStatus = status),
                selectedColor: const Color(0xFF2a86c9).withOpacity(0.1),
                labelStyle: TextStyle(
                  color: isSelected ? const Color(0xFF2a86c9) : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                side: BorderSide(
                    color: isSelected
                        ? const Color(0xFF2a86c9)
                        : Colors.grey.shade300),
              );
            }).toList(),
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
                      selectedStatus = "All";
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(fromDate, toDate, selectedStatus);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2a86c9),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text('Apply Filter',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
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
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) onSelect(date);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 10),
            Text(
              value != null ? DateFormat('dd/MM/yy').format(value) : label,
              style: TextStyle(
                  color: value != null ? Colors.black87 : Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
class _RequestDetailsDrawer extends StatelessWidget {
  final PurchaseRequestData request;
  final VoidCallback? onCreateOrder;
  final VoidCallback? onRefresh;

  const _RequestDetailsDrawer({
    required this.request,
    this.onCreateOrder,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final hasProducts =
        request.products != null && request.products!.isNotEmpty;

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Premium Header with Gradient
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: const Text(
                    'Purchase  Details',
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
                          color: const Color(0xFF2a86c9).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.assignment, color: Color(0xFF2a86c9)),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Request #${request.requestId ?? 'N/A'}',
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Requisition ID: ${request.id ?? 'N/A'}',
                              style: TextStyle(
                                  color: Colors.grey.shade500, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      // _buildStatusBadge(request.requestStatus ?? 'Pending'),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          title: "Estimated Amt",
                          value: "₹${request.estimatedAmount ?? '0'}",
                          icon: Icons.currency_rupee,
                          color: const Color(0xFF2a86c9),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          title: "Requested Date",
                          value: request.requestedDate ?? 'N/A',
                          icon: Icons.calendar_today,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildDetailRow(Icons.person_outline, 'Requested By',
                      request.requestedBy ?? 'Unknown'),
                  _buildDetailRow(Icons.shopping_cart_outlined, 'Order Status',
                      request.orderStatus ?? 'Not Ordered'),
                  if (request.requestStatus != "Pending")
                    _buildDetailRow(Icons.event_available_outlined, 'Approved Date',
                        request.approvedDate ?? 'Not Approved'),

                  const Divider(height: 30),

                  // Products Section
                  if (hasProducts) ...[
                    Row(
                      children: [
                        const Icon(Icons.inventory_2_outlined,
                            size: 20, color: Color(0xFF2a86c9)),
                        const SizedBox(width: 10),
                        const Text(
                          'Products List',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2a86c9).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${request.products?.length}',
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
                      itemCount: request.products!.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final product = request.products![index];
                        return _buildProductCard(product);
                      },
                    ),
                    const SizedBox(height: 20),
                    const Divider(height: 20),
                  ],

                  // Remarks Section
                  const Text(
                    'Remarks / Notes',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
                      request.remarks ?? 'No remarks provided',
                      style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                          fontStyle: FontStyle.italic),
                    ),
                  ),
                  const SizedBox(height: 25),
                  if (request.orderStatus == "Order Not Created" &&
                      request.requestStatus != "Pending")
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          if (onCreateOrder != null) {
                            onCreateOrder!();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2a86c9),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                        ),
                        child: const Text('Create Purchase Order',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 7, 7, 7),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                          ),
                          child: const Text('Close',
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      //  const SizedBox(width: 15),
                      // Expanded(
                      //   child: ElevatedButton(
                      //     onPressed: () {
                      //       showDialog(
                      //         context: context,
                      //         barrierDismissible: false,
                      //         builder: (BuildContext context) {
                      //           return ApprovalDialog(
                      //             request: request,
                      //             onRefresh: onRefresh,
                      //           );
                      //         },
                      //       );
                      //     },
                      //     style: ElevatedButton.styleFrom(
                      //       backgroundColor: Colors.green,
                      //       padding: const EdgeInsets.symmetric(vertical: 15),
                      //       shape: RoundedRectangleBorder(
                      //           borderRadius: BorderRadius.circular(15)),
                      //     ),
                      //     child: const Text('Approve / Reject',
                      //         style: TextStyle(
                      //             color: Colors.white, fontWeight: FontWeight.bold)),
                      //   ),
                      // ),
                     
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                title.toUpperCase(),
                style: TextStyle(color: Colors.grey.shade500, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2a86c9).withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2a86c9).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.shopping_bag_outlined,
                      size: 18, color: Color(0xFF2a86c9)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    product.productName ?? 'Unnamed Product',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _buildProductDetailRow('Quantity',
                    '${product.quantity ?? '0'} ${product.unitName?.isNotEmpty == true ? '(' + product.unitName! + ')' : ''}'),
                if (product.unitAmount != null && product.unitAmount != '0')
                  _buildProductDetailRow(
                      'Unit Price', '₹${product.unitAmount}'),
                _buildProductDetailRow(
                    'Estimated Amount', '₹${product.estimatedAmount ?? '0'}',
                    isHighlighted: true),
                if (product.description != null &&
                    product.description!.isNotEmpty)
                  _buildProductDetailRow('Description', product.description!),
                if (product.remarks != null && product.remarks!.isNotEmpty)
                  _buildProductDetailRow('Product Remarks', product.remarks!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetailRow(String label, String value,
      {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
                color: isHighlighted ? const Color(0xFF2a86c9) : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade400),
          const SizedBox(width: 15),
          Text('$label:',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey;

    final lowerStatus = status.toLowerCase();

    if (lowerStatus.contains('approved')) {
      color = Colors.green;
    } else if (lowerStatus.contains('pending')) {
      color = Colors.orange;
    } else if (lowerStatus.contains('rejected')) {
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.toUpperCase(),
        style:
            TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

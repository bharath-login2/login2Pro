import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/lead_management/materialModel.dart' as mat;
import 'package:login2/models/lead_management/stockCounsumptionListModel.dart';
import 'package:login2/models/lead_management/getMaterialForStockCunsuptionModel.dart';
import 'package:login2/models/rental/rentalLocationModel.dart' as loc;
import 'package:login2/service/service.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class CartItem {
  final String productId;
  final String productName;
  final List<ConsumptionMaterialData> materials;

  CartItem({
    required this.productId,
    required this.productName,
    required this.materials,
  });
}
class StockConsumptionPage extends StatefulWidget {
  final String? initialProductId;
  final String? initialProductName;
  
  const StockConsumptionPage({
    super.key,
    this.initialProductId,
    this.initialProductName,
  });

  @override
  State<StockConsumptionPage> createState() => _StockConsumptionPageState();
}

class _StockConsumptionPageState extends State<StockConsumptionPage> {
  bool _isLoading = true;
  List<ConsumptionData> _consumptionList = [];
  List<ConsumptionData> _filteredList = [];
  final TextEditingController _searchController = TextEditingController();
  // Filters
  String? _selectedProductId;
  String? _selectedProductName;
  List<mat.MaterialData> _products = [];
  List<loc.RetailLocation> _locations = [];

  @override
  void initState() {
    super.initState();
    _selectedProductId = widget.initialProductId;
    _selectedProductName = widget.initialProductName;
    _loadInitialData();
    _fetchConsumption();
    _searchController.addListener(_filterBySearch);
  }

  Future<void> _loadInitialData() async {
    final prodResponse = await HttpService.getMaterials();
    final locResponse = await HttpService.getRentalLocation();
    if (mounted) {
      setState(() {
        if (prodResponse != null) _products = prodResponse.data ?? [];
        if (locResponse != null) _locations = locResponse.data;
      });
    }
  }

Future<void> _fetchConsumption() async {
  setState(() => _isLoading = true);

  try {
    final response = await HttpService.getProductStockConsumedList(
      _selectedProductId ?? "",
    );

    if (!mounted) return;

    setState(() {
      if (response != null && response.status) {
        _consumptionList = response.data;
        _filteredList = List.from(_consumptionList);
      } else {
        _consumptionList.clear();
        _filteredList.clear();
      }

      _isLoading = false;
    });
  } catch (e) {
    debugPrint("Error fetching consumption: $e");

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}
void _filterBySearch() {
  final query = _searchController.text.toLowerCase();

  setState(() {
    _filteredList = _consumptionList.where((consumption) {
      return consumption.items.any(
        (item) => item.materialName.toLowerCase().contains(query),
      );
    }).toList();
  });
}

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Stock Consumption',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF2a86c9),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildFilterBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchConsumption,
                    child: _filteredList.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredList.length,
                            itemBuilder: (context, index) =>
                                _buildConsumptionCard(_filteredList[index]),
                          ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddConsumptionPage(),
        backgroundColor: const Color(0xFF2a86c9),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("ADD CONSUMPTION",
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
      child: Column(
        children: [
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(15),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search materials...",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _showProductPicker,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.inventory_2_outlined,
                        size: 18, color: Color(0xFF2a86c9)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _selectedProductName ?? "All Products",
                        style: TextStyle(
                          color: _selectedProductName == null
                              ? Colors.grey[400]
                              : const Color(0xFF1E293B),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_selectedProductId != null)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedProductId = null;
                            _selectedProductName = null;
                          });
                          _fetchConsumption();
                        },
                        child: const Icon(Icons.close, size: 18, color: Colors.red),
                      )
                    else
                      const Icon(Icons.keyboard_arrow_down,
                          size: 18, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

Widget _buildConsumptionCard(ConsumptionData item) {
  return InkWell(
    borderRadius: BorderRadius.circular(16),
    onTap: () => _showConsumptionDetails(item),
    child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
    const Icon(
      Icons.inventory_2_outlined,
      color: Color(0xFF2A86C9),
    ),
    const SizedBox(width: 8),

    const Expanded(
      child: Text(
        "Stock Consumption",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    // EDIT
    IconButton(
      tooltip: "Edit",
      onPressed: () {
        _showEditConsumptionPage(item);
      },
      icon: const Icon(
        Icons.edit_outlined,
        color: Color(0xFF2A86C9),
      ),
    ),

    // DELETE
    IconButton(
      tooltip: "Delete",
      onPressed: () => _deleteConsumption(item.consumptionId),
      icon: const Icon(
        Icons.delete_outline,
        color: Colors.red,
      ),
    ),
  ],
),

            const Divider(),

            _buildInfoRow(Icons.calendar_today, "Date", item.date),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.location_on, "Location", item.locationName),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.confirmation_number,
                "Requisition No", item.requisitionNo.isEmpty ? "-" : item.requisitionNo),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.notes,
                "Remarks", item.remarks.isEmpty ? "-" : item.remarks),
          ],
        ),
      ),
    ),
  );
}
void _showEditConsumptionPage(ConsumptionData item) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => AddStockConsumptionPage(
        locations: _locations,
        allProducts: _products,
        isEdit: true,
        consumptionData: item,
      ),
    ),
  ).then((value) {
    if (value == true) {
      _fetchConsumption();
    }
  });
}
void _showConsumptionDetails(ConsumptionData data) {
  final double total = data.items.fold<double>(
    0.0,
    (sum, item) => sum + (double.tryParse(item.totalAmount) ?? 0.0),
  );

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return Container(
        height: MediaQuery.of(context).size.height * .85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 45,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Consumption Details",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const Divider(height: 30),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _popupInfo("Requisition No", data.requisitionNo),
                    _popupInfo("Consumption Date", data.date),
                    _popupInfo("Location", data.locationName),
                    _popupInfo("Remarks", data.remarks),

                    const SizedBox(height: 25),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Products",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: data.items.length,
                      itemBuilder: (_, index) {
                        final item = data.items[index];

                        return Card(
                          elevation: 0,
                          color: Colors.grey.shade100,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.materialName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "₹${item.totalAmount}",
                                      style: const TextStyle(
                                        color: Color(0xff2A86C9),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _miniItem("Unit", item.unitName),
                                    _miniItem(
                                        "Price", "₹${item.unitPrice}"),
                                    _miniItem("Qty", item.quantity),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          "Total : ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          "₹${total.toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: Color(0xff2A86C9),
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
Widget _popupInfo(String title, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        SizedBox(
          width: 130,
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? "-" : value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

Widget _miniItem(String title, String value) {
  return Column(
    children: [
      Text(
        title,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 11,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}
Widget _buildInfoRow(
  IconData icon,
  String title,
  String value,
) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(
        icon,
        size: 18,
        color: const Color(0xFF2A86C9),
      ),
      const SizedBox(width: 10),

      SizedBox(
        width: 100,
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),

      const Text(
        ": ",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),

      Expanded(
        child: Text(
          value,
          style: const TextStyle(
            color: Colors.black54,
          ),
        ),
      ),
    ],
  );
}
  Widget _buildInfoTag(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: TextStyle(
                color: Colors.grey[400],
                fontSize: 8,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 14, color: color)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text("No consumption data found",
              style: TextStyle(color: Colors.grey[400], fontSize: 16)),
        ],
      ),
    );
  }

  void _showProductPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Select Product",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              Expanded(
                child: ListView.builder(
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final p = _products[index];
                    return ListTile(
                      title: Text(p.materialName ?? ""),
                      onTap: () {
                        setState(() {
                          _selectedProductId = p.materialId;
                          _selectedProductName = p.materialName;
                        });
                        Navigator.pop(context);
                        _fetchConsumption();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteConsumption(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Consumption"),
        content: const Text("Are you sure you want to delete this record?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Delete")),
        ],
      ),
    );

    if (confirm == true) {
      Common.showProgressDialog(context, "Deleting...");
      final response = await HttpService.deleteStockConsumed(id);
      Navigator.pop(context);

      if (response != null && response.status == true) {
        Common.toastMessaage("Deleted successfully", Colors.green);
        _fetchConsumption();
      } else {
        Common.toastMessaage(response?.message ?? "Delete failed", Colors.red);
      }
    }
  }

  void _showAddConsumptionPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddStockConsumptionPage(
          locations: _locations,
          allProducts: _products,
        ),
      ),
    ).then((value) {
      if (value == true) _fetchConsumption();
    });
  }
}

class AddStockConsumptionPage extends StatefulWidget {
  final List<loc.RetailLocation> locations;
  final List<mat.MaterialData> allProducts;
final bool isEdit;
  final ConsumptionData? consumptionData;
  
  const AddStockConsumptionPage({
    super.key,
    required this.locations,
    required this.allProducts,
     this.isEdit = false,
    this.consumptionData,
  });

  @override
  State<AddStockConsumptionPage> createState() => _AddStockConsumptionPageState();
}

class _AddStockConsumptionPageState extends State<AddStockConsumptionPage> {
  DateTime _consumedDate = DateTime.now();
  String? _selectedProductId;
  String? _selectedProductName;
  String? _selectedLocationId;
  String? _selectedLocationName;
  final TextEditingController _referenceNoController =
      TextEditingController();

  final TextEditingController _remarkController =
      TextEditingController();
bool _showMaterials = false;
List<CartItem> _cartItems = [];
  List<ConsumptionMaterialData> _materials = [];
  Map<String, double> _consumedQtys = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.isEdit && widget.consumptionData != null) {
      _loadEditData();
    } else {
      if (widget.locations.isNotEmpty) {
        _selectedLocationId = widget.locations.first.id;
        _selectedLocationName = widget.locations.first.locationName;
      }

      _fetchMaterials();
    }
  }
void _loadEditData() {
  final data = widget.consumptionData!;

  // Date
  try {
    _consumedDate = DateFormat("dd-MM-yyyy").parse(data.date);
  } catch (_) {
    _consumedDate = DateTime.now();
  }

  // Location
  final location = widget.locations.cast<loc.RetailLocation?>().firstWhere(
    (e) => e?.locationName == data.locationName,
    orElse: () => null,
  );

  if (location != null) {
    _selectedLocationId = location.id;
    _selectedLocationName = location.locationName;
  }

  // Header Details
  _referenceNoController.text = data.requisitionNo;
  _remarkController.text = data.remarks;

  _cartItems.clear();
  _materials.clear();
  _consumedQtys.clear();

  for (final item in data.items) {
    // Quantity
    _consumedQtys[item.materialId] =
        double.tryParse(item.quantity) ?? 0.0;

    // Material
    final material = ConsumptionMaterialData(
      id: item.materialId,
      productName: item.materialName,
      unitId: item.unit,
      unitName: item.unitName,
      unitPrice: item.unitPrice,
      currentStock: "",
    );

    _materials.add(material);

    // Cart
    _cartItems.add(
      CartItem(
        productId: item.materialId,
        productName: item.materialName,
        materials: [material],
      ),
    );
  }

  _showMaterials = _cartItems.isNotEmpty;

  setState(() {});
} 
  // Future<void> _fetchMaterials() async {
  //   setState(() => _isLoading = true);
  //   try {
  //     final dateStr = DateFormat('yyyy-MM-dd').format(_consumedDate);
  //     final response = await HttpService.getMaterialForConsumption(
  //       dateStr,
  //       _selectedProductId ?? "",
  //       _selectedLocationId ?? "",
  //     );
  //     if (mounted) {
  //       setState(() {
  //         _materials = response?.data ?? [];
  //         // Keep existing quantities if still in the list
  //         final newQtys = <String, double>{};
  //         for (var m in _materials) {
  //           newQtys[m.id] = _consumedQtys[m.id] ?? 0.0;
  //         }
  //         _consumedQtys = newQtys;
  //         _isLoading = false;
  //       });
  //     }
  //   } catch (e) {
  //     debugPrint("Error fetching materials for consumption: $e");
  //     if (mounted) setState(() => _isLoading = false);
  //   }
  // }
Future<List<ConsumptionMaterialData>> _fetchMaterials() async {
  setState(() => _isLoading = true);

  try {
    final dateStr = DateFormat('yyyy-MM-dd').format(_consumedDate);

    final response = await HttpService.getMaterialForConsumption(
      dateStr,
      _selectedProductId ?? "",
      _selectedLocationId ?? "",
    );

    final materials = response?.data ?? [];

    // Preserve existing quantities
    for (final m in materials) {
      _consumedQtys[m.id] = _consumedQtys[m.id] ?? 0.0;
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }

    return materials;
  } catch (e) {
    debugPrint("Error fetching materials for consumption: $e");

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }

    return [];
  }
}
double get _grandTotal {
  double total = 0;

  for (final cart in _cartItems) {
    for (final material in cart.materials) {
      final qty = _consumedQtys[material.id] ?? 0;
      final price = double.tryParse(material.unitPrice) ?? 0;

      total += qty * price;
    }
  }

  return total;
}
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF8FAFC),
    resizeToAvoidBottomInset: true,
    appBar: AppBar(
  title: Text(
    widget.isEdit
        ? 'Edit Stock Consumption'
        : 'Add Stock Consumption',
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
  backgroundColor: const Color(0xFF2A86C9),
  iconTheme: const IconThemeData(color: Colors.white),
),
    body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                children: [
                  _buildFilters(),

                  if (!_showMaterials)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          "Select a product and tap Add to Cart",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    )
                  else if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_cartItems.isEmpty)
                    _buildEmptyState()
                  else
                    _buildMaterialsList(),
                ],
              ),
            ),
          ),

          _buildBottomBar(),
        ],
      ),
    ),
  );
}
  Widget _buildFilters() {
  return Container(
    padding: const EdgeInsets.all(16),
    color: Colors.white,
    child: Column(
      children: [
        // First Row
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Consumed Date *",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _consumedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );

                      if (date != null) {
                        setState(() => _consumedDate = date);

                        if (_showMaterials) {
                          _fetchMaterials();
                        }
                      }
                    },
                    child: _buildFilterBox(
                      DateFormat('dd-MM-yyyy').format(_consumedDate),
                      Icons.calendar_today,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            if (widget.locations.length > 1)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Location",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: _showLocationPicker,
                      child: _buildFilterBox(
                        _selectedLocationName ?? "Select Location",
                        Icons.location_on_outlined,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
const SizedBox(height: 16),

// Reference No
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const Text(
      "Requisition No",
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
      ),
    ),
    const SizedBox(height: 6),
    TextField(
      controller: _referenceNoController,
      decoration: InputDecoration(
        hintText: "Enter Requisition No",
        prefixIcon: const Icon(Icons.numbers),
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
    ),
  ],
),

const SizedBox(height: 16),

// Remark
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const Text(
      "Remark",
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
      ),
    ),
    const SizedBox(height: 6),
    TextField(
      controller: _remarkController,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: "Enter Remark",
        alignLabelWithHint: true,
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
    ),
  ],
),

const SizedBox(height: 16),

        // Second Row
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Product",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 6),

            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _showProductPicker,
                    child: _buildFilterBox(
                      _selectedProductName ?? "---Select Product---",
                      Icons.inventory_2_outlined,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.qr_code_scanner,
                      color: Color(0xFF2a86c9),
                    ),
                    onPressed: () async {
                      var res = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const SimpleBarcodeScannerPage(),
                        ),
                      );

                      if (res is String && res != '-1') {
                        Common.showProgressDialog(
                          context,
                          "Fetching product...",
                        );

                        final productRes =
                            await HttpService.getQrcodeproductDetails(res);

                        Navigator.pop(context);

                        if (productRes != null &&
                            productRes.data != null) {
                          setState(() {
                            _selectedProductId = productRes.data!.id;
                            _selectedProductName =
                                productRes.data!.productName;
                            _showMaterials = false;
                          });
                        } else {
                          Common.toastMessaage(
                            "Product not found",
                            Colors.red,
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),

            if (_selectedProductId != null) ...[
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
  if (_selectedProductId == null) return;

  if (_cartItems.any((e) => e.productId == _selectedProductId)) {
    Common.toastMessaage(
      "Product already added",
      Colors.orange,
    );
    return;
  }

  final materials = await _fetchMaterials();

  if (materials.isEmpty) {
    Common.toastMessaage(
      "No materials found",
      Colors.red,
    );
    return;
  }

  setState(() {
    _cartItems.add(
      CartItem(
        productId: _selectedProductId!,
        productName: _selectedProductName!,
        materials: materials,
      ),
    );
    debugPrint("Cart Count: ${_cartItems.length}");
debugPrint("Materials Count: ${materials.length}");
    _showMaterials = true;

    _selectedProductId = null;
    _selectedProductName = null;
  });
},
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text("Add to Cart"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2A86C9),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    ),
  );
}
  
  Widget _buildFilterBox(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF2a86c9)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
          const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

Widget _buildMaterialsList() {
  return ListView.builder(
    padding: const EdgeInsets.all(16),
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: _cartItems.length,
    itemBuilder: (context, index) {
      return _buildCartCard(_cartItems[index], index);
    },
  );
}

  Widget _buildMaterialCard(ConsumptionMaterialData m, int siNo) {
    final qty = _consumedQtys[m.id] ?? 0.0;
    final price = double.tryParse(m.unitPrice) ?? 0.0;
    final amount = qty * price;

    return InkWell(
  borderRadius: BorderRadius.circular(15),
  onTap: () {
  debugPrint("Card Clicked");
    _showMaterialDetails(m);
  },
  child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(6)),
                  child: Text("$siNo", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(m.productName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              children: [
                _buildCardInfo("Unit", m.unitName),
                _buildCardInfo("Unit Price", "₹${m.unitPrice}"),
                _buildCardInfo("Current Stock", m.currentStock),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Consumed Qty",
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 16),
                              onPressed: () {
                                if (qty > 0) {
                                  setState(() => _consumedQtys[m.id] = qty - 1);
                                }
                              },
                            ),
                            Expanded(
                              child: TextField(
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                                onChanged: (val) {
                                  setState(() => _consumedQtys[m.id] = double.tryParse(val) ?? 0.0);
                                },
                                controller: TextEditingController(text: qty == 0 ? "0" : qty.toStringAsFixed(0))
                                  ..selection = TextSelection.fromPosition(TextPosition(offset: (qty == 0 ? "0" : qty.toStringAsFixed(0)).length)),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 16),
                              onPressed: () {
                                setState(() => _consumedQtys[m.id] = qty + 1);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text("Amount",
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text("₹${amount.toStringAsFixed(2)}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2a86c9))),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
           ),
    ),
  );
  }

void _showMaterialDetails(ConsumptionMaterialData m) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Container(
        height: 300,
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(
            m.productName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    },
  );
}
Widget _buildPopupTile(
  String title,
  String value,
  IconData icon,
) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [

        Icon(
          icon,
          color: const Color(0xff2A86C9),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                value,
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
  );
}
Widget _buildCartCard(CartItem cart, int index) {
  return Container(
    margin: const EdgeInsets.only(bottom: 20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: Color(0xFF2A86C9),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  cart.productName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
  setState(() {
    _cartItems.removeAt(index);

    if (_cartItems.isEmpty) {
      _showMaterials = false;
    }
  });
},
                icon: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: List.generate(
              cart.materials.length,
              (i) => _buildMaterialCard(cart.materials[i], i + 1),
            ),
          ),
        ),
      ],
    ),
  );
}
 
  Widget _buildCardInfo(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
  return Container(
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
    child: SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Grand Total",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                "₹ ${_grandTotal.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2A86C9),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Close"),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                      _cartItems.isEmpty ? null : _submitConsumption,
                  icon: const Icon(Icons.save),
                  label: const Text("Save"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2A86C9),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
  
  void _showProductPicker() {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Select Product",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),

            ListTile(
              title: const Text("---All Product---"),
              onTap: () {
                setState(() {
                  _selectedProductId = null;
                  _selectedProductName = null;
                });

                Navigator.pop(context);
              },
            ),

            Expanded(
              child: ListView.builder(
                itemCount: widget.allProducts.length,
                itemBuilder: (context, index) {
                  final p = widget.allProducts[index];

                  return ListTile(
                    title: Text(p.materialName ?? ""),
                    onTap: () {
                      setState(() {
                        _selectedProductId = p.materialId;
                        _selectedProductName = p.materialName;
                      });

                      Navigator.pop(context);

                      // ❌ Don't call _fetchMaterials() here.
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
  
  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Select Location", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.locations.length,
                  itemBuilder: (context, index) {
                    final l = widget.locations[index];
                    return ListTile(
                      title: Text(l.locationName),
                      onTap: () {
                        setState(() {
                          _selectedLocationId = l.id;
                          _selectedLocationName = l.locationName;
                        });
                        Navigator.pop(context);

                        setState(() {
                          _selectedLocationId = l.id;
                          _selectedLocationName = l.locationName;
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

Future<void> _submitConsumption() async {
  final itemsToSubmit = <Map<String, dynamic>>[];

  for (final cart in _cartItems) {
    for (final m in cart.materials) {
      final qty = _consumedQtys[m.id] ?? 0.0;

      if (qty > 0) {
        itemsToSubmit.add({
          "product_id": m.id,
          "quantity": qty.toString(),
          "unit_price": m.unitPrice,
          "unit": m.unitId,
        });
      }
    }
  }

  if (itemsToSubmit.isEmpty) {
    Common.toastMessaage(
      "Please enter quantity for at least one item",
      Colors.orange,
    );
    return;
  }

  if (_selectedLocationId == null) {
    Common.toastMessaage(
      "Please select a location",
      Colors.orange,
    );
    return;
  }

  Common.showProgressDialog(context, "Saving Consumption...");

  try {
    final dateStr = DateFormat('yyyy-MM-dd').format(_consumedDate);

    final response = await HttpService.addStockConsumption(
      date: dateStr,
      locationId: _selectedLocationId!,
      referenceNo: _referenceNoController.text.trim(),
      remark: _remarkController.text.trim(),
      items: itemsToSubmit,
    );

    if (mounted) Navigator.pop(context);

    if (response != null && response.status == true) {
      Common.toastMessaage(
        "Stock consumption saved successfully",
        Colors.green,
      );

      Navigator.pop(context, true);
    } else {
      Common.toastMessaage(
        response?.message ?? "Failed to save consumption",
        Colors.red,
      );
    }
  } catch (e) {
    if (mounted) Navigator.pop(context);

    Common.toastMessaage(
      "Error : $e",
      Colors.red,
    );
  }
}
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text("No materials available for consumption", style: TextStyle(color: Colors.grey[400], fontSize: 16)),
        ],
      ),
    );
  }
}

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/lead_management/materialModel.dart';
import 'package:login2/models/serviceman/workModel.dart';
import 'package:login2/models/serviceman/workTypeModel.dart';
import 'package:login2/screens/serviceman/addWorkPage.dart';
import 'package:login2/screens/serviceman/editWorkPage.dart';
import 'package:login2/service/service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timelines_plus/timelines_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class WorkListPage extends StatefulWidget {
  final String pageTitle;
  final String typeId;

  const WorkListPage({
    super.key,
    required this.pageTitle,
    required this.typeId,
  });

  @override
  State<WorkListPage> createState() => _WorkListPageState();
}

class _WorkListPageState extends State<WorkListPage>
    with SingleTickerProviderStateMixin {
  final Dio _dio = Dio();
  bool isLoading = true;
  List<WorkOrder> workOrders = [];
  String? roleId;
  String? savedRoleId;
  String? addWork;
  String? startAndStop;
  List<MaterialData> materials = [];
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool isWorkStarted = false;
  @override
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    _initPage();
  }

  Future<void> _initPage() async {
    await _loadRoleIdService();
    await _loadAddPermission();
    await _loadStartAndStopPermission();
    await _fetchWorkList();
    await _fetchWorkStatus();
    await _fetchMaterials();
  }

  Future<void> _loadRoleIdService() async {
    final httpService = HttpService();
    final roleModel = await httpService.getRoleId();

    if (roleModel != null && roleModel.status == "success") {
      setState(() {
        roleId = roleModel.data.role;
      });
      log("✅ Role ID from API: $roleId");
    } else {
      roleId = await Common.getSharedPref("roleId") ?? "2";
      log("⚠️ Using fallback Role ID: $roleId");
    }
  }

  Future<void> _fetchMaterials() async {
    try {
      final httpService = HttpService();
      final materialModel = await HttpService.getMaterials();

      if (materialModel != null && materialModel.status == true) {
        setState(() {
          materials = materialModel.data ?? [];
        });
        log("✅ Materials fetched successfully — Count: ${materials.length}");
      } else {
        log("⚠️ Failed to fetch materials — API returned null or false status");
      }
    } catch (e) {
      log("❌ Error fetching materials: $e");
    }
  }

  Future<bool> _loadAddPermission() async {
    final prefs = await SharedPreferences.getInstance();
    final addWork = prefs.getString("add work") == "true";
    //log("Role ID Loaded in WorkListPage: $addWork");
    return addWork;
  }

  Future<bool> _loadStartAndStopPermission() async {
    final prefs = await SharedPreferences.getInstance();
    final startAndStop = prefs.getString("start and stop work") == "true";
    log("Start And Stop: $startAndStop");
    return startAndStop;
  }

  void _showWorkInProgressDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info, color: Colors.orange),
            SizedBox(width: 8),
            Text("Work In Progress"),
          ],
        ),
        content: const Text(
          "You already have a work in progress. Please complete or stop the current work before starting a new one.",
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchWorkList() async {
    setState(() => isLoading = true);
    final today = DateTime.now().toIso8601String().split('T').first;
    final staffId = await Common.getSharedPref("staff_id") ?? "1";
    //roleId = await Common.getSharedPref("roleId") ?? "1";
    try {
      final httpService = HttpService();
      final model = await httpService.getWorkList(
        staffId,
        today,
        widget.typeId,
      );
      if (model != null && model.data?.lists != null) {
        setState(() {
          workOrders = model.data!.lists!;
        });
      }
    } catch (e) {
      log("Error fetching work list: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchWorkStatus() async {
    try {
      final httpService = HttpService();
      final currentStatus = await httpService.checkCurrentWorkStatus();

      if (currentStatus != null) {
        setState(() {
          isWorkStarted = currentStatus.isStarted;
        });
        log(
          "Work status fetched - isStarted: $isWorkStarted, message: ${currentStatus.message}",
        );
      } else {
        log("Failed to fetch work status - response is null");
        setState(() {
          isWorkStarted = false;
        });
      }
    } catch (e) {
      log("Error fetching work status: $e");
      setState(() {
        isWorkStarted = false;
      });
    }
  }

  void _launchPhone(String phoneNumber) async {
    final Uri telUri = Uri.parse('tel:$phoneNumber');
    await launchUrl(telUri, mode: LaunchMode.externalApplication);
  }

  Future<void> _confirmAction(
    String title,
    WorkOrder work,
    String action,
  ) async {
    final String? workId = work.workOrderID;
    if (workId == null) return;

    String? selectedProduct;
    String? selectedStatus = "New";
    String? selectedMilestone;
    String? selectedCustomerId;
    final List<String> statusOptions = [
      "New",
      "In Progress",
      "Completed",
      "On Hold",
      "Cancelled",
    ];

    List<WorkType> workTypes = [];
    List<MaterialData> materialsList = [];

    // Initialize selectedMaterials with existing add_products if available
    List<Map<String, dynamic>> selectedMaterials =
        work.addProducts?.map<Map<String, dynamic>>((product) {
              final String qty = (product.consumedQty != null && product.consumedQty!.isNotEmpty)
                  ? product.consumedQty!
                  : ((product.quantity != null && product.quantity!.isNotEmpty)
                      ? product.quantity!
                      : "1");
              final String rateVal = (product.unitPrice != null && product.unitPrice!.isNotEmpty)
                  ? product.unitPrice!
                  : ((product.rate != null && product.rate!.isNotEmpty)
                      ? product.rate!
                      : "0");
              return <String, dynamic>{
                "material_id": product.productId ?? "",
                "material_name": product.productName ?? "",
                "product_name": product.productName ?? "",
                "unit_price": rateVal,
                "rate": rateVal,
                "consumed_qty": qty,
                "quantity": qty,
                "total_price": product.amount ?? "0",
                "amount": product.amount ?? "0",
                "stock": product.currentStock ?? "999",
                "is_existing": true,
              };
            }).toList() ??
            <Map<String, dynamic>>[];

    bool isLoadingWorkTypes = true;
    bool isLoadingMaterials = true;

    final latestHistory =
        work.history?.isNotEmpty == true ? work.history!.last : null;
    PipelineProgress? firstPendingMilestone;

    if (latestHistory?.pipelineProgress != null &&
        latestHistory!.pipelineProgress!.isNotEmpty) {
      try {
        firstPendingMilestone = latestHistory.pipelineProgress!.firstWhere(
          (p) => p.status == 0,
          orElse: () => PipelineProgress(),
        );
      } catch (e) {
        firstPendingMilestone = null;
      }
    }

    if (firstPendingMilestone != null &&
        (firstPendingMilestone.name?.isNotEmpty ?? false)) {
      selectedMilestone = firstPendingMilestone.name!;
    }
    selectedCustomerId = work.custId ?? work.custId;

    final TextEditingController remarkController = TextEditingController();

    Future<void> _loadWorkTypes() async {
      try {
        final httpService = HttpService();
        final workTypeModel = await httpService.getWorkType();
        if (workTypeModel != null && workTypeModel.data.isNotEmpty) {
          workTypes = workTypeModel.data;
        }
      } catch (e) {
        log("❌ Error loading work types: $e");
      } finally {
        isLoadingWorkTypes = false;
      }
    }

    Future<void> _loadMaterials() async {
      try {
        final httpService = HttpService();
        final materialModel = await HttpService.getMaterials();
        if (materialModel != null && materialModel.status == true) {
          materialsList = materialModel.data ?? [];
        }
      } catch (e) {
        log("❌ Error loading materials: $e");
      } finally {
        isLoadingMaterials = false;
      }
    }

    await Future.wait([_loadWorkTypes(), _loadMaterials()]);
    if (workTypes.isNotEmpty) {
      selectedProduct = workTypes.first.id;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void updateQuantity(int index, bool increase) {
              if (selectedMaterials[index]["is_existing"] == true) return;
              final stock =
                  int.tryParse(selectedMaterials[index]["stock"].toString()) ??
                      0;
              int quantity = int.tryParse(
                    selectedMaterials[index]["quantity"].toString(),
                  ) ??
                  0;
              final double unitPrice = double.tryParse(
                    selectedMaterials[index]["unit_price"].toString(),
                  ) ??
                  0.0;

              if (increase) {
                if (quantity >= stock &&
                    !selectedMaterials[index]["is_existing"]) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Cannot exceed available stock ($stock)."),
                    ),
                  );
                  return;
                }
                quantity++;
              } else {
                if (quantity > 1) {
                  quantity--;
                } else {
                  return;
                }
              }
              selectedMaterials[index]["quantity"] = quantity.toString();
              selectedMaterials[index]["total_price"] =
                  (unitPrice * quantity).toStringAsFixed(2);
              selectedMaterials[index]["amount"] =
                  (unitPrice * quantity).toStringAsFixed(2);
              setState(() {});
            }

            void addMaterial(MaterialData material) {
              final existingIndex = selectedMaterials.indexWhere(
                (m) => m["material_id"] == material.materialId,
              );
              if (existingIndex != -1) {
                updateQuantity(existingIndex, true);
              } else {
                final double unitPrice =
                    double.tryParse(material.unitPrice ?? "0") ?? 0.0;
                selectedMaterials.add(<String, dynamic>{
                  "material_id": material.materialId,
                  "material_name": material.materialName,
                  "product_name": material.materialName,
                  "unit_price": material.unitPrice ?? "0",
                  "rate": material.unitPrice ?? "0",
                  "quantity": "1",
                  "total_price": unitPrice.toStringAsFixed(2),
                  "amount": unitPrice.toStringAsFixed(2),
                  "stock": material.currentStock ?? "0",
                  "is_existing": false,
                });
                setState(() {});
              }
            }

            void removeMaterial(int index) {
              if (selectedMaterials[index]["is_existing"] == true) return;
              selectedMaterials.removeAt(index);
              setState(() {});
            }

            return AlertDialog(
              title: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2a86c9),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Are you sure you want to proceed?"),
                    const SizedBox(height: 16),

                    if (isLoadingWorkTypes)
                      const Center(child: CircularProgressIndicator())
                    else if (selectedProduct != null && workTypes.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Product",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              "${workTypes.first.productName} (${workTypes.first.productType})",
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 12),
                    if (selectedMilestone != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Milestone",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              selectedMilestone!,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 16),

                    // Show existing materials info if available
                    if (work.addProducts?.isNotEmpty == true)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Existing Materials",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${work.addProducts!.length} material(s) already added",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),

                    const Text(
                      "Select Materials",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<MaterialData>(
                      value: null,
                      hint: const Text("Select Materials"),
                      isExpanded: true,
                      items: materialsList.map((mat) {
                        final stock =
                            int.tryParse(mat.currentStock ?? "0") ?? 0;
                        return DropdownMenuItem<MaterialData>(
                          enabled: stock > 0,
                          value: mat,
                          child: Text(
                            "${mat.materialName} (Stock: $stock)",
                            style: TextStyle(
                              color: stock > 0 ? Colors.black : Colors.grey,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (mat) {
                        if (mat != null) addMaterial(mat);
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    if (selectedMaterials.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...selectedMaterials.asMap().entries.map(
                            (entry) {
                              final index = entry.key;
                              final mat = entry.value;
                              final isExisting = mat["is_existing"] == true;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isExisting
                                      ? Colors.green.shade50
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isExisting
                                        ? Colors.green.shade200
                                        : Colors.grey.shade200,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            mat["material_name"] ?? mat["product_name"] ?? "",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: isExisting
                                                  ? Colors.green.shade900
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ),
                                        if (isExisting)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              "Existing",
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        if (isExisting)
                                          Text(
                                            "Qty: ${mat["consumed_qty"] ?? mat["quantity"] ?? "1"}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Colors.black87,
                                            ),
                                          )
                                        else
                                          Row(
                                            children: [
                                              InkWell(
                                                onTap: () => updateQuantity(
                                                  index,
                                                  false,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: const Icon(
                                                  Icons.remove_circle_outline,
                                                  color: Color(0xFFE57373),
                                                  size: 24,
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                ),
                                                child: Text(
                                                  mat["quantity"].toString(),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () => updateQuantity(
                                                  index,
                                                  true,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: const Icon(
                                                  Icons.add_circle_outline,
                                                  color: Color(0xFF81C784),
                                                  size: 24,
                                                ),
                                              ),
                                            ],
                                          ),
                                        Row(
                                          children: [
                                            Text(
                                              "₹${mat["total_price"] ?? mat["amount"] ?? "0"}",
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            if (!isExisting) ...[
                                              const SizedBox(width: 12),
                                              InkWell(
                                                onTap: () =>
                                                    removeMaterial(index),
                                                child: const Icon(
                                                  Icons.delete_outline,
                                                  color: Color(0xFFE57373),
                                                  size: 22,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ).toList(),
                          Container(
                            margin: const EdgeInsets.only(top: 2, bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Total Amount",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  "₹${selectedMaterials.fold<double>(0.0, (sum, mat) => sum + (double.tryParse(mat["total_price"].toString()) ?? 0.0)).toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 16),
                    const Text(
                      "Status",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      items: statusOptions.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => selectedStatus = value),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Remarks",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: remarkController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Enter remarks...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () => Navigator.pop(context, false),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2a86c9),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (selectedProduct == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please fill all required fields."),
                        ),
                      );
                      return;
                    }
                    Navigator.pop(context, true);
                  },
                  child: const Text("Confirm"),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed == true) {
      await _performWorkAction(
        workId,
        action,
        selectedStatus!,
        remarkController.text,
        selectedMilestone,
        selectedProduct,
        selectedMaterials,
        selectedCustomerId,
      );
    }
  }

  Future<void> _confirmActionStop(
    String title,
    WorkOrder work,
    String action,
  ) async {
    final String? workId = work.workOrderID;
    if (workId == null) return;

    String? selectedProduct;
    String? selectedStatus = "In Progress";
    String? selectedMilestone;
    String? selectedCustomerId;
    final List<String> statusOptions = [
      "In Progress",
      "Completed",
      "On Hold",
      "Cancelled",
    ];

    List<WorkType> workTypes = [];
    List<MaterialData> materialsList = [];

    // Initialize selectedMaterials with existing add_products if available
    List<Map<String, dynamic>> selectedMaterials =
        work.addProducts?.map<Map<String, dynamic>>((product) {
              final String qty = (product.consumedQty != null && product.consumedQty!.isNotEmpty)
                  ? product.consumedQty!
                  : ((product.quantity != null && product.quantity!.isNotEmpty)
                      ? product.quantity!
                      : "1");
              final String rateVal = (product.unitPrice != null && product.unitPrice!.isNotEmpty)
                  ? product.unitPrice!
                  : ((product.rate != null && product.rate!.isNotEmpty)
                      ? product.rate!
                      : "0");
              return <String, dynamic>{
                "material_id": product.productId ?? "",
                "material_name": product.productName ?? "",
                "product_name": product.productName ?? "",
                "unit_price": rateVal,
                "rate": rateVal,
                "consumed_qty": qty,
                "quantity": qty,
                "total_price": product.amount ?? "0",
                "amount": product.amount ?? "0",
                "stock": product.currentStock ?? "999",
                "is_existing": true,
              };
            }).toList() ??
            <Map<String, dynamic>>[];

    bool isLoadingWorkTypes = true;
    bool isLoadingMaterials = true;

    final latestHistory =
        work.history?.isNotEmpty == true ? work.history!.last : null;
    PipelineProgress? firstPendingMilestone;

    if (latestHistory?.pipelineProgress != null &&
        latestHistory!.pipelineProgress!.isNotEmpty) {
      try {
        firstPendingMilestone = latestHistory.pipelineProgress!.firstWhere(
          (p) => p.status == 0,
          orElse: () => PipelineProgress(),
        );
      } catch (e) {
        firstPendingMilestone = null;
      }
    }

    if (firstPendingMilestone != null &&
        (firstPendingMilestone.name?.isNotEmpty ?? false)) {
      selectedMilestone = firstPendingMilestone.name!;
    }
    selectedCustomerId = work.custId ?? work.custId;

    final TextEditingController remarkController = TextEditingController();

    Future<void> _loadWorkTypes() async {
      try {
        final httpService = HttpService();
        final workTypeModel = await httpService.getWorkType();
        if (workTypeModel != null && workTypeModel.data.isNotEmpty) {
          workTypes = workTypeModel.data;
          selectedProduct = workTypes.first.id;
        }
      } catch (e) {
        log("❌ Error loading work types: $e");
      } finally {
        isLoadingWorkTypes = false;
      }
    }

    Future<void> _loadMaterials() async {
      try {
        final httpService = HttpService();
        final materialModel = await HttpService.getMaterials();
        if (materialModel != null && materialModel.status == true) {
          materialsList = materialModel.data ?? [];
        }
      } catch (e) {
        log("❌ Error loading materials: $e");
      } finally {
        isLoadingMaterials = false;
      }
    }

    await Future.wait([_loadWorkTypes(), _loadMaterials()]);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void updateQuantity(int index, bool increase) {
              if (selectedMaterials[index]["is_existing"] == true) return;
              final stock =
                  int.tryParse(selectedMaterials[index]["stock"].toString()) ??
                      0;
              int quantity = int.tryParse(
                    selectedMaterials[index]["quantity"].toString(),
                  ) ??
                  0;
              final double unitPrice = double.tryParse(
                    selectedMaterials[index]["unit_price"].toString(),
                  ) ??
                  0.0;

              if (increase) {
                if (quantity >= stock &&
                    !selectedMaterials[index]["is_existing"]) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Cannot exceed available stock ($stock)."),
                    ),
                  );
                  return;
                }
                quantity++;
              } else {
                if (quantity > 1) {
                  quantity--;
                } else {
                  return;
                }
              }
              selectedMaterials[index]["quantity"] = quantity.toString();
              selectedMaterials[index]["total_price"] =
                  (unitPrice * quantity).toStringAsFixed(2);
              selectedMaterials[index]["amount"] =
                  (unitPrice * quantity).toStringAsFixed(2);
              setState(() {});
            }

            void addMaterial(MaterialData material) {
              final existingIndex = selectedMaterials.indexWhere(
                (m) => m["material_id"] == material.materialId,
              );
              if (existingIndex != -1) {
                updateQuantity(existingIndex, true);
              } else {
                final double unitPrice =
                    double.tryParse(material.unitPrice ?? "0") ?? 0.0;
                selectedMaterials.add(<String, dynamic>{
                  "material_id": material.materialId,
                  "material_name": material.materialName,
                  "product_name": material.materialName,
                  "unit_price": material.unitPrice ?? "0",
                  "rate": material.unitPrice ?? "0",
                  "quantity": "1",
                  "total_price": unitPrice.toStringAsFixed(2),
                  "amount": unitPrice.toStringAsFixed(2),
                  "stock": material.currentStock ?? "0",
                  "is_existing": false,
                });
                setState(() {});
              }
            }

            void removeMaterial(int index) {
              if (selectedMaterials[index]["is_existing"] == true) return;
              selectedMaterials.removeAt(index);
              setState(() {});
            }

            return AlertDialog(
              title: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2a86c9),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Are you sure you want to proceed?"),
                    const SizedBox(height: 16),

                    if (isLoadingWorkTypes)
                      const Center(child: CircularProgressIndicator())
                    else if (workTypes.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Product",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              "${workTypes.first.productName} (${workTypes.first.productType})",
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      )
                    else
                      const Text(
                        "No products available",
                        style: TextStyle(color: Colors.grey),
                      ),

                    const SizedBox(height: 12),

                    if (selectedMilestone != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Milestone",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              selectedMilestone!,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          "No pending milestones",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Show existing materials info if available
                    if (work.addProducts?.isNotEmpty == true)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Existing Materials",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${work.addProducts!.length} material(s) already added",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),

                    const Text(
                      "Select Materials",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),

                    if (isLoadingMaterials)
                      const Center(child: CircularProgressIndicator())
                    else if (materialsList.isNotEmpty)
                      DropdownButtonFormField<MaterialData>(
                        value: null,
                        hint: const Text("Select Materials"),
                        isExpanded: true,
                        items: materialsList.map((mat) {
                          final stock =
                              int.tryParse(mat.currentStock ?? "0") ?? 0;
                          return DropdownMenuItem<MaterialData>(
                            enabled: stock > 0,
                            value: mat,
                            child: Text(
                              "${mat.materialName} (Stock: $stock)",
                              style: TextStyle(
                                color: stock > 0 ? Colors.black : Colors.grey,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (mat) {
                          if (mat != null) addMaterial(mat);
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      )
                    else
                      const Text(
                        "No materials available",
                        style: TextStyle(color: Colors.grey),
                      ),

                    const SizedBox(height: 10),

                    if (selectedMaterials.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...selectedMaterials.asMap().entries.map(
                            (entry) {
                              final index = entry.key;
                              final mat = entry.value;
                              final isExisting = mat["is_existing"] == true;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isExisting
                                      ? Colors.green.shade50
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isExisting
                                        ? Colors.green.shade200
                                        : Colors.grey.shade200,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            mat["material_name"] ?? mat["product_name"] ?? "",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: isExisting
                                                  ? Colors.green.shade900
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ),
                                        if (isExisting)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              "Existing",
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        if (isExisting)
                                          Text(
                                            "Qty: ${mat["consumed_qty"] ?? mat["quantity"] ?? "1"}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Colors.black87,
                                            ),
                                          )
                                        else
                                          Row(
                                            children: [
                                              InkWell(
                                                onTap: () => updateQuantity(
                                                  index,
                                                  false,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: const Icon(
                                                  Icons.remove_circle_outline,
                                                  color: Color(0xFFE57373),
                                                  size: 24,
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                ),
                                                child: Text(
                                                  mat["quantity"].toString(),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () => updateQuantity(
                                                  index,
                                                  true,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: const Icon(
                                                  Icons.add_circle_outline,
                                                  color: Color(0xFF81C784),
                                                  size: 24,
                                                ),
                                              ),
                                            ],
                                          ),
                                        Row(
                                          children: [
                                            Text(
                                              "₹${mat["total_price"] ?? mat["amount"] ?? "0"}",
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            if (!isExisting) ...[
                                              const SizedBox(width: 12),
                                              InkWell(
                                                onTap: () =>
                                                    removeMaterial(index),
                                                child: const Icon(
                                                  Icons.delete_outline,
                                                  color: Color(0xFFE57373),
                                                  size: 22,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ).toList(),
                          Container(
                            margin: const EdgeInsets.only(top: 2, bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Total Amount",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  "₹${selectedMaterials.fold<double>(0.0, (sum, mat) => sum + (double.tryParse(mat["total_price"].toString()) ?? 0.0)).toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 16),

                    const Text(
                      "Status",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),

                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      hint: const Text("Select Status"),
                      items: statusOptions.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => selectedStatus = value),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      "Remarks",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),

                    TextField(
                      controller: remarkController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Enter remarks...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () => Navigator.pop(context, false),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2a86c9),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (selectedProduct == null || selectedStatus == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please fill all required fields."),
                        ),
                      );
                      return;
                    }
                    Navigator.pop(context, true);
                  },
                  child: const Text("Confirm"),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed == true) {
      await _performWorkActionStop(
        workId,
        action,
        selectedStatus!,
        remarkController.text,
        selectedMilestone,
        selectedProduct,
        selectedMaterials,
        selectedCustomerId,
      );
    }
  }

  Future<void> _confirmActionRestart(
    String title,
    WorkOrder work,
    String action,
  ) async {
    final String? workId = work.workOrderID;
    if (workId == null) return;

    String? selectedStatus = "On Hold";
    String? selectedMilestone;
    String? selectedProduct;

    // Initialize selectedMaterials with existing add_products if available
    List<Map<String, dynamic>> selectedMaterials =
        work.addProducts?.map<Map<String, dynamic>>((product) {
              final String qty = (product.consumedQty != null && product.consumedQty!.isNotEmpty)
                  ? product.consumedQty!
                  : ((product.quantity != null && product.quantity!.isNotEmpty)
                      ? product.quantity!
                      : "1");
              final String rateVal = (product.unitPrice != null && product.unitPrice!.isNotEmpty)
                  ? product.unitPrice!
                  : ((product.rate != null && product.rate!.isNotEmpty)
                      ? product.rate!
                      : "0");
              return <String, dynamic>{
                "material_id": product.productId ?? "",
                "material_name": product.productName ?? "",
                "product_name": product.productName ?? "",
                "unit_price": rateVal,
                "rate": rateVal,
                "consumed_qty": qty,
                "quantity": qty,
                "total_price": product.amount ?? "0",
                "amount": product.amount ?? "0",
                "stock": product.currentStock ?? "999",
                "is_existing": true,
              };
            }).toList() ??
            <Map<String, dynamic>>[];

    String? selectedCustomerId;
    final List<String> statusOptions = [
      "New",
      "In Progress",
      "Completed",
      "On Hold",
      "Cancelled",
    ];

    List<WorkType> workTypes = [];
    List<MaterialData> materialsList = [];
    bool isLoadingWorkTypes = true;
    bool isLoadingMaterials = true;

    final latestHistory =
        work.history?.isNotEmpty == true ? work.history!.last : null;
    PipelineProgress? firstPendingMilestone;

    if (latestHistory?.pipelineProgress != null &&
        latestHistory!.pipelineProgress!.isNotEmpty) {
      try {
        firstPendingMilestone = latestHistory.pipelineProgress!.firstWhere(
          (p) => p.status == 0,
          orElse: () => PipelineProgress(),
        );
      } catch (e) {
        firstPendingMilestone = null;
      }
    }

    if (firstPendingMilestone != null &&
        (firstPendingMilestone.name?.isNotEmpty ?? false)) {
      selectedMilestone = firstPendingMilestone.name!;
    }
    selectedCustomerId = work.custId ?? work.custId;

    final TextEditingController remarkController = TextEditingController();

    Future<void> _loadWorkTypes() async {
      try {
        final httpService = HttpService();
        final workTypeModel = await httpService.getWorkType();
        if (workTypeModel != null && workTypeModel.data.isNotEmpty) {
          workTypes = workTypeModel.data;
          selectedProduct = workTypes.first.id;
        }
      } catch (e) {
        log("Error loading work types: $e");
      } finally {
        isLoadingWorkTypes = false;
      }
    }

    Future<void> _loadMaterials() async {
      try {
        final httpService = HttpService();
        final materialModel = await HttpService.getMaterials();
        if (materialModel != null && materialModel.status == true) {
          materialsList = materialModel.data ?? [];
        }
      } catch (e) {
        log("Error loading materials: $e");
      } finally {
        isLoadingMaterials = false;
      }
    }

    await Future.wait([_loadWorkTypes(), _loadMaterials()]);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void updateQuantity(int index, bool increase) {
              if (selectedMaterials[index]["is_existing"] == true) return;
              final stock =
                  int.tryParse(selectedMaterials[index]["stock"].toString()) ??
                      0;
              int quantity = int.tryParse(
                    selectedMaterials[index]["quantity"].toString(),
                  ) ??
                  0;
              final double unitPrice = double.tryParse(
                    selectedMaterials[index]["unit_price"].toString(),
                  ) ??
                  0.0;

              if (increase) {
                if (quantity >= stock &&
                    !selectedMaterials[index]["is_existing"]) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Cannot exceed available stock ($stock)."),
                    ),
                  );
                  return;
                }
                quantity++;
              } else {
                if (quantity > 1) {
                  quantity--;
                } else {
                  return;
                }
              }
              selectedMaterials[index]["quantity"] = quantity.toString();
              selectedMaterials[index]["total_price"] =
                  (unitPrice * quantity).toStringAsFixed(2);
              selectedMaterials[index]["amount"] =
                  (unitPrice * quantity).toStringAsFixed(2);
              setState(() {});
            }

            void addMaterial(MaterialData material) {
              final existingIndex = selectedMaterials.indexWhere(
                (m) => m["material_id"] == material.materialId,
              );
              if (existingIndex != -1) {
                updateQuantity(existingIndex, true);
              } else {
                final double unitPrice =
                    double.tryParse(material.unitPrice ?? "0") ?? 0.0;
                selectedMaterials.add(<String, dynamic>{
                  "material_id": material.materialId,
                  "material_name": material.materialName,
                  "product_name": material.materialName,
                  "unit_price": material.unitPrice ?? "0",
                  "rate": material.unitPrice ?? "0",
                  "quantity": "1",
                  "total_price": unitPrice.toStringAsFixed(2),
                  "amount": unitPrice.toStringAsFixed(2),
                  "stock": material.currentStock ?? "0",
                  "is_existing": false,
                });
                setState(() {});
              }
            }

            void removeMaterial(int index) {
              if (selectedMaterials[index]["is_existing"] == true) return;
              selectedMaterials.removeAt(index);
              setState(() {});
            }

            return AlertDialog(
              title: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2a86c9),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Are you sure you want to proceed?"),
                    const SizedBox(height: 16),
                    if (isLoadingWorkTypes)
                      const Center(child: CircularProgressIndicator())
                    else if (selectedProduct != null && workTypes.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Product",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              "${workTypes.first.productName} (${workTypes.first.productType})",
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      )
                    else
                      const Text(
                        "No products available",
                        style: TextStyle(color: Colors.grey),
                      ),
                    const SizedBox(height: 12),
                    if (selectedMilestone != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Milestone",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              selectedMilestone!,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          "No pending milestones",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      hint: const Text("Select Status"),
                      items: statusOptions
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            ),
                          )
                          .toList(),
                      onChanged: (val) => setState(() => selectedStatus = val),
                      decoration: InputDecoration(
                        labelText: "Work Status",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (work.addProducts?.isNotEmpty == true)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Existing Materials",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${work.addProducts!.length} material(s) already added",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    const Text(
                      "Select Materials",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (isLoadingMaterials)
                      const Center(child: CircularProgressIndicator())
                    else if (materialsList.isNotEmpty)
                      DropdownButtonFormField<MaterialData>(
                        value: null,
                        hint: const Text("Select Materials"),
                        isExpanded: true,
                        items: materialsList.map((mat) {
                          final stock =
                              int.tryParse(mat.currentStock ?? "0") ?? 0;
                          return DropdownMenuItem<MaterialData>(
                            enabled: stock > 0,
                            value: mat,
                            child: Text(
                              "${mat.materialName} (Stock: $stock)",
                              style: TextStyle(
                                color: stock > 0 ? Colors.black : Colors.grey,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (mat) {
                          if (mat != null) addMaterial(mat);
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      )
                    else
                      const Text(
                        "No materials available",
                        style: TextStyle(color: Colors.grey),
                      ),
                    const SizedBox(height: 10),
                    if (selectedMaterials.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...selectedMaterials.asMap().entries.map(
                            (entry) {
                              final index = entry.key;
                              final mat = entry.value;
                              final isExisting = mat["is_existing"] == true;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isExisting
                                      ? Colors.green.shade50
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isExisting
                                        ? Colors.green.shade200
                                        : Colors.grey.shade200,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            mat["material_name"] ?? mat["product_name"] ?? "",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: isExisting
                                                  ? Colors.green.shade900
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ),
                                        if (isExisting)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              "Existing",
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        if (isExisting)
                                          Text(
                                            "Qty: ${mat["consumed_qty"] ?? mat["quantity"] ?? "1"}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Colors.black87,
                                            ),
                                          )
                                        else
                                          Row(
                                            children: [
                                              InkWell(
                                                onTap: () => updateQuantity(
                                                  index,
                                                  false,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: const Icon(
                                                  Icons.remove_circle_outline,
                                                  color: Color(0xFFE57373),
                                                  size: 24,
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                ),
                                                child: Text(
                                                  mat["quantity"].toString(),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () => updateQuantity(
                                                  index,
                                                  true,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: const Icon(
                                                  Icons.add_circle_outline,
                                                  color: Color(0xFF81C784),
                                                  size: 24,
                                                ),
                                              ),
                                            ],
                                          ),
                                        Row(
                                          children: [
                                            Text(
                                              "₹${mat["total_price"] ?? mat["amount"] ?? "0"}",
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            if (!isExisting) ...[
                                              const SizedBox(width: 12),
                                              InkWell(
                                                onTap: () =>
                                                    removeMaterial(index),
                                                child: const Icon(
                                                  Icons.delete_outline,
                                                  color: Color(0xFFE57373),
                                                  size: 22,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ).toList(),
                          Container(
                            margin: const EdgeInsets.only(top: 2, bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Total Amount",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  "₹${selectedMaterials.fold<double>(0.0, (sum, mat) => sum + (double.tryParse(mat["total_price"].toString()) ?? 0.0)).toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: remarkController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Enter remarks...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedStatus == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Please select status.",
                          ),
                        ),
                      );
                      return;
                    }
                    Navigator.pop(context, true);
                  },
                  child: const Text("Confirm"),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed == true) {
      await _performWorkActionRestart(
          workId,
          action,
          selectedStatus!,
          remarkController.text,
          selectedMilestone,
          selectedProduct,
          selectedMaterials,
          selectedCustomerId);
    }
  }

  Future<void> _performWorkAction(
    String workId,
    String action,
    String status,
    String remarks,
    String? milestone,
    String? productId,
    List<Map<String, dynamic>> selectedMaterials,
    String? selectedCustomerId,
  ) async {
    final http = HttpService();
    Map<String, dynamic> response = {};

    try {
      if (action == "start") {
        response = await http.startWorkService(
          workId,
          remarks,
          milestone,
          productId,
          selectedMaterials,
          selectedCustomerId,
        );
      } else if (action == "pause") {
        response =
            await http.pauseWorkService(workId, status, remarks, milestone);
      } else if (action == "stop") {
        response = await http.stopWorkService(
          workId,
          status,
          remarks,
          milestone,
          productId,
          selectedMaterials,
          selectedCustomerId,
        );
      }
      if (response["status"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green.shade600,
            content: Text("Work $action successful!"),
          ),
        );
        _fetchWorkList();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(response["message"] ?? "Failed to $action work"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error performing $action: $e")));
    }
  }

  Future<void> _performWorkActionStop(
    String workId,
    String action,
    String status,
    String remarks,
    String? milestone,
    String? productId,
    List<Map<String, dynamic>> selectedMaterials,
    String? selectedCustomerId,
  ) async {
    final http = HttpService();
    Map<String, dynamic> response = {};

    try {
      if (action == "stop") {
        response = await http.stopWorkService(
          workId,
          status,
          remarks,
          milestone,
          productId,
          selectedMaterials,
          selectedCustomerId,
        );
      } else if (action == "pause") {
        response =
            await http.pauseWorkService(workId, status, remarks, milestone);
      }

      if (response["status"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green.shade600,
            content: Text("Work $action successful!"),
          ),
        );
        _fetchWorkList();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(response["message"] ?? "Failed to $action work"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error performing $action: $e")));
    }
  }

  Future<void> _performWorkActionRestart(
    String workId,
    String action,
    String status,
    String remarks,
    String? milestone,
    String? productId,
    List<Map<String, dynamic>> selectedMaterials,
    String? selectedCustomerId,
  ) async {
    final http = HttpService();
    Map<String, dynamic> response = {};

    try {
      if (action == "restart") {
        response = await http.startWorkService(
          workId,
          remarks,
          milestone,
          productId,
          selectedMaterials,
          selectedCustomerId,
        );
      } else if (action == "pause") {
        response =
            await http.pauseWorkService(workId, status, remarks, milestone);
      } else if (action == "stop") {
        response = await http.stopWorkService(
          workId,
          status,
          remarks,
          milestone,
          productId,
          selectedMaterials,
          selectedCustomerId,
        );
      }

      if (response["status"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green.shade600,
            content: Text("Work $action successful!"),
          ),
        );
        _fetchWorkList();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(response["message"] ?? "Failed to $action work"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error performing $action: $e")));
    }
  }

  Widget _buildWorkCard(WorkOrder work) {
    final Color statusColor = _getStatusChipColor(work.status);
    final Color cardColor = _getCardColor(work.status);
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [cardColor.withOpacity(0.95), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: statusColor.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0xFF2a86c9),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        work.customerName ?? "-",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  _iconButton(
                    Icons.remove_red_eye_rounded,
                    Colors.indigo,
                    () => _showViewDialog(work),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(
                    backgroundColor: statusColor,
                    label: Text(
                      work.status?.toUpperCase() ?? "-",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        color: Colors.black54,
                        size: 16,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        work.estimatedDatetime ?? "-",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 22),
              work.issueDescription != ""
                  ? _buildInfoRow(
                      Icons.dangerous,
                      'Issue: ${work.issueDescription ?? "-"}',
                      const Color.fromARGB(255, 255, 55, 55),
                    )
                  : SizedBox(),
              work.assignedServiceMan != ""
                  ? _buildInfoRow(
                      Icons.workspace_premium_sharp,
                      'Assigned To: ${work.assignedServiceMan ?? "-"}',
                      const Color.fromARGB(255, 158, 34, 196),
                    )
                  : SizedBox(),
              _buildInfoRow(
                Icons.phone,
                work.mobileNumber,
                Colors.teal,
                isPhone: true,
              ),
              work.location != ""
                  ? _buildInfoRow(
                      Icons.location_pin,
                      work.location,
                      Colors.deepOrangeAccent,
                    )
                  : SizedBox(),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (work.status == "New")
                    Row(
                      children: [
                        work.priority != ""
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: work.priority == "Low"
                                      ? Colors.blue.shade100
                                      : work.priority == "Medium"
                                          ? Colors.orange.shade100
                                          : work.priority == "High"
                                              ? Colors.red.shade100
                                              : Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  work.priority ?? "",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: work.priority == "Low"
                                        ? Colors.blue.shade800
                                        : work.priority == "Medium"
                                            ? Colors.orange.shade800
                                            : work.priority == "High"
                                                ? Colors.red.shade800
                                                : Colors.green.shade800,
                                  ),
                                ),
                              )
                            : SizedBox(),
                      ],
                    )
                  else
                    const SizedBox(),
                  if ((work.status == "New") && roleId != null && roleId == "3")
                    ElevatedButton.icon(
                      onPressed: () {
                        if (isWorkStarted) {
                          _showWorkInProgressDialog();
                        } else {
                          _confirmAction("Start Work", work, "start");
                        }
                      },
                      icon: const Icon(Icons.play_arrow_rounded, size: 18),
                      label: const Text("Start"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  const SizedBox(width: 6),
                  if (roleId == "2" && work.status != "Completed") ...[
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditWorkPage(
                              workOrderId: work.workOrderID ?? '',
                            ),
                          ),
                        ).then((value) {
                          if (value == true) _fetchWorkList();
                        });
                      },
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text("Edit", style: TextStyle(fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          67,
                          207,
                          241,
                        ),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        textStyle: const TextStyle(fontSize: 13),
                        minimumSize: const Size(0, 36),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Confirm Delete"),
                            content: const Text(
                              "Are you sure you want to delete this work order? This action cannot be undone.",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    160,
                                    48,
                                    40,
                                  ),
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Delete"),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          final httpService = HttpService();
                          final success = await httpService.deleteWorkOrder(
                            work.workOrderID ?? '',
                          );
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Work order deleted successfully",
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            _fetchWorkList();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Failed to delete work order",
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text(
                        "Delete",
                        style: TextStyle(fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          230,
                          114,
                          133,
                        ),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        textStyle: const TextStyle(fontSize: 13),
                        minimumSize: const Size(0, 36),
                      ),
                    ),
                  ] else if ((work.status == "In Progress") &&
                      roleId != null &&
                      roleId == "3")
                    ElevatedButton.icon(
                      onPressed: () =>
                          _confirmActionStop("Stop Work", work, "stop"),
                      icon: const Icon(Icons.stop, size: 18),
                      label: const Text("Stop"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 238, 15, 15),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    )
                  else if ((work.status == "On Hold") &&
                      roleId != null &&
                      roleId == "3")
                    ElevatedButton.icon(
                      onPressed: () {
                        if (isWorkStarted) {
                          _showWorkInProgressDialog();
                        } else {
                          _confirmActionRestart(
                            "Restart Work",
                            work,
                            "restart",
                          );
                        }
                      },
                      icon: const Icon(Icons.restart_alt, size: 18),
                      label: const Text("Restart"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          37,
                          182,
                          240,
                        ),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    )
                  // else if (roleId == "3")
                  //   Row(
                  //     children: const [
                  //       Icon(Icons.verified, color: Colors.green, size: 22),
                  //       SizedBox(width: 4),
                  //       Text(
                  //         "Completed",
                  //         style: TextStyle(
                  //           fontWeight: FontWeight.bold,
                  //           color: Colors.green,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color, size: 24),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String? value,
    Color color, {
    bool isPhone = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap:
                  isPhone && value != null ? () => _launchPhone(value) : null,
              child: Text(
                value ?? '-',
                style: TextStyle(
                  color: isPhone ? Colors.blueAccent : Colors.black87,
                  fontSize: 14,
                  decoration: isPhone ? TextDecoration.underline : null,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCardColor(String? status) {
    switch (status?.toLowerCase()) {
      case "new":
        return const Color(0xFFD7E9FF);
      case "assigned":
        return const Color(0xFFFFD6D6);
      case "in progress":
        return const Color(0xFFFFEFC2);
      case "completed":
        return const Color.fromARGB(255, 223, 247, 225);
      case "on hold":
        return const Color(0xFFFFE3B3);
      default:
        return Colors.grey.shade200;
    }
  }

  Color _getStatusChipColor(String? status) {
    switch (status?.toLowerCase()) {
      case "new":
        return Colors.blueAccent;
      case "assigned":
        return Colors.pinkAccent;
      case "in progress":
        return Colors.orangeAccent;
      case "completed":
        return Colors.green;
      case "on hold":
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  void _showViewDialog(WorkOrder work) {
    final latestHistory =
        work.history?.isNotEmpty == true ? work.history!.last : null;
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 600, maxWidth: 400),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFFF5F6FF), Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Center(
                            child: Column(
                              children: const [
                                Icon(
                                  Icons.assignment_rounded,
                                  size: 50,
                                  color: Color(0xFF2a86c9),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Work Details",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2a86c9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          _detailTile(
                            Icons.person,
                            "Customer",
                            work.customerName,
                            Colors.indigo,
                          ),
                          _detailTile(
                            Icons.phone,
                            "Phone",
                            work.mobileNumber,
                            Colors.teal,
                          ),
                          _detailTile(
                            Icons.home_work_outlined,
                            "Address",
                            work.address,
                            Colors.deepOrange,
                          ),
                          _detailTile(
                            Icons.category_rounded,
                            "Category",
                            work.workCategory,
                            Colors.purple,
                          ),
                          _detailTile(
                            Icons.laptop,
                            "Type",
                            work.workType,
                            Colors.blue,
                          ),
                          _detailTile(
                            Icons.calendar_month,
                            "Preferred",
                            work.preferredDateTime,
                            Colors.redAccent,
                          ),
                          const SizedBox(height: 16),
                          const Divider(thickness: 1.2),
                          const SizedBox(height: 8),
                          if (latestHistory?.pipelineProgress?.isNotEmpty ==
                              true) ...[
                            const Text(
                              "Pipeline Progress",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2a86c9),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 100,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: List.generate(
                                    latestHistory!.pipelineProgress!.length,
                                    (i) {
                                      final step =
                                          latestHistory.pipelineProgress![i];
                                      final isDone = step.status == 1;

                                      return Row(
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              DotIndicator(
                                                color: isDone
                                                    ? Colors.green
                                                    : Colors.grey,
                                                size: 16,
                                                child: isDone
                                                    ? const Icon(
                                                        Icons.check,
                                                        color: Colors.white,
                                                        size: 10,
                                                      )
                                                    : null,
                                              ),
                                              const SizedBox(height: 8),
                                              SizedBox(
                                                width: 80,
                                                child: Text(
                                                  step.name ?? "-",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                    color: isDone
                                                        ? Colors.green
                                                        : Colors.grey,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (i !=
                                              latestHistory.pipelineProgress!
                                                      .length -
                                                  1)
                                            Container(
                                              width: 40,
                                              height: 2,
                                              color: latestHistory
                                                          .pipelineProgress![
                                                              i + 1]
                                                          .status ==
                                                      1
                                                  ? Colors.green
                                                  : Colors.grey,
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Divider(thickness: 1.2),
                          ],
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Work Timeline",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2a86c9),
                                ),
                              ),
                              const SizedBox(height: 4),
                              SizedBox(
                                height: 140,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: FixedTimeline.tileBuilder(
                                    theme: TimelineThemeData(
                                      direction: Axis.horizontal,
                                      connectorTheme: const ConnectorThemeData(
                                        color: Color(0xFF2a86c9),
                                        thickness: 2,
                                      ),
                                      indicatorTheme: const IndicatorThemeData(
                                        size: 14,
                                        color: Color(0xFF2a86c9),
                                      ),
                                    ),
                                    builder: TimelineTileBuilder.connected(
                                      itemCount: work.history?.length ?? 0,
                                      connectionDirection:
                                          ConnectionDirection.before,
                                      contentsBuilder: (_, i) {
                                        final step = work.history![i];
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 6,
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                '${step.actionType ?? "-"} by ${step.valCreatedBy ?? "-"}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                step.actionTime ?? "-",
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      indicatorBuilder: (_, i) =>
                                          const DotIndicator(
                                        color: Color(0xFF2a86c9),
                                        size: 14,
                                      ),
                                      connectorBuilder: (_, i, __) =>
                                          const SolidLineConnector(
                                        color: Color(0xFF2a86c9),
                                        thickness: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.redAccent),
                        onPressed: () => Navigator.of(context).pop(),
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

  Widget _detailTile(IconData icon, String label, String? value, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "$label: ${value ?? '-'}",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Text(widget.pageTitle),
        backgroundColor: const Color(0xFF2a86c9),
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        actions: [
          roleId != "3"
              ? IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: "Add New Work",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateNewJobPage(),
                      ),
                    ).then((_) => _fetchWorkList());
                  },
                )
              : SizedBox(),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : workOrders.isEmpty
              ? const Center(
                  child: Text(
                    "No works found.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchWorkList,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: workOrders.length,
                    itemBuilder: (context, index) =>
                        _buildWorkCard(workOrders[index]),
                  ),
                ),
    );
  }
}

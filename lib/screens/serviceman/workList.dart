import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/lead_management/materialModel.dart';
import 'package:login2/models/serviceman/workModel.dart';
import 'package:login2/models/serviceman/workTypeModel.dart';
import 'package:login2/screens/serviceman/addWorkPage.dart';
import 'package:login2/screens/serviceman/editWorkPage.dart';
import 'package:intl/intl.dart';
import 'package:login2/service/service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timelines_plus/timelines_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class WorkListPage extends StatefulWidget {
  final String pageTitle;
  final String typeId;
  final bool excludeCompleted;

  const WorkListPage({
    super.key,
    required this.pageTitle,
    required this.typeId,
    this.excludeCompleted = false,
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
  String? currentUserId;
  String? currentStaffId;
  String? currentUserName;
  String? currentStaffName;
  final Set<String> _currentUserIdentifiers = {};
  List<MaterialData> materials = [];

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool isWorkStarted = false;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

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

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Safely parses JSON-encoded pipeline_name (or List/Map) into `List<PipelineProgress>`
  List<PipelineProgress> _parsePipelineStages(dynamic raw) {
    if (raw == null) return [];
    if (raw is String) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty ||
          trimmed == "null" ||
          trimmed == "[]" ||
          trimmed == "{}" ||
          trimmed.toLowerCase() == "n/a") {
        return [];
      }
      try {
        final decoded = jsonDecode(trimmed);
        return _parsePipelineStages(decoded);
      } catch (e) {
        log("Error decoding pipeline_name JSON string: $e");
        if (trimmed.contains(',')) {
          return trimmed
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .map((s) => PipelineProgress(name: s, status: 0))
              .toList();
        } else if (!trimmed.startsWith('{') && !trimmed.startsWith('[')) {
          return [PipelineProgress(name: trimmed, status: 0)];
        }
        return [];
      }
    }
    if (raw is List) {
      return raw
          .map((e) {
            if (e == null) return null;
            if (e is Map<String, dynamic>) {
              return PipelineProgress.fromJson(e);
            } else if (e is Map) {
              return PipelineProgress.fromJson(Map<String, dynamic>.from(e));
            } else if (e is String && e.trim().isNotEmpty) {
              final str = e.trim();
              if (str.startsWith('{') && str.endsWith('}')) {
                try {
                  final d = jsonDecode(str);
                  if (d is Map) {
                    return PipelineProgress.fromJson(
                        Map<String, dynamic>.from(d));
                  }
                } catch (_) {}
              }
              return PipelineProgress(name: str, status: 0);
            }
            return null;
          })
          .whereType<PipelineProgress>()
          .where((p) => p.name != null && p.name!.trim().isNotEmpty)
          .toList();
    }
    if (raw is Map<String, dynamic>) {
      return [PipelineProgress.fromJson(raw)];
    } else if (raw is Map) {
      return [PipelineProgress.fromJson(Map<String, dynamic>.from(raw))];
    }
    return [];
  }

  /// Retrieves pipeline stages associated with this work order and corresponding product
  List<PipelineProgress> _getPipelineStagesForWork({
    required WorkOrder work,
    String? selectedProductId,
    List<WorkType>? workTypes,
  }) {
    List<PipelineProgress> stages = [];

    // 1. Check if the work order itself has pipeline_name from api_workorders
    if (work.pipelineName != null && work.pipelineName!.trim().isNotEmpty) {
      stages = _parsePipelineStages(work.pipelineName);
    }

    // 2. Check if a corresponding product in addProducts has pipeline_name
    if (stages.isEmpty && work.addProducts != null && work.addProducts!.isNotEmpty) {
      if (selectedProductId != null && selectedProductId.isNotEmpty) {
        final matched = work.addProducts!.firstWhere(
          (p) =>
              (p.productId == selectedProductId || p.id == selectedProductId) &&
              p.pipelineName != null &&
              p.pipelineName!.trim().isNotEmpty,
          orElse: () => AddProduct(),
        );
        if (matched.pipelineName != null &&
            matched.pipelineName!.trim().isNotEmpty) {
          stages = _parsePipelineStages(matched.pipelineName);
        }
      }
      if (stages.isEmpty) {
        for (final prod in work.addProducts!) {
          if (prod.pipelineName != null && prod.pipelineName!.trim().isNotEmpty) {
            stages = _parsePipelineStages(prod.pipelineName);
            if (stages.isNotEmpty) break;
          }
        }
      }
    }

    // 3. Check corresponding WorkType from getWorkType() if matching selectedProductId
    if (stages.isEmpty && workTypes != null && workTypes.isNotEmpty) {
      if (selectedProductId != null && selectedProductId.isNotEmpty) {
        final matchedType = workTypes.firstWhere(
          (wt) =>
              wt.id == selectedProductId &&
              wt.pipelineName.trim().isNotEmpty,
          orElse: () => WorkType(
              id: '', productType: '', productName: '', pipelineName: ''),
        );
        if (matchedType.pipelineName.trim().isNotEmpty) {
          stages = _parsePipelineStages(matchedType.pipelineName);
        }
      }
      if (stages.isEmpty && work.workType != null && work.workType!.isNotEmpty) {
        final matchedType = workTypes.firstWhere(
          (wt) =>
              (wt.id == work.workType ||
                  wt.productName.toLowerCase() ==
                      work.workType!.toLowerCase()) &&
              wt.pipelineName.trim().isNotEmpty,
          orElse: () => WorkType(
              id: '', productType: '', productName: '', pipelineName: ''),
        );
        if (matchedType.pipelineName.trim().isNotEmpty) {
          stages = _parsePipelineStages(matchedType.pipelineName);
        }
      }
    }

    // 4. Fallback to history or effectivePipelineProgress if still empty
    if (stages.isEmpty) {
      if (work.history != null && work.history!.isNotEmpty) {
        for (int i = work.history!.length - 1; i >= 0; i--) {
          final p = work.history![i].pipelineProgress;
          if (p != null && p.isNotEmpty) {
            stages = p;
            break;
          }
        }
      }
      if (stages.isEmpty &&
          work.effectivePipelineProgress != null &&
          work.effectivePipelineProgress!.isNotEmpty) {
        stages = work.effectivePipelineProgress!;
      }
    } else {
      // Merge existing progress from history if available, but never downgrade a status 1 to 0
      final historyStages = work.effectivePipelineProgress;
      if (historyStages != null && historyStages.isNotEmpty) {
        final historyMap = <String, int>{
          for (var h in historyStages)
            if (h.name != null && h.name!.trim().isNotEmpty)
              h.name!.trim().toLowerCase(): h.status ?? 0
        };
        stages = stages.map((s) {
          final key = (s.name ?? "").trim().toLowerCase();
          final int? histStatus = historyMap[key];
          final int currentStatus = s.status ?? 0;
          final int historyStatus = histStatus ?? 0;
          final int finalStatus =
              (currentStatus == 1 || historyStatus == 1) ? 1 : 0;
          return PipelineProgress(
            name: s.name,
            status: finalStatus,
          );
        }).toList();
      }
    }

    return stages;
  }

  /// Gets user-friendly product display name
  String _getProductDisplayName({
    required WorkOrder work,
    String? selectedProductId,
    List<WorkType>? workTypes,
  }) {
    if (work.addProducts != null && work.addProducts!.isNotEmpty) {
      final matched = work.addProducts!.firstWhere(
        (p) =>
            (p.productId != null && p.productId == selectedProductId) ||
            (p.id != null && p.id == selectedProductId),
        orElse: () => work.addProducts!.first,
      );
      if (matched.productName != null && matched.productName!.isNotEmpty) {
        return matched.productName!;
      }
    }

    if (workTypes != null && workTypes.isNotEmpty) {
      final matchedWt = workTypes.firstWhere(
        (wt) => wt.id == selectedProductId,
        orElse: () => workTypes.first,
      );
      final pName = matchedWt.productName;
      final pType = matchedWt.productType;
      if (pName.isNotEmpty && pType.isNotEmpty) {
        return "$pName ($pType)";
      } else if (pName.isNotEmpty) {
        return pName;
      }
    }

    if (work.workCategory?.isNotEmpty == true) {
      return work.workCategory!;
    }
    if (work.workType?.isNotEmpty == true) {
      return work.workType!;
    }

    return "Product";
  }

  DateTime? _parseEstimatedDateTime(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    if (trimmed.isEmpty ||
        trimmed == "0000-00-00 00:00:00" ||
        trimmed == "0000-00-00" ||
        trimmed == "null" ||
        trimmed.toLowerCase() == "n/a") {
      return null;
    }
    final dt = DateTime.tryParse(trimmed);
    if (dt != null) return dt;

    final formats = [
      'yyyy-MM-dd HH:mm:ss',
      'yyyy-MM-dd HH:mm',
      'yyyy-MM-dd',
      'dd-MM-yyyy HH:mm:ss',
      'dd-MM-yyyy HH:mm',
      'dd-MM-yyyy',
      'dd/MM/yyyy HH:mm:ss',
      'dd/MM/yyyy HH:mm',
      'dd/MM/yyyy',
      'MM/dd/yyyy HH:mm:ss',
      'MM/dd/yyyy',
    ];
    for (final fmt in formats) {
      try {
        return DateFormat(fmt).parseLoose(trimmed);
      } catch (_) {}
    }
    return null;
  }

  bool _isWorkOverdue(WorkOrder work) {
    final status = (work.status ?? '').trim().toLowerCase();
    if (status.contains('completed')) {
      return false;
    }
    final estDate = _parseEstimatedDateTime(work.estimatedDatetime);
    if (estDate == null) {
      return false;
    }
    return estDate.isBefore(DateTime.now());
  }

  List<WorkOrder> get _filteredWorkOrders {
    var list = workOrders;
    if (widget.excludeCompleted ||
        widget.pageTitle.toLowerCase().contains("overdue")) {
      list = list.where((w) => _isWorkOverdue(w)).toList();
    }
    if (_searchQuery.trim().isEmpty) return list;
    final query = _searchQuery.toLowerCase().trim();
    return list.where((work) {
      final name = (work.customerName ?? "").toLowerCase();
      final phone = (work.mobileNumber ?? "").toLowerCase();
      final workId = (work.workOrderID ?? work.workOrderId ?? "").toLowerCase();
      final cat = (work.workCategory ?? "").toLowerCase();
      final issue = (work.issueDescription ?? "").toLowerCase();
      final loc = (work.location ?? work.address ?? "").toLowerCase();
      return name.contains(query) ||
          phone.contains(query) ||
          workId.contains(query) ||
          cat.contains(query) ||
          issue.contains(query) ||
          loc.contains(query);
    }).toList();
  }

  Future<void> _initPage() async {
    await _loadRoleIdService();
    await _loadUserInfo();
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

  Future<void> _loadUserInfo() async {
    currentUserId = await Common.getSharedPref("userId");
    final prefUserId2 = await Common.getSharedPref("user_id");
    currentStaffId = await Common.getSharedPref("staff_id");
    currentUserName = await Common.getSharedPref("name");
    currentStaffName = await Common.getSharedPref("staff_name");

    final Set<String> ids = {};
    void addClean(String? val) {
      if (val != null) {
        final t = val.trim().toLowerCase();
        if (t.isNotEmpty) ids.add(t);
      }
    }

    addClean(currentUserId);
    addClean(prefUserId2);
    addClean(currentStaffId);
    addClean(currentUserName);
    addClean(currentStaffName);

    try {
      final httpService = HttpService();
      final staffModel = await httpService.getStaffName();
      if (staffModel != null && staffModel.data.isNotEmpty) {
        final cUid = currentUserId?.trim().toLowerCase() ?? "";
        final cUid2 = prefUserId2?.trim().toLowerCase() ?? "";
        final cSid = currentStaffId?.trim().toLowerCase() ?? "";
        final cName = currentUserName?.trim().toLowerCase() ?? "";
        final cSName = currentStaffName?.trim().toLowerCase() ?? "";

        for (var staff in staffModel.data) {
          final sUid = staff.userId.trim().toLowerCase();
          final sSid = staff.staffId.trim().toLowerCase();
          final sName = staff.staffName.trim().toLowerCase();

          bool isMatch = false;
          if (cUid.isNotEmpty && sUid == cUid) isMatch = true;
          if (cUid2.isNotEmpty && sUid == cUid2) isMatch = true;
          if (cSid.isNotEmpty && sSid == cSid) isMatch = true;
          if (cName.isNotEmpty &&
              (sName == cName ||
                  sName.contains(cName) ||
                  cName.contains(sName))) {
            isMatch = true;
          }
          if (cSName.isNotEmpty &&
              (sName == cSName ||
                  sName.contains(cSName) ||
                  cSName.contains(sName))) {
            isMatch = true;
          }

          if (isMatch) {
            addClean(sUid);
            addClean(sSid);
            addClean(sName);
          }
        }
      }
    } catch (e) {
      log("Error loading staff data for user matching: $e");
    }

    if (mounted) {
      setState(() {
        _currentUserIdentifiers.clear();
        _currentUserIdentifiers.addAll(ids);
      });
    } else {
      _currentUserIdentifiers.clear();
      _currentUserIdentifiers.addAll(ids);
    }
    log("✅ User identifiers loaded: $_currentUserIdentifiers");
  }

  bool _isAssignedToCurrentUser(WorkOrder work) {
    if (_currentUserIdentifiers.isEmpty) {
      if (currentUserId != null && currentUserId!.trim().isNotEmpty) {
        _currentUserIdentifiers.add(currentUserId!.trim().toLowerCase());
      }
      if (currentStaffId != null && currentStaffId!.trim().isNotEmpty) {
        _currentUserIdentifiers.add(currentStaffId!.trim().toLowerCase());
      }
      if (currentUserName != null && currentUserName!.trim().isNotEmpty) {
        _currentUserIdentifiers.add(currentUserName!.trim().toLowerCase());
      }
      if (currentStaffName != null && currentStaffName!.trim().isNotEmpty) {
        _currentUserIdentifiers.add(currentStaffName!.trim().toLowerCase());
      }
    }

    if (_currentUserIdentifiers.isEmpty) return false;

    // 1. Check assignedStaffIds (comma-separated or single)
    final assignedStaffIds = work.assignedStaffIds?.trim().toLowerCase() ?? "";
    if (assignedStaffIds.isNotEmpty) {
      final ids = assignedStaffIds
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty);
      for (var id in ids) {
        if (_currentUserIdentifiers.contains(id)) {
          return true;
        }
      }
    }

    // 2. Check assignedServiceMan
    final assignedServiceMan =
        work.assignedServiceMan?.trim().toLowerCase() ?? "";
    if (assignedServiceMan.isNotEmpty) {
      if (_currentUserIdentifiers.contains(assignedServiceMan)) {
        return true;
      }
      for (var id in _currentUserIdentifiers) {
        if (id.length >= 3 &&
            (assignedServiceMan.contains(id) ||
                id.contains(assignedServiceMan))) {
          return true;
        }
      }
    }

    return false;
  }

  bool _canShowWorkActionButtons(WorkOrder work) {
    // 1. Role 3 (Serviceman) always sees action buttons as before
    if (roleId == "3") return true;

    // 2. Direct flag if backend indicates assigned role is 2
    if (work.assignedRoleId == "2") return true;

    // 3. Admin user (roleId == 2) when the work order is assigned to them
    if (roleId == "2" && _isAssignedToCurrentUser(work)) return true;

    return false;
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
        var list = model.data!.lists!;
        if (widget.excludeCompleted ||
            widget.pageTitle.toLowerCase().contains("overdue")) {
          list = list.where((w) => _isWorkOverdue(w)).toList();
        }
        setState(() {
          workOrders = list;
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

  bool _isPipelineSequential(List<Map<String, dynamic>> stages) {
    if (stages.isEmpty) return true;
    bool foundZero = false;
    for (final stage in stages) {
      final int st = (stage["status"] == 1) ? 1 : 0;
      if (st == 1 && foundZero) {
        return false;
      }
      if (st == 0) {
        foundZero = true;
      }
    }
    return true;
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

    // Complete pipeline progress that will be sent to backend
    List<Map<String, dynamic>> selectedPipelineProgress = [];

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
              final String qty = (product.consumedQty != null &&
                      product.consumedQty!.isNotEmpty)
                  ? product.consumedQty!
                  : ((product.quantity != null && product.quantity!.isNotEmpty)
                      ? product.quantity!
                      : "1");

              final String rateVal =
                  (product.unitPrice != null && product.unitPrice!.isNotEmpty)
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

    selectedCustomerId = work.custId;

    final TextEditingController remarkController = TextEditingController();

    // ---------------------------------------------------------
    // LOAD WORK TYPES
    // ---------------------------------------------------------
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

    // ---------------------------------------------------------
    // LOAD MATERIALS
    // ---------------------------------------------------------
    Future<void> _loadMaterials() async {
      try {
        final materialModel = await HttpService.getMaterialsProduct();

        if (materialModel != null && materialModel.status == true) {
          materialsList = materialModel.data ?? [];
        }
      } catch (e) {
        log("❌ Error loading materials: $e");
      } finally {
        isLoadingMaterials = false;
      }
    }

    await Future.wait([
      _loadWorkTypes(),
      _loadMaterials(),
    ]);

    // Associate selectedProduct with corresponding product of work order
    if (work.addProducts?.isNotEmpty == true &&
        work.addProducts!.first.productId?.isNotEmpty == true) {
      selectedProduct = work.addProducts!.first.productId;
    } else if (work.workType?.isNotEmpty == true && workTypes.isNotEmpty) {
      final matched = workTypes.firstWhere(
        (wt) =>
            wt.id == work.workType ||
            wt.productName?.toLowerCase() == work.workType?.toLowerCase(),
        orElse: () => workTypes.first,
      );
      selectedProduct = matched.id;
    }

    if (selectedProduct == null && workTypes.isNotEmpty) {
      selectedProduct = workTypes.first.id;
    }

    // ---------------------------------------------------------
    // INITIALIZE PIPELINE PROGRESS FROM API
    // ---------------------------------------------------------
    final List<PipelineProgress> initialMilestones = _getPipelineStagesForWork(
      work: work,
      selectedProductId: selectedProduct,
      workTypes: workTypes,
    );

    if (initialMilestones.isNotEmpty) {
      selectedPipelineProgress = initialMilestones.map((milestone) {
        return <String, dynamic>{
          "name": milestone.name ?? "",
          "status": milestone.status ?? 0,
        };
      }).toList();
    }

    // ---------------------------------------------------------
    // SHOW CONFIRM DIALOG
    // ---------------------------------------------------------
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // ---------------------------------------------------------
            // UPDATE MATERIAL QUANTITY
            // ---------------------------------------------------------
            void updateQuantity(
              int index,
              bool increase,
            ) {
              if (selectedMaterials[index]["is_existing"] == true) {
                return;
              }

              final stock = int.tryParse(
                    selectedMaterials[index]["stock"].toString(),
                  ) ??
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
                      content: Text(
                        "Cannot exceed available stock ($stock).",
                      ),
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

            // ---------------------------------------------------------
            // ADD MATERIAL
            // ---------------------------------------------------------
            void addMaterial(MaterialData material) {
              final existingIndex = selectedMaterials.indexWhere(
                (m) => m["material_id"] == material.materialId,
              );

              if (existingIndex != -1) {
                updateQuantity(existingIndex, true);
              } else {
                final double unitPrice =
                    double.tryParse(material.unitPrice ?? "0") ?? 0.0;

                selectedMaterials.add(
                  <String, dynamic>{
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
                  },
                );

                setState(() {});
              }
            }

            // ---------------------------------------------------------
            // REMOVE MATERIAL
            // ---------------------------------------------------------
            void removeMaterial(int index) {
              if (selectedMaterials[index]["is_existing"] == true) {
                return;
              }

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
                    const Text(
                      "Are you sure you want to proceed?",
                    ),

                    const SizedBox(height: 16),

                    // ---------------------------------------------------------
                    // PRODUCT
                    // ---------------------------------------------------------
                    if (isLoadingWorkTypes)
                      const Center(
                        child: CircularProgressIndicator(),
                      )
                    else
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
                              border: Border.all(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              _getProductDisplayName(
                                work: work,
                                selectedProductId: selectedProduct,
                                workTypes: workTypes,
                              ),
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 12),

                    // ---------------------------------------------------------
                    // MILESTONE / CHECKPOINT / PIPELINE STAGES
                    // ---------------------------------------------------------
                    _milestoneTimeline(
                      work,
                      currentPipelineProgress: selectedPipelineProgress,
                      selectedProductId: selectedProduct,
                      workTypes: workTypes,
                      onMilestoneChanged: (updatedPipelineProgress) {
                        setState(() {
                          selectedPipelineProgress = updatedPipelineProgress;
                        });
                      },
                    ),

                    const SizedBox(height: 12),

                    // ---------------------------------------------------------
                    // EXISTING MATERIALS
                    // ---------------------------------------------------------
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

                    // ---------------------------------------------------------
                    // SELECT MATERIALS
                    // ---------------------------------------------------------
                    const Text(
                      "Select Materials",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 6),

                    DropdownButtonFormField<MaterialData>(
                      value: null,
                      hint: const Text(
                        "Select Materials",
                      ),
                      isExpanded: true,
                      items: materialsList.map((mat) {
                        final stock = int.tryParse(
                              mat.currentStock ?? "0",
                            ) ??
                            0;

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
                        if (mat != null) {
                          addMaterial(mat);
                        }
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ---------------------------------------------------------
                    // SELECTED MATERIALS
                    // ---------------------------------------------------------
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
                                margin: const EdgeInsets.only(
                                  bottom: 10,
                                ),
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
                                            mat["material_name"] ??
                                                mat["product_name"] ??
                                                "",
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
                                              const SizedBox(
                                                width: 12,
                                              ),
                                              InkWell(
                                                onTap: () => removeMaterial(
                                                  index,
                                                ),
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

                          // ---------------------------------------------------------
                          // TOTAL AMOUNT
                          // ---------------------------------------------------------
                          Container(
                            margin: const EdgeInsets.only(
                              top: 2,
                              bottom: 8,
                            ),
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
                                  "₹${selectedMaterials.fold<double>(
                                        0.0,
                                        (sum, mat) =>
                                            sum +
                                            (double.tryParse(
                                                  mat["total_price"].toString(),
                                                ) ??
                                                0.0),
                                      ).toStringAsFixed(2)}",
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

                    // ---------------------------------------------------------
                    // STATUS
                    // ---------------------------------------------------------
                    const Text(
                      "Status",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
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
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value;
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ---------------------------------------------------------
                    // REMARKS
                    // ---------------------------------------------------------
                    const Text(
                      "Remarks",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
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

              // ---------------------------------------------------------
              // ACTIONS
              // ---------------------------------------------------------
              actions: [
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
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
                          content: Text(
                            "Please fill all required fields.",
                          ),
                        ),
                      );
                      return;
                    }

                    if (!_isPipelineSequential(selectedPipelineProgress)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Pipeline stages must be completed sequentially.",
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

    // ---------------------------------------------------------
    // PERFORM ACTION
    // ---------------------------------------------------------
    if (confirmed == true) {
      await _performWorkAction(
        workId,
        action,
        selectedStatus!,
        remarkController.text,
        selectedPipelineProgress,
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
    List<Map<String, dynamic>> selectedPipelineProgress = [];
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
              final String qty = (product.consumedQty != null &&
                      product.consumedQty!.isNotEmpty)
                  ? product.consumedQty!
                  : ((product.quantity != null && product.quantity!.isNotEmpty)
                      ? product.quantity!
                      : "1");
              final String rateVal =
                  (product.unitPrice != null && product.unitPrice!.isNotEmpty)
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

    selectedCustomerId = work.custId;

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
        final materialModel = await HttpService.getMaterialsProduct();
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

    // Associate selectedProduct with corresponding product of work order
    if (work.addProducts?.isNotEmpty == true &&
        work.addProducts!.first.productId?.isNotEmpty == true) {
      selectedProduct = work.addProducts!.first.productId;
    } else if (work.workType?.isNotEmpty == true && workTypes.isNotEmpty) {
      final matched = workTypes.firstWhere(
        (wt) =>
            wt.id == work.workType ||
            wt.productName?.toLowerCase() == work.workType?.toLowerCase(),
        orElse: () => workTypes.first,
      );
      selectedProduct = matched.id;
    }

    if (selectedProduct == null && workTypes.isNotEmpty) {
      selectedProduct = workTypes.first.id;
    }

    // ---------------------------------------------------------
    // INITIALIZE PIPELINE PROGRESS FROM API
    // ---------------------------------------------------------
    final List<PipelineProgress> initialMilestones = _getPipelineStagesForWork(
      work: work,
      selectedProductId: selectedProduct,
      workTypes: workTypes,
    );

    if (initialMilestones.isNotEmpty) {
      selectedPipelineProgress = initialMilestones.map((milestone) {
        return <String, dynamic>{
          "name": milestone.name ?? "",
          "status": milestone.status ?? 0,
        };
      }).toList();
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
                    else
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
                              _getProductDisplayName(
                                work: work,
                                selectedProductId: selectedProduct,
                                workTypes: workTypes,
                              ),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 12),

                    // ---------------------------------------------------------
                    // MILESTONE / CHECKPOINT / PIPELINE STAGES
                    // ---------------------------------------------------------
                    _milestoneTimeline(
                      work,
                      currentPipelineProgress: selectedPipelineProgress,
                      selectedProductId: selectedProduct,
                      workTypes: workTypes,
                      onMilestoneChanged: (updatedPipelineProgress) {
                        setState(() {
                          selectedPipelineProgress = updatedPipelineProgress;
                        });
                      },
                    ),

                    const SizedBox(height: 12),

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
                                            mat["material_name"] ??
                                                mat["product_name"] ??
                                                "",
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

                    if (!_isPipelineSequential(selectedPipelineProgress)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Pipeline stages must be completed sequentially.",
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
      await _performWorkAction(
        workId,
        action,
        selectedStatus!,
        remarkController.text,
        selectedPipelineProgress,
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
    List<Map<String, dynamic>> selectedPipelineProgress = [];
    String? selectedProduct;

    // Initialize selectedMaterials with existing add_products if available
    List<Map<String, dynamic>> selectedMaterials =
        work.addProducts?.map<Map<String, dynamic>>((product) {
              final String qty = (product.consumedQty != null &&
                      product.consumedQty!.isNotEmpty)
                  ? product.consumedQty!
                  : ((product.quantity != null && product.quantity!.isNotEmpty)
                      ? product.quantity!
                      : "1");
              final String rateVal =
                  (product.unitPrice != null && product.unitPrice!.isNotEmpty)
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

    selectedCustomerId = work.custId;

    final TextEditingController remarkController = TextEditingController();

    Future<void> _loadWorkTypes() async {
      try {
        final httpService = HttpService();
        final workTypeModel = await httpService.getWorkType();
        if (workTypeModel != null && workTypeModel.data.isNotEmpty) {
          workTypes = workTypeModel.data;
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
        final materialModel = await HttpService.getMaterialsProduct();
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

    // Associate selectedProduct with corresponding product of work order
    if (work.addProducts?.isNotEmpty == true &&
        work.addProducts!.first.productId?.isNotEmpty == true) {
      selectedProduct = work.addProducts!.first.productId;
    } else if (work.workType?.isNotEmpty == true && workTypes.isNotEmpty) {
      final matched = workTypes.firstWhere(
        (wt) =>
            wt.id == work.workType ||
            wt.productName?.toLowerCase() == work.workType?.toLowerCase(),
        orElse: () => workTypes.first,
      );
      selectedProduct = matched.id;
    }

    if (selectedProduct == null && workTypes.isNotEmpty) {
      selectedProduct = workTypes.first.id;
    }

    // ---------------------------------------------------------
    // INITIALIZE PIPELINE PROGRESS FROM API
    // ---------------------------------------------------------
    final List<PipelineProgress> initialMilestones = _getPipelineStagesForWork(
      work: work,
      selectedProductId: selectedProduct,
      workTypes: workTypes,
    );

    if (initialMilestones.isNotEmpty) {
      selectedPipelineProgress = initialMilestones.map((milestone) {
        return <String, dynamic>{
          "name": milestone.name ?? "",
          "status": milestone.status ?? 0,
        };
      }).toList();
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Are you sure you want to proceed?"),
                    const SizedBox(height: 16),
                    if (isLoadingWorkTypes)
                      const Center(child: CircularProgressIndicator())
                    else
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
                              _getProductDisplayName(
                                work: work,
                                selectedProductId: selectedProduct,
                                workTypes: workTypes,
                              ),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 12),
                    // ---------------------------------------------------------
                    // MILESTONE / CHECKPOINT / PIPELINE STAGES
                    // ---------------------------------------------------------
                    _milestoneTimeline(
                      work,
                      currentPipelineProgress: selectedPipelineProgress,
                      selectedProductId: selectedProduct,
                      workTypes: workTypes,
                      onMilestoneChanged: (updatedPipelineProgress) {
                        setState(() {
                          selectedPipelineProgress = updatedPipelineProgress;
                        });
                      },
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
                                            mat["material_name"] ??
                                                mat["product_name"] ??
                                                "",
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

                    if (!_isPipelineSequential(selectedPipelineProgress)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Pipeline stages must be completed sequentially.",
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
      await _performWorkAction(
        workId,
        action,
        selectedStatus!,
        remarkController.text,
        selectedPipelineProgress,
        selectedProduct,
        selectedMaterials,
        selectedCustomerId,
      );
    }
  }

  Future<void> _performWorkAction(
    String workId,
    String action,
    String status,
    String remarks,
    List<Map<String, dynamic>> pipelineProgress,
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
          pipelineProgress,
          productId,
          selectedMaterials,
          selectedCustomerId,
        );
      } else if (action == "pause") {
        response = await http.pauseWorkService(
          workId,
          status,
          remarks,
          pipelineProgress,
        );
      } else if (action == "stop") {
        response = await http.stopWorkService(
          workId,
          status,
          remarks,
          pipelineProgress,
          productId,
          selectedMaterials,
          selectedCustomerId,
        );
      } else if (action == "restart") {
        response = await http.restartWorkService(
          workId,
          remarks,
          pipelineProgress,
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
            content: Text(
              response["message"] ?? "Failed to $action work",
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error performing $action: $e"),
        ),
      );
    }
  }

  Future<void> _performWorkActionStop(
    String workId,
    String action,
    String status,
    String remarks,
    List<Map<String, dynamic>> pipelineProgress,
    String? productId,
    List<Map<String, dynamic>> selectedMaterials,
    String? selectedCustomerId,
  ) async {
    await _performWorkAction(
      workId,
      action,
      status,
      remarks,
      pipelineProgress,
      productId,
      selectedMaterials,
      selectedCustomerId,
    );
  }

  Future<void> _performWorkActionRestart(
    String workId,
    String action,
    String status,
    String remarks,
    List<Map<String, dynamic>> pipelineProgress,
    String? productId,
    List<Map<String, dynamic>> selectedMaterials,
    String? selectedCustomerId,
  ) async {
    await _performWorkAction(
      workId,
      action,
      status,
      remarks,
      pipelineProgress,
      productId,
      selectedMaterials,
      selectedCustomerId,
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case "new":
        return const Color(0xFF3B82F6);
      case "assigned":
        return const Color(0xFF8B5CF6);
      case "in progress":
      case "ongoing":
        return const Color(0xFF10B981);
      case "completed":
        return const Color(0xFF059669);
      case "on hold":
      case "pending":
        return const Color(0xFFF59E0B);
      case "cancelled":
      case "overdue":
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF64748B);
    }
  }

  Widget _buildWorkCard(WorkOrder work) {
    final status = work.status ?? "New";
    final statusColor = _getStatusColor(status);
    final workId = (work.workOrderID?.isNotEmpty == true)
        ? work.workOrderID!
        : ((work.workOrderId?.isNotEmpty == true)
            ? work.workOrderId!
            : "WK-${work.custId ?? '0'}");
    final workTitle = (work.workCategory?.isNotEmpty == true)
        ? work.workCategory!
        : ((work.issueDescription?.isNotEmpty == true)
            ? work.issueDescription!
            : "Work Order");

    final double progress = status.toLowerCase().contains("completed")
        ? 1.0
        : status.toLowerCase().contains("progress")
            ? 0.70
            : (status.toLowerCase().contains("pending") ||
                    status.toLowerCase().contains("hold"))
                ? 0.35
                : 0.20;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1.1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => _showViewDialog(work),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Work ID badge + Status pill badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A86C9).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.assignment_outlined,
                                size: 13, color: Color(0xFF2A86C9)),
                            const SizedBox(width: 4),
                            Text(
                              workId,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2A86C9),
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          if (work.priority?.isNotEmpty == true) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              margin: const EdgeInsets.only(right: 6),
                              decoration: BoxDecoration(
                                color: work.priority == "Low"
                                    ? Colors.blue.shade50
                                    : work.priority == "Medium"
                                        ? Colors.amber.shade50
                                        : Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: work.priority == "Low"
                                      ? Colors.blue.shade200
                                      : work.priority == "Medium"
                                          ? Colors.amber.shade300
                                          : Colors.red.shade200,
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                work.priority!,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: work.priority == "Low"
                                      ? Colors.blue.shade800
                                      : work.priority == "Medium"
                                          ? Colors.amber.shade900
                                          : Colors.red.shade800,
                                ),
                              ),
                            ),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  status,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Customer Avatar & Name & Work Title
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A86C9).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Color(0xFF2A86C9),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              work.customerName ?? "Customer",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              workTitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _showViewDialog(work),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A86C9).withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.visibility_outlined,
                              size: 18,
                              color: Color(0xFF2A86C9),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Issue Description callout box if present
                  if (work.issueDescription?.isNotEmpty == true &&
                      work.issueDescription != workTitle) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              size: 14, color: Color(0xFF64748B)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              work.issueDescription!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF475569),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  // Mobile & Location Row
                  Row(
                    children: [
                      if (work.mobileNumber?.isNotEmpty == true) ...[
                        InkWell(
                          onTap: () => _launchPhone(work.mobileNumber!),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD1FAE5),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFA7F3D0),
                                width: 0.6,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.phone_enabled_outlined,
                                  size: 13,
                                  color: Color(0xFF047857),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  work.mobileNumber!,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF065F46),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (work.location?.isNotEmpty == true ||
                          work.address?.isNotEmpty == true) ...[
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: Color(0xFF64748B),
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  (work.location?.isNotEmpty == true
                                      ? work.location
                                      : work.address)!,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),

                  if (work.assignedServiceMan?.isNotEmpty == true ||
    work.estimatedDatetime?.isNotEmpty == true) ...[
  const SizedBox(height: 8),
  Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (work.assignedServiceMan?.isNotEmpty == true)
        Expanded(
          child: Row(
            children: [
              const Icon(
                Icons.badge_outlined,
                size: 13,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  "Assigned: ${work.assignedServiceMan}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
        ),
      if (work.assignedServiceMan?.isNotEmpty == true &&
          work.estimatedDatetime?.isNotEmpty == true)
        const SizedBox(width: 12),
      if (work.estimatedDatetime?.isNotEmpty == true)
        Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 12,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 4),
              const Text(
                'Est date: ',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
              ),
              Flexible(
                child: Text(
                  work.estimatedDatetime!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        ),
    ],
  ),
],

                  const SizedBox(height: 10),

                  // Progress Bar
                  // Column(
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: [
                  //     Row(
                  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //       children: [
                  //         Text(
                  //           "Progress",
                  //           style: TextStyle(
                  //             fontSize: 11,
                  //             fontWeight: FontWeight.w500,
                  //             color: Colors.grey.shade600,
                  //           ),
                  //         ),
                  //         Text(
                  //           "${(progress * 100).toInt()}%",
                  //           style: TextStyle(
                  //             fontSize: 11,
                  //             fontWeight: FontWeight.bold,
                  //             color: statusColor,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //     const SizedBox(height: 4),
                  //     ClipRRect(
                  //       borderRadius: BorderRadius.circular(4),
                  //       child: LinearProgressIndicator(
                  //         value: progress,
                  //         minHeight: 5,
                  //         backgroundColor: Colors.grey.shade100,
                  //         valueColor:
                  //             AlwaysStoppedAnimation<Color>(statusColor),
                  //       ),
                  //     ),
                  //   ],
                  // ),

                  // Pipeline Stages summary bar if present
                  // Builder(
                  //   builder: (context) {
                  //     final cardStages = _getPipelineStagesForWork(work: work);
                  //     if (cardStages.isEmpty) return const SizedBox.shrink();
                  //     final completedStages =
                  //         cardStages.where((s) => s.status == 1).length;
                  //     return Padding(
                  //       padding: const EdgeInsets.only(top: 8),
                  //       child: Container(
                  //         padding: const EdgeInsets.symmetric(
                  //           horizontal: 10,
                  //           vertical: 7,
                  //         ),
                  //         decoration: BoxDecoration(
                  //           color: const Color(0xFFF8FAFC),
                  //           borderRadius: BorderRadius.circular(10),
                  //           border: Border.all(color: Colors.grey.shade200),
                  //         ),
                  //         child: Row(
                  //           children: [
                  //             const Icon(
                  //               Icons.checklist_rounded,
                  //               size: 14,
                  //               color: Color(0xFF2A86C9),
                  //             ),
                  //             const SizedBox(width: 5),
                  //             Text(
                  //               "Pipeline: $completedStages/${cardStages.length}",
                  //               style: const TextStyle(
                  //                 fontSize: 11,
                  //                 fontWeight: FontWeight.w600,
                  //                 color: Color(0xFF334155),
                  //               ),
                  //             ),
                  //             const SizedBox(width: 8),
                  //             Expanded(
                  //               child: ClipRRect(
                  //                 borderRadius: BorderRadius.circular(4),
                  //                 child: LinearProgressIndicator(
                  //                   value: cardStages.isNotEmpty
                  //                       ? (completedStages / cardStages.length)
                  //                       : 0.0,
                  //                   minHeight: 5,
                  //                   backgroundColor: Colors.grey.shade200,
                  //                   valueColor: AlwaysStoppedAnimation<Color>(
                  //                     completedStages == cardStages.length
                  //                         ? const Color(0xFF10B981)
                  //                         : const Color(0xFF2A86C9),
                  //                   ),
                  //                 ),
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //     );
                  //   },
                  // ),

                  // Action Buttons Row
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (roleId == "2" && work.status != "Completed" && work.status != "In Progress" && work.status != "On Hold") ...[
                            OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditWorkPage(
                                      workOrderId: work.workOrderID ?? '',
                                      initialServiceType: work.serviceType,
                                    ),
                                  ),
                                ).then((value) {
                                  if (value == true) _fetchWorkList();
                                });
                              },
                              icon: const Icon(Icons.edit_outlined, size: 15),
                              label: const Text("Edit",
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF2A86C9),
                                side: const BorderSide(
                                    color: Color(0xFF2A86C9), width: 1.2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
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
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text("Cancel"),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFFEF4444),
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text("Delete"),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  final httpService = HttpService();
                                  final success =
                                      await httpService.deleteWorkOrder(
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
                              icon: const Icon(Icons.delete_outline, size: 15),
                              label: const Text("Delete",
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFEF4444),
                                side: const BorderSide(
                                    color: Color(0xFFEF4444), width: 1.2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
                            ),
                            if (_canShowWorkActionButtons(work) &&
                                (work.status == "New" ||
                                    work.status == "In Progress" ||
                                    work.status == "On Hold"))
                              const SizedBox(width: 8),
                          ],
                          if ((work.status == "New") &&
                              _canShowWorkActionButtons(work))
                            ElevatedButton.icon(
                              onPressed: () {
                                if (isWorkStarted) {
                                  _showWorkInProgressDialog();
                                } else {
                                  _confirmAction("Start Work", work, "start");
                                }
                              },
                              icon: const Icon(Icons.play_arrow_rounded,
                                  size: 16),
                              label: const Text("Start Work",
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                              ),
                            ),
                          if ((work.status == "In Progress") &&
                              _canShowWorkActionButtons(work))
                            ElevatedButton.icon(
                              onPressed: () =>
                                  _confirmActionStop("Stop Work", work, "stop"),
                              icon: const Icon(Icons.stop_rounded, size: 16),
                              label: const Text("Stop Work",
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEF4444),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                              ),
                            ),
                          if ((work.status == "On Hold") &&
                              _canShowWorkActionButtons(work))
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
                              icon: const Icon(Icons.restart_alt_rounded,
                                  size: 16),
                              label: const Text("Restart",
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3B82F6),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
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
      ),
    );
  }

  void _showViewDialog(WorkOrder work) {
    final viewPipelineStages = _getPipelineStagesForWork(work: work);
    final String orderId = (work.workOrderID != null &&
            work.workOrderID!.trim().isNotEmpty)
        ? work.workOrderID!.trim()
        : ((work.workOrderId != null && work.workOrderId!.trim().isNotEmpty)
            ? work.workOrderId!.trim()
            : "-");

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
              maxWidth: 420,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFFF8FAFC), Colors.white],
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
                            Icons.info_outline_rounded,
                            "Status",
                            work.status,
                            Colors.teal,
                          ),
                          _detailTile(
                            Icons.flag_outlined,
                            "Priority",
                            work.priority,
                            Colors.orange,
                          ),

                          // Customer Information
                          _detailTile(
                            Icons.person,
                            "Customer",
                            work.customerName,
                            Colors.indigo,
                          ),
                          _detailTile(
                            Icons.badge_outlined,
                            "Customer Type",
                            work.customerType,
                            Colors.teal.shade700,
                          ),
                          _detailTile(
                            Icons.phone,
                            "Phone",
                            work.mobileNumber,
                            Colors.teal,
                          ),
                          _detailTile(
                            Icons.email_outlined,
                            "Email",
                            work.emailId,
                            Colors.blueGrey,
                          ),
                          _detailTile(
                            Icons.home_work_outlined,
                            "Address",
                            work.address,
                            Colors.deepOrange,
                          ),
                          if (_hasDetailValue(work.location) &&
                              work.location!.trim().toLowerCase() !=
                                  (work.address ?? "").trim().toLowerCase())
                            _detailTile(
                              Icons.location_on_outlined,
                              "Location",
                              work.location,
                              Colors.redAccent,
                            ),

                          // Work & Service Details
                          _detailTile(
                            Icons.category_rounded,
                            "Work Category",
                            work.workCategory,
                            Colors.purple,
                          ),
                          _detailTile(
                            Icons.laptop,
                            "Product",
                            work.workType,
                            Colors.blue,
                          ),
                          _detailTile(
                            Icons.work_outline_rounded,
                            "Job Type",
                            work.jobType,
                            Colors.deepPurple,
                          ),
                          _detailTile(
                            Icons.build_circle_outlined,
                            "Service Type",
                            _formatServiceType(work.serviceType),
                            Colors.amber.shade800,
                          ),
                          _detailTile(
                            Icons.engineering_outlined,
                            "Assigned Serviceman",
                            work.assignedServiceMan,
                            Colors.teal.shade800,
                          ),
                          if (_hasDetailValue(work.receivedTru))
                            _detailTile(
                              Icons.call_received_rounded,
                              "Received Through",
                              work.receivedTru,
                              Colors.cyan.shade700,
                            ),

                          // Equipment / Device Information
                          _detailTile(
                            Icons.branding_watermark_outlined,
                            "Brand",
                            work.brand,
                            Colors.brown,
                          ),
                          _detailTile(
                            Icons.qr_code_rounded,
                            "Serial No / Model No",
                            work.serialNo,
                            Colors.blueGrey,
                          ),
                          if (_hasDetailValue(work.accessories))
                            _detailTile(
                              Icons.devices_other_outlined,
                              "Accessories",
                              work.accessories,
                              Colors.teal.shade600,
                            ),
                          if (_hasDetailValue(work.userPassword))
                            _detailTile(
                              Icons.password_rounded,
                              "User Password",
                              work.userPassword,
                              Colors.grey.shade700,
                            ),

                          // Schedule
                          _detailTile(
                            Icons.calendar_month,
                            "Preferred",
                            work.preferredDateTime,
                            Colors.redAccent,
                          ),
                          _detailTile(
                            Icons.event_available_outlined,
                            "Estimated Date",
                            work.estimatedDatetime,
                            Colors.blueAccent,
                          ),

                          // Issue & Description Details
                          _detailTile(
                            Icons.description_outlined,
                            "Issue Description",
                            _hasDetailValue(work.issueDescription)
                                ? work.issueDescription
                                : work.problemReportedByCustomer,
                            Colors.indigoAccent,
                          ),
                          if (_hasDetailValue(work.problemReportedByCustomer) &&
                              _hasDetailValue(work.issueDescription) &&
                              work.problemReportedByCustomer!.trim() !=
                                  work.issueDescription!.trim())
                            _detailTile(
                              Icons.report_problem_outlined,
                              "Reported by Customer",
                              work.problemReportedByCustomer,
                              Colors.deepOrangeAccent,
                            ),
                          if (_hasDetailValue(work.dealerName))
                            _detailTile(
                              Icons.storefront_outlined,
                              "Dealer Name",
                              work.dealerName,
                              Colors.purpleAccent,
                            ),
                          _detailTile(
                            Icons.comment_outlined,
                            "Remarks",
                            work.remarks,
                            Colors.blue.shade700,
                          ),

                          // Metadata
                          if (_hasDetailValue(work.createdBy))
                            _detailTile(
                              Icons.person_outline_rounded,
                              "Created By",
                              work.createdBy,
                              Colors.blueGrey,
                            ),
                          if (_hasDetailValue(work.createdAt))
                            _detailTile(
                              Icons.access_time_rounded,
                              "Created At",
                              work.createdAt,
                              Colors.blueGrey.shade600,
                            ),

                          // Materials / Added Products
                          if (work.addProducts != null &&
                              work.addProducts!.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            const Divider(thickness: 1.2),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.inventory_2_outlined,
                                  size: 20,
                                  color: Color(0xFF2a86c9),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "Materials / Products",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2a86c9),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2A86C9)
                                        .withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    "${work.addProducts!.length} Item(s)",
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2A86C9),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ...work.addProducts!.map((prod) {
                              final name = (prod.productName != null &&
                                      prod.productName!.isNotEmpty)
                                  ? prod.productName!
                                  : "Item";
                              final qty = (prod.consumedQty != null &&
                                      prod.consumedQty!.isNotEmpty)
                                  ? prod.consumedQty!
                                  : ((prod.quantity != null &&
                                          prod.quantity!.isNotEmpty)
                                      ? prod.quantity!
                                      : "1");
                              final rate = (prod.unitPrice != null &&
                                      prod.unitPrice!.isNotEmpty)
                                  ? prod.unitPrice!
                                  : ((prod.rate != null &&
                                          prod.rate!.isNotEmpty)
                                      ? prod.rate!
                                      : "");
                              final amount = (prod.amount != null &&
                                      prod.amount!.isNotEmpty)
                                  ? prod.amount!
                                  : "";
                              String subtitle = "Qty: $qty";
                              if (rate.isNotEmpty) subtitle += "  |  Rate: ₹$rate";
                              if (amount.isNotEmpty) subtitle += "  |  Total: ₹$amount";

                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 14,
                                      backgroundColor: Color(0xFFF1F5F9),
                                      child: Icon(
                                        Icons.build_outlined,
                                        size: 16,
                                        color: Color(0xFF2A86C9),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: const TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF0F172A),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            subtitle,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                          const SizedBox(height: 16),
                          const Divider(thickness: 1.2),
                          const SizedBox(height: 8),
                          if (viewPipelineStages.isNotEmpty) ...[
                            Row(
                              children: [
                                const Icon(
                                  Icons.checklist_rounded,
                                  size: 20,
                                  color: Color(0xFF2a86c9),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "Pipeline Stages",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2a86c9),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2A86C9)
                                        .withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    "${viewPipelineStages.where((s) => s.status == 1).length}/${viewPipelineStages.length} Completed",
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2A86C9),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                itemCount: viewPipelineStages.length,
                                separatorBuilder: (_, __) => Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Colors.grey.shade100,
                                ),
                                itemBuilder: (context, i) {
                                  final stage = viewPipelineStages[i];
                                  final bool isDone = stage.status == 1;
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8.5,
                                    ),
                                    color: isDone
                                        ? const Color(0xFF10B981)
                                            .withOpacity(0.06)
                                        : Colors.transparent,
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          value: isDone,
                                          activeColor: const Color(0xFF10B981),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          visualDensity: VisualDensity.compact,
                                          onChanged: null,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            stage.name ?? "-",
                                            style: TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: isDone
                                                  ? FontWeight.w600
                                                  : FontWeight.w500,
                                              color: isDone
                                                  ? const Color(0xFF0F172A)
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        if (isDone)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF10B981)
                                                  .withOpacity(0.12),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                color: const Color(0xFF10B981)
                                                    .withOpacity(0.3),
                                                width: 0.8,
                                              ),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.lock_rounded,
                                                  size: 11,
                                                  color: Color(0xFF059669),
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  "Completed",
                                                  style: TextStyle(
                                                    fontSize: 10.5,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF059669),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        else
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF59E0B)
                                                  .withOpacity(0.08),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                color: const Color(0xFFF59E0B)
                                                    .withOpacity(0.25),
                                                width: 0.8,
                                              ),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons
                                                      .radio_button_unchecked_rounded,
                                                  size: 11,
                                                  color: Color(0xFFD97706),
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  "Pending (0)",
                                                  style: TextStyle(
                                                    fontSize: 10.5,
                                                    fontWeight: FontWeight.w500,
                                                    color: Color(0xFFD97706),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
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

  bool _hasDetailValue(String? value) {
    if (value == null) return false;
    final t = value.trim();
    return t.isNotEmpty && t.toLowerCase() != "null" && t != "-";
  }

  String _formatServiceType(String? raw) {
    if (raw == null ||
        raw.trim().isEmpty ||
        raw.trim().toLowerCase() == "null") {
      return "-";
    }
    final t = raw.trim();
    final lower = t.toLowerCase();
    if (lower == "onsite") return "On-site Service";
    if (lower == "workshop") return "In-office / Workshop Service";
    return t;
  }

  Widget _detailTile(IconData icon, String label, String? value, Color color) {
    final String displayVal = (value == null ||
            value.trim().isEmpty ||
            value.trim().toLowerCase() == "null")
        ? "-"
        : value.trim();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                "$label: $displayVal",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _milestoneTimeline(
    WorkOrder work, {
    List<Map<String, dynamic>>? currentPipelineProgress,
    String? selectedProductId,
    List<WorkType>? workTypes,
    required ValueChanged<List<Map<String, dynamic>>> onMilestoneChanged,
  }) {
    // Get initial stages as saved on the work order
    final List<PipelineProgress> initialStages = _getPipelineStagesForWork(
      work: work,
      selectedProductId: selectedProductId,
      workTypes: workTypes,
    );

    final Set<int> alreadyCheckedIndices = {
      for (int i = 0; i < initialStages.length; i++)
        if (initialStages[i].status == 1) i
    };

    final Set<String> alreadyCheckedNames = {
      for (var s in initialStages)
        if (s.status == 1 && s.name != null && s.name!.trim().isNotEmpty)
          s.name!.trim().toLowerCase()
    };

    // Get pipeline progress either from current state or by resolving from work/product
    final List<PipelineProgress> milestones = (currentPipelineProgress != null &&
            currentPipelineProgress.isNotEmpty)
        ? currentPipelineProgress
            .map((m) => PipelineProgress.fromJson(m))
            .toList()
        : initialStages;

    if (milestones.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Row(
          children: [
            Icon(Icons.checklist_rounded, color: Colors.grey, size: 20),
            SizedBox(width: 8),
            Text(
              "No pipeline stages available",
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    final int completedCount = milestones.where((m) {
      final name = (m.name ?? "").trim().toLowerCase();
      final bool isAlready = alreadyCheckedNames.contains(name);
      return isAlready || m.status == 1;
    }).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.checklist_rounded,
              size: 18,
              color: Color(0xFF2a86c9),
            ),
            const SizedBox(width: 6),
            const Text(
              "Pipeline Stages",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF1E293B),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF2A86C9).withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "$completedCount/${milestones.length} Completed",
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2A86C9),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: milestones.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey.shade100,
            ),
            itemBuilder: (context, index) {
              final milestone = milestones[index];
              final String stageName =
                  (milestone.name ?? "").trim().toLowerCase();
              final bool isAlreadyChecked =
                  alreadyCheckedIndices.contains(index) ||
                  alreadyCheckedNames.contains(stageName) ||
                      (index < initialStages.length &&
                          initialStages[index].status == 1);
              final bool isChecked =
                  isAlreadyChecked || (milestone.status == 1);

              // Determine if the previous stage is completed or selected
              final bool isPreviousChecked;
              if (index == 0) {
                isPreviousChecked = true;
              } else {
                final prevMilestone = milestones[index - 1];
                final String prevName =
                    (prevMilestone.name ?? "").trim().toLowerCase();
                isPreviousChecked = alreadyCheckedIndices.contains(index - 1) ||
                    alreadyCheckedNames.contains(prevName) ||
                    (prevMilestone.status == 1);
              }

              // A stage can only be selected if the previous stage is already checked
              final bool canSelect = isPreviousChecked;

              // Check if any subsequent stage is currently selected (for unchecking restriction)
              final bool hasSubsequentChecked = (index < milestones.length - 1) &&
                  milestones.sublist(index + 1).any((m) => m.status == 1);

              void toggleCheckbox(bool? value) {
                if (isAlreadyChecked) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      duration: Duration(milliseconds: 1500),
                      content: Text(
                        "Already completed stages cannot be unchecked.",
                      ),
                    ),
                  );
                  return;
                }

                final bool newChecked = value ?? !isChecked;

                if (newChecked) {
                  // Enforce sequential selection: cannot check unless previous stage is checked
                  if (!canSelect) {
                    final String prevName = (index > 0 &&
                            milestones[index - 1].name != null &&
                            milestones[index - 1].name!.trim().isNotEmpty)
                        ? milestones[index - 1].name!
                        : "the previous stage";
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: const Duration(milliseconds: 1800),
                        content: Text(
                          "Cannot select '${milestone.name ?? 'this stage'}'. Please complete '$prevName' first.",
                        ),
                      ),
                    );
                    return;
                  }
                } else {
                  // Cannot uncheck if subsequent stages are checked
                  if (hasSubsequentChecked) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: const Duration(milliseconds: 1800),
                        content: Text(
                          "Please uncheck subsequent stages before unchecking '${milestone.name ?? 'this stage'}'.",
                        ),
                      ),
                    );
                    return;
                  }
                }

                final updatedPipelineProgress =
                    List<Map<String, dynamic>>.generate(
                  milestones.length,
                  (i) {
                    final m = milestones[i];
                    final mName = (m.name ?? "").trim().toLowerCase();
                    final bool isLocked =
                        alreadyCheckedIndices.contains(i) ||
                        alreadyCheckedNames.contains(mName) ||
                        (i < initialStages.length &&
                            initialStages[i].status == 1);

                    if (isLocked) {
                      return {
                        "name": m.name ?? "",
                        "status": 1,
                      };
                    }

                    final int newStatus;
                    if (i == index) {
                      newStatus = newChecked ? 1 : 0;
                    } else {
                      newStatus = (m.status == 1) ? 1 : 0;
                    }
                    return {
                      "name": m.name ?? "",
                      "status": newStatus,
                    };
                  },
                );
                onMilestoneChanged(updatedPipelineProgress);
              }

              return InkWell(
                onTap: isAlreadyChecked
                    ? () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            duration: Duration(milliseconds: 1500),
                            content: Text(
                              "Already completed stages cannot be unchecked.",
                            ),
                          ),
                        );
                      }
                    : () => toggleCheckbox(!isChecked),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8.5,
                  ),
                  color: isAlreadyChecked
                      ? const Color(0xFF10B981).withOpacity(0.06)
                      : (isChecked
                          ? const Color(0xFF2a86c9).withOpacity(0.05)
                          : (!canSelect
                              ? const Color(0xFFF8FAFC)
                              : Colors.transparent)),
                  child: Row(
                    children: [
                      Checkbox(
                        value: isChecked,
                        activeColor: isAlreadyChecked
                            ? const Color(0xFF10B981)
                            : const Color(0xFF2a86c9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        onChanged: isAlreadyChecked ? null : toggleCheckbox,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          milestone.name ?? "",
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: (isAlreadyChecked || isChecked)
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isAlreadyChecked
                                ? const Color(0xFF0F172A)
                                : (isChecked
                                    ? const Color(0xFF1E293B)
                                    : (!canSelect
                                        ? const Color(0xFF94A3B8)
                                        : Colors.black87)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isAlreadyChecked)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFF10B981).withOpacity(0.3),
                              width: 0.8,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.lock_rounded,
                                size: 11,
                                color: Color(0xFF059669),
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Completed",
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF059669),
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (isChecked)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A86C9).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFF2A86C9).withOpacity(0.3),
                              width: 0.8,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 11,
                                color: Color(0xFF2A86C9),
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Selected (1)",
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2A86C9),
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (!canSelect)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF64748B).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFF64748B).withOpacity(0.2),
                              width: 0.8,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.lock_outline_rounded,
                                size: 11,
                                color: Color(0xFF64748B),
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Locked",
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFFF59E0B).withOpacity(0.25),
                              width: 0.8,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.radio_button_unchecked_rounded,
                                size: 11,
                                color: Color(0xFFD97706),
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Pending (0)",
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFFD97706),
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
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredWorkOrders;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2a86c9), Color(0xFF406dbe)],
            ),
          ),
          child: AppBar(
            title: Text(
              widget.pageTitle,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              if (roleId != "3")
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 22),
                  tooltip: "Add New Work",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateNewJobPage(),
                      ),
                    ).then((_) => _fetchWorkList());
                  },
                ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Modern Search Bar
          Container(
            margin:
                const EdgeInsets.only(left: 16, right: 16, top: 14, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              decoration: InputDecoration(
                hintText: "Search by customer, phone, ID, location...",
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                border: InputBorder.none,
                icon: const Icon(Icons.search, color: Color(0xFF2a86c9)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear,
                            size: 18, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = "";
                          });
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Header summary badge bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      widget.pageTitle,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A86C9).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${filteredList.length} Work Orders",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2A86C9),
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  "Total: ${workOrders.length}",
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // Work orders list view
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF2A86C9)),
                  )
                : filteredList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.assignment_outlined,
                              size: 48,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? "No works matching '$_searchQuery'"
                                  : "No works found.",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: const Color(0xFF2A86C9),
                        onRefresh: _fetchWorkList,
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) =>
                              _buildWorkCard(filteredList[index]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}


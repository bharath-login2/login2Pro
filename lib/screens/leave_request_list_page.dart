import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/lead_management/pendingListLeaveModel.dart';
import 'package:login2/models/lead_management/approvedListLeaveModel.dart';
import 'package:login2/service/service.dart';
import 'package:login2/core/common.dart';
import 'package:login2/screens/leadManagement/StaffCalendarPage.dart';
import 'package:login2/models/expense/staffListModel.dart';
import 'package:login2/models/lead_management/getLeaveBalanceModel.dart';
import 'package:login2/models/lead_management/getLeaveApprovalRejectTemplate.dart';
import 'dart:async';

class LeaveRequestFilter {
  bool isPending = false;
  bool isApproved = false;
  bool isRejected = false;
}

class LeaveRequestListPage extends StatefulWidget {
  const LeaveRequestListPage({super.key});

  @override
  State<LeaveRequestListPage> createState() => _LeaveRequestListPageState();
}

class _LeaveRequestListPageState extends State<LeaveRequestListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  List<PendingLeaveData> _pendingLeaves = [];
  List<ApprovedLeaveData> _approvedLeaves = [];
  bool _isLoading = true;
  String _searchQuery = '';
  bool _canApprove = false;
  bool _canReject = false;
  bool _canEdit = false;
  bool _canDelete = false;

  // Selected leaves for bulk approval (maps item.id -> item)
  final Map<String, dynamic> _selectedLeaves = {};

  // Filter variables
  String? _selectedLeaveType;
  DateTime? _fromDate;
  DateTime? _toDate;
  List<Staff> _allStaffList = [];
  List<String> _selectedStaffIds = [];
  bool _filterPending = false;
  bool _filterApproved = false;
  bool _filterRejected = false;
  bool _filterPartial = false;
  List<TemplateData>? _allTemplates;

  final List<String> _leaveTypeFilters = [
    'Casual Leave',
    'Sick Leave',
    'Saturday Leave',
    // 'Paid Leave',
    // 'Unpaid Leave',
    // 'Paternity Leave',
    'Loss of Pay (LOP)',
  ];

  // Color palette
  static const Color primaryBlue = Color(0xFF2a86c9);
  static const Color secondaryBlue = Color(0xFF4A9FE0);
  static const Color lightBlue = Color(0xFFE8F1FA);
  static const Color softOrange = Color(0xFFFFB74D);
  static const Color softGreen = Color(0xFF4CAF50);
  static const Color softRed = Color(0xFFF44336);
  static const Color lightPurple = Color(0xFF9C27B0);
  static const Color softTeal = Color(0xFF009688);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color mediumGrey = Color(0xFFE0E0E0);
  static const Color darkGrey = Color(0xFF757575);

  String _normalizeLeaveType(String? type) {
    if (type == null) return _leaveTypeFilters[0];
    String normalized = type.trim();
    if (_leaveTypeFilters.contains(normalized)) return normalized;

    // Case-insensitive check
    for (var f in _leaveTypeFilters) {
      if (f.toLowerCase() == normalized.toLowerCase()) return f;
      if (f.toLowerCase().startsWith(normalized.toLowerCase())) return f;
    }

    // Handle short codes if any
    if (normalized.toLowerCase() == 'casual') return 'Casual Leave';
    if (normalized.toLowerCase() == 'sick') return 'Sick Leave';
    if (normalized.toLowerCase() == 'earned') return 'Earned Leave';

    return _leaveTypeFilters[0];
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadData();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _debounce?.cancel();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _selectedLeaves.clear();
    });
    await Future.wait([
      _fetchPendingLeaves(),
      _fetchApprovedLeaves(),
      _fetchPermissions(),
      _fetchTemplates(),
    ]);
    setState(() => _isLoading = false);
  }

  Future<void> _fetchTemplates() async {
    try {
      final res = await HttpService.getApprovalRejectTemplate();
      if (res != null && (res.status == true || res.message == 'success')) {
        setState(() {
          _allTemplates = res.data;
        });
      }
    } catch (e) {
      debugPrint("Error fetching templates: $e");
    }
  }

  Future<void> _fetchPermissions() async {
    try {
      final canApprove =
          await Common.getSharedPref("addApproveLeavePermission");
      final canReject =
          await Common.getSharedPref("rejectRequestLeavePermission");
      final canEdit = await Common.getSharedPref("editLeaveRequestPermission");
      final canDelete =
          await Common.getSharedPref("deleteLeaveRequestPermission");

      setState(() {
        _canApprove = canApprove?.toString() == "true";
        _canReject = canReject?.toString() == "true";
        _canEdit = canEdit?.toString() == "true";
        _canDelete = canDelete?.toString() == "true";
      });
    } catch (e) {
      debugPrint("Error fetching permissions from sharedPref: $e");
    }

    try {
      final data = await HttpService.getStaffs();
      if (data != null && data.status == true) {
        setState(() {
          _allStaffList = data.data;
        });
      }
    } catch (e) {
      debugPrint("Error fetching staffs: $e");
    }
  }

  Future<void> _fetchPendingLeaves() async {
    List<String> statuses = [];
    if (_filterPending) statuses.add("Pending");
    if (_filterApproved) statuses.add("Approved");
    if (_filterRejected) statuses.add("Rejected");

    final data = await HttpService.pendingLeaveList(
      fromDate: _fromDate != null
          ? DateFormat('dd-MM-yyyy').format(_fromDate!)
          : null,
      toDate:
          _toDate != null ? DateFormat('dd-MM-yyyy').format(_toDate!) : null,
      leaveType: _selectedLeaveType,
      search: _searchQuery,
      staffId:
          _selectedStaffIds.isNotEmpty ? _selectedStaffIds.join(',') : null,
      status: statuses.isNotEmpty ? statuses.join(',') : null,
    );
    if (data != null) {
      setState(() {
        _pendingLeaves = data.data;
        if (_searchQuery.isNotEmpty) {
          _pendingLeaves = _pendingLeaves
              .where((e) => (e.staffName ?? '')
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
              .toList();
        }
      });
    }
  }

  Future<void> _fetchApprovedLeaves() async {
    List<String> statuses = [];
    if (_filterPending) statuses.add("Pending");
    if (_filterApproved) statuses.add("Approved");
    if (_filterRejected) statuses.add("Rejected");
    if (_filterPartial) statuses.add("Partial");
    final data = await HttpService.approvedLeaveList(
      fromDate: _fromDate != null
          ? DateFormat('dd-MM-yyyy').format(_fromDate!)
          : null,
      toDate:
          _toDate != null ? DateFormat('dd-MM-yyyy').format(_toDate!) : null,
      leaveType: _selectedLeaveType,
      search: _searchQuery,
      staffId:
          _selectedStaffIds.isNotEmpty ? _selectedStaffIds.join(',') : null,
      status: statuses.isNotEmpty ? statuses.join(',') : null,
    );
    if (data != null) {
      setState(() {
        _approvedLeaves = data.data;
        if (_searchQuery.isNotEmpty) {
          _approvedLeaves = _approvedLeaves
              .where((e) => (e.staffName ?? '')
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
              .toList();
        }
      });
    }
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 20,
                  right: 20,
                  top: 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Filter Leaves",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: darkGrey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: lightBlue,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Leave Type",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: DropdownButtonFormField<String>(
                              value: _selectedLeaveType,
                              isExpanded: true,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                hintText: "Select Leave Type",
                                hintStyle: const TextStyle(color: darkGrey),
                                prefixIcon: const Icon(Icons.category_outlined,
                                    color: primaryBlue),
                              ),
                              items: _leaveTypeFilters
                                  .map((e) => DropdownMenuItem(
                                      value: e, child: Text(e)))
                                  .toList(),
                              onChanged: (val) =>
                                  setSheetState(() => _selectedLeaveType = val),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: lightBlue,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Date Range",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: _fromDate ?? DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                      builder: (context, child) {
                                        return Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme:
                                                const ColorScheme.light(
                                              primary: primaryBlue,
                                              onPrimary: Colors.white,
                                              surface: Colors.white,
                                            ),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );
                                    if (picked != null)
                                      setSheetState(() => _fromDate = picked);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.calendar_today,
                                            size: 16, color: primaryBlue),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _fromDate == null
                                                ? "From Date"
                                                : DateFormat('dd MMM yyyy')
                                                    .format(_fromDate!),
                                            style: TextStyle(
                                              color: _fromDate == null
                                                  ? darkGrey
                                                  : Colors.black,
                                              fontWeight: _fromDate == null
                                                  ? FontWeight.normal
                                                  : FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: _toDate ?? DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                      builder: (context, child) {
                                        return Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme:
                                                const ColorScheme.light(
                                              primary: primaryBlue,
                                              onPrimary: Colors.white,
                                              surface: Colors.white,
                                            ),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );
                                    if (picked != null)
                                      setSheetState(() => _toDate = picked);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.calendar_today,
                                            size: 16, color: primaryBlue),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _toDate == null
                                                ? "To Date"
                                                : DateFormat('dd MMM yyyy')
                                                    .format(_toDate!),
                                            style: TextStyle(
                                              color: _toDate == null
                                                  ? darkGrey
                                                  : Colors.black,
                                              fontWeight: _toDate == null
                                                  ? FontWeight.normal
                                                  : FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Staff Multiple Selection Filters
                    if (_allStaffList.isNotEmpty)
                      Container(
                        decoration: BoxDecoration(
                          color: lightBlue,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Select Staff",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: primaryBlue,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: InkWell(
                                onTap: () async {
                                  await showDialog(
                                    context: context,
                                    builder: (context) {
                                      return StatefulBuilder(
                                        builder: (context, setDialogState) {
                                          return AlertDialog(
                                            title: const Text("Select Staff"),
                                            content: SizedBox(
                                              width: double.maxFinite,
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: _allStaffList.length,
                                                itemBuilder: (context, index) {
                                                  final staff =
                                                      _allStaffList[index];
                                                  final isSelected =
                                                      _selectedStaffIds
                                                          .contains(staff
                                                              .userIdStaff);
                                                  return CheckboxListTile(
                                                    title: Text(staff.name),
                                                    value: isSelected,
                                                    activeColor: primaryBlue,
                                                    onChanged: (bool? val) {
                                                      setDialogState(() {
                                                        if (val == true) {
                                                          _selectedStaffIds.add(
                                                              staff
                                                                  .userIdStaff);
                                                        } else {
                                                          _selectedStaffIds
                                                              .remove(staff
                                                                  .userIdStaff);
                                                        }
                                                      });
                                                      setSheetState(() {});
                                                    },
                                                  );
                                                },
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text("Done",
                                                    style: TextStyle(
                                                        color: primaryBlue)),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.people_outline,
                                          color: primaryBlue),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          _selectedStaffIds.isEmpty
                                              ? "Select Staff"
                                              : "${_selectedStaffIds.length} Staff Selected",
                                          style: TextStyle(
                                            color: _selectedStaffIds.isEmpty
                                                ? darkGrey
                                                : Colors.black87,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      const Icon(Icons.keyboard_arrow_down,
                                          color: darkGrey),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    // Status filters
                    Container(
                      decoration: BoxDecoration(
                        color: lightBlue,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Status",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: InkWell(
                              onTap: () async {
                                await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return StatefulBuilder(
                                      builder: (context, setDialogState) {
                                        return AlertDialog(
                                          title: const Text("Select Status"),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              CheckboxListTile(
                                                title: const Text("Pending"),
                                                value: _filterPending,
                                                activeColor: softOrange,
                                                onChanged: (val) {
                                                  setDialogState(() =>
                                                      _filterPending =
                                                          val ?? false);
                                                  setSheetState(() {});
                                                },
                                              ),
                                              CheckboxListTile(
                                                title: const Text("Approved"),
                                                value: _filterApproved,
                                                activeColor: softGreen,
                                                onChanged: (val) {
                                                  setDialogState(() =>
                                                      _filterApproved =
                                                          val ?? false);
                                                  setSheetState(() {});
                                                },
                                              ),
                                              CheckboxListTile(
                                                title: const Text("Rejected"),
                                                value: _filterRejected,
                                                activeColor: softRed,
                                                onChanged: (val) {
                                                  setDialogState(() =>
                                                      _filterRejected =
                                                          val ?? false);
                                                  setSheetState(() {});
                                                },
                                              ),
                                              CheckboxListTile(
                                                title: const Text("Partial"),
                                                value: _filterRejected,
                                                activeColor:
                                                    const Color.fromARGB(
                                                        255, 240, 238, 133),
                                                onChanged: (val) {
                                                  setDialogState(() =>
                                                      _filterPartial =
                                                          val ?? false);
                                                  setSheetState(() {});
                                                },
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text("Done",
                                                  style: TextStyle(
                                                      color: primaryBlue)),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                child: Row(
                                  children: [
                                    const Icon(Icons.filter_list,
                                        color: primaryBlue),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        [
                                          if (_filterPending) "Pending",
                                          if (_filterApproved) "Approved",
                                          if (_filterRejected) "Rejected",
                                          if (_filterPartial) "Partial"
                                        ].isEmpty
                                            ? "Select Status"
                                            : [
                                                if (_filterPending) "Pending",
                                                if (_filterApproved) "Approved",
                                                if (_filterRejected) "Rejected",
                                                if (_filterPartial) "Partial"
                                              ].join(", "),
                                        style: TextStyle(
                                          color: (!(_filterPending ||
                                                  _filterApproved ||
                                                  _filterRejected ||
                                                  _filterPartial))
                                              ? darkGrey
                                              : Colors.black87,
                                          fontSize: 16,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Icon(Icons.keyboard_arrow_down,
                                        color: darkGrey),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_selectedLeaveType != null ||
                        _fromDate != null ||
                        _toDate != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: lightBlue,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: TextButton.icon(
                                onPressed: () {
                                  setSheetState(() {
                                    _selectedLeaveType = null;
                                    _fromDate = null;
                                    _toDate = null;
                                    _selectedStaffIds.clear();
                                    _filterPending = false;
                                    _filterApproved = false;
                                    _filterRejected = false;
                                    _filterPartial = false;
                                  });
                                },
                                icon: const Icon(Icons.refresh,
                                    size: 16, color: primaryBlue),
                                label: const Text(
                                  "Reset All Filters",
                                  style: TextStyle(color: primaryBlue),
                                ),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _loadData();
                        },
                        child: const Text(
                          "Apply Filters",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        title: const Text(
          'Leave Requests',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryBlue,
        elevation: 2,
        foregroundColor: Colors.white,
        actions: [
          if (_selectedLeaves.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.done_all, color: Colors.white),
                onPressed: _showBulkApproveDialog,
                tooltip: 'Bulk Approve (${_selectedLeaves.length})',
              ),
            ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.filter_alt_outlined),
              onPressed: _openFilterSheet,
              tooltip: 'Filter',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: lightGrey,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: mediumGrey.withOpacity(0.5)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() => _searchQuery = val);
                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                      _debounce = Timer(const Duration(milliseconds: 500), () {
                        _loadData();
                      });
                    },
                    onSubmitted: (_) => _loadData(),
                    decoration: InputDecoration(
                      hintText: 'Search by staff name...',
                      hintStyle: const TextStyle(color: darkGrey),
                      prefixIcon: const Icon(Icons.search, color: primaryBlue),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear,
                                  size: 20, color: darkGrey),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                                _loadData();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: lightGrey,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: primaryBlue.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: primaryBlue,
                    unselectedLabelColor: darkGrey,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    dividerColor: Colors.transparent,
                    tabs: [
                      Tab(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: softOrange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.pending_actions,
                                    size: 18, color: softOrange),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Pending",
                                style: const TextStyle(fontSize: 13),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: softOrange,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "${_pendingLeaves.length}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Tab(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: softGreen.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.check_circle_outline,
                                    size: 18, color: softGreen),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Recent",
                                style: const TextStyle(fontSize: 13),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: softGreen,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "${_approvedLeaves.length}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          if (_canApprove) ...[
            _buildBulkSelectionBar(),
          ],
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTabList(_pendingLeaves, true),
                _buildTabList(_approvedLeaves, false),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _selectedLeaves.isNotEmpty
          ? _buildBulkActionBar()
          : null,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _openApplyLeaveDialog(),
          backgroundColor: primaryBlue,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            "Apply Leave",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  Widget _buildTabList(List<dynamic> list, bool isPending) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
            ),
            const SizedBox(height: 16),
            Text(
              "Loading leave requests...",
              style: TextStyle(color: darkGrey, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: lightBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPending ? Icons.pending_outlined : Icons.event_available,
                size: 60,
                color: primaryBlue.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isPending ? "No pending requests" : "No approved requests",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Leave requests will appear here",
              style: TextStyle(
                fontSize: 14,
                color: darkGrey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: primaryBlue,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final item = list[index];
          return _buildLeaveCard(item, isPending);
        },
      ),
    );
  }

  Widget _buildLeaveCard(dynamic item, bool isPending) {
    final bool isEligible = _isLeaveEligibleForApproval(item);
    final String itemId = item.id.toString();
    final bool isSelected = _selectedLeaves.containsKey(itemId);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: isSelected
            ? Border.all(color: primaryBlue, width: 2)
            : Border.all(color: Colors.transparent, width: 2),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? primaryBlue.withOpacity(0.15)
                : Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: isSelected ? lightBlue.withOpacity(0.25) : Colors.transparent,
          child: InkWell(
            onTap: () => _showDetails(item),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_canApprove) ...[
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0, top: 8.0),
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: isSelected,
                              activeColor: primaryBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              onChanged: isEligible
                                  ? (bool? val) {
                                      setState(() {
                                        if (val == true) {
                                          _selectedLeaves[itemId] = item;
                                        } else {
                                          _selectedLeaves.remove(itemId);
                                        }
                                      });
                                    }
                                  : null,
                            ),
                          ),
                        ),
                      ],
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              primaryBlue,
                              secondaryBlue,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: 28,
                          child: Text(
                            item.staffName?[0].toUpperCase() ?? 'S',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.staffName ?? 'Staff Name',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Row(
                            //   children: [
                            //     Container(
                            //       padding: const EdgeInsets.all(4),
                            //       decoration: BoxDecoration(
                            //         color: lightBlue,
                            //         borderRadius: BorderRadius.circular(6),
                            //       ),
                            //       child: const Icon(Icons.calendar_today,
                            //           size: 12, color: primaryBlue),
                            //     ),
                            //     const SizedBox(width: 6),
                            //     Expanded(
                            //       child: Text(
                            //         'Applied: ${item.createdAt ?? 'N/A'}',
                            //         style: TextStyle(
                            //           color: darkGrey,
                            //           fontSize: 13,
                            //         ),
                            //         overflow: TextOverflow.ellipsis,
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: softOrange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(Icons.access_time,
                                      size: 12, color: softOrange),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Day: ${item.dayType == "half" || item.dayType == "half_day" ? "Half Day${item.session != null ? " (${item.session})" : ""}" : item.dayType ?? "Full Day"}',
                                  style: TextStyle(
                                    color: darkGrey,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildStatusChip(item.status ?? 'Pending'),
                          if (isPending) ...[
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: () => _showActionSheet(item, isPending),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.more_horiz,
                                    size: 20, color: darkGrey),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  if (!isPending) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: lightGrey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text("Applied Section",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: darkGrey)),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: lightBlue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.category_outlined,
                                      size: 14, color: primaryBlue),
                                  const SizedBox(width: 4),
                                  const Text(
                                    "LEAVE TYPE",
                                    style: TextStyle(
                                      color: darkGrey,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.leaveType ?? 'N/A',
                                style: TextStyle(
                                  color: primaryBlue,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: softOrange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.calendar_today_outlined,
                                      size: 14, color: softOrange),
                                  const SizedBox(width: 4),
                                  const Text(
                                    "DURATION",
                                    style: TextStyle(
                                      color: darkGrey,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item.noOfDays ?? '0'} Days',
                                style: TextStyle(
                                  color: softOrange,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Builder(builder: (context) {
                    List<String> dateList = (item.leaveDates?.toString() ?? '')
                        .split(',')
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty)
                        .toList();
                    String displayText = '';
                    bool showViewMore = false;
                    if (dateList.length > 2) {
                      displayText =
                          'Leave Dates: ${dateList.take(2).join(", ")}...';
                      showViewMore = true;
                    } else if (dateList.isNotEmpty) {
                      displayText = 'Leave Dates: ${dateList.join(", ")}';
                    } else {
                      displayText = 'Leave Dates: N/A';
                    }

                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: lightGrey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(Icons.date_range_outlined,
                              size: 16, color: primaryBlue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              displayText,
                              style: const TextStyle(
                                color: primaryBlue,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (showViewMore) ...[
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => Dialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(24)),
                                    child: Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(24),
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.white,
                                            lightBlue.withOpacity(0.3),
                                          ],
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(12),
                                                decoration: const BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      primaryBlue,
                                                      secondaryBlue
                                                    ],
                                                  ),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                    Icons.calendar_month,
                                                    color: Colors.white,
                                                    size: 24),
                                              ),
                                              const SizedBox(width: 16),
                                              const Text(
                                                "Leave Dates",
                                                style: TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  color: primaryBlue,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Divider(height: 24),
                                          Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.3,
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border:
                                                  Border.all(color: lightBlue),
                                            ),
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              itemCount: dateList.length,
                                              itemBuilder: (context, i) {
                                                return Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 6.0),
                                                  child: Row(
                                                    children: [
                                                      const Icon(
                                                          Icons.check_circle,
                                                          size: 16,
                                                          color: softGreen),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        dateList[i],
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          SizedBox(
                                            width: double.infinity,
                                            child: OutlinedButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx),
                                              style: OutlinedButton.styleFrom(
                                                side: const BorderSide(
                                                    color: primaryBlue),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12)),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 14),
                                              ),
                                              child: const Text(
                                                "Close",
                                                style: TextStyle(
                                                    color: primaryBlue,
                                                    fontSize: 16),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: primaryBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  "View More",
                                  style: TextStyle(
                                    color: primaryBlue,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: lightGrey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.date_range_outlined,
                            size: 16, color: primaryBlue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            // '${item.fromDate ?? ''}  →  ${item.toDate ?? ''}',
                            'Applied On:${item.createdAt}',
                            style: TextStyle(
                              color: primaryBlue,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: lightGrey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.note_alt_outlined,
                            size: 16, color: primaryBlue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            // '${item.fromDate ?? ''}  →  ${item.toDate ?? ''}',
                            'Reason:${item.reason}',
                            style: TextStyle(
                              color: primaryBlue,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!isPending) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: lightBlue.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: primaryBlue.withOpacity(0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.verified_outlined,
                                  size: 18, color: primaryBlue),
                              SizedBox(width: 8),
                              Text("Approved Section",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: primaryBlue,
                                      fontSize: 15)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (item.approvedDates != "")
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.date_range_outlined,
                                      size: 16,
                                      color: Color.fromARGB(255, 61, 133, 19)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                      child: Text(
                                          'Approved Dates: ${item.approvedDates}',
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color: Color.fromARGB(
                                                  255, 61, 133, 19),
                                              fontWeight: FontWeight.w500))),
                                ],
                              ),
                            ),
                          if (item.approvedBy != "")
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.person_outline,
                                      size: 16,
                                      color: Color.fromARGB(255, 61, 133, 19)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                      child: Text(
                                          'Approved By: ${item.approvedBy}',
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color: Color.fromARGB(
                                                  255, 61, 133, 19),
                                              fontWeight: FontWeight.w500))),
                                ],
                              ),
                            ),
                          if (item.remarks != null && item.remarks!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.notes,
                                      size: 16,
                                      color:
                                          Color.fromARGB(255, 253, 192, 192)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                      child: Text('Notes: ${item.remarks!}',
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color: Color.fromARGB(
                                                  221, 182, 43, 43)))),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Divider(height: 1, thickness: 1, color: lightGrey),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StaffCalendarPage(
                                  staffId: item.userId,
                                  selectedDate: DateTime.now(),
                                  staffName: item.staffName,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.calendar_month,
                              size: 16, color: primaryBlue),
                          label: const Text("Attendance",
                              style: TextStyle(color: primaryBlue)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: primaryBlue),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showDetails(item),
                          icon: const Icon(Icons.visibility,
                              size: 16, color: Colors.white),
                          label: const Text("View",
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showActionSheet(dynamic item, bool isPending) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Options",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
              const SizedBox(height: 24),
              // We removed View details and View Attendance from here as they are shown directly now.
              if (isPending && _canApprove)
                _buildActionItem(
                  icon: Icons.check_circle_outline,
                  label: "Approve",
                  color: softGreen,
                  onTap: () {
                    Navigator.pop(context);
                    _showApproveDialog(item);
                  },
                ),
              if (isPending && _canReject)
                _buildActionItem(
                  icon: Icons.cancel_outlined,
                  label: "Reject",
                  color: softRed,
                  onTap: () {
                    Navigator.pop(context);
                    _confirmReject(item);
                  },
                ),
              if (isPending && _canEdit)
                _buildActionItem(
                  icon: Icons.edit_outlined,
                  label: "Edit",
                  color: softOrange,
                  onTap: () {
                    Navigator.pop(context);
                    _openApplyLeaveDialog(item: item);
                  },
                ),
              if (isPending && _canDelete)
                _buildActionItem(
                  icon: Icons.delete_outline,
                  label: "Delete",
                  color: softRed,
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDelete(item);
                  },
                ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Icon(Icons.chevron_right, size: 18, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    IconData icon;
    Color bgColor;
    String label = status.toUpperCase();

    if (status.toLowerCase().contains('pending')) {
      color = softOrange;
      bgColor = softOrange.withOpacity(0.1);
      icon = Icons.hourglass_empty;
    } else if (status.toLowerCase().contains('approved')) {
      color = softGreen;
      bgColor = softGreen.withOpacity(0.1);
      icon = Icons.check_circle;
    } else if (status.toLowerCase().contains('rejected')) {
      color = softRed;
      bgColor = softRed.withOpacity(0.1);
      icon = Icons.cancel;
    } else if (status.toLowerCase().contains('partial')) {
      color = const Color.fromARGB(255, 240, 222, 124);
      bgColor = const Color.fromARGB(255, 232, 241, 146).withOpacity(0.1);
      icon = Icons.cancel;
    } else {
      color = primaryBlue;
      bgColor = lightBlue;
      icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showDetails(dynamic item) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        clipBehavior: Clip.antiAlias,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  lightBlue.withOpacity(0.3),
                ],
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryBlue, secondaryBlue],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.description_outlined,
                            color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Leave Details",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: darkGrey, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(
                            Icons.person_outline, "Staff", item.staffName ?? 'N/A'),
                        _buildDetailRow(Icons.category_outlined, "Leave Type",
                            item.leaveType ?? 'N/A'),
                        _buildDetailRow(Icons.calendar_today_outlined, "Duration",
                            '${item.noOfDays ?? '0'} Days'),
                        if (item.session != null && item.session != "")
                          _buildDetailRow(
                              Icons.access_time,
                              "Session",
                              item.session[0].toUpperCase() +
                                  item.session.substring(1)),
                        // _buildDetailRow(
                        //     Icons.date_range, "From Date", item.fromDate ?? 'N/A'),
                        // _buildDetailRow(
                        //     Icons.date_range, "To Date", item.toDate ?? 'N/A'),
                        // _buildDetailRow(Icons.access_time, "Applied On",
                        //     item.createdAt ?? 'N/A'),
                        _buildDetailRow(
                            Icons.info_outline, "Status", item.status ?? 'Pending',
                            isStatus: true, status: item.status),
                        _buildDetailRow(
                          Icons.note_alt_outlined,
                          "Reason",
                          (item.reason != null &&
                                  item.reason.toString().trim().isNotEmpty)
                              ? item.reason.toString().trim()
                              : 'N/A',
                        ),
                        if (item.approvedBy != null && item.approvedBy != "")
                          _buildDetailRow(Icons.person_pin_outlined, "Approved By",
                              item.approvedBy),
                        if (item.approvedDates != null && item.approvedDates != "")
                          _buildDetailRow(Icons.date_range_outlined,
                              "Approved Dates", item.approvedDates),
                        if (item.remarks != null && item.remarks!.isNotEmpty)
                          _buildDetailRow(Icons.notes, "Remarks", item.remarks!,
                              isRemarks: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StaffCalendarPage(
                                  staffId: item.userId,
                                  selectedDate: DateTime.now(),
                                  staffName: item.staffName,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.calendar_month_outlined,
                              size: 16, color: primaryBlue),
                          label: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "Attendance",
                              style: TextStyle(color: primaryBlue, fontSize: 13),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: primaryBlue),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(
                                vertical: 13, horizontal: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(
                                vertical: 13, horizontal: 8),
                            elevation: 0,
                          ),
                          child: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "Close",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value,
      {bool isStatus = false, String? status, bool isRemarks = false}) {
    Color valueColor = Colors.black87;
    if (isStatus) {
      if (status?.toLowerCase().contains('pending') ?? false) {
        valueColor = softOrange;
      } else if (status?.toLowerCase().contains('approved') ?? false) {
        valueColor = softGreen;
      } else if (status?.toLowerCase().contains('rejected') ?? false) {
        valueColor = softRed;
      } else {
        valueColor = primaryBlue;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            child: Icon(icon, size: 18, color: primaryBlue),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: darkGrey,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isRemarks ? FontWeight.normal : FontWeight.w600,
                fontSize: isRemarks ? 13 : 14,
                color: isRemarks ? darkGrey : valueColor,
                fontStyle: isRemarks ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showApproveDialog(dynamic item) {
    List<String> dates = (item.leaveDates as String)
        .split(',')
        .map((e) => e.trim())
        .toList()
        .cast<String>();
    List<String> selectedDates = List.from(dates);
    TextEditingController remarksCtrl = TextEditingController();

    bool isActionLoading = false;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    softGreen.withOpacity(0.05),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: softGreen.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_circle_outline,
                            color: softGreen, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Approve Leave",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: softGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: lightBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.person, size: 16, color: primaryBlue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Staff: ${item.staffName}",
                            style: const TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 24),
                  const Text(
                    "Select Dates to Approve",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: lightGrey),
                    ),
                    child: Column(
                      children: [
                        CheckboxListTile(
                          title: const Text(
                            "Select All Dates",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          value: selectedDates.length == dates.length,
                          onChanged: (val) {
                            setState(() {
                              if (val == true)
                                selectedDates = List.from(dates);
                              else
                                selectedDates.clear();
                            });
                          },
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          activeColor: softGreen,
                          checkColor: Colors.white,
                        ),
                        const Divider(height: 1),
                        ...dates.map((date) => CheckboxListTile(
                              title: Text(
                                date,
                                style: const TextStyle(fontSize: 14),
                              ),
                              value: selectedDates.contains(date),
                              onChanged: (val) {
                                setState(() {
                                  if (val == true)
                                    selectedDates.add(date);
                                  else
                                    selectedDates.remove(date);
                                });
                              },
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              activeColor: softGreen,
                              checkColor: Colors.white,
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_allTemplates != null &&
                      _allTemplates!.any((e) =>
                          e.templateType?.toLowerCase() == 'approve')) ...[
                    const Text(
                      "Select Template",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _allTemplates!
                          .where(
                              (e) => e.templateType?.toLowerCase() == 'approve')
                          .map((t) => ActionChip(
                                label: Text(t.templateName ?? '',
                                    style: const TextStyle(fontSize: 12)),
                                backgroundColor: softGreen.withOpacity(0.1),
                                onPressed: () {
                                  setState(() {
                                    if (remarksCtrl.text.isEmpty) {
                                      remarksCtrl.text = t.templateBody ?? '';
                                    } else {
                                      remarksCtrl.text +=
                                          "\n${t.templateBody ?? ''}";
                                    }
                                  });
                                },
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  const Text(
                    "Admin Remarks",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: remarksCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Enter approval remarks...",
                      hintStyle: const TextStyle(color: darkGrey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Cancel"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: softGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 4,
                          ),
                          onPressed: isActionLoading
                              ? null
                              : () async {
                                  if (selectedDates.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                            "Please select at least one date"),
                                        backgroundColor: softRed,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() {
                                    isActionLoading = true;
                                  });

                                  try {
                                    final res = await HttpService.approveLeave(
                                        item.id,
                                        selectedDates.join(','),
                                        remarksCtrl.text);
                                    if (res != null && res.status == true) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(res.message),
                                          backgroundColor: softGreen,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                      );
                                      Navigator.pop(context);
                                      _loadData();
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                              Text(res?.message ?? "Error"),
                                          backgroundColor: softRed,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                      );
                                    }
                                  } finally {
                                    setState(() {
                                      isActionLoading = false;
                                    });
                                  }
                                },
                          child: isActionLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Approve",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _isLeaveEligibleForApproval(dynamic item) {
    if (!_canApprove) return false;
    final status = (item.status ?? '').toString().trim().toLowerCase();
    // Do not allow requests with Approved or Rejected status to be selected for bulk approval
    if (status.contains('approved') || status.contains('rejected')) {
      return false;
    }
    return status.contains('pending') ||
        status.contains('partial') ||
        status.isEmpty;
  }

  Widget _buildBulkSelectionBar() {
    final List<dynamic> currentList =
        _tabController.index == 0 ? _pendingLeaves : _approvedLeaves;
    final List<dynamic> eligibleItems =
        currentList.where(_isLeaveEligibleForApproval).toList();
    if (eligibleItems.isEmpty && _selectedLeaves.isEmpty) {
      return const SizedBox.shrink();
    }

    final bool allEligibleSelected = eligibleItems.isNotEmpty &&
        eligibleItems.every(
            (item) => _selectedLeaves.containsKey((item as dynamic).id.toString()));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: mediumGrey.withOpacity(0.5), width: 1),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: allEligibleSelected,
              activeColor: primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              onChanged: eligibleItems.isEmpty
                  ? null
                  : (bool? val) {
                      setState(() {
                        if (val == true) {
                          for (var item in eligibleItems) {
                            _selectedLeaves[(item as dynamic).id.toString()] = item;
                          }
                        } else {
                          for (var item in eligibleItems) {
                            _selectedLeaves.remove((item as dynamic).id.toString());
                          }
                        }
                      });
                    },
            ),
          ),
          const SizedBox(width: 8),
          Text(
            "Select All (${eligibleItems.length} eligible)",
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: darkGrey,
            ),
          ),
          const Spacer(),
          if (_selectedLeaves.isNotEmpty)
            TextButton.icon(
              onPressed: _showBulkApproveDialog,
              icon: const Icon(Icons.check_circle_outline,
                  size: 16, color: softGreen),
              label: Text(
                "Approve (${_selectedLeaves.length})",
                style: const TextStyle(
                  color: softGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: softGreen.withOpacity(0.1),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBulkActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${_selectedLeaves.length} selected",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 2),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _selectedLeaves.clear();
                      });
                    },
                    child: const Text(
                      "Clear Selection",
                      style: TextStyle(
                        color: softRed,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: _showBulkApproveDialog,
              icon: const Icon(Icons.check_circle_outline,
                  color: Colors.white, size: 18),
              label: Text(
                "Bulk Approve (${_selectedLeaves.length})",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: softGreen,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBulkApproveDialog() {
    if (_selectedLeaves.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text("Please select at least one leave request to approve"),
          backgroundColor: softRed,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final TextEditingController remarksCtrl = TextEditingController();
    bool isActionLoading = false;

    showDialog(
      context: context,
      barrierDismissible: !isActionLoading,
      builder: (context) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    softGreen.withOpacity(0.05),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: softGreen.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_circle_outline,
                            color: softGreen, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Bulk Approve",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: softGreen,
                              ),
                            ),
                            Text(
                              "${_selectedLeaves.length} leave request(s) selected",
                              style: const TextStyle(
                                fontSize: 13,
                                color: darkGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  const Text(
                    "Admin Remarks",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: remarksCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Enter approval remarks...",
                      hintStyle: const TextStyle(color: darkGrey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: lightGrey,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: isActionLoading
                              ? null
                              : () => Navigator.pop(dialogCtx),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Cancel"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: softGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 4,
                          ),
                          onPressed: isActionLoading
                              ? null
                              : () async {
                                  setDialogState(() {
                                    isActionLoading = true;
                                  });

                                  final selectedList = _selectedLeaves.values
                                      .where(_isLeaveEligibleForApproval)
                                      .toList();
                                  final remarks = remarksCtrl.text.trim();
                                  int successCount = 0;
                                  int failureCount = 0;

                                  for (final item in selectedList) {
                                    final dates =
                                        (item.leaveDates?.toString() ?? '')
                                            .split(',')
                                            .map((e) => e.trim())
                                            .where((e) => e.isNotEmpty)
                                            .join(',');

                                    try {
                                      final res =
                                          await HttpService.approveLeave(
                                        item.id.toString(),
                                        dates,
                                        remarks,
                                      );
                                      if (res != null &&
                                          (res.status == true ||
                                              res.message
                                                  .toString()
                                                  .toLowerCase()
                                                  .contains('success'))) {
                                        successCount++;
                                      } else {
                                        failureCount++;
                                      }
                                    } catch (e) {
                                      failureCount++;
                                    }
                                  }

                                  if (dialogCtx.mounted) {
                                    Navigator.pop(dialogCtx);
                                  }
                                  if (!mounted) return;
                                  setState(() {
                                    _selectedLeaves.clear();
                                  });

                                  if (failureCount == 0) {
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "Successfully approved $successCount leave request(s)"),
                                        backgroundColor: softGreen,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                    );
                                  } else {
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "Approved $successCount request(s), $failureCount failed"),
                                        backgroundColor: successCount > 0
                                            ? softOrange
                                            : softRed,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                    );
                                  }

                                  _loadData();
                                },
                          child: isActionLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Confirm",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmReject(dynamic item) {
    TextEditingController remarksCtrl = TextEditingController();
    bool isActionLoading = false;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          clipBehavior: Clip.antiAlias,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    softRed.withOpacity(0.05),
                  ],
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: softRed.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.cancel_outlined,
                              color: softRed, size: 22),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            "Reject Leave",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: softRed,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: darkGrey, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text(
                              "Are you sure you want to reject this leave request?",
                              style: TextStyle(fontSize: 15),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_allTemplates != null &&
                              _allTemplates!.any((e) =>
                                  e.templateType?.toLowerCase() == 'reject')) ...[
                            const Text(
                              "Select Template",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: primaryBlue,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _allTemplates!
                                  .where((e) =>
                                      e.templateType?.toLowerCase() == 'reject')
                                  .map((t) => ActionChip(
                                        label: Text(t.templateName ?? '',
                                            style: const TextStyle(fontSize: 12)),
                                        backgroundColor: softRed.withOpacity(0.1),
                                        onPressed: () {
                                          setState(() {
                                            if (remarksCtrl.text.isEmpty) {
                                              remarksCtrl.text =
                                                  t.templateBody ?? '';
                                            } else {
                                              remarksCtrl.text +=
                                                  "\n${t.templateBody ?? ''}";
                                            }
                                          });
                                        },
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: 16),
                          ],
                          TextField(
                            controller: remarksCtrl,
                            minLines: 2,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: "Reason for rejection...",
                              hintStyle: const TextStyle(color: darkGrey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: lightGrey,
                              contentPadding: const EdgeInsets.all(14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: mediumGrey),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 13, horizontal: 8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                  color: darkGrey,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: softRed,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 13, horizontal: 8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                            ),
                            onPressed: isActionLoading
                                ? null
                                : () async {
                                    setState(() {
                                      isActionLoading = true;
                                    });

                                    try {
                                      final res = await HttpService.rejectLeave(
                                          item.id,
                                          remarks: remarksCtrl.text);
                                      if (!context.mounted) return;
                                      if (res != null && res.status == true) {
                                        Navigator.pop(context);
                                        _loadData();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: const Text(
                                                "Leave request rejected"),
                                            backgroundColor: softGreen,
                                            behavior:
                                                SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(res?.message ??
                                                "Failed to reject"),
                                            backgroundColor: softRed,
                                            behavior:
                                                SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                          ),
                                        );
                                      }
                                    } finally {
                                      setState(() {
                                        isActionLoading = false;
                                      });
                                    }
                                  },
                            child: isActionLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      "Reject",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(dynamic item) {
    bool isActionLoading = false;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  softRed.withOpacity(0.05),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: softRed.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_outline,
                      color: softRed, size: 32),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Delete Request",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: softRed,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Are you sure you want to delete this leave request permanently?",
                  style: TextStyle(fontSize: 15, color: darkGrey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: softRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                        ),
                        onPressed: isActionLoading
                            ? null
                            : () async {
                                setState(() {
                                  isActionLoading = true;
                                });

                                try {
                                  final res =
                                      await HttpService.deleteLeaveRequest(
                                          item.id);
                                  if (res != null && res.status == true) {
                                    Navigator.pop(context);
                                    _loadData();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            const Text("Leave request deleted"),
                                        backgroundColor: softGreen,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            res?.message ?? "Failed to delete"),
                                        backgroundColor: softRed,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                    );
                                  }
                                } finally {
                                  setState(() {
                                    isActionLoading = false;
                                  });
                                }
                              },
                        child: isActionLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Delete",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeaveBalanceWidget(String? type, GetLeaveBalanceModel? balance) {
    if (balance == null || type == null) return const SizedBox.shrink();

    LeaveType? typeData;
    if (type.toLowerCase().contains('casual')) {
      typeData = balance.data.casual;
    } else if (type.toLowerCase().contains('saturday')) {
      typeData = balance.data.saturday;
    }

    if (typeData == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryBlue.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_outlined,
                  size: 18, color: primaryBlue),
              const SizedBox(width: 8),
              const Text(
                "Leave Balance",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildBalanceItem(
                  "Allowed", typeData.allowed.toString(), primaryBlue),
              Container(width: 1, height: 30, color: Colors.grey[300]),
              _buildBalanceItem("Taken", typeData.taken.toString(), softOrange),
              Container(width: 1, height: 30, color: Colors.grey[300]),
              _buildBalanceItem(
                  "Balance", typeData.balance.toString(), softGreen),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceItem(String title, String value, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: darkGrey)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  void _openApplyLeaveDialog({dynamic item}) {
    bool isEdit = item != null;
    String? leaveType =
        isEdit ? _normalizeLeaveType(item.leaveType) : _leaveTypeFilters[0];

    GetLeaveBalanceModel? leaveBalance;
    bool isFetchingBalance = false;

    Future<void> fetchBalance(StateSetter setS) async {
      setS(() => isFetchingBalance = true);
      try {
        final res = await HttpService.leaveAvailable();
        if (res != null && res.status) {
          setS(() => leaveBalance = res);
        }
      } catch (e) {
        debugPrint("Error fetching leave balance: $e");
      } finally {
        setS(() => isFetchingBalance = false);
      }
    }

    List<String> selectedDates = [];
    if (isEdit && item.leaveDates != null && item.leaveDates.isNotEmpty) {
      selectedDates = item.leaveDates
          .toString()
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList()
          .cast<String>();
    }

    TextEditingController remarkCtrl = TextEditingController(
        text: isEdit ? (item.remarks ?? item.reason) : "");
    bool isHalfDay =
        isEdit ? (item.dayType == "half" || item.dayType == "half_day") : false;
    String? selectedSession = isEdit ? item.session : null;

    bool isActionLoading = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        bool initialLoad = true;
        return StatefulBuilder(
          builder: (context, setS) {
            if (initialLoad) {
              initialLoad = false;
              fetchBalance(setS);
            }
            return Container(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.9),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 20,
                  right: 20,
                  top: 20,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [primaryBlue, secondaryBlue],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              isEdit ? Icons.edit_outlined : Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            isEdit ? "Edit Leave Request" : "Apply for Leave",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: lightBlue,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Leave Type",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: primaryBlue,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: DropdownButtonFormField<String>(
                                value: leaveType,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  prefixIcon: const Icon(
                                      Icons.category_outlined,
                                      color: primaryBlue),
                                ),
                                items: _leaveTypeFilters
                                    .map((e) => DropdownMenuItem(
                                        value: e, child: Text(e)))
                                    .toList(),
                                onChanged: (v) {
                                  setS(() => leaveType = v);
                                  fetchBalance(setS);
                                },
                              ),
                            ),
                            if (isFetchingBalance)
                              const Padding(
                                padding: EdgeInsets.only(top: 16),
                                child: Center(
                                  child: SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: primaryBlue),
                                  ),
                                ),
                              )
                            else
                              _buildLeaveBalanceWidget(leaveType, leaveBalance),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: lightBlue,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Selected Dates",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: primaryBlue,
                                  ),
                                ),
                                if (selectedDates.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: softOrange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      isHalfDay
                                          ? "${selectedDates.length / 2} Days"
                                          : "${selectedDates.length} Days",
                                      style: const TextStyle(
                                        color: softOrange,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (selectedDates.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.info_outline,
                                        size: 16, color: darkGrey),
                                    const SizedBox(width: 8),
                                    const Text(
                                      "No dates selected",
                                      style: TextStyle(
                                          color: darkGrey, fontSize: 13),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: selectedDates
                                    .map((date) => Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.05),
                                                blurRadius: 5,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Chip(
                                            label: Text(
                                              date,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            onDeleted: () {
                                              setS(() {
                                                selectedDates.remove(date);
                                              });
                                            },
                                            deleteIcon: const Icon(Icons.close,
                                                size: 16, color: softRed),
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () async {
                                final p = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                                  lastDate: DateTime(2100),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: const ColorScheme.light(
                                          primary: primaryBlue,
                                          onPrimary: Colors.white,
                                          surface: Colors.white,
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (p != null) {
                                  String formatted =
                                      DateFormat('dd-MM-yyyy').format(p);
                                  if (!selectedDates.contains(formatted)) {
                                    setS(() {
                                      selectedDates.add(formatted);
                                      selectedDates.sort((a, b) {
                                        DateTime dateA =
                                            DateFormat('dd-MM-yyyy').parse(a);
                                        DateTime dateB =
                                            DateFormat('dd-MM-yyyy').parse(b);
                                        return dateA.compareTo(dateB);
                                      });
                                    });
                                  }
                                }
                              },
                              icon: const Icon(Icons.add),
                              label: const Text("Add Date"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: primaryBlue,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: lightBlue,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Leave Duration",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: primaryBlue,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  CheckboxListTile(
                                    title: const Text(
                                      "Is Half Day?",
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    value: isHalfDay,
                                    onChanged: (v) {
                                      setS(() {
                                        isHalfDay = v ?? false;
                                        if (!isHalfDay) selectedSession = null;
                                      });
                                    },
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    activeColor: primaryBlue,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    dense: true,
                                  ),
                                  if (isHalfDay) ...[
                                    const Divider(height: 1),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: InkWell(
                                              onTap: () => setS(() =>
                                                  selectedSession = "morning"),
                                              child: Row(
                                                children: [
                                                  Radio<String>(
                                                    value: "morning",
                                                    groupValue: selectedSession,
                                                    onChanged: (v) => setS(() =>
                                                        selectedSession = v),
                                                    activeColor: primaryBlue,
                                                  ),
                                                  const Text("Morning"),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: InkWell(
                                              onTap: () => setS(() =>
                                                  selectedSession =
                                                      "afternoon"),
                                              child: Row(
                                                children: [
                                                  Radio<String>(
                                                    value: "afternoon",
                                                    groupValue: selectedSession,
                                                    onChanged: (v) => setS(() =>
                                                        selectedSession = v),
                                                    activeColor: primaryBlue,
                                                  ),
                                                  const Text("Afternoon"),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: lightBlue,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Reason / Remarks",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: primaryBlue,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: remarkCtrl,
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText: "Enter your reason for leave...",
                                hintStyle: const TextStyle(color: darkGrey),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.all(16),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                          ),
                          onPressed: isActionLoading
                              ? null
                              : () async {
                                  if (leaveType == null ||
                                      selectedDates.isEmpty) {
                                    Common.toastMessaage(
                                        "Please select leave type and at least one date",
                                        Colors.red);
                                    return;
                                  }

                                  if (isHalfDay && selectedSession == null) {
                                    Common.toastMessaage(
                                        "Please select Morning or Afternoon for half day leave",
                                        Colors.red);
                                    return;
                                  }

                                  if (remarkCtrl.text.trim().isEmpty) {
                                    Common.toastMessaage(
                                        "Please enter reason / remarks for leave",
                                        Colors.red);
                                    return;
                                  }

                                  setS(() {
                                    isActionLoading = true;
                                  });

                                  try {
                                    if (isEdit) {
                                      final res =
                                          await HttpService.editLeaveRequest(
                                        id: item.id,
                                        leaveType: leaveType!,
                                        date: selectedDates.join(','),
                                        remarks: remarkCtrl.text,
                                        isHalfDay: isHalfDay,
                                        session: selectedSession,
                                      );
                                      if (res != null && res.status) {
                                        Navigator.pop(context);
                                        _loadData();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: const Text(
                                                "Leave request updated"),
                                            backgroundColor: softGreen,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(res?.message ??
                                                "Failed to update"),
                                            backgroundColor: softRed,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                          ),
                                        );
                                      }
                                    } else {
                                      final res =
                                          await HttpService.saveLeaveOfficial(
                                        leaveType: leaveType!,
                                        date: selectedDates.join(','),
                                        remarks: remarkCtrl.text,
                                        isHalfDay: isHalfDay,
                                        session: selectedSession,
                                      );
                                      if (res) {
                                        Navigator.pop(context);
                                        _loadData();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content:
                                                Text("Leave request submitted"),
                                            backgroundColor: softGreen,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                "Failed to submit request"),
                                            backgroundColor: softRed,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                          ),
                                        );
                                      }
                                    }
                                  } finally {
                                    if (mounted) {
                                      setS(() {
                                        isActionLoading = false;
                                      });
                                    }
                                  }
                                },
                          child: isActionLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  isEdit ? "Update Request" : "Submit Request",
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

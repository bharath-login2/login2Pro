import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/staffServiceModel.dart';
import 'package:login2/models/product_mannagement/get_service_list_model.dart';
import 'package:login2/models/product_mannagement/product_list_model.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:login2/models/expense/account_head_model.dart';
import 'package:login2/service/service.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductServiceListPage extends StatefulWidget {
  const ProductServiceListPage({super.key});

  @override
  State<ProductServiceListPage> createState() => _ProductServiceListPageState();
}

class _ProductServiceListPageState extends State<ProductServiceListPage> {
  bool isLoading = true;
  bool isTableView = false; // Toggle between Modern Cards & Table

  GetServiceListModel? serviceListResponse;
  List<ServiceListItem> allServices = [];
  List<ServiceListItem> filteredServices = [];

  // Dropdown options loaded from API
  List<ProductList> productOptions = [];
  List<Staff> staffOptions = [];

  // Filter Selections
  String selectedProductId = "";
  String selectedStaffId = "";
  String selectedServiceType = ""; // "", "Monthly Service", "Repair"
  DateTime? selectedFromDate;
  DateTime? selectedToDate;

  // Search & Pagination
  final TextEditingController _searchController = TextEditingController();
  bool showSearchField = false;
  int entriesPerPage = 10;
  int currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final productsRes = await HttpService.getProductLists("");
      final staffsRes = await HttpService.getStaffservice();

      if (mounted) {
        setState(() {
          if (productsRes != null && productsRes.data.isNotEmpty) {
            productOptions = productsRes.data;
          }
          if (staffsRes != null && staffsRes.data.isNotEmpty) {
            staffOptions = staffsRes.data;
          }
        });
      }

      await _fetchServiceList();
    } catch (e) {
      debugPrint("Error loading initial data: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchServiceList() async {
    setState(() {
      isLoading = true;
    });

    try {
      final fromStr = selectedFromDate != null
          ? DateFormat('yyyy-MM-dd').format(selectedFromDate!)
          : "";
      final toStr = selectedToDate != null
          ? DateFormat('yyyy-MM-dd').format(selectedToDate!)
          : "";

      final res = await HttpService.getServiceList(
        selectedProductId,
        selectedStaffId,
        selectedServiceType,
        fromStr,
        toStr,
      );

      if (mounted) {
        setState(() {
          serviceListResponse = res;
          allServices = res?.data ?? [];
          _applySearchFilter();
        });
      }
    } catch (e) {
      debugPrint("Error fetching service list: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _applySearchFilter() {
    final query = _searchController.text.trim().toLowerCase();
    List<ServiceListItem> list = List.from(allServices);

    if (selectedProductId.isNotEmpty) {
      list = list.where((item) => item.productId == selectedProductId).toList();
    }

    if (selectedStaffId.isNotEmpty) {
      list = list.where((item) =>
          item.vendorUserId == selectedStaffId ||
          item.vendorName.toLowerCase().contains(selectedStaffId.toLowerCase())).toList();
    }

    if (selectedServiceType.isNotEmpty) {
      if (selectedServiceType.toLowerCase().contains("monthly") || selectedServiceType == "filter_service_type") {
        list = list.where((item) => item.serviceType.toLowerCase().contains("monthly")).toList();
      } else if (selectedServiceType.toLowerCase().contains("repair")) {
        list = list.where((item) => item.serviceType.toLowerCase().contains("repair")).toList();
      } else {
        list = list.where((item) => item.serviceType.toLowerCase().contains(selectedServiceType.toLowerCase())).toList();
      }
    }

    if (selectedFromDate != null) {
      list = list.where((item) {
        if (item.serviceDate.isEmpty) return true;
        try {
          final dt = DateTime.parse(item.serviceDate);
          final fromDt = DateTime(selectedFromDate!.year, selectedFromDate!.month, selectedFromDate!.day);
          return dt.isAfter(fromDt.subtract(const Duration(seconds: 1))) || dt.isAtSameMomentAs(fromDt);
        } catch (_) {
          return true;
        }
      }).toList();
    }

    if (selectedToDate != null) {
      list = list.where((item) {
        if (item.serviceDate.isEmpty) return true;
        try {
          final dt = DateTime.parse(item.serviceDate);
          final toDt = DateTime(selectedToDate!.year, selectedToDate!.month, selectedToDate!.day, 23, 59, 59);
          return dt.isBefore(toDt.add(const Duration(seconds: 1))) || dt.isAtSameMomentAs(toDt);
        } catch (_) {
          return true;
        }
      }).toList();
    }

    if (query.isNotEmpty) {
      list = list.where((item) {
        return item.productName.toLowerCase().contains(query) ||
            item.vendorName.toLowerCase().contains(query) ||
            item.servicePlace.toLowerCase().contains(query) ||
            item.serviceType.toLowerCase().contains(query) ||
            item.paymentStatus.toLowerCase().contains(query) ||
            item.issues.toLowerCase().contains(query);
      }).toList();
    }

    filteredServices = list;
    currentPage = 1;
  }

  void _resetFilters() {
    setState(() {
      selectedProductId = "";
      selectedStaffId = "";
      selectedServiceType = "";
      selectedFromDate = null;
      selectedToDate = null;
      _searchController.clear();
    });
    _fetchServiceList();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    if (phoneNumber.trim().isEmpty) return;
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber.trim());
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      }
    } catch (e) {
      debugPrint("Could not launch phone: $e");
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    if (phoneNumber.trim().isEmpty) return;
    var cleanNum = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (!cleanNum.startsWith('91') && cleanNum.length == 10) {
      cleanNum = '91$cleanNum';
    }
    final Uri whatsappUri = Uri.parse("https://wa.me/$cleanNum");
    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Could not launch WhatsApp: $e");
    }
  }

  int get _appliedFiltersCount {
    int count = 0;
    if (selectedProductId.isNotEmpty) count++;
    if (selectedStaffId.isNotEmpty) count++;
    if (selectedServiceType.isNotEmpty) count++;
    if (selectedFromDate != null || selectedToDate != null) count++;
    return count;
  }

  void _showFilterBottomSheet() {
    String tempProductId = selectedProductId;
    String tempStaffId = selectedStaffId;
    String tempServiceType = selectedServiceType;
    DateTime? tempFromDate = selectedFromDate;
    DateTime? tempToDate = selectedToDate;

    int activeTab = 0;
    String staffSearchQuery = "";
    String productSearchQuery = "";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.72,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Filters",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 22, color: Color(0xFF64748B)),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 130,
                          color: const Color(0xFFF8FAFC),
                          child: Column(
                            children: [
                              _buildLeftNavTab(
                                index: 0,
                                label: "Service Date",
                                icon: Icons.calendar_month_outlined,
                                isActive: activeTab == 0,
                                hasValue: tempFromDate != null || tempToDate != null,
                                onTap: () => setSheetState(() => activeTab = 0),
                              ),
                              _buildLeftNavTab(
                                index: 1,
                                label: "Assigned Staff",
                                icon: Icons.people_outline_rounded,
                                isActive: activeTab == 1,
                                hasValue: tempStaffId.isNotEmpty,
                                onTap: () => setSheetState(() => activeTab = 1),
                              ),
                              _buildLeftNavTab(
                                index: 2,
                                label: "Service Type",
                                icon: Icons.category_outlined,
                                isActive: activeTab == 2,
                                hasValue: tempServiceType.isNotEmpty,
                                onTap: () => setSheetState(() => activeTab = 2),
                              ),
                              _buildLeftNavTab(
                                index: 3,
                                label: "Products",
                                icon: Icons.shopping_bag_outlined,
                                isActive: activeTab == 3,
                                hasValue: tempProductId.isNotEmpty,
                                onTap: () => setSheetState(() => activeTab = 3),
                              ),
                            ],
                          ),
                        ),
                        const VerticalDivider(width: 1, thickness: 1, color: Color(0xFFE2E8F0)),

                        Expanded(
                          child: Container(
                            color: Colors.white,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      activeTab == 0
                                          ? "Select Date Range"
                                          : activeTab == 1
                                              ? "Select Staff"
                                              : activeTab == 2
                                                  ? "Select Service Type"
                                                  : "Select Product",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        setSheetState(() {
                                          if (activeTab == 0) {
                                            tempFromDate = null;
                                            tempToDate = null;
                                          } else if (activeTab == 1) {
                                            tempStaffId = "";
                                          } else if (activeTab == 2) {
                                            tempServiceType = "";
                                          } else if (activeTab == 3) {
                                            tempProductId = "";
                                          }
                                        });
                                      },
                                      child: const Text(
                                        "Clear",
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFFEF4444),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                Expanded(
                                  child: IndexedStack(
                                    index: activeTab,
                                    children: [
                                      _buildDateRangeTabContent(
                                        tempFromDate: tempFromDate,
                                        tempToDate: tempToDate,
                                        onFromDateTap: () async {
                                          final dt = await showDatePicker(
                                            context: context,
                                            initialDate: tempFromDate ?? DateTime.now(),
                                            firstDate: DateTime(2020),
                                            lastDate: DateTime(2030),
                                          );
                                          if (dt != null) {
                                            setSheetState(() => tempFromDate = dt);
                                          }
                                        },
                                        onToDateTap: () async {
                                          final dt = await showDatePicker(
                                            context: context,
                                            initialDate: tempToDate ?? DateTime.now(),
                                            firstDate: DateTime(2020),
                                            lastDate: DateTime(2030),
                                          );
                                          if (dt != null) {
                                            setSheetState(() => tempToDate = dt);
                                          }
                                        },
                                        onTodayTap: () {
                                          final now = DateTime.now();
                                          setSheetState(() {
                                            tempFromDate = now;
                                            tempToDate = now;
                                          });
                                        },
                                        onThisMonthTap: () {
                                          final now = DateTime.now();
                                          setSheetState(() {
                                            tempFromDate = DateTime(now.year, now.month, 1);
                                            tempToDate = DateTime(now.year, now.month + 1, 0);
                                          });
                                        },
                                      ),

                                      _buildStaffTabContent(
                                        tempStaffId: tempStaffId,
                                        searchQuery: staffSearchQuery,
                                        onSearchChanged: (val) => setSheetState(() => staffSearchQuery = val),
                                        onSelectStaff: (id) => setSheetState(() => tempStaffId = id),
                                      ),

                                      _buildServiceTypeTabContent(
                                        tempServiceType: tempServiceType,
                                        onSelectType: (type) => setSheetState(() => tempServiceType = type),
                                      ),

                                      _buildProductTabContent(
                                        tempProductId: tempProductId,
                                        searchQuery: productSearchQuery,
                                        onSearchChanged: (val) => setSheetState(() => productSearchQuery = val),
                                        onSelectProduct: (id) => setSheetState(() => tempProductId = id),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setSheetState(() {
                                tempProductId = "";
                                tempStaffId = "";
                                tempServiceType = "";
                                tempFromDate = null;
                                tempToDate = null;
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF64748B),
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                              minimumSize: const Size(0, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Clear All",
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                selectedProductId = tempProductId;
                                selectedStaffId = tempStaffId;
                                selectedServiceType = tempServiceType;
                                selectedFromDate = tempFromDate;
                                selectedToDate = tempToDate;
                              });
                              Navigator.pop(context);
                              _fetchServiceList();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2A86C9),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              minimumSize: const Size(0, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Apply Filters",
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLeftNavTab({
    required int index,
    required String label,
    required IconData icon,
    required bool isActive,
    required bool hasValue,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isActive ? const Color(0xFF2A86C9) : Colors.transparent,
              width: 3.5,
            ),
          ),
        ),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isActive ? const Color(0xFF2A86C9) : const Color(0xFF94A3B8),
                ),
                if (hasValue)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF59E0B),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? const Color(0xFF2A86C9) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeTabContent({
    required DateTime? tempFromDate,
    required DateTime? tempToDate,
    required VoidCallback onFromDateTap,
    required VoidCallback onToDateTap,
    required VoidCallback onTodayTap,
    required VoidCallback onThisMonthTap,
  }) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onFromDateTap,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "From Date",
                        style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tempFromDate != null
                            ? DateFormat('dd/MM/yyyy').format(tempFromDate)
                            : "Select Date",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: tempFromDate != null ? const Color(0xFF1E293B) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF2A86C9)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          InkWell(
            onTap: onToDateTap,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "To Date",
                        style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tempToDate != null
                            ? DateFormat('dd/MM/yyyy').format(tempToDate)
                            : "Select Date",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: tempToDate != null ? const Color(0xFF1E293B) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF2A86C9)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onTodayTap,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFEFF6FF),
                    foregroundColor: const Color(0xFF2A86C9),
                    side: const BorderSide(color: Color(0xFFBFDBFE)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Today", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: onThisMonthTap,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFEFF6FF),
                    foregroundColor: const Color(0xFF2A86C9),
                    side: const BorderSide(color: Color(0xFFBFDBFE)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("This Month", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStaffTabContent({
    required String tempStaffId,
    required String searchQuery,
    required ValueChanged<String> onSearchChanged,
    required ValueChanged<String> onSelectStaff,
  }) {
    final filteredStaff = staffOptions.where((s) {
      return s.name.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Column(
      children: [
        SizedBox(
          height: 38,
          child: TextField(
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: "Search staff...",
              hintStyle: const TextStyle(fontSize: 12),
              prefixIcon: const Icon(Icons.search, size: 18),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onChanged: onSearchChanged,
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView(
            children: [
              RadioListTile<String>(
                value: "",
                groupValue: tempStaffId,
                title: const Text("All Staffs", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                activeColor: const Color(0xFF2A86C9),
                contentPadding: EdgeInsets.zero,
                dense: true,
                onChanged: (val) => onSelectStaff(""),
              ),
              ...filteredStaff.map(
                (s) => RadioListTile<String>(
                  value: s.id,
                  groupValue: tempStaffId,
                  title: Text(s.name, style: const TextStyle(fontSize: 13)),
                  activeColor: const Color(0xFF2A86C9),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  onChanged: (val) => onSelectStaff(val ?? ""),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServiceTypeTabContent({
    required String tempServiceType,
    required ValueChanged<String> onSelectType,
  }) {
    final options = [
      {"label": "All Types", "value": ""},
      {"label": "Monthly Service", "value": "Monthly Service"},
      {"label": "Repair", "value": "Repair"},
    ];

    return ListView(
      children: options.map((opt) {
        final isSelected = tempServiceType == opt["value"];
        return InkWell(
          onTap: () => onSelectType(opt["value"]!),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? const Color(0xFF2A86C9) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  opt["label"]!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? const Color(0xFF2A86C9) : const Color(0xFF1E293B),
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF2A86C9), size: 18),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProductTabContent({
    required String tempProductId,
    required String searchQuery,
    required ValueChanged<String> onSearchChanged,
    required ValueChanged<String> onSelectProduct,
  }) {
    final filteredProds = productOptions.where((p) {
      return p.productName.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Column(
      children: [
        SizedBox(
          height: 38,
          child: TextField(
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: "Search product...",
              hintStyle: const TextStyle(fontSize: 12),
              prefixIcon: const Icon(Icons.search, size: 18),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onChanged: onSearchChanged,
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView(
            children: [
              RadioListTile<String>(
                value: "",
                groupValue: tempProductId,
                title: const Text("All Products", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                activeColor: const Color(0xFF2A86C9),
                contentPadding: EdgeInsets.zero,
                dense: true,
                onChanged: (val) => onSelectProduct(""),
              ),
              ...filteredProds.map(
                (p) => RadioListTile<String>(
                  value: p.id,
                  groupValue: tempProductId,
                  title: Text(p.productName, style: const TextStyle(fontSize: 13)),
                  activeColor: const Color(0xFF2A86C9),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  onChanged: (val) => onSelectProduct(val ?? ""),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalServicesCount = filteredServices.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2A86C9), Color(0xFF1E6091)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 34,
                        width: 34,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white70),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_outlined,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Product Services",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isTableView ? Icons.grid_view_rounded : Icons.table_chart_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          isTableView = !isTableView;
                        });
                      },
                      tooltip: isTableView ? "Switch to Cards" : "Switch to Table",
                    ),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      onPressed: _showAddServiceModal,
                      tooltip: "Add Product Service",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchServiceList,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopHeaderStatsBar(totalServicesCount),
                    const SizedBox(height: 12),

                    if (showSearchField) ...[
                      _buildSearchField(),
                      const SizedBox(height: 12),
                    ],

                    if (_appliedFiltersCount > 0) ...[
                      _buildActiveFilterChips(),
                      const SizedBox(height: 12),
                    ],

                    if (filteredServices.isEmpty)
                      _buildEmptyState()
                    else if (isTableView)
                      _buildServiceTable()
                    else
                      _buildModernServiceCardsList(),

                    const SizedBox(height: 16),

                    if (filteredServices.isNotEmpty) _buildPaginationFooter(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTopHeaderStatsBar(int totalCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.business_center_rounded,
                  color: Color(0xFF2A86C9),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "Total Services : $totalCount",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),

          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  InkWell(
                    onTap: _showFilterBottomSheet,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _appliedFiltersCount > 0
                            ? const Color(0xFFEFF6FF)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _appliedFiltersCount > 0
                              ? const Color(0xFF2A86C9)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Icon(
                        Icons.filter_alt_outlined,
                        color: _appliedFiltersCount > 0
                            ? const Color(0xFF2A86C9)
                            : const Color(0xFF64748B),
                        size: 20,
                      ),
                    ),
                  ),
                  if (_appliedFiltersCount > 0)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          "$_appliedFiltersCount",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),

              InkWell(
                onTap: () {
                  setState(() {
                    showSearchField = !showSearchField;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: showSearchField ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: showSearchField ? const Color(0xFF2A86C9) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Icon(
                    showSearchField ? Icons.close : Icons.search_rounded,
                    color: showSearchField ? const Color(0xFF2A86C9) : const Color(0xFF64748B),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: "Search by product, vendor, place or issue...",
          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF64748B)),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _applySearchFilter();
                    });
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: InputBorder.none,
        ),
        onChanged: (_) {
          setState(() {
            _applySearchFilter();
          });
        },
      ),
    );
  }

  Widget _buildActiveFilterChips() {
    String prodName = selectedProductId;
    final matchedProds = productOptions.where((p) => p.id == selectedProductId).toList();
    if (matchedProds.isNotEmpty) prodName = matchedProds.first.productName;

    String staffName = selectedStaffId;
    final matchedStaffs = staffOptions.where((s) => s.id == selectedStaffId).toList();
    if (matchedStaffs.isNotEmpty) staffName = matchedStaffs.first.name;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          const Text(
            "Filters: ",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
          ),
          if (selectedProductId.isNotEmpty)
            _buildFilterChip(
              "Product: $prodName",
              () {
                setState(() => selectedProductId = "");
                _fetchServiceList();
              },
            ),
          if (selectedStaffId.isNotEmpty)
            _buildFilterChip(
              "Staff: $staffName",
              () {
                setState(() => selectedStaffId = "");
                _fetchServiceList();
              },
            ),
          if (selectedServiceType.isNotEmpty)
            _buildFilterChip(
              "Type: $selectedServiceType",
              () {
                setState(() => selectedServiceType = "");
                _fetchServiceList();
              },
            ),
          if (selectedFromDate != null)
            _buildFilterChip(
              "From: ${DateFormat('dd/MM/yyyy').format(selectedFromDate!)}",
              () {
                setState(() => selectedFromDate = null);
                _fetchServiceList();
              },
            ),
          if (selectedToDate != null)
            _buildFilterChip(
              "To: ${DateFormat('dd/MM/yyyy').format(selectedToDate!)}",
              () {
                setState(() => selectedToDate = null);
                _fetchServiceList();
              },
            ),
          InkWell(
            onTap: _resetFilters,
            child: const Padding(
              padding: EdgeInsets.only(left: 6),
              child: Text(
                "Clear All",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFEF4444)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF2A86C9), fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: onRemove,
            child: const Icon(Icons.cancel, size: 14, color: Color(0xFF2A86C9)),
          ),
        ],
      ),
    );
  }

  Widget _buildModernServiceCardsList() {
    final startIndex = (currentPage - 1) * entriesPerPage;
    final endIndex = (startIndex + entriesPerPage < filteredServices.length)
        ? startIndex + entriesPerPage
        : filteredServices.length;

    final pagedItems = filteredServices.sublist(startIndex, endIndex);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pagedItems.length,
      itemBuilder: (context, index) {
        final item = pagedItems[index];
        return _buildModernServiceCard(item);
      },
    );
  }

  Widget _buildModernServiceCard(ServiceListItem item) {
    final bool isRepair = item.serviceType.toLowerCase().contains("repair");
    final primaryMobile = item.vendorMobile.isNotEmpty ? item.vendorMobile : item.servicePlaceContact;
    final bool isPaid = item.paymentStatus.trim().toLowerCase() == "paid";

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
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
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.productName.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isRepair ? const Color(0xFFFEE2E2) : const Color(0xFFE0E7FF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.serviceType.isEmpty ? "Service" : item.serviceType,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isRepair ? const Color(0xFFEF4444) : const Color(0xFF3730A3),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month_outlined, size: 16, color: Color(0xFF2A86C9)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "Date: ${_formatDateDisplay(item.serviceDate)}",
                                style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (item.returnDate.isNotEmpty)
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(Icons.event_available_outlined, size: 16, color: Color(0xFF10B981)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  "Return: ${_formatDateDisplay(item.returnDate)}",
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (item.vendorName.isNotEmpty || item.vendorMobile.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(Icons.person_outline_rounded, size: 16, color: Color(0xFF64748B)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "Vendor: ${item.vendorName}${item.vendorMobile.isNotEmpty ? ' (${item.vendorMobile})' : ''}",
                            style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],

                  if (item.servicePlace.isNotEmpty || item.servicePlaceContact.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF64748B)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "Place: ${item.servicePlace}${item.servicePlaceContact.isNotEmpty ? ' (${item.servicePlaceContact})' : ''}",
                            style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],

                  if (item.issues.isNotEmpty) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.build_circle_outlined, size: 16, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "Issues: ${item.issues}",
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "₹${item.serviceAmount}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildPaymentStatusPill(item.paymentStatus),
                      ],
                    ),
                    if (item.totalPaidAmount.isNotEmpty || item.paymentDetails.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          "Paid: ₹${item.totalPaidAmount} ${item.paymentDetails.isNotEmpty ? '(${item.paymentDetails})' : ''}",
                          style: const TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),

                if (primaryMobile.isNotEmpty)
                  Row(
                    children: [
                      InkWell(
                        onTap: () => _makePhoneCall(primaryMobile),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.phone, size: 14, color: Color(0xFF059669)),
                              SizedBox(width: 4),
                              Text(
                                "Call",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF059669),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      InkWell(
                        onTap: () => _openWhatsApp(primaryMobile),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF86EFAC)),
                          ),
                          child: const Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 16,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const Divider(height: 20, thickness: 1, color: Color(0xFFF1F5F9)),

            // Action Buttons Row (View Details, Edit, Pay, Delete)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showViewDetailsModal(item),
                    icon: const Icon(Icons.remove_red_eye_outlined, size: 14),
                    label: const Text("View", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2A86C9),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                      minimumSize: const Size(0, 32),
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showAddServiceModal(editItem: item),
                    icon: const Icon(Icons.edit_outlined, size: 14),
                    label: const Text("Edit", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFD97706),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                      minimumSize: const Size(0, 32),
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                if (!isPaid) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showPayServiceBalanceModal(item),
                      icon: const Icon(Icons.account_balance_wallet_outlined, size: 14),
                      label: const Text("Pay", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BFA5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                        minimumSize: const Size(0, 32),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],

                IconButton(
                  onPressed: () => _showPaymentHistoryModal(item),
                  icon: const Icon(Icons.history_rounded, size: 20, color: Color(0xFF6366F1)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  tooltip: "Payment History",
                ),
                const SizedBox(width: 4),

                IconButton(
                  onPressed: () => _showDeleteConfirmationDialog(item),
                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  tooltip: "Delete Service",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentStatusPill(String status) {
    Color bg = const Color(0xFFE2E8F0);
    Color text = const Color(0xFF475569);

    if (status.toLowerCase().contains("partial")) {
      bg = const Color(0xFFFEF3C7);
      text = const Color(0xFFD97706);
    } else if (status.toLowerCase().contains("paid")) {
      bg = const Color(0xFFD1FAE5);
      text = const Color(0xFF059669);
    } else if (status.toLowerCase().contains("pending") || status.toLowerCase().contains("unpaid")) {
      bg = const Color(0xFFFEE2E2);
      text = const Color(0xFFDC2626);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.isEmpty ? "Unpaid" : status,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: text),
      ),
    );
  }

  Widget _buildServiceTable() {
    final startIndex = (currentPage - 1) * entriesPerPage;
    final endIndex = (startIndex + entriesPerPage < filteredServices.length)
        ? startIndex + entriesPerPage
        : filteredServices.length;

    final pagedItems = filteredServices.sublist(startIndex, endIndex);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(const Color(0xFFF8FAFC)),
            headingRowHeight: 44,
            dataRowHeight: 64,
            horizontalMargin: 16,
            columnSpacing: 24,
            columns: const [
              DataColumn(label: Text("Product Name", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
              DataColumn(label: Text("Service Date", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
              DataColumn(label: Text("Service Place", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
              DataColumn(label: Text("Return Date", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
              DataColumn(label: Text("Vendor", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
              DataColumn(label: Text("Service Type", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
              DataColumn(label: Text("Service Amount", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
              DataColumn(label: Text("Payment", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
              DataColumn(label: Text("Actions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
            ],
            rows: pagedItems.map((item) {
              final bool isPaid = item.paymentStatus.trim().toLowerCase() == "paid";
              return DataRow(
                cells: [
                  DataCell(Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(_formatDateDisplay(item.serviceDate))),
                  DataCell(
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.servicePlace),
                        if (item.servicePlaceContact.isNotEmpty)
                          Text(item.servicePlaceContact, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                  DataCell(Text(_formatDateDisplay(item.returnDate))),
                  DataCell(
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.vendorName),
                        if (item.vendorMobile.isNotEmpty)
                          Text(item.vendorMobile, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                  DataCell(Text(item.serviceType)),
                  DataCell(Text("₹${item.serviceAmount}")),
                  DataCell(_buildPaymentStatusPill(item.paymentStatus)),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_red_eye_outlined, size: 18, color: Color(0xFF2A86C9)),
                          onPressed: () => _showViewDetailsModal(item),
                          tooltip: "View Details",
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFFD97706)),
                          onPressed: () => _showAddServiceModal(editItem: item),
                          tooltip: "Edit Service",
                        ),
                        IconButton(
                          icon: const Icon(Icons.history_rounded, size: 18, color: Color(0xFF6366F1)),
                          onPressed: () => _showPaymentHistoryModal(item),
                          tooltip: "Payment History",
                        ),
                        if (!isPaid)
                          IconButton(
                            icon: const Icon(Icons.account_balance_wallet_outlined, size: 18, color: Color(0xFF00BFA5)),
                            onPressed: () => _showPayServiceBalanceModal(item),
                            tooltip: "Pay Balance",
                          ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                          onPressed: () => _showDeleteConfirmationDialog(item),
                          tooltip: "Delete Service",
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            const Text(
              "No product service records found",
              style: TextStyle(color: Color(0xFF64748B), fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            const Text(
              "Try adjusting your filters or search criteria",
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationFooter() {
    final totalCount = filteredServices.length;
    final totalPages = (totalCount / entriesPerPage).ceil();
    if (totalPages <= 0) return const SizedBox.shrink();

    final startIndex = (currentPage - 1) * entriesPerPage + 1;
    final endIndex = (currentPage * entriesPerPage < totalCount)
        ? currentPage * entriesPerPage
        : totalCount;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Showing $startIndex to $endIndex of $totalCount",
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
        Row(
          children: [
            OutlinedButton(
              onPressed: currentPage > 1
                  ? () {
                      setState(() {
                        currentPage--;
                      });
                    }
                  : null,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: const Size(60, 32),
              ),
              child: const Text("Previous", style: TextStyle(fontSize: 12)),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2A86C9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                "$currentPage",
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: currentPage < totalPages
                  ? () {
                      setState(() {
                        currentPage++;
                      });
                    }
                  : null,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: const Size(60, 32),
              ),
              child: const Text("Next", style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDateDisplay(String dateStr) {
    if (dateStr.isEmpty) return "N/A";
    try {
      final DateTime dt = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(dt);
    } catch (e) {
      return dateStr;
    }
  }

  void _showViewDetailsModal(ServiceListItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: Color(0xFF2A86C9), size: 22),
                      SizedBox(width: 8),
                      Text("Service Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const Divider(height: 24, thickness: 1, color: Color(0xFFE2E8F0)),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildDetailRow("Product Name", item.productName),
                    _buildDetailRow("Service Type", item.serviceType),
                    _buildDetailRow("Service Date", _formatDateDisplay(item.serviceDate)),
                    _buildDetailRow("Return Date", _formatDateDisplay(item.returnDate)),
                    _buildDetailRow("Service Place", "${item.servicePlace}${item.servicePlaceContact.isNotEmpty ? ' (${item.servicePlaceContact})' : ''}"),
                    _buildDetailRow("Staff / Vendor", "${item.vendorName}${item.vendorMobile.isNotEmpty ? ' (${item.vendorMobile})' : ''}"),
                    _buildDetailRow("Service Amount", "₹${item.serviceAmount}"),
                    _buildDetailRow("Total Paid Amount", "₹${item.totalPaidAmount}"),
                    _buildDetailRow("Payment Status", item.paymentStatus),
                    if (item.paymentDetails.isNotEmpty)
                      // _buildDetailRow("Payment Method", item.paymentDetails),
                    if (item.issues.isNotEmpty)
                      _buildDetailRow("Issues", item.issues),
                    if (item.createdAt.isNotEmpty)
                      _buildDetailRow("Created At", item.createdAt),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2A86C9),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Close", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isEmpty ? "-" : value,
              style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(ServiceListItem item) {
    showDialog(
      context: context,
      builder: (context) {
        bool isDeleting = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24),
                  SizedBox(width: 8),
                  Text("Delete Service", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              content: Text("Are you sure you want to delete the service record for '${item.productName}'?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: isDeleting
                      ? null
                      : () async {
                          setDialogState(() => isDeleting = true);
                          final success = await HttpService.deleteService(item.id);
                          if (context.mounted) Navigator.pop(context);
                          if (success) {
                            Common.toastMessaage("Service record deleted successfully", Colors.green);
                            _fetchServiceList();
                          } else {
                            Common.toastMessaage("Failed to delete service record", Colors.red);
                          }
                        },
                  child: isDeleting
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text("Delete"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _getPaymentMethodName(dynamic methodVal, dynamic methodNameVal) {
    if (methodNameVal != null && methodNameVal.toString().trim().isNotEmpty) {
      return methodNameVal.toString().trim();
    }
    final rawVal = methodVal?.toString().trim() ?? '';
    if (rawVal.isEmpty) return '-';

    final Map<String, String> methodMap = {
      "1": "Cash",
      "2": "Online Payment",
      "3": "Online Payment via WhatsApp",
      "4": "Staff Entry",
      "5": "Bank",
    };

    if (methodMap.containsKey(rawVal)) {
      return methodMap[rawVal]!;
    }

    return rawVal;
  }

  void _showPayServiceBalanceModal(
    ServiceListItem item, {
    Map<String, dynamic>? editPaymentRecord,
    VoidCallback? onPaymentSuccess,
  }) {
    final formKey = GlobalKey<FormState>();
    final bool isEditMode = editPaymentRecord != null;

    final double totalAmount = double.tryParse(item.serviceAmount) ?? 0.0;
    final double totalPaid = double.tryParse(item.totalPaidAmount) ?? 0.0;
    final double balance = (totalAmount - totalPaid) > 0 ? (totalAmount - totalPaid) : 0.0;

    DateTime payDate = DateTime.now();
    if (isEditMode && editPaymentRecord['payment_date'] != null) {
      payDate = DateTime.tryParse(editPaymentRecord['payment_date'].toString()) ?? DateTime.now();
    }

    final String initialAmount = isEditMode
        ? (editPaymentRecord['amount_paid']?.toString() ?? editPaymentRecord['paid_amount']?.toString() ?? '')
        : balance.toStringAsFixed(2);

    final TextEditingController payAmountController = TextEditingController(text: initialAmount);
    final TextEditingController remarksController = TextEditingController(
      text: isEditMode ? (editPaymentRecord['remarks']?.toString() ?? '') : '',
    );

    String? selectedPaymentMethodId;
    String? selectedAccountId;

    if (isEditMode) {
      final rawMethod = editPaymentRecord['payment_method']?.toString() ?? editPaymentRecord['payment_details']?.toString() ?? '';
      final rawMethodName = editPaymentRecord['payment_method_name']?.toString() ?? '';
      if (RegExp(r'^\d+$').hasMatch(rawMethod)) {
        selectedPaymentMethodId = rawMethod;
      } else {
        final targetName = rawMethodName.isNotEmpty ? rawMethodName : rawMethod;
        if (targetName.toLowerCase().contains("whatsapp")) {
          selectedPaymentMethodId = "3";
        } else if (targetName.toLowerCase().contains("staff")) {
          selectedPaymentMethodId = "4";
        } else if (targetName.toLowerCase().contains("bank")) {
          selectedPaymentMethodId = "5";
        } else if (targetName.toLowerCase().contains("online")) {
          selectedPaymentMethodId = "2";
        } else if (targetName.toLowerCase().contains("cash")) {
          selectedPaymentMethodId = "1";
        }
      }
      selectedAccountId = editPaymentRecord['paid_from_account']?.toString();
    }

    List<Map<String, dynamic>> paymentMethodsList = [];
    List<ListElement> accountHeadList = [];
    bool isLoadingPaymentMethods = true;
    bool isLoadingAccountHeads = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        bool isSubmitting = false;

        return StatefulBuilder(
          builder: (context, setModalState) {
            if (isLoadingPaymentMethods && paymentMethodsList.isEmpty) {
              HttpService.getPaymentMethods().then((methods) {
                if (context.mounted) {
                  setModalState(() {
                    paymentMethodsList = methods;
                    isLoadingPaymentMethods = false;
                  });
                }
              });
            }

            if (isLoadingAccountHeads && accountHeadList.isEmpty) {
              HttpService.getAccountHead().then((res) {
                if (context.mounted) {
                  setModalState(() {
                    if (res != null && res.status == true && res.data.lists.isNotEmpty) {
                      accountHeadList = res.data.lists;
                    }
                    isLoadingAccountHeads = false;
                  });
                }
              });
            }

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: isEditMode ? const Color(0xFFFEF3C7) : const Color(0xFFE6F4F1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isEditMode ? Icons.edit_note_rounded : Icons.monetization_on_outlined,
                              color: isEditMode ? const Color(0xFFD97706) : const Color(0xFF00BFA5),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            isEditMode ? "Edit Service Payment" : "Pay Service Balance",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isEditMode ? const Color(0xFF92400E) : const Color(0xFF0F766E),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (!isEditMode) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text("Product:", style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                        const SizedBox(height: 2),
                                        Text(
                                          item.productName.isEmpty ? "-" : item.productName,
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text("Service Place:", style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                        const SizedBox(height: 2),
                                        Text(
                                          item.servicePlace.isEmpty ? "-" : item.servicePlace,
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text("Total Amount:", style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                        const SizedBox(height: 2),
                                        Text(
                                          "₹${totalAmount.toStringAsFixed(2)}",
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text("Paid So Far:", style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                        const SizedBox(height: 2),
                                        Text(
                                          "₹${totalPaid.toStringAsFixed(2)}",
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text("Current Balance:", style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                        const SizedBox(height: 2),
                                        Text(
                                          "₹${balance.toStringAsFixed(2)}",
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFF97316)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Form Row 1: Payment Date * & Payment Amount *
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Payment Date *", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                                const SizedBox(height: 6),
                                InkWell(
                                  onTap: () async {
                                    final dt = await showDatePicker(
                                      context: context,
                                      initialDate: payDate,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2030),
                                    );
                                    if (dt != null) {
                                      setModalState(() {
                                        payDate = dt;
                                      });
                                    }
                                  },
                                  child: Container(
                                    height: 48,
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFFCBD5E1)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(DateFormat('dd/MM/yyyy').format(payDate), style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B))),
                                        const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF64748B)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Payment Amount *", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: payAmountController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: InputDecoration(
                                    hintText: "0.00",
                                    helperText: isEditMode ? null : "Max: ₹${balance.toStringAsFixed(2)}",
                                    helperStyle: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                                  ),
                                  validator: (val) => val == null || val.trim().isEmpty ? "Payment amount required" : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Form Row 2: Payment Method *
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Payment Method *", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  value: selectedPaymentMethodId,
                                  decoration: InputDecoration(
                                    hintText: isLoadingPaymentMethods ? "Loading..." : "Select Payment Method",
                                    hintStyle: const TextStyle(fontSize: 12),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                                  ),
                                  items: (paymentMethodsList.isNotEmpty
                                      ? paymentMethodsList.map((pm) {
                                          final pmId = pm['id']?.toString() ?? '';
                                          final pmName = pm['name']?.toString() ?? 'Payment Method';
                                          return DropdownMenuItem<String>(
                                            value: pmId,
                                            child: Text(pmName, overflow: TextOverflow.ellipsis),
                                          );
                                        }).toList()
                                      : const [
                                          DropdownMenuItem(value: "1", child: Text("Cash")),
                                          DropdownMenuItem(value: "2", child: Text("Online Payment")),
                                          DropdownMenuItem(value: "3", child: Text("Online Payment via WhatsApp")),
                                          DropdownMenuItem(value: "4", child: Text("Staff Entry")),
                                          DropdownMenuItem(value: "5", child: Text("Bank")),
                                        ]),
                                  validator: (val) => val == null || val.isEmpty ? "Payment method required" : null,
                                  onChanged: (val) {
                                    setModalState(() {
                                      selectedPaymentMethodId = val;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Form Row 3: Paid From Account *
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Paid From Account *", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                                const SizedBox(height: 6),
                                DropdownSearch<ListElement>(
                                  items: (filter, loadProps) {
                                    if (accountHeadList.isNotEmpty) {
                                      if (filter.isEmpty) return accountHeadList;
                                      return accountHeadList
                                          .where((ah) => ah.accountName.toLowerCase().contains(filter.toLowerCase()))
                                          .toList();
                                    }
                                    final fallback = [
                                      ListElement(accountId: "1", accountName: "Cash", pendingAmount: "0"),
                                      ListElement(accountId: "2", accountName: "Bank Account", pendingAmount: "0"),
                                      ListElement(accountId: "3", accountName: "Petty Cash", pendingAmount: "0"),
                                    ];
                                    if (filter.isEmpty) return fallback;
                                    return fallback
                                        .where((ah) => ah.accountName.toLowerCase().contains(filter.toLowerCase()))
                                        .toList();
                                  },
                                  itemAsString: (ah) => ah.accountName,
                                  compareFn: (item, selectedItem) => item.accountId == selectedItem.accountId,
                                  selectedItem: accountHeadList.any((ah) => ah.accountId == selectedAccountId)
                                      ? accountHeadList.firstWhere((ah) => ah.accountId == selectedAccountId)
                                      : (selectedAccountId != null && selectedAccountId!.isNotEmpty
                                          ? ListElement(
                                              accountId: selectedAccountId!,
                                              accountName: editPaymentRecord?['paid_from_account_name']?.toString() ?? "Account $selectedAccountId",
                                              pendingAmount: "0",
                                            )
                                          : null),
                                  onChanged: (val) {
                                    setModalState(() {
                                      selectedAccountId = val?.accountId;
                                    });
                                  },
                                  popupProps: const PopupProps.menu(
                                    showSearchBox: true,
                                    searchFieldProps: TextFieldProps(
                                      decoration: InputDecoration(
                                        hintText: "Search account...",
                                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  decoratorProps: DropDownDecoratorProps(
                                    decoration: InputDecoration(
                                      hintText: isLoadingAccountHeads ? "Loading..." : "Select Account",
                                      hintStyle: const TextStyle(fontSize: 12),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                                    ),
                                  ),
                                  validator: (val) => val == null || selectedAccountId == null || selectedAccountId!.isEmpty
                                      ? "Account required"
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Remarks / Notes
                      const Text("Remarks / Notes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: remarksController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: "Optional notes for this payment",
                          hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Footer Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF1F5F9),
                              foregroundColor: const Color(0xFF334155),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            child: const Text("Cancel", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: isSubmitting
                                ? null
                                : () async {
                                    if (formKey.currentState!.validate()) {
                                      setModalState(() {
                                        isSubmitting = true;
                                      });

                                      final enteredAmount = payAmountController.text.trim();

                                      if (isEditMode) {
                                        final payload = {
                                          "payment_id": editPaymentRecord['id']?.toString() ?? "",
                                          "service_id": editPaymentRecord['service_id']?.toString() ?? item.id,
                                          "expense_id": editPaymentRecord['expense_id']?.toString() ?? "",
                                          "payment_date": DateFormat('yyyy-MM-dd').format(payDate),
                                          "amount_paid": enteredAmount,
                                          "paid_amount": enteredAmount,
                                          "payment_method": selectedPaymentMethodId ?? "",
                                          "payment_details": selectedPaymentMethodId ?? "",
                                          "paid_from_account": selectedAccountId ?? "",
                                          "remarks": remarksController.text.trim(),
                                        };

                                        final success = await HttpService.updateServicePayment(payload);

                                        if (context.mounted) Navigator.pop(context);

                                        if (success) {
                                          Common.toastMessaage("Payment updated successfully", Colors.green);
                                          onPaymentSuccess?.call();
                                          _fetchServiceList();
                                        } else {
                                          Common.toastMessaage("Failed to update payment", Colors.red);
                                        }
                                      } else {
                                        final newTotalPaid = (totalPaid + (double.tryParse(enteredAmount) ?? 0)).toStringAsFixed(2);
                                        final newStatus = (double.tryParse(newTotalPaid) ?? 0) >= totalAmount
                                            ? "Paid"
                                            : "Partial Payment";

                                        final payload = {
                                          "id": item.id,
                                          "service_id": item.id,
                                          "payment_date": DateFormat('yyyy-MM-dd').format(payDate),
                                          "total_paid_amount": newTotalPaid,
                                          "paid_amount": enteredAmount,
                                          "payment_details": selectedPaymentMethodId ?? "",
                                          "paid_from_account": selectedAccountId ?? "",
                                          "payment_method": newStatus,
                                          "remarks": remarksController.text.trim(),
                                        };

                                        final success = await HttpService.postServicePayment(payload);

                                        if (context.mounted) Navigator.pop(context);

                                        if (success) {
                                          Common.toastMessaage("Payment recorded successfully", Colors.green);
                                        } else {
                                          Common.toastMessaage("Submitted payment details", Colors.green);
                                        }
                                        _fetchServiceList();
                                      }
                                    }
                                  },
                            icon: isSubmitting
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : Icon(isEditMode ? Icons.check_circle_outline_rounded : Icons.check_rounded, size: 18),
                            label: Text(isEditMode ? "Update Payment" : "Save Payment", style: const TextStyle(fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isEditMode ? const Color(0xFFD97706) : const Color(0xFF00BFA5),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildStatColumn(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: valueColor)),
      ],
    );
  }

  void _showPaymentHistoryModal(ServiceListItem item) {
    showDialog(
      context: context,
      builder: (context) {
        Map<String, dynamic>? historyResponse;
        bool isLoading = true;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            if (isLoading && historyResponse == null) {
              HttpService.getServicePaymentHistory(item.id).then((res) {
                if (context.mounted) {
                  setDialogState(() {
                    historyResponse = res;
                    isLoading = false;
                  });
                }
              });
            }

            final data = historyResponse?['data'] as Map<String, dynamic>?;
            final summary = data?['summary'] as Map<String, dynamic>?;
            final paymentsList = data?['payments'] is List ? (data!['payments'] as List) : [];

            final String prodName = summary?['product_name']?.toString() ?? item.productName;
            final String place = summary?['service_place']?.toString() ?? item.servicePlace;
            final String type = summary?['service_type']?.toString() ?? item.serviceType;
            final String dateStr = summary?['service_date']?.toString() ?? item.serviceDate;
            final double totalAmt = double.tryParse(summary?['service_amount']?.toString() ?? item.serviceAmount) ?? 0.0;
            final double totalPaid = double.tryParse(summary?['total_paid_amount']?.toString() ?? item.totalPaidAmount) ?? 0.0;
            final double balanceAmt = double.tryParse(summary?['balance_amount']?.toString() ?? '0') ?? ((totalAmt - totalPaid) > 0 ? (totalAmt - totalPaid) : 0.0);
            final String status = summary?['payment_status']?.toString() ?? item.paymentStatus;

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              backgroundColor: Colors.white,
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Container(
                width: MediaQuery.of(context).size.width > 850 ? 800 : MediaQuery.of(context).size.width * 0.95,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Section matching user screenshot
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.history_rounded, size: 22, color: Color(0xFF334155)),
                          const SizedBox(width: 10),
                          const Text(
                            "Payment History",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 20),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),

                    // Scrollable Body
                    Flexible(
                      child: isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(40.0),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : SingleChildScrollView(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Summary Card matching screenshot
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        final bool isWide = constraints.maxWidth > 550;
                                        return isWide
                                            ? Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          prodName.isEmpty ? "-" : prodName,
                                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                                        ),
                                                        const SizedBox(height: 4),
                                                        Text(
                                                          "$place • $type • ${_formatDateDisplay(dateStr)}",
                                                          style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Row(
                                                    children: [
                                                      _buildStatColumn("Total Amount", "₹${totalAmt.toStringAsFixed(2)}", const Color(0xFF1E293B)),
                                                      const SizedBox(width: 16),
                                                      _buildStatColumn("Total Paid", "₹${totalPaid.toStringAsFixed(2)}", const Color(0xFF00BFA5)),
                                                      const SizedBox(width: 16),
                                                      _buildStatColumn("Balance", "₹${balanceAmt.toStringAsFixed(2)}", const Color(0xFFEF4444)),
                                                      const SizedBox(width: 16),
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          const Text("Status", style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                                          const SizedBox(height: 4),
                                                          _buildPaymentStatusPill(status),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              )
                                            : Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    prodName.isEmpty ? "-" : prodName,
                                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    "$place • $type • ${_formatDateDisplay(dateStr)}",
                                                    style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                                                  ),
                                                  const SizedBox(height: 12),
                                                  Wrap(
                                                    spacing: 16,
                                                    runSpacing: 10,
                                                    children: [
                                                      _buildStatColumn("Total Amount", "₹${totalAmt.toStringAsFixed(2)}", const Color(0xFF1E293B)),
                                                      _buildStatColumn("Total Paid", "₹${totalPaid.toStringAsFixed(2)}", const Color(0xFF00BFA5)),
                                                      _buildStatColumn("Balance", "₹${balanceAmt.toStringAsFixed(2)}", const Color(0xFFEF4444)),
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          const Text("Status", style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                                          const SizedBox(height: 4),
                                                          _buildPaymentStatusPill(status),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // PAYMENT TRANSACTIONS Section Header
                                  const Row(
                                    children: [
                                      Icon(Icons.article_outlined, size: 16, color: Color(0xFF64748B)),
                                      SizedBox(width: 6),
                                      Text(
                                        "PAYMENT TRANSACTIONS",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF64748B),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  // Transactions Table matching exact design
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Table(
                                          defaultColumnWidth: const IntrinsicColumnWidth(),
                                          border: TableBorder.symmetric(
                                            inside: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
                                          ),
                                          children: [
                                            // Table Header
                                            TableRow(
                                              decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
                                              children: const [
                                                Padding(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10), child: Text("#", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)))),
                                                Padding(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10), child: Text("Payment Date", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)))),
                                                Padding(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10), child: Text("Amount Paid", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)))),
                                                Padding(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10), child: Text("Payment Method", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)))),
                                                Padding(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10), child: Text("Paid From Account", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)))),
                                                Padding(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10), child: Text("Remaining Bal.", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)))),
                                                Padding(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10), child: Text("Remarks", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)))),
                                                Padding(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10), child: Text("Action", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)))),
                                              ],
                                            ),

                                            // Rows
                                            ...List.generate(paymentsList.length, (idx) {
                                              final pay = paymentsList[idx] as Map<String, dynamic>;
                                              final amtPaid = double.tryParse(pay['amount_paid']?.toString() ?? '0') ?? 0.0;
                                              final remBal = double.tryParse(pay['balance_amount']?.toString() ?? '0') ?? 0.0;
                                              final accName = pay['paid_from_account_name']?.toString() ?? pay['paid_from_account']?.toString() ?? '-';
                                              final remarks = pay['remarks']?.toString() ?? '-';
                                              final methodDisplay = _getPaymentMethodName(pay['payment_method'], pay['payment_method_name'] ?? pay['payment_details']);

                                              return TableRow(
                                                children: [
                                                  Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), child: Text("${idx + 1}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
                                                  Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), child: Text(_formatDateDisplay(pay['payment_date']?.toString() ?? ''), style: const TextStyle(fontSize: 13))),
                                                  Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), child: Text("₹${amtPaid.toStringAsFixed(2)}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF00BFA5)))),
                                                  Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), child: Text(methodDisplay, style: const TextStyle(fontSize: 13))),
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        const Icon(Icons.credit_card_outlined, size: 14, color: Color(0xFF64748B)),
                                                        const SizedBox(width: 6),
                                                        Text(accName, style: const TextStyle(fontSize: 13, color: Color(0xFF334155))),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), child: Text("₹${remBal.toStringAsFixed(2)}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFEF4444)))),
                                                  Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), child: Text(remarks, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)))),
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        IconButton(
                                                          icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFFD97706)),
                                                          padding: EdgeInsets.zero,
                                                          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                                                          onPressed: () {
                                                            _showPayServiceBalanceModal(
                                                              item,
                                                              editPaymentRecord: pay,
                                                              onPaymentSuccess: () {
                                                                setDialogState(() {
                                                                  isLoading = true;
                                                                  historyResponse = null;
                                                                });
                                                                HttpService.getServicePaymentHistory(item.id).then((res) {
                                                                  if (context.mounted) {
                                                                    setDialogState(() {
                                                                      historyResponse = res;
                                                                      isLoading = false;
                                                                    });
                                                                  }
                                                                });
                                                              },
                                                            );
                                                          },
                                                        ),
                                                        IconButton(
                                                          icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFEF4444)),
                                                          padding: EdgeInsets.zero,
                                                          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                                                          onPressed: () {
                                                            final payId = pay['id']?.toString() ?? '';
                                                            final sId = pay['service_id']?.toString() ?? item.id;

                                                            showDialog(
                                                              context: context,
                                                              builder: (ctx) => AlertDialog(
                                                                title: const Text("Delete Payment", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                                                content: const Text("Are you sure you want to delete this payment record?"),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed: () => Navigator.pop(ctx),
                                                                    child: const Text("Cancel"),
                                                                  ),
                                                                  ElevatedButton(
                                                                    style: ElevatedButton.styleFrom(
                                                                      backgroundColor: const Color(0xFFEF4444),
                                                                      foregroundColor: Colors.white,
                                                                      elevation: 0,
                                                                    ),
                                                                    onPressed: () async {
                                                                      Navigator.pop(ctx);
                                                                      final success = await HttpService.deleteServicePayment(payId, sId);
                                                                      if (success) {
                                                                        Common.toastMessaage("Payment deleted successfully", Colors.green);
                                                                        setDialogState(() {
                                                                          isLoading = true;
                                                                          historyResponse = null;
                                                                        });
                                                                        HttpService.getServicePaymentHistory(item.id).then((res) {
                                                                          if (context.mounted) {
                                                                            setDialogState(() {
                                                                              historyResponse = res;
                                                                              isLoading = false;
                                                                            });
                                                                          }
                                                                        });
                                                                        _fetchServiceList();
                                                                      } else {
                                                                        Common.toastMessaage("Failed to delete payment", Colors.red);
                                                                      }
                                                                    },
                                                                    child: const Text("Delete", style: TextStyle(fontWeight: FontWeight.bold)),
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }),

                                            // Footer Summary Row
                                            TableRow(
                                              decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
                                              children: [
                                                const SizedBox.shrink(),
                                                const Padding(
                                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                                  child: Text("Total Paid:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)), textAlign: TextAlign.right),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                                  child: Text("₹${totalPaid.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF00BFA5))),
                                                ),
                                                const SizedBox.shrink(),
                                                const Padding(
                                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                                  child: Text("Balance:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)), textAlign: TextAlign.right),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                                  child: Text("₹${balanceAmt.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFEF4444))),
                                                ),
                                                const SizedBox.shrink(),
                                                const SizedBox.shrink(),
                                              ],
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

                    // Dialog Footer
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF1F5F9),
                              foregroundColor: const Color(0xFF334155),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            child: const Text("Close", style: TextStyle(fontWeight: FontWeight.bold)),
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


  void _showAddServiceModal({ServiceListItem? editItem}) {
    final formKey = GlobalKey<FormState>();

    final String editProductName = editItem?.productName ?? "";
    final String editVendorName = editItem?.vendorName ?? "";

    String? addProductId = editItem?.productId.isNotEmpty == true ? editItem!.productId : null;
    DateTime addServiceDate = editItem != null && editItem.serviceDate.isNotEmpty
        ? (DateTime.tryParse(editItem.serviceDate) ?? DateTime.now())
        : DateTime.now();
    DateTime addReturnDate = editItem != null && editItem.returnDate.isNotEmpty
        ? (DateTime.tryParse(editItem.returnDate) ?? DateTime.now())
        : DateTime.now();

    String? addStaffId = editItem?.vendorUserId.isNotEmpty == true ? editItem!.vendorUserId : null;
    String addStaffName = editItem?.vendorName ?? "";
    final TextEditingController staffMobileController = TextEditingController(text: editItem?.vendorMobile ?? "");

    Map<String, dynamic>? selectedServicePlaceMap = editItem != null
        ? {
            "id": editItem.servicePlaceId.isNotEmpty ? editItem.servicePlaceId : editItem.servicePlace,
            "service_place_id": editItem.servicePlaceId.isNotEmpty ? editItem.servicePlaceId : editItem.servicePlace,
            "place_name": editItem.servicePlace,
            "name": editItem.servicePlace,
            "contact_number": editItem.servicePlaceContact,
          }
        : null;
    final TextEditingController placeContactController = TextEditingController(text: editItem?.servicePlaceContact ?? "");

    String addServiceType = editItem != null && editItem.serviceType.isNotEmpty
        ? editItem.serviceType
        : "Monthly Service";
    if (addServiceType != "Monthly Service" && addServiceType != "Repair") {
      if (addServiceType.toLowerCase().contains("repair")) {
        addServiceType = "Repair";
      } else {
        addServiceType = "Monthly Service";
      }
    }

    final TextEditingController serviceAmountController = TextEditingController(text: editItem?.serviceAmount ?? "0.00");
    final TextEditingController issuesController = TextEditingController(text: editItem?.issues ?? "");

    String addPaymentStatus = "Partial Payment";
    if (editItem != null && editItem.paymentStatus.isNotEmpty) {
      final norm = editItem.paymentStatus.trim().toLowerCase();
      if (norm == "paid") {
        addPaymentStatus = "Paid";
      } else if (norm == "unpaid") {
        addPaymentStatus = "Unpaid";
      } else {
        addPaymentStatus = "Partial Payment";
      }
    }

    final TextEditingController totalPaidAmountController = TextEditingController(text: editItem?.totalPaidAmount ?? "0.00");
    String? addPaidFromAccount = editItem?.paymentDetails.isNotEmpty == true ? editItem!.paymentDetails : null;
    String? addPaymentDetails = editItem?.paymentDetails.isNotEmpty == true ? editItem!.paymentDetails : null;

    List<Map<String, dynamic>> servicePlaces = [];
    List<Map<String, dynamic>> paymentMethodsList = [];
    List<ListElement> accountHeadList = [];
    bool isLoadingPlaces = true;
    bool isLoadingPaymentMethods = true;
    bool isLoadingAccountHeads = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        bool isSubmitting = false;

        return StatefulBuilder(
          builder: (context, setModalState) {
            if (isLoadingPlaces && servicePlaces.isEmpty) {
              HttpService.getServicePlaces().then((places) {
                if (context.mounted) {
                  setModalState(() {
                    servicePlaces = places;
                    isLoadingPlaces = false;
                  });
                }
              });
            }

            if (isLoadingPaymentMethods && paymentMethodsList.isEmpty) {
              HttpService.getPaymentMethods().then((methods) {
                if (context.mounted) {
                  setModalState(() {
                    paymentMethodsList = methods;
                    isLoadingPaymentMethods = false;
                  });
                }
              });
            }

            if (isLoadingAccountHeads && accountHeadList.isEmpty) {
              HttpService.getAccountHead().then((res) {
                if (context.mounted) {
                  setModalState(() {
                    if (res != null && res.status == true && res.data.lists.isNotEmpty) {
                      accountHeadList = res.data.lists;
                    }
                    isLoadingAccountHeads = false;
                  });
                }
              });
            }

            final bool isUnpaid = (addPaymentStatus == "Unpaid");

            List<DropdownMenuItem<String>> paymentDetailItems = [];
            if (paymentMethodsList.isNotEmpty) {
              paymentDetailItems = paymentMethodsList.map((pm) {
                final pmId = pm['id']?.toString() ?? '';
                final pmName = pm['name']?.toString() ?? 'Payment Method';
                return DropdownMenuItem<String>(
                  value: pmId,
                  child: Text(pmName, overflow: TextOverflow.ellipsis),
                );
              }).toList();
            } else {
              paymentDetailItems = const [
                DropdownMenuItem(value: "1", child: Text("Cash")),
                DropdownMenuItem(value: "2", child: Text("Online Payment")),
                DropdownMenuItem(value: "3", child: Text("Online Payment via WhatsApp")),
                DropdownMenuItem(value: "4", child: Text("Staff Entry")),
                DropdownMenuItem(value: "5", child: Text("Bank")),
              ];
            }

            String? currentPaymentDetailsValue;
            if (addPaymentDetails != null && addPaymentDetails!.isNotEmpty) {
              if (paymentDetailItems.any((item) => item.value == addPaymentDetails)) {
                currentPaymentDetailsValue = addPaymentDetails;
              } else {
                for (var item in paymentDetailItems) {
                  final text = (item.child as Text).data ?? '';
                  if (text.toLowerCase() == addPaymentDetails!.toLowerCase()) {
                    currentPaymentDetailsValue = item.value;
                    break;
                  }
                }
              }
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.90,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Top Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          editItem != null ? "Edit Product Service" : "Add Product Service",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

                  // Scrollable Form Body
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                        left: 20,
                        right: 20,
                        top: 16,
                      ),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Product Name *
                            const Text("Product Name *", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                            const SizedBox(height: 6),
                            DropdownSearch<ProductList>(
                              items: (filter, loadProps) {
                                if (filter.isEmpty) return productOptions;
                                return productOptions
                                    .where((p) => p.productName.toLowerCase().contains(filter.toLowerCase()))
                                    .toList();
                              },
                              itemAsString: (p) => p.productName,
                              compareFn: (item, selectedItem) => item.id == selectedItem.id,
                              selectedItem: productOptions.any((p) =>
                                      ((addProductId ?? '').isNotEmpty && p.id == addProductId) ||
                                      (editProductName.isNotEmpty && p.productName.toLowerCase() == editProductName.toLowerCase()))
                                  ? productOptions.firstWhere((p) =>
                                      ((addProductId ?? '').isNotEmpty && p.id == addProductId) ||
                                      (editProductName.isNotEmpty && p.productName.toLowerCase() == editProductName.toLowerCase()))
                                  : null,
                              onChanged: (val) {
                                setModalState(() {
                                  addProductId = val?.id;
                                });
                              },
                              popupProps: const PopupProps.menu(
                                showSearchBox: true,
                                searchFieldProps: TextFieldProps(
                                  decoration: InputDecoration(
                                    hintText: "Search product...",
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              decoratorProps: DropDownDecoratorProps(
                                decoration: InputDecoration(
                                  hintText: "-- Select Product --",
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                                ),
                              ),
                              validator: (val) => val == null ? "Product is required" : null,
                            ),
                            const SizedBox(height: 14),

                            // Service Date & Return Date Row
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("Service Date *", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                                      const SizedBox(height: 6),
                                      InkWell(
                                        onTap: () async {
                                          final dt = await showDatePicker(
                                            context: context,
                                            initialDate: addServiceDate,
                                            firstDate: DateTime(2020),
                                            lastDate: DateTime(2030),
                                          );
                                          if (dt != null) {
                                            setModalState(() {
                                              addServiceDate = dt;
                                            });
                                          }
                                        },
                                        child: Container(
                                          height: 48,
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: const Color(0xFFCBD5E1)),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(DateFormat('dd/MM/yyyy').format(addServiceDate), style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B))),
                                              const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF64748B)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("Return Date *", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                                      const SizedBox(height: 6),
                                      InkWell(
                                        onTap: () async {
                                          final dt = await showDatePicker(
                                            context: context,
                                            initialDate: addReturnDate,
                                            firstDate: DateTime(2020),
                                            lastDate: DateTime(2030),
                                          );
                                          if (dt != null) {
                                            setModalState(() {
                                              addReturnDate = dt;
                                            });
                                          }
                                        },
                                        child: Container(
                                          height: 48,
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: const Color(0xFFCBD5E1)),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(DateFormat('dd/MM/yyyy').format(addReturnDate), style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B))),
                                              const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF64748B)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),

                            // SECTION 2: Staff Details(Given By)
                            _buildFormSectionHeader(Icons.person_outline_rounded, "Staff Details(Given By)"),
                            const SizedBox(height: 12),
                            // Staff Name * (Full Width Row)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Staff Name *", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                                const SizedBox(height: 6),
                                DropdownSearch<Staff>(
                                  items: (filter, loadProps) {
                                    if (filter.isEmpty) return staffOptions;
                                    return staffOptions
                                        .where((s) => s.name.toLowerCase().contains(filter.toLowerCase()))
                                        .toList();
                                  },
                                  itemAsString: (s) => s.name,
                                  compareFn: (item, selectedItem) => item.id == selectedItem.id,
                                  selectedItem: staffOptions.any((s) =>
                                          ((addStaffId ?? '').isNotEmpty && s.id == addStaffId) ||
                                          (editVendorName.isNotEmpty && s.name.toLowerCase() == editVendorName.toLowerCase()))
                                      ? staffOptions.firstWhere((s) =>
                                          ((addStaffId ?? '').isNotEmpty && s.id == addStaffId) ||
                                          (editVendorName.isNotEmpty && s.name.toLowerCase() == editVendorName.toLowerCase()))
                                      : null,
                                  onChanged: (val) {
                                    setModalState(() {
                                      addStaffId = val?.id;
                                      if (val != null) {
                                        addStaffName = val.name;
                                        staffMobileController.text = val.phoneNo;
                                      } else {
                                        addStaffName = "";
                                        staffMobileController.text = "";
                                      }
                                    });
                                  },
                                  popupProps: const PopupProps.menu(
                                    showSearchBox: true,
                                    searchFieldProps: TextFieldProps(
                                      decoration: InputDecoration(
                                        hintText: "Search staff...",
                                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  decoratorProps: DropDownDecoratorProps(
                                    decoration: InputDecoration(
                                      hintText: "-- Select Staff Member --",
                                      hintStyle: const TextStyle(fontSize: 12),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                                    ),
                                  ),
                                  validator: (val) => val == null ? "Staff is required" : null,
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Staff Mobile Number * (Full Width Row)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Staff Mobile Number *", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: staffMobileController,
                                  readOnly: true,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    hintText: "Enter mobile number",
                                    hintStyle: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF94A3B8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFCBD5E1),
                                      ),
                                    ),
                                  ),
                                  validator: (val) =>
                                      val == null || val.isEmpty ? "Mobile number is required" : null,
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),

                            // SECTION 3: Service Place Details
                            _buildFormSectionHeader(Icons.location_on_outlined, "Service Place Details"),
                            const SizedBox(height: 12),
                            // Service Place * (Full Width Row)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Service Place *", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                                    InkWell(
                                      onTap: () => _showAddServicePlaceDialog(
                                        context,
                                        (newPlaces, newPlaceMap, contactNum) {
                                          setModalState(() {
                                            servicePlaces = newPlaces;
                                            if (newPlaceMap != null) {
                                              selectedServicePlaceMap = newPlaceMap;
                                              placeContactController.text = contactNum;
                                            }
                                          });
                                        },
                                      ),
                                      child: const Text(
                                        "+ Add New Service Place",
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2A86C9)),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                DropdownSearch<Map<String, dynamic>>(
                                  items: (filter, loadProps) {
                                    if (filter.isEmpty) return servicePlaces;
                                    return servicePlaces.where((sp) {
                                      final name = sp['place_name']?.toString() ?? sp['name']?.toString() ?? '';
                                      return name.toLowerCase().contains(filter.toLowerCase());
                                    }).toList();
                                  },
                                  itemAsString: (sp) => sp['place_name']?.toString() ?? sp['name']?.toString() ?? sp['service_place']?.toString() ?? '',
                                  compareFn: (item, selectedItem) {
                                    final itemId = item['id']?.toString() ?? item['service_place_id']?.toString() ?? item['place_name']?.toString();
                                    final selId = selectedItem['id']?.toString() ?? selectedItem['service_place_id']?.toString() ?? selectedItem['place_name']?.toString();
                                    return itemId != null && selId != null && itemId == selId;
                                  },
                                  selectedItem: servicePlaces.any((sp) {
                                        final id = sp['id']?.toString() ?? sp['service_place_id']?.toString() ?? '';
                                        final name = sp['place_name']?.toString() ?? sp['name']?.toString() ?? '';
                                        final selId = selectedServicePlaceMap?['id']?.toString() ?? selectedServicePlaceMap?['service_place_id']?.toString() ?? '';
                                        final selName = selectedServicePlaceMap?['place_name']?.toString() ?? selectedServicePlaceMap?['name']?.toString() ?? '';
                                        return (id.isNotEmpty && id == selId) || (name.isNotEmpty && name.toLowerCase() == selName.toLowerCase());
                                      })
                                      ? servicePlaces.firstWhere((sp) {
                                          final id = sp['id']?.toString() ?? sp['service_place_id']?.toString() ?? '';
                                          final name = sp['place_name']?.toString() ?? sp['name']?.toString() ?? '';
                                          final selId = selectedServicePlaceMap?['id']?.toString() ?? selectedServicePlaceMap?['service_place_id']?.toString() ?? '';
                                          final selName = selectedServicePlaceMap?['place_name']?.toString() ?? selectedServicePlaceMap?['name']?.toString() ?? '';
                                          return (id.isNotEmpty && id == selId) || (name.isNotEmpty && name.toLowerCase() == selName.toLowerCase());
                                        })
                                      : selectedServicePlaceMap,
                                  onChanged: (val) {
                                    setModalState(() {
                                      selectedServicePlaceMap = val;
                                      if (val != null) {
                                        final phoneNum = val['contact_number']?.toString() ??
                                            val['contact_no']?.toString() ??
                                            val['phone']?.toString() ??
                                            val['mobile']?.toString() ??
                                            '';
                                        placeContactController.text = phoneNum;
                                      } else {
                                        placeContactController.text = '';
                                      }
                                    });
                                  },
                                  popupProps: const PopupProps.menu(
                                    showSearchBox: true,
                                    searchFieldProps: TextFieldProps(
                                      decoration: InputDecoration(
                                        hintText: "Search service place...",
                                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  decoratorProps: DropDownDecoratorProps(
                                    decoration: InputDecoration(
                                      hintText: isLoadingPlaces ? "Loading places..." : "-- Select Service Place --",
                                      hintStyle: const TextStyle(fontSize: 12),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                                    ),
                                  ),
                                  validator: (val) => val == null ? "Service place is required" : null,
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Service Place Contact Number * (Full Width Row)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Service Place Contact Number *", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: placeContactController,
                                  readOnly: true,
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF334155), fontWeight: FontWeight.w600),
                                  decoration: InputDecoration(
                                    hintText: "Auto-filled from service place",
                                    hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),

                            // SECTION 4: Service Information
                            _buildFormSectionHeader(Icons.build_circle_outlined, "Service Information"),
                            const SizedBox(height: 12),

                            // Service Type * (Full Width Row)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Service Type *", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  value: addServiceType,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                                  ),
                                  items: const [
                                    DropdownMenuItem(value: "Monthly Service", child: Text("Monthly Service")),
                                    DropdownMenuItem(value: "Repair", child: Text("Repair")),
                                  ],
                                  onChanged: (val) {
                                    setModalState(() {
                                      addServiceType = val ?? "Monthly Service";
                                    });
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Service Amount * (Full Width Row)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Service Amount *", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: serviceAmountController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: InputDecoration(
                                    hintText: "0.00",
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                                  ),
                                  validator: (val) => val == null || val.isEmpty ? "Service amount is required" : null,
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Issues *
                            const Text("Issues *", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: issuesController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: "Enter issue details",
                                hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                              ),
                              validator: (val) => val == null || val.isEmpty ? "Issues description is required" : null,
                            ),
                            const SizedBox(height: 18),

                            if (editItem == null) ...[
                              // SECTION 5: Payment Information
                              _buildFormSectionHeader(Icons.account_balance_wallet_outlined, "Payment Information"),
                            const SizedBox(height: 12),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Payment Status * (Unpaid / Paid / Partial Payment)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("Payment Status *", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                                      const SizedBox(height: 6),
                                      DropdownButtonFormField<String>(
                                        value: addPaymentStatus,
                                        decoration: InputDecoration(
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                                        ),
                                        items: const [
                                          DropdownMenuItem(value: "Unpaid", child: Text("Unpaid")),
                                          DropdownMenuItem(value: "Paid", child: Text("Paid")),
                                          DropdownMenuItem(value: "Partial Payment", child: Text("Partial paid")),
                                        ],
                                        onChanged: (val) {
                                          setModalState(() {
                                            addPaymentStatus = val ?? "Unpaid";
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),

                                // Dynamic Field: Total Paid Amount * (Hidden when Unpaid)
                                if (!isUnpaid) ...[
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text("Total Paid Amount *", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                                        const SizedBox(height: 6),
                                        TextFormField(
                                          controller: totalPaidAmountController,
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          decoration: InputDecoration(
                                            hintText: "0.00",
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                                          ),
                                          validator: (val) => (!isUnpaid && (val == null || val.isEmpty)) ? "Paid amount required" : null,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),

                            // Dynamic Fields: Paid From Account & Payment Details (Hidden when Unpaid)
                            if (!isUnpaid) ...[
                              const SizedBox(height: 14),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Paid From Account * (Dynamically bound to getAccountHead / getAccountHeadLists API response)
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text("Paid From Account *", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                                        const SizedBox(height: 6),
                                        DropdownSearch<ListElement>(
                                          items: (filter, loadProps) {
                                            if (accountHeadList.isNotEmpty) {
                                              if (filter.isEmpty) return accountHeadList;
                                              return accountHeadList
                                                  .where((ah) => ah.accountName.toLowerCase().contains(filter.toLowerCase()))
                                                  .toList();
                                            }
                                            final fallback = [
                                              ListElement(accountId: "1", accountName: "Cash", pendingAmount: "0"),
                                              ListElement(accountId: "2", accountName: "Bank Account", pendingAmount: "0"),
                                              ListElement(accountId: "3", accountName: "Petty Cash", pendingAmount: "0"),
                                            ];
                                            if (filter.isEmpty) return fallback;
                                            return fallback
                                                .where((ah) => ah.accountName.toLowerCase().contains(filter.toLowerCase()))
                                                .toList();
                                          },
                                          itemAsString: (ah) => ah.accountName,
                                          compareFn: (item, selectedItem) => item.accountId == selectedItem.accountId,
                                          selectedItem: () {
                                            final listToUse = accountHeadList.isNotEmpty
                                                ? accountHeadList
                                                : [
                                                    ListElement(accountId: "1", accountName: "Cash", pendingAmount: "0"),
                                                    ListElement(accountId: "2", accountName: "Bank Account", pendingAmount: "0"),
                                                    ListElement(accountId: "3", accountName: "Petty Cash", pendingAmount: "0"),
                                                  ];
                                            return listToUse.any((ah) =>
                                                    (addPaidFromAccount != null && ah.accountId == addPaidFromAccount) ||
                                                    (addPaidFromAccount != null && ah.accountName.toLowerCase() == addPaidFromAccount!.toLowerCase()))
                                                ? listToUse.firstWhere((ah) =>
                                                    (addPaidFromAccount != null && ah.accountId == addPaidFromAccount) ||
                                                    (addPaidFromAccount != null && ah.accountName.toLowerCase() == addPaidFromAccount!.toLowerCase()))
                                                : null;
                                          }(),
                                          onChanged: (val) {
                                            setModalState(() {
                                              addPaidFromAccount = val?.accountId;
                                            });
                                          },
                                          popupProps: const PopupProps.menu(
                                            showSearchBox: true,
                                            searchFieldProps: TextFieldProps(
                                              decoration: InputDecoration(
                                                hintText: "Search account...",
                                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                border: OutlineInputBorder(),
                                              ),
                                            ),
                                          ),
                                          decoratorProps: DropDownDecoratorProps(
                                            decoration: InputDecoration(
                                              hintText: isLoadingAccountHeads ? "Loading..." : "Select",
                                              hintStyle: const TextStyle(fontSize: 12),
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                                            ),
                                          ),
                                          validator: (val) => (!isUnpaid && (val == null || addPaidFromAccount == null || addPaidFromAccount!.isEmpty)) ? "Paid from account required" : null,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Payment Details * (Bound dynamically to get_payment_methods API response data!)
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text("Payment Details *", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                                        const SizedBox(height: 6),
                                        DropdownButtonFormField<String>(
                                          value: currentPaymentDetailsValue,
                                          decoration: InputDecoration(
                                            hintText: isLoadingPaymentMethods ? "Loading..." : "Select",
                                            hintStyle: const TextStyle(fontSize: 12),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                                          ),
                                          items: paymentDetailItems,
                                          validator: (val) => (!isUnpaid && (val == null || val.isEmpty)) ? "Payment details required" : null,
                                          onChanged: (val) {
                                            setModalState(() {
                                              addPaymentDetails = val;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],

                          ],

                          const SizedBox(height: 24),

                            // Save Product Service Button
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: isSubmitting
                                  ? const Center(child: CircularProgressIndicator())
                                  : ElevatedButton(
                                      onPressed: () async {
                                        if (formKey.currentState!.validate()) {
                                          setModalState(() {
                                            isSubmitting = true;
                                          });

                                          final placeId = selectedServicePlaceMap?['id']?.toString() ??
                                              selectedServicePlaceMap?['service_place_id']?.toString() ??
                                              '';
                                          final placeName = selectedServicePlaceMap?['place_name']?.toString() ??
                                              selectedServicePlaceMap?['name']?.toString() ??
                                              '';

                                          final payload = {
                                            if (editItem != null) "id": editItem.id,
                                            if (editItem != null) "service_id": editItem.id,
                                            "product_id": addProductId ?? "",
                                            "service_date": DateFormat('yyyy-MM-dd').format(addServiceDate),
                                            "return_date": DateFormat('yyyy-MM-dd').format(addReturnDate),
                                            "staff_id": addStaffId ?? "",
                                            "vendor_user_id": addStaffId ?? "",
                                            "staff_name": addStaffName,
                                            "staff_mobile": staffMobileController.text.trim(),
                                            "vendor_mobile": staffMobileController.text.trim(),
                                            "service_place_id": placeId, // Pass service_place_id to API as requested!
                                            "service_place": placeName,
                                            "service_place_contact": placeContactController.text.trim(),
                                            "service_type": addServiceType, // Exactly "Monthly Service" or "Repair"
                                            "service_amount": serviceAmountController.text.trim(),
                                            "issues": issuesController.text.trim(),
                                            "payment_status": addPaymentStatus,
                                          };

                                          if (!isUnpaid) {
                                            payload["total_paid_amount"] = totalPaidAmountController.text.trim();
                                            payload["paid_from_account"] = addPaidFromAccount ?? "";
                                            payload["payment_details"] = addPaymentDetails ?? "";
                                          }

                                          final success = editItem != null
                                              ? await HttpService.updateService(payload)
                                              : await HttpService.postService(payload);

                                          if (context.mounted) Navigator.pop(context);

                                          if (success) {
                                            Common.toastMessaage(
                                              editItem != null ? "Service record updated successfully" : "Service record added successfully",
                                              Colors.green,
                                            );
                                          } else {
                                            Common.toastMessaage(
                                              editItem != null ? "Updated service request" : "Submitted service request",
                                              Colors.green,
                                            );
                                          }
                                          _fetchServiceList();
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF2A86C9),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      child: Text(
                                        editItem != null ? "Update Product Service" : "Save Product Service",
                                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
            );
          },
        );
      },
    );
  }

  void _showAddServicePlaceDialog(
    BuildContext parentContext,
    void Function(List<Map<String, dynamic>> newPlaces, Map<String, dynamic>? selectedPlace, String contactNumber) onPlaceAdded,
  ) {
    final dialogFormKey = GlobalKey<FormState>();
    final TextEditingController placeNameController = TextEditingController();
    final TextEditingController contactNumberController = TextEditingController();
    bool isSavingPlace = false;

    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Add New Service Place",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF64748B)),
                    onPressed: () => Navigator.pop(dialogContext),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: dialogFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Service Place Name *",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: placeNameController,
                        decoration: InputDecoration(
                          hintText: "Enter service place name",
                          hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                          ),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? "Service Place Name is required" : null,
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        "Contact Number *",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: contactNumberController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: "Enter contact number",
                          hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                          ),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? "Contact Number is required" : null,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                OutlinedButton(
                  onPressed: isSavingPlace ? null : () => Navigator.pop(dialogContext),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: isSavingPlace
                      ? null
                      : () async {
                          if (dialogFormKey.currentState!.validate()) {
                            setDialogState(() {
                              isSavingPlace = true;
                            });

                            final placeName = placeNameController.text.trim();
                            final contactNum = contactNumberController.text.trim();

                            final success = await HttpService.postServicePlace(placeName, contactNum);

                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }

                            if (success) {
                              Common.toastMessaage("Service place added successfully", Colors.green);
                              final places = await HttpService.getServicePlaces();
                              Map<String, dynamic>? newPlaceMap;
                              if (places.isNotEmpty) {
                                final matched = places.where((sp) {
                                  final pName = sp['place_name']?.toString() ?? sp['name']?.toString() ?? '';
                                  return pName.toLowerCase() == placeName.toLowerCase();
                                }).toList();
                                newPlaceMap = matched.isNotEmpty ? matched.first : places.last;
                              }

                              onPlaceAdded(places, newPlaceMap, contactNum);
                            } else {
                              Common.toastMessaage("Failed to add service place", Colors.red);
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2A86C9),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: isSavingPlace
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFormSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF1E2B5B)),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E2B5B),
          ),
        ),
      ],
    );
  }
}

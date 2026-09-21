import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/lead_management/addLeadCommonDataModel.dart';
import 'package:login2/models/lead_management/leadProductsModel.dart';
import 'package:login2/service/service.dart';
import 'package:login2/models/lead_management/getActiveStatusModel.dart';
import 'package:login2/models/lead_management/tagListForFilterModel.dart';
import 'package:login2/models/lead_management/classListModel.dart';
import 'package:login2/models/lead_management/streamListModel.dart';
import 'package:login2/models/lead_management/syllabusListModel.dart';
import 'package:login2/models/lead_management/schoolDistrictListModel.dart';
import 'package:login2/models/lead_management/schoolListModel.dart';
import 'package:login2/models/lead_management/abroadListModel.dart';

class ViewLeadsFilterWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onApplyFilters;
  final AddLeadCommonDataModel? commonDetails;
  final LeadProductSectionModel? productSectionModel;
  final String? currentTab;
  final Map<String, dynamic>? initialFilters;
  final String? isActiveLeads;
  const ViewLeadsFilterWidget({
    super.key,
    required this.onApplyFilters,
    this.commonDetails,
    this.productSectionModel,
    this.currentTab,
    this.initialFilters,
    this.isActiveLeads,
  });

  @override
  State<ViewLeadsFilterWidget> createState() => _ViewLeadsFilterWidgetState();
}

class _ViewLeadsFilterWidgetState extends State<ViewLeadsFilterWidget> {
  String selectedCategory = 'Leads Date';
  DateTime? fromDate;
  DateTime? toDate;
  DateTime? fromDateUpdated;
  DateTime? toDateUpdated;
  bool isDateFiltered = false;
  bool isDateFilteredUpdated = false;
  Set<String> selectedStatusIds = {};
  Set<String> selectedStaffIds = {};
  Set<String> selectedCategoryIds = {};
  Set<String> selectedPriorityIds = {};
  Set<String> selectedProductIds = {};
  Set<String> selectedTagIds = {};
  Set<String> selectedClassIds = {};
  Set<String> selectedStreamNames = {};
  Set<String> selectedSyllabusIds = {};
  Set<String> selectedSchoolDistrictIds = {};
  Set<String> selectedAbroadIds = {};
  Set<String> selectedSchoolIds = {};

  List<ClassItem> _classList = [];
  bool _isClassLoading = false;

  List<StreamItem> _streamList = [];
  bool _isStreamLoading = false;

  List<SyllabusItem> _syllabusList = [];
  bool _isSyllabusLoading = false;

  List<SchoolDistrictItem> _schoolDistrictList = [];
  bool _isSchoolDistrictLoading = false;

  List<AbroadItem> _abroadList = [];
  bool _isAbroadLoading = false;

  List<SchoolItem> _schoolList = [];
  bool _isSchoolLoading = false;

  final DateFormat _formatter = DateFormat('dd-MM-yyyy');
  final TextEditingController _searchController = TextEditingController();
  GetActiveStatusModel? _activeStatusModel;
  bool _isActiveStatusLoading = false;
  TagListForFilterModel? _tagListModel;
  bool _isTagLoading = false;
  String? selectedDateType;

  @override
  void initState() {
    super.initState();
    _loadInitialFilters();
    _fetchActiveStatus();
    selectedDateType = widget.initialFilters?['dateType'] ?? 'created';
    if (selectedStatusIds.isNotEmpty) {
      _fetchTags(selectedStatusIds.first);
    }
    _fetchDropdownFiltersData();
  }

  Future<void> _fetchDropdownFiltersData() async {
    _fetchClassList();
    _fetchStreamList();
    _fetchSyllabusList();
    _fetchSchoolDistrictList();
    _fetchAbroadList();
    _fetchSchoolList(selectedSchoolDistrictIds.isNotEmpty ? selectedSchoolDistrictIds.first : null);
  }

  Future<void> _fetchClassList() async {
    setState(() => _isClassLoading = true);
    try {
      final res = await HttpService.getClassList(null);
      if (mounted) {
        setState(() {
          _classList = res?.data ?? [];
          _isClassLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isClassLoading = false);
    }
  }

  Future<void> _fetchStreamList() async {
    setState(() => _isStreamLoading = true);
    try {
      final res = await HttpService.getStreamList(null);
      if (mounted) {
        setState(() {
          _streamList = res?.data ?? [];
          _isStreamLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isStreamLoading = false);
    }
  }

  Future<void> _fetchSyllabusList() async {
    setState(() => _isSyllabusLoading = true);
    try {
      final res = await HttpService.getSyllabusList(null);
      if (mounted) {
        setState(() {
          _syllabusList = res?.data ?? [];
          _isSyllabusLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isSyllabusLoading = false);
    }
  }

  Future<void> _fetchSchoolDistrictList() async {
    setState(() => _isSchoolDistrictLoading = true);
    try {
      final res = await HttpService.getDistrictList(null);
      if (mounted) {
        setState(() {
          _schoolDistrictList = res?.data ?? [];
          _isSchoolDistrictLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isSchoolDistrictLoading = false);
    }
  }

  Future<void> _fetchAbroadList() async {
    setState(() => _isAbroadLoading = true);
    try {
      final res = await HttpService.getAbroadList(null);
      if (mounted) {
        setState(() {
          _abroadList = res?.data ?? [];
          _isAbroadLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isAbroadLoading = false);
    }
  }

  Future<void> _fetchSchoolList([String? districtId]) async {
    setState(() => _isSchoolLoading = true);
    try {
      final res = await HttpService.getSchoolList(null, districtId ?? "");
      if (mounted) {
        setState(() {
          _schoolList = res?.data ?? [];
          _isSchoolLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isSchoolLoading = false);
    }
  }

  Future<void> _fetchTags(String callResultId) async {
    setState(() {
      _isTagLoading = true;
      _tagListModel = null;
    });
    try {
      final res = await HttpService.getLeadsTagForFilter(callResultId);
      if (mounted) {
        setState(() {
          _tagListModel = res;
          _isTagLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isTagLoading = false);
      }
    }
  }

  Future<void> _fetchActiveStatus() async {
    setState(() => _isActiveStatusLoading = true);
    String? statusFew;
    if (widget.currentTab == 'Active') {
      statusFew = '2';
    } else if (widget.currentTab == 'Called') {
      statusFew = '1';
    }
    if (widget.isActiveLeads == '1') {
      statusFew = '2';
    }
    try {
      final res = await HttpService.getActiveStatus(status: statusFew);
      if (mounted) {
        setState(() {
          _activeStatusModel = res;
          _isActiveStatusLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isActiveStatusLoading = false);
      }
    }
  }

  void _loadInitialFilters() {
    if (widget.initialFilters != null) {
      final filters = widget.initialFilters!;
      isDateFiltered = filters['isDateFiltered'] ?? false;
      isDateFilteredUpdated = filters['isDateFilteredUpdated'] ?? false;
      if (filters['fromDate'] != null) {
        fromDate = filters['fromDate'] is DateTime
            ? filters['fromDate']
            : DateTime.tryParse(filters['fromDate'].toString());
      }
      if (filters['toDate'] != null) {
        toDate = filters['toDate'] is DateTime
            ? filters['toDate']
            : DateTime.tryParse(filters['toDate'].toString());
      }

      if (filters['fromDateUpdated'] != null) {
        fromDate = filters['fromDateUpdated'] is DateTime
            ? filters['fromDateUpdated']
            : DateTime.tryParse(filters['fromDateUpdated'].toString());
      }
      if (filters['toDateUpdated'] != null) {
        toDate = filters['toDateUpdated'] is DateTime
            ? filters['toDateUpdated']
            : DateTime.tryParse(filters['toDateUpdated'].toString());
      }

      if (filters['statusIds'] != null) {
        selectedStatusIds = Set<String>.from(filters['statusIds']);
      }
      if (filters['staffIds'] != null) {
        selectedStaffIds = Set<String>.from(filters['staffIds']);
      }
      if (filters['categoryIds'] != null) {
        selectedCategoryIds = Set<String>.from(filters['categoryIds']);
      }
      if (filters['priorityIds'] != null) {
        selectedPriorityIds = Set<String>.from(filters['priorityIds']);
      }
      if (filters['productIds'] != null) {
        selectedProductIds = Set<String>.from(filters['productIds']);
      }
      if (filters['tagIds'] != null) {
        selectedTagIds = Set<String>.from(filters['tagIds']);
      }
      if (filters['call_result_reason'] != null) {
        selectedTagIds = Set<String>.from(filters['call_result_reason']);
      }
      if (filters['classIds'] != null) {
        selectedClassIds = Set<String>.from(filters['classIds']);
      } else if (filters['class_id'] != null && filters['class_id'] is List) {
        selectedClassIds = Set<String>.from(filters['class_id']);
      }
      if (filters['streamNames'] != null) {
        selectedStreamNames = Set<String>.from(filters['streamNames']);
      } else if (filters['stream'] != null && filters['stream'] is List) {
        selectedStreamNames = Set<String>.from(filters['stream']);
      }
      if (filters['syllabusIds'] != null) {
        selectedSyllabusIds = Set<String>.from(filters['syllabusIds']);
      } else if (filters['syllabus'] != null && filters['syllabus'] is List) {
        selectedSyllabusIds = Set<String>.from(filters['syllabus']);
      }
      if (filters['schoolDistrictIds'] != null) {
        selectedSchoolDistrictIds = Set<String>.from(filters['schoolDistrictIds']);
      } else if (filters['school_district_id'] != null && filters['school_district_id'] is List) {
        selectedSchoolDistrictIds = Set<String>.from(filters['school_district_id']);
      }
      if (filters['abroadIds'] != null) {
        selectedAbroadIds = Set<String>.from(filters['abroadIds']);
      } else if (filters['abroad'] != null && filters['abroad'] is List) {
        selectedAbroadIds = Set<String>.from(filters['abroad']);
      }
      if (filters['schoolIds'] != null) {
        selectedSchoolIds = Set<String>.from(filters['schoolIds']);
      } else if (filters['school_name'] != null && filters['school_name'] is List) {
        selectedSchoolIds = Set<String>.from(filters['school_name']);
      }
      if (filters['dateType'] != null) {
        selectedDateType = filters['dateType'];
        // Set selectedCategory based on dateType
        if (selectedDateType == 'created') {
          selectedCategory = 'Leads Date';
        } else if (selectedDateType == 'updated') {
          selectedCategory = 'Updated Date';
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildFilterBody(),
          const SizedBox(height: 24),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Filters',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E3A59),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF2E3A59)),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildFilterBody() {
    return Container(
      height: 350,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120,
            decoration: const BoxDecoration(
              border: Border(right: BorderSide(color: Color(0xFFE4E9F2))),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildCategoryItem('Leads Date', Icons.calendar_today),
                  // widget.currentTab == "All Leads"
                  //     ? _buildCategoryItem('Updated Date', Icons.calendar_today)
                  // : SizedBox.shrink(),
                  if (widget.currentTab != 'New' &&
                      widget.currentTab != 'Closed Leads' &&
                      widget.currentTab != 'Lost Leads' &&
                      widget.currentTab != 'New Leads')
                    _buildCategoryItem('Stages', Icons.info_outline),
                  if (selectedStatusIds.isNotEmpty &&
                      (widget.currentTab != 'New' &&
                          widget.currentTab != 'Closed Leads' &&
                          widget.currentTab != 'Lost Leads' &&
                          widget.currentTab != 'New Leads'))
                    _buildCategoryItem('Tags', Icons.tag_rounded),
                  _buildCategoryItem('Assigned Staff', Icons.people_outline),
                  _buildCategoryItem('Category', Icons.category_outlined),
                  _buildCategoryItem('Priority', Icons.low_priority),
                  // _buildCategoryItem('Products', Icons.shopping_bag_outlined),
                  _buildCategoryItem('Class', Icons.class_outlined),
                  _buildCategoryItem('Stream', Icons.account_tree_outlined),
                  _buildCategoryItem('Syllabus', Icons.menu_book_outlined),
                  _buildCategoryItem('District school', Icons.location_city_outlined),
                  _buildCategoryItem('Abroad', Icons.flight_takeoff_outlined),
                  _buildCategoryItem('School Name', Icons.school_outlined),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildOptionsExpansion(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String title, IconData icon) {
    final isSelected = selectedCategory == title;
    final hasFilters = _hasFiltersForCategory(title);

    return GestureDetector(
      onTap: () => setState(() {
        _searchController.clear();
        selectedCategory = title;
      }),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          border: isSelected
              ? const Border(left: BorderSide(color: Colors.blue, width: 3))
              : null,
        ),
        child: Column(
          children: [
            Stack(
              children: [
                Icon(icon,
                    color: isSelected ? Colors.blue : const Color(0xFF8F9BB3),
                    size: 24),
                if (hasFilters)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.blue : const Color(0xFF8F9BB3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasFiltersForCategory(String category) {
    switch (category) {
      case 'Leads Date':
        return isDateFiltered;
      case 'Stages':
        return selectedStatusIds.isNotEmpty;
      case 'Assigned Staff':
        return selectedStaffIds.isNotEmpty;
      case 'Category':
        return selectedCategoryIds.isNotEmpty;
      case 'Priority':
        return selectedPriorityIds.isNotEmpty;
      case 'Products':
        return selectedProductIds.isNotEmpty;
      case 'Tags':
        return selectedTagIds.isNotEmpty;
      case 'Class':
        return selectedClassIds.isNotEmpty;
      case 'Stream':
        return selectedStreamNames.isNotEmpty;
      case 'Syllabus':
        return selectedSyllabusIds.isNotEmpty;
      case 'District school' || 'District School':
        return selectedSchoolDistrictIds.isNotEmpty;
      case 'Abroad':
        return selectedAbroadIds.isNotEmpty;
      case 'School Name':
        return selectedSchoolIds.isNotEmpty;
      default:
        return false;
    }
  }

  Widget _buildOptionsExpansion() {
    switch (selectedCategory) {
      case 'Leads Date' || 'Created Date':
        return _buildDateOptions();
      case 'Updated Date':
        return _buildDateOptionsUpdated();
      case 'Stages':
        return _buildStatusOptions();
      case 'Assigned Staff':
        return _buildStaffOptions();
      case 'Category':
        return _buildLeadCategoryOptions();
      case 'Priority':
        return _buildPriorityOptions();
      case 'Products':
        return _buildProductOptions();
      case 'Tags':
        return _buildTagOptions();
      case 'Class':
        return _buildClassOptions();
      case 'Stream':
        return _buildStreamOptions();
      case 'Syllabus':
        return _buildSyllabusOptions();
      case 'District school' || 'District School':
        return _buildSchoolDistrictOptions();
      case 'Abroad':
        return _buildAbroadOptions();
      case 'School Name':
        return _buildSchoolOptions();
      default:
        return const Center(child: Text('Select a category'));
    }
  }

  Widget _buildDateOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.currentTab == "All Leads"?
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                value: 'created',
                groupValue: selectedDateType,
                onChanged: (value) {
                  setState(() {
                    selectedDateType = value!;
                  });
                },
                title: const Text(
                  'Created Date',
                  style: TextStyle(fontSize: 12),
                ),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            // Expanded(
            //   child: RadioListTile<String>(
            //     value: 'updated',
            //     groupValue: selectedDateType,
            //     onChanged: (value) {
            //       setState(() {
            //         selectedDateType = value!;
            //       });
            //     },
            //     title: const Text('Updated',style: TextStyle(fontSize: 12),),
            //     dense: true,
            //     contentPadding: EdgeInsets.zero,
            //   ),
            // ),
          ],
        ):SizedBox.shrink(),

        //  const SizedBox(height: 8),
         widget.currentTab == "All Leads"?
        Row(
          children: [
            // Expanded(
            //   child: RadioListTile<String>(
            //     value: 'created',
            //     groupValue: selectedDateType,
            //     onChanged: (value) {
            //       setState(() {
            //         selectedDateType = value!;
            //       });
            //     },
            //     title: const Text('Created',style: TextStyle(fontSize: 12),),
            //     dense: true,
            //     contentPadding: EdgeInsets.zero,
            //   ),
            // ),
            Expanded(
              child: RadioListTile<String>(
                value: 'updated',
                groupValue: selectedDateType,
                onChanged: (value) {
                  setState(() {
                    selectedDateType = value!;
                  });
                },
                title: const Text(
                  'Updated Date',
                  style: TextStyle(fontSize: 12),
                ),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ):SizedBox.shrink(),

        //const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Select Date Range',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            // if (isDateFiltered)
            TextButton(
              onPressed: () {
                setState(() {
                  fromDate = null;
                  toDate = null;
                  isDateFiltered = false;
                });
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(50, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Clear',
                  style: TextStyle(color: Colors.red, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildDateField('From Date', fromDate, (date) {
          setState(() {
            fromDate = date;
            isDateFiltered = true;
          });
        }),
        const SizedBox(height: 12),
        _buildDateField('To Date', toDate, (date) {
          setState(() {
            toDate = date;
            isDateFiltered = true;
          });
        }),
        const SizedBox(height: 16),
        _buildQuickDateFilters(
          onToday: () {
            final now = DateTime.now();
            setState(() {
              fromDate = now;
              toDate = now;
              isDateFiltered = true;
            });
          },
          onThisMonth: () {
            final now = DateTime.now();
            setState(() {
              fromDate = DateTime(now.year, now.month, 1);
              toDate = DateTime(now.year, now.month + 1, 0);
              isDateFiltered = true;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDateOptionsUpdated() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Select Date Updated',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            // if (isDateFiltered)
            TextButton(
              onPressed: () {
                setState(() {
                  fromDateUpdated = null;
                  toDateUpdated = null;
                  isDateFilteredUpdated = false;
                });
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(50, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Clear',
                  style: TextStyle(color: Colors.red, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildDateField('From Date', fromDateUpdated, (date) {
          setState(() {
            fromDateUpdated = date;
            isDateFilteredUpdated = true;
          });
        }),
        const SizedBox(height: 12),
        _buildDateField('To Date', toDateUpdated, (date) {
          setState(() {
            toDateUpdated = date;
            isDateFilteredUpdated = true;
          });
        }),
        const SizedBox(height: 16),
        _buildQuickDateFiltersUpdated(
          onToday: () {
            final now = DateTime.now();
            setState(() {
              fromDateUpdated = now;
              toDateUpdated = now;
              isDateFilteredUpdated = true;
            });
          },
          onThisMonth: () {
            final now = DateTime.now();
            setState(() {
              fromDateUpdated = DateTime(now.year, now.month, 1);
              toDateUpdated = DateTime(now.year, now.month + 1, 0);
              isDateFilteredUpdated = true;
            });
          },
        ),
      ],
    );
  }

  Widget _buildQuickDateFilters({
    required VoidCallback onToday,
    required VoidCallback onThisMonth,
  }) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onToday,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE3F2FD),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 4),
              side: const BorderSide(color: Colors.blue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: const Size(0, 40),
            ),
            child: const Text(
              "Today",
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: onThisMonth,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE3F2FD),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 4),
              side: const BorderSide(color: Colors.blue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: const Size(0, 40),
            ),
            child: const Text(
              "This Month",
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildQuickDateFiltersUpdated({
    required VoidCallback onToday,
    required VoidCallback onThisMonth,
  }) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onToday,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE3F2FD),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 4),
              side: const BorderSide(color: Colors.blue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: const Size(0, 40),
            ),
            child: const Text(
              "Today",
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: onThisMonth,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE3F2FD),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 4),
              side: const BorderSide(color: Colors.blue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: const Size(0, 40),
            ),
            child: const Text(
              "This Month",
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildDateField(
      String label, DateTime? value, Function(DateTime) onSelect) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) onSelect(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE4E9F2)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 10, color: Color(0xFF8F9BB3))),
                Text(value != null ? _formatter.format(value) : 'Select Date',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
            Icon(Icons.calendar_today, size: 18, color: Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOptions() {
    // if (widget.isActiveLeads == '1') {
    if (_isActiveStatusLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_activeStatusModel == null ||
        (_activeStatusModel?.data?.isEmpty ?? true)) {
      return const Center(child: Text('No active statuses found'));
    }
    return _buildSelectionList(
      items: _activeStatusModel?.data
              ?.map((e) =>
                  {'id': e.callResultId.toString(), 'name': e.callResult ?? ''})
              .toList() ??
          [],
      selectedIds: selectedStatusIds,
      isSingleSelect: true,
      onToggle: (id) => setState(() {
        if (selectedStatusIds.contains(id)) {
          selectedStatusIds.remove(id);
          selectedTagIds.clear();
          _tagListModel = null;
        } else {
          selectedStatusIds.clear();
          selectedStatusIds.add(id);
          selectedTagIds.clear();
          _fetchTags(id);
        }
      }),
    );
    // }

    if (widget.commonDetails == null)
      return const Center(child: Text('Loading...'));
    final items = widget.commonDetails!.data.callResult;
    return _buildSelectionList(
      items: items
          .map((e) => {'id': e.callResultId.toString(), 'name': e.callResult})
          .toList(),
      selectedIds: selectedStatusIds,
      isSingleSelect: true,
      onToggle: (id) => setState(() {
        if (selectedStatusIds.contains(id)) {
          selectedStatusIds.remove(id);
          selectedTagIds.clear();
          _tagListModel = null;
        } else {
          selectedStatusIds.clear();
          selectedStatusIds.add(id);
          selectedTagIds.clear();
          _fetchTags(id);
        }
      }),
    );
  }

  Widget _buildTagOptions() {
    if (_isTagLoading) return const Center(child: CircularProgressIndicator());
    if (_tagListModel == null || (_tagListModel?.data?.isEmpty ?? true)) {
      return const Center(child: Text('No tags found for this stage'));
    }
    final items = _tagListModel!.data!;
    return _buildSelectionList(
      items: items
          .map((e) => {'id': e.id.toString(), 'name': e.reason ?? ''})
          .toList(),
      selectedIds: selectedTagIds,
      onToggle: (id) => setState(() {
        if (selectedTagIds.contains(id)) {
          selectedTagIds.remove(id);
        } else {
          selectedTagIds.add(id);
        }
      }),
    );
  }

  Widget _buildStaffOptions() {
    if (widget.commonDetails == null)
      return const Center(child: Text('Loading...'));
    final items = widget.commonDetails!.data.staff;
    return _buildSelectionList(
      items: items
          .map((e) => {'id': e.userId.toString(), 'name': e.staffName})
          .toList(),
      selectedIds: selectedStaffIds,
      onToggle: (id) => setState(() => selectedStaffIds.contains(id)
          ? selectedStaffIds.remove(id)
          : selectedStaffIds.add(id)),
    );
  }

  Widget _buildLeadCategoryOptions() {
    if (widget.commonDetails == null)
      return const Center(child: Text('Loading...'));
    final items = widget.commonDetails!.data.leadCategory;
    return _buildSelectionList(
      items: items
          .map((e) =>
              {'id': e.leadCategoryId.toString(), 'name': e.leadCategory})
          .toList(),
      selectedIds: selectedCategoryIds,
      onToggle: (id) => setState(() => selectedCategoryIds.contains(id)
          ? selectedCategoryIds.remove(id)
          : selectedCategoryIds.add(id)),
    );
  }

  Widget _buildPriorityOptions() {
    if (widget.commonDetails == null)
      return const Center(child: Text('Loading...'));
    final items = widget.commonDetails!.data.priority;
    return _buildSelectionList(
      items: items
          .map((e) => {'id': e.priorityId.toString(), 'name': e.priority})
          .toList(),
      selectedIds: selectedPriorityIds,
      onToggle: (id) => setState(() => selectedPriorityIds.contains(id)
          ? selectedPriorityIds.remove(id)
          : selectedPriorityIds.add(id)),
    );
  }

  Widget _buildProductOptions() {
    if (widget.productSectionModel == null)
      return const Center(child: Text('Loading...'));
    final items = widget.productSectionModel!.data ?? [];
    if (items.isEmpty) return const Center(child: Text('No products added'));
    return _buildSelectionList(
      items: items
          .map((e) => {'id': e.id.toString(), 'name': e.productName ?? ''})
          .toList(),
      selectedIds: selectedProductIds,
      onToggle: (id) => setState(() => selectedProductIds.contains(id)
          ? selectedProductIds.remove(id)
          : selectedProductIds.add(id)),
    );
  }

  Widget _buildClassOptions() {
    if (_isClassLoading) return const Center(child: CircularProgressIndicator());
    if (_classList.isEmpty) return const Center(child: Text('No classes found'));
    return _buildSelectionList(
      items: _classList
          .map((e) => {'id': e.classId, 'name': e.className})
          .toList(),
      selectedIds: selectedClassIds,
      onToggle: (id) => setState(() {
        if (selectedClassIds.contains(id)) {
          selectedClassIds.remove(id);
        } else {
          selectedClassIds.add(id);
        }
      }),
    );
  }

  Widget _buildStreamOptions() {
    if (_isStreamLoading) return const Center(child: CircularProgressIndicator());
    if (_streamList.isEmpty) return const Center(child: Text('No streams found'));
    return _buildSelectionList(
      items: _streamList
          .map((e) => {'id': e.streamName, 'name': e.streamName})
          .toList(),
      selectedIds: selectedStreamNames,
      onToggle: (id) => setState(() {
        if (selectedStreamNames.contains(id)) {
          selectedStreamNames.remove(id);
        } else {
          selectedStreamNames.add(id);
        }
      }),
    );
  }

  Widget _buildSyllabusOptions() {
    if (_isSyllabusLoading) return const Center(child: CircularProgressIndicator());
    if (_syllabusList.isEmpty) return const Center(child: Text('No syllabus found'));
    return _buildSelectionList(
      items: _syllabusList
          .map((e) => {'id': e.id, 'name': e.value})
          .toList(),
      selectedIds: selectedSyllabusIds,
      onToggle: (id) => setState(() {
        if (selectedSyllabusIds.contains(id)) {
          selectedSyllabusIds.remove(id);
        } else {
          selectedSyllabusIds.add(id);
        }
      }),
    );
  }

  Widget _buildSchoolDistrictOptions() {
    if (_isSchoolDistrictLoading) return const Center(child: CircularProgressIndicator());
    if (_schoolDistrictList.isEmpty) return const Center(child: Text('No districts found'));
    return _buildSelectionList(
      items: _schoolDistrictList
          .map((e) => {'id': e.districtId, 'name': e.districtTitle})
          .toList(),
      selectedIds: selectedSchoolDistrictIds,
      onToggle: (id) => setState(() {
        if (selectedSchoolDistrictIds.contains(id)) {
          selectedSchoolDistrictIds.remove(id);
        } else {
          selectedSchoolDistrictIds.add(id);
        }
        _fetchSchoolList(selectedSchoolDistrictIds.isNotEmpty ? selectedSchoolDistrictIds.first : null);
      }),
    );
  }

  Widget _buildAbroadOptions() {
    if (_isAbroadLoading) return const Center(child: CircularProgressIndicator());
    if (_abroadList.isEmpty) return const Center(child: Text('No abroad options found'));
    return _buildSelectionList(
      items: _abroadList
          .map((e) => {'id': e.placeId, 'name': e.placeName})
          .toList(),
      selectedIds: selectedAbroadIds,
      onToggle: (id) => setState(() {
        if (selectedAbroadIds.contains(id)) {
          selectedAbroadIds.remove(id);
        } else {
          selectedAbroadIds.add(id);
        }
      }),
    );
  }

  Widget _buildSchoolOptions() {
    if (_isSchoolLoading) return const Center(child: CircularProgressIndicator());
    if (_schoolList.isEmpty) return const Center(child: Text('No schools found'));
    return _buildSelectionList(
      items: _schoolList
          .map((e) => {
                'id': e.id.isNotEmpty ? e.id : e.schoolName,
                'name': e.schoolName
              })
          .toList(),
      selectedIds: selectedSchoolIds,
      onToggle: (id) => setState(() {
        if (selectedSchoolIds.contains(id)) {
          selectedSchoolIds.remove(id);
        } else {
          selectedSchoolIds.add(id);
        }
      }),
    );
  }

  Widget _buildSelectionList({
    required List<Map<String, String>> items,
    required Set<String> selectedIds,
    required Function(String) onToggle,
    bool isSingleSelect = false,
  }) {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Search...',
            prefixIcon: const Icon(Icons.search, size: 20),
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE4E9F2)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final name = item['name'] ?? '';
              final id = item['id'] ?? '';

              if (_searchController.text.isNotEmpty &&
                  !name
                      .toLowerCase()
                      .contains(_searchController.text.toLowerCase())) {
                return const SizedBox.shrink();
              }

              if (isSingleSelect) {
                return RadioListTile<String>(
                  value: id,
                  groupValue:
                      selectedIds.length == 1 ? selectedIds.first : null,
                  onChanged: (v) => onToggle(id),
                  toggleable: true,
                  title: Text(name, style: const TextStyle(fontSize: 13)),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  visualDensity: VisualDensity.compact,
                );
              }
              final isSelected = selectedIds.contains(id);

              return CheckboxListTile(
                value: isSelected,
                onChanged: (_) => onToggle(id),
                title: Text(name, style: const TextStyle(fontSize: 13)),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                dense: true,
                visualDensity: VisualDensity.compact,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                selectedStatusIds.clear();
                selectedStaffIds.clear();
                selectedCategoryIds.clear();
                selectedPriorityIds.clear();
                selectedProductIds.clear();
                selectedTagIds.clear();
                selectedClassIds.clear();
                selectedStreamNames.clear();
                selectedSyllabusIds.clear();
                selectedSchoolDistrictIds.clear();
                selectedAbroadIds.clear();
                selectedSchoolIds.clear();
                _tagListModel = null;
                fromDate = null;
                toDate = null;
                fromDateUpdated = null;
                toDateUpdated = null;
                isDateFiltered = false;
                isDateFilteredUpdated = false;
              });
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: Color(0xFFE4E9F2)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Clear All',
                style: TextStyle(color: Color(0xFF2E3A59))),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              widget.onApplyFilters({
                'dateType': selectedDateType,
                'fromDate': fromDate,
                'toDate': toDate,
                'isDateFiltered': isDateFiltered,
                'statusIds': selectedStatusIds.toList(),
                'staffIds': selectedStaffIds.toList(),
                'categoryIds': selectedCategoryIds.toList(),
                'priorityIds': selectedPriorityIds.toList(),
                'productIds': selectedProductIds.toList(),
                'tagIds': selectedTagIds.toList(),
                'call_result_reason': selectedTagIds.toList(),
                'classIds': selectedClassIds.toList(),
                'class_id': selectedClassIds.toList(),
                'streamNames': selectedStreamNames.toList(),
                'stream': selectedStreamNames.toList(),
                'syllabusIds': selectedSyllabusIds.toList(),
                'syllabus': selectedSyllabusIds.toList(),
                'schoolDistrictIds': selectedSchoolDistrictIds.toList(),
                'school_district_id': selectedSchoolDistrictIds.toList(),
                'abroadIds': selectedAbroadIds.toList(),
                'abroad': selectedAbroadIds.toList(),
                'schoolIds': selectedSchoolIds.toList(),
                'school_name': selectedSchoolIds.toList(),
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Apply Filters',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}

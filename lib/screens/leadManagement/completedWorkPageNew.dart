import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/expense/staffListModel.dart';
import 'package:login2/models/lead_management/staffwiseCompletedUpdatedModel.dart';
import 'package:login2/screens/leadManagement/AssignReport.dart';
import 'package:login2/screens/leadManagement/addWork_page.dart';
import 'package:login2/screens/leadManagement/assignWorkPage.dart';
import 'package:login2/service/service.dart';
import 'package:login2/widgets/filterWidget.dart';

class CompletedWorkPageNew extends StatefulWidget {
  final String workId;
  final String sectionId;
  final String? preselectedWorkId;
  final String? selectedStatus;
  final String staffId;
  final String? assignedToMyself;
  final String? assignedByMyself;
  const CompletedWorkPageNew({
    super.key,
    required this.workId,
    required this.sectionId,
    this.preselectedWorkId,
    this.selectedStatus,
    required this.staffId,
    this.assignedToMyself,
    this.assignedByMyself,
  });

  @override
  State<CompletedWorkPageNew> createState() => _CompletedWorkPageNewState();
}

class _CompletedWorkPageNewState extends State<CompletedWorkPageNew> {
  late String currentDate;
  late Future<StaffwiseCompletedUpdatedModel?> staffwiseWorkFuture;
  Map<String, dynamic> currentFilters = {};
  bool _hasInitialStatusFilter = false;
  String? _initialStatus;
  String? name;
  String? token;
  String? userId;
  String? phoneCallLogPermission;
  String? assignWork;
  bool isLoading = true;
  final Set<String> _selectedFilters = {};
  Map<String, bool> _expandedStaff = {};
  Map<String, bool> _expandedProjects = {};
  Map<String, bool> _expandedTasks = {};
  List<Summary>? staffwiseData;
  List<Staff> allStaffs = [];
  String? selectedStaffName;
  Map<String, int> _filterCounts = {
    'assignedByMe': 0,
    'assignedToMe': 0,
    'pending': 0,
    'todo': 0,
    'all': 0,
  };
  Count? _totalCounts;
  bool _isCalculatingCounts = false;

  @override
  // void initState() {
  //   super.initState();
  //   _loadData(currentFilters);
  //   _loadName();
  //   currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  //   _fetchStaffList();
  void initState() {
    super.initState();
    _loadData(currentFilters);
    _loadName();
    currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _fetchStaffList();
  }

  Future<void> _fetchStaffList() async {
    try {
      final response = await HttpService.getStaffs();
      if (response != null && response.status) {
        setState(() {
          allStaffs = response.data;
        });
      }
    } catch (e) {
      debugPrint('Error fetching staffs: $e');
    }
  }

  Future<void> _loadName() async {
    token = await Common.getSharedPref("token");
    name = await Common.getSharedPref("name");
    assignWork = await Common.getSharedPref("assignWork");
    userId = await Common.getSharedPref("userId");
    phoneCallLogPermission =
        await Common.getSharedPref("phoneCallLogPermission");
    setState(() {
      // Apply filters when navigating from project dashboard
      if (widget.assignedByMyself == "1" && userId != null) {
        _selectedFilters.add('assignedByMe');
        if (widget.selectedStatus != null &&
            widget.selectedStatus!.isNotEmpty) {
          _selectedFilters.add(widget.selectedStatus!);
          currentFilters['status_names'] = [
            widget.selectedStatus!.toLowerCase()
          ];
        }
        // Set Assigned To as the staffId if provided
        if (widget.staffId != null && widget.staffId.isNotEmpty) {
          currentFilters['assigned_to_ids'] = [widget.staffId];
        }
        // Set Assigned By as the logged-in user
        currentFilters['assigned_by_ids'] = [userId];
        _hasInitialStatusFilter = false;
        _initialStatus = null;
      } else if (widget.assignedToMyself == "1" &&
          widget.staffId != null &&
          widget.staffId!.isNotEmpty &&
          userId != null) {
        // _selectedFilters.add('assignedByMe'); // Removed as per user request for general pending
        if (widget.selectedStatus != null &&
            widget.selectedStatus!.isNotEmpty) {
          _selectedFilters.add(widget.selectedStatus!);
          currentFilters['status_names'] = [
            widget.selectedStatus!.toLowerCase()
          ];
        }
        // Set Assigned To as the staffId
        currentFilters['assigned_to_ids'] = [widget.staffId!];
        // Set Assigned By as the logged-in user
        // currentFilters['assigned_by_ids'] = [userId]; // Removed as per user request for general pending
        _hasInitialStatusFilter = false;
        _initialStatus = null;
      }
      _loadData(currentFilters);
    });
  }

  void _loadData(Map<String, dynamic> filters) {
    setState(() {
      isLoading = true;
      _isCalculatingCounts = true;
    });

    staffwiseWorkFuture =
        HttpService().getStaffwiseWorkCompletedNew(widget.staffId).then((data) {
      if (data != null && data.status && data.summary.isNotEmpty) {
        staffwiseData = data.summary;
        _totalCounts = data.count;
        _calculateFilterCounts(data.summary);

        if (widget.staffId.isNotEmpty) {
          _expandAllCards();
        }

        if (widget.workId.isNotEmpty && staffwiseData != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToAndHighlightWork(widget.workId);
          });
        }
      } else {
        staffwiseData = null;
        _filterCounts = {
          'assignedByMe': 0,
          'assignedToMe': 0,
          'pending': 0,
          'todo': 0,
          'all': 0,
        };
      }

      setState(() {
        isLoading = false;
        _isCalculatingCounts = false;
      });
      return data;
    }).catchError((error) {
      debugPrint('Error loading staffwise works: $error');
      setState(() {
        isLoading = false;
        _isCalculatingCounts = false;
        staffwiseData = null;
        _filterCounts = {
          'assignedByMe': 0,
          'assignedToMe': 0,
          'pending': 0,
          'todo': 0,
          'all': 0,
        };
      });
      return null;
    });
  }

  void _calculateFilterCounts(List<Summary> data) {
    int assignedByMeCount = 0;
    int assignedToMeCount = 0;
    int pendingCount = 0;
    int todoCount = 0;

    for (var staff in data) {
      for (var project in staff.projects) {
        for (var task in project.tasks) {
          if (task.assignedBy.toLowerCase() == name?.toLowerCase()) {
            assignedByMeCount++;
          }
          if (task.assignedTo.toLowerCase() == name?.toLowerCase()) {
            assignedToMeCount++;
          }
          if (task.status == 'pending' || task.status == '2') {
            pendingCount++;
          }
          if (task.status == 'todo' ||
              task.status == '1' ||
              task.status == 'to do') {
            todoCount++;
          }
        }
      }
    }

    _filterCounts = {
      'assignedByMe': assignedByMeCount,
      'assignedToMe': assignedToMeCount,
      'pending': pendingCount,
      'todo': todoCount,
      'all': data.length,
    };
  }

  void _expandAllCards() {
    if (staffwiseData == null) return;
    for (var staff in staffwiseData!) {
      _expandedStaff[staff.userId] = true;
      for (var project in staff.projects) {
        final projectKey = '${project.projectId}_${project.customerId}';
        _expandedProjects[projectKey] = true;
        for (var task in project.tasks) {
          _expandedTasks[task.workDetailsId] = true;
        }
      }
    }
  }

  void _scrollToAndHighlightWork(String workId) {}

  Future<void> _handleRefresh() async {
    _loadData(currentFilters);
  }

  void _clearAllFiltersAndState() {
    setState(() {
      currentFilters.clear();
      _selectedFilters.clear();
      _hasInitialStatusFilter = false;
      _initialStatus = null;
      selectedStaffName = null;
      _filterCounts = {
        'assignedByMe': 0,
        'assignedToMe': 0,
        'pending': 0,
        'todo': 0,
        'all': 0,
      };
    });
    _loadData({});
  }

  List<Summary>? getFilteredStaffData() {
    if (staffwiseData == null) return null;
    List<Summary>? filtered = staffwiseData;
    if (selectedStaffName != null) {
      filtered = staffwiseData!.where((staff) {
        return staff.staffName == selectedStaffName;
      }).toList();
    }

    if (_selectedFilters.isEmpty) return filtered;
    return filtered!.where((staff) {
      for (var project in staff.projects) {
        for (var task in project.tasks) {
          bool matchesAssignedByMe = _selectedFilters.contains('assignedByMe')
              ? task.assignedBy.toLowerCase() == name?.toLowerCase()
              : true;
          bool matchesAssignedToMe = _selectedFilters.contains('assignedToMe')
              ? task.assignedTo.toLowerCase() == name?.toLowerCase()
              : true;
          bool hasStatusFilter = _selectedFilters.contains('pending') ||
              _selectedFilters.contains('todo');
          bool matchesStatus = true;
          if (hasStatusFilter) {
            bool matchesPending = _selectedFilters.contains('pending') &&
                (task.status == 'pending' || task.status == '2');
            bool matchesTodo = _selectedFilters.contains('todo') &&
                (task.status == 'todo' ||
                    task.status == '1' ||
                    task.status == 'to do');
            matchesStatus = matchesPending || matchesTodo;
          }
          if (matchesAssignedByMe && matchesAssignedToMe && matchesStatus) {
            return true;
          }
        }
      }
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredStaffData = getFilteredStaffData();
    final hasFilters = _hasInitialStatusFilter ||
        currentFilters.isNotEmpty ||
        _selectedFilters.isNotEmpty ||
        selectedStaffName != null;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Completed Work",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_alt_outlined),
                onPressed: _showFilters,
                tooltip: 'Filter',
              ),
              if (hasFilters)
                Positioned(
                  right: 10,
                  top: 10,
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
          )
          // IconButton(
          //   icon: const Icon(Icons.filter_alt_outlined),
          //   onPressed: _showFilters,
          //   tooltip: 'Filter',
          // ),
        ],
      ),
      body: Column(
        children: [
          // Filter buttons row
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Flexible(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _selectedFilters.contains('assignedByMe')
                                ? Colors.blue
                                : Colors.grey.shade300,
                        foregroundColor:
                            _selectedFilters.contains('assignedByMe')
                                ? Colors.white
                                : Colors.black,
                        minimumSize: const Size(0, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      onPressed: () {
                        setState(() {
                          if (_selectedFilters.contains('assignedByMe')) {
                            _selectedFilters.remove('assignedByMe');
                            currentFilters.remove('assigned_by_ids');
                          } else {
                            _selectedFilters.add('assignedByMe');
                            if (userId != null) {
                              currentFilters['assigned_by_ids'] = [userId];
                            }
                          }
                          _loadData(currentFilters);
                        });
                      },
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'By Me',
                          style: TextStyle(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _selectedFilters.contains('assignedToMe')
                                ? Colors.blue
                                : Colors.grey.shade300,
                        foregroundColor:
                            _selectedFilters.contains('assignedToMe')
                                ? Colors.white
                                : Colors.black,
                        minimumSize: const Size(0, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      onPressed: () {
                        setState(() {
                          if (_selectedFilters.contains('assignedToMe')) {
                            _selectedFilters.remove('assignedToMe');
                            currentFilters.remove('assigned_to_ids');
                          } else {
                            _selectedFilters.add('assignedToMe');
                            if (userId != null) {
                              currentFilters['assigned_to_ids'] = [userId];
                            }
                          }
                          _loadData(currentFilters);
                        });
                      },
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'To Me',
                          style: TextStyle(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedFilters.contains('pending')
                            ? Colors.blue
                            : Colors.grey.shade300,
                        foregroundColor: _selectedFilters.contains('pending')
                            ? Colors.white
                            : Colors.black,
                        minimumSize: const Size(0, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      onPressed: () {
                        setState(() {
                          if (_selectedFilters.contains('pending')) {
                            _selectedFilters.remove('pending');
                            if (currentFilters.containsKey('status_names')) {
                              List<String> names = List<String>.from(
                                  currentFilters['status_names']);
                              names.remove('pending');
                              if (names.isEmpty) {
                                currentFilters.remove('status_names');
                              } else {
                                currentFilters['status_names'] = names;
                              }
                            }
                          } else {
                            _selectedFilters.add('pending');
                            List<String> names =
                                currentFilters.containsKey('status_names')
                                    ? List<String>.from(
                                        currentFilters['status_names'])
                                    : [];
                            if (!names.contains('pending')) {
                              names.add('pending');
                            }
                            currentFilters['status_names'] = names;
                          }
                          _loadData(currentFilters);
                        });
                      },
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Pending',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedFilters.contains('todo')
                            ? Colors.blue
                            : Colors.grey.shade300,
                        foregroundColor: _selectedFilters.contains('todo')
                            ? Colors.white
                            : Colors.black,
                        minimumSize: const Size(0, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      onPressed: () {
                        setState(() {
                          if (_selectedFilters.contains('todo')) {
                            _selectedFilters.remove('todo');
                            if (currentFilters.containsKey('status_names')) {
                              List<String> names = List<String>.from(
                                  currentFilters['status_names']);
                              names.remove('todo');
                              if (names.isEmpty) {
                                currentFilters.remove('status_names');
                              } else {
                                currentFilters['status_names'] = names;
                              }
                            }
                          } else {
                            _selectedFilters.add('todo');
                            List<String> names =
                                currentFilters.containsKey('status_names')
                                    ? List<String>.from(
                                        currentFilters['status_names'])
                                    : [];
                            if (!names.contains('todo')) {
                              names.add('todo');
                            }
                            currentFilters['status_names'] = names;
                          }
                          _loadData(currentFilters);
                        });
                      },
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'To-Do',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                ),
                // Staff popup button
                Container(
                  width: 40,
                  height: 36,
                  margin: const EdgeInsets.only(left: 8),
                  child: IconButton(
                    icon: const Icon(Icons.people),
                    onPressed: () {
                      _showSmallStaffPopup(context);
                    },
                  ),
                ),
              ],
            ),
          ),

          if (selectedStaffName != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.blue.shade50,
              child: Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Filtered by: $selectedStaffName',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () {
                      setState(() {
                        selectedStaffName = null;
                      });
                    },
                  ),
                ],
              ),
            ),

          // Filter applied indicator
          if (hasFilters && selectedStaffName == null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                border: Border(
                  bottom: BorderSide(color: Colors.orange.shade100, width: 1),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.filter_alt, size: 16, color: Colors.orange),
                  const SizedBox(width: 8),
                  const Text('Filters applied',
                      style: TextStyle(color: Colors.orange)),
                  const Spacer(),
                  TextButton(
                    onPressed: _clearAllFiltersAndState,
                    child: const Text('Clear all',
                        style: TextStyle(color: Colors.orange)),
                  ),
                ],
              ),
            ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              child: FutureBuilder<StaffwiseCompletedUpdatedModel?>(
                future: staffwiseWorkFuture,
                builder: (context, snapshot) {
                  if (isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          Text("Error: ${snapshot.error}",
                              style: const TextStyle(color: Colors.red)),
                        ],
                      ),
                    );
                  } else if (filteredStaffData == null ||
                      filteredStaffData!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.assignment_outlined,
                              size: 48, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            hasFilters
                                ? 'No matching assignments found'
                                : 'No pending work assigned',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          if (hasFilters) ...[
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _clearAllFiltersAndState,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade800,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Clear filters',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredStaffData!.length,
                          itemBuilder: (context, index) {
                            final staff = filteredStaffData![index];
                            return _buildStaffCard(staff);
                          },
                        ),
                      ),
                      _buildBottomCountSummary(),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: assignWork == "true"
          ? FloatingActionButton(
              backgroundColor: Colors.blue,
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AssignWorkPage(
                      onSuccess: () {
                        _loadData(currentFilters);
                      },
                    ),
                  ),
                );
                if (result == true) {
                  _loadData(currentFilters);
                }
              },
            )
          : null,
    );
  }

  Widget _buildBottomCountSummary() {
    if (_totalCounts == null) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
        ),
        child: const SizedBox.shrink(),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.assignment_outlined,
            color: Colors.blue,
            size: 24,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Work :',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(255, 17, 17, 17),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _totalCounts!.workCount,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 25),
                  const Icon(
                    Icons.assignment_outlined,
                    color: Colors.blue,
                    size: 24,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Task:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(255, 22, 22, 22),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _totalCounts!.taskCount,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSmallStaffPopup(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    TextEditingController searchController = TextEditingController();
    bool showAll = false;
    String searchQuery = '';
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            List<Staff> filteredStaffs = allStaffs.where((staff) {
              if (searchQuery.isEmpty) return true;
              return staff.name
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase());
            }).toList();

            final itemsToShow = showAll ? filteredStaffs.length : 15;
            final displayStaffs = filteredStaffs.take(itemsToShow).toList();

            return Stack(
              children: [
                Positioned(
                  top: position.top + 111,
                  right: 8,
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 200,
                      height: 400,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Search header
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                              ),
                              border: Border(
                                bottom: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.search,
                                    size: 20, color: Colors.blue),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: searchController,
                                    decoration: const InputDecoration(
                                      hintText: 'Search staff...',
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    autofocus: true,
                                    style: const TextStyle(fontSize: 14),
                                    onChanged: (value) {
                                      setDialogState(() {
                                        searchQuery = value;
                                        showAll = false;
                                      });
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 18),
                                  onPressed: () => Navigator.pop(context),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ),

                          // Staff list
                          Expanded(
                            child: filteredStaffs.isEmpty
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(20.0),
                                      child: Text(
                                        'No staff found',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.all(0),
                                    itemCount: displayStaffs.length,
                                    itemBuilder: (context, index) {
                                      final staff = displayStaffs[index];
                                      return InkWell(
                                        onTap: () {
                                          setState(() {
                                            selectedStaffName = staff.name;
                                          });
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: Colors.grey.shade200,
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            staff.name,
                                            style:
                                                const TextStyle(fontSize: 14),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),

                          // View More / Show Less button
                          if (filteredStaffs.length > 15)
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: Colors.grey.shade300),
                                ),
                              ),
                              child: InkWell(
                                onTap: () {
                                  setDialogState(() {
                                    showAll = !showAll;
                                  });
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      showAll
                                          ? 'Show Less'
                                          : 'View More (${filteredStaffs.length - 15})',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      showAll
                                          ? Icons.arrow_drop_up
                                          : Icons.arrow_drop_down,
                                      size: 16,
                                      color: Colors.blue,
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
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStaffCard(Summary staff) {
    final isStaffExpanded = _expandedStaff[staff.userId] ?? true;
    final totalProjects = staff.projects.length;
    int totalTasks = 0;
    for (var project in staff.projects) {
      totalTasks += project.tasks.length;
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 20, left: 0, right: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade300, width: 1.5),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Colors.blue, size: 28),
            ),
            title: Text(
              staff.staffName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildCountBadge(
                      '$totalProjects ${totalProjects == 1 ? 'Project' : 'Projects'}',
                      Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    _buildCountBadge(
                      '$totalTasks ${totalTasks == 1 ? 'Task' : 'Tasks'}',
                      Colors.green,
                    ),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(
                isStaffExpanded ? Icons.expand_less : Icons.expand_more,
                color: Colors.blue,
              ),
              onPressed: () {
                setState(() {
                  _expandedStaff[staff.userId] = !isStaffExpanded;
                });
              },
            ),
          ),

          // Projects List (expandable)
          if (isStaffExpanded && staff.projects.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: staff.projects.map((project) {
                  return _buildProjectCard(project);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  String? _getSelectedTaskWorkId(Project project) {
    if (project.tasks.isEmpty) return null;
    final pendingTask = project.tasks.firstWhere(
      (task) => task.status == '1' || task.status == 'pending',
      orElse: () => project.tasks.first,
    );

    return pendingTask.workId;
  }

  Widget _buildProjectCard(Project project) {
    final projectKey = '${project.projectId}_${project.customerId}';
    final isProjectExpanded = _expandedProjects[projectKey] ?? true;
    final totalTasks = project.tasks.length;
    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 0, right: 0),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.work_outline, color: Colors.green, size: 22),
            ),
            title: GestureDetector(
              onTap: () {
                String? selectedWorkId = _getSelectedTaskWorkId(project);
                if (selectedWorkId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AssignReport(
                        preselectedWorkId: selectedWorkId,
                        workId: selectedWorkId,
                        sectionId: "",
                      ),
                    ),
                  );
                }
              },
              child: Text(
                project.projectName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(
                  'Client: ${project.customerName}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildCountBadge(
                      '$totalTasks ${totalTasks == 1 ? 'Task' : 'Tasks'}',
                      Colors.blue,
                      size: 10,
                    ),
                    const SizedBox(width: 6),
                    if (project.module.isNotEmpty)
                      _buildCountBadge(
                        project.module,
                        Colors.purple,
                        size: 10,
                      ),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(
                isProjectExpanded ? Icons.expand_less : Icons.expand_more,
                size: 20,
                color: Colors.green,
              ),
              onPressed: () {
                setState(() {
                  _expandedProjects[projectKey] = !isProjectExpanded;
                });
              },
            ),
          ),
          if (isProjectExpanded && project.tasks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                children: project.tasks.map((task) {
                  return _buildTaskItem(task);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(Task task) {
    final isTaskExpanded = _expandedTasks[task.workDetailsId] ?? true;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status indicator
              Container(
                width: 6,
                height: 40,
                decoration: BoxDecoration(
                  color: _getStatusColor(task.status),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Task header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            task.taskName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                _getStatusColor(task.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getStatusText(task.status),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _getStatusColor(task.status),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Assigned info
                    Row(
                      children: [
                        const Icon(Icons.person_outline,
                            size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          'Assigned by: ${task.assignedBy}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 2),

                    // Priority and due date
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        if (task.priority.isNotEmpty)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.flag,
                                  size: 12, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                'Priority: ${_getPriorityText(task.priority)}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _getPriorityColor(task.priority),
                                ),
                              ),
                            ],
                          ),
                        if (task.dueDate.isNotEmpty)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.calendar_today,
                                  size: 12, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                'Due: ${task.dueDate}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _getDueDateColor(task.dueDate),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),

                    // Remarks (expandable)
                    if (task.remarks.isNotEmpty &&
                        task.remarks.any((r) => r.isNotEmpty))
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _expandedTasks[task.workDetailsId] =
                                    !isTaskExpanded;
                              });
                            },
                            child: Row(
                              children: [
                                Icon(
                                  isTaskExpanded
                                      ? Icons.comment_outlined
                                      : Icons.comment_bank_outlined,
                                  size: 14,
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${task.remarks.where((r) => r.isNotEmpty).length} ${task.remarks.where((r) => r.isNotEmpty).length == 1 ? 'remark' : 'remarks'}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  isTaskExpanded
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  size: 16,
                                  color: Colors.blue,
                                ),
                              ],
                            ),
                          ),
                          if (isTaskExpanded)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: task.remarks
                                    .where((remark) => remark.isNotEmpty)
                                    .map((remark) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.circle,
                                          size: 8,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            remark,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCountBadge(String text, Color color, {double size = 12}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Future<void> _handleStartWork(Task task) async {
    final result = await HttpService.getWorkStatus();
    if (result != null && result.data.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Work in Progress"),
          content: const Text(
            "You already have a work in progress. Please complete it before starting a new one.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else {
      // Navigate to AddWorkPage with task details
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddWorkPage(
            workId: task.workId,
            existingWork: null,
            isPaused: 0,
            Restart: 0,
            onSuccess: () {
              _loadData(currentFilters);
            },
          ),
        ),
      );
      if (result == true) {
        _loadData(currentFilters);
      }
    }
  }

  void _showTaskDetails(BuildContext context, Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Task Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Text(
                          'Work ID: ${task.workId}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Task Info Card
                      Card(
                        elevation: 0,
                        color: Colors.blue.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Task Name',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                task.taskName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Status',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(task.status)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _getStatusColor(task.status),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  _getStatusText(task.status),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _getStatusColor(task.status),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Assignment Info Card
                      Card(
                        elevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.person_outline,
                                      color: Colors.green,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Assigned To',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          task.assignedTo,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade100,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.person_add_alt_1,
                                      color: Colors.orange,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Assigned By',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          task.assignedBy,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Priority & Due Date Card
                      Card(
                        elevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade100,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.flag,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Priority',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _getPriorityText(task.priority),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: _getPriorityColor(
                                                task.priority),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.purple.shade100,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.calendar_today,
                                      color: Colors.purple,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Due Date',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          task.dueDate,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                _getDueDateColor(task.dueDate),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Remarks Section
                      if (task.remarks.isNotEmpty &&
                          task.remarks.any((r) => r.isNotEmpty))
                        const SizedBox(height: 16),
                      if (task.remarks.isNotEmpty &&
                          task.remarks.any((r) => r.isNotEmpty))
                        Card(
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.comment_outlined,
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Remarks',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ...task.remarks
                                    .where((remark) => remark.isNotEmpty)
                                    .map((remark) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.circle,
                                          size: 8,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            remark,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ),
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

  void _showFilters() {
    Map<String, dynamic> initialFiltersForWidget = {};

    if (currentFilters.isNotEmpty) {
      initialFiltersForWidget.addAll(currentFilters);
    } else if (_hasInitialStatusFilter) {
      initialFiltersForWidget['status_name'] = _initialStatus;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: FilterWidget(
                  pageId: 2,
                  initialFilters: initialFiltersForWidget,
                  onApplyFilters: (filters) {
                    setState(() {
                      _hasInitialStatusFilter = false;
                      _initialStatus = null;
                      _selectedFilters.clear();

                      if (filters.containsKey('status_names')) {
                        List<String> names =
                            List<String>.from(filters['status_names'] ?? []);
                        if (names.any((n) => n.contains('pending'))) {
                          _selectedFilters.add('pending');
                        }
                        if (names.any(
                            (n) => n.contains('todo') || n.contains('to do'))) {
                          _selectedFilters.add('todo');
                        }
                      }

                      // Handle assigned_by_ids filter
                      if (filters.containsKey('assigned_by_ids')) {
                        _selectedFilters.add('assignedByMe');
                      }

                      // Handle assigned_to_ids filter
                      if (filters.containsKey('assigned_to_ids')) {
                        _selectedFilters.add('assignedToMe');
                      }

                      currentFilters = Map.from(filters);
                      _loadData(currentFilters);
                    });
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '1':
      case 'To Do':
        return Colors.orange;
      case '2': // Running/In Progress
      case 'Pending':
        return Colors.blue;
      case '3': // To Do
      case 'Completed':
      case 'completed':
        return Colors.green;
      case '4': // Completed
      case 'Running':
        return Colors.orange;
      case '5': // Overdue
      case 'Cancelled':
        return Colors.red;
      case '6': // Cancelled
      case 'cancel':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case '1':
        return 'To Do';
      case '2':
        return 'Pending';
      case '3':
        return 'Completed';
      case '4':
        return 'Running';
      case '5':
        return 'Cancelled';
      case '6':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String _getPriorityText(String priority) {
    switch (priority) {
      case '1':
        return 'Normal';
      case '2':
        return 'High';
      case '3':
        return 'Critical';
      case '4':
        return 'Normal';
      default:
        return priority;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case '1':
        return Colors.green;
      case '2':
        return Colors.orange;
      case '3':
        return Colors.red;
      case '4':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getDueDateColor(String dueDate) {
    try {
      final now = DateTime.now();
      DateTime? due;
      final formats = [
        DateFormat('dd-MM-yyyy hh:mm a'),
        DateFormat('dd-MM-yyyy HH:mm:ss'),
        DateFormat('dd-MM-yyyy HH:mm'),
        DateFormat('yyyy-MM-dd HH:mm:ss'),
        DateFormat('yyyy-MM-dd HH:mm'),
        DateFormat('dd-MM-yyyy'),
        DateFormat('yyyy-MM-dd'),
      ];
      for (var f in formats) {
        try {
          due = f.parse(dueDate.trim());
          break;
        } catch (_) {}
      }
      due ??= DateTime.tryParse(dueDate.trim());
      if (due == null) return Colors.grey;

      final difference = due.difference(now).inDays;

      if (due.isBefore(now)) {
        return Colors.red; // Past due
      } else if (due.year == now.year &&
          due.month == now.month &&
          due.day == now.day) {
        return Colors.orange; // Due today
      } else if (difference <= 3) {
        return Colors.orange.shade700; // Due in 3 days
      } else {
        return Colors.green; // Future due date
      }
    } catch (e) {
      return Colors.grey;
    }
  }
}

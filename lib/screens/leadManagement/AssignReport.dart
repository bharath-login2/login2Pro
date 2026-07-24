import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/lead_management/AssignedWorkModel.dart';
import 'package:login2/models/lead_management/assignedWorkStatusModel.dart';
import 'package:login2/models/lead_management/workDetailsCompanyModel.dart';
import 'package:login2/models/lead_management/workstatus_model.dart'
    as workStatus;
import 'package:login2/screens/customer/customerDasboard.dart';
import 'package:login2/screens/leadManagement/ChatScreenWork.dart';
import 'package:login2/screens/leadManagement/addWork_page.dart';
import 'package:login2/screens/leadManagement/assignWorkPage.dart';
import 'package:login2/screens/leadManagement/editAssignedReportPage.dart';
import 'package:login2/service/service.dart';
import 'package:login2/widgets/blinkwidget.dart';
import 'package:login2/widgets/filterWidget.dart';
import 'package:login2/models/expense/staffListModel.dart';
import 'package:login2/models/lead_management/staffwisePendingUpdatedModel.dart';
import 'package:url_launcher/url_launcher.dart';
class AssignReport extends StatefulWidget {
  final String workId;
  final String sectionId;
  final String? preselectedWorkId;
  final String? selectedStatus;
  final String? staffId;
  final String? assignedToMyself;
  final String? assignedByMyself;
  final String? isUnassigned;

  const AssignReport(
      {super.key,
      required this.workId,
      required this.sectionId,
      this.preselectedWorkId,
      this.selectedStatus,
      this.staffId,
      this.assignedToMyself,
      this.assignedByMyself,
      this.isUnassigned});

  @override
  State<AssignReport> createState() => _AssignReportState();
}

class _AssignReportState extends State<AssignReport> {
  late String currentDate;
  Future<List<AssignedWork>> assignedWorkFuture = Future.value(<AssignedWork>[]);
  Map<String, dynamic> currentFilters = {};
  Map<String, bool> _expandedDescriptions = {};
  Map<String, bool> _expandedRemarks = {};
  // bool get isFiltered => currentFilters.isNotEmpty;
  bool get isFiltered =>
      currentFilters.isNotEmpty ||
      (_hasInitialStatusFilter && currentFilters.isEmpty);
  workStatus.WorkStatus? existingWork;
  AssignedWorkStatus? assignedWorks;
  final bool _showAllTasks = false;
  WorkCompanyDetailsModel? workStatusDetails;
  Map<String, bool> _expandedTimelineSessions = {};
  String? name;
  String? token;
  String? userId;
  String? phoneCallLogPermission;
  String? assignWork;
    String? editAssignWork;
    String? deleteAssignWork;
  bool isLoading = true;
  bool isRemarkExpanded = false;
  List<String> participantIds = [];
  final String _selectedFilter = 'all';
  String? _currentUserId;
  final Set<String> _selectedFilters = {};
  bool _isCalculatingCounts = false;
  bool _hasInitialStatusFilter = false;
  String? _initialStatus;
  List<Summary>? staffwiseData;
  List<Staff> allStaffs = [];
  String? selectedStaffName;
  String? selectedStaffId;
  Map<String, int> _filterCounts = {
    'assignedByMe': 0,
    'pending': 0,
    'todo': 0,
    'all': 0,
  };

  bool _isMinimalView = true;
  Map<String, bool> _expandedWorkSessions = {};
  Map<String, bool> _cardMinimalViews = {};
  bool _hasShownTaskDetails = false;
  bool isLoggedIn = false;
  String? whatsappMenu;

  Future<void> loginorNot() async {
    final token = await Common.getSharedPref("token");
    final response = await HttpService.getLoginorNot(token);

    setState(() {
      if (response != null && response.data == true) {
        isLoggedIn = true;
      } else {
        isLoggedIn = false;
      }
    });
  }

  // @override
  // void initState() {
  //   super.initState();
  //   _loadCurrentUserId();
  //   _fetchStaffList();
  //   _loadData(currentFilters);
  //   checkAssignedWorks();
  //   _loadName();
  //   print('widget.isUnassigned: ${widget.isUnassigned}');
  //   currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  //   if (widget.selectedStatus != null && widget.selectedStatus!.isNotEmpty) {
  //     _hasInitialStatusFilter = true;
  //     _initialStatus = widget.selectedStatus!.toLowerCase();
  //     final statusList = widget.selectedStatus!.split(',');
  //     for (var status in statusList) {
  //       final trimmedStatus = status.trim().toLowerCase();
  //       if (trimmedStatus == 'pending') {
  //         _selectedFilters.add('pending');
  //       } else if (trimmedStatus == 'todo' || trimmedStatus == 'to do') {
  //         _selectedFilters.add('todo');
  //       } else {
  //         _selectedFilters.add(status.trim());
  //       }
  //     }
  //   }
  // }

  @override
  void initState() {
    super.initState();
    loginorNot();
    _initAsync(); 
    _loadCurrentUserId();
    _fetchStaffList();
    checkAssignedWorks();
    _loadName();
    print('widget.isUnassigned: ${widget.isUnassigned}');
    currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (widget.selectedStatus != null && widget.selectedStatus!.isNotEmpty) {
      _hasInitialStatusFilter = true;
      _initialStatus = widget.selectedStatus!.toLowerCase();
      final statusList = widget.selectedStatus!.split(',');
      for (var status in statusList) {
        final trimmedStatus = status.trim().toLowerCase();
        if (trimmedStatus == 'pending') {
          _selectedFilters.add('pending');
        } else if (trimmedStatus == 'todo' || trimmedStatus == 'to do') {
          _selectedFilters.add('todo');
        } else {
          _selectedFilters.add(status.trim());
        }
      }
    }
  }
void _initAsync() async {
  final fetchedToken = await Common.getSharedPref("token") ?? "";
  token = fetchedToken;
  userId = await Common.getSharedPref("userId");
  whatsappMenu = await Common.getSharedPref("whatsappMenu");

  if (whatsappMenu == null && fetchedToken.isNotEmpty) {
    final object1 = await HttpService.userPermissionCheck(fetchedToken);
    if (object1 != null && object1.status == true && object1.data != null) {
      whatsappMenu = object1.data!.whatsappMenu?.toString();
      if (whatsappMenu != null) {
        Common.saveSharedPref("whatsappMenu", whatsappMenu!);
      }
    }
  }
  if (mounted) setState(() {});
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

  Future<void> _loadCurrentUserId() async {
    _currentUserId = await Common.getSharedPref("userId");
    setState(() {});
  }

  Future<void> _loadName() async {
    token = await Common.getSharedPref("token");
    name = await Common.getSharedPref("name");
    assignWork = await Common.getSharedPref("assignWork");
     editAssignWork = await Common.getSharedPref("editAssignWork");
     deleteAssignWork = await Common.getSharedPref("deleteAssignWork");
    userId = await Common.getSharedPref("userId");
    phoneCallLogPermission =
        await Common.getSharedPref("phoneCallLogPermission");

    setState(() {
      if (widget.assignedByMyself == "1" &&
          widget.staffId != null &&
          widget.staffId!.isNotEmpty &&
          userId != null) {
        _selectedFilters.add('assignedByMe');
        if (widget.selectedStatus != null &&
            widget.selectedStatus!.isNotEmpty) {
          final statusList = widget.selectedStatus!.split(',');
          for (var status in statusList) {
            final trimmedStatus = status.trim().toLowerCase();
            if (trimmedStatus == 'pending') {
              _selectedFilters.add('pending');
            } else if (trimmedStatus == 'todo' || trimmedStatus == 'to do') {
              _selectedFilters.add('todo');
            } else {
              _selectedFilters.add(status.trim());
            }
          }
          currentFilters['status_names'] =
              statusList.map((s) => s.trim().toLowerCase()).toList();
        }

        currentFilters['assigned_to_ids'] = [widget.staffId!];

        currentFilters['assigned_by_ids'] = [userId];
        _hasInitialStatusFilter = false;
        _initialStatus = null;
      } else if (widget.assignedToMyself == "1" &&
          widget.staffId != null &&
          widget.staffId!.isNotEmpty &&
          userId != null) {
        if (widget.selectedStatus != null &&
            widget.selectedStatus!.isNotEmpty) {
          final statusList = widget.selectedStatus!.split(',');
          for (var status in statusList) {
            final trimmedStatus = status.trim().toLowerCase();
            if (trimmedStatus == 'pending') {
              _selectedFilters.add('pending');
            } else if (trimmedStatus == 'todo' || trimmedStatus == 'to do') {
              _selectedFilters.add('todo');
            } else {
              _selectedFilters.add(status.trim());
            }
          }
          currentFilters['status_names'] =
              statusList.map((s) => s.trim().toLowerCase()).toList();
        }

        currentFilters['assigned_to_ids'] = [widget.staffId!];
        _hasInitialStatusFilter = false;
        _initialStatus = null;
      } else if (widget.isUnassigned == "1") {
        _selectedFilters.add('unassigned');
        currentFilters['assigned_to_ids'] = ['0'];
        currentFilters['status_names'] = ['unassigned'];
        _hasInitialStatusFilter = false;
        _initialStatus = null;
      }
    });

    _loadData(currentFilters);
  }

  // Future<void> _loadName() async {
  //   token = await Common.getSharedPref("token");
  //   name = await Common.getSharedPref("name");
  //   assignWork = await Common.getSharedPref("assignWork");
  //   userId = await Common.getSharedPref("userId");
  //   phoneCallLogPermission =
  //       await Common.getSharedPref("phoneCallLogPermission");
  //   setState(() {
  //     // Apply filters when navigating from project dashboard
  //     if (widget.assignedByMyself == "1" &&
  //         widget.staffId != null &&
  //         widget.staffId!.isNotEmpty &&
  //         userId != null) {
  //       _selectedFilters.add('assignedByMe');
  //       if (widget.selectedStatus != null &&
  //           widget.selectedStatus!.isNotEmpty) {
  //         final statusList = widget.selectedStatus!.split(',');
  //         for (var status in statusList) {
  //           final trimmedStatus = status.trim().toLowerCase();
  //           if (trimmedStatus == 'pending') {
  //             _selectedFilters.add('pending');
  //           } else if (trimmedStatus == 'todo' || trimmedStatus == 'to do') {
  //             _selectedFilters.add('todo');
  //           } else {
  //             _selectedFilters.add(status.trim());
  //           }
  //         }
  //         currentFilters['status_names'] =
  //             statusList.map((s) => s.trim().toLowerCase()).toList();
  //       }
  //       // Set Assigned To as the staffId
  //       currentFilters['assigned_to_ids'] = [widget.staffId!];
  //       // Set Assigned By as the logged-in user
  //       currentFilters['assigned_by_ids'] = [userId];
  //       _hasInitialStatusFilter = false;
  //       _initialStatus = null;
  //     } else if (widget.assignedToMyself == "1" &&
  //         widget.staffId != null &&
  //         widget.staffId!.isNotEmpty &&
  //         userId != null) {
  //       // _selectedFilters.add('assignedByMe'); // Removed as per user request for general pending
  //       if (widget.selectedStatus != null &&
  //           widget.selectedStatus!.isNotEmpty) {
  //         final statusList = widget.selectedStatus!.split(',');
  //         for (var status in statusList) {
  //           final trimmedStatus = status.trim().toLowerCase();
  //           if (trimmedStatus == 'pending') {
  //             _selectedFilters.add('pending');
  //           } else if (trimmedStatus == 'todo' || trimmedStatus == 'to do') {
  //             _selectedFilters.add('todo');
  //           } else {
  //             _selectedFilters.add(status.trim());
  //           }
  //         }
  //         currentFilters['status_names'] =
  //             statusList.map((s) => s.trim().toLowerCase()).toList();
  //       }
  //       // Set Assigned To as the staffId
  //       currentFilters['assigned_to_ids'] = [widget.staffId!];
  //       // Set Assigned By as the logged-in user
  //       // currentFilters['assigned_by_ids'] = [userId]; // Removed as per user request for general pending
  //       _hasInitialStatusFilter = false;
  //       _initialStatus = null;
  //     } else if (widget.isUnassigned == "1") {
  //       _selectedFilters.add('unassigned');
  //       currentFilters['assigned_to_ids'] = ['0'];
  //       currentFilters['status_names'] = ['unassigned'];
  //       _hasInitialStatusFilter = false;
  //       _initialStatus = null;
  //     }
  //     _loadData(currentFilters);
  //   });
  // }
Future<void> _openAttachment(String url) async {
  final Uri? uri = Uri.tryParse(url);

  if (uri == null) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Invalid attachment link"),
      ),
    );
    return;
  }

  try {
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Unable to open attachment"),
        ),
      );
    }
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error opening attachment: $e"),
      ),
    );
  }
}
Future<void> _publishWork(
  dynamic item,
  String remark,
) async {
  final success = await HttpService.publishWork(
    workId: item.id.toString(),
    remark: remark,
  );

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        success
            ? "Published successfully"
            : "Failed to publish",
      ),
      backgroundColor:
          success ? Colors.green : Colors.red,
    ),
  );

  if (success) {
    _loadData(currentFilters);
    checkExistingWorkStatus();
    checkAssignedWorks();
  }
}
  Future<void> _showApproveDialog(AssignedWork item) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Approve Work"),
      content: const Text(
        "Are you sure you want to approve this work?",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text("Approve"),
        ),
      ],
    ),
  );

  if (confirm != true) return;

  final success = await HttpService.approveWork(
    workId: item.id.toString(),
  );

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        success
            ? "Work approved successfully."
            : "Failed to approve work.",
      ),
    ),
  );

  if (success) {
    _handleRefresh(); // Refresh list so status becomes Approved
  }
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
                                            selectedStaffId = staff.userIdStaff;
                                            // Clear "To Me" filter when selecting a specific staff
                                            _selectedFilters
                                                .remove('assignedToMe');
                                            // Add staff filter to currentFilters
                                            currentFilters['assigned_to_ids'] =
                                                [staff.userIdStaff];
                                          });
                                          Navigator.pop(context);
                                          // Reload data with the new filter
                                          _loadData(currentFilters);
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

  void _handleEditWork(AssignedWork item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditWorkPage(
          assignedWork: item,
          onSuccess: () {
            setState(() {
              _loadData(currentFilters);
              checkExistingWorkStatus();
              checkAssignedWorks();
            });
          },
        ),
      ),
    );
  }

  void _handleDeleteWork(AssignedWork item) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Delete Work'),
      content: Text(
        'Are you sure you want to delete "${item.projectName}"?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: () async {
            final result =
                await HttpService().deleteWork(item.id.toString());

            if (!mounted) return;

            if (result != null && result.status == true) {
              Navigator.pop(dialogContext); // Close dialog

              _loadData(currentFilters);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result.message),
                  backgroundColor: Colors.green,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    result?.message ?? "Failed to delete work",
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: const Text(
            'Delete',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );
}
  void _clearAllFiltersAndState() {
    setState(() {
      currentFilters.clear();
      _selectedFilters.clear();
      _hasInitialStatusFilter = false;
      _initialStatus = null;
      selectedStaffName = null;
      selectedStaffId = null;
      _filterCounts = {
        'assignedByMe': 0,
        'pending': 0,
        'todo': 0,
        'all': 0,
      };
      _expandedWorkSessions.clear();
      _cardMinimalViews.clear();
      _isMinimalView = false;
      _loadData({});
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All filters and selections cleared'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _loadData(currentFilters) {
    setState(() {
      isLoading = true;
      _isCalculatingCounts = true;
    });
    Map<String, dynamic> filters = {};
    if (_hasInitialStatusFilter && currentFilters.isEmpty) {
      filters['status_name'] = _initialStatus;
    }
    filters.addAll(currentFilters);
    if (currentFilters.containsKey('status_ids') &&
        (currentFilters['status_ids'] as List).isEmpty) {
      filters.remove('status_name');
      _hasInitialStatusFilter = false;
      _initialStatus = null;
    }
    assignedWorkFuture = HttpService.getAssignedWorks(
            filters: filters,
            sectionId: widget.sectionId,
            unassigned: widget.isUnassigned)
        .then((assignedList) {
      int assignedByMeCount = assignedList.where((item) {
        return item.assignedBy.toLowerCase() == name?.toLowerCase();
      }).length;

      int assignedToMeCount = assignedList.where((item) {
        return item.assignedToId.toString() == userId.toString();
      }).length;

      int pendingCount = assignedList.where((item) {
        return item.status.toLowerCase() == 'pending';
      }).length;

      int todoCount = assignedList.where((item) {
        return item.status.toLowerCase() == 'to do';
      }).length;
      setState(() {
        _filterCounts = {
          'assignedByMe': assignedByMeCount,
          'assignedToMe': assignedToMeCount,
          'pending': pendingCount,
          'todo': todoCount,
          'all': assignedList.length,
        };
        _isCalculatingCounts = false;
      });
      List<AssignedWork> filteredList = assignedList;

      if (widget.workId.isNotEmpty && !_hasShownTaskDetails) {
        final AssignedWork matchedItem = filteredList.firstWhere(
          (item) => item.id.toString() == widget.workId,
          orElse: () => null as AssignedWork,
        );
        if (mounted) {
          _hasShownTaskDetails = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showTaskDetails(context, matchedItem);
          });
        }
      }

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      return filteredList;
    }).catchError((error) {
      debugPrint('Error loading assigned works: $error');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      return <AssignedWork>[];
    });
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _loadData(currentFilters);
      checkExistingWorkStatus();
      checkAssignedWorks();
    });
  }

  void _clearFilters() {
    setState(() {
      currentFilters.clear();
      _selectedFilters.clear();
      _hasInitialStatusFilter = false;
      _initialStatus = null;
      selectedStaffName = null;
      selectedStaffId = null;

      print('=== CLEAR FILTERS DEBUG ===');
      print('Cleared all filters and selections');
      print('Reset _hasInitialStatusFilter to: $_hasInitialStatusFilter');
      print('widget.selectedStatus: ${widget.selectedStatus}');
      _loadData(currentFilters);
    });
  }

  Future<void> checkExistingWorkStatus() async {
    final workStatusModel = await HttpService.getWorkStatus();
    setState(() {
      if (workStatusModel != null && workStatusModel.data.isNotEmpty) {
        existingWork = workStatusModel.data.first;
      } else {
        existingWork = null;
      }
    });
  }

  Future<void> checkAssignedWorks() async {
    final AssignedWorkModel =
        await HttpService.getAssinedWorkStatus(widget.workId, widget.sectionId);
    setState(() {
      if (AssignedWorkModel != null && AssignedWorkModel.data.isNotEmpty) {
        assignedWorks = AssignedWorkModel.data.first;
      } else {
        assignedWorks = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Assign Report",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: const Color.fromARGB(255, 77, 173, 252),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isMinimalView ? Icons.grid_view : Icons.view_list,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isMinimalView = !_isMinimalView;
                _cardMinimalViews.clear();
                if (!_isMinimalView) {
                  _expandedWorkSessions.clear();
                }
              });
            },
            tooltip: _isMinimalView ? 'Detailed View' : 'Minimal View',
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_alt_outlined),
                onPressed: _showFilters,
                tooltip: 'Filter',
              ),
              if (isFiltered)
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
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
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
                                // Clear staff filter when using "To Me" filter
                                selectedStaffName = null;
                                selectedStaffId = null;
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
                            backgroundColor:
                                _selectedFilters.contains('pending')
                                    ? Colors.blue
                                    : Colors.grey.shade300,
                            foregroundColor:
                                _selectedFilters.contains('pending')
                                    ? Colors.white
                                    : Colors.black,
                            minimumSize: const Size(0, 36),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          onPressed: () {
                            setState(() {
                              if (_selectedFilters.contains('pending')) {
                                _selectedFilters.remove('pending');
                                if (currentFilters
                                    .containsKey('status_names')) {
                                  List<String> names = List<String>.from(
                                      currentFilters['status_names']);
                                  names.remove('pending');
                                  if (names.isEmpty) {
                                    currentFilters.remove('status_names');
                                    currentFilters.remove('status_ids');
                                  } else {
                                    currentFilters['status_names'] = names;
                                    List<String> statusIds = [];
                                    if (names.contains('pending'))
                                      statusIds.add('2');
                                    if (names.contains('todo'))
                                      statusIds.add('1');
                                    currentFilters['status_ids'] = statusIds;
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
                                List<String> statusIds =
                                    currentFilters.containsKey('status_ids')
                                        ? List<String>.from(
                                            currentFilters['status_ids'])
                                        : [];
                                if (!statusIds.contains('2')) {
                                  statusIds.add('2');
                                }
                                currentFilters['status_ids'] = statusIds;
                              }
                              _loadData(currentFilters);
                            });
                          },
                          // onPressed: () {
                          //   setState(() {
                          //     if (_selectedFilters.contains('pending')) {
                          //       _selectedFilters.remove('pending');
                          //       if (currentFilters
                          //           .containsKey('status_names')) {
                          //         List<String> names = List<String>.from(
                          //             currentFilters['status_names']);
                          //         names.remove('pending');
                          //         if (names.isEmpty) {
                          //           currentFilters.remove('status_names');
                          //         } else {
                          //           currentFilters['status_names'] = names;
                          //         }
                          //       }
                          //     } else {
                          //       _selectedFilters.add('pending');
                          //       List<String> names =
                          //           currentFilters.containsKey('status_names')
                          //               ? List<String>.from(
                          //                   currentFilters['status_names'])
                          //               : [];
                          //       if (!names.contains('pending')) {
                          //         names.add('pending');
                          //       }
                          //       currentFilters['status_names'] = names;
                          //     }
                          //     _loadData(currentFilters);
                          //   });
                          // },
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
                                if (currentFilters
                                    .containsKey('status_names')) {
                                  List<String> names = List<String>.from(
                                      currentFilters['status_names']);
                                  names.remove('todo');
                                  if (names.isEmpty) {
                                    currentFilters.remove('status_names');
                                    currentFilters.remove('status_ids');
                                  } else {
                                    currentFilters['status_names'] = names;
                                    List<String> statusIds = [];
                                    if (names.contains('pending'))
                                      statusIds.add('2');
                                    if (names.contains('todo'))
                                      statusIds.add('1');
                                    currentFilters['status_ids'] = statusIds;
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
                                List<String> statusIds =
                                    currentFilters.containsKey('status_ids')
                                        ? List<String>.from(
                                            currentFilters['status_ids'])
                                        : [];
                                if (!statusIds.contains('1')) {
                                  statusIds.add('1');
                                }
                                currentFilters['status_ids'] = statusIds;
                              }
                              _loadData(currentFilters);
                            });
                          },
                          // onPressed: () {
                          //   setState(() {
                          //     if (_selectedFilters.contains('todo')) {
                          //       _selectedFilters.remove('todo');
                          //       if (currentFilters
                          //           .containsKey('status_names')) {
                          //         List<String> names = List<String>.from(
                          //             currentFilters['status_names']);
                          //         names.remove('todo');
                          //         if (names.isEmpty) {
                          //           currentFilters.remove('status_names');
                          //         } else {
                          //           currentFilters['status_names'] = names;
                          //         }
                          //       }
                          //     } else {
                          //       _selectedFilters.add('todo');
                          //       List<String> names =
                          //           currentFilters.containsKey('status_names')
                          //               ? List<String>.from(
                          //                   currentFilters['status_names'])
                          //               : [];
                          //       if (!names.contains('todo')) {
                          //         names.add('todo');
                          //       }
                          //       currentFilters['status_names'] = names;
                          //     }
                          //     _loadData(currentFilters);
                          //   });
                          // },
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
                    // const SizedBox(width: 8),
                    // Flexible(
                    //   child: SizedBox(
                    //     width: double.infinity,
                    //     child: ElevatedButton(
                    //       style: ElevatedButton.styleFrom(
                    //         backgroundColor:
                    //             _selectedFilters.contains('unassigned')
                    //                 ? Colors.blue
                    //                 : Colors.grey.shade300,
                    //         foregroundColor:
                    //             _selectedFilters.contains('unassigned')
                    //                 ? Colors.white
                    //                 : Colors.black,
                    //         minimumSize: const Size(0, 36),
                    //         padding: const EdgeInsets.symmetric(horizontal: 8),
                    //       ),
                    //       onPressed: () {
                    //         setState(() {
                    //           if (_selectedFilters.contains('unassigned')) {
                    //             _selectedFilters.remove('unassigned');
                    //             if (currentFilters
                    //                 .containsKey('status_names')) {
                    //               List<String> names = List<String>.from(
                    //                   currentFilters['status_names']);
                    //               names.remove('unassigned');
                    //               if (names.isEmpty) {
                    //                 currentFilters.remove('status_names');
                    //                 currentFilters.remove('status_ids');
                    //               } else {
                    //                 currentFilters['status_names'] = names;
                    //                 List<String> statusIds = List<String>.from(
                    //                     currentFilters['status_ids'] ?? []);
                    //                 statusIds.remove('0');
                    //                 currentFilters['status_ids'] = statusIds;
                    //               }
                    //             }
                    //           } else {
                    //             _selectedFilters.add('unassigned');
                    //             List<String> names =
                    //                 currentFilters.containsKey('status_names')
                    //                     ? List<String>.from(
                    //                         currentFilters['status_names'])
                    //                     : [];
                    //             if (!names.contains('unassigned')) {
                    //               names.add('unassigned');
                    //             }
                    //             currentFilters['status_names'] = names;
                    //             List<String> statusIds =
                    //                 currentFilters.containsKey('status_ids')
                    //                     ? List<String>.from(
                    //                         currentFilters['status_ids'])
                    //                     : [];
                    //             if (!statusIds.contains('0')) {
                    //               statusIds.add('0');
                    //             }
                    //             currentFilters['status_ids'] = statusIds;
                    //           }
                    //           _loadData(currentFilters);
                    //         });
                    //       },
                    //       child: const FittedBox(
                    //         fit: BoxFit.scaleDown,
                    //         child: Text(
                    //           'Unassigned',
                    //           style: TextStyle(fontSize: 12),
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                            selectedStaffId = null;
                            // Remove staff filter from currentFilters
                            currentFilters.remove('assigned_to_ids');
                          });
                          // Reload data without the staff filter
                          _loadData(currentFilters);
                        },
                      ),
                    ],
                  ),
                ),
              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: Row(
              //     children: [
              //       Flexible(
              //         child: SizedBox(
              //           width: double.infinity,
              //           child: ElevatedButton(
              //             style: ElevatedButton.styleFrom(
              //               backgroundColor:
              //                   _selectedFilters.contains('assignedByMe')
              //                       ? Colors.blue
              //                       : Colors.grey.shade300,
              //               foregroundColor:
              //                   _selectedFilters.contains('assignedByMe')
              //                       ? Colors.white
              //                       : Colors.black,
              //               minimumSize: const Size(0, 36),
              //               padding: const EdgeInsets.symmetric(horizontal: 8),
              //             ),
              //             onPressed: () {
              //               setState(() {
              //                 if (_selectedFilters.contains('assignedByMe')) {
              //                   _selectedFilters.remove('assignedByMe');
              //                   currentFilters.remove('assigned_by_ids');
              //                 } else {
              //                   _selectedFilters.add('assignedByMe');
              //                   if (userId != null) {
              //                     currentFilters['assigned_by_ids'] = [userId];
              //                   }
              //                 }
              //                 _loadData(currentFilters);
              //               });
              //             },
              //             child: const FittedBox(
              //               fit: BoxFit.scaleDown,
              //               child: Text(
              //                 'By Me',
              //                 style: TextStyle(fontSize: 12),
              //                 maxLines: 1,
              //                 overflow: TextOverflow.ellipsis,
              //               ),
              //             ),
              //           ),
              //         ),
              //       ),
              //       const SizedBox(width: 8),
              //       Flexible(
              //         child: SizedBox(
              //           width: double.infinity,
              //           child: ElevatedButton(
              //             style: ElevatedButton.styleFrom(
              //               backgroundColor:
              //                   _selectedFilters.contains('assignedToMe')
              //                       ? Colors.blue
              //                       : Colors.grey.shade300,
              //               foregroundColor:
              //                   _selectedFilters.contains('assignedToMe')
              //                       ? Colors.white
              //                       : Colors.black,
              //               minimumSize: const Size(0, 36),
              //               padding: const EdgeInsets.symmetric(horizontal: 8),
              //             ),
              //             onPressed: () {
              //               setState(() {
              //                 if (_selectedFilters.contains('assignedToMe')) {
              //                   _selectedFilters.remove('assignedToMe');
              //                   currentFilters.remove('assigned_to_ids');
              //                 } else {
              //                   _selectedFilters.add('assignedToMe');
              //                   if (userId != null) {
              //                     currentFilters['assigned_to_ids'] = [userId];
              //                   }
              //                 }
              //                 _loadData(currentFilters);
              //               });
              //             },
              //             child: const FittedBox(
              //               fit: BoxFit.scaleDown,
              //               child: Text(
              //                 'To Me',
              //                 style: TextStyle(fontSize: 12),
              //                 maxLines: 1,
              //                 overflow: TextOverflow.ellipsis,
              //               ),
              //             ),
              //           ),
              //         ),
              //       ),
              //       const SizedBox(width: 8),
              //       Flexible(
              //         child: SizedBox(
              //           width: double.infinity,
              //           child: ElevatedButton(
              //             style: ElevatedButton.styleFrom(
              //               backgroundColor:
              //                   _selectedFilters.contains('pending')
              //                       ? Colors.blue
              //                       : Colors.grey.shade300,
              //               foregroundColor:
              //                   _selectedFilters.contains('pending')
              //                       ? Colors.white
              //                       : Colors.black,
              //               minimumSize: const Size(0, 36),
              //               padding: const EdgeInsets.symmetric(horizontal: 8),
              //             ),
              //             onPressed: () {
              //               setState(() {
              //                 if (_selectedFilters.contains('pending')) {
              //                   _selectedFilters.remove('pending');
              //                   // Remove 'pending' from status_names list if present
              //                   if (currentFilters
              //                       .containsKey('status_names')) {
              //                     List<String> names = List<String>.from(
              //                         currentFilters['status_names']);
              //                     names.remove('pending');
              //                     if (names.isEmpty) {
              //                       currentFilters.remove('status_names');
              //                     } else {
              //                       currentFilters['status_names'] = names;
              //                     }
              //                   }
              //                 } else {
              //                   _selectedFilters.add('pending');
              //                   // Add 'pending' to status_names list or create it
              //                   List<String> names =
              //                       currentFilters.containsKey('status_names')
              //                           ? List<String>.from(
              //                               currentFilters['status_names'])
              //                           : [];
              //                   if (!names.contains('pending')) {
              //                     names.add('pending');
              //                   }
              //                   currentFilters['status_names'] = names;
              //                 }
              //                 _loadData(currentFilters);
              //               });
              //             },
              //             child: const FittedBox(
              //               fit: BoxFit.scaleDown,
              //               child: Text(
              //                 'Pending',
              //                 style: TextStyle(fontSize: 12),
              //               ),
              //             ),
              //           ),
              //         ),
              //       ),
              //       const SizedBox(width: 8),
              //       Flexible(
              //         child: SizedBox(
              //           width: double.infinity,
              //           child: ElevatedButton(
              //             style: ElevatedButton.styleFrom(
              //               backgroundColor: _selectedFilters.contains('todo')
              //                   ? Colors.blue
              //                   : Colors.grey.shade300,
              //               foregroundColor: _selectedFilters.contains('todo')
              //                   ? Colors.white
              //                   : Colors.black,
              //               minimumSize: const Size(0, 36),
              //               padding: const EdgeInsets.symmetric(horizontal: 8),
              //             ),
              //             onPressed: () {
              //               setState(() {
              //                 if (_selectedFilters.contains('todo')) {
              //                   _selectedFilters.remove('todo');
              //                   // Remove 'todo' from status_names list if present
              //                   if (currentFilters
              //                       .containsKey('status_names')) {
              //                     List<String> names = List<String>.from(
              //                         currentFilters['status_names']);
              //                     names.remove('todo');
              //                     if (names.isEmpty) {
              //                       currentFilters.remove('status_names');
              //                     } else {
              //                       currentFilters['status_names'] = names;
              //                     }
              //                   }
              //                 } else {
              //                   _selectedFilters.add('todo');
              //                   // Add 'todo' to status_names list or create it
              //                   List<String> names =
              //                       currentFilters.containsKey('status_names')
              //                           ? List<String>.from(
              //                               currentFilters['status_names'])
              //                           : [];
              //                   if (!names.contains('todo')) {
              //                     names.add('todo');
              //                   }
              //                   currentFilters['status_names'] = names;
              //                 }
              //                 _loadData(currentFilters);
              //               });
              //             },
              //             child: const FittedBox(
              //               fit: BoxFit.scaleDown,
              //               child: Text(
              //                 'To-Do',
              //                 style: TextStyle(fontSize: 12),
              //               ),
              //             ),
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              if (isFiltered)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    border: Border(
                      bottom:
                          BorderSide(color: Colors.orange.shade100, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.filter_alt,
                          size: 16, color: Colors.orange),
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
                  child: FutureBuilder<List<AssignedWork>>(
                    future: assignedWorkFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.blue),
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
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.assignment_outlined,
                                  size: 48, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(
                                isFiltered
                                    ? 'No matching assignments found'
                                    : 'No work assigned yet',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              if (isFiltered) ...[
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: _clearFilters,
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
                      final assignedItems = snapshot.data!;
                      return Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: assignedItems.length,
                              itemBuilder: (context, index) {
                                final item = assignedItems[index];
                                // Check if this card should use minimal view
                                final isCardMinimal =
                                    _cardMinimalViews[item.id.toString()] ??
                                        _isMinimalView;
                                return isCardMinimal
                                    ? _buildMinimalAssignmentCard(
                                        item, context, true)
                                    : _buildAssignmentCard(item, context, true);
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
        ],
      ),
      floatingActionButton: assignWork == "true"
          ? Padding(
              padding: const EdgeInsets.only(bottom: 48),
              child: FloatingActionButton(
                backgroundColor: Colors.blue,
                child: const Icon(Icons.add, color: Colors.white),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AssignWorkPage(
                        onSuccess: () {
                          setState(() {
                            checkExistingWorkStatus();
                          });
                        },
                      ),
                    ),
                  );
                  if (result == true) {
                    setState(() {
                      _loadData(currentFilters);
                      checkExistingWorkStatus();
                      checkAssignedWorks();
                    });
                  }
                },
              ),
            )
          : null,
    );
  }

  Widget _buildMinimalAssignmentCard(
      AssignedWork item, BuildContext context, bool showToggleButton) {
    final workSessions = item.workSessions;
    final isExpanded = _expandedWorkSessions[item.id.toString()] ?? false;
    final sessionsToShow = isExpanded || workSessions.length <= 3
        ? workSessions
        : workSessions.sublist(0, 3);

    return GestureDetector(
      onTap: () => _showTaskDetails(context, item),
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 16),
        color: item.status == "Completed"
            ? const Color.fromARGB(255, 238, 255, 234)
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: widget.workId == item.id.toString()
              ? () => _showTaskDetails(context, item)
              : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.clientName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.projectName,
                            style: TextStyle(
                              fontSize: 14,
                              color: const Color.fromARGB(255, 15, 15, 15),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                _getStatusColor(item.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _getStatusColor(item.status),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            item.status,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _getStatusColor(item.status),
                            ),
                          ),
                        ),
                        if (showToggleButton) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(
                              Icons.expand_more,
                              size: 20,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              setState(() {
                                _cardMinimalViews[item.id.toString()] = false;
                              });
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                            tooltip: 'Detailed View',
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Assigned by: ',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(
                              text: item.assignedBy,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(
                              text: '  →  ',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                            TextSpan(
                              text: 'Assigned to: ',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(
                              text: item.assignedTo,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (workSessions.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Work Sessions',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            if (workSessions.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${workSessions.length}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...sessionsToShow.map((session) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          session.taskName,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: _getStatusColor(
                                                        session.status)
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.circle,
                                                    size: 8,
                                                    color: _getStatusColor(
                                                        session.status),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    session.status,
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: _getStatusColor(
                                                          session.status),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (session
                                                .totalHours.isNotEmpty) ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.green.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.timer,
                                                      size: 11,
                                                      color:
                                                          Colors.green.shade700,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      session.totalHours,
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors
                                                            .green.shade700,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (session.lastUpdatedTime.isNotEmpty) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      session.lastUpdatedTime,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                        if (workSessions.length > 3 && !isExpanded) ...[
                          const SizedBox(height: 8),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  _expandedWorkSessions[item.id.toString()] =
                                      true;
                                });
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Load more (${workSessions.length - 3} more)',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.blue.shade800,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    size: 18,
                                    color: Colors.blue.shade800,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        if (isExpanded && workSessions.length > 3) ...[
                          const SizedBox(height: 8),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  _expandedWorkSessions[item.id.toString()] =
                                      false;
                                });
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Show less',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.blue.shade800,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_drop_up,
                                    size: 18,
                                    color: Colors.blue.shade800,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    if (name?.toLowerCase() == item.assignedTo.toLowerCase())
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: item.status == "Running"
                              ? const Color.fromARGB(255, 226, 180, 80)
                              : const Color.fromARGB(255, 32, 179, 67),
                          disabledBackgroundColor: const Color.fromARGB(
                              255, 236, 167, 18), // for null onPressed
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                        ),
                        onPressed: item.status == "Running"
                            ? null
                            : () => _handleStartWork(item),
                        child: Row(
                          children: [
                            Icon(
                              item.status == "Running"
                                  ? Icons.pause_circle_outline
                                  : Icons.play_circle_outline,
                              size: 16,
                              color: item.status == "Running"
                                  ? const Color.fromARGB(255, 106, 219, 61)
                                  : item.startStatus == "Started"
                                      ? const Color.fromARGB(255, 106, 219, 61)
                                      : const Color.fromARGB(255, 179, 32, 32),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item.status == "Running"
                                  ? "Working"
                                  : item.startStatus == "Started"
                                      ? "Restart"
                                      : "Start",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(width: 8),
                    Container(
                      width: 90,
                      height: 40,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.remove_red_eye, size: 16),
                        label: const Text(
                          "View",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade50,
                          foregroundColor: Colors.blue.shade800,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: Colors.blue.shade300,
                              width: 1.5,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          elevation: 0,
                          minimumSize: const Size(0, 32),
                        ),
                        onPressed: () => _showTaskDetails(context, item),
                      ),
                    ),

                    //  const SizedBox(width: 8),
                    // Stack(
                    //   clipBehavior: Clip.none,
                    //   children: [
                    //     IconButton(
                    //       icon: Icon(Icons.message,
                    //           color: const Color.fromARGB(255, 22, 182, 62)),
                    //       onPressed: () => Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //           builder: (context) => ChatScreenWork(
                    //             groupId: item.id.toString(),
                    //             nav: "",
                    //             assignedTo: item.assignedTo,
                    //             project: item.projectName,
                    //             assignedToId: item.assignedToId.toString(),
                    //           ),
                    //         ),
                    //       ),
                    //       style: IconButton.styleFrom(
                    //         backgroundColor: Colors.blue.shade50,
                    //         shape: RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.circular(8),
                    //           side: BorderSide(
                    //               color: const Color.fromARGB(255, 19, 175, 53)),
                    //         ),
                    //       ),
                    //     ),
                    //     item.unreadCount != "0"
                    //         ? Positioned(
                    //             top: -4,
                    //             right: -4,
                    //             child: Container(
                    //               padding: const EdgeInsets.all(4),
                    //               decoration: const BoxDecoration(
                    //                 color: Colors.red,
                    //                 shape: BoxShape.circle,
                    //               ),
                    //               constraints: const BoxConstraints(
                    //                 minWidth: 20,
                    //                 minHeight: 20,
                    //               ),
                    //               child: Text(
                    //                 item.unreadCount,
                    //                 style: const TextStyle(
                    //                   color: Colors.white,
                    //                   fontSize: 12,
                    //                   fontWeight: FontWeight.bold,
                    //                 ),
                    //                 textAlign: TextAlign.center,
                    //               ),
                    //             ),
                    //           )
                    //         : const SizedBox(),
                    //   ],
                    // ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notification_add,
                              color: Color.fromARGB(255, 146, 180, 20)),
                          onPressed: () => _showShareDialog(context, item),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.blue.shade50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(
                                  color: Color.fromARGB(255, 20, 212, 94)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color.fromARGB(255, 19, 175, 53),
                          ),
                        ),
                        child: const Icon(
                          Icons.more_vert,
                          color: Color.fromARGB(255, 22, 182, 62),
                          size: 20,
                        ),
                      ),
                      onSelected: (value) {
                        if (value == 'chat') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreenWork(
                                groupId: item.id.toString(),
                                nav: "",
                                assignedTo: item.assignedTo,
                                project: item.projectName,
                                assignedToId: item.assignedToId.toString(),
                              ),
                            ),
                          );
                        } else if (value == 'edit') {
                          _handleEditWork(item);
                        } else if (value == 'delete') {
                          _handleDeleteWork(item);
                        } else if (value == 'approve') {
                          _showApproveDialog(item);
                        } else if (value == 'publish') {
                          _showPublishDialog(item);
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'chat',
                          child: SizedBox(
                            width: 100, // Set your desired width here
                            child: Row(
                              children: [
                                const Icon(Icons.message,
                                    color: Colors.green, size: 20),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Chat',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                                if (item.unreadCount != "0" &&
                                    item.unreadCount != "0") ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      item.unreadCount,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const PopupMenuDivider(),
                        if (editAssignWork == "true") ...[
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: SizedBox(
                            width: 100,
                            child: Row(
                              children: [
                                const Icon(Icons.edit,
                                    color: Colors.blue, size: 20),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Edit',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        ],
                        const PopupMenuDivider(),
                        if (deleteAssignWork == "true") ...[
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: SizedBox(
                            width: 100, // Same width for consistency
                            child: Row(
                              children: [
                                const Icon(Icons.delete,
                                    color: Colors.red, size: 20),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        ],
                        if (item.status == "Approval Pending") ...[
                            const PopupMenuDivider(),
                            PopupMenuItem<String>(
                              value: 'approve',
                              child: SizedBox(
                                width: 120,
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.verified,
                                      color: Colors.orange,
                                      size: 20,
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Approve',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          if (item.status == "Approved") ...[
                            const PopupMenuDivider(),
                            PopupMenuItem<String>(
                              value: 'publish',
                              child: SizedBox(
                                width: 120,
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.publish,
                                      color: Colors.green,
                                      size: 20,
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Publish',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                      ],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      position: PopupMenuPosition.under,
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
Future<void> _showPublishDialog(dynamic item) async {
  final remarkController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          children: const [
            Icon(Icons.publish, color: Colors.green),
            SizedBox(width: 8),
            Text("Publish Work"),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Are you sure you want to publish this work?",
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: remarkController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Remark *",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Remark is required";
                  }
                  return null;
                },
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
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            child: const Text("Publish"),
          ),
        ],
      );
    },
  );

  if (confirm != true) return;

  await _publishWork(
    item,
    remarkController.text.trim(),
  );
}
  Widget _buildAssignmentCard(
      AssignedWork item, BuildContext context, bool showToggleButton) {
    return GestureDetector(
      onTap: () => _showTaskDetails(context, item),
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 16),
        color: item.status == "Completed"
            ? const Color.fromARGB(255, 238, 255, 234)
            : Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: const Color.fromARGB(255, 226, 216, 216))),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: widget.workId == item.id.toString()
              ? () => _showTaskDetails(context, item)
              : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.clientName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.projectName,
                            style: TextStyle(
                              fontSize: 14,
                              color: const Color.fromARGB(255, 15, 15, 15),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(item.priority)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _getPriorityColor(item.priority),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            _getPriorityText(item.priority),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _getPriorityColor(item.priority),
                            ),
                          ),
                        ),
                        if (showToggleButton) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(
                              Icons.expand_less,
                              size: 20,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              setState(() {
                                _cardMinimalViews[item.id.toString()] = true;
                              });
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                            tooltip: 'Minimal View',
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        Icons.person,
                        "Assigned by",
                        item.assignedBy,
                      ),
                    ),
                    if (name?.toLowerCase() == item.assignedTo.toLowerCase())
                      _buildStatusChip(item.status),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        Icons.person_outline,
                        "Assigned to",
                        item.assignedTo,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (item.dueDate.isNotEmpty)
                      Expanded(
                        child: _buildInfoRow(
                          Icons.calendar_today,
                          "Due date",
                          item.dueDate,
                        ),
                      ),
                  ],
                ),
                // Row(
                //   children: [
                //     Expanded(
                //       child: _buildInfoRow(
                //         Icons.star_outline_sharp,
                //         "Status",
                //         item.status,
                //       ),
                //     ),
                //   ],
                // ),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatusInfoRow(item),
                    ),
                  ],
                ),
                _buildCompletionWidget(item.completion),
                _buildInfoRow(Icons.work, "Work Status", item.startStatus),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (name?.toLowerCase() == item.assignedTo.toLowerCase())
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: item.startStatus == "Started"
                              ? const Color.fromARGB(255, 122, 121, 121)
                              : const Color.fromARGB(255, 32, 179, 67),
                          disabledBackgroundColor: const Color.fromARGB(
                              255, 236, 167, 18), // for null onPressed
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                        ),
                        onPressed: item.startStatus == "Started"
                            ? () => _handleStartWork(item)
                            : () => _handleStartWork(item),
                        child: Row(
                          children: [
                            Icon(
                              item.startStatus == "Started"
                                  ? Icons.stop_circle_outlined
                                  : Icons.play_circle_outline,
                              size: 16,
                              color: item.startStatus == "Not Started"
                                  ? Colors.white
                                  : const Color.fromARGB(255, 179, 32, 32),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item.startStatus == "Started"
                                  ? "Started"
                                  : "Start",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(width: 8),
                    Container(
                      width: 90,
                      height: 40,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.remove_red_eye, size: 16),
                        label: const Text(
                          "View",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade50,
                          foregroundColor: Colors.blue.shade800,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: Colors.blue.shade300,
                              width: 1.5, // thinner border
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6, // reduced height
                          ),
                          elevation: 0,
                          minimumSize:
                              const Size(0, 32), // control button height
                        ),
                        onPressed: () => _showTaskDetails(context, item),
                      ),
                    ),
                    // const SizedBox(width: 8),
                    // PopupMenuButton<String>(
                    //   icon: Container(
                    //     padding: const EdgeInsets.all(8),
                    //     decoration: BoxDecoration(
                    //       color: Colors.blue.shade50,
                    //       shape: BoxShape.circle,
                    //       border: Border.all(
                    //         color: const Color.fromARGB(255, 19, 175, 53),
                    //       ),
                    //     ),
                    //     child: const Icon(
                    //       Icons.more_vert,
                    //       color: Color.fromARGB(255, 22, 182, 62),
                    //       size: 20,
                    //     ),
                    //   ),
                    //   onSelected: (value) {
                    //     if (value == 'chat') {
                    //       Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //           builder: (context) => ChatScreenWork(
                    //             groupId: item.id.toString(),
                    //             nav: "",
                    //             assignedTo: item.assignedTo,
                    //             project: item.projectName,
                    //             assignedToId: item.assignedToId.toString(),
                    //           ),
                    //         ),
                    //       );
                    //     } else if (value == 'edit') {
                    //       _handleEditWork(item);
                    //     } else if (value == 'delete') {
                    //       _handleDeleteWork(item);
                    //     }
                    //   },
                    //   itemBuilder: (BuildContext context) =>
                    //       <PopupMenuEntry<String>>[
                    //     PopupMenuItem<String>(
                    //       value: 'chat',
                    //       child: SizedBox(
                    //         width: 200, // Set your desired width here
                    //         child: Row(
                    //           children: [
                    //             const Icon(Icons.message,
                    //                 color: Colors.green, size: 20),
                    //             const SizedBox(width: 12),
                    //             const Expanded(
                    //               child: Text(
                    //                 'Chat',
                    //                 style: TextStyle(fontSize: 14),
                    //               ),
                    //             ),
                    //             if (item.unreadCount != "0" &&
                    //                 item.unreadCount != "0") ...[
                    //               const SizedBox(width: 8),
                    //               Container(
                    //                 padding: const EdgeInsets.symmetric(
                    //                     horizontal: 6, vertical: 2),
                    //                 decoration: BoxDecoration(
                    //                   color: Colors.red,
                    //                   borderRadius: BorderRadius.circular(10),
                    //                 ),
                    //                 child: Text(
                    //                   item.unreadCount,
                    //                   style: const TextStyle(
                    //                     color: Colors.white,
                    //                     fontSize: 12,
                    //                     fontWeight: FontWeight.bold,
                    //                   ),
                    //                 ),
                    //               ),
                    //             ],
                    //           ],
                    //         ),
                    //       ),
                    //     ),
                    //     const PopupMenuDivider(),
                    //     PopupMenuItem<String>(
                    //       value: 'edit',
                    //       child: SizedBox(
                    //         width: 200, // Same width for consistency
                    //         child: Row(
                    //           children: [
                    //             const Icon(Icons.edit,
                    //                 color: Colors.blue, size: 20),
                    //             const SizedBox(width: 12),
                    //             const Expanded(
                    //               child: Text(
                    //                 'Edit',
                    //                 style: TextStyle(fontSize: 14),
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     ),
                    //     const PopupMenuDivider(),
                    //     PopupMenuItem<String>(
                    //       value: 'delete',
                    //       child: SizedBox(
                    //         width: 200, // Same width for consistency
                    //         child: Row(
                    //           children: [
                    //             const Icon(Icons.delete,
                    //                 color: Colors.red, size: 20),
                    //             const SizedBox(width: 12),
                    //             const Expanded(
                    //               child: Text(
                    //                 'Delete',
                    //                 style: TextStyle(fontSize: 14),
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    //   shape: RoundedRectangleBorder(
                    //     borderRadius: BorderRadius.circular(12),
                    //   ),
                    //   elevation: 4,
                    //   position: PopupMenuPosition.under,
                    // ),
                    // const SizedBox(width: 8),
                    // Stack(
                    //   clipBehavior: Clip.none,
                    //   children: [
                    //     IconButton(
                    //       icon: Icon(Icons.message,
                    //           color: const Color.fromARGB(255, 22, 182, 62)),
                    //       onPressed: () => Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //           builder: (context) => ChatScreenWork(
                    //             groupId: item.id.toString(),
                    //             nav: "",
                    //             assignedTo: item.assignedTo,
                    //             project: item.projectName,
                    //             assignedToId: item.assignedToId.toString(),
                    //           ),
                    //         ),
                    //       ),
                    //       style: IconButton.styleFrom(
                    //         backgroundColor: Colors.blue.shade50,
                    //         shape: RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.circular(8),
                    //           side: BorderSide(
                    //               color:
                    //                   const Color.fromARGB(255, 19, 175, 53)),
                    //         ),
                    //       ),
                    //     ),
                    //     item.unreadCount != "0"
                    //         ? Positioned(
                    //             top: -4,
                    //             right: -4,
                    //             child: Container(
                    //               padding: const EdgeInsets.all(4),
                    //               decoration: const BoxDecoration(
                    //                 color: Colors.red,
                    //                 shape: BoxShape.circle,
                    //               ),
                    //               constraints: const BoxConstraints(
                    //                 minWidth: 20,
                    //                 minHeight: 20,
                    //               ),
                    //               child: Text(
                    //                 item.unreadCount,
                    //                 style: const TextStyle(
                    //                   color: Colors.white,
                    //                   fontSize: 12,
                    //                   fontWeight: FontWeight.bold,
                    //                 ),
                    //                 textAlign: TextAlign.center,
                    //               ),
                    //             ),
                    //           )
                    //         : const SizedBox(),
                    //   ],
                    // ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notification_add,
                              color: Color.fromARGB(255, 146, 180, 20)),
                          onPressed: () => _showShareDialog(context, item),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.blue.shade50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(
                                  color: Color.fromARGB(255, 20, 212, 94)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color.fromARGB(255, 19, 175, 53),
                          ),
                        ),
                        child: const Icon(
                          Icons.more_vert,
                          color: Color.fromARGB(255, 22, 182, 62),
                          size: 20,
                        ),
                      ),
                      onSelected: (value) {
                        if (value == 'chat') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreenWork(
                                groupId: item.id.toString(),
                                nav: "",
                                assignedTo: item.assignedTo,
                                project: item.projectName,
                                assignedToId: item.assignedToId.toString(),
                              ),
                            ),
                          );
                        } else if (value == 'edit') {
                          _handleEditWork(item);
                        } else if (value == 'delete') {
                          _handleDeleteWork(item);
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'chat',
                          child: SizedBox(
                            width: 100, // Set your desired width here
                            child: Row(
                              children: [
                                const Icon(Icons.message,
                                    color: Colors.green, size: 20),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Chat',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                                if (item.unreadCount != "0" &&
                                    item.unreadCount != "0") ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      item.unreadCount,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const PopupMenuDivider(),
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: SizedBox(
                            width: 100, // Same width for consistency
                            child: Row(
                              children: [
                                const Icon(Icons.edit,
                                    color: Colors.blue, size: 20),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Edit',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const PopupMenuDivider(),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: SizedBox(
                            width: 100, // Same width for consistency
                            child: Row(
                              children: [
                                const Icon(Icons.delete,
                                    color: Colors.red, size: 20),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      position: PopupMenuPosition.under,
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

  Widget _buildStatusInfoRow(AssignedWork item) {
    bool isRunning = item.status.toLowerCase() == 'running';
    Widget statusWidget = Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isRunning ? Icons.run_circle_outlined : Icons.star_outline_sharp,
            size: 18,
            color: isRunning ? Colors.green : Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Text(
            "Status:",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              item.status,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isRunning ? Colors.green : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );

    if (isRunning) {
      return BlinkingWidget(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 47, 255, 54).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: const Color.fromARGB(255, 28, 248, 36).withOpacity(0.3)),
          ),
          child: statusWidget,
        ),
      );
    }

    return statusWidget;
  }

  Widget _buildCompletionWidget(String completion) {
    final parts = completion.split('/');
    int completed = int.tryParse(parts[0]) ?? 0;
    int total = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    double progress = total > 0 ? completed / total : 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Completion",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress == 1.0 ? Colors.green : Colors.blue,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 210),
          child: Text(
            "$completed of $total tasks",
            style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text("$label:",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(value,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getStatusColor(status), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 10, color: _getStatusColor(status)),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _getStatusColor(status),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleStartWork(AssignedWork item) async {
    if (!isLoggedIn) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Login Required'),
            content: const Text('Please login to start work.'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    final result = await HttpService.getWorkStatus();
    if (result != null && result.data.isNotEmpty) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Work in Progress"),
          content: const Text(
              "You already have a work in progress. Please complete it before starting a new one."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else if (item.startStatus == "Started") {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddWorkPage(
            workId: item.id,
            existingWork: null,
            isPaused: 0,
            Restart: 1,
            onSuccess: () {
              setState(() {
                checkExistingWorkStatus();
              });
            },
          ),
        ),
      );
      if (result == true) {
        _loadData(currentFilters);
        checkExistingWorkStatus();
        checkAssignedWorks();
      }
    } else {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddWorkPage(
            workId: item.id,
            existingWork: null,
            isPaused: 0,
            Restart: 0,
            isAssigned:1,
            onSuccess: () {
              setState(() {
                checkExistingWorkStatus();
              });
            },
          ),
        ),
      );
      if (result == true) {
        _loadData(currentFilters);
        checkExistingWorkStatus();
        checkAssignedWorks();
      }
    }
  }

  void _showTaskDetails(BuildContext context, AssignedWork item) {
    Map<String, bool> localExpandedSessions = {};
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Widget _buildLocalCompactWorkSession(WorkSession session) {
              final sessionKey = '${session.taskName}_${session.totalHours}';
              final isExpanded = localExpandedSessions[sessionKey] ?? false;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.task_alt,
                                    size: 18, color: Colors.blue),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '${session.taskName} ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (session.description.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            StatefulBuilder(
                              builder: (context, setState) {
                                final isExpanded = _expandedDescriptions[
                                        '${item.id}_${session.taskName}'] ??
                                    false;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _expandedDescriptions[
                                                  '${item.id}_${session.taskName}'] =
                                              !isExpanded;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: Colors.grey.shade300,
                                              width: 1),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Icon(
                                            //   isExpanded
                                            //       ? Icons.expand_more
                                            //       : Icons.chevron_right,
                                            //   size: 20,
                                            //   color: Colors.grey.shade600,
                                            // ),
                                            // const SizedBox(width: 8),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    session.description,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color:
                                                          Colors.grey.shade700,
                                                    ),
                                                    maxLines:
                                                        isExpanded ? null : 1,
                                                    overflow: isExpanded
                                                        ? null
                                                        : TextOverflow.ellipsis,
                                                  ),
                                                  if (!isExpanded &&
                                                      session.description
                                                              .length >
                                                          80)
                                                    const SizedBox(height: 4),
                                                  if (!isExpanded &&
                                                      session.description
                                                              .length >
                                                          80)
                                                    Text(
                                                      'View more',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors
                                                            .blue.shade600,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                            Icon(
                                              isExpanded
                                                  ? Icons.keyboard_arrow_up
                                                  : Icons.keyboard_arrow_down,
                                              size: 18,
                                              color: Colors.grey.shade600,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                          if (session.totalHours.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Total Hours:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    Text(
                                      '${session.totalHours}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: const Color.fromARGB(
                                            255, 19, 18, 18),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 41),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(session.status)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _getStatusColor(session.status)
                                          .withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.circle,
                                        size: 8,
                                        color: _getStatusColor(session.status),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        session.status,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              _getStatusColor(session.status),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ],
                          if (session.lastUpdatedTime.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  'Last Updated:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                Text(
                                  '${session.lastUpdatedTime}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: const Color.fromARGB(255, 8, 8, 8),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (session.attachments.isNotEmpty) ...[
                            const SizedBox(height: 12),

                            Text(
                              "Attachments",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),

                            const SizedBox(height: 8),

                            ...List.generate(session.attachments.length, (index) {
                              final attachment = session.attachments[index];

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.attach_file,
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),

                                    Expanded(
                                      child: InkWell(
                                        onTap: () => _openAttachment(attachment),
                                        child: Text(
                                          attachment.split('/').last,
                                          style: const TextStyle(
                                            color: Colors.blue,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ],
                      ),
                    ),

                    // Log count button (shows logs count and acts as expander)
                    if (session.works.isNotEmpty) ...[
                      GestureDetector(
                        onTap: () {
                          setSheetState(() {
                            if (isExpanded) {
                              localExpandedSessions.remove(sessionKey);
                            } else {
                              localExpandedSessions[sessionKey] = true;
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.list_alt,
                                    size: 18,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Timeline',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${session.count} Log${session.count != "1" ? "s" : ""}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue.shade800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    isExpanded
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                    color: Colors.grey.shade600,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Timeline section (only shown when expanded)
                      if (isExpanded) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 12),
                              ...session.works.map((work) {
                                return _buildCompactTimelineItem(work);
                              }),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
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

                  // Header with close button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.assignment,
                                  size: 24, color: Colors.blue),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.projectName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  item.createdAt,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.close, size: 20),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Colors.grey),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      _buildCompactDetailCard(
                                        icon: Icons.person,
                                        title: "Assigned To",
                                        value: item.assignedTo,
                                        color: Colors.blue,
                                      ),
                                      const SizedBox(height: 12),
                                      _buildCompactDetailCard(
                                        icon: Icons.flag,
                                        title: "Priority",
                                        value: _getPriorityText(item.priority),
                                        color: _getPriorityColor(item.priority),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    children: [
                                      _buildCompactDetailCard(
                                        icon: Icons.person_outline,
                                        title: "Assigned By",
                                        value: item.assignedBy,
                                        color: Colors.purple,
                                      ),
                                      const SizedBox(height: 12),
                                      _buildCompactDetailCard(
                                        icon: Icons.calendar_today,
                                        title: "Due Date",
                                        value: item.dueDate,
                                        color: Colors.orange,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
  child: Container(
    margin: const EdgeInsets.only(bottom: 20),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _getStatusColor(item.status).withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: _getStatusColor(item.status).withOpacity(0.3),
        width: 1,
      ),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          item.status == "Completed"
              ? Icons.check_circle
              : item.status == "To Do"
                  ? Icons.list_alt
                  : item.status == "Pending"
                      ? Icons.pending_actions
                      : item.status == "In-Progress"
                          ? Icons.timeline
                          : Icons.error_outline,
          color: _getStatusColor(item.status),
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Status",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Tooltip(
                message: item.status,
                child: Text(
                  item.status,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(item.status),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  ),
),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 20),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        color: Colors.grey.shade700,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Last Work Time",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            item.lastWorkTime ?? "--",
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey.shade800,
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
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      if (name != null &&
                                          token != null &&
                                          userId != null) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                CustomerDashboard(
                                              name: name!,
                                              token: token!,
                                              userId: userId!,
                                              phoneCallLogPermission:
                                                  phoneCallLogPermission,
                                              custId: item.clientId,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: _buildCompactDetailCard(
                                      icon: Icons.business,
                                      title: "Client",
                                      value: item.clientName,
                                      color: Colors.teal,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildCompactDetailCard(
                                    icon: Icons.widgets,
                                    title: "Module",
                                    value: item.moduleName,
                                    color: Colors.indigo,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (item.workSessions.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            const Text(
                              "Work Sessions",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...item.workSessions.map((session) {
                              return _buildLocalCompactWorkSession(session);
                            }),
                          ] else ...[
                            Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.hourglass_empty,
                                      size: 40, color: Colors.grey.shade400),
                                  const SizedBox(height: 8),
                                  Text(
                                    "No work sessions recorded",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (item
                              .notification.participantNames.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            const Text(
                              "Chat Participants",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: item.notification.participantNames
                                  .map((name) {
                                return Chip(
                                  label: Text(name),
                                  backgroundColor: Colors.blue.shade50,
                                  side: BorderSide(color: Colors.blue.shade100),
                                  avatar: const Icon(Icons.person, size: 16),
                                );
                              }).toList(),
                            ),
                          ],
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  if (item.status == "Approval Pending" ||
                      item.status == "Approved")
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(color: Colors.grey.shade200),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        child: SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              if (item.status == "Approval Pending") {
                                Navigator.pop(context);
                                _showApproveDialog(item);
                              } else if (item.status == "Approved") {
                                Navigator.pop(context);
                                _showPublishDialog(item);
                              }
                            },
                            icon: Icon(
                              item.status == "Approval Pending"
                                  ? Icons.verified
                                  : Icons.publish,
                              color: Colors.white,
                            ),
                            label: Text(
                              item.status == "Approval Pending"
                                  ? "Approve Work"
                                  : "Publish Work",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: item.status == "Approval Pending"
                                  ? Colors.orange
                                  : Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
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

  // void _showTaskDetails(BuildContext context, AssignedWork item) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (context) {
  //       return Container(
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
  //           boxShadow: [
  //             BoxShadow(
  //               color: Colors.black.withOpacity(0.1),
  //               blurRadius: 20,
  //               offset: const Offset(0, -5),
  //             ),
  //           ],
  //         ),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             // Drag handle
  //             Container(
  //               padding: const EdgeInsets.only(top: 12, bottom: 8),
  //               child: Container(
  //                 width: 40,
  //                 height: 4,
  //                 decoration: BoxDecoration(
  //                   color: Colors.grey.shade400,
  //                   borderRadius: BorderRadius.circular(2),
  //                 ),
  //               ),
  //             ),

  //             // Header with close button
  //             Padding(
  //               padding:
  //                   const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Row(
  //                     children: [
  //                       Container(
  //                         padding: const EdgeInsets.all(8),
  //                         decoration: BoxDecoration(
  //                           color: Colors.blue.shade50,
  //                           borderRadius: BorderRadius.circular(10),
  //                         ),
  //                         child: const Icon(Icons.assignment,
  //                             size: 24, color: Colors.blue),
  //                       ),
  //                       const SizedBox(width: 12),
  //                       Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           Text(
  //                             item.projectName,
  //                             style: const TextStyle(
  //                               fontSize: 18,
  //                               fontWeight: FontWeight.w700,
  //                               color: Colors.black87,
  //                             ),
  //                           ),
  //                           Text(
  //                             item.createdAt,
  //                             style: TextStyle(
  //                               fontSize: 14,
  //                               color: Colors.grey.shade600,
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ],
  //                   ),
  //                   IconButton(
  //                     icon: Container(
  //                       padding: const EdgeInsets.all(6),
  //                       decoration: BoxDecoration(
  //                         color: Colors.grey.shade100,
  //                         borderRadius: BorderRadius.circular(10),
  //                       ),
  //                       child: const Icon(Icons.close, size: 20),
  //                     ),
  //                     onPressed: () => Navigator.pop(context),
  //                   ),
  //                 ],
  //               ),
  //             ),

  //             const Divider(height: 1, color: Colors.grey),

  //             // Main content - optimized for single screen
  //             Expanded(
  //               child: SingleChildScrollView(
  //                 padding: const EdgeInsets.all(20),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     // Quick stats in 2 columns
  //                     Container(
  //                       margin: const EdgeInsets.only(bottom: 20),
  //                       child: Row(
  //                         children: [
  //                           // Left column
  //                           Expanded(
  //                             child: Column(
  //                               children: [
  //                                 _buildCompactDetailCard(
  //                                   icon: Icons.person,
  //                                   title: "Assigned To",
  //                                   value: item.assignedTo,
  //                                   color: Colors.blue,
  //                                 ),
  //                                 const SizedBox(height: 12),
  //                                 _buildCompactDetailCard(
  //                                   icon: Icons.flag,
  //                                   title: "Priority",
  //                                   value: _getPriorityText(item.priority),
  //                                   color: _getPriorityColor(item.priority),
  //                                 ),
  //                               ],
  //                             ),
  //                           ),

  //                           const SizedBox(width: 12),

  //                           // Right column
  //                           Expanded(
  //                             child: Column(
  //                               children: [
  //                                 _buildCompactDetailCard(
  //                                   icon: Icons.person_outline,
  //                                   title: "Assigned By",
  //                                   value: item.assignedBy,
  //                                   color: Colors.purple,
  //                                 ),
  //                                 const SizedBox(height: 12),
  //                                 _buildCompactDetailCard(
  //                                   icon: Icons.calendar_today,
  //                                   title: "Due Date",
  //                                   value: item.dueDate,
  //                                   color: Colors.orange,
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),

  //                     Row(
  //                       children: [
  //                         Expanded(
  //                           child: Container(
  //                             margin: const EdgeInsets.only(bottom: 20),
  //                             padding: const EdgeInsets.all(16),
  //                             decoration: BoxDecoration(
  //                               color: _getStatusColor(item.status)
  //                                   .withOpacity(0.1),
  //                               borderRadius: BorderRadius.circular(12),
  //                               border: Border.all(
  //                                 color: _getStatusColor(item.status)
  //                                     .withOpacity(0.3),
  //                                 width: 1,
  //                               ),
  //                             ),
  //                             child: Row(
  //                               children: [
  //                                 Icon(
  //                                   item.status == "Completed"
  //                                       ? Icons.check_circle
  //                                       : item.status == "To Do"
  //                                           ? Icons.list_alt
  //                                           : item.status == "Pending"
  //                                               ? Icons.pending_actions
  //                                               : item.status == "In-Progress"
  //                                                   ? Icons.timeline
  //                                                   : Icons.error_outline,
  //                                   color: _getStatusColor(item.status),
  //                                   size: 24,
  //                                 ),
  //                                 const SizedBox(width: 12),
  //                                 Column(
  //                                   crossAxisAlignment:
  //                                       CrossAxisAlignment.start,
  //                                   children: [
  //                                     Text(
  //                                       "Status",
  //                                       style: TextStyle(
  //                                         fontSize: 12,
  //                                         color: Colors.grey.shade600,
  //                                       ),
  //                                     ),
  //                                     Text(
  //                                       item.status,
  //                                       style: TextStyle(
  //                                         fontSize: 16,
  //                                         fontWeight: FontWeight.w600,
  //                                         color: _getStatusColor(item.status),
  //                                       ),
  //                                     ),
  //                                   ],
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                         ),

  //                         const SizedBox(width: 12),

  //                         // LAST WORK TIME
  //                         Expanded(
  //                           child: Container(
  //                             margin: const EdgeInsets.only(bottom: 20),
  //                             padding: const EdgeInsets.all(16),
  //                             decoration: BoxDecoration(
  //                               color: Colors.grey.shade100,
  //                               borderRadius: BorderRadius.circular(12),
  //                               border: Border.all(
  //                                 color: Colors.grey.shade300,
  //                                 width: 1,
  //                               ),
  //                             ),
  //                             child: Row(
  //                               children: [
  //                                 Icon(
  //                                   Icons.access_time,
  //                                   color: Colors.grey.shade700,
  //                                   size: 24,
  //                                 ),
  //                                 const SizedBox(width: 12),
  //                                 Column(
  //                                   crossAxisAlignment:
  //                                       CrossAxisAlignment.start,
  //                                   children: [
  //                                     Text(
  //                                       "Last Work Time",
  //                                       style: TextStyle(
  //                                         fontSize: 12,
  //                                         color: Colors.grey.shade600,
  //                                       ),
  //                                     ),
  //                                     const SizedBox(height: 4),
  //                                     Text(
  //                                       item.lastWorkTime ?? "--",
  //                                       style: TextStyle(
  //                                         fontSize: 11,
  //                                         fontWeight: FontWeight.w600,
  //                                         color: Colors.grey.shade800,
  //                                       ),
  //                                     ),
  //                                   ],
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),

  //                     // Client and Module in row - FIXED SECTION
  //                     Container(
  //                       margin: const EdgeInsets.only(bottom: 20),
  //                       child: Row(
  //                         children: [
  //                           // Client card with tap functionality
  //                           Expanded(
  //                             child: GestureDetector(
  //                               onTap: () {
  //                                 if (name != null &&
  //                                     token != null &&
  //                                     userId != null) {
  //                                   Navigator.push(
  //                                     context,
  //                                     MaterialPageRoute(
  //                                       builder: (context) => CustomerDashboard(
  //                                         name: name!,
  //                                         token: token!,
  //                                         userId: userId!,
  //                                         phoneCallLogPermission:
  //                                             phoneCallLogPermission,
  //                                         custId: item.clientId,
  //                                       ),
  //                                     ),
  //                                   );
  //                                 }
  //                               },
  //                               child: _buildCompactDetailCard(
  //                                 icon: Icons.business,
  //                                 title: "Client",
  //                                 value: item.clientName,
  //                                 color: Colors.teal,
  //                               ),
  //                             ),
  //                           ),
  //                           const SizedBox(width: 12),
  //                           // Module card
  //                           Expanded(
  //                             child: _buildCompactDetailCard(
  //                               icon: Icons.widgets,
  //                               title: "Module",
  //                               value: item.moduleName,
  //                               color: Colors.indigo,
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),

  //                     if (item.workSessions.isNotEmpty) ...[
  //                       const SizedBox(height: 8),
  //                       const Text(
  //                         "Work Sessions",
  //                         style: TextStyle(
  //                           fontSize: 16,
  //                           fontWeight: FontWeight.w700,
  //                           color: Colors.black87,
  //                         ),
  //                       ),
  //                       const SizedBox(height: 12),
  //                       ...item.workSessions.map((session) {
  //                         return _buildCompactWorkSession(session);
  //                       }),
  //                     ] else ...[
  //                       Container(
  //                         margin: const EdgeInsets.only(bottom: 20),
  //                         padding: const EdgeInsets.all(20),
  //                         decoration: BoxDecoration(
  //                           color: Colors.grey.shade50,
  //                           borderRadius: BorderRadius.circular(12),
  //                         ),
  //                         child: Column(
  //                           children: [
  //                             Icon(Icons.hourglass_empty,
  //                                 size: 40, color: Colors.grey.shade400),
  //                             const SizedBox(height: 8),
  //                             Text(
  //                               "No work sessions recorded",
  //                               style: TextStyle(
  //                                 color: Colors.grey.shade600,
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ],

  //                     // Participants section
  //                     if (item.notification.participantNames.isNotEmpty) ...[
  //                       const SizedBox(height: 8),
  //                       const Text(
  //                         "Chat Participants",
  //                         style: TextStyle(
  //                           fontSize: 16,
  //                           fontWeight: FontWeight.w700,
  //                           color: Colors.black87,
  //                         ),
  //                       ),
  //                       const SizedBox(height: 12),
  //                       Wrap(
  //                         spacing: 8,
  //                         runSpacing: 8,
  //                         children:
  //                             item.notification.participantNames.map((name) {
  //                           return Chip(
  //                             label: Text(name),
  //                             backgroundColor: Colors.blue.shade50,
  //                             side: BorderSide(color: Colors.blue.shade100),
  //                             avatar: const Icon(Icons.person, size: 16),
  //                           );
  //                         }).toList(),
  //                       ),
  //                     ],

  //                     const SizedBox(height: 20),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

// Helper widget for compact detail cards
  Widget _buildCompactDetailCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactWorkSession(WorkSession session) {
    final sessionKey = '${session.taskName}_${session.totalHours}';
    final isExpanded = _expandedTimelineSessions[sessionKey] ?? false;

    // Determine how many items to show
    final worksToShow = isExpanded || session.works.length <= 5
        ? session.works
        : session.works.sublist(0, 5);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Session header (unchanged)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.task_alt,
                          size: 18, color: Colors.blue),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${session.taskName} ',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                if (session.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    session.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (session.totalHours.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Total Hours:',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          Text(
                            '${session.totalHours}',
                            style: TextStyle(
                              fontSize: 13,
                              color: const Color.fromARGB(255, 19, 18, 18),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 41),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color:
                              _getStatusColor(session.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getStatusColor(session.status)
                                .withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.circle,
                              size: 8,
                              color: _getStatusColor(session.status),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              session.status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _getStatusColor(session.status),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
                if (session.lastUpdatedTime.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Last Updated:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        '${session.lastUpdatedTime}',
                        style: TextStyle(
                          fontSize: 13,
                          color: const Color.fromARGB(255, 8, 8, 8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          if (session.works.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Timeline',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(width: 175),
                      Text(
                        '${session.count} Log',
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Show timeline items (limited to 5 if not expanded)
                  ...worksToShow.map((work) {
                    return _buildCompactTimelineItem(work);
                  }),

                  // Show "Show More/Less" button if there are more than 5 items
                  if (session.works.length > 5) ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isExpanded) {
                              _expandedTimelineSessions.remove(sessionKey);
                            } else {
                              _expandedTimelineSessions[sessionKey] = true;
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.blue.shade200,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isExpanded
                                    ? 'Show Less'
                                    : 'Show More (${session.works.length - 5} more)',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                isExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                size: 16,
                                color: Colors.blue.shade800,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
  // Widget _buildCompactWorkSession(WorkSession session) {
  //   return Container(
  //     margin: const EdgeInsets.only(bottom: 12),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(color: Colors.grey.shade200, width: 1),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.05),
  //           blurRadius: 4,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         // Session header
  //         Padding(
  //           padding: const EdgeInsets.all(16),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Row(
  //                 children: [
  //                   Container(
  //                     padding: const EdgeInsets.all(6),
  //                     decoration: BoxDecoration(
  //                       color: Colors.blue.shade50,
  //                       borderRadius: BorderRadius.circular(8),
  //                     ),
  //                     child: const Icon(Icons.task_alt,
  //                         size: 18, color: Colors.blue),
  //                   ),
  //                   const SizedBox(width: 10),
  //                   Expanded(
  //                     child: Text(
  //                       '${session.taskName} ',
  //                       style: const TextStyle(
  //                         fontWeight: FontWeight.w600,
  //                         fontSize: 15,
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //               if (session.description.isNotEmpty) ...[
  //                 const SizedBox(height: 8),
  //                 Text(
  //                   session.description,
  //                   style: TextStyle(
  //                     fontSize: 13,
  //                     color: Colors.grey.shade700,
  //                   ),
  //                   maxLines: 2,
  //                   overflow: TextOverflow.ellipsis,
  //                 ),
  //               ],
  //               if (session.totalHours.isNotEmpty) ...[
  //                 const SizedBox(height: 8),
  //                 Row(
  //                   children: [
  //                     Row(
  //                       children: [
  //                         Text(
  //                           'Total Hours:',
  //                           style: TextStyle(
  //                             fontSize: 14,
  //                             color: Colors.grey.shade700,
  //                           ),
  //                         ),
  //                         Text(
  //                           '${session.totalHours}',
  //                           style: TextStyle(
  //                             fontSize: 13,
  //                             color: const Color.fromARGB(255, 19, 18, 18),
  //                             fontWeight: FontWeight.w600,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                     const SizedBox(width: 41),
  //                     Container(
  //                       padding: const EdgeInsets.symmetric(
  //                           horizontal: 8, vertical: 4),
  //                       decoration: BoxDecoration(
  //                         color:
  //                             _getStatusColor(session.status).withOpacity(0.1),
  //                         borderRadius: BorderRadius.circular(12),
  //                         border: Border.all(
  //                           color: _getStatusColor(session.status)
  //                               .withOpacity(0.3),
  //                           width: 1,
  //                         ),
  //                       ),
  //                       child: Row(
  //                         mainAxisSize: MainAxisSize.min,
  //                         children: [
  //                           Icon(
  //                             Icons.circle,
  //                             size: 8,
  //                             color: _getStatusColor(session.status),
  //                           ),
  //                           const SizedBox(width: 6),
  //                           Text(
  //                             session.status,
  //                             style: TextStyle(
  //                               fontSize: 11,
  //                               fontWeight: FontWeight.w600,
  //                               color: _getStatusColor(session.status),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ],
  //                 )
  //               ],
  //               if (session.lastUpdatedTime.isNotEmpty) ...[
  //                 const SizedBox(height: 8),
  //                 Row(
  //                   children: [
  //                     Text(
  //                       'Last Updated:',
  //                       style: TextStyle(
  //                         fontSize: 14,
  //                         color: Colors.grey.shade700,
  //                       ),
  //                     ),
  //                     Text(
  //                       '${session.lastUpdatedTime}',
  //                       style: TextStyle(
  //                         fontSize: 13,
  //                         color: const Color.fromARGB(255, 8, 8, 8),
  //                         fontWeight: FontWeight.w600,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ],
  //           ),
  //         ),

  //         if (session.works.isNotEmpty) ...[
  //           Container(
  //             padding: const EdgeInsets.all(16),
  //             decoration: BoxDecoration(
  //               color: Colors.grey.shade50,
  //               borderRadius: const BorderRadius.only(
  //                 bottomLeft: Radius.circular(12),
  //                 bottomRight: Radius.circular(12),
  //               ),
  //             ),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Row(
  //                   children: [
  //                     Text(
  //                       'Timeline',
  //                       style: TextStyle(
  //                         fontSize: 14,
  //                         fontWeight: FontWeight.w600,
  //                         color: Colors.grey.shade700,
  //                       ),
  //                     ),
  //                     const SizedBox(width: 175),
  //                     Text(
  //                       '${session.count} Log',
  //                       style: TextStyle(
  //                           fontSize: 13,
  //                           color: Colors.grey.shade600,
  //                           fontWeight: FontWeight.bold),
  //                     ),
  //                   ],
  //                 ),
  //                 const SizedBox(height: 12),
  //                 ...session.works.map((work) {
  //                   return _buildCompactTimelineItem(work);
  //                 }),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ],
  //     ),
  //   );
  // }

  Widget _buildCompactTimelineItem(Work work) {
    String formatDate(String datetime) {
      try {
        final dateTime = DateTime.tryParse(datetime);
        if (dateTime != null) {
          return DateFormat('dd MMM yyyy').format(dateTime);
        }
        return datetime;
      } catch (e) {
        return datetime;
      }
    }

    String formatTime(String datetime) {
      try {
        final dateTime = DateTime.tryParse(datetime);
        if (dateTime != null) {
          return DateFormat('hh:mm a').format(dateTime);
        }
        return datetime;
      } catch (e) {
        return datetime;
      }
    }

    String formatDuration(String duration) {
      if (duration.contains(':')) {
        final parts = duration.split(':');
        if (parts.length == 3) {
          int hours = int.tryParse(parts[0]) ?? 0;
          int minutes = int.tryParse(parts[1]) ?? 0;
          if (hours > 0) {
            return '${hours}h ${minutes}m';
          }
          return '${minutes}m';
        }
      }
      return duration;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              Container(
                width: 2,
                height: 40,
                margin: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 12, color: Colors.blue),
                          const SizedBox(width: 4),
                          Text(
                            formatDate(work.workedDate),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    //  const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 216, 201, 175),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          // const Icon(Icons.lock_clock,
                          //     size: 9,
                          //     color: Color.fromARGB(255, 151, 137, 137)),
                          // const SizedBox(width: 4),
                          Text(
                            "${formatTime(work.startTime)} - ${formatTime(work.endTime)}",
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: const Color.fromARGB(255, 143, 133, 133),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.timer,
                              size: 12, color: Colors.orange),
                          const SizedBox(width: 4),
                          Text(
                            formatDuration(work.duration),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // const SizedBox(height: 8),
                // Row(
                //   children: [
                //     Container(
                //       padding: const EdgeInsets.symmetric(
                //           horizontal: 9, vertical: 3),
                //       decoration: BoxDecoration(
                //         color: const Color.fromARGB(255, 216, 201, 175),
                //         borderRadius: BorderRadius.circular(8),
                //       ),
                //       child: Row(
                //         children: [
                //           const Icon(Icons.lock_clock,
                //               size: 12,
                //               color: Color.fromARGB(255, 151, 137, 137)),
                //           const SizedBox(width: 4),
                //           Text(
                //             "${formatTime(work.startTime)} - ${formatTime(work.endTime)}",
                //             style: TextStyle(
                //               fontSize: 11,
                //               fontWeight: FontWeight.w600,
                //               color: const Color.fromARGB(255, 143, 133, 133),
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ],
                // ),

                // Remarks section - Always show all remarks
                if (work.remarks.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 237, 253, 227),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Remarks header with icon
                        // Row(
                        //   children: [
                        //     Icon(
                        //       Icons.note,
                        //       size: 14,
                        //       color: const Color.fromARGB(255, 208, 33, 243),
                        //     ),
                        //     const SizedBox(width: 6),
                        //     Text(
                        //       'Remarks (${work.remarks.length}):',
                        //       style: TextStyle(
                        //         fontSize: 12,
                        //         fontWeight: FontWeight.w600,
                        //         color: const Color.fromARGB(255, 208, 33, 243),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // const SizedBox(height: 6),
                        // List all remarks
                        ...work.remarks.asMap().entries.map((entry) {
                          final index = entry.key;
                          final remark = entry.value;
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index == work.remarks.length - 1 ? 0 : 6,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${index + 1}.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        const Color.fromARGB(255, 19, 19, 19),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    remark,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: const Color.fromARGB(255, 7, 7, 7),
                                      fontWeight: FontWeight.w500,
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
                ],

                // Attachments section
                if (work.logAttachments.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.attach_file,
                                size: 13, color: Colors.blue.shade700),
                            const SizedBox(width: 4),
                            Text(
                              'Attachments (${work.logAttachments.length})',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.blue.shade800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ...work.logAttachments.asMap().entries.map((entry) {
                          final url = entry.value;
                          // Extract a short display name from the URL
                          final uri = Uri.tryParse(url);
                          String displayName = uri?.pathSegments.isNotEmpty == true
                              ? uri!.pathSegments.last
                              : 'Attachment ${entry.key + 1}';
                          if (displayName.isEmpty) {
                            displayName = 'Attachment ${entry.key + 1}';
                          }

                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: entry.key == work.logAttachments.length - 1
                                  ? 0
                                  : 6,
                            ),
                            child: InkWell(
                              onTap: () => _openAttachment(url),
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border:
                                      Border.all(color: Colors.blue.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.insert_drive_file_rounded,
                                      size: 16,
                                      color: Colors.blue.shade600,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        displayName,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      Icons.open_in_new_rounded,
                                      size: 14,
                                      color: Colors.blue.shade400,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildCompactTimelineItem(Work work) {
  //   String formatDate(String datetime) {
  //     try {
  //       final dateTime = DateTime.tryParse(datetime);
  //       if (dateTime != null) {
  //         return DateFormat('dd MMM yyyy').format(dateTime);
  //       }
  //       return datetime;
  //     } catch (e) {
  //       return datetime;
  //     }
  //   }

  //   String formatTime(String datetime) {
  //     try {
  //       final dateTime = DateTime.tryParse(datetime);
  //       if (dateTime != null) {
  //         return DateFormat('hh:mm a').format(dateTime);
  //       }
  //       return datetime;
  //     } catch (e) {
  //       return datetime;
  //     }
  //   }

  //   String formatDuration(String duration) {
  //     if (duration.contains(':')) {
  //       final parts = duration.split(':');
  //       if (parts.length == 3) {
  //         int hours = int.tryParse(parts[0]) ?? 0;
  //         int minutes = int.tryParse(parts[1]) ?? 0;
  //         if (hours > 0) {
  //           return '${hours}h ${minutes}m';
  //         }
  //         return '${minutes}m';
  //       }
  //     }
  //     return duration;
  //   }

  //   return Container(
  //     margin: const EdgeInsets.only(bottom: 12),
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Column(
  //           children: [
  //             Container(
  //               width: 12,
  //               height: 12,
  //               decoration: BoxDecoration(
  //                 color: Colors.green,
  //                 shape: BoxShape.circle,
  //                 border: Border.all(color: Colors.white, width: 2),
  //                 boxShadow: [
  //                   BoxShadow(
  //                     color: Colors.green.withOpacity(0.3),
  //                     blurRadius: 4,
  //                     offset: const Offset(0, 2),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             Container(
  //               width: 2,
  //               height: 40,
  //               margin: const EdgeInsets.symmetric(vertical: 2),
  //               decoration: BoxDecoration(
  //                 color: Colors.grey.shade300,
  //                 borderRadius: BorderRadius.circular(1),
  //               ),
  //             ),
  //             Container(
  //               width: 12,
  //               height: 12,
  //               decoration: BoxDecoration(
  //                 color: Colors.red,
  //                 shape: BoxShape.circle,
  //                 border: Border.all(color: Colors.white, width: 2),
  //                 boxShadow: [
  //                   BoxShadow(
  //                     color: Colors.red.withOpacity(0.3),
  //                     blurRadius: 4,
  //                     offset: const Offset(0, 2),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),

  //         const SizedBox(width: 12),

  //         // Content
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               // Date row
  //               Row(
  //                 children: [
  //                   Container(
  //                     padding: const EdgeInsets.symmetric(
  //                         horizontal: 10, vertical: 4),
  //                     decoration: BoxDecoration(
  //                       color: Colors.blue.shade50,
  //                       borderRadius: BorderRadius.circular(8),
  //                     ),
  //                     child: Row(
  //                       children: [
  //                         const Icon(Icons.calendar_today,
  //                             size: 12, color: Colors.blue),
  //                         const SizedBox(width: 4),
  //                         Text(
  //                           formatDate(work.workedDate),
  //                           style: TextStyle(
  //                             fontSize: 11,
  //                             fontWeight: FontWeight.w600,
  //                             color: Colors.blue.shade800,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                   const Spacer(),
  //                   Container(
  //                     padding: const EdgeInsets.symmetric(
  //                         horizontal: 10, vertical: 4),
  //                     decoration: BoxDecoration(
  //                       color: Colors.orange.shade50,
  //                       borderRadius: BorderRadius.circular(8),
  //                     ),
  //                     child: Row(
  //                       children: [
  //                         const Icon(Icons.timer,
  //                             size: 12, color: Colors.orange),
  //                         const SizedBox(width: 4),
  //                         Text(
  //                           formatDuration(work.duration),
  //                           style: TextStyle(
  //                             fontSize: 11,
  //                             fontWeight: FontWeight.w600,
  //                             color: Colors.orange.shade800,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               ),

  //               const SizedBox(height: 8),
  //               Row(
  //                 children: [
  //                   Container(
  //                     padding: const EdgeInsets.symmetric(
  //                         horizontal: 9, vertical: 3),
  //                     decoration: BoxDecoration(
  //                       color: const Color.fromARGB(255, 216, 201, 175),
  //                       borderRadius: BorderRadius.circular(8),
  //                     ),
  //                     child: Row(
  //                       children: [
  //                         const Icon(Icons.lock_clock,
  //                             size: 12,
  //                             color: const Color.fromARGB(255, 151, 137, 137)),
  //                         const SizedBox(width: 4),
  //                         Text(
  //                           "${formatTime(work.startTime)} - ${formatTime(work.endTime)}",
  //                           style: TextStyle(
  //                             fontSize: 11,
  //                             fontWeight: FontWeight.w600,
  //                             color: const Color.fromARGB(255, 143, 133, 133),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               ),

  //               const SizedBox(height: 8),
  //               // if (work.remarks.isNotEmpty)
  //               //   InkWell(
  //               //     onTap: work.remarks.length > 1
  //               //         ? () {
  //               //             // Show popup with all remarks
  //               //             showDialog(
  //               //               context: context,
  //               //               builder: (context) => AlertDialog(
  //               //                 title: const Text("Remarks"),
  //               //                 content: SingleChildScrollView(
  //               //                   child: Column(
  //               //                     mainAxisSize: MainAxisSize.min,
  //               //                     crossAxisAlignment:
  //               //                         CrossAxisAlignment.start,
  //               //                     children: work.remarks
  //               //                         .map((remark) => Padding(
  //               //                               padding:
  //               //                                   const EdgeInsets.symmetric(
  //               //                                       vertical: 6),
  //               //                               child: Row(
  //               //                                 crossAxisAlignment:
  //               //                                     CrossAxisAlignment.start,
  //               //                                 children: [
  //               //                                   Text("•",
  //               //                                       style: TextStyle(
  //               //                                         color: const Color
  //               //                                             .fromARGB(
  //               //                                             255, 208, 33, 243),
  //               //                                         fontSize: 14,
  //               //                                       )),
  //               //                                   const SizedBox(width: 8),
  //               //                                   Expanded(
  //               //                                     child: Text(
  //               //                                       remark,
  //               //                                       style: const TextStyle(
  //               //                                           fontSize: 14),
  //               //                                     ),
  //               //                                   ),
  //               //                                 ],
  //               //                               ),
  //               //                             ))
  //               //                         .toList(),
  //               //                   ),
  //               //                 ),
  //               //                 actions: [
  //               //                   TextButton(
  //               //                     onPressed: () => Navigator.pop(context),
  //               //                     child: const Text("Close"),
  //               //                   ),
  //               //                 ],
  //               //               ),
  //               //             );
  //               //           }
  //               //         : null, // Don't make clickable if only 1 remark
  //               //     child: Container(
  //               //       padding: const EdgeInsets.symmetric(
  //               //           horizontal: 10, vertical: 4),
  //               //       decoration: BoxDecoration(
  //               //         color: const Color.fromARGB(255, 243, 227, 253),
  //               //         borderRadius: BorderRadius.circular(8),
  //               //       ),
  //               //       child: Row(
  //               //         children: [
  //               //           const Icon(Icons.note,
  //               //               size: 12,
  //               //               color: Color.fromARGB(255, 208, 33, 243)),
  //               //           const SizedBox(width: 4),
  //               //           Text(
  //               //             work.remarks.length == 1
  //               //                 ? work.remarks[0]
  //               //                 : "${work.remarks.length} remarks",
  //               //             style: TextStyle(
  //               //               fontSize: 11,
  //               //               fontWeight: FontWeight.w600,
  //               //               color: const Color.fromARGB(255, 208, 33, 243),
  //               //             ),
  //               //             maxLines: 1,
  //               //             overflow: TextOverflow.ellipsis,
  //               //           ),
  //               //           if (work.remarks.length > 1) ...[
  //               //             const SizedBox(width: 4),
  //               //             Icon(
  //               //               Icons.arrow_drop_down,
  //               //               size: 14,
  //               //               color: const Color.fromARGB(255, 208, 33, 243),
  //               //             ),
  //               //           ],
  //               //         ],
  //               //       ),
  //               //     ),
  //               //   ),
  //               if (work.remarks.isNotEmpty)
  //                 StatefulBuilder(
  //                   builder: (context, setState) {
  //                     final isRemarksExpanded = _expandedRemarks[
  //                             '${work.startTime}_${work.endTime}'] ??
  //                         false;
  //                     final hasMultipleRemarks = work.remarks.length > 1;

  //                     return Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         InkWell(
  //                           onTap: hasMultipleRemarks
  //                               ? () {
  //                                   setState(() {
  //                                     _expandedRemarks[
  //                                             '${work.startTime}_${work.endTime}'] =
  //                                         !isRemarksExpanded;
  //                                   });
  //                                 }
  //                               : null,
  //                           child: Container(
  //                             padding: const EdgeInsets.symmetric(
  //                                 horizontal: 12, vertical: 10),
  //                             decoration: BoxDecoration(
  //                               color: const Color.fromARGB(255, 243, 227, 253),
  //                               borderRadius: BorderRadius.circular(8),
  //                             ),
  //                             child: Column(
  //                               crossAxisAlignment: CrossAxisAlignment.start,
  //                               children: [
  //                                 Row(
  //                                   mainAxisAlignment:
  //                                       MainAxisAlignment.spaceBetween,
  //                                   crossAxisAlignment:
  //                                       CrossAxisAlignment.start,
  //                                   children: [
  //                                     Expanded(
  //                                       child: Column(
  //                                         crossAxisAlignment:
  //                                             CrossAxisAlignment.start,
  //                                         children: [
  //                                           // Single remark - show full text with wrapping
  //                                           if (!hasMultipleRemarks) ...[
  //                                             Text(
  //                                               work.remarks[0],
  //                                               style: TextStyle(
  //                                                 fontSize: 12,
  //                                                 fontWeight: FontWeight.w500,
  //                                                 color: const Color.fromARGB(
  //                                                     255, 208, 33, 243),
  //                                               ),
  //                                               maxLines: isRemarksExpanded
  //                                                   ? null
  //                                                   : 3,
  //                                               overflow: isRemarksExpanded
  //                                                   ? null
  //                                                   : TextOverflow.ellipsis,
  //                                             ),
  //                                           ],

  //                                           // Multiple remarks - show count
  //                                           if (hasMultipleRemarks &&
  //                                               !isRemarksExpanded) ...[
  //                                             Text(
  //                                               "${work.remarks.length} remarks",
  //                                               style: TextStyle(
  //                                                 fontSize: 12,
  //                                                 fontWeight: FontWeight.w600,
  //                                                 color: const Color.fromARGB(
  //                                                     255, 208, 33, 243),
  //                                               ),
  //                                             ),
  //                                           ],

  //                                           // Show individual remarks when expanded
  //                                           if (hasMultipleRemarks &&
  //                                               isRemarksExpanded) ...[
  //                                             ...work.remarks
  //                                                 .asMap()
  //                                                 .entries
  //                                                 .map((entry) {
  //                                               final index = entry.key;
  //                                               final remark = entry.value;
  //                                               return Padding(
  //                                                 padding: EdgeInsets.only(
  //                                                   bottom: index ==
  //                                                           work.remarks
  //                                                                   .length -
  //                                                               1
  //                                                       ? 0
  //                                                       : 8,
  //                                                 ),
  //                                                 child: Row(
  //                                                   crossAxisAlignment:
  //                                                       CrossAxisAlignment
  //                                                           .start,
  //                                                   children: [
  //                                                     Text(
  //                                                       "${index + 1}.",
  //                                                       style: TextStyle(
  //                                                         fontSize: 12,
  //                                                         fontWeight:
  //                                                             FontWeight.w600,
  //                                                         color: const Color
  //                                                             .fromARGB(255,
  //                                                             208, 33, 243),
  //                                                       ),
  //                                                     ),
  //                                                     const SizedBox(width: 8),
  //                                                     Expanded(
  //                                                       child: Text(
  //                                                         remark,
  //                                                         style: TextStyle(
  //                                                           fontSize: 12,
  //                                                           fontWeight:
  //                                                               FontWeight.w500,
  //                                                           color: const Color
  //                                                               .fromARGB(255,
  //                                                               208, 33, 243),
  //                                                         ),
  //                                                       ),
  //                                                     ),
  //                                                   ],
  //                                                 ),
  //                                               );
  //                                             }).toList(),
  //                                           ],
  //                                         ],
  //                                       ),
  //                                     ),

  //                                     // Icon and arrow
  //                                     if (hasMultipleRemarks) ...[
  //                                       const SizedBox(width: 8),
  //                                       Row(
  //                                         children: [
  //                                           Icon(
  //                                             Icons.note,
  //                                             size: 14,
  //                                             color: const Color.fromARGB(
  //                                                 255, 208, 33, 243),
  //                                           ),
  //                                           const SizedBox(width: 4),
  //                                           Icon(
  //                                             isRemarksExpanded
  //                                                 ? Icons.expand_less
  //                                                 : Icons.expand_more,
  //                                             size: 16,
  //                                             color: const Color.fromARGB(
  //                                                 255, 208, 33, 243),
  //                                           ),
  //                                         ],
  //                                       ),
  //                                     ],
  //                                   ],
  //                                 ),

  //                                 // "View more" hint for single long remark
  //                                 if (!hasMultipleRemarks &&
  //                                     work.remarks[0].length > 100 &&
  //                                     !isRemarksExpanded) ...[
  //                                   const SizedBox(height: 4),
  //                                   Text(
  //                                     'Tap to view more',
  //                                     style: TextStyle(
  //                                       fontSize: 10,
  //                                       color: const Color.fromARGB(
  //                                           255, 208, 33, 243),
  //                                       fontStyle: FontStyle.italic,
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ],
  //                             ),
  //                           ),
  //                         ),

  //                         // Make single long remarks expandable too
  //                         if (!hasMultipleRemarks &&
  //                             work.remarks[0].length > 100) ...[
  //                           GestureDetector(
  //                             onTap: () {
  //                               setState(() {
  //                                 _expandedRemarks[
  //                                         '${work.startTime}_${work.endTime}'] =
  //                                     !isRemarksExpanded;
  //                               });
  //                             },
  //                             child: Container(
  //                               padding: const EdgeInsets.only(top: 4),
  //                               child: Row(
  //                                 mainAxisAlignment: MainAxisAlignment.end,
  //                                 children: [
  //                                   Text(
  //                                     isRemarksExpanded
  //                                         ? 'Show less'
  //                                         : 'View more',
  //                                     style: TextStyle(
  //                                       fontSize: 10,
  //                                       color: const Color.fromARGB(
  //                                           255, 208, 33, 243),
  //                                       fontWeight: FontWeight.w600,
  //                                     ),
  //                                   ),
  //                                   Icon(
  //                                     isRemarksExpanded
  //                                         ? Icons.keyboard_arrow_up
  //                                         : Icons.keyboard_arrow_down,
  //                                     size: 12,
  //                                     color: const Color.fromARGB(
  //                                         255, 208, 33, 243),
  //                                   ),
  //                                 ],
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                       ],
  //                     );
  //                   },
  //                 ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void _showShareDialog(BuildContext context, AssignedWork item) {
    // bool whatsappNotification = item.notification.whatsappNotification == "1";
    bool whatsappNotification = whatsappMenu == "true"
    ? item.notification.whatsappNotification == "1"
    : false;
    bool pushNotification = item.notification.pushNotification == "1";
    bool notifyOnStart = item.notification.onStart == "1";
    bool notifyStatusChange = item.notification.onSave == "1";
    bool notifyOnComplete = item.notification.onComplete == "1";

    // Initialize selected staff IDs
    List<String> notificationStaffIds = item.notification.staffIds is String
        ? (item.notification.staffIds as String)
            .split(',')
            .where((id) => id.isNotEmpty)
            .toList()
        : List<String>.from(item.notification.staffIds ?? []);

    List<String> participantIds = item.notification.participantIds is String
        ? (item.notification.participantIds as String)
            .split(',')
            .where((id) => id.isNotEmpty)
            .toList()
        : List<String>.from(item.notification.participantIds ?? []);

    bool hasOtherStaff =
        notificationStaffIds.any((id) => id != item.assignedToId);
    bool notifyOtherPeople = hasOtherStaff;

    // Track selected staff (excluding the assigned staff)
    List<String> selectedStaffIds =
        List.from(notificationStaffIds.where((id) => id != item.assignedToId));

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Notify Work"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Notification Settings",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    if (whatsappMenu == "true") ...[
                      InkWell(
                        onTap: () {
                          setState(() {
                            whatsappNotification = !whatsappNotification;
                          });
                        },
                        child: Row(
                          children: [
                            Checkbox(
                              value: whatsappNotification,
                              onChanged: (value) {
                                setState(() {
                                  whatsappNotification = value ?? false;
                                });
                              },
                            ),
                            const Text('WhatsApp Notification'),
                          ],
                        ),
                      ),
                    ],
                    InkWell(
                      onTap: () {
                        setState(() {
                          pushNotification = !pushNotification;
                        });
                      },
                      child: Row(
                        children: [
                          Checkbox(
                            value: pushNotification,
                            onChanged: (value) {
                              setState(() {
                                pushNotification = value ?? false;
                              });
                            },
                          ),
                          const Text('Push Notification'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () {
                        setState(() {
                          notifyOnStart = !notifyOnStart;
                        });
                      },
                      child: Row(
                        children: [
                          Checkbox(
                            value: notifyOnStart,
                            onChanged: (value) {
                              setState(() {
                                notifyOnStart = value ?? false;
                              });
                            },
                          ),
                          const Text('Notify on Work Start'),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          notifyStatusChange = !notifyStatusChange;
                        });
                      },
                      child: Row(
                        children: [
                          Checkbox(
                            value: notifyStatusChange,
                            onChanged: (value) {
                              setState(() {
                                notifyStatusChange = value ?? false;
                              });
                            },
                          ),
                          const Text('Notify on Status Change'),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          notifyOnComplete = !notifyOnComplete;
                        });
                      },
                      child: Row(
                        children: [
                          Checkbox(
                            value: notifyOnComplete,
                            onChanged: (value) {
                              setState(() {
                                notifyOnComplete = value ?? false;
                              });
                            },
                          ),
                          const Text('Notify on Work Completion'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () {
                        setState(() {
                          notifyOtherPeople = !notifyOtherPeople;
                          if (!notifyOtherPeople) selectedStaffIds.clear();
                        });
                      },
                      child: Row(
                        children: [
                          Checkbox(
                            value: notifyOtherPeople,
                            onChanged: (value) {
                              setState(() {
                                notifyOtherPeople = value ?? false;
                                if (!notifyOtherPeople) {
                                  selectedStaffIds.clear();
                                }
                              });
                            },
                          ),
                          const Text('Notify other people'),
                        ],
                      ),
                    ),
                    if (notifyOtherPeople) ...[
                      const SizedBox(height: 8),
                      const Text('Select Staff to Notify:'),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () async {
                          final selected = await _showMultiStaffSelectionDialog(
                            context,
                            false,
                            item.assignedToId,
                            selectedStaffIds,
                            item,
                          );
                          if (selected != null) {
                            setState(() => selectedStaffIds = selected);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedStaffIds.isEmpty
                                    ? 'Select Staff'
                                    : '${selectedStaffIds.length + 1} staff selected',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      'Participants in Chat',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final selected = await _showMultiStaffSelectionDialog(
                          context,
                          true,
                          item.assignedToId,
                          participantIds,
                          item,
                        );
                        if (selected != null) {
                          setState(() => participantIds = selected);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              participantIds.isEmpty
                                  ? 'Select Chat Participants'
                                  : '${participantIds.length} participants selected',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final allStaffIds = [
                      item.assignedToId,
                      ...selectedStaffIds,
                    ].where((id) => id.isNotEmpty).toList();

                    final notificationData = {
                      'work_id': item.id.toString(),
                      'assigned_to': item.assignedToId,
                      'assigned_to_name': item.assignedTo,
                      'assigned_by': item.assignedBy,
                      'project_name': item.projectName,
                      'task_name': item.taskName,
                      'task_description': item.taskDescription,
                      'priority': item.priority,
                      'due_date': item.dueDate,
                      'whatsapp': whatsappNotification ? '1' : '0',
                      'push': pushNotification ? '1' : '0',
                      'on_start': notifyOnStart ? '1' : '0',
                      'on_save': notifyStatusChange ? '1' : '0',
                      'on_complete': notifyOnComplete ? '1' : '0',
                      'notify_other_people': notifyOtherPeople ? '1' : '0',
                      'staff_ids': allStaffIds.join(','),
                      'participant_ids': participantIds.join(','),
                    };

                    final isSuccess = await HttpService.alertWorkNotification(
                        notificationData);

                    if (isSuccess) {
                      await _handleRefresh();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Notification sent successfully"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Failed to send notification"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Notify'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showShareDialogTransfer(BuildContext context, AssignedWork item) {
    final _formKey = GlobalKey<FormState>();
    TextEditingController descriptionController = TextEditingController();
    List<String> selectedStaffIds = [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Transfer Work"),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Project Name (Read-only)
                    TextFormField(
                      initialValue: item.projectName,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Project Name",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Module Name (Read-only)
                    TextFormField(
                      initialValue: item.moduleName,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Module Name",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Staff Selection
                    InkWell(
                      onTap: () async {
                        final selected = await _showMultiStaffSelectionDialog(
                          context,
                          false,
                          item.assignedToId,
                          selectedStaffIds,
                          item,
                        );
                        if (selected != null) {
                          setState(() => selectedStaffIds = selected);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          labelText: "Transfer To",
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedStaffIds.isEmpty
                                  ? 'Select Staff'
                                  : '${selectedStaffIds.length} staff selected',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Description
                    TextFormField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: "Reason / Description",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? "Enter a reason"
                          : null,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (selectedStaffIds.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Select at least one staff")),
                        );
                        return;
                      }

                      try {
                        final response = await HttpService.transferWork(
                          workId: item.id.toString(),
                          staffIds: selectedStaffIds,
                          description: descriptionController.text,
                        );

                        if (response != null && response.status) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                response.message,
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              margin: const EdgeInsets.all(12),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    response?.message ?? "Transfer failed")),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: $e")),
                        );
                      }
                    }
                  },
                  child: const Text("Transfer"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<List<String>?> _showMultiStaffSelectionDialog(
    BuildContext context,
    bool isForParticipants,
    String assignedToId,
    List<String> initiallySelected,
    AssignedWork item,
  ) async {
    List<String> tempSelected = List.from(initiallySelected);

    return await showDialog<List<String>>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                unselectedWidgetColor: Colors.grey,
                disabledColor: Colors.grey,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.group, color: Colors.blue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isForParticipants
                                ? 'Select Chat Participants'
                                : 'Select Staff to Notify',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search staff...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: FutureBuilder<List<Staff>>(
                      future: HttpService.getStaffs().then(
                        (staffListModel) => staffListModel?.data ?? <Staff>[],
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                              child: Text("No staff available"));
                        }

                        final staffList = snapshot.data!;

                        return StatefulBuilder(
                          builder: (context, setState) {
                            return ListView.builder(
                              itemCount: staffList.length,
                              itemBuilder: (context, index) {
                                final staff = staffList[index];
                                final staffId = staff.userIdStaff.toString();
                                final isSelected =
                                    tempSelected.contains(staffId);
                                final isAssignedStaff = staffId == assignedToId;
                                final isDisabled =
                                    !isForParticipants && isAssignedStaff;

                                return Container(
                                    color: isSelected
                                        ? Colors.blue.withOpacity(0.1)
                                        : null,
                                    child: CheckboxListTile(
                                      value: isSelected,
                                      onChanged: isDisabled
                                          ? null
                                          : (value) {
                                              setState(() {
                                                if (value == true) {
                                                  tempSelected.add(staffId);
                                                } else {
                                                  tempSelected.remove(staffId);
                                                }
                                              });
                                            },
                                      title: Text(
                                        staff.name +
                                            (isDisabled ? ' (Assigned)' : ''),
                                        style: isDisabled
                                            ? const TextStyle(
                                                color: Colors.grey)
                                            : null,
                                      ),
                                      secondary:
                                          const Icon(Icons.person_outline),
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      activeColor: Colors.blue,
                                      checkColor: Colors.white,
                                    ));
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel')),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context, tempSelected);
                            },
                            child: const Text('Confirm'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFilters() {
    print('=== SHOW FILTERS DEBUG ===');
    print('_hasInitialStatusFilter: $_hasInitialStatusFilter');
    print('_initialStatus: $_initialStatus');
    print('currentFilters: $currentFilters');
    print('currentFilters.isEmpty: ${currentFilters.isEmpty}');
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
                  showUnassigned: true,
                  onApplyFilters: (filters) {
                    print('=== FILTERS APPLIED DEBUG ===');
                    print('Applied filters: $filters');
                    print(
                        'Has status_ids: ${filters.containsKey('status_ids')}');

                    if (filters.containsKey('status_ids')) {
                      print('status_ids value: ${filters['status_ids']}');
                      print(
                          'status_ids is empty list: ${(filters['status_ids'] as List).isEmpty}');
                    }
                    setState(() {
                      _hasInitialStatusFilter = false;
                      _initialStatus = null;
                      _selectedFilters.remove('todo');
                      _selectedFilters.remove('pending');

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
                        if (names.any((n) => n.contains('unassigned'))) {
                          _selectedFilters.add('unassigned');
                        }
                      }

                      currentFilters = Map.from(filters);
                      print('Updated currentFilters: $currentFilters');
                      print('Cleared widget status filter');
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

  Widget _buildBottomCountSummary() {
    return FutureBuilder<List<AssignedWork>>(
      future: assignedWorkFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done ||
            !snapshot.hasData ||
            snapshot.data!.isEmpty) {
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

        final assignedItems = snapshot.data!;
        String firstItemTotal =
            assignedItems.isNotEmpty ? assignedItems.first.total : "0";
        String firstTaskItemTotal =
            assignedItems.isNotEmpty ? assignedItems.last.totalTask : "0";
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
              Icon(
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
                      Text(
                        'Work :',
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color.fromARGB(255, 17, 17, 17),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        firstItemTotal,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(width: 25),
                      Icon(
                        Icons.assignment_outlined,
                        color: Colors.blue,
                        size: 24,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Task:',
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color.fromARGB(255, 22, 22, 22),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        firstTaskItemTotal,
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
      },
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case "1":
        return const Color.fromARGB(255, 28, 197, 118);
      case "2":
        return Colors.orange;
      case "3":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getPriorityText(String priority) {
    switch (priority) {
      case "1":
        return "Normal";
      case "2":
        return "High";
      case "3":
        return "Critical";
      default:
        return "__";
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'running':
        return const Color.fromARGB(255, 88, 156, 10);
      case 'to do':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'overdue':
        return Colors.red;
      case 'cancel':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}

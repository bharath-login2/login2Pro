import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/lead_management/priorityStatusModel.dart';
import 'package:login2/models/lead_management/taskStatusModel.dart';
import 'package:login2/models/expense/staffListModel.dart';
import 'package:login2/service/service.dart';
import 'package:login2/core/common.dart';

class FilterWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onApplyFilters;
  final int pageId;
  final Map<String, dynamic>? initialFilters;

  final bool showUnassigned;

  const FilterWidget({
    super.key,
    required this.onApplyFilters,
    required this.pageId,
    this.initialFilters,
    this.showUnassigned = false,
  });

  @override
  State<FilterWidget> createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  String selectedCategory = 'Task status';
  Set<String> selectedPriorityIds = {};
  Set<String> selectedStatusIds = {};
  Set<String> selectedAssignedByIds = {};
  Set<String> selectedAssignedToIds = {};
  DateTime? dueDateFrom;
  DateTime? dueDateTo;
  DateTime? createdFrom;
  DateTime? createdTo;
  List<PrioState> prioList = [];
  List<TaskState> statusList = [];
  List<Staff> staffList = [];
  bool shouldSortSelectedFirst = false;
  String? lastAppliedCategory;

  final DateFormat _formatter = DateFormat('dd-MM-yyyy');
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData().then((_) {
      _initializeFilters();
    });
  }

  Future<void> _loadData() async {
    final prio = await HttpService.getPrioState();
    final task = await HttpService.getTaskState();
    final staff = await HttpService.getStaffs();
    if (mounted) {
      setState(() {
        if (prio?.data != null) prioList = prio!.data;
        if (task?.data != null) {
          statusList = List<TaskState>.from(task!.data);
        }
        if (staff?.data != null) staffList = staff!.data;
      });
    }
  }

  void _initializeFilters() {
    if (widget.initialFilters != null) {
      print('DEBUG: Initial filters: ${widget.initialFilters}');
      print(
          'DEBUG: statusList: ${statusList.map((s) => '${s.id}: ${s.status}').toList()}');
      setState(() {
        selectedPriorityIds =
            Set.from(widget.initialFilters?['priority_ids'] ?? []);
        selectedAssignedByIds =
            Set.from(widget.initialFilters?['assigned_by_ids'] ?? []);
        selectedAssignedToIds =
            Set.from(widget.initialFilters?['assigned_to_ids'] ?? []);
        selectedStatusIds.clear();

        // First check for status_names from the filters
        if (widget.initialFilters?['status_names'] != null) {
          dynamic statusNamesValue = widget.initialFilters!['status_names'];
          List<String> statusNames = [];

          if (statusNamesValue is List) {
            for (var item in statusNamesValue) {
              if (item is String && item.contains(',')) {
                statusNames.addAll(item.split(',').map((s) => s.trim()));
              } else {
                statusNames.add(item.toString().trim());
              }
            }
          } else if (statusNamesValue is String) {
            statusNames
                .addAll(statusNamesValue.split(',').map((s) => s.trim()));
          }

          print('DEBUG: Found status_names: $statusNames');

          for (String statusName in statusNames) {
            String normalizedName = statusName.toLowerCase();
            print('DEBUG: Looking for status: $normalizedName');

            for (var status in statusList) {
              String statusText = status.status.toLowerCase();

              // Handle "to do" variations
              if ((normalizedName == 'todo' || normalizedName == 'to do') &&
                  (statusText.contains('todo') ||
                      statusText.contains('to do'))) {
                selectedStatusIds.add(status.id);
                print(
                    'DEBUG: Found "To Do" status: ${status.id} - ${status.status}');
                break;
              }
              // Handle other statuses
              else if (normalizedName == 'completed' &&
                  statusText.contains('completed')) {
                selectedStatusIds.add(status.id);
                print(
                    'DEBUG: Found "Completed" status: ${status.id} - ${status.status}');
                break;
              } else if (normalizedName == 'pending' &&
                  statusText.contains('pending')) {
                selectedStatusIds.add(status.id);
                print(
                    'DEBUG: Found "Pending" status: ${status.id} - ${status.status}');
                break;
              } else if (normalizedName == 'overdue' &&
                  statusText.contains('overdue')) {
                selectedStatusIds.add(status.id);
                print(
                    'DEBUG: Found "Overdue" status: ${status.id} - ${status.status}');
                break;
              }
              // Handle in-progress
              else if (normalizedName == 'in-progress' ||
                  normalizedName == 'in progress') {
                if (statusText.contains('in-progress') ||
                    statusText.contains('in progress')) {
                  selectedStatusIds.add(status.id);
                  print(
                      'DEBUG: Found "In-Progress" status: ${status.id} - ${status.status}');
                  break;
                }
              }
              // Generic match for other status names
              else if (statusText == normalizedName) {
                selectedStatusIds.add(status.id);
                print(
                    'DEBUG: Found exact match: ${status.id} - ${status.status}');
                break;
              }
            }
            if (normalizedName == 'unassigned') {
              selectedAssignedToIds.add('0');
              print('DEBUG: Found "Unassigned" for Assigned To');
            }
          }
        }
        // Fallback to status_name (singular) for backward compatibility (may contain commas)
        else if (widget.initialFilters?['status_name'] != null) {
          String statusNameField =
              widget.initialFilters!['status_name'].toString();
          List<String> statusNames =
              statusNameField.split(',').map((s) => s.trim()).toList();

          print(
              'DEBUG: Looking for statuses from status_name field: $statusNames');

          for (String statusName in statusNames) {
            String normalizedName = statusName.toLowerCase();
            bool found = false;

            for (var status in statusList) {
              String statusText = status.status.toLowerCase();

              if ((normalizedName == 'todo' || normalizedName == 'to do') &&
                  (statusText.contains('todo') ||
                      statusText.contains('to do'))) {
                selectedStatusIds.add(status.id);
                print(
                    'DEBUG: Found "To Do" status: ${status.id} - ${status.status}');
                found = true;
                break;
              } else if (normalizedName == 'completed' &&
                  statusText.contains('completed')) {
                selectedStatusIds.add(status.id);
                print(
                    'DEBUG: Found "Completed" status: ${status.id} - ${status.status}');
                found = true;
                break;
              } else if (normalizedName == 'pending' &&
                  statusText.contains('pending')) {
                selectedStatusIds.add(status.id);
                print(
                    'DEBUG: Found "Pending" status: ${status.id} - ${status.status}');
                found = true;
                break;
              } else if (normalizedName == 'overdue' &&
                  statusText.contains('overdue')) {
                selectedStatusIds.add(status.id);
                print(
                    'DEBUG: Found "Overdue" status: ${status.id} - ${status.status}');
                found = true;
                break;
              } else if (normalizedName == 'in-progress' ||
                  normalizedName == 'in progress') {
                if (statusText.contains('in-progress') ||
                    statusText.contains('in progress')) {
                  selectedStatusIds.add(status.id);
                  print(
                      'DEBUG: Found "In-Progress" status: ${status.id} - ${status.status}');
                  found = true;
                  break;
                }
              }
            }

            if (!found) {
              for (var status in statusList) {
                if (status.status.toLowerCase().contains(normalizedName)) {
                  selectedStatusIds.add(status.id);
                  print(
                      'DEBUG: Found matching status (contains): ${status.id} - ${status.status}');
                  break;
                }
              }
            }
          }
        }

        if (widget.initialFilters?['due_from'] != null) {
          dueDateFrom = DateTime.parse(widget.initialFilters?['due_from']);
        }
        if (widget.initialFilters?['due_to'] != null) {
          dueDateTo = DateTime.parse(widget.initialFilters?['due_to']);
        }
        if (widget.initialFilters?['created_from'] != null) {
          createdFrom = DateTime.parse(widget.initialFilters?['created_from']);
        }
        if (widget.initialFilters?['created_to'] != null) {
          createdTo = DateTime.parse(widget.initialFilters?['created_to']);
        }
        shouldSortSelectedFirst = true;

        print('DEBUG: Final selectedStatusIds: $selectedStatusIds');
      });
    }
  }

  // void _initializeFilters() {
  //   if (widget.initialFilters != null) {
  //     print('DEBUG: Initial filters: ${widget.initialFilters}');
  //     print(
  //         'DEBUG: statusList: ${statusList.map((s) => '${s.id}: ${s.status}').toList()}');
  //     setState(() {
  //       selectedPriorityIds =
  //           Set.from(widget.initialFilters?['priority_ids'] ?? []);
  //       selectedAssignedByIds =
  //           Set.from(widget.initialFilters?['assigned_by_ids'] ?? []);
  //       selectedAssignedToIds =
  //           Set.from(widget.initialFilters?['assigned_to_ids'] ?? []);
  //       selectedStatusIds.clear();
  //       if (widget.initialFilters?['status_ids'] != null) {
  //         List<dynamic> statusIds = widget.initialFilters!['status_ids'];
  //         if (statusIds is List) {
  //           for (var id in statusIds) {
  //             if (id != null && id.toString().isNotEmpty) {
  //               selectedStatusIds.add(id.toString());
  //             }
  //           }
  //         }
  //         print(
  //             'DEBUG: Set status_ids from initial filters: $selectedStatusIds');
  //       } else if (widget.initialFilters?['status_name'] != null) {
  //         String statusName =
  //             widget.initialFilters!['status_name'].toLowerCase();
  //         print('DEBUG: Looking for status with name: $statusName');
  //         bool found = false;
  //         for (var status in statusList) {
  //           String statusText = status.status.toLowerCase();
  //           if ((statusName == 'todo' || statusName == 'to do') &&
  //               (statusText.contains('todo') || statusText.contains('to do'))) {
  //             selectedStatusIds.add(status.id);
  //             print(
  //                 'DEBUG: Found "To Do" status: ${status.id} - ${status.status}');
  //             found = true;
  //             break;
  //           } else if (statusName == 'completed' &&
  //               statusText.contains('completed')) {
  //             selectedStatusIds.add(status.id);
  //             print(
  //                 'DEBUG: Found "Completed" status: ${status.id} - ${status.status}');
  //             found = true;
  //             break;
  //           } else if (statusName == 'pending' &&
  //               statusText.contains('pending')) {
  //             selectedStatusIds.add(status.id);
  //             print(
  //                 'DEBUG: Found "Pending" status: ${status.id} - ${status.status}');
  //             found = true;
  //             break;
  //           } else if (statusName == 'overdue' &&
  //               statusText.contains('overdue')) {
  //             selectedStatusIds.add(status.id);
  //             print(
  //                 'DEBUG: Found "Overdue" status: ${status.id} - ${status.status}');
  //             found = true;
  //             break;
  //           }
  //         }
  //         if (!found) {
  //           for (var status in statusList) {
  //             if (status.status.toLowerCase().contains(statusName)) {
  //               selectedStatusIds.add(status.id);
  //               print(
  //                   'DEBUG: Found matching status (contains): ${status.id} - ${status.status}');
  //               break;
  //             }
  //           }
  //         }
  //         if (selectedStatusIds.isEmpty) {
  //           print('DEBUG: Could not find any status for name: $statusName');
  //         }
  //       }
  //       if (widget.initialFilters?['due_from'] != null) {
  //         dueDateFrom = DateTime.parse(widget.initialFilters?['due_from']);
  //       }
  //       if (widget.initialFilters?['due_to'] != null) {
  //         dueDateTo = DateTime.parse(widget.initialFilters?['due_to']);
  //       }
  //       if (widget.initialFilters?['created_from'] != null) {
  //         createdFrom = DateTime.parse(widget.initialFilters?['created_from']);
  //       }
  //       if (widget.initialFilters?['created_to'] != null) {
  //         createdTo = DateTime.parse(widget.initialFilters?['created_to']);
  //       }
  //       shouldSortSelectedFirst = true;

  //       print('DEBUG: Final selectedStatusIds: $selectedStatusIds');
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 7,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filters',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E3A59),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Color(0xFF2E3A59)),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFilterCategory(
                          'Task status', Icons.star_outline_sharp),
                      _buildFilterCategory('Assigned By', Icons.person),
                      _buildFilterCategory('Assigned to', Icons.person_2),
                      _buildFilterCategory('Due date', Icons.date_range),
                      _buildFilterCategory('Priority', Icons.priority_high),
                      _buildFilterCategory('Created time', Icons.date_range),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(child: _buildFilterOptionsPanel()),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Divider(color: Color(0xFFE4E9F2), height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: _resetFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE4E9F2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text(
                  'Reset Filters',
                  style: TextStyle(
                    color: Color(0xFF3366FF),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3366FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterCategory(String title, IconData icon) {
    final isSelected = selectedCategory == title;

    bool isFiltered = false;
    switch (title) {
      case 'Priority':
        isFiltered = selectedPriorityIds.isNotEmpty;
        break;
      case 'Task status':
        isFiltered = selectedStatusIds.isNotEmpty;
        break;
      case 'Assigned By':
        isFiltered = selectedAssignedByIds.isNotEmpty;
        break;
      case 'Assigned to':
        isFiltered = selectedAssignedToIds.isNotEmpty;
        break;
      case 'Due date':
        isFiltered = dueDateFrom != null || dueDateTo != null;
        break;
      case 'Created time':
        isFiltered = createdFrom != null || createdTo != null;
        break;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = title;
          shouldSortSelectedFirst = title == lastAppliedCategory;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE3F2FD) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: const Color(0xFF3366FF),
                ),
                if (isFiltered)
                  const Positioned(
                    left: 115,
                    top: 5,
                    child: Icon(Icons.circle, size: 10, color: Colors.orange),
                  ),
              ],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E3A59),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOptionsPanel() {
    switch (selectedCategory) {
      case 'Priority':
        return _buildMultiSelectList(
          items: prioList,
          selectedIds: selectedPriorityIds,
          displayProperty: (p) => p.priority,
          getId: (p) => p.id,
        );

      case 'Task status':
        return _buildMultiSelectList(
          items: statusList,
          selectedIds: selectedStatusIds,
          displayProperty: (s) => s.status,
          getId: (s) => s.id,
        );

      case 'Assigned By':
        return _buildStaffSelectionList(
          selectedIds: selectedAssignedByIds,
        );

      case 'Assigned to':
        return _buildStaffSelectionList(
          selectedIds: selectedAssignedToIds,
        );

      case 'Due date':
        return Column(
          children: [
            _buildDateField(
              "From",
              dueDateFrom,
              true,
              dueDateTo,
              (d) async {
                final dateFilterMonths = await Common.getDateFilter();
                setState(() {
                  dueDateFrom = d;
                  if (dateFilterMonths != null && dateFilterMonths > 0) {
                    final maxTo = Common.addMonths(d, dateFilterMonths);
                    if (dueDateTo != null && (dueDateTo!.isBefore(d) || dueDateTo!.isAfter(maxTo))) {
                      dueDateTo = null;
                    }
                  } else if (dueDateTo != null && dueDateTo!.isBefore(d)) {
                    dueDateTo = null;
                  }
                });
              },
            ),
            _buildDateField(
              "To",
              dueDateTo,
              false,
              dueDateFrom,
              (d) async {
                final dateFilterMonths = await Common.getDateFilter();
                setState(() {
                  dueDateTo = d;
                  if (d != null && dateFilterMonths != null && dateFilterMonths > 0) {
                    final minFrom = Common.subtractMonths(d, dateFilterMonths);
                    if (dueDateFrom != null && (dueDateFrom!.isBefore(minFrom) || dueDateFrom!.isAfter(d))) {
                      dueDateFrom = null;
                    }
                  }
                });
              },
            ),
            const SizedBox(height: 10),
            _buildQuickDateFilters(
              onToday: () {
                final now = DateTime.now();
                setState(() {
                  dueDateFrom = now;
                  dueDateTo = now;
                });
              },
              onThisMonth: () {
                final now = DateTime.now();
                setState(() {
                  dueDateFrom = DateTime(now.year, now.month, 1);
                  dueDateTo = DateTime(now.year, now.month + 1, 0);
                });
              },
            ),
          ],
        );

      case 'Created time':
        return Column(
          children: [
            _buildDateField(
              "From",
              createdFrom,
              true,
              createdTo,
              (d) async {
                final dateFilterMonths = await Common.getDateFilter();
                setState(() {
                  createdFrom = d;
                  if (dateFilterMonths != null && dateFilterMonths > 0) {
                    final maxTo = Common.addMonths(d, dateFilterMonths);
                    if (createdTo != null && (createdTo!.isBefore(d) || createdTo!.isAfter(maxTo))) {
                      createdTo = null;
                    }
                  } else if (createdTo != null && createdTo!.isBefore(d)) {
                    createdTo = null;
                  }
                });
              },
            ),
            _buildDateField(
              "To",
              createdTo,
              false,
              createdFrom,
              (d) async {
                final dateFilterMonths = await Common.getDateFilter();
                setState(() {
                  createdTo = d;
                  if (d != null && dateFilterMonths != null && dateFilterMonths > 0) {
                    final minFrom = Common.subtractMonths(d, dateFilterMonths);
                    if (createdFrom != null && (createdFrom!.isBefore(minFrom) || createdFrom!.isAfter(d))) {
                      createdFrom = null;
                    }
                  }
                });
              },
            ),
            const SizedBox(height: 10),
            _buildQuickDateFilters(
              onToday: () {
                final now = DateTime.now();
                setState(() {
                  createdFrom = now;
                  createdTo = now;
                });
              },
              onThisMonth: () {
                final now = DateTime.now();
                setState(() {
                  createdFrom = DateTime(now.year, now.month, 1);
                  createdTo = DateTime(now.year, now.month + 1, 0);
                });
              },
            ),
          ],
        );

      default:
        return const Text("Coming soon...");
    }
  }

  Widget _buildMultiSelectList<T>({
    required List<T> items,
    required Set<String> selectedIds,
    required String Function(T) displayProperty,
    required String Function(T) getId,
  }) {
    final searchTerm = _searchController.text.toLowerCase();

    var filteredItems = items.where((item) {
      return displayProperty(item).toLowerCase().contains(searchTerm);
    }).toList();

    if (shouldSortSelectedFirst) {
      filteredItems.sort((a, b) {
        final aSelected = selectedIds.contains(getId(a));
        final bSelected = selectedIds.contains(getId(b));

        if (aSelected && !bSelected) return -1;
        if (!aSelected && bSelected) return 1;
        return displayProperty(a).compareTo(displayProperty(b));
      });
    } else {
      filteredItems
          .sort((a, b) => displayProperty(a).compareTo(displayProperty(b)));
    }

    return Column(
      children: [
        if (selectedCategory == 'Assigned By' ||
            selectedCategory == 'Assigned to')
          Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search, size: 18),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  isDense: true,
                ),
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 8),
            ],
          ),
        Container(
          height: 250,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFC5CEE0)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              final item = filteredItems[index];
              final id = getId(item);
              final selected = selectedIds.contains(id);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (selected) {
                      selectedIds.remove(id);
                    } else {
                      selectedIds.add(id);
                    }
                    shouldSortSelectedFirst = false;
                  });
                },
                child: SizedBox(
                  height: 40,
                  child: ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    contentPadding: const EdgeInsets.only(left: 4, right: 8),
                    leading: Transform.scale(
                      scale: 0.7,
                      child: Checkbox(
                        value: selected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              selectedIds.add(id);
                            } else {
                              selectedIds.remove(id);
                            }
                            // Never sort immediately after selection
                            shouldSortSelectedFirst = false;
                          });
                        },
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    title: Text(
                      displayProperty(item),
                      style: TextStyle(
                        fontSize: 13,
                        color: selected
                            ? const Color(0xFF3366FF)
                            : const Color(0xFF2E3A59),
                        fontWeight:
                            selected ? FontWeight.bold : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    minLeadingWidth: 12,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStaffSelectionList({
    required Set<String> selectedIds,
  }) {
    final searchTerm = _searchController.text.toLowerCase();

    var filteredStaff = staffList.where((staff) {
      return staff.name.toLowerCase().contains(searchTerm);
    }).toList();

    if (widget.showUnassigned && selectedCategory == 'Assigned to') {
      if ('unassigned'.contains(searchTerm)) {
        filteredStaff.insert(
            0, Staff(id: '0', name: 'Unassigned', userIdStaff: '0'));
      }
    }

    if (shouldSortSelectedFirst) {
      filteredStaff.sort((a, b) {
        final aSelected = selectedIds.contains(a.userIdStaff);
        final bSelected = selectedIds.contains(b.userIdStaff);

        if (aSelected && !bSelected) return -1;
        if (!aSelected && bSelected) return 1;
        return a.name.compareTo(b.name);
      });
    } else {
      filteredStaff.sort((a, b) => a.name.compareTo(b.name));
    }

    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search',
            prefixIcon: const Icon(Icons.search, size: 18),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            isDense: true,
          ),
          onChanged: (value) => setState(() {}),
        ),
        const SizedBox(height: 8),
        Container(
          height: 250,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFC5CEE0)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: filteredStaff.length,
            itemBuilder: (context, index) {
              final staff = filteredStaff[index];
              final id = staff.userIdStaff;
              final selected = selectedIds.contains(id);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (selected) {
                      selectedIds.remove(id);
                    } else {
                      selectedIds.add(id);
                    }
                    shouldSortSelectedFirst = false;
                  });
                },
                child: SizedBox(
                  height: 40,
                  child: ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    contentPadding: const EdgeInsets.only(left: 4, right: 8),
                    leading: Transform.scale(
                      scale: 0.7,
                      child: Checkbox(
                        value: selected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              selectedIds.add(id);
                            } else {
                              selectedIds.remove(id);
                            }
                            shouldSortSelectedFirst = false;
                          });
                        },
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    title: Text(
                      staff.name,
                      style: TextStyle(
                        fontSize: 13,
                        color: selected
                            ? const Color(0xFF3366FF)
                            : const Color(0xFF2E3A59),
                        fontWeight:
                            selected ? FontWeight.bold : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    minLeadingWidth: 12,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(
    String label,
    DateTime? value,
    bool isFrom,
    DateTime? otherDate,
    Function(DateTime) onSelect,
  ) {
    final display = value != null ? _formatter.format(value) : 'Select';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () async {
          final dateFilterMonths = await Common.getDateFilter();
          final DateTime now = DateTime.now();

          DateTime firstDate;
          DateTime lastDate;
          DateTime initialDate;

          if (isFrom) {
            if (otherDate != null) {
              lastDate = otherDate;
              if (dateFilterMonths != null && dateFilterMonths > 0) {
                firstDate = Common.subtractMonths(otherDate, dateFilterMonths);
              } else {
                firstDate = DateTime(2020);
              }
            } else {
              firstDate = DateTime(2020);
              lastDate = DateTime(2100);
            }
            initialDate = value ?? lastDate;
            if (initialDate.isBefore(firstDate)) initialDate = firstDate;
            if (initialDate.isAfter(lastDate)) initialDate = lastDate;
          } else {
            if (otherDate != null) {
              firstDate = otherDate;
              if (dateFilterMonths != null && dateFilterMonths > 0) {
                lastDate = Common.addMonths(otherDate, dateFilterMonths);
              } else {
                lastDate = DateTime(2100);
              }
            } else {
              firstDate = DateTime(2020);
              lastDate = DateTime(2100);
            }
            initialDate = value ?? firstDate;
            if (initialDate.isBefore(firstDate)) initialDate = firstDate;
            if (initialDate.isAfter(lastDate)) initialDate = lastDate;
          }

          final picked = await showDatePicker(
            context: context,
            initialDate: initialDate,
            firstDate: firstDate,
            lastDate: lastDate,
          );
          if (picked != null) onSelect(picked);
        },
        child: Row(
          children: [
            const Icon(Icons.calendar_month,
                size: 20, color: Color(0xFF3366FF)),
            const SizedBox(width: 8),
            Text(
              '$label: $display',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2E3A59),
              ),
            ),
          ],
        ),
      ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: const BorderSide(color: Color(0xFF3366FF)),
              ),
              minimumSize: const Size(0, 32),
            ),
            child: const Text(
              "Today",
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF3366FF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: onThisMonth,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE3F2FD),
              elevation: 0,
              padding:
                  const EdgeInsets.symmetric(vertical: 4), // Reduced from 8
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6), // Smaller radius
                side: const BorderSide(color: Color(0xFF3366FF)),
              ),
              minimumSize: const Size(0, 32), // Set minimum height
            ),
            child: const Text(
              "This Month",
              style: TextStyle(
                fontSize: 10, // Reduced font size
                color: Color(0xFF3366FF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        )
      ],
    );
  }

  // void _applyFilters() {
  //   widget.onApplyFilters({
  //     'priority_ids': selectedPriorityIds.toList(),
  //     'status_ids': selectedStatusIds.toList(),
  //     'assigned_by_ids': selectedAssignedByIds.toList(),
  //     'assigned_to_ids': selectedAssignedToIds.toList(),
  //     'due_from': dueDateFrom?.toIso8601String(),
  //     'due_to': dueDateTo?.toIso8601String(),
  //     'created_from': createdFrom?.toIso8601String(),
  //     'created_to': createdTo?.toIso8601String(),
  //   });
  //   setState(() {
  //     lastAppliedCategory = selectedCategory;
  //   });
  //   Navigator.pop(context);
  // }
  void _applyFilters() {
    Map<String, dynamic> appliedFilters = {};
    if (selectedPriorityIds.isNotEmpty) {
      appliedFilters['priority_ids'] = selectedPriorityIds.toList();
    }
    if (selectedStatusIds.isNotEmpty) {
      appliedFilters['status_ids'] = selectedStatusIds.toList();
      // Also return names for UI sync
      appliedFilters['status_names'] = statusList
          .where((s) => selectedStatusIds.contains(s.id))
          .map((s) => s.status.toLowerCase())
          .toList();
    } else {
      appliedFilters['status_ids'] = [];
      appliedFilters['status_names'] = [];
    }
    if (selectedAssignedByIds.isNotEmpty) {
      appliedFilters['assigned_by_ids'] = selectedAssignedByIds.toList();
    }
    if (selectedAssignedToIds.isNotEmpty) {
      appliedFilters['assigned_to_ids'] = selectedAssignedToIds.toList();
      if (selectedAssignedToIds.contains('0')) {
        List<String> names =
            List<String>.from(appliedFilters['status_names'] ?? []);
        if (!names.contains('unassigned')) names.add('unassigned');
        appliedFilters['status_names'] = names;
      }
    }
    if (dueDateFrom != null) {
      appliedFilters['due_from'] = dueDateFrom!.toIso8601String();
    }
    if (dueDateTo != null) {
      appliedFilters['due_to'] = dueDateTo!.toIso8601String();
    }
    if (createdFrom != null) {
      appliedFilters['created_from'] = createdFrom!.toIso8601String();
    }
    if (createdTo != null) {
      appliedFilters['created_to'] = createdTo!.toIso8601String();
    }

    widget.onApplyFilters(appliedFilters);
    setState(() {
      lastAppliedCategory = selectedCategory;
    });
    Navigator.pop(context);
  }

  void _resetFilters() {
    setState(() {
      selectedPriorityIds.clear();
      selectedStatusIds.clear();
      selectedAssignedByIds.clear();
      selectedAssignedToIds.clear();
      dueDateFrom = null;
      dueDateTo = null;
      createdFrom = null;
      createdTo = null;
      shouldSortSelectedFirst = false;
      lastAppliedCategory = null;
    });
  }
}

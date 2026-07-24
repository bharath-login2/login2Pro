import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/lead_management/priorityStatusModel.dart';
import 'package:login2/models/lead_management/taskStatusModel.dart';
import '../../core/common.dart';
import '../../models/lead_management/projectList_model.dart';
import '../../models/lead_management/titleListModel.dart';
import '../../models/lead_management/workstatus_model.dart';
import '../../service/service.dart';
import 'package:login2/models/expense/staffListModel.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class TaskForm {
  TextEditingController controller;
  TextEditingController descriptionController;
  String? status;
  String? taskId;
  List<TextEditingController> remarksControllers;

  List<File> attachments;

  TaskForm({
    required this.controller,
    required this.descriptionController,
    this.status,
    this.taskId,
    List<TextEditingController>? remarks,
    List<File>? attachments,
  })  : remarksControllers = remarks ?? [TextEditingController()],
        attachments = attachments ?? [];
}

class AssignWorkPage extends StatefulWidget {
  final String callMasterId;
  final String callLeadId;
  final String clientName;
  final WorkStatus? existingWork;
  final Function() onSuccess;
  final int isPaused;
  final int Restart;
  const AssignWorkPage({
    super.key,
    required this.callMasterId,
    required this.callLeadId,
    required this.clientName,
    this.existingWork,
    required this.onSuccess,
    this.isPaused = 0,
    this.Restart = 0,
  });

  @override
  _AssignWorkPageState createState() => _AssignWorkPageState();
}

class _AssignWorkPageState extends State<AssignWorkPage> {
  late TextEditingController titleController;
  late List<TaskForm> tasks;
  String? selectedProjectId;
  String? selectedProjectName;
  String? selectedTitleId;
  DateTime? dueDate;
  String? priority;
  String? assignedTo;
  final TextEditingController _searchController = TextEditingController();
  List<Projects> _filteredProjects = [];
  bool _isSearching = false;
  List<Projects> projectList = [];
  List<TitleListDet> titleList = [];
  List<String> participantIds = [];
  String taskType = "Task";
  String category = "New Work";
  final List<String> taskTypes = ["Task", "Complaint"];
  final List<String> categories = ["New Work", "Re Work"];
  bool isLoading = true;
  final TextEditingController search = TextEditingController();
  final TextEditingController selectedProjectController =
      TextEditingController();
  List<dynamic> filteredNames = [];
  List<dynamic> filteredTemplates = [];
  List<Projects> filteredProjects = [];
  List<dynamic> filteredProducts = [];
  dynamic customerNameExisting = TextEditingController();
  dynamic customerIdExisting;
  dynamic remindMeExisting = TextEditingController();
  dynamic templateIdExisting;
  dynamic productIdExisting;
  dynamic productNameExisting = TextEditingController();
  dynamic prodRateExisting = TextEditingController();
  dynamic prodTaxExisting = TextEditingController();
  dynamic typeDuration;
  bool isLocationEnabled = false;
  final bool _isGettingLocation = false;
  double? currentLatitude;
  double? currentLongitude;
  void filterCustomers(String value) {}
  void filterTemplates(String value) {}
  void filterProjects(String value) {}
  void filterProducts(String value) {}
  void calculateTotalExisting() {}
  late String token;
  late String userId;
  List<Staff> staffList = [];
  List<TaskState> allTaskStates = [];
  List<PrioState> allPriorities = [];
  bool whatsappNotification = false;
  bool pushNotification = false;
  bool notifyOnStart = false;
  bool notifyOnComplete = false;
  bool notifyToAssignedStaff = true;
  bool notifyOnStatusChange = false;
  bool notifyOtherPeople = false;
  List<String> selectedStaffIds = [];
  List<String> selectedAssignedStaffIds = [];
  bool _isAssigning = false;
  String? whatsappMenu;

  @override
  void initState() {
    super.initState();
   _loadModules();
  print("AssignWork callMasterId = ${widget.callMasterId}");
  print("AssignWork callLeadId = ${widget.callLeadId}");
    debugPrint('Work is paused? ${widget.isPaused == 1 ? "Yes" : "No"}');
    debugPrint('Work is restarted? ${widget.Restart == 1 ? "Yes" : "No"}');
    titleController = TextEditingController(
      text: widget.existingWork?.title_name ?? '',
    );
    log('''
===== Assign Work =====
Call Master ID : ${widget.callMasterId}
Call Lead ID   : ${widget.callLeadId}
Client Name    : ${widget.clientName}
=======================
''');
    _searchController.addListener(_filterProjects);
    tasks = widget.existingWork != null
        ? widget.existingWork!.tasks
            .map((task) => TaskForm(
                  controller: TextEditingController(text: task.taskName),
                  descriptionController:
                      TextEditingController(text: task.description ?? ''),
                  status: task.status,
                  taskId: task.taskId,
                  remarks: task.remarks
                      .map((remark) => TextEditingController(text: remark))
                      .toList(),
                ))
            .toList()
        : [
            TaskForm(
              controller: TextEditingController(),
              descriptionController: TextEditingController(),
              status: allTaskStates.isNotEmpty ? allTaskStates.first.id : null,
              taskId: null,
              remarks: [TextEditingController()],
            )
          ];

    if (widget.existingWork != null) {
      selectedProjectId = widget.existingWork!.projectId;
      selectedTitleId = widget.existingWork!.title;
      dueDate = widget.existingWork!.dueDate;
      priority = widget.existingWork!.priority;
      assignedTo = widget.existingWork!.assignedTo;
      if (selectedProjectId == "0") {
        selectedProjectId = null;
      }
    }
    if (widget.existingWork != null &&
        widget.existingWork!.assignedTo != null) {
      if (widget.existingWork!.assignedTo != null) {
        selectedStaffIds = [widget.existingWork!.assignedTo!];
      } else {
        selectedStaffIds = [];
      }
    } else if (assignedTo != null) {
      selectedStaffIds = [assignedTo!];
    }
    if (assignedTo != null && assignedTo!.isNotEmpty) {
      selectedAssignedStaffIds = assignedTo!.split(',').where((id) => id.trim().isNotEmpty && id.trim() != "0").toList();
    } else {
      selectedAssignedStaffIds = [];
    }
    whatsappNotification = false;
    pushNotification = false;
    notifyOnStart = false;
    notifyOnComplete = false;
    selectedStaffIds = [];
    _initAsync();
    _loadStaffs();
    _loadTaskState();
    _loadPrioState();
  }

  void _initAsync() async {
    token = await Common.getSharedPref("token") ?? "";
    userId = await Common.getSharedPref("userId");
    whatsappMenu = await Common.getSharedPref("whatsappMenu");
    if (whatsappMenu == null && token.isNotEmpty) {
      final object1 = await HttpService.userPermissionCheck(token);
      if (object1 != null && object1.status == true && object1.data != null) {
        whatsappMenu = object1.data!.whatsappMenu?.toString();
        if (whatsappMenu != null) {
          Common.saveSharedPref("whatsappMenu", whatsappMenu!);
        }
      }
    }
    await _loadProjects();
    setState(() {});
    // if (assignedTo == null) {
    //   setState(() {
    //     assignedTo = userId;
    //   });
    // }
  }

  Future<void> _loadProjects() async {
    try {
      final response = await HttpService.getProjectList();
      setState(() {
        projectList = response!.data;

        final uniqueProjects = <String, Projects>{};
        for (var project in projectList) {
          uniqueProjects[project.id] = project;
        }
        projectList = uniqueProjects.values.toList();
        filteredProjects = List.from(projectList);
        if (selectedProjectId != null) {
          final exists = projectList.any((p) => p.id == selectedProjectId);
          if (!exists) {
            selectedProjectId = null;
          }
          _loadTitle();
        }
        if (widget.existingWork != null && selectedProjectId != null) {
          final selectedProject =
              projectList.firstWhere((p) => p.id == selectedProjectId);
          selectedProjectName = selectedProject.name;
          selectedProjectController.text = selectedProject.name;
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        selectedProjectId = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load projects: $e')),
      );
    }
  }

  Future<void> _loadTitle() async {
    if (selectedProjectId == null) return;
    try {
      final response = await HttpService.getTitleList(selectedProjectId!);
      setState(() {
        titleList = response!.data;
        if (widget.existingWork != null &&
            widget.existingWork!.title.isNotEmpty) {
          final matchedTitle = titleList.firstWhere(
            (title) => title.id == widget.existingWork!.title,
            orElse: () => TitleListDet(
                id: widget.existingWork!.title,
                name: widget.existingWork!.title),
          );
          selectedTitleId = matchedTitle.id;
          titleController.text = matchedTitle.name;
          if (!titleList.any((t) => t.id == matchedTitle.id)) {
            titleList.add(matchedTitle);
          }
        }
      });
    } catch (e) {
      debugPrint('Error loading titles: $e');
    }
  }

  Future<void> _loadStaffs() async {
    final response = await HttpService.getStaffs();
    if (response != null && response.status == true) {
      setState(() {
        staffList = response.data;
        // if (assignedTo == null) {
        //   if (staffList.any((staff) => staff.userIdStaff == userId)) {
        //     assignedTo = userId;
        //   }
        // }
        notifyToAssignedStaff = true;
        notifyOnStatusChange = false;
        notifyOtherPeople = false;
        selectedStaffIds = [];
      });
    }
  }

  Future<void> _loadTaskState() async {
    final response = await HttpService.getTaskState();
    if (response != null && response.status == true) {
      setState(() {
        allTaskStates = response.data;
      });
      log("✅ Task States Loaded: ${allTaskStates.length}");
      for (var t in allTaskStates) {
        log("TaskState: id=${t.id}, status=${t.status}");
      }
    } else {
      log("❌ Failed to load task states or status is false");
    }
  }

  Future<void> _loadPrioState() async {
    final response = await HttpService.getPrioState();
    if (response != null && response.status == true) {
      setState(() {
        allPriorities = response.data;
        if (priority == null && allPriorities.isNotEmpty) {
          final highPriority = allPriorities.firstWhere(
            (p) => p.priority.toLowerCase() == 'medium',
            orElse: () => allPriorities.first,
          );
          priority = highPriority.id;
        }
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services are disabled.');
      return;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Location permission denied.');
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      debugPrint('Location permissions are permanently denied.');
      return;
    }
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      currentLatitude = position.latitude;
      currentLongitude = position.longitude;
    });
    debugPrint('Lat: ${position.latitude}, Long: ${position.longitude}');
  }
Future<void> _loadModules() async {
  final response =
      await HttpService.getLeadModules(widget.callMasterId);

  if (response != null && response.status) {
    setState(() {
      titleList = response.data
          .map(
            (module) => TitleListDet(
              id: module.id,
              name: module.module,
            ),
          )
          .toList();
    });
  }
}
  @override
  void dispose() {
    titleController.dispose();
    for (var task in tasks) {
      task.controller.dispose();
      for (var remark in task.remarksControllers) {
        remark.dispose();
      }
    }
    _searchController.dispose();
    super.dispose();
  }

  void _filterProjects() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProjects = projectList.where((project) {
        return project.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  void filterProjectsDialog(String query) {
    setState(() {
      filteredProjects = projectList
          .where((project) =>
              project.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _filteredProjects = projectList;
      }
    });
  }

  void _addRemarkField(int taskIndex) {
    setState(() {
      tasks[taskIndex].remarksControllers.add(TextEditingController());
    });
  }

  void _removeRemarkField(int taskIndex, int remarkIndex) {
    if (tasks[taskIndex].remarksControllers.length > 1) {
      setState(() {
        tasks[taskIndex].remarksControllers.removeAt(remarkIndex);
      });
    }
  }

  Future<void> _submitWork() async {
    if (_isAssigning) return;

    setState(() {
      _isAssigning = true;
    });

    try {
      // if (selectedProjectId == null) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(
      //       content: Text('Please select a project'),
      //       backgroundColor: Colors.red,
      //     ),
      //   );
      //   return;
      // }

      if (isLocationEnabled &&
          (currentLatitude == null || currentLongitude == null)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location not available yet.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (selectedTitleId == null ||
          selectedTitleId!.isEmpty ||
          titleController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a title'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      // Validate Task
      if (tasks.isEmpty ||
          tasks.every((task) => task.controller.text.trim().isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one task'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isAssigning = false);
        return;
      }

      // Validate each task
      for (int i = 0; i < tasks.length; i++) {
        if (tasks[i].controller.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Task ${i + 1} is mandatory'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => _isAssigning = false);
          return;
        }
      }
      final currentUserId = await Common.getSharedPref('user_id');
      if (!selectedAssignedStaffIds.contains(currentUserId)) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Confirm Assignment'),
            content: const Text(
              'Are you sure you want to assign this work?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Confirm'),
              ),
            ],
          ),
        );

        if (confirmed != true) {
          setState(() => _isAssigning = false);
          return;
        }
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final workData = {
        'work_id': widget.existingWork?.id,
        'project_id': selectedProjectId,
         'call_master_id': widget.callMasterId,
        'project_name': selectedProjectName,
        'title': titleController.text,
        'title_id': selectedTitleId,
        'due_date': dueDate != null
          ? DateFormat('yyyy-MM-dd HH:mm:ss').format(dueDate!)
          : null,
        'priority': priority,
        'assigned_to': assignedTo,
        'task_type': taskType,
        'category': category,
        'latitude': currentLatitude,
        'longitude': currentLongitude,
        'participant_ids': participantIds.join(','),
        'notification': {
          'whatsapp': whatsappNotification,
          'push': pushNotification,
          'notify_to_assigned': notifyToAssignedStaff,
          'notify_on_status_change': notifyOnStatusChange,
          'notify_other_people': notifyOtherPeople,
          'staff_ids': [
            if (notifyToAssignedStaff)
              ...selectedAssignedStaffIds,
            if (notifyOtherPeople)
              ...selectedStaffIds.where((id) => !selectedAssignedStaffIds.contains(id)),
          ].join(','),
          'on_start': notifyOnStart,
          'on_complete': notifyOnComplete,
        },
        'tasks': tasks.asMap().entries.map((entry) {
          final task = entry.value;
          return {
            'task_id': task.taskId,
            'description': task.controller.text,
            'task_description': task.descriptionController.text,
            'status': (task.status != null && task.status.toString().isNotEmpty)
                ? task.status
                : 1,
            'attachments': task.attachments
    .map((file) => file.path)
    .toList(),
            'remarks': task.remarksControllers
                .map((controller) => controller.text)
                .where((remark) => remark.isNotEmpty)
                .toList(),
          };
        }).toList(),
      };

      final response = widget.existingWork != null
          ? await HttpService.updateWorkData(workData)
          : await HttpService.assignWorkData(workData);

      Navigator.of(context).pop();

      if (response.status) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingWork != null
                ? 'Work stopped successfully!'
                : 'Work Assigned successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        await Future.delayed(const Duration(seconds: 1));
        if (context.mounted) {
          Navigator.pop(context, true);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Operation failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isAssigning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.existingWork != null;
    final isPausing = widget.isPaused == 1;
    final isRestarting = widget.Restart == 1;

    return AbsorbPointer(
      absorbing: _isAssigning,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: isEditing
              ? isPausing
                  ? Colors.orange[800]
                  : isRestarting
                      ? Colors.green[800]
                      : Colors.red[800]
              : Colors.blue,
          elevation: 2,
          shadowColor: Colors.black12,
          title: Row(
            children: [
              Icon(
                isEditing
                    ? isPausing
                        ? Icons.pause_circle_outline
                        : isRestarting
                            ? Icons.play_circle_outline
                            : FontAwesomeIcons.stop
                    : Icons.assignment_add,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Text(
                isEditing
                    ? isPausing
                        ? 'Pause Work'
                        : isRestarting
                            ? 'Restart Work'
                            : 'Stop Work'
                    : 'Assign New Work',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          centerTitle: false,
          actions: [
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(60, 255, 255, 255),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.close, size: 22),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    //padding: const EdgeInsets.all(20),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Container(
                        //   padding: const EdgeInsets.all(16),
                        //   decoration: BoxDecoration(
                        //     color: Colors.blue.withOpacity(0.05),
                        //     borderRadius: BorderRadius.circular(12),
                        //     border: Border.all(
                        //       color: Colors.blue.withOpacity(0.1),
                        //     ),
                        //   ),
                        //   child: Row(
                        //     children: [
                        //       Icon(
                        //         Icons.info_outline_rounded,
                        //         color: Colors.blue,
                        //         size: 24,
                        //       ),
                        //       const SizedBox(width: 12),
                        //       Expanded(
                        //         child: Text(
                        //           isEditing
                        //               ? 'You are ${isPausing ? 'pausing' : isRestarting ? 'restarting' : 'stopping'} an existing work assignment'
                        //               : 'Fill in the details below to assign new work',
                        //           style: TextStyle(
                        //             fontSize: 14,
                        //             color: Colors.grey[700],
                        //             fontWeight: FontWeight.w500,
                        //           ),
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // const SizedBox(height: 24),
                        // Card(
                        //   elevation: 1,
                        //   shape: RoundedRectangleBorder(
                        //     borderRadius: BorderRadius.circular(12),
                        //   ),
                        //   child: Padding(
                        //     padding: const EdgeInsets.all(20),
                        //     child: Column(
                        //       children: [
                        //         Row(
                        //           children: [
                        //             Icon(
                        //               Icons.folder_special_rounded,
                        //               color: Colors.blue,
                        //               size: 20,
                        //             ),
                        //             const SizedBox(width: 8),
                        //             Text(
                        //               'Project Details',
                        //               style: TextStyle(
                        //                 fontSize: 16,
                        //                 fontWeight: FontWeight.w600,
                        //                 color: Colors.grey[800],
                        //               ),
                        //             ),
                        //           ],
                        //         ),
                        //         const SizedBox(height: 16),
                        //         Row(
                        //           crossAxisAlignment: CrossAxisAlignment.start,
                        //           children: [
                        //             Expanded(
                        //               child: Column(
                        //                 crossAxisAlignment:
                        //                     CrossAxisAlignment.start,
                        //                 children: [
                        //                   Text(
                        //                     'Project *',
                        //                     style: TextStyle(
                        //                       fontSize: 14,
                        //                       fontWeight: FontWeight.w500,
                        //                       color: Colors.grey[700],
                        //                     ),
                        //                   ),
                        //                   const SizedBox(height: 6),
                        //                   Container(
                        //                     decoration: BoxDecoration(
                        //                       border: Border.all(
                        //                         color: Colors.grey.shade300,
                        //                       ),
                        //                       borderRadius:
                        //                           BorderRadius.circular(8),
                        //                     ),
                        //                     child: ListTile(
                        //                       onTap: () async {
                        //                         final selected =
                        //                             await dropDialogExisting(
                        //                                 context, "Projects");
                        //                         if (selected != null) {
                        //                           setState(() {
                        //                             selectedProjectId =
                        //                                 selected['id'];
                        //                             selectedProjectController
                        //                                     .text =
                        //                                 selected['name'] ?? '';
                        //                           });
                        //                           await _loadTitle();
                        //                         }
                        //                       },
                        //                       title: Text(
                        //                         selectedProjectController
                        //                                 .text.isEmpty
                        //                             ? 'Select Project'
                        //                             : selectedProjectController
                        //                                 .text,
                        //                         style: TextStyle(
                        //                           color:
                        //                               selectedProjectController
                        //                                       .text.isEmpty
                        //                                   ? Colors.grey[500]
                        //                                   : Colors.grey[800],
                        //                         ),
                        //                       ),
                        //                       trailing: const Icon(
                        //                         Icons.arrow_drop_down,
                        //                         color: Colors.grey,
                        //                       ),
                        //                       dense: true,
                        //                       contentPadding:
                        //                           const EdgeInsets.symmetric(
                        //                               horizontal: 12),
                        //                       shape: RoundedRectangleBorder(
                        //                         borderRadius:
                        //                             BorderRadius.circular(8),
                        //                       ),
                        //                     ),
                        //                   ),
                        //                 ],
                        //               ),
                        //             ),

                        //           ],
                        //         ),
                        //         const SizedBox(height: 16),
                        //         Row(
                        //           crossAxisAlignment: CrossAxisAlignment.start,
                        //           children: [

                        //             Expanded(
                        //               child: Column(
                        //                 crossAxisAlignment:
                        //                     CrossAxisAlignment.start,
                        //                 children: [
                        //                   Text(
                        //                     'Module *',
                        //                     style: TextStyle(
                        //                       fontSize: 14,
                        //                       fontWeight: FontWeight.w500,
                        //                       color: Colors.grey[700],
                        //                     ),
                        //                   ),
                        //                   const SizedBox(height: 6),
                        //                   Container(
                        //                     decoration: BoxDecoration(
                        //                       border: Border.all(
                        //                         color: Colors.grey.shade300,
                        //                       ),
                        //                       borderRadius:
                        //                           BorderRadius.circular(8),
                        //                     ),
                        //                     child: ListTile(
                        //                       onTap: () async {
                        //                         final selected =
                        //                             await dropTitleDialog(
                        //                                 context, titleList);
                        //                         if (selected != null) {
                        //                           setState(() {
                        //                             selectedTitleId =
                        //                                 selected['id'];
                        //                             titleController.text =
                        //                                 selected['name']!;
                        //                           });
                        //                         }
                        //                       },
                        //                       title: Text(
                        //                         titleController.text.isEmpty
                        //                             ? 'Select Module'
                        //                             : titleController.text,
                        //                         style: TextStyle(
                        //                           color: titleController
                        //                                   .text.isEmpty
                        //                               ? Colors.grey[500]
                        //                               : Colors.grey[800],
                        //                         ),
                        //                       ),
                        //                       trailing: Row(
                        //                         mainAxisSize: MainAxisSize.min,
                        //                         children: [
                        //                           IconButton(
                        //                             icon: const Icon(
                        //                               Icons.add,
                        //                               size: 18,
                        //                             ),
                        //                             onPressed: () async {
                        //                               final newTitle =
                        //                                   await showProjectTitleDialog(
                        //                                       context);
                        //                               if (newTitle != null) {
                        //                                 setState(() {
                        //                                   titleList
                        //                                       .add(newTitle);
                        //                                   selectedTitleId =
                        //                                       newTitle.id;
                        //                                   titleController.text =
                        //                                       newTitle.name;
                        //                                 });
                        //                               }
                        //                             },
                        //                           ),
                        //                           const Icon(
                        //                             Icons.arrow_drop_down,
                        //                             color: Colors.grey,
                        //                           ),
                        //                         ],
                        //                       ),
                        //                       dense: true,
                        //                       contentPadding:
                        //                           const EdgeInsets.symmetric(
                        //                               horizontal: 8),
                        //                       shape: RoundedRectangleBorder(
                        //                         borderRadius:
                        //                             BorderRadius.circular(8),
                        //                       ),
                        //                     ),
                        //                   ),
                        //                 ],
                        //               ),
                        //             ),
                        //           ],
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                       Card(
  elevation: 1,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        Row(
          children: [
            const Icon(
              Icons.folder_special_rounded,
              color: Colors.blue,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Project Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Client Name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Client Name',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.clientName ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Module Field
                           Expanded(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Module *',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.grey[700],
        ),
      ),
      const SizedBox(height: 4),
      Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: ListTile(
          onTap: () async {
  if (titleList.isEmpty) {
    await _loadModules();
  }

  final selected =
      await dropTitleDialog(context, titleList);

  if (selected != null) {
    setState(() {
      selectedTitleId = selected['id'];
      titleController.text = selected['name'] ?? '';
    });
  }
},
          title: Text(
            titleController.text.isEmpty
                ? 'Select Module'
                : titleController.text,
            style: TextStyle(
              fontSize: 14,
              color: titleController.text.isEmpty
                  ? Colors.grey[500]
                  : Colors.grey[800],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.add,
                  size: 16,
                ),
                onPressed: () async {
                  final newModule =
                      await showProjectTitleDialog(context);

                  if (newModule != null) {
                    setState(() {
                      titleList.add(newModule);
                      selectedTitleId = newModule.id;
                      titleController.text = newModule.name;
                    });
                  }
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
              ),
              const Icon(
                Icons.arrow_drop_down,
                color: Colors.grey,
                size: 20,
              ),
            ],
          ),
          dense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          minVerticalPadding: 0,
          minLeadingWidth: 0,
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
                        Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.schedule_rounded,
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Work Details',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Due Date & Time',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        GestureDetector(
                                          onTap: () async {
                                            final now = DateTime.now();

                                            // Pick Date
                                            final pickedDate = await showDatePicker(
                                              context: context,
                                              initialDate: dueDate ?? now,
                                              firstDate: DateTime(now.year, now.month, now.day),
                                              lastDate: DateTime(2100),
                                            );

                                            if (pickedDate == null) return;

                                            TimeOfDay? pickedTime;

                                            while (true) {
                                              pickedTime = await showTimePicker(
                                                context: context,
                                                initialTime: TimeOfDay.fromDateTime(
                                                  pickedDate.year == now.year &&
                                                          pickedDate.month == now.month &&
                                                          pickedDate.day == now.day
                                                      ? now
                                                      : DateTime(
                                                          pickedDate.year,
                                                          pickedDate.month,
                                                          pickedDate.day,
                                                          9,
                                                          0,
                                                        ),
                                                ),
                                              );

                                              if (pickedTime == null) {
                                                // User cancelled
                                                return;
                                              }

                                              final selectedDateTime = DateTime(
                                                pickedDate.year,
                                                pickedDate.month,
                                                pickedDate.day,
                                                pickedTime.hour,
                                                pickedTime.minute,
                                              );

                                              if (!selectedDateTime.isBefore(now)) {
                                                setState(() {
                                                  dueDate = selectedDateTime;
                                                });
                                                break;
                                              }

                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Past time is not allowed. Please select the current or a future time.',
                                                  ),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(14),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.grey.shade300,
                                              ),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.calendar_today,
                                                  size: 20,
                                                  color: Colors.grey[600],
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    dueDate != null
                                                        ? DateFormat('dd-MM-yyyy hh:mm a')
                                                            .format(dueDate!)
                                                        : 'Select Date & Time',
                                                    style: TextStyle(
                                                      color: dueDate != null
                                                          ? Colors.grey[800]
                                                          : Colors.grey[500],
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
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Priority',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey.shade300),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButtonFormField<
                                                  String>(
                                                isExpanded: true,
                                                value: priority,
                                                items:
                                                    allPriorities.map((prio) {
                                                  Color priorityColor;
                                                  switch (prio.priority
                                                      .toLowerCase()) {
                                                    case 'high':
                                                      priorityColor =
                                                          const Color.fromARGB(
                                                              255,
                                                              244,
                                                              155,
                                                              54);
                                                      break;
                                                    case 'medium':
                                                      priorityColor =
                                                          Colors.orange;
                                                      break;
                                                    case 'normal':
                                                      priorityColor =
                                                          const Color.fromARGB(
                                                              255, 43, 233, 75);
                                                      break;
                                                    case 'critical':
                                                      priorityColor =
                                                          const Color.fromARGB(
                                                              255, 255, 29, 29);
                                                      break;
                                                    case 'low':
                                                      priorityColor =
                                                          Colors.green;
                                                      break;
                                                    default:
                                                      priorityColor =
                                                          Colors.grey;
                                                  }
                                                  return DropdownMenuItem(
                                                    value: prio.id,
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                          width: 12,
                                                          height: 12,
                                                          decoration:
                                                              BoxDecoration(
                                                            color:
                                                                priorityColor,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 12),
                                                        Expanded(
                                                          child: Text(
                                                            prio.priority,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }).toList(),
                                                onChanged: (value) =>
                                                    setState(() {
                                                  priority = value;
                                                }),
                                                decoration:
                                                    const InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          horizontal: 12),
                                                  border: InputBorder.none,
                                                ),
                                              ),
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
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Task Type',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey.shade300),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButtonFormField<
                                                  String>(
                                                value: taskType,
                                                items: taskTypes.map((type) {
                                                  return DropdownMenuItem(
                                                    value: type,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 12),
                                                      child: Text(type),
                                                    ),
                                                  );
                                                }).toList(),
                                                onChanged: (value) {
                                                  setState(() {
                                                    taskType = value!;
                                                  });
                                                },
                                                decoration:
                                                    const InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          horizontal: 12),
                                                  border: InputBorder.none,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Category',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey.shade300),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButtonFormField<
                                                  String>(
                                                value: category,
                                                items: categories.map((cat) {
                                                  return DropdownMenuItem(
                                                    value: cat,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 12),
                                                      child: Text(cat),
                                                    ),
                                                  );
                                                }).toList(),
                                                onChanged: (value) {
                                                  setState(() {
                                                    category = value!;
                                                  });
                                                },
                                                decoration:
                                                    const InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          horizontal: 12),
                                                  border: InputBorder.none,
                                                ),
                                              ),
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
                        //  const SizedBox(height: 10),
                        Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.person_rounded,
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Assignment',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Assigned To',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    GestureDetector(
                                      onTap: () async {
                                        await _showMultiAssignedStaffSelectionDialog(context);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: Colors.white,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.person_outline_rounded,
                                              color: Colors.grey[600],
                                              size: 22,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                _getAssignedStaffNames(),
                                                style: TextStyle(
                                                  color: selectedAssignedStaffIds.isNotEmpty
                                                      ? Colors.grey[800]
                                                      : Colors.grey[500],
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            Icon(
                                              Icons.arrow_drop_down,
                                              color: Colors.grey[600],
                                              size: 24,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.checklist_rounded,
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Tasks',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                ...List.generate(tasks.length, (taskIndex) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey.shade200),
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.white,
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Task ${taskIndex + 1}',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.grey[700],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  TextField(
                                                    controller: tasks[taskIndex]
                                                        .controller,
                                                    minLines: 1,
                                                    maxLines: 2,
                                                    decoration: InputDecoration(
                                                      hintText: 'Task *',
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      contentPadding:
                                                          const EdgeInsets.all(
                                                              12),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Container(
                                              width: 120,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Status',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.grey[700],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors
                                                              .grey.shade300),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child:
                                                        DropdownButtonHideUnderline(
                                                      child:
                                                          DropdownButtonFormField<
                                                              String>(
                                                        isExpanded: true,
                                                        value: tasks[taskIndex]
                                                                .status ??
                                                            (allTaskStates
                                                                    .isNotEmpty
                                                                ? allTaskStates
                                                                    .first.id
                                                                : null),
                                                        items: allTaskStates
                                                                .isNotEmpty
                                                            ? allTaskStates
                                                                .map((status) {
                                                                return DropdownMenuItem(
                                                                  value:
                                                                      status.id,
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            12),
                                                                    child: Text(
                                                                      status
                                                                          .status,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      maxLines:
                                                                          1,
                                                                    ),
                                                                  ),
                                                                );
                                                              }).toList()
                                                            : [],
                                                        onChanged: (value) =>
                                                            setState(() {
                                                          tasks[taskIndex]
                                                              .status = value;
                                                        }),
                                                        decoration:
                                                            const InputDecoration(
                                                          contentPadding:
                                                              EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          4),
                                                          border:
                                                              InputBorder.none,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (taskIndex > 0)
                                              IconButton(
                                                icon: Container(
                                                  padding:
                                                      const EdgeInsets.all(6),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red[50],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: Icon(
                                                    Icons.close,
                                                    size: 18,
                                                    color: Colors.red[700],
                                                  ),
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    tasks.removeAt(taskIndex);
                                                  });
                                                },
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              TextField(
                                                controller: tasks[taskIndex].descriptionController,
                                                minLines: 2,
                                                maxLines: 4,
                                                decoration: InputDecoration(
                                                  hintText: 'Task description',
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  contentPadding: const EdgeInsets.all(12),
                                                ),
                                              ),

                                              const SizedBox(height: 12),

                                              InkWell(
                                                onTap: () async {
                                                  FilePickerResult? result =
                                                      await FilePicker.platform.pickFiles(
                                                    allowMultiple: true,
                                                  );

                                                  if (result != null) {
                                                    setState(() {
                                                      tasks[taskIndex].attachments.addAll(
                                                        result.paths
                                                            .where((path) => path != null)
                                                            .map((path) => File(path!))
                                                            .toList(),
                                                      );
                                                    });
                                                  }
                                                },
                                                child: Container(
                                                  width: double.infinity,
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 14,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: Colors.grey.shade300,
                                                    ),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.attach_file,
                                                        color: Colors.grey[600],
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Expanded(
                                                        child: Text(
                                                          'Upload Files',
                                                          style: TextStyle(
                                                            color: Colors.grey[700],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),

                                              if (tasks[taskIndex].attachments.isNotEmpty)
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 10),
                                                  child: Column(
                                                    children: tasks[taskIndex]
                                                        .attachments
                                                        .asMap()
                                                        .entries
                                                        .map((entry) {
                                                      final fileIndex = entry.key;
                                                      final file = entry.value;

                                                      return Container(
                                                        margin: const EdgeInsets.only(bottom: 8),
                                                        padding: const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 8,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: Colors.grey.shade100,
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            const Icon(Icons.insert_drive_file),
                                                            const SizedBox(width: 8),
                                                            Expanded(
                                                              child: Text(
                                                                file.path.split('/').last,
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                            ),
                                                            IconButton(
                                                              icon: const Icon(
                                                                Icons.close,
                                                                color: Colors.red,
                                                              ),
                                                              onPressed: () {
                                                                setState(() {
                                                                  tasks[taskIndex]
                                                                      .attachments
                                                                      .removeAt(fileIndex);
                                                                });
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                              ],
                                    
                                    ),
                                  );
                                }),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        tasks.add(TaskForm(
                                          controller: TextEditingController(),
                                          descriptionController:
                                              TextEditingController(),
                                          status: allTaskStates.isNotEmpty
                                              ? allTaskStates.first.id
                                              : null,
                                          taskId: null,
                                          attachments: [],
                                          remarks: [TextEditingController()],
                                        ));
                                      });
                                    },
                                    icon: const Icon(Icons.add,
                                        size: 18, color: Colors.white),
                                    label: const Text('Add Task'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.notifications_rounded,
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Notification Settings',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                if (whatsappMenu == "true") ...[
                                  _buildNotificationOption(
                                    icon: FontAwesomeIcons.whatsapp,
                                    iconColor: Colors.green,
                                    title: 'WhatsApp Notification',
                                    value: whatsappNotification,
                                    onChanged: (value) => setState(() {
                                      whatsappNotification = value;
                                    }),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                const SizedBox(height: 12),
                                _buildNotificationOption(
                                  icon: Icons.notifications_active_rounded,
                                  iconColor: Colors.blue,
                                  title: 'Push Notification',
                                  value: pushNotification,
                                  onChanged: (value) => setState(() {
                                    pushNotification = value;
                                  }),
                                ),
                                const SizedBox(height: 12),

                                // Notify to Assigned Staff
                                _buildNotificationOption(
                                  icon: Icons.person_rounded,
                                  iconColor: Colors.orange,
                                  title: 'Notify to Assigned Staff',
                                  value: notifyToAssignedStaff,
                                  onChanged: (value) => setState(() {
                                    notifyToAssignedStaff = value;
                                  }),
                                ),
                                const SizedBox(height: 12),

                                // Notify on Status Change
                                _buildNotificationOption(
                                  icon: Icons.change_circle_rounded,
                                  iconColor: Colors.purple,
                                  title: 'Notify on Status Change',
                                  value: notifyOnStatusChange,
                                  onChanged: (value) => setState(() {
                                    notifyOnStatusChange = value;
                                  }),
                                ),
                                const SizedBox(height: 12),

                                // Notify When Work Starts
                                _buildNotificationOption(
                                  icon: Icons.play_arrow_rounded,
                                  iconColor: Colors.teal,
                                  title: 'Notify When Work Starts',
                                  value: notifyOnStart,
                                  onChanged: (value) => setState(() {
                                    notifyOnStart = value;
                                  }),
                                ),
                                const SizedBox(height: 12),

                                // Notify When Work Completes
                                _buildNotificationOption(
                                  icon: Icons.check_circle_rounded,
                                  iconColor: Colors.green,
                                  title: 'Notify When Work Completes',
                                  value: notifyOnComplete,
                                  onChanged: (value) => setState(() {
                                    notifyOnComplete = value;
                                  }),
                                ),
                                const SizedBox(height: 12),

                                // Notify Other People
                                _buildNotificationOption(
                                  icon: Icons.group_rounded,
                                  iconColor: Colors.indigo,
                                  title: 'Notify Other People',
                                  value: notifyOtherPeople,
                                  onChanged: (value) {
                                    setState(() {
                                      notifyOtherPeople = value;
                                      if (!notifyOtherPeople) {
                                        selectedStaffIds.clear();
                                      }
                                    });
                                  },
                                ),

                                if (notifyOtherPeople) ...[
                                  const SizedBox(height: 16),
                                  Text(
                                    'Select Staff to Notify:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: () => _showMultiStaffSelectionDialog(
                                        context, false),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.white,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.group_add_rounded,
                                                color: Colors.grey[600],
                                                size: 20,
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                selectedStaffIds.isEmpty
                                                    ? 'Select Staff to Notify'
                                                    : '${selectedStaffIds.length} staff selected',
                                                style: TextStyle(
                                                  color:
                                                      selectedStaffIds.isEmpty
                                                          ? Colors.grey[500]
                                                          : Colors.grey[800],
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Icon(
                                            Icons.arrow_drop_down,
                                            color: Colors.grey[600],
                                            size: 24,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 16),
                                Text(
                                  'Participants in Chat',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () => _showMultiStaffSelectionDialog(
                                      context, true),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.white,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.chat_bubble_outline_rounded,
                                              color: Colors.grey[600],
                                              size: 20,
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              participantIds.isEmpty
                                                  ? 'Select Chat Participants'
                                                  : '${participantIds.length} participants selected',
                                              style: TextStyle(
                                                color: participantIds.isEmpty
                                                    ? Colors.grey[500]
                                                    : Colors.grey[800],
                                                fontSize: 15,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Icon(
                                          Icons.arrow_drop_down,
                                          color: Colors.grey[600],
                                          size: 24,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
                // Action Button
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Colors.grey[200]!)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isAssigning ? null : _submitWork,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isEditing
                          ? isPausing
                              ? Colors.orange[800]
                              : isRestarting
                                  ? Colors.green[800]
                                  : Colors.red[800]
                          : Colors.blue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isAssigning
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isEditing
                                    ? isPausing
                                        ? Icons.pause_rounded
                                        : isRestarting
                                            ? Icons.play_arrow_rounded
                                            : Icons.stop_rounded
                                    : Icons.assignment_turned_in_rounded,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                isEditing
                                    ? isPausing
                                        ? 'PAUSE WORK'
                                        : isRestarting
                                            ? 'RESTART WORK'
                                            : 'STOP WORK'
                                    : 'ASSIGN WORK',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
            if (_isAssigning)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper widget for notification options
  Widget _buildNotificationOption({
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[50],
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Transform.scale(
            scale: 0.9,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: iconColor,
            ),
          ),
        ],
      ),
    );
  }

  // All existing methods remain the same from original code
  Future<dynamic> dropDialogExisting(BuildContext context, String title) {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              scrollable: true,
              title: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          search.clear();
                          Navigator.pop(context);
                        },
                        child: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: TextField(
                      controller: search,
                      autocorrect: false,
                      keyboardType: TextInputType.text,
                      autofocus: true,
                      onChanged: (value) {
                        setState(() {
                          if (title == "Projects") {
                            filterProjectsDialog(value);
                          } else if (title == "Customers") {
                            filterCustomers(value);
                          } else if (title == "Template") {
                            filterTemplates(value);
                          } else {
                            filterProducts(value);
                          }
                        });
                      },
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.only(left: 8),
                        labelStyle: TextStyle(color: Colors.grey),
                        labelText: 'Search...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              content: SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                width: MediaQuery.of(context).size.width * 0.8,
                child: ListView.builder(
                  itemCount: title == "Projects"
                      ? filteredProjects.length
                      : title == "Customers"
                          ? filteredNames.length
                          : title == "Template"
                              ? filteredTemplates.length
                              : filteredProducts.length,
                  itemBuilder: (context, index) {
                    final project =
                        title == "Projects" ? filteredProjects[index] : null;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: const Color(0xFFFCFBFA),
                        ),
                        child: ListTile(
                          onTap: () {
                            if (title == "Projects") {
                              final project = filteredProjects[index];
                              selectedProjectId = project.id;
                              selectedProjectName = project.name;
                              selectedProjectController.text = project.name;
                            } else if (title == "Customers") {
                              customerIdExisting = filteredNames[index].id;
                              customerNameExisting.text =
                                  filteredNames[index].name;
                            } else if (title == "Template") {
                              templateIdExisting = filteredTemplates[index].id;
                              remindMeExisting.text =
                                  filteredTemplates[index].templateName;
                            } else {
                              final p = filteredProducts[index];
                              productIdExisting = p.id;
                              productNameExisting.text = p.productName;
                              prodRateExisting.text = p.sellingPrice;
                              prodTaxExisting.text = p.taxPercent;
                              typeDuration = p.noOfDays;
                              calculateTotalExisting();
                            }
                            Navigator.pop(context, {
                              'id': project!.id,
                              'name': project.name,
                            });
                            setState(() {});
                            search.clear();
                            return;
                          },
                          title: Text(
                            title == "Projects"
                                ? filteredProjects[index].name
                                : title == "Customers"
                                    ? filteredNames[index].name
                                    : title == "Template"
                                        ? filteredTemplates[index].templateName
                                        : filteredProducts[index].productName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                          leading: CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.white,
                            child: (title == "Projects" &&
                                        filteredProjects.isEmpty) ||
                                    (title == "Customers" &&
                                        filteredNames.isEmpty) ||
                                    (title == "Template" &&
                                        filteredTemplates.isEmpty) ||
                                    (title == "Products" &&
                                        filteredProducts.isEmpty)
                                ? const Center(child: Text('No items found'))
                                : ListView.builder(
                                    itemCount: title == "Projects"
                                        ? filteredProjects.length
                                        : title == "Customers"
                                            ? filteredNames.length
                                            : title == "Template"
                                                ? filteredTemplates.length
                                                : filteredProducts.length,
                                    itemBuilder: (context, index) {
                                      return null;
                                    },
                                  ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<Map<String, String>?> dropTitleDialog(
      BuildContext context, List<TitleListDet> titleList) async {
    TextEditingController searchController = TextEditingController();
    final FocusNode searchFocusNode = FocusNode();
    List<TitleListDet> filteredTitles = List.from(titleList);

    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!searchFocusNode.hasFocus) {
                FocusScope.of(context).requestFocus(searchFocusNode);
              }
            });

            return AlertDialog(
              scrollable: true,
              title: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    focusNode: searchFocusNode,
                    controller: searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search Modules...',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        filteredTitles = titleList
                            .where((t) => t.name
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                            .toList();
                      });
                    },
                  ),
                ],
              ),
              content: SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                width: MediaQuery.of(context).size.width * 0.8,
                child: ListView.builder(
                  itemCount: filteredTitles.length,
                  itemBuilder: (context, index) {
                    final title = filteredTitles[index];
                    return ListTile(
                      title: Text(title.name),
                      onTap: () {
                        Navigator.pop(context, {
                          'id': title.id,
                          'name': title.name,
                        });
                      },
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<TitleListDet?> showProjectTitleDialog(BuildContext context) async {
  TextEditingController titleController = TextEditingController();

  return showDialog<TitleListDet>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Add Module'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'Module',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter module name'),
                  ),
                );
                return;
              }

              final newTitle = await HttpService.submitModule(
                context: context,
                leadId: widget.callMasterId,
                title: titleController.text.trim(),
              );
              print("newTitle id = ${newTitle?.id}");
              print("newTitle name = ${newTitle?.name}");
              if (newTitle != null) {
                Navigator.pop(context, newTitle);
              }
            },
            child: const Text('Submit'),
          ),
        ],
      );
    },
  );
}
  Future<Map<String, String>?> _showStaffSearchDialog(
      BuildContext context) async {
    TextEditingController searchController = TextEditingController();
    FocusNode focusNode = FocusNode();
    List<Staff> filteredStaff = List.from(staffList);
    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        Future.delayed(Duration(milliseconds: 100), () {
          FocusScope.of(context).requestFocus(focusNode);
        });
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Staff'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchController,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        labelText: 'Search Staff',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {
                          filteredStaff = staffList
                              .where((staff) => staff.name
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredStaff.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return ListTile(
                              title: const Text('Unassigned'),
                              onTap: () {
                                Navigator.pop(context, {
                                  'id': '0',
                                  'name': 'Unassigned',
                                });
                              },
                            );
                          }
                          final staff = filteredStaff[index - 1];
                          return ListTile(
                            title: Text(staff.name),
                            onTap: () {
                              Navigator.pop(context, {
                                'id': staff.userIdStaff,
                                'name': staff.name,
                              });
                            },
                          );
                        },
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

  Future<void> _showMultiStaffSelectionDialog(
      BuildContext context, bool isForParticipants) async {
    final currentSelection =
        isForParticipants ? participantIds : selectedStaffIds;
    final selected = await showDialog<List<String>>(
      context: context,
      builder: (context) {
        final tempSelected = List<String>.from(currentSelection);
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isForParticipants
                  ? 'Select Chat Participants'
                  : 'Select Staff to Notify'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Search Staff',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {},
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: staffList.length,
                        itemBuilder: (context, index) {
                          final staff = staffList[index];
                          return CheckboxListTile(
                            title: Text(staff.name),
                            value: tempSelected.contains(staff.userIdStaff),
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  tempSelected.add(staff.userIdStaff);
                                } else {
                                  tempSelected.remove(staff.userIdStaff);
                                }
                              });
                            },
                          );
                        },
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
                  onPressed: () => Navigator.pop(context, tempSelected),
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
    if (selected != null) {
      setState(() {
        if (isForParticipants) {
          participantIds = selected;
        } else {
          selectedStaffIds = selected;
        }
      });
    }
  }

  String _getAssignedStaffNames() {
    if (selectedAssignedStaffIds.isEmpty) {
      if (assignedTo == "0") return 'Unassigned';
      return 'Select Staff';
    }
    final names = selectedAssignedStaffIds
        .map((id) {
          final staff = staffList.firstWhere(
            (s) => s.userIdStaff == id,
            orElse: () => Staff(id: '', name: '', userIdStaff: ''),
          );
          return staff.name;
        })
        .where((name) => name.isNotEmpty)
        .toList();

    if (names.isEmpty) return 'Select Staff';
    return names.join(', ');
  }

  Future<void> _showMultiAssignedStaffSelectionDialog(
      BuildContext context) async {
    final selected = await showDialog<List<String>>(
      context: context,
      builder: (context) {
        final tempSelected = List<String>.from(selectedAssignedStaffIds);
        List<Staff> filteredStaff = List.from(staffList);
        TextEditingController searchController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Assigned Staff'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        labelText: 'Search Staff',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {
                          filteredStaff = staffList
                              .where((staff) => staff.name
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredStaff.length,
                        itemBuilder: (context, index) {
                          final staff = filteredStaff[index];
                          return CheckboxListTile(
                            title: Text(staff.name),
                            value: tempSelected.contains(staff.userIdStaff),
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  tempSelected.add(staff.userIdStaff);
                                } else {
                                  tempSelected.remove(staff.userIdStaff);
                                }
                              });
                            },
                          );
                        },
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
                  onPressed: () => Navigator.pop(context, tempSelected),
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
    if (selected != null) {
      setState(() {
        selectedAssignedStaffIds = selected;
        assignedTo = selectedAssignedStaffIds.isNotEmpty
            ? selectedAssignedStaffIds.join(',')
            : null;
      });
    }
  }
}

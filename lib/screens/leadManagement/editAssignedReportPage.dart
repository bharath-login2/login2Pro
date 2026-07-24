import 'dart:io';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/lead_management/AssignedWorkModel.dart';
import 'package:login2/models/lead_management/priorityStatusModel.dart';
import 'package:login2/models/lead_management/projectList_model.dart';
import 'package:login2/models/lead_management/taskStatusModel.dart';
import 'package:login2/models/lead_management/titleListModel.dart';
import 'package:login2/service/service.dart';
import 'package:login2/models/expense/staffListModel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
class EditTaskForm {
  TextEditingController controller;
  TextEditingController descriptionController;
  String? status;
  String? taskId;
  List<TextEditingController> remarksControllers;
  bool isExisting;

  EditTaskForm({
    required this.controller,
    required this.descriptionController,
    this.status,
    this.taskId,
    List<TextEditingController>? remarks,
    this.isExisting = false,
  }) : remarksControllers = remarks ?? [TextEditingController()];
}

class EditWorkPage extends StatefulWidget {
  final AssignedWork assignedWork;
  final Function() onSuccess;

  const EditWorkPage({
    super.key,
    required this.assignedWork,
    required this.onSuccess,
  });

  @override
  _EditWorkPageState createState() => _EditWorkPageState();
}

class _EditWorkPageState extends State<EditWorkPage> {
  late TextEditingController titleController;
  late List<EditTaskForm> tasks = [];
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
  bool _isUpdating = false;
  bool _hasChanges = false;
  late Map<String, dynamic> _originalData;
  List<int> deletedAttachmentIds = [];
  List<String> deletedAttachmentFileIds = [];
  List<File> newAttachments = [];
Map<int, List<File>> taskAttachments = {};
 String? whatsappMenu;
Future<void> _openAttachment(String url) async {
  final uri = Uri.tryParse(url);

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
    final launched = await canLaunchUrl(uri);

    if (!mounted) return;

    if (launched) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
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
Future<void> _pickAttachments(int taskIndex) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    allowMultiple: true,
  );

  if (result != null) {
    setState(() {
      taskAttachments.putIfAbsent(taskIndex, () => []);

      taskAttachments[taskIndex]!.addAll(
        result.files
            .where((file) => file.path != null)
            .map((file) => File(file.path!)),
      );

      _checkForChanges();
    });
  }
}
  @override
  void initState() {
    super.initState();
    _initializeData();
    _searchController.addListener(_filterProjects);
    _initAsync();
    _loadStaffs();
    _loadTaskState();
    _loadPrioState();
    _loadProjectAndTitleData();
    log("📊 AssignedWork Data:");
    log("- Work ID: ${widget.assignedWork.id}");
    log("- Project ID: ${widget.assignedWork.projectId}");
    log("- Project Name: ${widget.assignedWork.projectName}");
    log("- Module Name: ${widget.assignedWork.moduleName}");
    log("- Task ID: ${widget.assignedWork.taskId}");
    // log("- Title: ${widget.assignedWork.title}");
  }

  void _initializeData() {
    final work = widget.assignedWork;
    titleController = TextEditingController(text: work.projectName);
    selectedProjectId = work.projectId.toString();
    selectedProjectName = work.projectName;
    selectedProjectController.text = work.projectName;
    selectedTitleId = '';
    titleController.text = work.moduleName ?? '';
    log("🔍 Initializing Title Data:");
    log("- Module Name from API: ${work.moduleName}");
    log("- Selected Title ID (initial): $selectedTitleId");
    log("🔍 Work Sessions (${work.workSessions.length}):");
    for (var i = 0; i < work.workSessions.length; i++) {
      var session = work.workSessions[i];
      log("  - Session $i: ${session.taskName}");
      log("    Task ID: ${session.taskId}");
    }

    if (work.dueDate.isNotEmpty) {
      try {
        dueDate = DateFormat('dd-MM-yyyy hh:mm a').parse(work.dueDate);
        log("Parsed Due Date: $dueDate");
      } catch (e) {
        log("Due Date Parse Error: $e");
        dueDate = null;
      }
    }

    priority = _mapPriorityToId(work.priority);
    assignedTo = work.assignedToId?.toString();
    whatsappNotification = false;
    pushNotification = false;
    notifyOnStart = false;
    notifyOnComplete = false;
    notifyToAssignedStaff = true;
    notifyOnStatusChange = false;
    notifyOtherPeople = false;

    // Initialize tasks with proper task IDs
    if (work.workSessions.isNotEmpty) {
      tasks = work.workSessions.map((session) {
        final remarkList = session.remark.isNotEmpty
            ? session.remark
                .split(',')
                .map((r) => TextEditingController(text: r.trim()))
                .toList()
            : [TextEditingController()];

        // IMPORTANT: Get the actual task ID from the session
        // You need to add taskId to your WorkSession model
        String taskId = session.taskId ?? ""; // Get from session

        return EditTaskForm(
          controller: TextEditingController(text: session.taskName),
          descriptionController:
              TextEditingController(text: session.description),
          status: _mapStatusToId(session.status),
          taskId: taskId, // Pass the actual task ID
          remarks: remarkList,
          isExisting: true,
        );
      }).toList();
    } else {
      // For single task (no work sessions)
      tasks.add(EditTaskForm(
        controller: TextEditingController(text: work.taskName),
        descriptionController:
            TextEditingController(text: work.taskDescription),
        status: _mapStatusToId(work.status),
        taskId: "", // Empty for new tasks or get from work.taskId if exists
        isExisting: false,
        remarks: [TextEditingController()],
      ));
    }

    _originalData = _getCurrentData();
  }

  // void _initializeData() {
  //   final work = widget.assignedWork;
  //   titleController = TextEditingController(text: work.projectName);
  //   selectedProjectId = work.id.toString();
  //   selectedProjectName = work.projectName;
  //   selectedProjectController.text = work.projectName;
  //   selectedTitleId = work.moduleName;
  //   titleController.text = work.moduleName;
  //   if (work.dueDate.isNotEmpty) {
  //     try {
  //       final parsedDate = DateFormat('yyyy-MM-dd').parse(work.dueDate);
  //       dueDate = parsedDate;
  //     } catch (e) {
  //       try {
  //         final parsedDate = DateFormat('dd-MM-yyyy').parse(work.dueDate);
  //         dueDate = parsedDate;
  //       } catch (e) {
  //         dueDate = null;
  //       }
  //     }
  //   }

  //   priority = _mapPriorityToId(work.priority);
  //   assignedTo = work.assignedToId?.toString();
  //   whatsappNotification = false;
  //   pushNotification = false;
  //   notifyOnStart = false;
  //   notifyOnComplete = false;
  //   notifyToAssignedStaff = true;
  //   notifyOnStatusChange = false;
  //   notifyOtherPeople = false;
  //   if (work.workSessions.isNotEmpty) {
  //     tasks = work.workSessions.map((session) {
  //       final remarkList = session.remark.isNotEmpty
  //           ? session.remark
  //               .split(',')
  //               .map((r) => TextEditingController(text: r.trim()))
  //               .toList()
  //           : [TextEditingController()];
  //       return EditTaskForm(
  //         controller: TextEditingController(text: session.taskName),
  //         descriptionController:
  //             TextEditingController(text: session.description),
  //         status: _mapStatusToId(session.status),
  //         taskId: "",
  //         remarks: remarkList,
  //         isExisting: true,
  //       );
  //     }).toList();
  //   } else {
  //     tasks.add(EditTaskForm(
  //       controller: TextEditingController(text: work.taskName),
  //       descriptionController:
  //           TextEditingController(text: work.taskDescription),
  //       status: _mapStatusToId(work.status),
  //       isExisting: false,
  //       remarks: [TextEditingController()],
  //     ));
  //   }

  //   _originalData = _getCurrentData();
  // }

  String _mapPriorityToId(String priorityText) {
    switch (priorityText.toLowerCase()) {
      case 'normal':
      case '1':
        return '1';
      case 'high':
      case '2':
        return '2';
      case 'critical':
      case '3':
        return '3';
      default:
        return '1';
    }
  }

  String _mapStatusToId(String statusText) {
    switch (statusText.toLowerCase()) {
      case 'to do':
      case 'todo':
        return '1';
      case 'in progress':
      case 'in-progress':
        return '4';
      case 'pending':
        return '2';
      case 'completed':
        return '3';
      default:
        return '1';
    }
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
    await _loadProjectAndTitleData();
    setState(() {});
    // if (assignedTo == null) {
    //   setState(() {
    //     assignedTo = userId;
    //   });
    // }
  }
  Future<void> _loadProjectAndTitleData() async {
    try {
      final projectResponse = await HttpService.getProjectList();
      if (projectResponse != null) {
        setState(() {
          projectList = projectResponse.data;
          filteredProjects = List.from(projectList);
          if (selectedProjectId != null) {
            final project = projectList.firstWhere(
              (p) => p.id == selectedProjectId,
              orElse: () => Projects(
                id: selectedProjectId!,
                name: selectedProjectName ?? 'Unknown Project',
              ),
            );
            selectedProjectName = project.name;
            selectedProjectController.text = project.name;
            _loadTitle(selectedProjectId!);
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading project data: $e');
    }
  }

  // Future<void> _loadTitle(String projectId) async {
  //   try {
  //     final response = await HttpService.getTitleList(projectId);
  //     if (response != null) {
  //       setState(() {
  //         titleList = response.data;
  //         if (selectedTitleId != null && titleController.text.isNotEmpty) {
  //           final matchedTitle = titleList.firstWhere(
  //             (title) => title.name == titleController.text,
  //             orElse: () => TitleListDet(
  //               id: selectedTitleId ?? '',
  //               name: titleController.text,
  //             ),
  //           );
  //           selectedTitleId = matchedTitle.id;
  //           if (!titleList.any((t) => t.id == matchedTitle.id)) {
  //             titleList.add(matchedTitle);
  //           }
  //         }
  //       });
  //     }
  //   } catch (e) {
  //     debugPrint('Error loading titles: $e');
  //   }
  // }

  Future<void> _loadTitle(String projectId) async {
    try {
      final response = await HttpService.getTitleList(projectId);
      if (response != null) {
        setState(() {
          titleList = response.data;

          // Log the titles we got
          log("📋 Loaded Titles (${titleList.length}):");
          for (var title in titleList) {
            log("  - ${title.name} (ID: ${title.id})");
          }

          // Now try to find the ID by matching the name from assigned work
          if (titleController.text.isNotEmpty) {
            final titleName = titleController.text;

            // Try exact match first
            var foundTitle = titleList.firstWhere(
              (title) => title.name.toLowerCase() == titleName.toLowerCase(),
              orElse: () => TitleListDet(id: '', name: ''),
            );

            // If not found, try case-insensitive contains
            if (foundTitle.id.isEmpty) {
              foundTitle = titleList.firstWhere(
                (title) =>
                    title.name.toLowerCase().contains(titleName.toLowerCase()),
                orElse: () => TitleListDet(id: '', name: ''),
              );
            }

            if (foundTitle.id.isNotEmpty) {
              selectedTitleId = foundTitle.id;
              log("✅ Found matching title:");
              log("  - Looking for: $titleName");
              log("  - Found: ${foundTitle.name} (ID: ${foundTitle.id})");
              log("  - Selected Title ID set to: $selectedTitleId");
            } else {
              log("⚠️ Title not found in list: $titleName");
              log("  - Available titles: ${titleList.map((t) => t.name).toList()}");
              selectedTitleId = '';
            }
          } else {
            log("ℹ️ Title text is empty");
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading titles: $e');
      log("❌ Error loading titles: $e");
    }
  }

  Future<void> _loadStaffs() async {
    final response = await HttpService.getStaffs();
    if (response != null && response.status == true) {
      setState(() {
        staffList = response.data;
        if (widget.assignedWork.notification.staffIds is String) {
          final staffIdString =
              widget.assignedWork.notification.staffIds as String;
          selectedStaffIds =
              staffIdString.split(',').where((id) => id.isNotEmpty).toList();
        } else if (widget.assignedWork.notification.staffIds is List) {
          selectedStaffIds = List<String>.from(
              widget.assignedWork.notification.staffIds ?? []);
        }

        // Initialize participant IDs for chat
        if (widget.assignedWork.notification.participantIds is String) {
          final participantIdString =
              widget.assignedWork.notification.participantIds as String;
          participantIds = participantIdString
              .split(',')
              .where((id) => id.isNotEmpty)
              .toList();
        } else if (widget.assignedWork.notification.participantIds is List) {
          participantIds = List<String>.from(
              widget.assignedWork.notification.participantIds ?? []);
        }

        // Set notification settings
        whatsappNotification =
            widget.assignedWork.notification.whatsappNotification == "1";
        pushNotification =
            widget.assignedWork.notification.pushNotification == "1";
        notifyOnStart = widget.assignedWork.notification.onStart == "1";
        notifyOnStatusChange = widget.assignedWork.notification.onSave == "1";
        notifyOnComplete = widget.assignedWork.notification.onComplete == "1";
        final hasOtherStaff = selectedStaffIds.any((id) => id != assignedTo);
        notifyOtherPeople = hasOtherStaff;
        notifyToAssignedStaff = selectedStaffIds.contains(assignedTo);
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
    } else {
      log("❌ Failed to load task states");
    }
  }

  Future<void> _loadPrioState() async {
    final response = await HttpService.getPrioState();
    if (response != null && response.status == true) {
      setState(() {
        allPriorities = response.data;
        if (priority == null && allPriorities.isNotEmpty) {
          final mediumPriority = allPriorities.firstWhere(
            (p) => p.priority.toLowerCase() == 'medium',
            orElse: () => allPriorities.first,
          );
          priority = mediumPriority.id;
        }
      });
    }
  }

  Map<String, dynamic> _getCurrentData() {
    return {
      'project_id': selectedProjectId,
      'title': titleController.text,
      'due_date': dueDate,
      'priority': priority,
      'assigned_to': assignedTo,
      'tasks': tasks
          .map((task) => ({
                'task_id': task.taskId,
                'description': task.controller.text,
                'task_description': task.descriptionController.text,
                'status': task.status,
                'remarks': task.remarksControllers.map((c) => c.text).toList(),
              }))
          .toList(),
      'notification': {
        'whatsapp': whatsappNotification,
        'push': pushNotification,
        'notify_to_assigned': notifyToAssignedStaff,
        'notify_on_status_change': notifyOnStatusChange,
        'on_start': notifyOnStart,
        'on_complete': notifyOnComplete,
        'staff_ids': selectedStaffIds,
        'participant_ids': participantIds,
      },
    };
  }

  void _checkForChanges() {
    final currentData = _getCurrentData();
    setState(() {
      _hasChanges = _compareData(_originalData, currentData);
    });
  }

  bool _compareData(
      Map<String, dynamic> original, Map<String, dynamic> current) {
    return original.toString() != current.toString();
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
      _checkForChanges();
    });
  }

  void _removeRemarkField(int taskIndex, int remarkIndex) {
    if (tasks[taskIndex].remarksControllers.length > 1) {
      setState(() {
        tasks[taskIndex].remarksControllers.removeAt(remarkIndex);
        _checkForChanges();
      });
    }
  }

//   Future<void> _updateWork() async {
//     if (_isUpdating) return;

//     setState(() {
//       _isUpdating = true;
//     });

//     try {
//       if (selectedProjectId == null || selectedProjectId!.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Please select a project'),
//             backgroundColor: Colors.red,
//           ),
//         );
//         setState(() => _isUpdating = false);
//         return;
//       }

//       if (titleController.text.trim().isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Please enter a title/module'),
//             backgroundColor: Colors.red,
//           ),
//         );
//         setState(() => _isUpdating = false);
//         return;
//       }

//       if (tasks.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Please add at least one task'),
//             backgroundColor: Colors.red,
//           ),
//         );
//         setState(() => _isUpdating = false);
//         return;
//       }

//       for (var task in tasks) {
//         if (task.controller.text.trim().isEmpty) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Please fill all task names'),
//               backgroundColor: Colors.red,
//             ),
//           );
//           setState(() => _isUpdating = false);
//           return;
//         }
//       }

//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => const Center(
//           child: CircularProgressIndicator(),
//         ),
//       );

//       final updateData = {
//         'work_id': widget.assignedWork.id.toString(),
//         'project_id': selectedProjectId,
//         'project_name': selectedProjectName,
//         'title': titleController.text.trim(),
//         'title_id': selectedTitleId ?? titleController.text.trim(),
//         'due_date':
//             dueDate != null ? DateFormat('yyyy-MM-dd').format(dueDate!) : '',
//         'priority': priority ?? '1',
//         'assigned_to': assignedTo,
//         'task_type': taskType,
//         'category': category,
//         'notification': {
//           'whatsapp': whatsappNotification,
//           'push': pushNotification,
//           'notify_to_assigned': notifyToAssignedStaff,
//           'notify_on_status_change': notifyOnStatusChange,
//           'notify_other_people': notifyOtherPeople,
//           'staff_ids': [
//             if (notifyToAssignedStaff &&
//                 assignedTo != null &&
//                 assignedTo != "0")
//               assignedTo!,
//             if (notifyOtherPeople)
//               ...selectedStaffIds.where((id) => id != assignedTo && id != "0"),
//           ].join(','),
//           'on_start': notifyOnStart,
//           'on_complete': notifyOnComplete,
//         },
        
           
//         'tasks': tasks.asMap().entries.map((entry) {
//         final index = entry.key;
//         final task = entry.value;

//         return {
//           'task_id': task.taskId,
//           'task_name': task.controller.text.trim(),
//           'task_description': task.descriptionController.text.trim(),
//           'status': task.status ?? '1',
//           'remarks': task.remarksControllers
//               .map((c) => c.text.trim())
//               .where((r) => r.isNotEmpty)
//               .toList(),
//           'is_existing': task.isExisting,
//           'delete_attachment_id': deletedAttachmentIds,
//           'delete_attachment_file': deletedAttachmentFileIds,
//           'attachment_count': taskAttachments[index]?.length ?? 0,
//         };
//       }).toList(),
//       };
// final List<File> allAttachments = taskAttachments.values
//         .expand((files) => files)
//         .toList();
//       final response = await HttpService().updateAssignedWork(updateData, newAttachments);

//       Navigator.of(context).pop();

//       if (response != null && response.status == true) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(response.message ?? 'Work updated successfully!'),
//             backgroundColor: Colors.green,
//           ),
//         );

//         widget.onSuccess();

//         await Future.delayed(const Duration(seconds: 1));
//         if (context.mounted) {
//           Navigator.pop(context);
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(response?.message ?? 'Failed to update work'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } catch (e) {
//       Navigator.of(context).pop();
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error: ${e.toString()}'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() => _isUpdating = false);
//     }
//   }
Future<void> _updateWork() async {
  if (_isUpdating) return;

  setState(() {
    _isUpdating = true;
  });

  try {
    if (selectedProjectId == null || selectedProjectId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a project'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isUpdating = false);
      return;
    }

    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title/module'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isUpdating = false);
      return;
    }

    if (tasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one task'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isUpdating = false);
      return;
    }
// Validate tasks
if (tasks.isEmpty ||
    tasks.every((task) => task.controller.text.trim().isEmpty)) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Please add at least one task'),
      backgroundColor: Colors.red,
    ),
  );
  setState(() => _isUpdating = false);
  return;
}

// Validate each task name
for (int i = 0; i < tasks.length; i++) {
  if (tasks[i].controller.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task ${i + 1} is mandatory'),
        backgroundColor: Colors.red,
      ),
    );
    setState(() => _isUpdating = false);
    return;
  }
}
    for (var task in tasks) {
      if (task.controller.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill all task names'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isUpdating = false);
        return;
      }
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final updateData = {
      'work_id': widget.assignedWork.id.toString(),
      'project_id': selectedProjectId,
      'project_name': selectedProjectName,
      'title': titleController.text.trim(),
      'title_id': selectedTitleId ?? titleController.text.trim(),
      'due_date': dueDate != null
          ? DateFormat('yyyy-MM-dd HH:mm:ss').format(dueDate!)
          : null,
      'priority': priority ?? '1',
      'assigned_to': assignedTo,
      'task_type': taskType,
      'category': category,

      'notification': {
        'whatsapp': whatsappNotification,
        'push': pushNotification,
        'notify_to_assigned': notifyToAssignedStaff,
        'notify_on_status_change': notifyOnStatusChange,
        'notify_other_people': notifyOtherPeople,
        'staff_ids': [
          if (notifyToAssignedStaff &&
              assignedTo != null &&
              assignedTo != "0")
            assignedTo!,
          if (notifyOtherPeople)
            ...selectedStaffIds.where(
              (id) => id != assignedTo && id != "0",
            ),
        ].join(','),
        'on_start': notifyOnStart,
        'on_complete': notifyOnComplete,
      },

      'tasks': tasks.asMap().entries.map((entry) {
        final index = entry.key;
        final task = entry.value;

        return {
          'task_id': task.taskId,
          'task_name': task.controller.text.trim(),
          'task_description': task.descriptionController.text.trim(),
          'status': task.status ?? '1',
          'remarks': task.remarksControllers
              .map((c) => c.text.trim())
              .where((r) => r.isNotEmpty)
              .toList(),
          'is_existing': task.isExisting,
          'delete_attachment_id': deletedAttachmentIds,
          'delete_attachment_file': deletedAttachmentFileIds,
          'attachment_count': taskAttachments[index]?.length ?? 0,
        };
      }).toList(),
    };

    /// Flatten all task attachments into one list
    final response = await HttpService().updateAssignedWork(
  updateData,
  taskAttachments,
);

    Navigator.of(context).pop();

    if (response != null && response.status == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message ?? 'Work updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      widget.onSuccess();

      await Future.delayed(const Duration(seconds: 1));

      if (context.mounted) {
        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response?.message ?? 'Failed to update work'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: ${e.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    setState(() {
      _isUpdating = false;
    });
  }
}
  
  Future<void> _showDiscardDialog() async {
    if (!_hasChanges) {
      Navigator.pop(context);
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text(
            'You have unsaved changes. Are you sure you want to discard them?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_hasChanges) {
          _showDiscardDialog();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.blue,
          elevation: 2,
          shadowColor: Colors.black12,
          title: Row(
            children: [
              Text(
                'Edit Work',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          centerTitle: false,
          actions: [
            if (_hasChanges)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.circle, size: 8, color: Colors.orange[700]),
                      const SizedBox(width: 4),
                      const Text(
                        'Unsaved',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(60, 255, 255, 255),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.close, size: 22),
              ),
              onPressed: _showDiscardDialog,
            ),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    // padding: const EdgeInsets.all(20),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                    Icon(
                                      Icons.folder_special_rounded,
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Project Details',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color.fromARGB(255, 10, 10, 10),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Project *',
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
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: ListTile(
                                              onTap: () async {
                                                final selected =
                                                    await _showProjectSelectionDialog(
                                                        context);
                                                if (selected != null) {
                                                  setState(() {
                                                    selectedProjectId =
                                                        selected['id'];
                                                    selectedProjectName =
                                                        selected['name'];
                                                    selectedProjectController
                                                            .text =
                                                        selected['name'] ?? '';
                                                    _loadTitle(
                                                        selectedProjectId!);
                                                    _checkForChanges();
                                                  });
                                                }
                                              },
                                              title: Text(
                                                selectedProjectController
                                                        .text.isEmpty
                                                    ? 'Project'
                                                    : selectedProjectController
                                                        .text,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color:
                                                      selectedProjectController
                                                              .text.isEmpty
                                                          ? Colors.grey[500]
                                                          : Colors.grey[800],
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              trailing: const Icon(
                                                Icons.arrow_drop_down,
                                                color: Colors.grey,
                                                size: 20,
                                              ),
                                              dense: true,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 4,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: ListTile(
                                              onTap: () async {
                                                final selected =
                                                    await _showTitleSelectionDialog(
                                                        context);
                                                if (selected != null) {
                                                  setState(() {
                                                    selectedTitleId =
                                                        selected['id'];
                                                    titleController.text =
                                                        selected['name']!;
                                                    _checkForChanges();
                                                  });
                                                }
                                              },
                                              title: Text(
                                                titleController.text.isEmpty
                                                    ? 'Module'
                                                    : titleController.text,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: titleController
                                                          .text.isEmpty
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
                                                    icon: const Icon(Icons.add,
                                                        size: 16),
                                                    onPressed: () async {
                                                      final newTitle =
                                                          await _showAddTitleDialog(
                                                              context);
                                                      if (newTitle != null) {
                                                        setState(() {
                                                          titleList
                                                              .add(newTitle);
                                                          selectedTitleId =
                                                              newTitle.id;
                                                          titleController.text =
                                                              newTitle.name;
                                                          _checkForChanges();
                                                        });
                                                      }
                                                    },
                                                    padding: EdgeInsets.zero,
                                                    constraints:
                                                        const BoxConstraints(
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
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
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
                        const SizedBox(height: 16),
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
                                    const Text(
                                      'Work Details',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color.fromARGB(255, 8, 8, 8),
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
    firstDate: now, // Prevent past dates
    lastDate: DateTime(2100),
  );

  if (pickedDate == null) return;

  // Determine initial time
  TimeOfDay initialTime = dueDate != null
      ? TimeOfDay.fromDateTime(dueDate!)
      : TimeOfDay.fromDateTime(now);

  // Pick Time
  final pickedTime = await showTimePicker(
    context: context,
    initialTime: initialTime,
  );

  if (pickedTime == null) return;

  // Create selected DateTime
  final selectedDateTime = DateTime(
    pickedDate.year,
    pickedDate.month,
    pickedDate.day,
    pickedTime.hour,
    pickedTime.minute,
  );

  // Prevent past date & time
  if (selectedDateTime.isBefore(now)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Please select a future date and time.",
        ),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  setState(() {
    dueDate = selectedDateTime;
    _checkForChanges();
  });
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
                      ? DateFormat('dd-MM-yyyy hh:mm a').format(dueDate!)
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
                                    // Expanded(
                                    //   child: Column(
                                    //     crossAxisAlignment:
                                    //         CrossAxisAlignment.start,
                                    //     children: [
                                    //       Text(
                                    //         'Due Date',
                                    //         style: TextStyle(
                                    //           fontSize: 14,
                                    //           fontWeight: FontWeight.w500,
                                    //           color: Colors.grey[700],
                                    //         ),
                                    //       ),
                                    //       const SizedBox(height: 6),
                                    //       GestureDetector(
                                    //         onTap: () async {
                                    //           final picked =
                                    //               await showDatePicker(
                                    //             context: context,
                                    //             initialDate:
                                    //                 dueDate ?? DateTime.now(),
                                    //             firstDate: DateTime(2022),
                                    //             lastDate: DateTime(2100),
                                    //           );
                                    //           if (picked != null) {
                                    //             setState(() {
                                    //               dueDate = picked;
                                    //               _checkForChanges();
                                    //             });
                                    //           }
                                    //         },
                                    //         child: Container(
                                    //           padding: const EdgeInsets.all(14),
                                    //           decoration: BoxDecoration(
                                    //             border: Border.all(
                                    //                 color:
                                    //                     Colors.grey.shade300),
                                    //             borderRadius:
                                    //                 BorderRadius.circular(8),
                                    //           ),
                                    //           child: Row(
                                    //             children: [
                                    //               Icon(
                                    //                 Icons.calendar_today,
                                    //                 size: 20,
                                    //                 color: Colors.grey[600],
                                    //               ),
                                    //               const SizedBox(width: 12),
                                    //               Expanded(
                                    //                 child: Text(
                                    //                   dueDate != null
                                    //                       ? DateFormat(
                                    //                               'dd-MM-yyyy')
                                    //                           .format(dueDate!)
                                    //                       : 'Select',
                                    //                   style: TextStyle(
                                    //                     color: dueDate != null
                                    //                         ? Colors.grey[800]
                                    //                         : Colors.grey[500],
                                    //                   ),
                                    //                 ),
                                    //               ),
                                    //             ],
                                    //           ),
                                    //         ),
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),
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
                                                            style:
                                                                const TextStyle(
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
                                                onChanged: (value) {
                                                  setState(() {
                                                    priority = value;
                                                    _checkForChanges();
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
                        const SizedBox(height: 16),
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
                                    const Text(
                                      'Assignment',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color.fromARGB(255, 0, 0, 0),
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
                                        final selected =
                                            await _showStaffSelectionDialog(
                                                context);
                                        if (selected != null) {
                                          setState(() {
                                            assignedTo = selected['id'];
                                            if (!selectedStaffIds
                                                .contains(selected['id'])) {
                                              selectedStaffIds = [
                                                selected['id'] as String
                                              ];
                                            }
                                            _checkForChanges();
                                          });
                                        }
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
                                                assignedTo == "0"
                                                    ? 'Unassigned'
                                                    : assignedTo != null &&
                                                            staffList.isNotEmpty
                                                        ? staffList
                                                            .firstWhere(
                                                              (s) =>
                                                                  s.userIdStaff ==
                                                                  assignedTo,
                                                              orElse: () =>
                                                                  Staff(
                                                                id: '',
                                                                name:
                                                                    'Select Staff',
                                                                userIdStaff: '',
                                                              ),
                                                            )
                                                            .name
                                                        : 'Select Staff',
                                                style: TextStyle(
                                                  color: assignedTo != null
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
                        const SizedBox(height: 16),
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
                                    const Text(
                                      'Tasks',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color.fromARGB(255, 0, 0, 0),
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
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'Task ${taskIndex + 1}',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color:
                                                              Colors.grey[700],
                                                        ),
                                                      ),
                                                      if (tasks[taskIndex]
                                                          .isExisting)
                                                        Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 8),
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            horizontal: 6,
                                                            vertical: 2,
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .blue.shade50,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4),
                                                          ),
                                                          child: Text(
                                                            'Existing',
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              color: Colors.blue
                                                                  .shade800,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  TextField(
                                                    controller: tasks[taskIndex]
                                                        .controller,
                                                    minLines: 1,
                                                    maxLines: 2,
                                                    onChanged: (_) =>
                                                        _checkForChanges(),
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
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 200,
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
                                                        // onChanged: (value) {
                                                        //   setState(() {
                                                        //     tasks[taskIndex]
                                                          //         .status = value;
                                                        //     _checkForChanges();
                                                        //   });
                                                        // },
                                                           onChanged: null,
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
                                            if (taskIndex > 0 ||
                                                tasks.length > 1)
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
                                                    _checkForChanges();
                                                  });
                                                },
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        TextField(
                                          controller: tasks[taskIndex]
                                              .descriptionController,
                                          minLines: 2,
                                          maxLines: 4,
                                          onChanged: (_) => _checkForChanges(),
                                          decoration: InputDecoration(
                                            hintText: 'Task description',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.all(12),
                                          ),
                                        ),
                                        const SizedBox(height: 12),

if (taskIndex < widget.assignedWork.workSessions.length &&
    widget.assignedWork.workSessions[taskIndex].attachments.isNotEmpty)
  Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Attachments',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
        ),
      ),
      const SizedBox(height: 8),

      ...List.generate(
        widget.assignedWork.workSessions[taskIndex].attachments.length,
        (index) {
          final attachment = widget
              .assignedWork.workSessions[taskIndex].attachments[index];

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
                      "Attachment ${index + 1}",
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),

                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    setState(() {
                      final session = widget.assignedWork.workSessions[taskIndex];

                      deletedAttachmentIds.add(session.attachmentIds[index]);
                      deletedAttachmentFileIds.add(session.attachmentFileIds[index]);

                      session.attachments.removeAt(index);
                      session.attachmentIds.removeAt(index);
                      session.attachmentFileIds.removeAt(index);

                      _checkForChanges();
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),
    ],
  ),
  const SizedBox(height: 12),

ElevatedButton.icon(
  onPressed: () => _pickAttachments(taskIndex),
  icon: const Icon(Icons.attach_file),
  label: const Text("Add Attachment"),
),

const SizedBox(height: 10),

if ((taskAttachments[taskIndex] ?? []).isNotEmpty)
  Column(
    children: List.generate(
      taskAttachments[taskIndex]!.length,
      (index) {
        final file = taskAttachments[taskIndex]![index];

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
                Icons.insert_drive_file,
                color: Colors.green,
              ),
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
                    taskAttachments[taskIndex]!.removeAt(index);

                    if (taskAttachments[taskIndex]!.isEmpty) {
                      taskAttachments.remove(taskIndex);
                    }

                    _checkForChanges();
                  });
                },
              ),
            ],
          ),
        );
      },
    ),
  ),
  
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
                                        tasks.add(EditTaskForm(
                                          controller: TextEditingController(),
                                          descriptionController:
                                              TextEditingController(),
                                          status: allTaskStates.isNotEmpty
                                              ? allTaskStates.first.id
                                              : null,
                                          isExisting: false,
                                          remarks: [TextEditingController()],
                                        ));
                                        _checkForChanges();
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
                        const SizedBox(height: 16),
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
                                    const Text(
                                      'Notification Settings',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color.fromARGB(255, 8, 8, 8),
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
                                    onChanged: (value) {
                                      setState(() {
                                        whatsappNotification = value;
                                        _checkForChanges();
                                      });
                                    },
                                  ),
                                ],
                                const SizedBox(height: 12),
                                _buildNotificationOption(
                                  icon: Icons.notifications_active_rounded,
                                  iconColor: Colors.blue,
                                  title: 'Push Notification',
                                  value: pushNotification,
                                  onChanged: (value) {
                                    setState(() {
                                      pushNotification = value;
                                      _checkForChanges();
                                    });
                                  },
                                ),
                                const SizedBox(height: 12),
                                _buildNotificationOption(
                                  icon: Icons.person_rounded,
                                  iconColor: Colors.orange,
                                  title: 'Notify to Assigned Staff',
                                  value: notifyToAssignedStaff,
                                  onChanged: (value) {
                                    setState(() {
                                      notifyToAssignedStaff = value;
                                      _checkForChanges();
                                    });
                                  },
                                ),
                                const SizedBox(height: 12),
                                _buildNotificationOption(
                                  icon: Icons.change_circle_rounded,
                                  iconColor: Colors.purple,
                                  title: 'Notify on Status Change',
                                  value: notifyOnStatusChange,
                                  onChanged: (value) {
                                    setState(() {
                                      notifyOnStatusChange = value;
                                      _checkForChanges();
                                    });
                                  },
                                ),
                                const SizedBox(height: 12),
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
                                      _checkForChanges();
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
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Update Button
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
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
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _showDiscardDialog,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                          minimumSize: const Size(0, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            _hasChanges && !_isUpdating ? _updateWork : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _hasChanges ? Colors.blue : Colors.grey[400],
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: _isUpdating
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.save, size: 22),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'SAVE CHANGES',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  // if (_hasChanges)
                                  //   Container(
                                  //     margin: const EdgeInsets.only(left: 8),
                                  //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  //     decoration: BoxDecoration(
                                  //       color: Colors.orange,
                                  //       borderRadius: BorderRadius.circular(10),
                                  //     ),
                                  //     child: const Text(
                                  //       '●',
                                  //       style: TextStyle(
                                  //         fontSize: 10,
                                  //         color: Colors.white,
                                  //       ),
                                  //     ),
                                  //   ),
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
      ),
    );
  }

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

  Future<Map<String, String>?> _showProjectSelectionDialog(
      BuildContext context) async {
    TextEditingController searchController = TextEditingController();
    List<Projects> filteredProjects = List.from(projectList);

    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Project'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        labelText: 'Search Projects',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {
                          filteredProjects = projectList
                              .where((project) => project.name
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
                        itemCount: filteredProjects.length,
                        itemBuilder: (context, index) {
                          final project = filteredProjects[index];
                          return ListTile(
                            title: Text(project.name),
                            onTap: () {
                              Navigator.pop(context, {
                                'id': project.id,
                                'name': project.name,
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
              ],
            );
          },
        );
      },
    );
  }

  Future<Map<String, String>?> _showTitleSelectionDialog(
      BuildContext context) async {
    TextEditingController searchController = TextEditingController();
    List<TitleListDet> filteredTitles = List.from(titleList);

    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Module'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        labelText: 'Search Modules',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {
                          filteredTitles = titleList
                              .where((title) => title.name
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
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<TitleListDet?> _showAddTitleDialog(BuildContext context) async {
    TextEditingController titleController = TextEditingController();

    return showDialog<TitleListDet>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Module'),
          content: TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Module Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter module name')),
                  );
                  return;
                }
                final newTitle = TitleListDet(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: titleController.text.trim(),
                );
                Navigator.pop(context, newTitle);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, String>?> _showStaffSelectionDialog(
      BuildContext context) async {
    TextEditingController searchController = TextEditingController();
    List<Staff> filteredStaff = List.from(staffList);

    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
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
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
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
        _checkForChanges();
      });
    }
  }
}

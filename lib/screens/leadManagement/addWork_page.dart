import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/lead_management/assignedWorkStatusModel.dart';
import 'package:login2/models/lead_management/priorityStatusModel.dart';
import 'package:login2/models/lead_management/taskStatusModel.dart';
import 'package:login2/screens/leadManagement/dashboard.dart';
import 'package:login2/screens/leadManagement/projectDashboard.dart';
import 'package:login2/screens/leadManagement/viewwork_page.dart';

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
  String? status;
  String? taskId;
  List<TextEditingController> remarksControllers;
  bool isChecked;

  TaskForm({
    required this.controller,
    this.status,
    this.taskId,
    List<TextEditingController>? remarks,
    this.isChecked = false,
  }) : remarksControllers = remarks ?? [TextEditingController()] {
    if (remarksControllers.isEmpty) {
      remarksControllers.add(TextEditingController());
    }
  }
}

class AddWorkPage extends StatefulWidget {
  final String workId;
  final WorkStatus? existingWork;
  final Function() onSuccess;
  final int isPaused;
  final int Restart;
  final int isAssigned;
  const AddWorkPage({
    super.key,
    required this.workId,
    this.existingWork,
    required this.onSuccess,
    this.isPaused = 0,
    this.Restart = 0,
    this.isAssigned = 0,
  });

  @override
  _AddWorkPageState createState() => _AddWorkPageState();
}

class _AddWorkPageState extends State<AddWorkPage> {
  late TextEditingController titleController;
  late List<TaskForm> tasks;
  String? selectedProjectId;
  String? selectedProjectName;
  String? selectedTitleId;
  DateTime? dueDate;
  String? priority;
  String? assignedTo;
  String? sectionId;
  DateTime? currentDate;
  String? ProjectDashboardPermission;
  final TextEditingController _searchController = TextEditingController();
  List<Projects> _filteredProjects = [];
  bool _isSearching = false;
  List<Projects> projectList = [];
  List<TitleListDet> titleList = [];
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
  bool _isGettingLocation = false;
  double? currentLatitude;
  double? currentLongitude;
  void filterCustomers(String value) {}
  void filterTemplates(String value) {}
  void filterProjects(String value) {}
  void filterProducts(String value) {}
  void calculateTotalExisting() {}
  late String token;
  late String userId;
  String? addWorkModule;
  List<Staff> staffList = [];
  List<TaskState> allTaskStates = [];
  List<PrioState> allPriorities = [];
  AssignedWorkStatus? assignedWorks;
List<File> stopWorkAttachments = [];
  @override
  void initState() {
    super.initState();
    debugPrint('Work is paused? ${widget.isPaused == 1 ? "Yes" : "No"}');
    debugPrint('Work is restarted? ${widget.Restart == 1 ? "Yes" : "No"}');

    titleController = TextEditingController(
      text: widget.existingWork?.title_name ?? '',
    );
    _searchController.addListener(_filterProjects);
    tasks = widget.existingWork != null
        ? widget.existingWork!.tasks
            .map((task) => TaskForm(
                  controller: TextEditingController(text: task.taskName),
                  status: task.status,
                  taskId: task.taskId,
                  isChecked: task.status == '4',
                  remarks: task.remarks
                      .map((remark) => TextEditingController(text: remark))
                      .toList(),
                ))
            .toList()
        : [
            TaskForm(
              controller: TextEditingController(),
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

    _initAsync();
    _loadStaffs();
    _loadTaskState();
    _loadPrioState();
    checkAssignedWorks();
  }
Future<void> _pickStopWorkAttachments() async {
  final result = await FilePicker.platform.pickFiles(
    allowMultiple: true,
    type: FileType.any,
  );

  if (result != null) {
    setState(() {
      stopWorkAttachments.addAll(
        result.paths
            .whereType<String>()
            .map((path) => File(path))
            .toList(),
      );
    });
  }
}
  void _initAsync() async {
    token = await Common.getSharedPref("token") ?? "";
    userId = await Common.getSharedPref("userId");
    addWorkModule = await Common.getSharedPref("addWorkModule");
    ProjectDashboardPermission =
        await Common.getSharedPref("ProjectDashboardPermission");
    await _loadProjects();
    if (assignedTo == null) {
      setState(() {
        assignedTo = userId;
      });
    }
  }

  bool _validateTasks() {
    bool atLeastOneChecked =
        tasks.any((task) => task.status == '4' || task.isChecked);
    if (tasks.isEmpty ||
        !tasks.any((task) => task.controller.text.trim().isNotEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please add at least one task to proceed'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return false;
    }

    if (!atLeastOneChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please check at least one task to proceed'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return false;
    }

    // Check if mandatory descriptions (remarks) are provided for checked/completed tasks
    // User requested mandatory only for Save Work and Stop Work
    bool isSaveOrStopWork = widget.existingWork != null &&
        widget.Restart != 1 &&
        widget.isPaused != 1;

    if (isSaveOrStopWork) {
  // Validate remarks
  for (int i = 0; i < tasks.length; i++) {
    if (tasks[i].isChecked || tasks[i].status == '4') {
      bool hasRemark = tasks[i]
          .remarksControllers
          .any((controller) => controller.text.trim().isNotEmpty);

      if (!hasRemark) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please provide a remark for task: '
              '${tasks[i].controller.text.isEmpty ? (i + 1) : tasks[i].controller.text}',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade400,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return false;
      }
    }
  }

  // Validate attachments for Completed or Ready To Publish tasks
  final requiresAttachment = tasks.any(
    (task) =>
        task.isChecked &&
        (task.status == '3' || task.status == '6'),
  );

  if (requiresAttachment && stopWorkAttachments.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Please upload at least one attachment before submitting.',
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
      ),
    );
    return false;
  }
}
    return true;
  }

  Future<void> checkAssignedWorks() async {
    if (widget.workId.isEmpty) return;

    final AssignedWorkModel =
        await HttpService.getAssinedWorkStatus(widget.workId, sectionId = "");
    setState(() {
      if (AssignedWorkModel != null && AssignedWorkModel.data.isNotEmpty) {
        assignedWorks = AssignedWorkModel.data.first;

        if (widget.existingWork == null) {
          titleController.text = assignedWorks?.titleName ?? '';
          selectedProjectId = assignedWorks?.projectId;
          selectedProjectName = assignedWorks?.projectName;
          selectedTitleId = assignedWorks?.title;
          dueDate = assignedWorks?.dueDate;
          priority = assignedWorks?.priority;
          assignedTo = assignedWorks?.assignedTo;

          if (selectedProjectName != null) {
            selectedProjectController.text = selectedProjectName!;
          }
          tasks = (assignedWorks?.tasks ?? [])
              .map((task) => TaskForm(
                    controller: TextEditingController(text: task.taskName),
                    status: task.status,
                    taskId: task.taskId,
                    isChecked: task.status == '4',
                    remarks: task.remarks.isNotEmpty
                        ? task.remarks
                            .map(
                                (remark) => TextEditingController(text: remark))
                            .toList()
                        : [TextEditingController()],
                  ))
              .toList();

          if (tasks.isEmpty) {
            tasks.add(TaskForm(
              controller: TextEditingController(),
              status: allTaskStates.isNotEmpty ? allTaskStates.first.id : null,
              remarks: [TextEditingController()],
            ));
          }
        }
      } else {
        assignedWorks = null;
        tasks = [
          TaskForm(
            controller: TextEditingController(),
            status: allTaskStates.isNotEmpty ? allTaskStates.first.id : null,
            remarks: [TextEditingController()],
          )
        ];
      }
    });

    if (selectedProjectId != null) {
      await _loadTitle();
    }
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
        SnackBar(
          content: Text('Failed to load projects: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
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
        if (assignedTo == null) {
          if (staffList.any((staff) => staff.id == userId)) {
            assignedTo = userId;
          }
        }
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
            (p) => p.priority.toLowerCase() == 'high',
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

  void _addDescriptionField(int taskIndex) {
    setState(() {
      tasks[taskIndex].remarksControllers.add(TextEditingController());
    });
  }

  void _removeDescriptionField(int taskIndex, int remarkIndex) {
    if (tasks[taskIndex].remarksControllers.length > 1) {
      setState(() {
        tasks[taskIndex].remarksControllers.removeAt(remarkIndex);
      });
    }
  }

  Future<void> _submitWork() async {
    if (!_validateTasks()) return;

    if (selectedProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a project'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }
    if (_isGettingLocation) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please wait, fetching location...'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orange.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    if (isLocationEnabled &&
        (currentLatitude == null || currentLongitude == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Location not available yet.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }
    if (selectedTitleId == null ||
        selectedTitleId!.isEmpty ||
        titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a title'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    final workData = {
      'work_id': widget.existingWork?.id,
      'project_id': selectedProjectId,
      'project_name': selectedProjectName,
      'title': titleController.text,
      'title_id': selectedTitleId,
      if (widget.workId != "") 'attendance_id': widget.workId,
      'assignedId': widget.existingWork?.assignedId,
      'latitude': currentLatitude,
      'longitude': currentLongitude,
      'action': widget.existingWork != null ? 'stop' : 'start',
      'tasks': tasks.asMap().entries.map((entry) {
        final task = entry.value;
        return {
          'task_id': task.taskId,
          'description': task.controller.text,
          'status': task.status,
          'is_checked': task.isChecked ? 1 : 0,
          'task_description': task.remarksControllers
              .map((controller) => controller.text)
              .where((remark) => remark.isNotEmpty)
              .join('\n'),
        'attachment_count':
        task.isChecked && task.status == '3'
            ? stopWorkAttachments.length
            : 0,
        };
      }).toList(),
    };
    try {
      final response = widget.existingWork != null
          ?await HttpService.saveWorkData(workData,stopWorkAttachments)
          // await HttpService.updateWorkData(workData)
          : await HttpService.submitWorkData(workData);

      if (response.status) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingWork != null
                ? 'Work stopped successfully!'
                : 'Work started successfully!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green.shade400,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        await Future.delayed(const Duration(seconds: 1));
        ProjectDashboardPermission == "true"
            ? Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ViewWorkPage(staffId: userId, selectedDate: currentDate),
                ),
              )
            : Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ViewWorkPage(staffId: userId, selectedDate: currentDate),
                ),
              );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Operation failed'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade400,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _savework() async {
    if (!_validateTasks()) return;
    if (selectedProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a project'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }
    final workData = {
      'work_id': widget.existingWork?.id,
      'project_id': selectedProjectId,
      'project_name': selectedProjectName,
      'title': titleController.text,
      'title_id': selectedTitleId,
      'assignedId': widget.existingWork?.assignedId,
      'latitude': currentLatitude,
      'longitude': currentLongitude,
      'action': 'save',
      'tasks': tasks.asMap().entries.map((entry) {
        final task = entry.value;
        return {
          'task_id': task.taskId,
          'description': task.controller.text,
          'status': task.status,
          'is_checked': task.isChecked ? 1 : 0,
          'task_description': task.remarksControllers
              .map((controller) => controller.text)
              .where((remark) => remark.isNotEmpty)
              .join('\n'),
        };
      }).toList(),
    };
    try {
      final response = await HttpService.saveWorkData(workData,stopWorkAttachments);
      if (response.status) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Work saved successfully!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green.shade400,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        widget.onSuccess();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Failed to save work'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade400,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving work: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _pauseWork() async {
    if (!_validateTasks()) return;
    if (selectedProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a project'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }
    if (_isGettingLocation) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please wait, fetching location...'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orange.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    if (isLocationEnabled &&
        (currentLatitude == null || currentLongitude == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Location not available yet.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }
    if (selectedTitleId == null ||
        selectedTitleId!.isEmpty ||
        titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a title'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    final workData = {
      'work_id': widget.existingWork?.id,
      'project_id': selectedProjectId,
      'project_name': selectedProjectName,
      'title': titleController.text,
      'title_id': selectedTitleId,
      'assignedId': widget.existingWork?.assignedId,
      'latitude': currentLatitude,
      'longitude': currentLongitude,
      'tasks': tasks.asMap().entries.map((entry) {
        final task = entry.value;
        return {
          'task_id': task.taskId,
          'description': task.controller.text,
          'status': task.status,
          'task_description': task.remarksControllers
              .map((controller) => controller.text)
              .where((remark) => remark.isNotEmpty)
              .join('\n'),
        };
      }).toList(),
    };
    try {
      final response = await HttpService.pauseWorkData(workData);

      if (response.status) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingWork != null
                ? 'Work stopped successfully!'
                : 'Work started successfully!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green.shade400,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        await Future.delayed(const Duration(seconds: 1));

        ProjectDashboardPermission == "true"
            ? Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ViewWorkPage(staffId: userId, selectedDate: currentDate),
                ),
              )
            : Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ViewWorkPage(staffId: userId, selectedDate: currentDate),
                ),
              );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Operation failed'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade400,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _restartWork() async {
    if (!_validateTasks()) return;
    if (selectedProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a project'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }
    if (_isGettingLocation) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please wait, fetching location...'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orange.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    if (isLocationEnabled &&
        (currentLatitude == null || currentLongitude == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Location not available yet.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }
    if (selectedTitleId == null ||
        selectedTitleId!.isEmpty ||
        titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a title'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    final workData = {
      'work_id': widget.existingWork?.id,
      'project_id': selectedProjectId,
      'project_name': selectedProjectName,
      'title': titleController.text,
      'title_id': selectedTitleId,
      'latitude': currentLatitude,
      'longitude': currentLongitude,
      if (widget.workId != "") 'attendance_id': widget.workId,
      'tasks': tasks.asMap().entries.map((entry) {
        final task = entry.value;
        return {
          'task_id': task.taskId,
          'description': task.controller.text,
          'status': task.status,
          'task_description': task.remarksControllers
              .map((controller) => controller.text)
              .where((remark) => remark.isNotEmpty)
              .join('\n'),
        };
      }).toList(),
    };
    try {
      final response = await HttpService.restartWork(workData);

      if (response.status) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingWork != null &&
                    widget.isPaused != 1 &&
                    widget.Restart != 1
                ? 'Work stopped successfully!'
                : widget.isPaused == 1
                    ? 'Work Paused successfully!'
                    : widget.Restart == 1
                        ? 'Work Restarted successfully!'
                        : 'Work started successfully!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green.shade400,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        await Future.delayed(const Duration(seconds: 1));

        ProjectDashboardPermission == "true"
            ? Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ViewWorkPage(staffId: userId, selectedDate: currentDate),
                ),
              )
            : Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ViewWorkPage(staffId: userId, selectedDate: currentDate),
                ),
              );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Operation failed'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade400,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: Text(
          widget.isPaused != 1 && widget.Restart != 1
              ? (widget.existingWork != null ? 'Stop Work' : 'Start Work')
              : (widget.Restart != 1
                  ? 'Pause Work'
                  : (assignedWorks != "" ? 'Start Work' : 'Restart Work')),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Project Field
                        InkWell(
                          onTap: () async {
                            final selected =
                                await dropDialogExisting(context, "Projects");
                            if (selected != null) {
                              setState(() {
                                selectedProjectId = selected['id'];
                                selectedProjectController.text =
                                    selected['name'] ?? '';
                              });
                              await _loadTitle();
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Project',
                              labelStyle:
                                  TextStyle(color: Colors.blue.shade700),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              prefixIcon: Icon(Icons.work_outline,
                                  color: Colors.blue.shade700, size: 20),
                              suffixIcon: const Icon(Icons.arrow_drop_down,
                                  color: Colors.grey),
                            ),
                            child: Text(
                              selectedProjectController.text.isEmpty
                                  ? 'Select Project'
                                  : selectedProjectController.text,
                              style: TextStyle(
                                color: selectedProjectController.text.isEmpty
                                    ? Colors.grey.shade600
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Module Field
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  FocusScope.of(context).unfocus();

                                  final selected = await dropTitleDialog(context, titleList);

                                  if (selected == null) return;

                                  setState(() {
                                    selectedTitleId = selected['id'] ?? '';
                                    titleController.text = selected['name'] ?? '';
                                  });

                                  debugPrint("Selected Module Id : $selectedTitleId");
                                  debugPrint("Selected Module Name : ${titleController.text}");
},
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Module',
                                    labelStyle:
                                        TextStyle(color: Colors.blue.shade700),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    prefixIcon: Icon(Icons.category_outlined,
                                        color: Colors.blue.shade700, size: 20),
                                    suffixIcon: const Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.grey),
                                  ),
                                  child: Text(
                                    titleController.text.isEmpty
                                        ? 'Select Module'
                                        : titleController.text,
                                    style: TextStyle(
                                      color: titleController.text.isEmpty
                                          ? Colors.grey.shade600
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (addWorkModule.toString() == "true")
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.add,
                                      color: Colors.blue.shade700),
                                  onPressed: () async {
                                    final newTitle =
                                        await showProjectTitleDialog(context);
                                    if (newTitle != null) {
                                      setState(() {
                                        titleList.add(newTitle);
                                        selectedTitleId = newTitle.id;
                                        titleController.text = newTitle.name;
                                      });
                                    }
                                  },
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(tasks.length, (taskIndex) {
                    final now = DateTime.now();
                    final formattedTime = DateFormat('hh:mm a').format(now);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: tasks[taskIndex].isChecked
                            ? Border.all(color: Colors.blue.shade200, width: 1)
                            : null,
                      ),
                      child: Container(
                        decoration: tasks[taskIndex].isChecked
                            ? BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                              )
                            : null,
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 40,
                                  child: Checkbox(
                                    value: tasks[taskIndex].isChecked,
                                    onChanged: (value) {
                                      setState(() {
                                        if (value == true) {
                                          for (var i = 0;
                                              i < tasks.length;
                                              i++) {
                                            if (i != taskIndex) {
                                              tasks[i].isChecked = false;
                                              final toDoStatus =
                                                  allTaskStates.firstWhere(
                                                (status) =>
                                                    status.status
                                                        .toLowerCase()
                                                        .contains('to-do') ||
                                                    status.status
                                                        .toLowerCase()
                                                        .contains('todo'),
                                                orElse: () =>
                                                    allTaskStates.first,
                                              );
                                              tasks[i].status = toDoStatus.id;
                                            }
                                          }
                                          tasks[taskIndex].isChecked = true;
                                          final completedStatus =
                                              allTaskStates.firstWhere(
                                            (status) => status.id == '4',
                                            orElse: () =>
                                                allTaskStates.firstWhere(
                                              (status) => status.status
                                                  .toLowerCase()
                                                  .contains('complete'),
                                              orElse: () => allTaskStates.first,
                                            ),
                                          );
                                          tasks[taskIndex].status =
                                              completedStatus.id;
                                        } else {
                                          tasks[taskIndex].isChecked = false;
                                        }
                                      });
                                    },
                                  ),
                                ),

                                const SizedBox(width: 8),

                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    controller: tasks[taskIndex].controller,
                                    minLines: 1,
                                    maxLines: 2,
                                    decoration: InputDecoration(
                                      hintText: 'Enter task title',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // Status Dropdown
                                Container(
                                  width: 110,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.grey.shade50,
                                  ),
                                  child: DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    value:
                                        tasks[taskIndex].status?.isNotEmpty ==
                                                true
                                            ? tasks[taskIndex].status
                                            : (allTaskStates.isNotEmpty
                                                ? allTaskStates.first.id
                                                : null),
                                    items: allTaskStates
                                        .map((status) => DropdownMenuItem(
                                              value: status.id,
                                              child: Text(
                                                status.status,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontSize: 12),
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: (value) => setState(() {
                                      tasks[taskIndex].status = value;
                                    }),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                    ),
                                    icon: const Icon(Icons.arrow_drop_down,
                                        size: 20),
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // Time and Delete
                                Column(
                                  children: [
                                    if (taskIndex != 0)
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade50,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: IconButton(
                                          icon: const Icon(Icons.close,
                                              color: Colors.red, size: 16),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(
                                              maxWidth: 30, maxHeight: 30),
                                          onPressed: () {
                                            setState(() {
                                              tasks.removeAt(taskIndex);
                                            });
                                          },
                                        ),
                                      ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        formattedTime,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            ...List.generate(
                                tasks[taskIndex].remarksControllers.length,
                                (remarkIndex) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: tasks[taskIndex]
                                            .remarksControllers[remarkIndex],
                                        minLines: 1,
                                        maxLines: 2,
                                        decoration: InputDecoration(
                                          hintText:
                                              '${widget.Restart == 1 ? "Remark" : (widget.existingWork != null && widget.isPaused != 1 && widget.Restart != 1) ? "Remark" : "Description"} ${remarkIndex + 1}',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: remarkIndex == 0
                                            ? Colors.green.shade50
                                            : Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: IconButton(
                                        icon: Icon(
                                          remarkIndex == 0
                                              ? Icons.add
                                              : Icons.remove,
                                          color: remarkIndex == 0
                                              ? Colors.green.shade700
                                              : Colors.red.shade700,
                                          size: 18,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                            maxWidth: 32, maxHeight: 32),
                                        onPressed: () {
                                          if (remarkIndex == 0) {
                                            _addDescriptionField(taskIndex);
                                          } else {
                                            _removeDescriptionField(
                                                taskIndex, remarkIndex);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),

                            // Add Task Button (only for last task)
                            if ((taskIndex == tasks.length - 1) && widget.Restart != 1 && widget.isAssigned != 1)
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  icon: const Icon(Icons.add_circle_outline,
                                      size: 18),
                                  label: const Text(
                                    "Add Task",
                                    style: TextStyle(fontSize: 13),
                                  ),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.green.shade700,
                                    backgroundColor: Colors.green.shade50,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      tasks.add(TaskForm(
                                        controller: TextEditingController(),
                                        status: allTaskStates.isNotEmpty
                                            ? allTaskStates.first.id
                                            : '',
                                        taskId: null,
                                        remarks: [TextEditingController()],
                                      ));
                                    });
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Bottom Action Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Location Toggle
                InkWell(
                  onTap: _isGettingLocation
                      ? null
                      : () async {
                          setState(() {
                            isLocationEnabled = !isLocationEnabled;
                            _isGettingLocation = true;
                          });

                          if (isLocationEnabled) {
                            await _getCurrentLocation();
                          } else {
                            currentLatitude = null;
                            currentLongitude = null;
                          }

                          setState(() {
                            _isGettingLocation = false;
                          });
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: isLocationEnabled,
                          activeColor: Colors.blue.shade700,
                          onChanged: _isGettingLocation
                              ? null
                              : (value) async {
                                  setState(() {
                                    isLocationEnabled = value ?? false;
                                    _isGettingLocation = true;
                                  });

                                  if (isLocationEnabled) {
                                    await _getCurrentLocation();
                                  } else {
                                    currentLatitude = null;
                                    currentLongitude = null;
                                  }

                                  setState(() {
                                    _isGettingLocation = false;
                                  });
                                },
                        ),
                        Text(
                          'Update Location',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        if (_isGettingLocation) ...[
                          const SizedBox(width: 8),
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

              
               if (widget.existingWork != null &&
    widget.isPaused != 1 &&
    widget.Restart != 1) ...[
  if (tasks.any(
    (task) =>
        task.isChecked &&
        (task.status == '3' || task.status == '6'),
  )) ...[
    Align(
      alignment: Alignment.centerLeft,
      child: Text(
        "Attachments",
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      ),
    ),

    const SizedBox(height: 8),

    SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _pickStopWorkAttachments,
        icon: const Icon(Icons.attach_file),
        label: const Text("Upload Attachment"),
      ),
    ),

    const SizedBox(height: 10),

    if (stopWorkAttachments.isNotEmpty)
      Column(
        children: List.generate(
          stopWorkAttachments.length,
          (index) {
            final file = stopWorkAttachments[index];

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
                        stopWorkAttachments.removeAt(index);
                      });
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),

    const SizedBox(height: 12),

    Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade600,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          onPressed: _submitWork,
          child: const Text(
            'STOP WORK',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    ),
  ] else ...[
    Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          onPressed: _savework,
          child: const Text(
            'SAVE WORK',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    ),
  ],
] else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.isPaused == 1
                            ? Colors.orange.shade600
                            : (widget.Restart == 1
                                ? Colors.green.shade600
                                : Colors.green.shade600),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: widget.isPaused == 1 && widget.Restart != 1
                          ? _pauseWork
                          : (widget.Restart == 1
                              ? _restartWork
                              : _submitWork),
                      child: Text(
                        widget.isPaused == 1
                            ? "PAUSE WORK"
                            : (widget.Restart == 1
                                ? "RESTART WORK"
                                : 'START WORK'),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Dialog Methods
  Future<Map<String, dynamic>?> dropDialogExisting(
    BuildContext context, String title) async {
  search.clear();

  if (title == "Projects") {
    filterProjectsDialog("");
  }

  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Select $title",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          search.clear();
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: search,
                    decoration: InputDecoration(
                      hintText: "Search...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      if (title == "Projects") {
                        setState(() {
                          filterProjectsDialog(value);
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 12),

                  Expanded(
                    child: ListView.builder(
                      itemCount:
                          title == "Projects" ? filteredProjects.length : 0,
                      itemBuilder: (context, index) {
                        final project = filteredProjects[index];

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: Text(
                              project.name[0].toUpperCase(),
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(project.name),
                          onTap: () {
                            search.clear();

                            Navigator.pop<Map<String, dynamic>>(context, {
                              "id": project.id.toString(),
                              "name": project.name,
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
Future<Map<String, String>?> dropTitleDialog(
  BuildContext context,
  List<TitleListDet> titleList,
) async {
  final TextEditingController searchController = TextEditingController();
  List<TitleListDet> filteredTitles = List.from(titleList);

  return await showDialog<Map<String, String>>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * .60,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [

                    /// Header
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "Select Module",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          splashRadius: 22,
                          onPressed: () =>
                              Navigator.pop(dialogContext),
                          icon: const Icon(Icons.close),
                        )
                      ],
                    ),

                    const SizedBox(height: 12),

                    /// Search
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: "Search Module",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          filteredTitles = titleList.where((e) {
                            return e.name
                                .toLowerCase()
                                .contains(value.toLowerCase());
                          }).toList();
                        });
                      },
                    ),

                    const SizedBox(height: 15),

                    Expanded(
                      child: filteredTitles.isEmpty
                          ? const Center(
                              child: Text("No Modules Found"),
                            )
                          : ListView.separated(
                              itemCount: filteredTitles.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final title = filteredTitles[index];

                                return InkWell(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  onTap: () {
                                    FocusScope.of(context).unfocus();

                                    Navigator.pop(
                                      dialogContext,
                                      {
                                        "id": title.id.toString(),
                                        "name": title.name,
                                      },
                                    );
                                  },
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 10,
                                    ),
                                    child: Row(
                                      children: [

                                        CircleAvatar(
                                          radius: 18,
                                          backgroundColor:
                                              const Color(0xff2A86C9)
                                                  .withOpacity(.12),
                                          child: Text(
                                            title.name.isNotEmpty
                                                ? title.name[0]
                                                    .toUpperCase()
                                                : "?",
                                            style: const TextStyle(
                                              color:
                                                  Color(0xff2A86C9),
                                              fontWeight:
                                                  FontWeight.bold,
                                            ),
                                          ),
                                        ),

                                        const SizedBox(width: 12),

                                        Expanded(
                                          child: Text(
                                            title.name,
                                            style:
                                                const TextStyle(
                                              fontSize: 15,
                                              fontWeight:
                                                  FontWeight.w500,
                                            ),
                                          ),
                                        ),

                                        const Icon(
                                          Icons.chevron_right,
                                          color: Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
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

Future<TitleListDet?> showProjectTitleDialog(BuildContext context) async {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController projectController =
      TextEditingController(text: selectedProjectName ?? '');

  return showDialog<TitleListDet>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Add New Module',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 16),

                  InkWell(
                    onTap: () async {
                      final selectedProject =
                          await dropDialogExisting(context, "Projects");

                      if (selectedProject != null) {
                        setState(() {
                          selectedProjectId = selectedProject["id"].toString();
                          selectedProjectName = selectedProject["name"].toString();
                          projectController.text = selectedProjectName!;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Project',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: const Icon(Icons.arrow_drop_down),
                      ),
                      child: Text(
                        projectController.text.isEmpty
                            ? "Select Project"
                            : projectController.text,
                        style: TextStyle(
                          color: projectController.text.isEmpty
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Module Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () async {
                            if (selectedProjectId == null ||
                                selectedProjectId!.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                      'Please select a project'),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Colors.red.shade400,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                              return;
                            }

                            if (titleController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                      'Please enter module name'),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Colors.red.shade400,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                              return;
                            }

                            final newTitle =
                                await HttpService.submitTitle(
                              context: context,
                              projectId: selectedProjectId!,
                              title: titleController.text.trim(),
                            );

                            if (newTitle != null) {
                              // Automatically select newly created module
                              this.setState(() {
                                selectedTitleId = newTitle.id;
                                this.titleController.text = newTitle.name;
                              });

                              Navigator.pop(dialogContext, newTitle);
                            }
                          },
                          child: const Text('Submit'),
                        ),
                      ),
                    ],
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

}

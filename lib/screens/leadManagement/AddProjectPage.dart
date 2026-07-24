import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/expense/customerListModel.dart';
import 'package:login2/models/expense/getProjectListModel.dart';
import 'package:login2/screens/leadManagement/SingleProjectDashboard.dart';
import 'package:login2/screens/leadManagement/projectDashboard.dart';
import 'package:login2/service/service.dart';
class AddProjectPage extends StatefulWidget {
  const AddProjectPage({super.key});

  @override
  State<AddProjectPage> createState() => _AddProjectPageState();
}

class _AddProjectPageState extends State<AddProjectPage> {
  List<ProjectExp> projects = [];
  List<ProjectExp> filteredProjects = [];
  ProjectPermissions? permissions;
  List<CustomerExp> customers = [];
  List<CustomerExp> filteredCustomers = [];
  final TextEditingController searchController = TextEditingController();
  final TextEditingController selectedCustomerController =
      TextEditingController();
  final TextEditingController projectNameController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  String? selectedCustomerId;
  DateTime? startDate;
  DateTime? endDate;
  bool isLoading = true;
  bool hasError = false;
  bool saveToLocation = false;
  @override
  void initState() {
    super.initState();
    loadInitialData();
    searchController.addListener(() {
      filterProjects(searchController.text);
    });
  }

 Future<void> loadInitialData() async {
  setState(() {
    isLoading = true;
    hasError = false;
  });
  try {
    final projectResponse = await HttpService.getProjectsLists();
    final customerResponse = await HttpService.getCustomers();
    if (customerResponse != null && customerResponse.status) {
      customers = customerResponse.data;
      filteredCustomers = List.from(customers); 
    }
    if (projectResponse != null && projectResponse.status) {
      projects = projectResponse.data.list;
      permissions = projectResponse.data.permissions;
      filteredProjects = List.from(projects);
    }
    setState(() => isLoading = false);
  } catch (e) {
    log("loadInitialData error: $e");
    setState(() {
      hasError = true;
      isLoading = false;
    });
  }
}

  void filterProjects(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      filteredProjects = projects
          .where((p) => p.projectName.toLowerCase().contains(lowerQuery))
          .toList();
    });
  }

  void filterCustomers(String query) {
    if (customers.isEmpty) return;
    final lower = query.toLowerCase();
    setState(() {
      filteredCustomers = query.isEmpty
          ? List.from(customers)
          : customers
              .where((c) => c.name.toLowerCase().contains(lower))
              .toList();
    });
  }

  void clearForm() {
    selectedCustomerId = null;
    selectedCustomerController.clear();
    projectNameController.clear();
    startDateController.clear();
    endDateController.clear();
    startDate = null;
    endDate = null;
    saveToLocation = false;
  }

  Future<dynamic> dropDialogExisting(BuildContext context, String title) {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            if (filteredCustomers.isEmpty && customers.isNotEmpty) {
              filteredCustomers = List.from(customers);
            }
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
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: TextField(
                      autofocus: true,
                      onChanged: filterCustomers,
                      decoration: const InputDecoration(
                        labelText: 'Search',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                width: MediaQuery.of(context).size.width * 0.8,
                child: filteredCustomers.isEmpty
                    ? const Center(child: Text("No customers found"))
                    : ListView.builder(
                        itemCount: filteredCustomers.length,
                        itemBuilder: (context, index) {
                          if (index >= filteredCustomers.length) {
                            return const SizedBox(); 
                          }
                          final customer = filteredCustomers[index];
                          return ListTile(
                            title: Text(customer.name),
                            onTap: () {
                              Navigator.pop(context, {
                                'id': customer.id,
                                'name': customer.name,
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

  void showAddOrEditDialog({ProjectExp? project}) {
    if (project != null) {
  selectedCustomerId = project.customerId;
  selectedCustomerController.text = project.customerName;
  projectNameController.text = project.projectName;
  startDate = project.fromDate != null
      ? DateTime.tryParse(project.fromDate!)
      : null;
  endDate = project.toDate != null
      ? DateTime.tryParse(project.toDate!)
      : null;

  startDateController.text = project.fromDate ?? "";
  endDateController.text = project.toDate ?? "";

  // Set checkbox value from project
  saveToLocation = project.saveToLocation == "Y"; // or project.saveToLocation == true
} else {
  clearForm();
  saveToLocation = false;
}
showDialog(
  context: context,
  builder: (ctx) {
    return StatefulBuilder(
      builder: (context, dialogSetState) {
        return AlertDialog(
          title: Text(project != null ? "Edit Project" : "Add Project"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: selectedCustomerController,
                  readOnly: true,
                  onTap: () async {
                    final selected =
                        await dropDialogExisting(context, "Customers");
                    if (selected != null) {
                      dialogSetState(() {
                        selectedCustomerId = selected['id'];
                        selectedCustomerController.text = selected['name'];
                      });
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Customer',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: projectNameController,
                  decoration: const InputDecoration(
                    labelText: 'Project Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: startDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );

                    if (picked != null) {
                      dialogSetState(() {
                        startDate = picked;
                        startDateController.text =
                            DateFormat('dd-MM-yyyy').format(picked);
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: startDateController,
                      decoration: const InputDecoration(
                        labelText: 'Start Date',
                        suffixIcon: Icon(Icons.calendar_month),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: endDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );

                    if (picked != null) {
                      dialogSetState(() {
                        endDate = picked;
                        endDateController.text =
                            DateFormat('dd-MM-yyyy').format(picked);
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: endDateController,
                      decoration: const InputDecoration(
                        labelText: 'End Date',
                        suffixIcon: Icon(Icons.calendar_month),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                CheckboxListTile(
                  value: saveToLocation,
                  onChanged: (value) {
                    dialogSetState(() {
                      saveToLocation = value ?? false;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text(
                    "Save to location",
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (startDate == null &&
                    startDateController.text.isNotEmpty) {
                  try {
                    startDate = DateFormat('dd-MM-yyyy')
                        .parseStrict(startDateController.text);
                  } catch (_) {}
                }

                if (endDate == null &&
                    endDateController.text.isNotEmpty) {
                  try {
                    endDate = DateFormat('dd-MM-yyyy')
                        .parseStrict(endDateController.text);
                  } catch (_) {}
                }

                if (selectedCustomerId != null &&
                    projectNameController.text.isNotEmpty) {
                  bool result;

                  if (project == null) {
                    result = await HttpService.addProjectsCustomers(
                      customerId: selectedCustomerId!,
                      projectName: projectNameController.text,
                      startDate: startDate,
                      endDate: endDate,
                      saveToLocation: saveToLocation,
                    );
                  } else {
                    result = await HttpService.updateProject(
                      id: project.id,
                      customerId: selectedCustomerId!,
                      projectName: projectNameController.text,
                      startDate: startDate,
                      endDate: endDate,
                      saveToLocation: saveToLocation,
                    );
                  }

                  if (result) {
                    Navigator.pop(ctx);
                    await loadInitialData();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          project == null
                              ? "Project added successfully"
                              : "Project updated successfully",
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );

                    clearForm();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          project == null
                              ? "Failed to add project"
                              : "Failed to update project",
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(project != null ? "Update" : "Add"),
            ),
          ],
        );
      },
    );
  },
);
  }

  void deleteProject(String id) async {
    final confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Project"),
        content: const Text("Are you sure you want to delete this project?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Delete")),
        ],
      ),
    );

    if (confirm == true) {
      final result = await HttpService.deleteProject(id);
      if (result) {
        await loadInitialData();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Project deleted successfully"),
          backgroundColor: Colors.green,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Failed to delete project"),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text("Projects"),
        backgroundColor: const Color.fromARGB(255, 81, 139, 238),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard),
              onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProjectDashboard(),
                ),
              );
            },
            tooltip: "Project dashboard",
          ),
          if (permissions == null || permissions!.addProject)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => showAddOrEditDialog(),
              tooltip: "Add Project",
            ),
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : hasError
                ? const Center(
                    child: Text("Something went wrong!",
                        style: TextStyle(color: Colors.red)))
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: 'Search by project name...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      Expanded(
                        child: filteredProjects.isEmpty
                            ? const Center(
                                child: Text("No project data found",
                                    style: TextStyle(fontSize: 16)))
                            : ListView.builder(
                                itemCount: filteredProjects.length,
                                itemBuilder: (context, index) {
                                  final item = filteredProjects[index];
                                  final List<Color> accentColors = [
                                    const Color(0xFF6C63FF), // Indigo
                                    const Color(0xFF00B4D8), // Cyan
                                    const Color(0xFFFF6584), // Pink/Coral
                                    const Color(0xFF38B000), // Green
                                    const Color(0xFFFF9F1C), // Orange
                                  ];
                                  final Color accentColor = accentColors[index % accentColors.length];

                                  return Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: accentColor.withOpacity(0.15),
                                          blurRadius: 15,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => SingleProjectDashboard(project: item, permissions: permissions),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border(
                                                left: BorderSide(color: accentColor, width: 6),
                                              ),
                                            ),
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.all(12),
                                                      decoration: BoxDecoration(
                                                        color: accentColor.withOpacity(0.1),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        Icons.rocket_launch_rounded,
                                                        color: accentColor,
                                                        size: 26,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            item.projectName,
                                                            style: const TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 18,
                                                              color: Colors.black87,
                                                            ),
                                                            maxLines: 2,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                          const SizedBox(height: 6),
                                                          Row(
                                                            children: [
                                                              Container(
                                                                padding: const EdgeInsets.all(4),
                                                                decoration: BoxDecoration(
                                                                  color: Colors.grey.shade100,
                                                                  borderRadius: BorderRadius.circular(6),
                                                                ),
                                                                child: const Icon(Icons.person, size: 14, color: Colors.grey),
                                                              ),
                                                              const SizedBox(width: 8),
                                                              Expanded(
                                                                child: Text(
                                                                  item.customerName,
                                                                  style: const TextStyle(
                                                                    fontWeight: FontWeight.w600,
                                                                    fontSize: 14,
                                                                    color: Colors.black54,
                                                                  ),
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    if (permissions == null || permissions!.editProject || permissions!.deleteProject)
                                                      Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          if (permissions == null || permissions!.editProject)
                                                            IconButton(
                                                              icon: Container(
                                                                padding: const EdgeInsets.all(6),
                                                                decoration: BoxDecoration(color: Colors.orange.shade50, shape: BoxShape.circle),
                                                                child: const Icon(Icons.edit_outlined, color: Colors.orange, size: 18),
                                                              ),
                                                              padding: EdgeInsets.zero,
                                                              constraints: const BoxConstraints(),
                                                              onPressed: () => showAddOrEditDialog(project: item),
                                                            ),
                                                          const SizedBox(width: 8),
                                                          if (permissions == null || permissions!.deleteProject)
                                                            IconButton(
                                                              icon: Container(
                                                                padding: const EdgeInsets.all(6),
                                                                decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                                                                child: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                                                              ),
                                                              padding: EdgeInsets.zero,
                                                              constraints: const BoxConstraints(),
                                                              onPressed: () => deleteProject(item.id),
                                                            ),
                                                        ],
                                                      ),
                                                  ],
                                                ),
                                                if (item.fromDate != null && item.toDate != null && item.fromDate!.isNotEmpty && item.toDate!.isNotEmpty) ...[
                                                  const SizedBox(height: 16),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                                    decoration: BoxDecoration(
                                                      color: accentColor.withOpacity(0.05),
                                                      borderRadius: BorderRadius.circular(12),
                                                      border: Border.all(color: accentColor.withOpacity(0.1)),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.calendar_month_rounded, size: 16, color: accentColor),
                                                        const SizedBox(width: 10),
                                                        Text(
                                                          "${item.fromDate}  ➔  ${item.toDate}",
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            fontWeight: FontWeight.w600,
                                                            color: accentColor.withOpacity(0.8),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

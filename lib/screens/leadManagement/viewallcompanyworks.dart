import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/expense/expense_post.dart';
import 'package:login2/screens/leadManagement/AddProjectPage.dart';
import 'package:login2/screens/leadManagement/AssignReport.dart';
import 'package:login2/screens/leadManagement/StaffCalendarPage.dart';
import 'package:login2/screens/leadManagement/addWork_page.dart';
import 'package:login2/screens/leadManagement/assignWorkPage.dart';
import 'package:login2/screens/leadManagement/pendingWorkPage.dart';
import 'package:login2/screens/leadManagement/totalSummeryPage.dart';
import 'package:login2/screens/leadManagement/viewwork_page.dart';
import '../../models/lead_management/workDetailsCompanyModel.dart';
import 'package:login2/models/lead_management/workstatus_model.dart'
    as workStatus;
import '../../service/service.dart';
import '../staff_reports/timeline_page.dart';

class ViewCompanyWorkPage extends StatefulWidget {
  const ViewCompanyWorkPage({super.key});

  @override
  State<ViewCompanyWorkPage> createState() => _ViewCompanyWorkPageState();
}

class _ViewCompanyWorkPageState extends State<ViewCompanyWorkPage> {
  late String currentDate;
  WorkCompanyDetailsModel? workStatusDetails;
  workStatus.WorkStatus? existingWork;
  String multipleWorksCheck = '';
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  String searchText = "";
  DateTime selectedDate = DateTime.now();
  String token = '';
  CommonResponse? loginOrNot;
  String viewAttendanceSection = '';
  String viewAttendance = '';
  bool? isLoggedIn;
  @override
  @override
  void initState() {
    super.initState();
    currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getWorkDuration(currentDate);
      checkExistingWorkStatus();
      _initMultipleWorksCheck();
      loginorNot();
      _viewAttendanceSection();
    });
    searchController.addListener(() {
      setState(() {
        searchText = searchController.text.toLowerCase();
      });
    });
  }

  Future<void> _initMultipleWorksCheck() async {
    final value = await Common.getSharedPref("multipleWorks");

    setState(() {
      multipleWorksCheck = value ?? '';
    });
  }

  Future<void> _viewAttendanceSection() async {
    final viewAttendanceSection =
        await Common.getSharedPref("viewAttendanceSection");
    setState(() {
      viewAttendance = viewAttendanceSection ?? '';
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

  Future<void> getWorkDuration(String date) async {
    final response = await HttpService.getWorkCompanyStatusDetails(date);
    setState(() {
      workStatusDetails = response;
      isLoading = false;
    });
  }

  // if (loginOrNot?.data == true) {
  //   print("Logged in Today.");
  // } else {
  //   Future.delayed(Duration.zero, () {
  //     showLoginPrompt(context);
  //   });
  // }

  String _formatTime(String? time) {
    if (time == null || time.isEmpty) return "--";
    try {
      final dt = DateTime.parse(time);
      return DateFormat('hh:mm a').format(dt);
    } catch (_) {
      return time;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = workStatusDetails?.data
            .where((staff) => staff.name.toLowerCase().contains(searchText))
            .toList() ??
        [];

    return Scaffold(
      appBar: AppBar(
        title: const Text("View All Works"),
        backgroundColor: const Color.fromARGB(255, 77, 155, 228),
        foregroundColor: Colors.white,
        actions: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.calendar_month_sharp),
                onPressed: () {
                  showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  ).then((pickedDate) {
                    if (pickedDate != null) {
                      setState(() {
                        selectedDate = pickedDate;
                      });
                      String formattedDate =
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                      getWorkDuration(formattedDate);
                    }
                  });
                },
              ),
              //  IconButton(
              //   icon: const Icon(Icons.align_horizontal_left),
              //   onPressed: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => TotalSummeryPage(
              //         ),
              //       ),
              //     );
              //   },
              // ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert), // 3 dots vertical
                onSelected: (value) {
                  if (value == 'summary') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TotalSummeryPage(),
                      ),
                    );
                  } else if (value == 'add_project') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddProjectPage(),
                      ),
                    );
                  } else if (value == 'pending_works') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PendingWorkPage(),
                      ),
                    );
                  } else if (value == 'assign_works') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AssignWorkPage(
                          // existingWork: '',
                          onSuccess: () {
                            setState(() {
                              getWorkDuration(currentDate);
                              checkExistingWorkStatus();
                            });
                          },
                        ),
                      ),
                    );
                  } else if (value == 'assign_report') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AssignReport(workId: "", sectionId: ""),
                      ),
                    );
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'summary',
                    child: Text('Total Work Summary'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'add_project',
                    child: Text('Add Project'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'pending_works',
                    child: Text('Pending Works'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'assign_works',
                    child: Text('Assign Works'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'assign_report',
                    child: Text('Assigned Report'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: existingWork != null
          ? StreamBuilder<DateTime>(
              stream: Stream.periodic(
                  const Duration(seconds: 1), (_) => DateTime.now()),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();

                final now = snapshot.data!;
                final createdAt = DateTime.parse(existingWork!.createdAt);
                final diff = now.difference(createdAt);
                String timeSince =
                    "${diff.inHours.toString().padLeft(2, '0')}:${(diff.inMinutes % 60).toString().padLeft(2, '0')}:${(diff.inSeconds % 60).toString().padLeft(2, '0')}";

                return FloatingActionButton.extended(
                  onPressed: () async {
                    final workStatusModel = await HttpService.getWorkStatus();
                    workStatus.WorkStatus? newExistingWork;

                    if (workStatusModel != null &&
                        workStatusModel.data.isNotEmpty) {
                      newExistingWork = workStatusModel.data.first;
                    }

                    final paused = await showDialog(
                      context: context,
                      builder: (context) => AddWorkPage(
                        workId: "",
                        existingWork: newExistingWork,
                        isAssigned: 1,
                        onSuccess: () {
                          setState(() {
                            getWorkDuration(currentDate);
                            checkExistingWorkStatus();
                          });
                        },
                      ),
                    );

                    if (paused == true) {
                      setState(() {
                        existingWork = null;
                      });
                      getWorkDuration(currentDate);
                    }
                  },
                  backgroundColor: Colors.red,
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timeSince,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.pause, color: Colors.white),
                    ],
                  ),
                );
              },
            )
          : FloatingActionButton(
              onPressed: () async {
                if (isLoggedIn == true) {
                  final workStatusModel = await HttpService.getWorkStatus();
                  workStatus.WorkStatus? newExistingWork;

                  if (workStatusModel != null &&
                      workStatusModel.data.isNotEmpty) {
                    newExistingWork = workStatusModel.data.first;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddWorkPage(
                        workId: "",
                        existingWork: newExistingWork,
                        onSuccess: () {
                          setState(() {
                            getWorkDuration(currentDate);
                            checkExistingWorkStatus();
                          });
                        },
                      ),
                    ),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Login Required'),
                        content: const Text('Please login to add work.'),
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
                }
              },
              backgroundColor: Colors.green,
              child: const Icon(Icons.add, color: Colors.white),
            ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                Expanded(
                    child: RefreshIndicator(
                  onRefresh: () async {
                    await getWorkDuration(currentDate);
                    await checkExistingWorkStatus();
                  },
                  child: filteredList.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 200),
                            Center(child: Text("No work data available")),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            final staff = filteredList[index];
                            return GestureDetector(
                              onTap: () {
                                if (staff.multiple == "true") {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text("Phone Call Log"),
                                        content: const Text(
                                            "Choose an action below"),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => ViewWorkPage(
                                                    staffName: staff.name,
                                                    staffId: staff.staffId,
                                                    selectedDate: selectedDate,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: const Text("Works"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      const TimelinePage(),
                                                  settings: RouteSettings(
                                                    arguments: {
                                                      "staffId": staff.staffId,
                                                      "selectedDate":
                                                          selectedDate,
                                                    },
                                                  ),
                                                ),
                                              );
                                            },
                                            child: const Text("Call Log"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                } else if (staff.taskName == "") {
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (_) => ViewWorkPage(
                                  //       staffName: staff.name,
                                  //       staffId: staff.staffId,
                                  //       selectedDate: selectedDate,
                                  //     ),
                                  //   ),
                                  // );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const TimelinePage(),
                                      settings: RouteSettings(
                                        arguments: {
                                          "staffId": staff.staffId,
                                          "selectedDate": selectedDate,
                                        },
                                      ),
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ViewWorkPage(
                                        staffName: staff.name,
                                        staffId: staff.staffId,
                                        selectedDate: selectedDate,
                                      ),
                                    ),
                                  );
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (_) => const TimelinePage(),
                                  //     settings: RouteSettings(
                                  //       arguments: {
                                  //         "staffId": staff.staffId,
                                  //         "selectedDate": selectedDate,
                                  //       },
                                  //     ),
                                  //   ),
                                  // );
                                }
                              },
                              // child: Container(
                              //   margin: const EdgeInsets.only(bottom: 12),
                              //   padding: const EdgeInsets.all(16),
                              //   decoration: BoxDecoration(
                              //     color: Colors.white,
                              //     borderRadius: BorderRadius.circular(12),
                              //     boxShadow: [
                              //       BoxShadow(
                              //         color: Colors.black12,
                              //         blurRadius: 4,
                              //         offset: const Offset(0, 2),
                              //       ),
                              //     ],
                              //   ),
                              //   child: Row(
                              //     crossAxisAlignment: CrossAxisAlignment.start,
                              //     children: [
                              //       CircleAvatar(
                              //         radius: 22,
                              //         backgroundColor: Colors.blue,
                              //         child: Text(
                              //           staff.name.isNotEmpty
                              //               ? staff.name[0].toUpperCase()
                              //               : "?",
                              //           style: const TextStyle(
                              //               color: Colors.white,
                              //               fontWeight: FontWeight.bold),
                              //         ),
                              //       ),
                              //       const SizedBox(width: 12),
                              //       Expanded(
                              //         child: Column(
                              //           crossAxisAlignment:
                              //               CrossAxisAlignment.start,
                              //           children: [
                              //             Row(
                              //               children: [
                              //                 Text(
                              //                   staff.name,
                              //                   style: const TextStyle(
                              //                     fontSize: 18,
                              //                     fontWeight: FontWeight.w600,
                              //                     color: Colors.black87,
                              //                   ),
                              //                 ),
                              //                 const SizedBox(width: 8),
                              //                 // Text(
                              //                 //   staff.status.toLowerCase() ==
                              //                 //           "started"
                              //                 //       ? "(Online)"
                              //                 //       : staff.status
                              //                 //                   .toLowerCase() ==
                              //                 //               "ended"
                              //                 //           ? "(Offline)"
                              //                 //           : "(Not Started)",
                              //                 //   style: TextStyle(
                              //                 //     color: staff.status
                              //                 //                 .toLowerCase() ==
                              //                 //             "started"
                              //                 //         ? Colors.green
                              //                 //         : staff.status
                              //                 //                     .toLowerCase() ==
                              //                 //                 "ended"
                              //                 //             ? Colors.red
                              //                 //             : Colors.grey,
                              //                 //     fontWeight: FontWeight.w500,
                              //                 //     fontSize: 14,
                              //                 //   ),
                              //                 // ),
                              //                 Positioned(
                              //                   top: 8,
                              //                   right: 25,
                              //                   child: Container(
                              //                     width: 12,
                              //                     height: 12,
                              //                     decoration: BoxDecoration(
                              //                       color: staff.status
                              //                                   .toLowerCase() ==
                              //                               "started"
                              //                           ? Colors.green
                              //                           : staff.status
                              //                                       .toLowerCase() ==
                              //                                   "ended"
                              //                               ? Colors.red
                              //                               : Colors.grey,
                              //                       shape: BoxShape.circle,
                              //                     ),
                              //                   ),
                              //                 ),
                              //               ],
                              //             ),
                              //             const SizedBox(height: 8),
                              //             Row(
                              //               children: [
                              //                 const Icon(Icons.play_arrow,
                              //                     size: 16,
                              //                     color: Colors.green),
                              //                 const SizedBox(width: 4),
                              //                 Text(
                              //                   "Login Time: ${_formatTime(staff.firstLoginTime)}",
                              //                   style: const TextStyle(
                              //                       fontSize: 14),
                              //                 ),
                              //               ],
                              //             ),
                              //             const SizedBox(height: 4),
                              //             Row(
                              //               children: [
                              //                 const Icon(Icons.stop,
                              //                     size: 16, color: Colors.red),
                              //                 const SizedBox(width: 4),
                              //                 Text(
                              //                   "Logout Time: ${_formatTime(staff.lastLogoutTime)}",
                              //                   style: const TextStyle(
                              //                       fontSize: 14),
                              //                 ),
                              //               ],
                              //             ),
                              //           ],
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              child: Stack(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          radius: 22,
                                          backgroundColor: Colors.blue,
                                          child: Text(
                                            staff.name.isNotEmpty
                                                ? staff.name[0].toUpperCase()
                                                : "?",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                staff.name,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  const Icon(Icons.play_arrow,
                                                      size: 16,
                                                      color: Colors.green),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    "Login Time: ${_formatTime(staff.firstLoginTime)}",
                                                    style: const TextStyle(
                                                        fontSize: 14),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(Icons.stop,
                                                      size: 16,
                                                      color: Colors.red),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    "Logout Time: ${_formatTime(staff.lastLogoutTime)}",
                                                    style: const TextStyle(
                                                        fontSize: 14),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          width: 16,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: staff.status.toLowerCase() ==
                                                    "started"
                                                ? Colors.green
                                                : staff.status.toLowerCase() ==
                                                        "ended"
                                                    ? const Color.fromARGB(
                                                        255, 241, 160, 67)
                                                    : const Color.fromARGB(
                                                        255, 247, 2, 2),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        viewAttendance == "true"
                                            ? const SizedBox(height: 40)
                                            : SizedBox(),
                                        viewAttendance == "true"
                                            ? Transform.translate(
                                                offset: const Offset(12, 0),
                                                child: IconButton(
                                                  icon: const Icon(
                                                      Icons.calendar_month,
                                                      size: 24,
                                                      color: Colors.teal),
                                                  tooltip: 'View Calendar',
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            StaffCalendarPage(
                                                                staffId: staff
                                                                    .staffId,
                                                                selectedDate:
                                                                    selectedDate,
                                                                staffName:
                                                                    staff.name),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              )
                                            : SizedBox(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                )),
              ],
            ),
    );
  }
}

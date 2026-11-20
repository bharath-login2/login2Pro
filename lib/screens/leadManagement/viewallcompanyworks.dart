// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:login2/core/common.dart';
// import 'package:login2/models/expense/expense_post.dart';
// import 'package:login2/screens/leadManagement/AddProjectPage.dart';
// import 'package:login2/screens/leadManagement/AssignReport.dart';
// import 'package:login2/screens/leadManagement/StaffCalendarPage.dart';
// import 'package:login2/screens/leadManagement/addWork_page.dart';
// import 'package:login2/screens/leadManagement/assignWorkPage.dart';
// import 'package:login2/screens/leadManagement/pendingWorkPage.dart';
// import 'package:login2/screens/leadManagement/totalSummeryPage.dart';
// import 'package:login2/screens/leadManagement/viewwork_page.dart';
// import '../../models/lead_management/workDetailsCompanyModel.dart';
// import 'package:login2/models/lead_management/workstatus_model.dart'
//     as workStatus;
// import '../../service/service.dart';
// import '../staff_reports/timeline_page.dart';
// import 'package:login2/widgets/work_timer_overlay.dart';
// import 'package:login2/widgets/work_timer_chip.dart';

// class ViewCompanyWorkPage extends StatefulWidget {
//   const ViewCompanyWorkPage({super.key});

//   @override
//   State<ViewCompanyWorkPage> createState() => _ViewCompanyWorkPageState();
// }

// class _ViewCompanyWorkPageState extends State<ViewCompanyWorkPage> {
//   late String currentDate;
//   WorkCompanyDetailsModel? workStatusDetails;
//   workStatus.WorkStatus? existingWork;
//   String multipleWorksCheck = '';
//   bool isLoading = true;
//   TextEditingController searchController = TextEditingController();
//   String searchText = "";
//   DateTime selectedDate = DateTime.now();
//   String token = '';
//   CommonResponse? loginOrNot;
//   String viewAttendanceSection = '';
//   String viewAttendance = '';
//   bool? isLoggedIn;
//   @override
//   @override
//   void initState() {
//     super.initState();
//     currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       getWorkDuration(currentDate);
//       checkExistingWorkStatus();
//       _initMultipleWorksCheck();
//       loginorNot();
//       _viewAttendanceSection();
//     });
//     searchController.addListener(() {
//       setState(() {
//         searchText = searchController.text.toLowerCase();
//       });
//     });
//   }

//   Future<void> _initMultipleWorksCheck() async {
//     final value = await Common.getSharedPref("multipleWorks");

//     setState(() {
//       multipleWorksCheck = value ?? '';
//     });
//   }

//   Future<void> _viewAttendanceSection() async {
//     final viewAttendanceSection =
//         await Common.getSharedPref("viewAttendanceSection");
//     setState(() {
//       viewAttendance = viewAttendanceSection ?? '';
//     });
//   }

//   Future<void> checkExistingWorkStatus() async {
//     final workStatusModel = await HttpService.getWorkStatus();
//     setState(() {
//       if (workStatusModel != null && workStatusModel.data.isNotEmpty) {
//         existingWork = workStatusModel.data.first;
//       } else {
//         existingWork = null;
//       }
//     });
//     WorkTimerChip.refreshAll();
//   }

//   Future<void> loginorNot() async {
//     // final token = await Common.getSharedPref("token");
//     // final response = await HttpService.getLoginorNot(token);
//     final response = await HttpService.getCurrentLoginStatus();

//     setState(() {
//       if (response != null && response.data == true) {
//         isLoggedIn = true;
//       } else {
//         isLoggedIn = false;
//       }
//     });
//   }

//   Future<void> getWorkDuration(String date) async {
//     final response = await HttpService.getWorkCompanyStatusDetails(date);
//     setState(() {
//       workStatusDetails = response;
//       isLoading = false;
//     });
//   }

//   // if (loginOrNot?.data == true) {
//   //   print("Logged in Today.");
//   // } else {
//   //   Future.delayed(Duration.zero, () {
//   //     showLoginPrompt(context);
//   //   });
//   // }

//   String _formatTime(String? time) {
//     if (time == null || time.isEmpty) return "--";
//     try {
//       final dt = DateTime.parse(time);
//       return DateFormat('hh:mm a').format(dt);
//     } catch (_) {
//       return time;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final filteredList = workStatusDetails?.data
//             .where((staff) => staff.name.toLowerCase().contains(searchText))
//             .toList() ??
//         [];

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("View All Works"),
//         backgroundColor: const Color.fromARGB(255, 77, 155, 228),
//         foregroundColor: Colors.white,
//         actions: [
//           Row(
//             children: [
//               IconButton(
//                 icon: const Icon(Icons.calendar_month_sharp),
//                 onPressed: () {
//                   showDatePicker(
//                     context: context,
//                     initialDate: selectedDate,
//                     firstDate: DateTime(2000),
//                     lastDate: DateTime(2100),
//                   ).then((pickedDate) {
//                     if (pickedDate != null) {
//                       setState(() {
//                         selectedDate = pickedDate;
//                       });
//                       String formattedDate =
//                           DateFormat('yyyy-MM-dd').format(pickedDate);
//                       getWorkDuration(formattedDate);
//                     }
//                   });
//                 },
//               ),
//               //  IconButton(
//               //   icon: const Icon(Icons.align_horizontal_left),
//               //   onPressed: () {
//               //     Navigator.push(
//               //       context,
//               //       MaterialPageRoute(
//               //         builder: (context) => TotalSummeryPage(
//               //         ),
//               //       ),
//               //     );
//               //   },
//               // ),
//               PopupMenuButton<String>(
//                 icon: const Icon(Icons.more_vert), // 3 dots vertical
//                 onSelected: (value) {
//                   if (value == 'summary') {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const TotalSummeryPage(),
//                       ),
//                     );
//                   } else if (value == 'add_project') {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const AddProjectPage(),
//                       ),
//                     );
//                   } else if (value == 'pending_works') {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const PendingWorkPage(),
//                       ),
//                     );
//                   } else if (value == 'assign_works') {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => AssignWorkPage(
//                           // existingWork: '',
//                           onSuccess: () {
//                             setState(() {
//                               getWorkDuration(currentDate);
//                               checkExistingWorkStatus();
//                             });
//                           },
//                         ),
//                       ),
//                     );
//                   } else if (value == 'assign_report') {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) =>
//                             AssignReport(workId: "", sectionId: ""),
//                       ),
//                     );
//                   }
//                 },
//                 itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
//                   const PopupMenuItem<String>(
//                     value: 'summary',
//                     child: Text('Total Work Summary'),
//                   ),
//                   const PopupMenuItem<String>(
//                     value: 'add_project',
//                     child: Text('Add Project'),
//                   ),
//                   const PopupMenuItem<String>(
//                     value: 'pending_works',
//                     child: Text('Pending Works'),
//                   ),
//                   const PopupMenuItem<String>(
//                     value: 'assign_works',
//                     child: Text('Assign Works'),
//                   ),
//                   const PopupMenuItem<String>(
//                     value: 'assign_report',
//                     child: Text('Assigned Report'),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//       // floatingActionButton: existingWork != null
//       //     ? StreamBuilder<DateTime>(
//       //         stream: Stream.periodic(
//       //             const Duration(seconds: 1), (_) => DateTime.now()),
//       //         builder: (context, snapshot) {
//       //           if (!snapshot.hasData) return const SizedBox();

//       //           final now = snapshot.data!;
//       //           final createdAt = DateTime.parse(existingWork!.createdAt);
//       //           final diff = now.difference(createdAt);
//       //           String timeSince =
//       //               "${diff.inHours.toString().padLeft(2, '0')}:${(diff.inMinutes % 60).toString().padLeft(2, '0')}:${(diff.inSeconds % 60).toString().padLeft(2, '0')}";

//       //           return FloatingActionButton.extended(
//       //             onPressed: () async {
//       //               final workStatusModel = await HttpService.getWorkStatus();
//       //               workStatus.WorkStatus? newExistingWork;

//       //               if (workStatusModel != null &&
//       //                   workStatusModel.data.isNotEmpty) {
//       //                 newExistingWork = workStatusModel.data.first;
//       //               }

//       //               final paused = await showDialog(
//       //                 context: context,
//       //                 builder: (context) => AddWorkPage(
//       //                   workId: "",
//       //                   existingWork: newExistingWork,
//       //                   isAssigned: 1,
//       //                   onSuccess: () {
//       //                     setState(() {
//       //                       getWorkDuration(currentDate);
//       //                       checkExistingWorkStatus();
//       //                     });
//       //                   },
//       //                 ),
//       //               );

//       //               if (paused == true) {
//       //                 setState(() {
//       //                   existingWork = null;
//       //                 });
//       //                 getWorkDuration(currentDate);
//       //               }
//       //             },
//       //             backgroundColor: Colors.red,
//       //             label: Row(
//       //               mainAxisSize: MainAxisSize.min,
//       //               children: [
//       //                 Text(
//       //                   timeSince,
//       //                   style: const TextStyle(
//       //                     fontSize: 14,
//       //                     color: Colors.white,
//       //                     fontWeight: FontWeight.bold,
//       //                   ),
//       //                 ),
//       //                 const SizedBox(width: 8),
//       //                 const Icon(Icons.pause, color: Colors.white),
//       //               ],
//       //             ),
//       //           );
//       //         },
//       //       )
//       //     : FloatingActionButton(
//       //         onPressed: () async {
//       //           final loginResponse = await HttpService.getCurrentLoginStatus();
//       //           isLoggedIn = loginResponse != null &&
//       //               loginResponse.status == true &&
//       //               loginResponse.data == true;
//       //           if (!mounted) return;
//       //           if (isLoggedIn == true) {
//       //             final workStatusModel = await HttpService.getWorkStatus();
//       //             workStatus.WorkStatus? newExistingWork;

//       //             if (workStatusModel != null &&
//       //                 workStatusModel.data.isNotEmpty) {
//       //               newExistingWork = workStatusModel.data.first;
//       //             }

//       //             Navigator.push(
//       //               context,
//       //               MaterialPageRoute(
//       //                 builder: (context) => AddWorkPage(
//       //                   workId: "",
//       //                   existingWork: newExistingWork,
//       //                   onSuccess: () {
//       //                     setState(() {
//       //                       getWorkDuration(currentDate);
//       //                       checkExistingWorkStatus();
//       //                     });
//       //                   },
//       //                 ),
//       //               ),
//       //             );
//       //           } else {
//       //             showDialog(
//       //               context: context,
//       //               builder: (BuildContext context) {
//       //                 return AlertDialog(
//       //                   title: const Text('Login Required'),
//       //                   content: const Text('Please login to add work.'),
//       //                   actions: [
//       //                     TextButton(
//       //                       child: const Text('OK'),
//       //                       onPressed: () {
//       //                         Navigator.of(context).pop();
//       //                       },
//       //                     ),
//       //                   ],
//       //                 );
//       //               },
//       //             );
//       //           }
//       //         },
//       //         backgroundColor: Colors.green,
//       //         child: const Icon(Icons.add, color: Colors.white),
//       //       ),
//       floatingActionButton: existingWork == null
//           ? FloatingActionButton(
//               onPressed: () async {
//                 final loginResponse = await HttpService.getCurrentLoginStatus();
//                 isLoggedIn = loginResponse != null &&
//                     loginResponse.status == true &&
//                     loginResponse.data == true;
//                 if (!mounted) return;

//                 if (isLoggedIn == true) {
//                   final workStatusModel = await HttpService.getWorkStatus();
//                   workStatus.WorkStatus? newExistingWork;
//                   if (workStatusModel != null &&
//                       workStatusModel.data.isNotEmpty) {
//                     newExistingWork = workStatusModel.data.first;
//                   }

//                   if (!mounted) return;
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => AddWorkPage(
//                         workId: "",
//                         existingWork: newExistingWork,
//                         onSuccess: () {
//                           setState(() {
//                             getWorkDuration(currentDate);
//                             checkExistingWorkStatus();
//                           });
//                         },
//                       ),
//                     ),
//                   );
//                 } else {
//                   showDialog(
//                     context: context,
//                     builder: (BuildContext context) {
//                       return AlertDialog(
//                         title: const Text('Login Required'),
//                         content: const Text('Please login to add work.'),
//                         actions: [
//                           TextButton(
//                             child: const Text('OK'),
//                             onPressed: () => Navigator.of(context).pop(),
//                           ),
//                         ],
//                       );
//                     },
//                   );
//                 }
//               },
//               backgroundColor: Colors.green,
//               child: const Icon(Icons.add, color: Colors.white),
//             )
//           : null,

//       body: WorkTimerOverlay(
//         onTimerReturn: () {
//           getWorkDuration(currentDate);
//           checkExistingWorkStatus();
//         },
//         child: isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: TextField(
//                       controller: searchController,
//                       decoration: InputDecoration(
//                         hintText: 'Search by name',
//                         prefixIcon: const Icon(Icons.search),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                       child: RefreshIndicator(
//                     onRefresh: () async {
//                       await getWorkDuration(currentDate);
//                       await checkExistingWorkStatus();
//                     },
//                     child: filteredList.isEmpty
//                         ? ListView(
//                             children: const [
//                               SizedBox(height: 200),
//                               Center(child: Text("No work data available")),
//                             ],
//                           )
//                         : ListView.builder(
//                             padding: const EdgeInsets.symmetric(horizontal: 16),
//                             itemCount: filteredList.length,
//                             itemBuilder: (context, index) {
//                               final staff = filteredList[index];
//                               return GestureDetector(
//                                 onTap: () {
//                                   if (staff.multiple == "true") {
//                                     showDialog(
//                                       context: context,
//                                       builder: (context) {
//                                         return AlertDialog(
//                                           title: const Text("Phone Call Log"),
//                                           content: const Text(
//                                               "Choose an action below"),
//                                           actions: [
//                                             TextButton(
//                                               onPressed: () {
//                                                 Navigator.pop(context);
//                                                 Navigator.push(
//                                                   context,
//                                                   MaterialPageRoute(
//                                                     builder: (_) =>
//                                                         ViewWorkPage(
//                                                       staffName: staff.name,
//                                                       staffId: staff.staffId,
//                                                       selectedDate:
//                                                           selectedDate,
//                                                     ),
//                                                   ),
//                                                 );
//                                               },
//                                               child: const Text("Works"),
//                                             ),
//                                             TextButton(
//                                               onPressed: () {
//                                                 Navigator.pop(context);
//                                                 Navigator.push(
//                                                   context,
//                                                   MaterialPageRoute(
//                                                     builder: (_) =>
//                                                         const TimelinePage(),
//                                                     settings: RouteSettings(
//                                                       arguments: {
//                                                         "staffId":
//                                                             staff.staffId,
//                                                         "selectedDate":
//                                                             selectedDate,
//                                                       },
//                                                     ),
//                                                   ),
//                                                 );
//                                               },
//                                               child: const Text("Call Log"),
//                                             ),
//                                           ],
//                                         );
//                                       },
//                                     );
//                                   } else if (staff.taskName == "") {
//                                     // Navigator.push(
//                                     //   context,
//                                     //   MaterialPageRoute(
//                                     //     builder: (_) => ViewWorkPage(
//                                     //       staffName: staff.name,
//                                     //       staffId: staff.staffId,
//                                     //       selectedDate: selectedDate,
//                                     //     ),
//                                     //   ),
//                                     // );
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (_) => const TimelinePage(),
//                                         settings: RouteSettings(
//                                           arguments: {
//                                             "staffId": staff.staffId,
//                                             "selectedDate": selectedDate,
//                                           },
//                                         ),
//                                       ),
//                                     );
//                                   } else {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (_) => ViewWorkPage(
//                                           staffName: staff.name,
//                                           staffId: staff.staffId,
//                                           selectedDate: selectedDate,
//                                         ),
//                                       ),
//                                     );
//                                     // Navigator.push(
//                                     //   context,
//                                     //   MaterialPageRoute(
//                                     //     builder: (_) => const TimelinePage(),
//                                     //     settings: RouteSettings(
//                                     //       arguments: {
//                                     //         "staffId": staff.staffId,
//                                     //         "selectedDate": selectedDate,
//                                     //       },
//                                     //     ),
//                                     //   ),
//                                     // );
//                                   }
//                                 },
//                                 // child: Container(
//                                 //   margin: const EdgeInsets.only(bottom: 12),
//                                 //   padding: const EdgeInsets.all(16),
//                                 //   decoration: BoxDecoration(
//                                 //     color: Colors.white,
//                                 //     borderRadius: BorderRadius.circular(12),
//                                 //     boxShadow: [
//                                 //       BoxShadow(
//                                 //         color: Colors.black12,
//                                 //         blurRadius: 4,
//                                 //         offset: const Offset(0, 2),
//                                 //       ),
//                                 //     ],
//                                 //   ),
//                                 //   child: Row(
//                                 //     crossAxisAlignment: CrossAxisAlignment.start,
//                                 //     children: [
//                                 //       CircleAvatar(
//                                 //         radius: 22,
//                                 //         backgroundColor: Colors.blue,
//                                 //         child: Text(
//                                 //           staff.name.isNotEmpty
//                                 //               ? staff.name[0].toUpperCase()
//                                 //               : "?",
//                                 //           style: const TextStyle(
//                                 //               color: Colors.white,
//                                 //               fontWeight: FontWeight.bold),
//                                 //         ),
//                                 //       ),
//                                 //       const SizedBox(width: 12),
//                                 //       Expanded(
//                                 //         child: Column(
//                                 //           crossAxisAlignment:
//                                 //               CrossAxisAlignment.start,
//                                 //           children: [
//                                 //             Row(
//                                 //               children: [
//                                 //                 Text(
//                                 //                   staff.name,
//                                 //                   style: const TextStyle(
//                                 //                     fontSize: 18,
//                                 //                     fontWeight: FontWeight.w600,
//                                 //                     color: Colors.black87,
//                                 //                   ),
//                                 //                 ),
//                                 //                 const SizedBox(width: 8),
//                                 //                 // Text(
//                                 //                 //   staff.status.toLowerCase() ==
//                                 //                 //           "started"
//                                 //                 //       ? "(Online)"
//                                 //                 //       : staff.status
//                                 //                 //                   .toLowerCase() ==
//                                 //                 //               "ended"
//                                 //                 //           ? "(Offline)"
//                                 //                 //           : "(Not Started)",
//                                 //                 //   style: TextStyle(
//                                 //                 //     color: staff.status
//                                 //                 //                 .toLowerCase() ==
//                                 //                 //             "started"
//                                 //                 //         ? Colors.green
//                                 //                 //         : staff.status
//                                 //                 //                     .toLowerCase() ==
//                                 //                 //                 "ended"
//                                 //                 //             ? Colors.red
//                                 //                 //             : Colors.grey,
//                                 //                 //     fontWeight: FontWeight.w500,
//                                 //                 //     fontSize: 14,
//                                 //                 //   ),
//                                 //                 // ),
//                                 //                 Positioned(
//                                 //                   top: 8,
//                                 //                   right: 25,
//                                 //                   child: Container(
//                                 //                     width: 12,
//                                 //                     height: 12,
//                                 //                     decoration: BoxDecoration(
//                                 //                       color: staff.status
//                                 //                                   .toLowerCase() ==
//                                 //                               "started"
//                                 //                           ? Colors.green
//                                 //                           : staff.status
//                                 //                                       .toLowerCase() ==
//                                 //                                   "ended"
//                                 //                               ? Colors.red
//                                 //                               : Colors.grey,
//                                 //                       shape: BoxShape.circle,
//                                 //                     ),
//                                 //                   ),
//                                 //                 ),
//                                 //               ],
//                                 //             ),
//                                 //             const SizedBox(height: 8),
//                                 //             Row(
//                                 //               children: [
//                                 //                 const Icon(Icons.play_arrow,
//                                 //                     size: 16,
//                                 //                     color: Colors.green),
//                                 //                 const SizedBox(width: 4),
//                                 //                 Text(
//                                 //                   "Login Time: ${_formatTime(staff.firstLoginTime)}",
//                                 //                   style: const TextStyle(
//                                 //                       fontSize: 14),
//                                 //                 ),
//                                 //               ],
//                                 //             ),
//                                 //             const SizedBox(height: 4),
//                                 //             Row(
//                                 //               children: [
//                                 //                 const Icon(Icons.stop,
//                                 //                     size: 16, color: Colors.red),
//                                 //                 const SizedBox(width: 4),
//                                 //                 Text(
//                                 //                   "Logout Time: ${_formatTime(staff.lastLogoutTime)}",
//                                 //                   style: const TextStyle(
//                                 //                       fontSize: 14),
//                                 //                 ),
//                                 //               ],
//                                 //             ),
//                                 //           ],
//                                 //         ),
//                                 //       ),
//                                 //     ],
//                                 //   ),
//                                 // ),
//                                 child: Stack(
//                                   children: [
//                                     Container(
//                                       margin: const EdgeInsets.only(bottom: 12),
//                                       padding: const EdgeInsets.all(16),
//                                       decoration: BoxDecoration(
//                                         color: Colors.white,
//                                         borderRadius: BorderRadius.circular(12),
//                                         boxShadow: const [
//                                           BoxShadow(
//                                             color: Colors.black12,
//                                             blurRadius: 4,
//                                             offset: Offset(0, 2),
//                                           ),
//                                         ],
//                                       ),
//                                       child: Row(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           CircleAvatar(
//                                             radius: 22,
//                                             backgroundColor: Colors.blue,
//                                             child: Text(
//                                               staff.name.isNotEmpty
//                                                   ? staff.name[0].toUpperCase()
//                                                   : "?",
//                                               style: const TextStyle(
//                                                 color: Colors.white,
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                             ),
//                                           ),
//                                           const SizedBox(width: 12),
//                                           Expanded(
//                                             child: Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 Text(
//                                                   staff.name,
//                                                   style: const TextStyle(
//                                                     fontSize: 18,
//                                                     fontWeight: FontWeight.w600,
//                                                     color: Colors.black87,
//                                                   ),
//                                                 ),
//                                                 const SizedBox(height: 8),
//                                                 Row(
//                                                   children: [
//                                                     const Icon(Icons.play_arrow,
//                                                         size: 16,
//                                                         color: Colors.green),
//                                                     const SizedBox(width: 4),
//                                                     Text(
//                                                       "Login Time: ${_formatTime(staff.firstLoginTime)}",
//                                                       style: const TextStyle(
//                                                           fontSize: 14),
//                                                     ),
//                                                   ],
//                                                 ),
//                                                 const SizedBox(height: 4),
//                                                 Row(
//                                                   children: [
//                                                     const Icon(Icons.stop,
//                                                         size: 16,
//                                                         color: Colors.red),
//                                                     const SizedBox(width: 4),
//                                                     Text(
//                                                       "Logout Time: ${_formatTime(staff.lastLogoutTime)}",
//                                                       style: const TextStyle(
//                                                           fontSize: 14),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     Positioned(
//                                       top: 8,
//                                       right: 8,
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.end,
//                                         children: [
//                                           Container(
//                                             width: 16,
//                                             height: 16,
//                                             decoration: BoxDecoration(
//                                               color: staff.status
//                                                           .toLowerCase() ==
//                                                       "started"
//                                                   ? Colors.green
//                                                   : staff.status
//                                                               .toLowerCase() ==
//                                                           "ended"
//                                                       ? const Color.fromARGB(
//                                                           255, 241, 160, 67)
//                                                       : const Color.fromARGB(
//                                                           255, 247, 2, 2),
//                                               shape: BoxShape.circle,
//                                             ),
//                                           ),
//                                           viewAttendance == "true"
//                                               ? const SizedBox(height: 40)
//                                               : SizedBox(),
//                                           viewAttendance == "true"
//                                               ? Transform.translate(
//                                                   offset: const Offset(12, 0),
//                                                   child: IconButton(
//                                                     icon: const Icon(
//                                                         Icons.calendar_month,
//                                                         size: 24,
//                                                         color: Colors.teal),
//                                                     tooltip: 'View Calendar',
//                                                     onPressed: () {
//                                                       Navigator.push(
//                                                         context,
//                                                         MaterialPageRoute(
//                                                           builder: (context) =>
//                                                               StaffCalendarPage(
//                                                                   staffId: staff
//                                                                       .staffId,
//                                                                   selectedDate:
//                                                                       selectedDate,
//                                                                   staffName:
//                                                                       staff
//                                                                           .name),
//                                                         ),
//                                                       );
//                                                     },
//                                                   ),
//                                                 )
//                                               : SizedBox(),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             },
//                           ),
//                   )),
//                 ],
//               ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/core/app_colors.dart';
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
import 'package:login2/widgets/work_timer_overlay.dart';
import 'package:login2/widgets/work_timer_chip.dart';

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

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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
    WorkTimerChip.refreshAll();
  }

  Future<void> loginorNot() async {
    // final token = await Common.getSharedPref("token");
    // final response = await HttpService.getLoginorNot(token);
    final response = await HttpService.getCurrentLoginStatus();

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

  // ------------------------------------------------------------------
  // UI helpers (presentation only)
  // ------------------------------------------------------------------

  /// Same date-picker logic as before, shared by the app-bar icon and
  /// the date chip.
  void _pickDate() {
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
        String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
        getWorkDuration(formattedDate);
      }
    });
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case "started":
        return AppColors.present;
      case "ended":
        return AppColors.pending;
      default:
        return AppColors.danger;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case "started":
        return "Started";
      case "ended":
        return "Ended";
      default:
        return "Not started";
    }
  }

  PopupMenuItem<String> _menuItem(String value, IconData icon, String label) {
    return PopupMenuItem<String>(
      value: value,
      height: 44,
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textDark,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: TextField(
        controller: searchController,
        style: const TextStyle(fontSize: 14, color: AppColors.textDark),
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: 'Search by name',
          hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded,
              size: 20, color: AppColors.textGrey),
          suffixIcon: searchController.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close_rounded,
                      size: 18, color: AppColors.textGrey),
                  onPressed: () => searchController.clear(),
                ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildDateRow(int count) {
    final isToday =
        DateFormat('yyyy-MM-dd').format(selectedDate) == currentDate;
    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.tint(AppColors.primary, 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.event_rounded,
                    size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  isToday
                      ? "Today, ${DateFormat('dd MMM').format(selectedDate)}"
                      : DateFormat('EEE, dd MMM yyyy').format(selectedDate),
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.keyboard_arrow_down_rounded,
                    size: 16, color: AppColors.primary),
              ],
            ),
          ),
        ),
        const Spacer(),
        Text(
          "$count staff",
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textGrey,
          ),
        ),
      ],
    );
  }

  Widget _timeBox({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: AppColors.tint(color),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffCard({
    required String name,
    required String status,
    required String? loginTime,
    required String? logoutTime,
    required VoidCallback onTap,
    VoidCallback? onCalendarTap,
  }) {
    final statusColor = _statusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: (loginTime == null || loginTime.isEmpty)
            ? AppColors.tint(AppColors.danger, 0.20)
            : AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
            child: Column(
              children: [
                // Header: avatar, name, status pill, calendar
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.tint(AppColors.primary, 0.12),
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : "?",
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                _statusLabel(status),
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (onCalendarTap != null)
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        constraints:
                            const BoxConstraints(minWidth: 36, minHeight: 36),
                        padding: EdgeInsets.zero,
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.tint(AppColors.primary, 0.10),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.calendar_month_rounded,
                              size: 18, color: AppColors.primary),
                        ),
                        tooltip: 'View Calendar',
                        onPressed: onCalendarTap,
                      )
                    else
                      const Icon(Icons.chevron_right_rounded,
                          size: 20, color: AppColors.textLight),
                  ],
                ),
                const SizedBox(height: 10),

                // Times
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.softGrey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      _timeBox(
                        icon: Icons.login_rounded,
                        color: AppColors.present,
                        label: "Login",
                        value: _formatTime(loginTime),
                      ),
                      Container(
                        width: 1,
                        height: 26,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        color: AppColors.borderStrong,
                      ),
                      _timeBox(
                        icon: Icons.logout_rounded,
                        color: AppColors.danger,
                        label: "Logout",
                        value: _formatTime(logoutTime),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.skeletonBase,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            itemCount: 6,
            itemBuilder: (_, __) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              height: 104,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                          radius: 18, backgroundColor: AppColors.skeletonBase),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 12,
                            width: 130,
                            decoration: BoxDecoration(
                              color: AppColors.skeletonBase,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 9,
                            width: 70,
                            decoration: BoxDecoration(
                              color: AppColors.skeletonHighlight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.skeletonHighlight,
                        borderRadius: BorderRadius.circular(10),
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
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        Icon(Icons.work_off_outlined,
            size: 56, color: AppColors.tint(AppColors.primary, 0.35)),
        const SizedBox(height: 12),
        const Center(
          child: Text(
            "No work data available",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textMedium,
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Center(
          child: Text(
            "Pull down to refresh or pick another date",
            style: TextStyle(fontSize: 12.5, color: AppColors.textGrey),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = workStatusDetails?.data
            .where((staff) => staff.name.toLowerCase().contains(searchText))
            .toList() ??
        [];

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textOnColor,
        iconTheme: const IconThemeData(color: AppColors.textOnColor),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.appBarGradient),
        ),
        title: const Text(
          "View All Works",
          style: TextStyle(
            color: AppColors.textOnColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.calendar_month_sharp),
                onPressed: _pickDate,
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
                color: AppColors.card,
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
                  _menuItem(
                      'summary', Icons.bar_chart_rounded, 'Total Work Summary'),
                  _menuItem('add_project', Icons.create_new_folder_outlined,
                      'Add Project'),
                  _menuItem('pending_works', Icons.pending_actions_rounded,
                      'Pending Works'),
                  _menuItem('assign_works', Icons.assignment_ind_outlined,
                      'Assign Works'),
                  _menuItem('assign_report', Icons.description_outlined,
                      'Assigned Report'),
                ],
              ),
            ],
          ),
        ],
      ),
      // floatingActionButton: existingWork != null
      //     ? StreamBuilder<DateTime>(
      //         stream: Stream.periodic(
      //             const Duration(seconds: 1), (_) => DateTime.now()),
      //         builder: (context, snapshot) {
      //           if (!snapshot.hasData) return const SizedBox();

      //           final now = snapshot.data!;
      //           final createdAt = DateTime.parse(existingWork!.createdAt);
      //           final diff = now.difference(createdAt);
      //           String timeSince =
      //               "${diff.inHours.toString().padLeft(2, '0')}:${(diff.inMinutes % 60).toString().padLeft(2, '0')}:${(diff.inSeconds % 60).toString().padLeft(2, '0')}";

      //           return FloatingActionButton.extended(
      //             onPressed: () async {
      //               final workStatusModel = await HttpService.getWorkStatus();
      //               workStatus.WorkStatus? newExistingWork;

      //               if (workStatusModel != null &&
      //                   workStatusModel.data.isNotEmpty) {
      //                 newExistingWork = workStatusModel.data.first;
      //               }

      //               final paused = await showDialog(
      //                 context: context,
      //                 builder: (context) => AddWorkPage(
      //                   workId: "",
      //                   existingWork: newExistingWork,
      //                   isAssigned: 1,
      //                   onSuccess: () {
      //                     setState(() {
      //                       getWorkDuration(currentDate);
      //                       checkExistingWorkStatus();
      //                     });
      //                   },
      //                 ),
      //               );

      //               if (paused == true) {
      //                 setState(() {
      //                   existingWork = null;
      //                 });
      //                 getWorkDuration(currentDate);
      //               }
      //             },
      //             backgroundColor: Colors.red,
      //             label: Row(
      //               mainAxisSize: MainAxisSize.min,
      //               children: [
      //                 Text(
      //                   timeSince,
      //                   style: const TextStyle(
      //                     fontSize: 14,
      //                     color: Colors.white,
      //                     fontWeight: FontWeight.bold,
      //                   ),
      //                 ),
      //                 const SizedBox(width: 8),
      //                 const Icon(Icons.pause, color: Colors.white),
      //               ],
      //             ),
      //           );
      //         },
      //       )
      //     : FloatingActionButton(
      //         onPressed: () async {
      //           final loginResponse = await HttpService.getCurrentLoginStatus();
      //           isLoggedIn = loginResponse != null &&
      //               loginResponse.status == true &&
      //               loginResponse.data == true;
      //           if (!mounted) return;
      //           if (isLoggedIn == true) {
      //             final workStatusModel = await HttpService.getWorkStatus();
      //             workStatus.WorkStatus? newExistingWork;

      //             if (workStatusModel != null &&
      //                 workStatusModel.data.isNotEmpty) {
      //               newExistingWork = workStatusModel.data.first;
      //             }

      //             Navigator.push(
      //               context,
      //               MaterialPageRoute(
      //                 builder: (context) => AddWorkPage(
      //                   workId: "",
      //                   existingWork: newExistingWork,
      //                   onSuccess: () {
      //                     setState(() {
      //                       getWorkDuration(currentDate);
      //                       checkExistingWorkStatus();
      //                     });
      //                   },
      //                 ),
      //               ),
      //             );
      //           } else {
      //             showDialog(
      //               context: context,
      //               builder: (BuildContext context) {
      //                 return AlertDialog(
      //                   title: const Text('Login Required'),
      //                   content: const Text('Please login to add work.'),
      //                   actions: [
      //                     TextButton(
      //                       child: const Text('OK'),
      //                       onPressed: () {
      //                         Navigator.of(context).pop();
      //                       },
      //                     ),
      //                   ],
      //                 );
      //               },
      //             );
      //           }
      //         },
      //         backgroundColor: Colors.green,
      //         child: const Icon(Icons.add, color: Colors.white),
      //       ),
      floatingActionButton: existingWork == null
          ? FloatingActionButton(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onPressed: () async {
                final loginResponse = await HttpService.getCurrentLoginStatus();
                isLoggedIn = loginResponse != null &&
                    loginResponse.status == true &&
                    loginResponse.data == true;
                if (!mounted) return;

                if (isLoggedIn == true) {
                  final workStatusModel = await HttpService.getWorkStatus();
                  workStatus.WorkStatus? newExistingWork;
                  if (workStatusModel != null &&
                      workStatusModel.data.isNotEmpty) {
                    newExistingWork = workStatusModel.data.first;
                  }

                  if (!mounted) return;
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
                        backgroundColor: AppColors.card,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: const Text(
                          'Login Required',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        content: const Text(
                          'Please login to add work.',
                          style: TextStyle(color: AppColors.textMedium),
                        ),
                        actions: [
                          TextButton(
                            style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary),
                            child: const Text('OK'),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add_rounded,
                  color: AppColors.textOnColor, size: 28),
            )
          : null,

      body: WorkTimerOverlay(
        onTimerReturn: () {
          getWorkDuration(currentDate);
          checkExistingWorkStatus();
        },
        child: isLoading
            ? _buildSkeleton()
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                    child: Column(
                      children: [
                        _buildSearchField(),
                        const SizedBox(height: 8),
                        _buildDateRow(filteredList.length),
                      ],
                    ),
                  ),
                  Expanded(
                      child: RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async {
                      await getWorkDuration(currentDate);
                      await checkExistingWorkStatus();
                    },
                    child: filteredList.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
                            itemCount: filteredList.length,
                            itemBuilder: (context, index) {
                              final staff = filteredList[index];
                              // ---- old card design (kept for reference) ----
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
                              return _buildStaffCard(
                                name: staff.name,
                                status: staff.status,
                                loginTime: staff.firstLoginTime,
                                logoutTime: staff.lastLogoutTime,
                                onCalendarTap: viewAttendance == "true"
                                    ? () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                StaffCalendarPage(
                                                    staffId: staff.staffId,
                                                    selectedDate: selectedDate,
                                                    staffName: staff.name),
                                          ),
                                        );
                                      }
                                    : null,
                                onTap: () {
                                  if (staff.multiple == "true") {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          backgroundColor: AppColors.card,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          title: const Text(
                                            "Phone Call Log",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textDark,
                                            ),
                                          ),
                                          content: const Text(
                                            "Choose an action below",
                                            style: TextStyle(
                                                color: AppColors.textMedium),
                                          ),
                                          actions: [
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                  foregroundColor:
                                                      AppColors.primary),
                                              onPressed: () {
                                                Navigator.pop(context);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        ViewWorkPage(
                                                      staffName: staff.name,
                                                      staffId: staff.staffId,
                                                      selectedDate:
                                                          selectedDate,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: const Text("Works"),
                                            ),
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                  foregroundColor:
                                                      AppColors.primary),
                                              onPressed: () {
                                                Navigator.pop(context);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        const TimelinePage(),
                                                    settings: RouteSettings(
                                                      arguments: {
                                                        "staffId":
                                                            staff.staffId,
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
                              );
                            },
                          ),
                  )),
                ],
              ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:login2/core/common.dart';
// import 'package:login2/core/app_colors.dart';
// import 'package:login2/models/expense/expense_post.dart';
// import 'package:login2/screens/leadManagement/AssignReport.dart';
// import 'package:login2/screens/leadManagement/addWork_page.dart';
// import 'package:login2/screens/leadManagement/login_summary_page.dart';
// import 'package:login2/widgets/blinkngTime.dart';
// import 'package:login2/widgets/work_timer_overlay.dart';
// import 'package:login2/widgets/work_timer_chip.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../../models/lead_management/workDetailsModel.dart' as workDetails;
// import 'package:login2/models/lead_management/workstatus_model.dart'
//     as workStatus;
// import '../../service/service.dart';

// class ViewWorkPage extends StatefulWidget {
//   final String? staffName;
//   final String staffId;
//   final DateTime? selectedDate;
//   const ViewWorkPage(
//       {super.key, this.selectedDate, required this.staffId, this.staffName});

//   @override
//   State<ViewWorkPage> createState() => _ViewWorkPageState();
// }

// class _ViewWorkPageState extends State<ViewWorkPage> {
//   late String currentDate;
//   workDetails.WorkDetailsModel? workStatusDetails;
//   workStatus.WorkStatus? existingWork;
//   bool isLoading = true;
//   bool _isPanelOpen = false;
//   final double _panelWidth = 200.0;
//   double _panelPosition = -200.0;
//   String token = "";
//   //workDetails.Data? currentRunningItem;
//   late DateTime selectedDate;
//   CommonResponse? loginOrNot;
//   bool? isLoggedIn;
//   String? userId;
//   String? addWorkPermission;
//   String? _resolvedStaffName;
//   // @override
//   // void initState() {
//   //   super.initState();
//   //   // currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
//   //   selectedDate = widget.selectedDate ?? DateTime.now();
//   //   currentDate =
//   //       DateFormat('yyyy-MM-dd').format(widget.selectedDate ?? DateTime.now());

//   //   print("Selected date passed to ViewWorkPage: ${widget.selectedDate}");
//   //   WidgetsBinding.instance.addPostFrameCallback((_) {
//   //     getWorkDuration(currentDate);
//   //     checkExistingWorkStatus();
//   //   });
//   //   loadToken();
//   // }
//   // @override
//   // void initState() {
//   //   super.initState();
//   //   selectedDate = widget.selectedDate ?? DateTime.now();
//   //   currentDate = DateFormat('yyyy-MM-dd').format(selectedDate);
//   //    final userId =  Common.getSharedPref("userId");
//   //   print("Selected date passed to ViewWorkPage: ${widget.selectedDate}");
//   //   WidgetsBinding.instance.addPostFrameCallback((_) {
//   //     getWorkDuration(currentDate);
//   //     checkExistingWorkStatus();
//   //   });
//   //   loadToken();
//   //   loginorNot();
//   //    getStaffid();
//   // }
//   @override
//   void initState() {
//     super.initState();
//     selectedDate = widget.selectedDate ?? DateTime.now();
//     currentDate = DateFormat('yyyy-MM-dd').format(selectedDate);
//     print("Selected date passed to ViewWorkPage: ${widget.selectedDate}");
//     _resolvedStaffName =
//         (widget.staffName != null && widget.staffName!.isNotEmpty)
//             ? widget.staffName
//             : null;
//     _initData();
//     _loadStaffName();
//   }

//   Future<void> _loadStaffName() async {
//     if (widget.staffName != null && widget.staffName!.isNotEmpty) {
//       _resolvedStaffName = widget.staffName;
//       return;
//     }
//     final response = await HttpService.getStaffs();
//     if (!mounted) return;
//     if (response != null && response.data.isNotEmpty) {
//       for (final staff in response.data) {
//         if (staff.userIdStaff == widget.staffId) {
//           if (!mounted) return;
//           setState(() {
//             _resolvedStaffName = staff.name;
//           });
//           break;
//         }
//       }
//     }
//   }

//   Future<void> _initData() async {
//     userId = await Common.getSharedPref("userId");
//     addWorkPermission = await Common.getSharedPref("addWorkPermission");
//     print("userId:$userId");
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       getWorkDuration(currentDate);
//       checkExistingWorkStatus();
//     });
//     await loadToken();
//     await loginorNot();
//   }

//   Future<void> loadToken() async {
//     token = await Common.getSharedPref("token");
//     if (!mounted) return;
//     setState(() {});
//   }

//   Future<void> checkExistingWorkStatus() async {
//     final workStatusModel = await HttpService.getWorkStatus();
//     if (!mounted) return;
//     setState(() {
//       if (workStatusModel != null && workStatusModel.data.isNotEmpty) {
//         existingWork = workStatusModel.data.first;
//       } else {
//         existingWork = null;
//       }
//     });
//      WorkTimerChip.refreshAll();
//   }

//   String formatDueDate(String? dueDate) {
//     if (dueDate == null || dueDate.isEmpty) return '';
//     try {
//       DateTime? parsedDate;
//       final formats = [
//         DateFormat('dd-MM-yyyy hh:mm a'),
//         DateFormat('dd-MM-yyyy HH:mm:ss'),
//         DateFormat('dd-MM-yyyy HH:mm'),
//         DateFormat('yyyy-MM-dd HH:mm:ss'),
//         DateFormat('yyyy-MM-dd HH:mm'),
//         DateFormat('dd-MM-yyyy'),
//         DateFormat('yyyy-MM-dd'),
//       ];
//       for (var f in formats) {
//         try {
//           parsedDate = f.parse(dueDate.trim());
//           break;
//         } catch (_) {}
//       }
//       parsedDate ??= DateTime.tryParse(dueDate.trim());
//       if (parsedDate != null) {
//         if (parsedDate.hour != 0 || parsedDate.minute != 0) {
//           return DateFormat('dd-MM-yyyy hh:mm a').format(parsedDate);
//         }
//         return DateFormat('dd-MM-yyyy').format(parsedDate);
//       }
//       return dueDate;
//     } catch (e) {
//       return dueDate;
//     }
//   }

//   Future<void> loginorNot() async {
//     // final token = await Common.getSharedPref("token");
//     // final response = await HttpService.getLoginorNot(token);
//     final response = await HttpService.getCurrentLoginStatus();
//     if (!mounted) return;
//     setState(() {
//       if (response != null && response.data == true) {
//         isLoggedIn = true;
//       } else {
//         isLoggedIn = false;
//       }
//     });
//   }

//   void _launchMap(String? latitude, String? longitude) async {
//     final url =
//         'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
//     final uri = Uri.parse(url);

//     try {
//       final launched =
//           await launchUrl(uri, mode: LaunchMode.externalApplication);
//       if (!launched) {
//         debugPrint('Could not launch URL: $url');
//       }
//     } catch (e) {
//       debugPrint('Exception when launching URL: $e');
//     }
//   }

//   Future<void> getWorkDuration(String date) async {
//     final response =
//         await HttpService.getWorkStatusDetails(date, staffId: widget.staffId);
//     if (!mounted) return;
//     setState(() {
//       workStatusDetails = response;
//       isLoading = false;
//     });
//   }

//   String getDurationSinceLogin(String? loginTimeString) {
//     if (loginTimeString == null || loginTimeString.isEmpty) return "--";
//     try {
//       final loginTime = DateTime.parse(loginTimeString);
//       final now = DateTime.now();
//       final duration = now.difference(loginTime);
//       final hours = duration.inHours;
//       final minutes = duration.inMinutes % 60;
//       if (hours == 0 && minutes == 0) return "Just now";
//       if (hours == 0) return "$minutes min ago";
//       return "$hours hr ${minutes.toString().padLeft(2, '0')} min ago";
//     } catch (e) {
//       return "--";
//     }
//   }

//   String _formatDuration(String? duration) {
//     if (duration == null || duration.isEmpty) return "Started";
//     try {
//       if (duration.contains(':')) {
//         final parts = duration.split(':');
//         if (parts.length == 3) {
//           final hours = int.parse(parts[0]);
//           final minutes = int.parse(parts[1]);
//           final seconds = int.parse(parts[2]);
//           if (hours > 0) return "${hours}h ${minutes}m";
//           if (minutes > 0) return "${minutes}m ${seconds}s";
//           return "${seconds}s";
//         }
//       }
//       final seconds = int.tryParse(duration) ?? 0;
//       return "${seconds}s";
//     } catch (e) {
//       return "0s";
//     }
//   }

//   void _togglePanel() {
//     setState(() {
//       _isPanelOpen = !_isPanelOpen;
//       _panelPosition = _isPanelOpen ? 0 : -_panelWidth;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: _resolvedStaffName != null && _resolvedStaffName!.isNotEmpty
//             ? Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   if (_resolvedStaffName != null &&
//                       _resolvedStaffName!.isNotEmpty)
//                     Text(
//                       _resolvedStaffName!,
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                         color: Color.fromARGB(255, 255, 255, 255),
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   const Text(
//                     "Work Timeline",
//                     style: TextStyle(
//                       fontSize: 14,
//                       // fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               )
//             : Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     "Work Timeline",
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//         backgroundColor: Colors
//             .transparent, // changed (was Color.fromARGB(255, 77, 155, 228))
//         foregroundColor: Colors.white,
//         elevation: 0, // optional, removes the shadow under the gradient
//         flexibleSpace: Container(
//           // new
//           decoration: const BoxDecoration(
//             gradient: AppColors.appBarGradient,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.calendar_month),
//             onPressed: () async {
//               final DateTime? picked = await showDatePicker(
//                 context: context,
//                 initialDate: selectedDate,
//                 firstDate: DateTime(2020),
//                 lastDate: DateTime(2100),
//               );
//               if (picked != null && picked != selectedDate) {
//                 if (!mounted) return;
//                 setState(() {
//                   selectedDate = picked;
//                   currentDate = DateFormat('yyyy-MM-dd').format(picked);
//                   isLoading = true;
//                 });
//                 await getWorkDuration(currentDate);
//               }
//             },
//           ),
//         ],
//       ),
//       // floatingActionButton: ((widget.staffId != "")
//       //             ? (userId != null && widget.staffId == userId)
//       //             : (userId != null)) &&
//       //         addWorkPermission == "true"
//       //     ? (existingWork != null
//       //         ? StreamBuilder<DateTime>(
//       //             stream: Stream.periodic(
//       //               const Duration(seconds: 1),
//       //               (_) => DateTime.now(),
//       //             ),
//       //             builder: (context, snapshot) {
//       //               if (!snapshot.hasData) return const SizedBox();
//       //               final now = snapshot.data!;
//       //               final createdAt = DateTime.parse(existingWork!.createdAt);
//       //               final diff = now.difference(createdAt);
//       //               String timeSince =
//       //                   "${diff.inHours.toString().padLeft(2, '0')}:"
//       //                   "${(diff.inMinutes % 60).toString().padLeft(2, '0')}:"
//       //                   "${(diff.inSeconds % 60).toString().padLeft(2, '0')}";
//       //               return FloatingActionButton.extended(
//       //                 onPressed: () async {
//       //                   final workStatusModel =
//       //                       await HttpService.getWorkStatus();
//       //                   workStatus.WorkStatus? newExistingWork;
//       //                   if (workStatusModel != null &&
//       //                       workStatusModel.data.isNotEmpty) {
//       //                     newExistingWork = workStatusModel.data.first;
//       //                   }
//       //                   final paused = await showDialog(
//       //                     context: context,
//       //                     builder: (context) => AddWorkPage(
//       //                       workId: "",
//       //                       existingWork: newExistingWork,
//       //                       isAssigned: 1,
//       //                       onSuccess: () {
//       //                         setState(() {
//       //                           getWorkDuration(currentDate);
//       //                           checkExistingWorkStatus();
//       //                         });
//       //                       },
//       //                     ),
//       //                   );

//       //                   if (paused == true) {
//       //                     setState(() {
//       //                       existingWork = null;
//       //                     });
//       //                     getWorkDuration(currentDate);
//       //                   }
//       //                 },
//       //                 backgroundColor: Colors.red,
//       //                 label: Row(
//       //                   mainAxisSize: MainAxisSize.min,
//       //                   children: [
//       //                     Text(
//       //                       timeSince,
//       //                       style: const TextStyle(
//       //                         fontSize: 14,
//       //                         color: Colors.white,
//       //                         fontWeight: FontWeight.bold,
//       //                       ),
//       //                     ),
//       //                     const SizedBox(width: 8),
//       //                     const Icon(Icons.pause, color: Colors.white),
//       //                   ],
//       //                 ),
//       //               );
//       //             },
//       //           )
//       //         : FloatingActionButton(
//       //             onPressed: () async {
//       //               final loginResponse =
//       //                   await HttpService.getCurrentLoginStatus();
//       //               isLoggedIn = loginResponse != null &&
//       //                   loginResponse.status == true &&
//       //                   loginResponse.data == true;
//       //               if (!mounted) return;
//       //               if (isLoggedIn == true) {
//       //                 final workStatusModel = await HttpService.getWorkStatus();
//       //                 workStatus.WorkStatus? newExistingWork;

//       //                 if (workStatusModel != null &&
//       //                     workStatusModel.data.isNotEmpty) {
//       //                   newExistingWork = workStatusModel.data.first;
//       //                 }
//       //                 Navigator.push(
//       //                   context,
//       //                   MaterialPageRoute(
//       //                     builder: (context) => AddWorkPage(
//       //                       workId: "",
//       //                       existingWork: newExistingWork,
//       //                       onSuccess: () {
//       //                         setState(() {
//       //                           getWorkDuration(currentDate);
//       //                           checkExistingWorkStatus();
//       //                         });
//       //                       },
//       //                     ),
//       //                   ),
//       //                 );
//       //               } else {
//       //                 showDialog(
//       //                   context: context,
//       //                   builder: (BuildContext context) {
//       //                     return AlertDialog(
//       //                       title: const Text('Login Required'),
//       //                       content: const Text('Please login to add work.'),
//       //                       actions: [
//       //                         TextButton(
//       //                           child: const Text('OK'),
//       //                           onPressed: () {
//       //                             Navigator.of(context).pop();
//       //                           },
//       //                         ),
//       //                       ],
//       //                     );
//       //                   },
//       //                 );
//       //               }
//       //             },
//       //             backgroundColor: Colors.green,
//       //             child: const Icon(Icons.add, color: Colors.white),
//       //           ))
//       //     : null,
//       floatingActionButton: ((widget.staffId != "")
//                   ? (userId != null && widget.staffId == userId)
//                   : (userId != null)) &&
//               addWorkPermission == "true" &&
//               existingWork == null
//           ? FloatingActionButton(
//               onPressed: () async {
//                 final loginResponse = await HttpService.getCurrentLoginStatus();
//                 isLoggedIn = loginResponse != null &&
//                     loginResponse.status == true &&
//                     loginResponse.data == true;
//                 if (!mounted) return;
//                 if (isLoggedIn == true) {
//                   final workStatusModel = await HttpService.getWorkStatus();
//                   if (!mounted) return;
//                   workStatus.WorkStatus? newExistingWork;
//                   if (workStatusModel != null &&
//                       workStatusModel.data.isNotEmpty) {
//                     newExistingWork = workStatusModel.data.first;
//                   }
//                   final result = await Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => AddWorkPage(
//                         workId: "",
//                         existingWork: newExistingWork,
//                         popOnSuccess: true,
//                         onSuccess: () {
//                           setState(() {
//                             getWorkDuration(currentDate);
//                             checkExistingWorkStatus();
//                           });
//                         },
//                       ),
//                     ),
//                   );
//                   if (result == true && mounted) {
//                     getWorkDuration(currentDate);
//                     checkExistingWorkStatus();
//                   }
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
//         child: Stack(
//           children: [
//             // _buildMainContent(),
//             GestureDetector(
//               onTap: () {
//                 if (_isPanelOpen) {
//                   _togglePanel();
//                 }
//               },
//               child: AbsorbPointer(
//                 absorbing: _isPanelOpen,
//                 child: _buildMainContent(),
//               ),
//             ),
//             AnimatedPositioned(
//               duration: const Duration(milliseconds: 300),
//               curve: Curves.easeInOut,
//               right: _panelPosition,
//               top: 0,
//               bottom: 0,
//               width: _panelWidth,
//               child: GestureDetector(
//                 onHorizontalDragUpdate: (details) {
//                   if (details.delta.dx < 0) {
//                     // Swiping left
//                     setState(() {
//                       _panelPosition = (_panelPosition - details.delta.dx)
//                           .clamp(-_panelWidth, 0.0);
//                     });
//                   } else if (details.delta.dx > 0) {
//                     // Swiping right
//                     setState(() {
//                       _panelPosition = (_panelPosition - details.delta.dx)
//                           .clamp(-_panelWidth, 0.0);
//                     });
//                   }
//                 },
//                 onHorizontalDragEnd: (details) {
//                   if (details.primaryVelocity! < 0) {
//                     // Swiped left
//                     _togglePanel();
//                   } else if (details.primaryVelocity! > 0) {
//                     // Swiped right
//                     _togglePanel();
//                   } else {
//                     // No significant velocity - snap to nearest state
//                     if (_panelPosition.abs() > _panelWidth / 2) {
//                       _togglePanel();
//                     } else {
//                       _togglePanel();
//                     }
//                   }
//                 },
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.2),
//                         blurRadius: 8,
//                         offset: const Offset(-3, 0),
//                       ),
//                     ],
//                   ),
//                   child: _buildTimeSummaryPanel(),
//                 ),
//               ),
//             ),
//             if (!_isPanelOpen)
//               Positioned(
//                 right: 0,
//                 top: MediaQuery.of(context).size.height / 2 - 50,
//                 child: GestureDetector(
//                   onTap: _togglePanel,
//                   child: Container(
//                     width: 24,
//                     height: 100,
//                     decoration: BoxDecoration(
//                       color: Colors.blue,
//                       borderRadius: const BorderRadius.only(
//                         topLeft: Radius.circular(12),
//                         bottomLeft: Radius.circular(12),
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.2),
//                           blurRadius: 4,
//                           offset: const Offset(-2, 0),
//                         ),
//                       ],
//                     ),
//                     child: const Center(
//                       child: Icon(
//                         Icons.chevron_left,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMainContent() {
//     return Column(
//       children: [
//         Expanded(
//           child: isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : (workStatusDetails == null ||
//                       workStatusDetails!.data.isEmpty ||
//                       workStatusDetails!.data.first.tasks.isEmpty)
//                   ? const Center(child: Text("No work data available"))
//                   : RefreshIndicator(
//                       onRefresh: () async {
//                         setState(() {
//                           isLoading = true;
//                         });
//                         await getWorkDuration(currentDate);
//                         await checkExistingWorkStatus();
//                       },
//                       child: ListView.builder(
//                         padding: const EdgeInsets.symmetric(
//                             vertical: 12, horizontal: 16),
//                         itemCount: workStatusDetails!.data.length,
//                         itemBuilder: (context, index) {
//                           final item = workStatusDetails!.data[index];
//                           final hasAssignment = item.assigns
//                               .any((assign) => assign.assignedBy.isNotEmpty);
//                           List<bool> expandedTasks =
//                               List.generate(item.tasks.length, (index) => true);

//                           final isCurrentSessionRunning = existingWork != null &&
//                               existingWork!.id.isNotEmpty &&
//                               existingWork!.id == item.id;
//                           final hasInProgressTask = item.tasks.any(
//                               (t) => Common.isWorkInProgressStatus(t.status));
//                           final isInProgress = isCurrentSessionRunning ||
//                               hasInProgressTask ||
//                               item.endTime == "00:00:00" ||
//                               item.endTime.isEmpty;
//                           final showDateHeader = index == 0 ||
//                               _getDateFromTime(item.startTime) !=
//                                   _getDateFromTime(workStatusDetails!
//                                       .data[index - 1].startTime);
//                           if (item.title != "") {
//                             return Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 if (showDateHeader)
//                                   Padding(
//                                     padding: const EdgeInsets.only(
//                                         top: 8, bottom: 12),
//                                     child: Row(
//                                       children: [
//                                         Container(
//                                           width: 40,
//                                           height: 40,
//                                           decoration: BoxDecoration(
//                                             color: Colors.blue.shade50,
//                                             shape: BoxShape.circle,
//                                           ),
//                                           child: Center(
//                                             child: Text(
//                                               _getDayFromTime(currentDate),
//                                               style: TextStyle(
//                                                 fontSize: 16,
//                                                 fontWeight: FontWeight.bold,
//                                                 color: Colors.blue.shade800,
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                         const SizedBox(width: 12),
//                                         Text(
//                                           _getMonthYearFromTime(currentDate),
//                                           style: TextStyle(
//                                             fontSize: 16,
//                                             color: Colors.grey.shade700,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 Row(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Column(
//                                       children: [
//                                         Container(
//                                           width: 16,
//                                           height: 16,
//                                           decoration: BoxDecoration(
//                                             color: isInProgress
//                                                 ? Colors.orange
//                                                 : Colors.green,
//                                             shape: BoxShape.circle,
//                                             border: Border.all(
//                                               color: Colors.white,
//                                               width: 2,
//                                             ),
//                                           ),
//                                         ),
//                                         if (index !=
//                                             workStatusDetails!.data.length - 1)
//                                           Container(
//                                             width: 2,
//                                             height: _calculateItemHeight(
//                                                     item.tasks) +
//                                                 210,
//                                             color: Colors.grey.shade300,
//                                           ),
//                                       ],
//                                     ),
//                                     const SizedBox(width: 12),
//                                     Expanded(
//                                       child: Column(
//                                         children: [
//                                           Container(
//                                             margin: const EdgeInsets.only(
//                                                 bottom: 8),
//                                             padding: const EdgeInsets.all(16),
//                                             decoration: BoxDecoration(
//                                               color: hasAssignment
//                                                   ? const Color.fromARGB(
//                                                       255, 255, 249, 220)
//                                                   : Colors.white,
//                                               borderRadius:
//                                                   BorderRadius.circular(12),
//                                               boxShadow: [
//                                                 BoxShadow(
//                                                   color: Colors.black
//                                                       .withOpacity(0.05),
//                                                   blurRadius: 6,
//                                                   offset: const Offset(0, 2),
//                                                 )
//                                               ],
//                                             ),
//                                             child: Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 Row(
//                                                   mainAxisAlignment:
//                                                       MainAxisAlignment
//                                                           .spaceBetween,
//                                                   crossAxisAlignment:
//                                                       CrossAxisAlignment.start,
//                                                   children: [
//                                                     Flexible(
//                                                       child: GestureDetector(
//                                                         onTap: () {
//                                                           Navigator.push(
//                                                             context,
//                                                             MaterialPageRoute(
//                                                               builder: (context) =>
//                                                                   AssignReport(
//                                                                       workId: item
//                                                                           .id,
//                                                                       sectionId:
//                                                                           ""),
//                                                             ),
//                                                           );
//                                                         },
//                                                         child: Text(
//                                                           '${item.customerName ?? "No title"} [${item.projectName}]',
//                                                           style:
//                                                               const TextStyle(
//                                                             fontSize: 16,
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                           ),
//                                                           softWrap: true,
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     const SizedBox(width: 8),
//                                                     (item.totalDuration
//                                                                 .isNotEmpty) &&
//                                                             item.is_paused !=
//                                                                 "0"
//                                                         ? Text(
//                                                             "Worked:${item.totalDuration}",
//                                                             style: TextStyle(
//                                                               fontSize: 14,
//                                                               color: Colors.grey
//                                                                   .shade600,
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold,
//                                                             ),
//                                                             overflow:
//                                                                 TextOverflow
//                                                                     .ellipsis,
//                                                           )
//                                                         : (isInProgress ==
//                                                                     false &&
//                                                                 userId !=
//                                                                     null &&
//                                                                 widget.staffId ==
//                                                                     userId
//                                                             ? GestureDetector(
//                                                                 onTap:
//                                                                     () async {
//                                                                   final loginResponse =
//                                                                       await HttpService
//                                                                           .getCurrentLoginStatus();
//                                                                   if (loginResponse == null ||
//                                                                       loginResponse
//                                                                               .status !=
//                                                                           true ||
//                                                                       loginResponse
//                                                                               .data !=
//                                                                           true) {
//                                                                     if (!mounted)
//                                                                       return;
//                                                                     showDialog(
//                                                                       context:
//                                                                           context,
//                                                                       builder:
//                                                                           (BuildContext
//                                                                               context) {
//                                                                         return AlertDialog(
//                                                                           title:
//                                                                               const Text('Login Required'),
//                                                                           content:
//                                                                               const Text('Please login first.'),
//                                                                           actions: [
//                                                                             TextButton(
//                                                                               child: const Text('OK'),
//                                                                               onPressed: () {
//                                                                                 Navigator.of(context).pop();
//                                                                               },
//                                                                             ),
//                                                                           ],
//                                                                         );
//                                                                       },
//                                                                     );
//                                                                     return;
//                                                                   }
//                                                                   bool isAnyWorkInProgress = existingWork != null ||
//                                                                       workStatusDetails!.data.any((w) {
//                                                                         final isCur = existingWork != null &&
//                                                                             existingWork!.id.isNotEmpty &&
//                                                                             existingWork!.id == w.id;
//                                                                         final hasProg = w.tasks.any((t) =>
//                                                                             Common.isWorkInProgressStatus(t.status));
//                                                                         return isCur ||
//                                                                             hasProg ||
//                                                                             w.endTime == "00:00:00" ||
//                                                                             w.endTime.isEmpty;
//                                                                       });
//                                                                   if (isAnyWorkInProgress) {
//                                                                     Common.toastMessaage(
//                                                                         'Work is in progress. Please stop the work before restarting new work',
//                                                                         Colors
//                                                                             .red);
//                                                                     return;
//                                                                   }
//                                                                   final workStatusModel =
//                                                                       await HttpService
//                                                                           .getWorkStatusPaused(
//                                                                               item.id);
//                                                                   if (!mounted) return;
//                                                                   workStatus
//                                                                       .WorkStatus?
//                                                                       newExistingWork;
//                                                                   if (workStatusModel !=
//                                                                           null &&
//                                                                       workStatusModel
//                                                                           .data
//                                                                           .isNotEmpty) {
//                                                                     newExistingWork =
//                                                                         workStatusModel
//                                                                             .data
//                                                                             .first;
//                                                                   }
//                                                                   final result =
//                                                                       await Navigator
//                                                                           .push(
//                                                                     context,
//                                                                     MaterialPageRoute(
//                                                                       builder:
//                                                                           (context) =>
//                                                                               AddWorkPage(
//                                                                         workId:
//                                                                             item.id,
//                                                                         existingWork:
//                                                                             null,
//                                                                         isPaused:
//                                                                             0,
//                                                                         Restart:
//                                                                             1,
//                                                                         popOnSuccess:
//                                                                             true,
//                                                                         onSuccess:
//                                                                             () {
//                                                                           setState(
//                                                                               () {
//                                                                             checkExistingWorkStatus();
//                                                                           });
//                                                                         },
//                                                                       ),
//                                                                     ),
//                                                                   );
//                                                                   if (result ==
//                                                                           true &&
//                                                                       mounted) {
//                                                                     getWorkDuration(
//                                                                         currentDate);
//                                                                     checkExistingWorkStatus();
//                                                                   }
//                                                                 },
//                                                                 //     () async {
//                                                                 //   await loginorNot();
//                                                                 //   if (isLoggedIn ==
//                                                                 //       true) {
//                                                                 //     bool isAnyWorkInProgress = workStatusDetails!.data.any((w) =>
//                                                                 //         w.endTime ==
//                                                                 //             "00:00:00" ||
//                                                                 //         w.endTime
//                                                                 //             .isEmpty);
//                                                                 //     if (isAnyWorkInProgress) {
//                                                                 //       Common.toastMessaage(
//                                                                 //           'Work is in progress. Please stop the work before restarting new work',
//                                                                 //           Colors
//                                                                 //               .red);
//                                                                 //       return;
//                                                                 //     }
//                                                                 //     final workStatusModel =
//                                                                 //         await HttpService.getWorkStatusPaused(
//                                                                 //             item.id);
//                                                                 //     workStatus
//                                                                 //         .WorkStatus?
//                                                                 //         newExistingWork;
//                                                                 //     if (workStatusModel !=
//                                                                 //             null &&
//                                                                 //         workStatusModel
//                                                                 //             .data
//                                                                 //             .isNotEmpty) {
//                                                                 //       newExistingWork = workStatusModel
//                                                                 //           .data
//                                                                 //           .first;
//                                                                 //     }
//                                                                 //     Navigator
//                                                                 //         .push(
//                                                                 //       context,
//                                                                 //       MaterialPageRoute(
//                                                                 //         builder:
//                                                                 //             (context) =>
//                                                                 //                 AddWorkPage(
//                                                                 //           workId:
//                                                                 //               item.id,
//                                                                 //           existingWork:
//                                                                 //               null,
//                                                                 //           isPaused:
//                                                                 //               0,
//                                                                 //           Restart:
//                                                                 //               1,
//                                                                 //           onSuccess:
//                                                                 //               () {
//                                                                 //             setState(() {
//                                                                 //               checkExistingWorkStatus();
//                                                                 //             });
//                                                                 //           },
//                                                                 //         ),
//                                                                 //       ),
//                                                                 //     );
//                                                                 //   } else {
//                                                                 //     showDialog(
//                                                                 //       context:
//                                                                 //           context,
//                                                                 //       builder:
//                                                                 //           (BuildContext
//                                                                 //               context) {
//                                                                 //         return AlertDialog(
//                                                                 //           title:
//                                                                 //               const Text('Login Required'),
//                                                                 //           content:
//                                                                 //               const Text('Please login to restart work.'),
//                                                                 //           actions: [
//                                                                 //             TextButton(
//                                                                 //               child: const Text('OK'),
//                                                                 //               onPressed: () {
//                                                                 //                 Navigator.of(context).pop();
//                                                                 //               },
//                                                                 //             ),
//                                                                 //           ],
//                                                                 //         );
//                                                                 //       },
//                                                                 //     );
//                                                                 //   }
//                                                                 // },
//                                                                 child:
//                                                                     const Row(
//                                                                   mainAxisSize:
//                                                                       MainAxisSize
//                                                                           .min,
//                                                                   children: [
//                                                                     Icon(
//                                                                       Icons
//                                                                           .restart_alt,
//                                                                       size: 20,
//                                                                       color: Color.fromARGB(
//                                                                           255,
//                                                                           29,
//                                                                           183,
//                                                                           230),
//                                                                     ),
//                                                                     SizedBox(
//                                                                         width:
//                                                                             4),
//                                                                     Text(
//                                                                       "Restart",
//                                                                       style:
//                                                                           TextStyle(
//                                                                         fontSize:
//                                                                             14,
//                                                                         color: Color.fromARGB(
//                                                                             255,
//                                                                             29,
//                                                                             183,
//                                                                             230),
//                                                                         fontWeight:
//                                                                             FontWeight.bold,
//                                                                       ),
//                                                                       overflow:
//                                                                           TextOverflow
//                                                                               .ellipsis,
//                                                                     ),
//                                                                   ],
//                                                                 ),
//                                                               )
//                                                             : Text(
//                                                                 "Running...",
//                                                                 style:
//                                                                     TextStyle(
//                                                                   fontSize: 14,
//                                                                   color: Colors
//                                                                       .grey
//                                                                       .shade600,
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .bold,
//                                                                 ),
//                                                               ))
//                                                   ],
//                                                 ),
//                                                 const SizedBox(height: 8),
//                                                 Text(
//                                                   "Module: ${item.titleName}",
//                                                   style: TextStyle(
//                                                     fontSize: 14,
//                                                     color: Colors.grey.shade700,
//                                                   ),
//                                                 ),
//                                                 const SizedBox(height: 8),
//                                                 Row(
//                                                   children: [
//                                                     Text(
//                                                       "Start: ${item.startTime}",
//                                                       style: TextStyle(
//                                                         fontSize: 13,
//                                                         color: Colors
//                                                             .grey.shade600,
//                                                       ),
//                                                     ),
//                                                     const SizedBox(width: 16),
//                                                     isInProgress
//                                                         ? const Row(
//                                                             children: [
//                                                               Text(""),
//                                                               BlinkingText(
//                                                                 text: "Running",
//                                                                 style:
//                                                                     TextStyle(
//                                                                   fontSize: 13,
//                                                                   color: Color
//                                                                       .fromARGB(
//                                                                           255,
//                                                                           148,
//                                                                           233,
//                                                                           50),
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .bold,
//                                                                 ),
//                                                               ),
//                                                             ],
//                                                           )
//                                                         : Text(
//                                                             "End: ${item.endTime}",
//                                                             style: TextStyle(
//                                                               fontSize: 13,
//                                                               color: Colors.grey
//                                                                   .shade600,
//                                                             ),
//                                                           ),
//                                                   ],
//                                                 ),
//                                                 const SizedBox(height: 8),
//                                                 if (item.latitude.isNotEmpty &&
//                                                     double.tryParse(
//                                                             item.latitude) !=
//                                                         0)
//                                                   Row(
//                                                     children: [
//                                                       GestureDetector(
//                                                         onTap: () => _launchMap(
//                                                             item.latitude,
//                                                             item.longitude),
//                                                         child: const Text(
//                                                           "View Location",
//                                                           style: TextStyle(
//                                                             fontSize: 14,
//                                                             color: Colors.blue,
//                                                             decoration:
//                                                                 TextDecoration
//                                                                     .underline,
//                                                             fontWeight:
//                                                                 FontWeight.w500,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ...item.tasks
//                                                     .asMap()
//                                                     .entries
//                                                     .map((entry) {
//                                                   int index = entry.key;
//                                                   var task = entry.value;
//                                                   return StatefulBuilder(
//                                                     builder:
//                                                         (context, setState) {
//                                                       return Column(
//                                                         crossAxisAlignment:
//                                                             CrossAxisAlignment
//                                                                 .start,
//                                                         children: [
//                                                           GestureDetector(
//                                                             onTap: () {
//                                                               setState(() {
//                                                                 expandedTasks[
//                                                                         index] =
//                                                                     !expandedTasks[
//                                                                         index];
//                                                               });
//                                                             },
//                                                             child: Padding(
//                                                               padding:
//                                                                   const EdgeInsets
//                                                                       .only(
//                                                                       bottom:
//                                                                           8),
//                                                               child: Row(
//                                                                 children: [
//                                                                   Container(
//                                                                     width: 8,
//                                                                     height: 8,
//                                                                     decoration:
//                                                                         BoxDecoration(
//                                                                       color: _getStatusColor(
//                                                                           task.status),
//                                                                       shape: BoxShape
//                                                                           .circle,
//                                                                     ),
//                                                                   ),
//                                                                   const SizedBox(
//                                                                       width: 8),
//                                                                   Expanded(
//                                                                     child:
//                                                                         Column(
//                                                                       crossAxisAlignment:
//                                                                           CrossAxisAlignment
//                                                                               .start,
//                                                                       children: [
//                                                                         Text(
//                                                                           task.taskName,
//                                                                           style:
//                                                                               const TextStyle(fontSize: 14),
//                                                                         ),
//                                                                         const SizedBox(
//                                                                             height:
//                                                                                 4),
//                                                                         Row(
//                                                                           children: [
//                                                                             Text(
//                                                                               '${task.taskStart} - ${task.taskEnd}',
//                                                                               style: const TextStyle(
//                                                                                 fontSize: 12,
//                                                                                 color: Colors.grey,
//                                                                               ),
//                                                                             ),
//                                                                             const SizedBox(width: 15),
//                                                                             Container(
//                                                                               padding: const EdgeInsets.symmetric(
//                                                                                 horizontal: 8,
//                                                                                 vertical: 2,
//                                                                               ),
//                                                                               decoration: BoxDecoration(
//                                                                                 color: _getStatusColor(task.status).withOpacity(0.2),
//                                                                                 borderRadius: BorderRadius.circular(4),
//                                                                               ),
//                                                                               child: Text(
//                                                                                 task.status,
//                                                                                 style: TextStyle(
//                                                                                   fontSize: 12,
//                                                                                   color: _getStatusColor(task.status),
//                                                                                 ),
//                                                                               ),
//                                                                             ),
//                                                                           ],
//                                                                         ),
//                                                                       ],
//                                                                     ),
//                                                                   ),
//                                                                 ],
//                                                               ),
//                                                             ),
//                                                           ),
//                                                           AnimatedSize(
//                                                             duration:
//                                                                 const Duration(
//                                                                     milliseconds:
//                                                                         300),
//                                                             curve: Curves
//                                                                 .easeInOut,
//                                                             child: expandedTasks[
//                                                                     index]
//                                                                 ? Padding(
//                                                                     padding: const EdgeInsets
//                                                                         .only(
//                                                                         left:
//                                                                             16,
//                                                                         bottom:
//                                                                             8),
//                                                                     child:
//                                                                         Column(
//                                                                       crossAxisAlignment:
//                                                                           CrossAxisAlignment
//                                                                               .start,
//                                                                       children: [
//                                                                         const Text(
//                                                                           'Remarks:',
//                                                                           style:
//                                                                               TextStyle(
//                                                                             fontSize:
//                                                                                 13,
//                                                                             fontWeight:
//                                                                                 FontWeight.w600,
//                                                                             color:
//                                                                                 Colors.black87,
//                                                                           ),
//                                                                         ),
//                                                                         const SizedBox(
//                                                                             height:
//                                                                                 4),
//                                                                         ...task
//                                                                             .remarks
//                                                                             .map((remark) {
//                                                                           return Padding(
//                                                                             padding:
//                                                                                 const EdgeInsets.symmetric(vertical: 2),
//                                                                             child:
//                                                                                 Text(
//                                                                               '• $remark',
//                                                                               style: const TextStyle(
//                                                                                 fontSize: 12,
//                                                                                 color: Colors.black87,
//                                                                               ),
//                                                                             ),
//                                                                           );
//                                                                         }),
//                                                                       ],
//                                                                     ),
//                                                                   )
//                                                                 : const SizedBox(),
//                                                           ),
//                                                         ],
//                                                       );
//                                                     },
//                                                   );
//                                                 }),
//                                                 if (item.assigns.any((assign) =>
//                                                     assign.assignedBy
//                                                         .isNotEmpty)) ...[
//                                                   const SizedBox(height: 12),
//                                                   Container(
//                                                     padding:
//                                                         const EdgeInsets.all(
//                                                             12),
//                                                     decoration: BoxDecoration(
//                                                       color:
//                                                           Colors.grey.shade100,
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               8),
//                                                       border: Border.all(
//                                                         color: Colors
//                                                             .grey.shade300,
//                                                         width: 1,
//                                                       ),
//                                                     ),
//                                                     child: Column(
//                                                       crossAxisAlignment:
//                                                           CrossAxisAlignment
//                                                               .start,
//                                                       children: [
//                                                         const Text(
//                                                           "Assignment Details",
//                                                           style: TextStyle(
//                                                             fontSize: 14,
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                             color:
//                                                                 Colors.blueGrey,
//                                                           ),
//                                                         ),
//                                                         const SizedBox(
//                                                             height: 8),
//                                                         ...item.assigns
//                                                             .map((assign) {
//                                                           return Column(
//                                                             crossAxisAlignment:
//                                                                 CrossAxisAlignment
//                                                                     .start,
//                                                             children: [
//                                                               if (assign.dueDate
//                                                                   .isNotEmpty)
//                                                                 // _buildAssignDetailRow(
//                                                                 //   "Due Date",
//                                                                 //   assign
//                                                                 //       .dueDate,
//                                                                 //   Icons
//                                                                 //       .calendar_today,
//                                                                 // ),
//                                                                 _buildAssignDetailRow(
//                                                                   "Due Date",
//                                                                   formatDueDate(
//                                                                       assign
//                                                                           .dueDate),
//                                                                   Icons
//                                                                       .calendar_today,
//                                                                 ),
//                                                               if (assign
//                                                                   .priority
//                                                                   .isNotEmpty)
//                                                                 _buildAssignDetailRow(
//                                                                   "Priority",
//                                                                   _getPriorityText(
//                                                                       assign
//                                                                           .priority),
//                                                                   Icons
//                                                                       .priority_high,
//                                                                 ),
//                                                               if (assign
//                                                                   .assignedBy
//                                                                   .isNotEmpty)
//                                                                 _buildAssignDetailRow(
//                                                                   "Assigned By",
//                                                                   assign
//                                                                       .assignedBy,
//                                                                   Icons.person,
//                                                                 ),
//                                                             ],
//                                                           );
//                                                         }),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ],
//                                             ),
//                                           ),
//                                           Container(
//                                             padding: const EdgeInsets.symmetric(
//                                                 horizontal: 16, vertical: 12),
//                                             decoration: BoxDecoration(
//                                               color: Colors.white,
//                                               borderRadius:
//                                                   BorderRadius.circular(12),
//                                               boxShadow: [
//                                                 BoxShadow(
//                                                   color: Colors.black
//                                                       .withOpacity(0.05),
//                                                   blurRadius: 6,
//                                                   offset: const Offset(0, 2),
//                                                 )
//                                               ],
//                                             ),
//                                             child: Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment
//                                                       .spaceBetween,
//                                               children: [
//                                                 const Text(
//                                                   "Ideal Time:",
//                                                   style: TextStyle(
//                                                     fontSize: 14,
//                                                     color: Colors.grey,
//                                                   ),
//                                                 ),
//                                                 Text(
//                                                   _formatDuration(
//                                                       item.gapDuration),
//                                                   style: const TextStyle(
//                                                     fontSize: 14,
//                                                     fontWeight: FontWeight.bold,
//                                                     color: Colors.redAccent,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                           const SizedBox(height: 10),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             );
//                           }
//                           return const SizedBox.shrink();
//                         },
//                       ),
//                     ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTimeSummaryPanel() {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(12),
//           color: Colors.blue,
//           child: Row(
//             children: [
//               const Text(
//                 "Time Summary",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const Spacer(),
//               IconButton(
//                 icon: const Icon(Icons.chevron_right, color: Colors.white),
//                 onPressed: _togglePanel,
//               ),
//             ],
//           ),
//         ),
//         Expanded(
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 _buildTimeSummaryItem(
//                   "Login",
//                   (workStatusDetails != null &&
//                           workStatusDetails!.data.isNotEmpty)
//                       ? workStatusDetails!.data.first.loginTime
//                       : "--",
//                   Icons.login,
//                   Colors.green,
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => LoginSummaryPage(
//                           staffId: widget.staffId,
//                           token: token,
//                           date: selectedDate,
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//                 // _buildTimeSummaryItem(
//                 //   "Work Time",
//                 //   (workStatusDetails != null &&
//                 //           workStatusDetails!.data.isNotEmpty)
//                 //       ? workStatusDetails!.data.first.totalWorkingTime ?? "--"
//                 //       : "--",
//                 //   Icons.timer,
//                 //   Colors.purple,
//                 // ),

//                 _buildTimeSummaryItem(
//                   "Ideal",
//                   (workStatusDetails != null &&
//                           workStatusDetails!.data.isNotEmpty)
//                       ? workStatusDetails!.data.first.totalIdeaTime ?? "--"
//                       : "--",
//                   Icons.hourglass_empty,
//                   Colors.orange,
//                 ),
//                 // _buildTimeSummaryItem(
//                 //   "Break",
//                 //   (workStatusDetails != null &&
//                 //           workStatusDetails!.data.isNotEmpty)
//                 //       ? workStatusDetails!.data.first.totalIdeaTime ?? "--"
//                 //       : "--",
//                 //   Icons.free_breakfast,
//                 //   Colors.blue,
//                 // ),

//                 _buildTimeSummaryItem(
//                   "Loggedin Time",
//                   (workStatusDetails != null &&
//                           workStatusDetails!.data.isNotEmpty)
//                       ? workStatusDetails!.data.first.TimeDifference
//                       : "--",
//                   Icons.timeline_rounded,
//                   Colors.green,
//                 ),

//                 _buildTimeSummaryItem(
//                   "Logout",
//                   (workStatusDetails != null &&
//                           workStatusDetails!.data.isNotEmpty)
//                       ? workStatusDetails!.data.first.logoutTime ?? "--"
//                       : "--",
//                   Icons.logout,
//                   Colors.redAccent,
//                 ),
//                 _buildTimeSummaryItem(
//                   "Work Time",
//                   (workStatusDetails != null &&
//                           workStatusDetails!.data.isNotEmpty)
//                       ? workStatusDetails!.data.first.totalWorkingTime ?? "--"
//                       : "--",
//                   Icons.timer,
//                   Colors.deepPurpleAccent,
//                   isHighlight: true,
//                 ),
//                 // _buildTimeSummaryItem(
//                 //   "Total",
//                 //   (workStatusDetails != null &&
//                 //           workStatusDetails!.data.isNotEmpty)
//                 //       ? workStatusDetails!.data.first.totalWorkingTime ?? "--"
//                 //       : "--",
//                 //   Icons.timer,
//                 //   Colors.purple,
//                 // ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTimeSummaryItem(
//     String title,
//     String value,
//     IconData icon,
//     Color color, {
//     bool isHighlight = false,
//     VoidCallback? onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: title == "Work Time"
//               ? Border.all(
//                   color: Colors.deepPurpleAccent,
//                   width: 2) // Only for Work Time
//               : null,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 6,
//               offset: const Offset(0, 3),
//             ),
//           ],
//         ),
//         padding: const EdgeInsets.all(12),
//         child: Row(
//           children: [
//             Icon(icon, color: color, size: 28),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(title,
//                       style:
//                           const TextStyle(fontSize: 14, color: Colors.black54)),
//                   const SizedBox(height: 4),
//                   Text(value,
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight:
//                             isHighlight ? FontWeight.bold : FontWeight.normal,
//                       )),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   double _calculateItemHeight(List<workDetails.Task> tasks) {
//     return 60 + (tasks.length * 28.0);
//   }

//   Widget _buildAssignDetailRow(String label, String value, IconData icon) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 6),
//       child: Row(
//         children: [
//           Icon(
//             icon,
//             size: 16,
//             color: Colors.grey.shade600,
//           ),
//           const SizedBox(width: 8),
//           Text(
//             "$label: ",
//             style: TextStyle(
//               fontSize: 13,
//               color: Colors.grey.shade600,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           Text(
//             value,
//             style: const TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _getPriorityText(String priority) {
//     switch (priority) {
//       case "1":
//         return "Normal";
//       case "2":
//         return "High";
//       case "3":
//         return "Critical";
//       default:
//         return priority;
//     }
//   }

//   Color _getStatusColor(String status) {
//     if (Common.isWorkInProgressStatus(status)) {
//       return const Color.fromARGB(255, 226, 117, 15);
//     }
//     switch (status.trim().toLowerCase()) {
//       case 'complete':
//       case 'completed':
//         return Colors.green;
//       case 'pending':
//         return const Color.fromARGB(255, 172, 201, 7);
//       case 'to do':
//       case 'todo':
//         return Colors.blue;
//       case 'cancelled':
//       case 'cancel':
//         return const Color.fromARGB(255, 164, 21, 19);
//       default:
//         return const Color.fromARGB(255, 42, 188, 251);
//     }
//   }

//   String _getDayFromTime(String? time) {
//     final date = _parseDateTime(time);
//     return date != null ? DateFormat('dd').format(date) : "--";
//   }

//   String _getMonthYearFromTime(String? time) {
//     final date = _parseDateTime(time);
//     return date != null ? DateFormat('MMM yyyy').format(date) : "--- ----";
//   }

//   String _getDateFromTime(String? time) {
//     final date = _parseDateTime(time);
//     return date != null ? DateFormat('yyyyMMdd').format(date) : "";
//   }

//   DateTime? _parseDateTime(String? time) {
//     try {
//       if (time == null) return null;
//       if (time.contains('-') && time.length >= 10) {
//         return DateTime.parse(time);
//       }
//       if (time.contains(':')) {
//         final parts = time.split(':');
//         if (parts.length == 3) {
//           final now = DateTime.now();
//           return DateTime(now.year, now.month, now.day, int.parse(parts[0]),
//               int.parse(parts[1]), int.parse(parts[2]));
//         }
//       }
//       return null;
//     } catch (_) {
//       return null;
//     }
//   }
// }
// ///above is old code
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/core/app_colors.dart';
import 'package:login2/models/expense/expense_post.dart';
import 'package:login2/screens/leadManagement/AssignReport.dart';
import 'package:login2/screens/leadManagement/addWork_page.dart';
import 'package:login2/screens/leadManagement/login_summary_page.dart';
import 'package:login2/widgets/blinkngTime.dart';
import 'package:login2/widgets/work_timer_overlay.dart';
import 'package:login2/widgets/work_timer_chip.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/lead_management/workDetailsModel.dart' as workDetails;
import 'package:login2/models/lead_management/workstatus_model.dart'
    as workStatus;
import '../../service/service.dart';

/// Visual state of one work card on the timeline.
enum _WorkState { running, completed, pending }

class ViewWorkPage extends StatefulWidget {
  final String? staffName;
  final String staffId;
  final DateTime? selectedDate;
  const ViewWorkPage(
      {super.key, this.selectedDate, required this.staffId, this.staffName});

  @override
  State<ViewWorkPage> createState() => _ViewWorkPageState();
}

class _ViewWorkPageState extends State<ViewWorkPage> {
  late String currentDate;
  workDetails.WorkDetailsModel? workStatusDetails;
  workStatus.WorkStatus? existingWork;
  bool isLoading = true;
  bool _isPanelOpen = false;
  final double _panelWidth = 200.0;
  double _panelPosition = -200.0;
  String token = "";
  late DateTime selectedDate;
  CommonResponse? loginOrNot;
  bool? isLoggedIn;
  String? userId;
  String? addWorkPermission;
  String? _resolvedStaffName;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedDate ?? DateTime.now();
    currentDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    print("Selected date passed to ViewWorkPage: ${widget.selectedDate}");
    _resolvedStaffName =
        (widget.staffName != null && widget.staffName!.isNotEmpty)
            ? widget.staffName
            : null;
    _initData();
    _loadStaffName();
  }

  Future<void> _loadStaffName() async {
    if (widget.staffName != null && widget.staffName!.isNotEmpty) {
      _resolvedStaffName = widget.staffName;
      return;
    }
    final response = await HttpService.getStaffs();
    if (!mounted) return;
    if (response != null && response.data.isNotEmpty) {
      for (final staff in response.data) {
        if (staff.userIdStaff == widget.staffId) {
          if (!mounted) return;
          setState(() {
            _resolvedStaffName = staff.name;
          });
          break;
        }
      }
    }
  }

  Future<void> _initData() async {
    userId = await Common.getSharedPref("userId");
    addWorkPermission = await Common.getSharedPref("addWorkPermission");
    print("userId:$userId");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getWorkDuration(currentDate);
      checkExistingWorkStatus();
    });
    await loadToken();
    await loginorNot();
  }

  Future<void> loadToken() async {
    token = await Common.getSharedPref("token");
    if (!mounted) return;
    setState(() {});
  }

  Future<void> checkExistingWorkStatus() async {
    final workStatusModel = await HttpService.getWorkStatus();
    if (!mounted) return;
    setState(() {
      if (workStatusModel != null && workStatusModel.data.isNotEmpty) {
        existingWork = workStatusModel.data.first;
      } else {
        existingWork = null;
      }
    });
    WorkTimerChip.refreshAll();
  }

  String formatDueDate(String? dueDate) {
    if (dueDate == null || dueDate.isEmpty) return '';
    try {
      DateTime? parsedDate;
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
          parsedDate = f.parse(dueDate.trim());
          break;
        } catch (_) {}
      }
      parsedDate ??= DateTime.tryParse(dueDate.trim());
      if (parsedDate != null) {
        if (parsedDate.hour != 0 || parsedDate.minute != 0) {
          return DateFormat('dd-MM-yyyy hh:mm a').format(parsedDate);
        }
        return DateFormat('dd-MM-yyyy').format(parsedDate);
      }
      return dueDate;
    } catch (e) {
      return dueDate;
    }
  }

  Future<void> loginorNot() async {
    final response = await HttpService.getCurrentLoginStatus();
    if (!mounted) return;
    setState(() {
      if (response != null && response.data == true) {
        isLoggedIn = true;
      } else {
        isLoggedIn = false;
      }
    });
  }

  void _launchMap(String? latitude, String? longitude) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    final uri = Uri.parse(url);

    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        debugPrint('Could not launch URL: $url');
      }
    } catch (e) {
      debugPrint('Exception when launching URL: $e');
    }
  }

  Future<void> getWorkDuration(String date) async {
    final response =
        await HttpService.getWorkStatusDetails(date, staffId: widget.staffId);
    if (!mounted) return;
    setState(() {
      workStatusDetails = response;
      isLoading = false;
    });
  }

  String getDurationSinceLogin(String? loginTimeString) {
    if (loginTimeString == null || loginTimeString.isEmpty) return "--";
    try {
      final loginTime = DateTime.parse(loginTimeString);
      final now = DateTime.now();
      final duration = now.difference(loginTime);
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      if (hours == 0 && minutes == 0) return "Just now";
      if (hours == 0) return "$minutes min ago";
      return "$hours hr ${minutes.toString().padLeft(2, '0')} min ago";
    } catch (e) {
      return "--";
    }
  }

  String _formatDuration(String? duration) {
    if (duration == null || duration.isEmpty) return "Started";
    try {
      if (duration.contains(':')) {
        final parts = duration.split(':');
        if (parts.length == 3) {
          final hours = int.parse(parts[0]);
          final minutes = int.parse(parts[1]);
          final seconds = int.parse(parts[2]);
          if (hours > 0) return "${hours}h ${minutes}m";
          if (minutes > 0) return "${minutes}m ${seconds}s";
          return "${seconds}s";
        }
      }
      final seconds = int.tryParse(duration) ?? 0;
      return "${seconds}s";
    } catch (e) {
      return "0s";
    }
  }

  void _togglePanel() {
    setState(() {
      _isPanelOpen = !_isPanelOpen;
      _panelPosition = _isPanelOpen ? 0 : -_panelWidth;
    });
  }

  // ------------------------------------------------------------------
  // Work state -> colours (running / completed / pending)
  // ------------------------------------------------------------------

  _WorkState _resolveState(List<workDetails.Task> tasks, bool isInProgress) {
    if (isInProgress) return _WorkState.running;

    final hasPending = tasks.any((t) {
      final s = t.status.trim().toLowerCase();
      return s == 'pending' || s == 'to do' || s == 'todo';
    });
    return hasPending ? _WorkState.pending : _WorkState.completed;
  }

  Color _stateColor(_WorkState s) {
    switch (s) {
      case _WorkState.running:
        return AppColors.running;
      case _WorkState.completed:
        return AppColors.success;
      case _WorkState.pending:
        return AppColors.warning;
    }
  }

  Color _stateTint(_WorkState s) {
    switch (s) {
      case _WorkState.running:
        return AppColors.runningTint;
      case _WorkState.completed:
        return AppColors.successTint;
      case _WorkState.pending:
        return AppColors.warningTint;
    }
  }

  Color _stateBorder(_WorkState s) {
    switch (s) {
      case _WorkState.completed:
        return AppColors.successBorder;
      default:
        return AppColors.tint(_stateColor(s), 0.30);
    }
  }

  // ------------------------------------------------------------------
  // Logic moved into methods (same behaviour as before)
  // ------------------------------------------------------------------

  /// Same date-picker logic as the old AppBar icon.
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      if (!mounted) return;
      setState(() {
        selectedDate = picked;
        currentDate = DateFormat('yyyy-MM-dd').format(picked);
        isLoading = true;
      });
      await getWorkDuration(currentDate);
    }
  }

  /// Same logic as the old "Restart" onTap (only item.id was used).
  Future<void> _handleRestart(String itemId) async {
    final loginResponse = await HttpService.getCurrentLoginStatus();
    if (loginResponse == null ||
        loginResponse.status != true ||
        loginResponse.data != true) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: AppColors.card,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text(
              'Login Required',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            content: const Text('Please login first.',
                style: TextStyle(color: AppColors.textMedium)),
            actions: [
              TextButton(
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
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
    bool isAnyWorkInProgress = existingWork != null ||
        workStatusDetails!.data.any((w) {
          final isCur = existingWork != null &&
              existingWork!.id.isNotEmpty &&
              existingWork!.id == w.id;
          final hasProg =
              w.tasks.any((t) => Common.isWorkInProgressStatus(t.status));
          return isCur ||
              hasProg ||
              w.endTime == "00:00:00" ||
              w.endTime.isEmpty;
        });
    if (isAnyWorkInProgress) {
      Common.toastMessaage(
          'Work is in progress. Please stop the work before restarting new work',
          Colors.red);
      return;
    }
    final workStatusModel = await HttpService.getWorkStatusPaused(itemId);
    if (!mounted) return;
    workStatus.WorkStatus? newExistingWork;
    if (workStatusModel != null && workStatusModel.data.isNotEmpty) {
      newExistingWork = workStatusModel.data.first;
    }
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddWorkPage(
          workId: itemId,
          existingWork: null,
          isPaused: 0,
          Restart: 1,
          popOnSuccess: true,
          onSuccess: () {
            setState(() {
              checkExistingWorkStatus();
            });
          },
        ),
      ),
    );
    if (result == true && mounted) {
      getWorkDuration(currentDate);
      checkExistingWorkStatus();
    }
  }

  // ------------------------------------------------------------------
  // Small UI helpers (presentation only)
  // ------------------------------------------------------------------
  BoxDecoration _cardDecoration({Color? color, double radius = 14}) =>
      BoxDecoration(
        color: color ?? AppColors.card,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      );

  Widget _pill(String text, Color color, {IconData? icon, double size = 12}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.tint(color),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: size + 2, color: color),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: size,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoLine(IconData icon, String text, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 15, color: color ?? AppColors.textGrey),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: color ?? AppColors.textMedium,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasStaffName =
        _resolvedStaffName != null && _resolvedStaffName!.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: false,
        title: hasStaffName
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _resolvedStaffName!,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textOnColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "Work Timeline",
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.tint(AppColors.textOnColor, 0.85),
                    ),
                  ),
                ],
              )
            : const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Work Timeline",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textOnColor,
                    ),
                  ),
                ],
              ),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textOnColor,
        iconTheme: const IconThemeData(color: AppColors.textOnColor),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.appBarGradient,
          ),
        ),
        actions: [
          // selected date, so the user always knows which day is shown
          Center(
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: _pickDate,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.tint(AppColors.textOnColor, 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  DateFormat('dd MMM').format(selectedDate),
                  style: const TextStyle(
                    color: AppColors.textOnColor,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _pickDate,
          ),
        ],
      ),
      floatingActionButton: ((widget.staffId != "")
                  ? (userId != null && widget.staffId == userId)
                  : (userId != null)) &&
              addWorkPermission == "true" &&
              existingWork == null
          ? FloatingActionButton.extended(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add_rounded, color: AppColors.textOnColor),
              label: const Text(
                'Start Work',
                style: TextStyle(
                  color: AppColors.textOnColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onPressed: () async {
                final loginResponse = await HttpService.getCurrentLoginStatus();
                isLoggedIn = loginResponse != null &&
                    loginResponse.status == true &&
                    loginResponse.data == true;
                if (!mounted) return;
                if (isLoggedIn == true) {
                  final workStatusModel = await HttpService.getWorkStatus();
                  if (!mounted) return;
                  workStatus.WorkStatus? newExistingWork;
                  if (workStatusModel != null &&
                      workStatusModel.data.isNotEmpty) {
                    newExistingWork = workStatusModel.data.first;
                  }
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddWorkPage(
                        workId: "",
                        existingWork: newExistingWork,
                        popOnSuccess: true,
                        onSuccess: () {
                          setState(() {
                            getWorkDuration(currentDate);
                            checkExistingWorkStatus();
                          });
                        },
                      ),
                    ),
                  );
                  if (result == true && mounted) {
                    getWorkDuration(currentDate);
                    checkExistingWorkStatus();
                  }
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: AppColors.card,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        title: const Text(
                          'Login Required',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        content: const Text('Please login to add work.',
                            style: TextStyle(color: AppColors.textMedium)),
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
            )
          : null,
      body: WorkTimerOverlay(
        onTimerReturn: () {
          getWorkDuration(currentDate);
          checkExistingWorkStatus();
        },
        child: Stack(
          children: [
            GestureDetector(
              onTap: () {
                if (_isPanelOpen) {
                  _togglePanel();
                }
              },
              child: AbsorbPointer(
                absorbing: _isPanelOpen,
                child: _buildMainContent(),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              right: _panelPosition,
              top: 0,
              bottom: 0,
              width: _panelWidth,
              child: GestureDetector(
                onHorizontalDragUpdate: (details) {
                  if (details.delta.dx < 0) {
                    // Swiping left
                    setState(() {
                      _panelPosition = (_panelPosition - details.delta.dx)
                          .clamp(-_panelWidth, 0.0);
                    });
                  } else if (details.delta.dx > 0) {
                    // Swiping right
                    setState(() {
                      _panelPosition = (_panelPosition - details.delta.dx)
                          .clamp(-_panelWidth, 0.0);
                    });
                  }
                },
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity! < 0) {
                    _togglePanel();
                  } else if (details.primaryVelocity! > 0) {
                    _togglePanel();
                  } else {
                    if (_panelPosition.abs() > _panelWidth / 2) {
                      _togglePanel();
                    } else {
                      _togglePanel();
                    }
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(-3, 0),
                      ),
                    ],
                  ),
                  child: _buildTimeSummaryPanel(),
                ),
              ),
            ),
            if (!_isPanelOpen)
              Positioned(
                right: 0,
                top: MediaQuery.of(context).size.height / 2 - 50,
                child: GestureDetector(
                  onTap: _togglePanel,
                  child: Container(
                    width: 26,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        bottomLeft: Radius.circular(14),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(-2, 0),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.chevron_left_rounded,
                        color: AppColors.textOnColor,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.work_off_outlined,
              size: 56, color: AppColors.tint(AppColors.primary, 0.35)),
          const SizedBox(height: 12),
          const Text(
            "No work data available",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textMedium,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Try another date from the calendar",
            style: TextStyle(fontSize: 12.5, color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        Expanded(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary))
              : (workStatusDetails == null ||
                      workStatusDetails!.data.isEmpty ||
                      workStatusDetails!.data.first.tasks.isEmpty)
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () async {
                        setState(() {
                          isLoading = true;
                        });
                        await getWorkDuration(currentDate);
                        await checkExistingWorkStatus();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
                        itemCount: workStatusDetails!.data.length,
                        itemBuilder: (context, index) =>
                            _buildTimelineEntry(index),
                      ),
                    ),
        ),
      ],
    );
  }

  /// One work entry of the timeline (date header + rail + card + ideal time).
  Widget _buildTimelineEntry(int index) {
    final item = workStatusDetails!.data[index];

    final hasAssignment =
        item.assigns.any((assign) => assign.assignedBy.isNotEmpty);

    // Tasks collapsed initially
    List<bool> expandedTasks =
        List.generate(item.tasks.length, (index) => false);

    final isCurrentSessionRunning = existingWork != null &&
        existingWork!.id.isNotEmpty &&
        existingWork!.id == item.id;

    final hasInProgressTask =
        item.tasks.any((t) => Common.isWorkInProgressStatus(t.status));

    final isInProgress = isCurrentSessionRunning ||
        hasInProgressTask ||
        item.endTime == "00:00:00" ||
        item.endTime.isEmpty;

    // State -> colours for this card
    final state = _resolveState(item.tasks, isInProgress);
    final stateColor = _stateColor(state);
    final stateTint = _stateTint(state);
    final stateBorder = _stateBorder(state);

    final showDateHeader = index == 0 ||
        _getDateFromTime(item.startTime) !=
            _getDateFromTime(workStatusDetails!.data[index - 1].startTime);

    if (item.title == "") {
      return const SizedBox.shrink();
    }

    // Status action
    Widget statusAction;

    if (item.totalDuration.isNotEmpty && item.is_paused != "0") {
      statusAction = _pill(
        "Worked: ${item.totalDuration}",
        AppColors.textMedium,
        icon: Icons.timer_outlined,
      );
    } else if (!isInProgress && userId != null && widget.staffId == userId) {
      statusAction = GestureDetector(
        onTap: () => _handleRestart(item.id),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.tint(AppColors.primary, 0.10),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.tint(AppColors.primary, 0.35),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.restart_alt_rounded,
                size: 17,
                color: AppColors.primary,
              ),
              SizedBox(width: 3),
              Text(
                "Restart",
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      statusAction = _pill(
        "Running...",
        stateColor,
        icon: Icons.play_circle_outline_rounded,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date header
        if (showDateHeader)
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 9),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _getDayFromTime(currentDate),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textOnColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  _getMonthYearFromTime(currentDate),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),

        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Timeline rail
              SizedBox(
                width: 18,
                child: Column(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: stateColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.card,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.tint(stateColor, 0.35),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                    ),
                    if (index != workStatusDetails!.data.length - 1)
                      Expanded(
                        child: Container(
                          width: 2,
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          color: AppColors.borderStrong,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Column(
                  children: [
                    // Main work card
                    Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        color: stateTint,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: stateBorder),
                        boxShadow: AppColors.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Customer / Project + Status
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AssignReport(
                                          workId: item.id,
                                          sectionId: "",
                                        ),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color:
                                              AppColors.tint(stateColor, 0.12),
                                          borderRadius:
                                              BorderRadius.circular(9),
                                        ),
                                        child: Icon(
                                          Icons.work_outline_rounded,
                                          size: 18,
                                          color: stateColor,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          '${item.customerName ?? "No title"} [${item.projectName}]',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textDark,
                                          ),
                                          softWrap: true,
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.only(top: 1),
                                        child: Icon(
                                          Icons.chevron_right_rounded,
                                          size: 18,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              statusAction,
                            ],
                          ),

                          const SizedBox(height: 7),

                          // Module
                          _infoLine(
                            Icons.widgets_outlined,
                            "Module: ${item.titleName}",
                          ),

                          const SizedBox(height: 6),

                          // Start / End (+ Assigned badge)
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              _pill(
                                "Start: ${item.startTime}",
                                AppColors.present,
                                icon: Icons.login_rounded,
                                size: 11.5,
                              ),
                              isInProgress
                                  ? BlinkingText(
                                      text: "Running",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: stateColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : _pill(
                                      "End: ${item.endTime}",
                                      AppColors.danger,
                                      icon: Icons.logout_rounded,
                                      size: 11.5,
                                    ),
                              // if (hasAssignment)
                              //   _pill(
                              //     "Assigned",
                              //     AppColors.accent,
                              //     icon: Icons.assignment_ind_outlined,
                              //     size: 11.5,
                              //   ),
                            ],
                          ),

                          // Location
                          if (item.latitude.isNotEmpty &&
                              double.tryParse(item.latitude) != 0) ...[
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: () => _launchMap(
                                item.latitude,
                                item.longitude,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.tint(AppColors.primary, 0.08),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 16,
                                      color: AppColors.primary,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      "View Location",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],

                          // Tasks
                          const SizedBox(height: 9),

                          const Text(
                            "TASKS",
                            style: TextStyle(
                              fontSize: 11,
                              letterSpacing: 0.8,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textLight,
                            ),
                          ),

                          const SizedBox(height: 4),

                          ...item.tasks.asMap().entries.map((entry) {
                            final taskIndex = entry.key;
                            final task = entry.value;

                            return _buildTaskTile(
                              task,
                              expandedTasks,
                              taskIndex,
                            );
                          }),

                          // Assignment details
                          if (hasAssignment) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.border,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.assignment_ind_outlined,
                                        size: 18,
                                        color: AppColors.primary,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        "Assignment Details",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  ...item.assigns.map((assign) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (assign.dueDate.isNotEmpty)
                                          _buildAssignDetailRow(
                                            "Due Date",
                                            formatDueDate(assign.dueDate),
                                            Icons.calendar_today,
                                          ),
                                        if (assign.priority.isNotEmpty)
                                          _buildAssignDetailRow(
                                            "Priority",
                                            _getPriorityText(assign.priority),
                                            Icons.priority_high,
                                          ),
                                        if (assign.assignedBy.isNotEmpty)
                                          _buildAssignDetailRow(
                                            "Assigned By",
                                            assign.assignedBy,
                                            Icons.person,
                                          ),
                                      ],
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Ideal Time
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 9,
                      ),
                      decoration: _cardDecoration(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.hourglass_empty_rounded,
                                size: 18,
                                color: AppColors.textGrey,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Ideal Time:",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textGrey,
                                ),
                              ),
                            ],
                          ),
                          _pill(
                            _formatDuration(item.gapDuration),
                            AppColors.danger,
                            size: 13,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// One task row, tap to expand/collapse its remarks (same logic as before).
  Widget _buildTaskTile(
    workDetails.Task task,
    List<bool> expandedTasks,
    int taskIndex,
  ) {
    return StatefulBuilder(
      builder: (context, setState) {
        final statusColor = _getStatusColor(task.status);
        final bool expanded = expandedTasks[taskIndex];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppColors.card, // white, so it stands out on tinted card
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  setState(() {
                    expandedTasks[taskIndex] = !expandedTasks[taskIndex];
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 4,
                        height: 38,
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.taskName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Wrap(
                              spacing: 10,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.schedule_rounded,
                                        size: 13, color: AppColors.textGrey),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${task.taskStart} - ${task.taskEnd}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textGrey,
                                      ),
                                    ),
                                  ],
                                ),
                                _pill(task.status, statusColor, size: 11.5),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        expanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 22,
                        color: AppColors.textLight,
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: expanded
                    ? Container(
                        width: double.infinity,
                        margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.sheetBackground,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.notes_rounded,
                                    size: 14, color: AppColors.textGrey),
                                SizedBox(width: 6),
                                Text(
                                  'Remarks',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textMedium,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            if (task.remarks.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 2),
                                child: Text(
                                  'No remarks',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: AppColors.textLight,
                                  ),
                                ),
                              ),
                            ...task.remarks.map((remark) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2),
                                child: Text(
                                  '• $remark',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.textMedium,
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      )
                    : const SizedBox(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeSummaryPanel() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
          child: Row(
            children: [
              const Icon(Icons.access_time_filled_rounded,
                  size: 18, color: AppColors.textOnColor),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  "Time Summary",
                  style: TextStyle(
                    color: AppColors.textOnColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textOnColor),
                onPressed: _togglePanel,
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: AppColors.pageBackground,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  _buildTimeSummaryItem(
                    "Login",
                    (workStatusDetails != null &&
                            workStatusDetails!.data.isNotEmpty)
                        ? workStatusDetails!.data.first.loginTime
                        : "--",
                    Icons.login,
                    AppColors.present,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginSummaryPage(
                            staffId: widget.staffId,
                            token: token,
                            date: selectedDate,
                          ),
                        ),
                      );
                    },
                  ),
                  _buildTimeSummaryItem(
                    "Ideal",
                    (workStatusDetails != null &&
                            workStatusDetails!.data.isNotEmpty)
                        ? workStatusDetails!.data.first.totalIdeaTime ?? "--"
                        : "--",
                    Icons.hourglass_empty,
                    AppColors.pending,
                  ),
                  _buildTimeSummaryItem(
                    "Loggedin Time",
                    (workStatusDetails != null &&
                            workStatusDetails!.data.isNotEmpty)
                        ? workStatusDetails!.data.first.TimeDifference
                        : "--",
                    Icons.timeline_rounded,
                    AppColors.success,
                  ),
                  _buildTimeSummaryItem(
                    "Logout",
                    (workStatusDetails != null &&
                            workStatusDetails!.data.isNotEmpty)
                        ? workStatusDetails!.data.first.logoutTime ?? "--"
                        : "--",
                    Icons.logout,
                    AppColors.danger,
                  ),
                  _buildTimeSummaryItem(
                    "Work Time",
                    (workStatusDetails != null &&
                            workStatusDetails!.data.isNotEmpty)
                        ? workStatusDetails!.data.first.totalWorkingTime ?? "--"
                        : "--",
                    Icons.timer,
                    AppColors.accent,
                    isHighlight: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSummaryItem(
    String title,
    String value,
    IconData icon,
    Color color, {
    bool isHighlight = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: title == "Work Time"
              ? Border.all(color: AppColors.accent, width: 2)
              : Border.all(color: AppColors.border),
          boxShadow: AppColors.cardShadow,
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.tint(color),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textGrey,
                      )),
                  const SizedBox(height: 3),
                  Text(value,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textDark,
                        fontWeight:
                            isHighlight ? FontWeight.w800 : FontWeight.w600,
                      )),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 13, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }

  double _calculateItemHeight(List<workDetails.Task> tasks) {
    return 60 + (tasks.length * 28.0);
  }

  Widget _buildAssignDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.textGrey,
          ),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
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
        return priority;
    }
  }

  Color _getStatusColor(String status) {
    if (Common.isWorkInProgressStatus(status)) {
      return AppColors.accent;
    }
    switch (status.trim().toLowerCase()) {
      case 'complete':
      case 'completed':
        return AppColors.success;
      case 'pending':
        return AppColors.pending;
      case 'to do':
      case 'todo':
        return AppColors.halfDay;
      case 'cancelled':
      case 'cancel':
        return AppColors.danger;
      default:
        return AppColors.statusDefault;
    }
  }

  String _getDayFromTime(String? time) {
    final date = _parseDateTime(time);
    return date != null ? DateFormat('dd').format(date) : "--";
  }

  String _getMonthYearFromTime(String? time) {
    final date = _parseDateTime(time);
    return date != null ? DateFormat('MMM yyyy').format(date) : "--- ----";
  }

  String _getDateFromTime(String? time) {
    final date = _parseDateTime(time);
    return date != null ? DateFormat('yyyyMMdd').format(date) : "";
  }

  DateTime? _parseDateTime(String? time) {
    try {
      if (time == null) return null;
      if (time.contains('-') && time.length >= 10) {
        return DateTime.parse(time);
      }
      if (time.contains(':')) {
        final parts = time.split(':');
        if (parts.length == 3) {
          final now = DateTime.now();
          return DateTime(now.year, now.month, now.day, int.parse(parts[0]),
              int.parse(parts[1]), int.parse(parts[2]));
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}

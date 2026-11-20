// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:login2/core/common.dart';
// import 'package:login2/screens/leadManagement/login_summary_page.dart';
// import '../../models/staff_report/staff_calls_model.dart';
// import '../../service/service.dart';

// class TimelinePage extends StatefulWidget {
//   const TimelinePage({super.key});

//   @override
//   State<TimelinePage> createState() => _TimelinePageState();
// }

// class _TimelinePageState extends State<TimelinePage> {
//   late String staffId;
//   late String currentDate;
//   late DateTime selectedDate;

//   StaffCallDuration? staffCallDuration;
//   Map<String, List<Call>> groupedItems = {};

//   // Right panel variables
//   bool _isPanelOpen = false;
//   final double _panelWidth = 200.0;
//   double _panelPosition = -200.0;

//   // Left panel variables
//   bool _isLeftPanelOpen = false;
//   final double _leftPanelWidth = 200.0;
//   double _leftPanelPosition = -200.0;
//   String token = "";
//   @override
//   void initState() {
//     super.initState();
//     _initializeData();
//     // Future.delayed(Duration.zero, () {
//     //   final args =
//     //       ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

//     //   staffId = args["staffId"] as String;

//     //   selectedDate = args.containsKey("selectedDate")
//     //       ? args["selectedDate"] as DateTime
//     //       : DateTime.now();

//     //   currentDate = DateFormat('yyyy-MM-dd').format(selectedDate);
//     //   getCallDuration();
//     // });
//   }

//   Future<void> _initializeData() async {
//     token = await Common.getSharedPref("token") ?? "";
//     final args =
//         ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

//     staffId = args["staffId"] as String;

//     selectedDate = args.containsKey("selectedDate")
//         ? args["selectedDate"] as DateTime
//         : DateTime.now();

//     currentDate = DateFormat('yyyy-MM-dd').format(selectedDate);
//     await getCallDuration();
//   }

//   Future<void> getCallDuration() async {
//     staffCallDuration =
//         await HttpService.getStaffCallDuration(staffId, currentDate);
//     if (staffCallDuration != null && staffCallDuration!.status == true) {
//       for (var call in staffCallDuration!.data.calls) {
//         String dateStr = call.calledDate.split(' ')[0];
//         groupedItems.putIfAbsent(dateStr, () => []).add(call);
//       }
//       setState(() {});
//     }
//   }

//   void _togglePanel() {
//     setState(() {
//       _isPanelOpen = !_isPanelOpen;
//       _panelPosition = _isPanelOpen ? 0 : -_panelWidth;
//     });
//   }

//   void _toggleLeftPanel() {
//     setState(() {
//       _isLeftPanelOpen = !_isLeftPanelOpen;
//       _leftPanelPosition = _isLeftPanelOpen ? 0 : -_leftPanelWidth;
//     });
//   }

//   String formatDateHeader(String dateStr) {
//     final date = DateFormat('dd-MM-yyyy').parse(dateStr);
//     return DateFormat('dd MMM').format(date).toUpperCase();
//   }

//   Widget buildTimelineItem(Call call) {
//     return Column(
//       children: [
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Column(
//               children: [
//                 const CircleAvatar(radius: 6, backgroundColor: Colors.green),
//                 Container(width: 2, height: 90, color: Colors.grey.shade400),
//               ],
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: Column(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.lightBlue.shade50,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Row(
//                       children: [
//                         const CircleAvatar(
//                           radius: 20,
//                           backgroundImage: AssetImage(
//                               'assets/icons/profile_placeholder.png'),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(call.name,
//                                   style: const TextStyle(
//                                       fontWeight: FontWeight.bold)),
//                               Text(call.phone),
//                               Text("Called Date : ${call.calledDate}",
//                                   style: const TextStyle(fontSize: 12)),
//                               Text("Called Time : ${call.calledTime}",
//                                   style: const TextStyle(fontSize: 12)),
//                               Text("Called Duration : ${call.duration}",
//                                   style: const TextStyle(fontSize: 12)),
//                             ],
//                           ),
//                         ),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                               vertical: 4, horizontal: 8),
//                           decoration: BoxDecoration(
//                             color: Colors.blue,
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                           child: Text(call.callType,
//                               style: const TextStyle(
//                                   color: Colors.white, fontSize: 12)),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       _tagBox("Ideal Time", const Color.fromARGB(255, 8, 8, 8)),
//                       const SizedBox(width: 8),
//                       _tagBox(call.idealTime,
//                           const Color.fromARGB(255, 228, 58, 58)),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget buildLoginTimeBox() {
//     return Center(
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         decoration: BoxDecoration(
//           color: const Color(0xFF3DC721),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Text(
//           'Login Time: ${staffCallDuration?.data.summary.startTime ?? "N/A"}',
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildLogoutTimeRow() {
//     return Center(
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         decoration: BoxDecoration(
//           color: const Color.fromARGB(255, 219, 58, 29),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Text(
//           'Logout Time: ${staffCallDuration?.data.summary.endTime ?? "N/A"}',
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _tagBox(String text, Color color, {IconData? icon}) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//       decoration: BoxDecoration(
//         color: color,
//         borderRadius: BorderRadius.circular(4),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           if (icon != null) ...[
//             Icon(icon, color: Colors.white, size: 14),
//             const SizedBox(width: 4),
//           ],
//           Text(
//             text,
//             style: const TextStyle(color: Colors.white, fontSize: 12),
//           ),
//         ],
//       ),
//     );
//   }

//   Duration parseDuration(String time) {
//     final parts = time.split(':').map(int.parse).toList();
//     if (parts.length != 3) return Duration.zero;
//     return Duration(hours: parts[0], minutes: parts[1], seconds: parts[2]);
//   }

//   String formatDuration(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     return "${twoDigits(duration.inHours)}:${twoDigits(duration.inMinutes % 60)}:${twoDigits(duration.inSeconds % 60)}";
//   }

//   Widget buildBottomSummarySection(StaffCallDuration staffCallDuration) {
//     final summary = staffCallDuration.data.summary;
//     final incoming = parseDuration(summary.totalIncomingDuration);
//     final outgoing = parseDuration(summary.totalOutgoingDuration);
//     final totalDuration = incoming + outgoing;

//     return Column(
//       children: [
//         Row(
//           children: [
//             buildInfoCard(
//               "WORK TIME",
//               "START TIME : ${summary.startTime}\nEND TIME : ${summary.endTime}",
//               Icons.schedule,
//             ),
//             const SizedBox(width: 10),
//             buildInfoCard(
//               "TOTAL TIME DURATION",
//               "INCOMING : ${summary.totalIncomingDuration}\n"
//                   "OUTGOING : ${summary.totalOutgoingDuration}\n"
//                   "TOTAL: ${formatDuration(totalDuration)}",
//               Icons.timelapse,
//             ),
//           ],
//         ),
//         const SizedBox(height: 10),
//         Row(
//           children: [
//             buildInfoCard(
//                 "TOTAL FREE TIME",
//                 "🛑 IDEAL : ${summary.totalIdealTime}\n☕BREAK :00min,0secs\nTOTAL: ${summary.totalIdealTime}",
//                 Icons.free_breakfast),
//             const SizedBox(width: 10),
//             buildInfoCard(
//                 "TOTAL CONNECTED CALLS",
//                 "TOTAL: ${summary.totalCalls}\nCONNECTED: ${summary.totalCalls}\nMISSED: 0",
//                 Icons.call),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget buildInfoCard(String title, String content, IconData icon) {
//     return Expanded(
//       child: Card(
//         elevation: 2,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: Padding(
//           padding: const EdgeInsets.all(12),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Icon(icon, color: Colors.blue),
//                   const SizedBox(width: 8),
//                   Expanded(
//                       child: Text(title,
//                           style: const TextStyle(fontWeight: FontWeight.bold))),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               Text(content, style: const TextStyle(fontSize: 13)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Widget _buildTimeSummaryItem(
//   //     String label, String value, IconData icon, Color color) {
//   //   return Container(
//   //     padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//   //     margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//   //     decoration: BoxDecoration(
//   //       color: Colors.grey.shade100,
//   //       borderRadius: BorderRadius.circular(8),
//   //     ),
//   //     child: Row(
//   //       children: [
//   //         Icon(icon, color: color),
//   //         const SizedBox(width: 12),
//   //         Column(
//   //           crossAxisAlignment: CrossAxisAlignment.start,
//   //           children: [
//   //             Text(
//   //               label,
//   //               style: const TextStyle(
//   //                 fontSize: 12,
//   //                 color: Colors.black54,
//   //               ),
//   //             ),
//   //             Text(
//   //               value,
//   //               style: const TextStyle(
//   //                 fontSize: 14,
//   //                 fontWeight: FontWeight.bold,
//   //               ),
//   //             ),
//   //           ],
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }
//   Widget _buildTimeSummaryItem(
//     String label,
//     String value,
//     IconData icon,
//     Color color, {
//     VoidCallback? onTap, // only passed for "Login"
//   }) {
//     final isClickable = onTap != null;

//     final content = Container(
//       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//       margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade100,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, color: color),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: const TextStyle(fontSize: 12, color: Colors.black54),
//                 ),
//                 Text(
//                   value,
//                   style: const TextStyle(
//                       fontSize: 14, fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//           ),
//           if (isClickable)
//             const Icon(Icons.arrow_forward_ios,
//                 size: 16, color: Colors.black45),
//         ],
//       ),
//     );

//     return isClickable ? InkWell(onTap: onTap, child: content) : content;
//   }

//   Duration parseDuration_build(String time) {
//     final parts = time.split(':').map(int.parse).toList();
//     if (parts.length == 3) {
//       return Duration(hours: parts[0], minutes: parts[1], seconds: parts[2]);
//     } else if (parts.length == 2) {
//       return Duration(minutes: parts[0], seconds: parts[1]);
//     }
//     return Duration.zero;
//   }

//   String formatDuration_build(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     return "${twoDigits(duration.inHours)}:"
//         "${twoDigits(duration.inMinutes.remainder(60))}:"
//         "${twoDigits(duration.inSeconds.remainder(60))}";
//   }

//   Widget _buildTimeSummaryPanel(String token) {
//     final summary = staffCallDuration?.data.summary;
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
//                 // _buildTimeSummaryItem(
//                 //   "Login",
//                 //   summary?.startTime ?? "--",
//                 //   Icons.login,
//                 //   Colors.green,
//                 // ),
//                 _buildTimeSummaryItem(
//                   "Login",
//                   summary?.startTime ?? "--",
//                   Icons.login,
//                   Colors.green,
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => LoginSummaryPage(
//                           staffId: staffId,
//                           token: token,
//                           date: selectedDate ?? DateTime.now(),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//                 _buildTimeSummaryItem(
//                   "Work Time",
//                   summary != null
//                       ? formatDuration_build(
//                           parseDuration_build(summary.totalIncomingDuration) +
//                               parseDuration_build(
//                                   summary.totalOutgoingDuration),
//                         )
//                       : "--",
//                   Icons.timer,
//                   Colors.purple,
//                 ),
//                 _buildTimeSummaryItem(
//                   "Ideal",
//                   summary?.totalIdealTime ?? "--",
//                   Icons.hourglass_empty,
//                   Colors.orange,
//                 ),

//                 _buildTimeSummaryItem(
//                   "Loggedin Time",
//                   "--",
//                   Icons.login,
//                   Colors.orange,
//                 ),
//                 // _buildTimeSummaryItem(
//                 //   "Break",
//                 //   summary?.totalIdealTime ?? "--",
//                 //   Icons.free_breakfast,
//                 //   Colors.blue,
//                 // ),
//                 _buildTimeSummaryItem(
//                   "Logout",
//                   summary?.endTime ?? "--",
//                   Icons.logout,
//                   Colors.redAccent,
//                 ),
//                 // _buildTimeSummaryItem(
//                 //   "Total",
//                 //   summary != null
//                 //       ? formatDuration_build(
//                 //           parseDuration_build(summary.totalIncomingDuration) +
//                 //               parseDuration_build(
//                 //                   summary.totalOutgoingDuration),
//                 //         )
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

//   String _calculateAverageCallDuration() {
//     if (staffCallDuration == null ||
//         staffCallDuration!.data.calls.isEmpty ||
//         staffCallDuration!.data.summary.totalCalls == 0) {
//       return "--";
//     }

//     final totalDuration = parseDuration_build(
//             staffCallDuration!.data.summary.totalIncomingDuration) +
//         parseDuration_build(
//             staffCallDuration!.data.summary.totalOutgoingDuration);

//     final averageSeconds =
//         totalDuration.inSeconds / staffCallDuration!.data.summary.totalCalls;
//     final averageDuration = Duration(seconds: averageSeconds.round());

//     return formatDuration_build(averageDuration);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Timeline"),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.calendar_month),
//             onPressed: () async {
//               final DateTime initial = selectedDate;

//               final DateTime? picked = await showDatePicker(
//                 context: context,
//                 initialDate: initial,
//                 firstDate: DateTime(2020),
//                 lastDate: DateTime(2100),
//               );

//               if (picked != null) {
//                 setState(() {
//                   selectedDate = picked;
//                   currentDate = DateFormat('yyyy-MM-dd').format(picked);
//                   groupedItems.clear();
//                 });
//                 getCallDuration();
//               }
//             },
//           ),
//         ],
//       ),
//       body: staffCallDuration == null
//           ? const Center(child: CircularProgressIndicator())
//           : Stack(
//               children: [
//                 GestureDetector(
//                   onTap: () {
//                     if (_isPanelOpen) _togglePanel();
//                     if (_isLeftPanelOpen) _toggleLeftPanel();
//                   },
//                   child: AbsorbPointer(
//                     absorbing: _isPanelOpen || _isLeftPanelOpen,
//                     child: SingleChildScrollView(
//                       padding: const EdgeInsets.all(12.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           buildBottomSummarySection(staffCallDuration!),
//                           const SizedBox(height: 16),
//                           buildLogoutTimeRow(),
//                           ListView.builder(
//                             itemCount: groupedItems.keys.length,
//                             shrinkWrap: true,
//                             physics: const NeverScrollableScrollPhysics(),
//                             itemBuilder: (context, index) {
//                               final date = groupedItems.keys.toList()[index];
//                               final entries = groupedItems[date]!;
//                               return Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Row(
//                                     children: [
//                                       CircleAvatar(
//                                         radius: 25,
//                                         backgroundColor: Colors.green,
//                                         child: Text(
//                                           formatDateHeader(date),
//                                           style: const TextStyle(
//                                               color: Colors.white),
//                                           textAlign: TextAlign.center,
//                                         ),
//                                       ),
//                                       const SizedBox(width: 12),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 20),
//                                   ...entries.map(buildTimelineItem),
//                                 ],
//                               );
//                             },
//                           ),
//                           const SizedBox(height: 16),
//                           buildLoginTimeBox(),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 AnimatedPositioned(
//                   duration: const Duration(milliseconds: 300),
//                   curve: Curves.easeInOut,
//                   right: _panelPosition,
//                   top: 0,
//                   bottom: 0,
//                   width: _panelWidth,
//                   child: GestureDetector(
//                     onHorizontalDragUpdate: (details) {
//                       if (details.delta.dx < 0) {
//                         setState(() {
//                           _panelPosition = (_panelPosition - details.delta.dx)
//                               .clamp(-_panelWidth, 0.0);
//                         });
//                       } else if (details.delta.dx > 0) {
//                         setState(() {
//                           _panelPosition = (_panelPosition - details.delta.dx)
//                               .clamp(-_panelWidth, 0.0);
//                         });
//                       }
//                     },
//                     onHorizontalDragEnd: (details) {
//                       if (details.primaryVelocity! < 0) {
//                         _togglePanel();
//                       } else if (details.primaryVelocity! > 0) {
//                         _togglePanel();
//                       } else {
//                         if (_panelPosition.abs() > _panelWidth / 2) {
//                           _togglePanel();
//                         } else {
//                           _togglePanel();
//                         }
//                       }
//                     },
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.2),
//                             blurRadius: 8,
//                             offset: const Offset(-3, 0),
//                           ),
//                         ],
//                       ),
//                       child: _buildTimeSummaryPanel(token),
//                     ),
//                   ),
//                 ),
//                 AnimatedPositioned(
//                   duration: const Duration(milliseconds: 300),
//                   curve: Curves.easeInOut,
//                   left: _leftPanelPosition,
//                   top: 0,
//                   bottom: 0,
//                   width: _leftPanelWidth,
//                   child: GestureDetector(
//                     onHorizontalDragUpdate: (details) {
//                       if (details.delta.dx > 0) {
//                         setState(() {
//                           _leftPanelPosition =
//                               (_leftPanelPosition + details.delta.dx)
//                                   .clamp(-_leftPanelWidth, 0.0);
//                         });
//                       } else if (details.delta.dx < 0) {
//                         setState(() {
//                           _leftPanelPosition =
//                               (_leftPanelPosition + details.delta.dx)
//                                   .clamp(-_leftPanelWidth, 0.0);
//                         });
//                       }
//                     },
//                     onHorizontalDragEnd: (details) {
//                       if (details.primaryVelocity! > 0) {
//                         _toggleLeftPanel();
//                       } else if (details.primaryVelocity! < 0) {
//                         _toggleLeftPanel();
//                       } else {
//                         if (_leftPanelPosition.abs() > _leftPanelWidth / 2) {
//                           _toggleLeftPanel();
//                         } else {
//                           _toggleLeftPanel();
//                         }
//                       }
//                     },
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.2),
//                             blurRadius: 8,
//                             offset: const Offset(3, 0),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 if (!_isPanelOpen)
//                   Positioned(
//                     right: 0,
//                     top: MediaQuery.of(context).size.height / 2 - 50,
//                     child: GestureDetector(
//                       onTap: _togglePanel,
//                       child: Container(
//                         width: 24,
//                         height: 100,
//                         decoration: BoxDecoration(
//                           color: Colors.blue,
//                           borderRadius: const BorderRadius.only(
//                             topLeft: Radius.circular(12),
//                             bottomLeft: Radius.circular(12),
//                           ),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.2),
//                               blurRadius: 4,
//                               offset: const Offset(-2, 0),
//                             ),
//                           ],
//                         ),
//                         child: const Center(
//                           child: Icon(
//                             Icons.chevron_left,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//     );
//   }
// }

///above code is old design
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/core/app_colors.dart'; 
import 'package:login2/screens/leadManagement/login_summary_page.dart';
import '../../models/staff_report/staff_calls_model.dart';
import '../../service/service.dart';

class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  late String staffId;
  late String currentDate;
  late DateTime selectedDate;

  StaffCallDuration? staffCallDuration;
  Map<String, List<Call>> groupedItems = {};

  // Right panel variables
  bool _isPanelOpen = false;
  final double _panelWidth = 200.0;
  double _panelPosition = -200.0;

  // Left panel variables
  bool _isLeftPanelOpen = false;
  final double _leftPanelWidth = 200.0;
  double _leftPanelPosition = -200.0;
  String token = "";
  @override
  void initState() {
    super.initState();
    _initializeData();
    // Future.delayed(Duration.zero, () {
    //   final args =
    //       ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    //   staffId = args["staffId"] as String;

    //   selectedDate = args.containsKey("selectedDate")
    //       ? args["selectedDate"] as DateTime
    //       : DateTime.now();

    //   currentDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    //   getCallDuration();
    // });
  }

  Future<void> _initializeData() async {
    token = await Common.getSharedPref("token") ?? "";
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    staffId = args["staffId"] as String;

    selectedDate = args.containsKey("selectedDate")
        ? args["selectedDate"] as DateTime
        : DateTime.now();

    currentDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    await getCallDuration();
  }

  Future<void> getCallDuration() async {
    staffCallDuration =
        await HttpService.getStaffCallDuration(staffId, currentDate);
    if (staffCallDuration != null && staffCallDuration!.status == true) {
      for (var call in staffCallDuration!.data.calls) {
        String dateStr = call.calledDate.split(' ')[0];
        groupedItems.putIfAbsent(dateStr, () => []).add(call);
      }
      setState(() {});
    }
  }

  void _togglePanel() {
    setState(() {
      _isPanelOpen = !_isPanelOpen;
      _panelPosition = _isPanelOpen ? 0 : -_panelWidth;
    });
  }

  void _toggleLeftPanel() {
    setState(() {
      _isLeftPanelOpen = !_isLeftPanelOpen;
      _leftPanelPosition = _isLeftPanelOpen ? 0 : -_leftPanelWidth;
    });
  }

  String formatDateHeader(String dateStr) {
    final date = DateFormat('dd-MM-yyyy').parse(dateStr);
    return DateFormat('dd MMM').format(date).toUpperCase();
  }

  // ------------------------------------------------------------------
  // UI helpers (presentation only)
  // ------------------------------------------------------------------
  BoxDecoration _cardDecoration({double radius = 14}) => BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      );

  Widget buildTimelineItem(Call call) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // timeline rail
          SizedBox(
            width: 16,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    color: AppColors.present,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.card, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.tint(AppColors.present, 0.35),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
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
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: _cardDecoration(),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 20,
                          backgroundImage: AssetImage(
                              'assets/icons/profile_placeholder.png'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                call.name,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.phone_rounded,
                                      size: 13, color: AppColors.textGrey),
                                  const SizedBox(width: 4),
                                  Text(
                                    call.phone,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textMedium,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.softGrey,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _callDetailLine(
                                      Icons.event_rounded,
                                      "Called Date : ${call.calledDate}",
                                    ),
                                    const SizedBox(height: 4),
                                    _callDetailLine(
                                      Icons.schedule_rounded,
                                      "Called Time : ${call.calledTime}",
                                    ),
                                    const SizedBox(height: 4),
                                    _callDetailLine(
                                      Icons.timer_outlined,
                                      "Called Duration : ${call.duration}",
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 10),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            call.callType,
                            style: const TextStyle(
                              color: AppColors.textOnColor,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _tagBox("Ideal Time", AppColors.textDark,
                          icon: Icons.hourglass_empty_rounded),
                      const SizedBox(width: 8),
                      _tagBox(call.idealTime, AppColors.danger),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _callDetailLine(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textGrey),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: AppColors.textMedium),
          ),
        ),
      ],
    );
  }

  Widget buildLoginTimeBox() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.present,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.tint(AppColors.present, 0.35),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.login_rounded,
                size: 18, color: AppColors.textOnColor),
            const SizedBox(width: 8),
            Text(
              'Login Time: ${staffCallDuration?.data.summary.startTime ?? "N/A"}',
              style: const TextStyle(
                color: AppColors.textOnColor,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLogoutTimeRow() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.tint(AppColors.danger, 0.35),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.logout_rounded,
                size: 18, color: AppColors.textOnColor),
            const SizedBox(width: 8),
            Text(
              'Logout Time: ${staffCallDuration?.data.summary.endTime ?? "N/A"}',
              style: const TextStyle(
                color: AppColors.textOnColor,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tagBox(String text, Color color, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.tint(color),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Duration parseDuration(String time) {
    final parts = time.split(':').map(int.parse).toList();
    if (parts.length != 3) return Duration.zero;
    return Duration(hours: parts[0], minutes: parts[1], seconds: parts[2]);
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inHours)}:${twoDigits(duration.inMinutes % 60)}:${twoDigits(duration.inSeconds % 60)}";
  }

  Widget buildBottomSummarySection(StaffCallDuration staffCallDuration) {
    final summary = staffCallDuration.data.summary;
    final incoming = parseDuration(summary.totalIncomingDuration);
    final outgoing = parseDuration(summary.totalOutgoingDuration);
    final totalDuration = incoming + outgoing;

    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildInfoCard(
                "WORK TIME",
                "START TIME : ${summary.startTime}\nEND TIME : ${summary.endTime}",
                Icons.schedule,
                AppColors.primary,
              ),
              const SizedBox(width: 10),
              buildInfoCard(
                "TOTAL TIME DURATION",
                "INCOMING : ${summary.totalIncomingDuration}\n"
                    "OUTGOING : ${summary.totalOutgoingDuration}\n"
                    "TOTAL: ${formatDuration(totalDuration)}",
                Icons.timelapse,
                AppColors.todo,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildInfoCard(
                "TOTAL FREE TIME",
                "🛑 IDEAL : ${summary.totalIdealTime}\n☕BREAK :00min,0secs\nTOTAL: ${summary.totalIdealTime}",
                Icons.free_breakfast,
                AppColors.pending,
              ),
              const SizedBox(width: 10),
              buildInfoCard(
                "TOTAL CONNECTED CALLS",
                "TOTAL: ${summary.totalCalls}\nCONNECTED: ${summary.totalCalls}\nMISSED: 0",
                Icons.call,
                AppColors.success,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildInfoCard(String title, String content, IconData icon,
      [Color color = AppColors.primary]) {
    final lines = content.split('\n');
    return Expanded(
      child: Container(
        decoration: _cardDecoration(),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.tint(color),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...lines.map((line) {
              final idx = line.indexOf(':');
              if (idx == -1) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    line,
                    style: const TextStyle(
                        fontSize: 12.5, color: AppColors.textMedium),
                  ),
                );
              }
              final key = line.substring(0, idx).trim();
              final value = line.substring(idx + 1).trim();
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        key,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // Widget _buildTimeSummaryItem(
  //     String label, String value, IconData icon, Color color) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
  //     margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
  //     decoration: BoxDecoration(
  //       color: Colors.grey.shade100,
  //       borderRadius: BorderRadius.circular(8),
  //     ),
  //     child: Row(
  //       children: [
  //         Icon(icon, color: color),
  //         const SizedBox(width: 12),
  //         Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               label,
  //               style: const TextStyle(
  //                 fontSize: 12,
  //                 color: Colors.black54,
  //               ),
  //             ),
  //             Text(
  //               value,
  //               style: const TextStyle(
  //                 fontSize: 14,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }
  Widget _buildTimeSummaryItem(
    String label,
    String value,
    IconData icon,
    Color color, {
    VoidCallback? onTap, // only passed for "Login"
  }) {
    final isClickable = onTap != null;

    final content = Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.tint(color),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textGrey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
          if (isClickable)
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppColors.textLight),
        ],
      ),
    );

    return isClickable
        ? InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: content,
          )
        : content;
  }

  Duration parseDuration_build(String time) {
    final parts = time.split(':').map(int.parse).toList();
    if (parts.length == 3) {
      return Duration(hours: parts[0], minutes: parts[1], seconds: parts[2]);
    } else if (parts.length == 2) {
      return Duration(minutes: parts[0], seconds: parts[1]);
    }
    return Duration.zero;
  }

  String formatDuration_build(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inHours)}:"
        "${twoDigits(duration.inMinutes.remainder(60))}:"
        "${twoDigits(duration.inSeconds.remainder(60))}";
  }

  Widget _buildTimeSummaryPanel(String token) {
    final summary = staffCallDuration?.data.summary;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
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
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                children: [
                  // _buildTimeSummaryItem(
                  //   "Login",
                  //   summary?.startTime ?? "--",
                  //   Icons.login,
                  //   Colors.green,
                  // ),
                  _buildTimeSummaryItem(
                    "Login",
                    summary?.startTime ?? "--",
                    Icons.login,
                    AppColors.present,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginSummaryPage(
                            staffId: staffId,
                            token: token,
                            date: selectedDate ?? DateTime.now(),
                          ),
                        ),
                      );
                    },
                  ),
                  _buildTimeSummaryItem(
                    "Work Time",
                    summary != null
                        ? formatDuration_build(
                            parseDuration_build(summary.totalIncomingDuration) +
                                parseDuration_build(
                                    summary.totalOutgoingDuration),
                          )
                        : "--",
                    Icons.timer,
                    AppColors.todo,
                  ),
                  _buildTimeSummaryItem(
                    "Ideal",
                    summary?.totalIdealTime ?? "--",
                    Icons.hourglass_empty,
                    AppColors.pending,
                  ),

                  _buildTimeSummaryItem(
                    "Loggedin Time",
                    "--",
                    Icons.login,
                    AppColors.pending,
                  ),
                  // _buildTimeSummaryItem(
                  //   "Break",
                  //   summary?.totalIdealTime ?? "--",
                  //   Icons.free_breakfast,
                  //   Colors.blue,
                  // ),
                  _buildTimeSummaryItem(
                    "Logout",
                    summary?.endTime ?? "--",
                    Icons.logout,
                    AppColors.danger,
                  ),
                  // _buildTimeSummaryItem(
                  //   "Total",
                  //   summary != null
                  //       ? formatDuration_build(
                  //           parseDuration_build(summary.totalIncomingDuration) +
                  //               parseDuration_build(
                  //                   summary.totalOutgoingDuration),
                  //         )
                  //       : "--",
                  //   Icons.timer,
                  //   Colors.purple,
                  // ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _calculateAverageCallDuration() {
    if (staffCallDuration == null ||
        staffCallDuration!.data.calls.isEmpty ||
        staffCallDuration!.data.summary.totalCalls == 0) {
      return "--";
    }

    final totalDuration = parseDuration_build(
            staffCallDuration!.data.summary.totalIncomingDuration) +
        parseDuration_build(
            staffCallDuration!.data.summary.totalOutgoingDuration);

    final averageSeconds =
        totalDuration.inSeconds / staffCallDuration!.data.summary.totalCalls;
    final averageDuration = Duration(seconds: averageSeconds.round());

    return formatDuration_build(averageDuration);
  }

  @override
  Widget build(BuildContext context) {
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
          "Timeline",
          style: TextStyle(
            color: AppColors.textOnColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () async {
              final DateTime initial = selectedDate;

              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: initial,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );

              if (picked != null) {
                setState(() {
                  selectedDate = picked;
                  currentDate = DateFormat('yyyy-MM-dd').format(picked);
                  groupedItems.clear();
                });
                getCallDuration();
              }
            },
          ),
        ],
      ),
      body: staffCallDuration == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    if (_isPanelOpen) _togglePanel();
                    if (_isLeftPanelOpen) _toggleLeftPanel();
                  },
                  child: AbsorbPointer(
                    absorbing: _isPanelOpen || _isLeftPanelOpen,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildBottomSummarySection(staffCallDuration!),
                          const SizedBox(height: 16),
                          buildLogoutTimeRow(),
                          const SizedBox(height: 16),
                          if (groupedItems.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 28),
                              decoration: _cardDecoration(),
                              child: Column(
                                children: [
                                  Icon(Icons.phone_disabled_rounded,
                                      size: 44,
                                      color: AppColors.tint(
                                          AppColors.primary, 0.35)),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'No calls found',
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ListView.builder(
                            itemCount: groupedItems.keys.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final date = groupedItems.keys.toList()[index];
                              final entries = groupedItems[date]!;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 8),
                                        decoration: BoxDecoration(
                                          gradient: AppColors.primaryGradient,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                                Icons.calendar_today_rounded,
                                                size: 14,
                                                color: AppColors.textOnColor),
                                            const SizedBox(width: 6),
                                            Text(
                                              formatDateHeader(date),
                                              style: const TextStyle(
                                                color: AppColors.textOnColor,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 13,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  ...entries.map(buildTimelineItem),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          buildLoginTimeBox(),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
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
                        setState(() {
                          _panelPosition = (_panelPosition - details.delta.dx)
                              .clamp(-_panelWidth, 0.0);
                        });
                      } else if (details.delta.dx > 0) {
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
                      child: _buildTimeSummaryPanel(token),
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  left: _leftPanelPosition,
                  top: 0,
                  bottom: 0,
                  width: _leftPanelWidth,
                  child: GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      if (details.delta.dx > 0) {
                        setState(() {
                          _leftPanelPosition =
                              (_leftPanelPosition + details.delta.dx)
                                  .clamp(-_leftPanelWidth, 0.0);
                        });
                      } else if (details.delta.dx < 0) {
                        setState(() {
                          _leftPanelPosition =
                              (_leftPanelPosition + details.delta.dx)
                                  .clamp(-_leftPanelWidth, 0.0);
                        });
                      }
                    },
                    onHorizontalDragEnd: (details) {
                      if (details.primaryVelocity! > 0) {
                        _toggleLeftPanel();
                      } else if (details.primaryVelocity! < 0) {
                        _toggleLeftPanel();
                      } else {
                        if (_leftPanelPosition.abs() > _leftPanelWidth / 2) {
                          _toggleLeftPanel();
                        } else {
                          _toggleLeftPanel();
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
                            offset: const Offset(3, 0),
                          ),
                        ],
                      ),
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
    );
  }
}

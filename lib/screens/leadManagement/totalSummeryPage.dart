// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:login2/models/expense/staffListModel.dart';
// import 'dart:async';

// import 'package:login2/models/lead_management/staffCallSummaryModel.dart';
// import 'package:login2/models/lead_management/staffWorkSummaryModel.dart';
// import 'package:login2/screens/leadManagement/AssignReport.dart';
// import 'package:login2/service/service.dart';
// import 'package:login2/widgets/work_timer_overlay.dart';

// class TotalSummeryPage extends StatefulWidget {
//   const TotalSummeryPage({super.key});

//   @override
//   State<TotalSummeryPage> createState() => _TotalSummeryPageState();
// }

// class _TotalSummeryPageState extends State<TotalSummeryPage>
//     with TickerProviderStateMixin {
//   late DateTime selectedDate;
//   late TabController _tabController;

//   List<StaffWork> allStaffWorks = [];
//   List<StaffCalls> allStaffCalls = [];
//   List<StaffWork> filteredStaffWorks = [];
//   List<StaffCalls> filteredStaffCalls = [];
//   List<Staff> allStaffs = [];
//   String selectedStaffName = 'All Staff';
//   String? selectedStaffId;
//   String searchQuery = '';

//   bool isLoadingWorks = true;
//   bool isLoadingCalls = true;
//   bool isLoadingStaffs = true;
//   bool showSearchField = false;

//   late AnimationController _blinkController;
//   final ScrollController _staffListController = ScrollController();

//   @override
//   void initState() {
//     super.initState();
//     selectedDate = DateTime.now();
//     _tabController = TabController(length: 2, vsync: this);
//     _blinkController = AnimationController(
//       duration: const Duration(seconds: 1),
//       vsync: this,
//     )..repeat(reverse: true);
//     fetchStaffs(selectedDate);
//     fetchDoneWorks(selectedDate);
//     fetchDoneCalls(selectedDate);
//   }

//   @override
//   void dispose() {
//     _blinkController.dispose();
//     _staffListController.dispose();
//     super.dispose();
//   }

//   Future<void> fetchStaffs(DateTime date) async {
//     final formattedDate = DateFormat('yyyy-MM-dd').format(date);
//     setState(() => isLoadingStaffs = true);
//     try {
//       final response = await HttpService.getWorkedStaffs(formattedDate);
//       if (response != null && response.status) {
//         setState(() {
//           allStaffs = response.data;
//           // Add "All Staff" option at the beginning
//           allStaffs.insert(
//               0,
//               Staff(
//                 id: '',
//                 name: 'All Staff',
//                 userIdStaff: '',
//               ));
//         });
//       }
//     } catch (e) {
//       print("Error fetching staffs: $e");
//     } finally {
//       setState(() => isLoadingStaffs = false);
//     }
//   }

//   Future<void> fetchDoneWorks(DateTime date) async {
//     final formattedDate = DateFormat('yyyy-MM-dd').format(date);
//     setState(() => isLoadingWorks = true);
//     try {
//       final response = await HttpService.getAllDoneworks(formattedDate);
//       if (response != null) {
//         setState(() {
//           allStaffWorks = response.data;
//           _filterData();
//         });
//       }
//     } catch (e) {
//       print("Error fetching done works: $e");
//     } finally {
//       setState(() => isLoadingWorks = false);
//     }
//   }

//   Future<void> fetchDoneCalls(DateTime date) async {
//     final formattedDate = DateFormat('yyyy-MM-dd').format(date);
//     setState(() => isLoadingCalls = true);
//     try {
//       final response = await HttpService.getAllDonecalls(formattedDate);
//       if (response != null) {
//         setState(() {
//           allStaffCalls = response.data;
//           _filterData();
//         });
//       }
//     } catch (e) {
//       print("Error fetching done calls: $e");
//     } finally {
//       setState(() => isLoadingCalls = false);
//     }
//   }

//   Future<void> _handleRefresh() async {
//     await Future.wait([
//       fetchStaffs(selectedDate),
//       fetchDoneWorks(selectedDate),
//       fetchDoneCalls(selectedDate),
//     ]);
//   }

//   void _filterData() {
//     // First filter by selected staff
//     if (selectedStaffName == 'All Staff') {
//       filteredStaffWorks = List.from(allStaffWorks);
//       filteredStaffCalls = List.from(allStaffCalls);
//     } else {
//       filteredStaffWorks = allStaffWorks
//           .where((staff) => staff.staffName == selectedStaffName)
//           .toList();
//       filteredStaffCalls = allStaffCalls
//           .where((staff) => staff.staffName == selectedStaffName)
//           .toList();
//     }

//     // Then apply search filter if searchQuery is not empty
//     if (searchQuery.isNotEmpty) {
//       filteredStaffWorks = filteredStaffWorks
//           .where((staff) =>
//               staff.staffName.toLowerCase().contains(searchQuery.toLowerCase()))
//           .toList();
//       filteredStaffCalls = filteredStaffCalls
//           .where((staff) =>
//               staff.staffName.toLowerCase().contains(searchQuery.toLowerCase()))
//           .toList();
//     }
//   }

//   void _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: selectedDate,
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2100),
//     );
//     if (picked != null && picked != selectedDate) {
//       setState(() {
//         selectedDate = picked;
//       });
//       fetchStaffs(selectedDate);
//       fetchDoneWorks(selectedDate);
//       fetchDoneCalls(selectedDate);
//     }
//   }

//   String getFormattedDisplayDate() {
//     return DateFormat('dd-MM-yyyy').format(selectedDate);
//   }

//   /// Modified to handle isCompleted check
//   Widget buildStatusText(String status, String isCompleted) {
//     // ✅ Custom condition: if isCompleted is 1
//     if (isCompleted == "1") {
//       // First resolve the status label from the status code
//       String label;
//       switch (status) {
//         case '1':
//           label = 'To-do';
//           break;
//         case '2':
//           label = 'Pending';
//           break;
//         case '3':
//           label = 'Completed';
//           break;
//         case '4':
//           label = 'Running';
//           break;
//         case '5':
//           label = 'Cancelled';
//           break;
//         default:
//           label = 'Unknown';
//       }

//       return Column(
//         children: [
//           Text(
//             label,
//             style: const TextStyle(
//               decoration: TextDecoration.lineThrough, // 🔥 cut line
//               color: Colors.red,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 4),
//           const Text(
//             "Completed",
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Colors.green,
//             ),
//           ),
//         ],
//       );
//     }

//     Color color;
//     String label;

//     switch (status) {
//       case '1':
//         color = const Color.fromARGB(255, 56, 148, 235);
//         label = 'To-do';
//         break;
//       case '2':
//         color = const Color.fromARGB(255, 227, 143, 34);
//         label = 'Pending';
//         break;
//       case '3':
//         color = Colors.green;
//         label = 'Completed';
//         break;
//       case '4':
//         color = const Color.fromARGB(255, 200, 181, 37);
//         label = 'Running';
//         break;
//       case '5':
//         color = const Color.fromARGB(255, 235, 69, 69);
//         label = 'Cancelled';
//         break;
//       default:
//         color = Colors.grey;
//         label = 'Unknown';
//     }

//     if (status == '1' || status == '2') {
//       return AnimatedBuilder(
//         animation: _blinkController,
//         builder: (context, child) {
//           return Opacity(
//             opacity: _blinkController.value,
//             child: Text(
//               label,
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             ),
//           );
//         },
//       );
//     }

//     return Text(
//       label,
//       style: TextStyle(fontWeight: FontWeight.bold, color: color),
//     );
//   }

//   Color _getStatusBackgroundColor(String status, String isCompleted) {
//     if (isCompleted == "1") {
//       return Colors.green.shade50;
//     }
//     switch (status) {
//       case '1': // To-do
//         return Colors.blue.shade50;
//       case '2': // Pending
//         return Colors.orange.shade50;
//       case '3': // Completed
//         return Colors.green.shade50;
//       case '4': // Running
//         return Colors.yellow.shade50;
//       case '5': // Cancelled
//         return Colors.red.shade50;
//       default:
//         return Colors.grey.shade50;
//     }
//   }

//   void _showSmallStaffPopup(BuildContext context) {
//     final RenderBox button = context.findRenderObject() as RenderBox;
//     final RenderBox overlay =
//         Overlay.of(context).context.findRenderObject() as RenderBox;
//     final RelativeRect position = RelativeRect.fromRect(
//       Rect.fromPoints(
//         button.localToGlobal(Offset.zero, ancestor: overlay),
//         button.localToGlobal(button.size.bottomRight(Offset.zero),
//             ancestor: overlay),
//       ),
//       Offset.zero & overlay.size,
//     );
//     TextEditingController searchController = TextEditingController();
//     bool showAll = false;
//     String searchQuery = '';
//     showDialog(
//       context: context,
//       barrierDismissible: true,
//       barrierColor: Colors.transparent,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setDialogState) {
//             List<Staff> filteredStaffs = allStaffs.where((staff) {
//               if (searchQuery.isEmpty) return true;
//               return staff.name
//                   .toLowerCase()
//                   .contains(searchQuery.toLowerCase());
//             }).toList();
//             final itemsToShow = showAll ? filteredStaffs.length : 15;
//             final displayStaffs = filteredStaffs.take(itemsToShow).toList();
//             return Stack(
//               children: [
//                 Positioned(
//                   top: position.top + 30,
//                   right: 8,
//                   child: Material(
//                     elevation: 8,
//                     borderRadius: BorderRadius.circular(8),
//                     child: Container(
//                       width: 200,
//                       height: 400,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(8),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.1),
//                             blurRadius: 10,
//                             offset: const Offset(0, 4),
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(12),
//                             decoration: BoxDecoration(
//                               color: Colors.blue.shade50,
//                               borderRadius: const BorderRadius.only(
//                                 topLeft: Radius.circular(8),
//                                 topRight: Radius.circular(8),
//                               ),
//                               border: Border(
//                                 bottom: BorderSide(color: Colors.grey.shade300),
//                               ),
//                             ),
//                             child: Row(
//                               children: [
//                                 const Icon(Icons.search,
//                                     size: 20, color: Colors.blue),
//                                 const SizedBox(width: 8),
//                                 Expanded(
//                                   child: TextField(
//                                     controller: searchController,
//                                     decoration: const InputDecoration(
//                                       hintText: 'Search staff...',
//                                       border: InputBorder.none,
//                                       isDense: true,
//                                       contentPadding: EdgeInsets.zero,
//                                     ),
//                                     autofocus: true,
//                                     style: const TextStyle(fontSize: 14),
//                                     onChanged: (value) {
//                                       setDialogState(() {
//                                         searchQuery = value;
//                                         showAll = false;
//                                       });
//                                     },
//                                   ),
//                                 ),
//                                 IconButton(
//                                   icon: const Icon(Icons.close, size: 18),
//                                   onPressed: () => Navigator.pop(context),
//                                   padding: EdgeInsets.zero,
//                                   constraints: const BoxConstraints(),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Expanded(
//                             child: filteredStaffs.isEmpty
//                                 ? const Center(
//                                     child: Padding(
//                                       padding: EdgeInsets.all(20.0),
//                                       child: Text(
//                                         'No staff found',
//                                         style: TextStyle(
//                                           fontSize: 14,
//                                           color: Colors.grey,
//                                         ),
//                                       ),
//                                     ),
//                                   )
//                                 : ListView.builder(
//                                     padding: const EdgeInsets.all(0),
//                                     itemCount: displayStaffs.length,
//                                     itemBuilder: (context, index) {
//                                       final staff = displayStaffs[index];
//                                       return InkWell(
//                                         onTap: () {
//                                           setState(() {
//                                             selectedStaffName = staff.name;
//                                             selectedStaffId = staff.userIdStaff;
//                                             _filterData();
//                                           });
//                                           Navigator.pop(context);
//                                         },
//                                         child: Container(
//                                           padding: const EdgeInsets.symmetric(
//                                             horizontal: 16,
//                                             vertical: 12,
//                                           ),
//                                           decoration: BoxDecoration(
//                                             border: Border(
//                                               bottom: BorderSide(
//                                                 color: Colors.grey.shade200,
//                                               ),
//                                             ),
//                                           ),
//                                           child: Text(
//                                             staff.name,
//                                             style:
//                                                 const TextStyle(fontSize: 14),
//                                             maxLines: 1,
//                                             overflow: TextOverflow.ellipsis,
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                   ),
//                           ),
//                           if (filteredStaffs.length > 15)
//                             Container(
//                               padding: const EdgeInsets.symmetric(vertical: 8),
//                               decoration: BoxDecoration(
//                                 border: Border(
//                                   top: BorderSide(color: Colors.grey.shade300),
//                                 ),
//                               ),
//                               child: InkWell(
//                                 onTap: () {
//                                   setDialogState(() {
//                                     showAll = !showAll;
//                                   });
//                                 },
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Text(
//                                       showAll
//                                           ? 'Show Less'
//                                           : 'View More (${filteredStaffs.length - 15})',
//                                       style: const TextStyle(
//                                         fontSize: 13,
//                                         color: Colors.blue,
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                     ),
//                                     const SizedBox(width: 4),
//                                     Icon(
//                                       showAll
//                                           ? Icons.arrow_drop_up
//                                           : Icons.arrow_drop_down,
//                                       size: 16,
//                                       color: Colors.blue,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildStaffList() {
//     if (isLoadingStaffs) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     return Row(
//       children: [
//         Expanded(
//           child: ListView.builder(
//             controller: _staffListController,
//             scrollDirection: Axis.horizontal,
//             itemCount: allStaffs.length,
//             itemBuilder: (context, index) {
//               final staff = allStaffs[index];
//               final isSelected = staff.name == selectedStaffName;

//               return GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     selectedStaffName = staff.name;
//                     selectedStaffId = staff.userIdStaff;
//                     _filterData();
//                   });
//                 },
//                 child: Container(
//                   margin: EdgeInsets.only(
//                     left: index == 0 ? 0 : 8,
//                     right: index == allStaffs.length - 1 ? 8 : 0,
//                     top: 8,
//                     bottom: 8,
//                   ),
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 5,
//                     vertical: 8,
//                   ),
//                   decoration: BoxDecoration(
//                     color: isSelected
//                         ? const Color.fromARGB(255, 77, 155, 228)
//                         : Colors.grey.shade200,
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(
//                       color: isSelected
//                           ? const Color.fromARGB(255, 77, 155, 228)
//                           : Colors.grey.shade300,
//                       width: 1,
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       CircleAvatar(
//                         radius: 12,
//                         backgroundColor: isSelected
//                             ? Colors.white
//                             : const Color.fromARGB(255, 77, 155, 228),
//                         child: Text(
//                           staff.name.isNotEmpty
//                               ? staff.name[0].toUpperCase()
//                               : '?',
//                           style: TextStyle(
//                             fontSize: 10,
//                             fontWeight: FontWeight.bold,
//                             color: isSelected
//                                 ? const Color.fromARGB(255, 77, 155, 228)
//                                 : Colors.white,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         staff.name,
//                         style: TextStyle(
//                           fontSize: 13,
//                           fontWeight: FontWeight.w500,
//                           color: isSelected ? Colors.white : Colors.black87,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//         Builder(
//           builder: (context) => IconButton(
//             icon: const Icon(
//               Icons.person,
//               color: Color.fromARGB(255, 77, 155, 228),
//               size: 24,
//             ),
//             onPressed: () => _showSmallStaffPopup(context),
//             tooltip: 'Filter Staff',
//             padding: EdgeInsets.zero,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSearchField() {
//     return TextField(
//       controller: TextEditingController(text: searchQuery),
//       decoration: InputDecoration(
//         hintText: "Search by staff name...",
//         prefixIcon: const Icon(Icons.search),
//         suffixIcon: IconButton(
//           icon: const Icon(Icons.close),
//           onPressed: () {
//             setState(() {
//               searchQuery = '';
//               _filterData();
//             });
//           },
//         ),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
//       ),
//       onChanged: (value) {
//         setState(() {
//           searchQuery = value;
//           _filterData();
//         });
//       },
//     );
//   }

//   Widget buildWorkTab() {
//     if (isLoadingWorks) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (filteredStaffWorks.isEmpty) {
//       return RefreshIndicator(
//         onRefresh: _handleRefresh,
//         child: ListView(
//           children: [
//             SizedBox(
//               height: MediaQuery.of(context).size.height * 0.6,
//               child: Center(
//                 child: Text(
//                   selectedStaffName == 'All Staff'
//                       ? "No work found"
//                       : "No work found for $selectedStaffName",
//                   style: const TextStyle(fontSize: 16, color: Colors.grey),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     return RefreshIndicator(
//       onRefresh: _handleRefresh,
//       child: ListView.builder(
//         itemCount: filteredStaffWorks.length,
//         itemBuilder: (context, index) {
//           final staff = filteredStaffWorks[index];
//           return Card(
//             margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             elevation: 4,
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     staff.staffName,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.indigo,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       Chip(
//                         backgroundColor: Colors.green.shade50,
//                         label: Text("Login: ${staff.loginTime}",
//                             style: const TextStyle(color: Colors.green)),
//                       ),
//                       const SizedBox(width: 8),
//                       Chip(
//                         backgroundColor: Colors.red.shade50,
//                         label: Text("Logout: ${staff.logoutTime}",
//                             style: const TextStyle(color: Colors.red)),
//                       ),
//                     ],
//                   ),
//                   ...staff.projects.map((project) {
//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         GestureDetector(
//                           // onTap: () {
//                           //   Navigator.push(
//                           //     context,
//                           //     MaterialPageRoute(
//                           //       builder: (context) => AssignReport(
//                           //         workId: project.projectId,
//                           //         sectionId: "",
//                           //       ),
//                           //     ),
//                           //   );
//                           // },
//                           child: Text(
//                             "${project.customerName ?? "No title"} [${project.projectName}]",
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                         // const SizedBox(height: 12),
//                         // Text(
//                         //   "Module: ${project.moduleName}",
//                         //   style: const TextStyle(
//                         //     fontSize: 14,
//                         //     fontWeight: FontWeight.w600,
//                         //   ),
//                         // ),
//                         const SizedBox(height: 12),
//                         Column(
//                           children: project.tasks.map((task) {
//                             final isCompleted =
//                                 task.status.toLowerCase() == "completed";
//                             final bgColor = _getStatusBackgroundColor(
//                                 task.status, task.isCompleted);

//                             return IntrinsicHeight(
//                               child: Row(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Column(
//                                     children: [
//                                       Container(
//                                         width: 24,
//                                         alignment: Alignment.center,
//                                         child: Icon(
//                                           isCompleted
//                                               ? Icons.check_circle
//                                               : Icons.access_time,
//                                           color: isCompleted
//                                               ? Colors.green
//                                               : const Color.fromARGB(
//                                                   255, 238, 141, 31),
//                                           size: 20,
//                                         ),
//                                       ),
//                                       if (project.tasks.last != task)
//                                         Expanded(
//                                           child: Container(
//                                             width: 2,
//                                             color: Colors.grey.shade300,
//                                           ),
//                                         ),
//                                     ],
//                                   ),
//                                   const SizedBox(width: 12),
//                                   Expanded(
//                                     child: GestureDetector(
//                                       onTap: () {
//                                         Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (context) => AssignReport(
//                                               workId: task.workId,
//                                               sectionId: "",
//                                             ),
//                                           ),
//                                         );
//                                       },
//                                       child: Container(
//                                         margin:
//                                             const EdgeInsets.only(bottom: 16),
//                                         padding: const EdgeInsets.all(12),
//                                         decoration: BoxDecoration(
//                                           color: bgColor,
//                                           borderRadius:
//                                               BorderRadius.circular(6),
//                                           border: Border.all(
//                                               color: Colors.grey.shade300),
//                                         ),
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               "Module: ${task.moduleName ?? 'N/A'}",
//                                               style: const TextStyle(
//                                                 fontSize: 14,
//                                                 fontWeight: FontWeight.w600,
//                                               ),
//                                             ),
//                                             const SizedBox(height: 15),
//                                             Text(
//                                               task.taskName,
//                                               style: const TextStyle(
//                                                   fontWeight: FontWeight.w600),
//                                             ),
//                                             const SizedBox(height: 8),
//                                             Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment
//                                                       .spaceBetween,
//                                               children: [
//                                                 Text(
//                                                   '${task.startTime} - ${task.endTime}',
//                                                   style: const TextStyle(
//                                                     fontSize: 12,
//                                                     color: Colors.black54,
//                                                   ),
//                                                 ),
//                                                 buildStatusText(
//                                                   task.status,
//                                                   task.isCompleted,
//                                                 ),
//                                               ],
//                                             ),
//                                             if (task.remarks.isNotEmpty) ...[
//                                               const SizedBox(height: 8),
//                                               Column(
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.start,
//                                                 children:
//                                                     task.remarks.map((remark) {
//                                                   return Padding(
//                                                     padding:
//                                                         const EdgeInsets.only(
//                                                             top: 6.0),
//                                                     child: Row(
//                                                       crossAxisAlignment:
//                                                           CrossAxisAlignment
//                                                               .start,
//                                                       children: [
//                                                         const Text(
//                                                           "• ",
//                                                           style: TextStyle(
//                                                             color:
//                                                                 Colors.black54,
//                                                           ),
//                                                         ),
//                                                         Expanded(
//                                                           child: Text(
//                                                             remark,
//                                                             style: TextStyle(
//                                                               color: Colors
//                                                                   .blueGrey
//                                                                   .shade700,
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   );
//                                                 }).toList(),
//                                               ),
//                                             ],
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           }).toList(),
//                         ),
//                         const Divider(thickness: 1, color: Colors.grey),
//                         const SizedBox(height: 12),
//                       ],
//                     );
//                   }),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget buildPhoneCallTab() {
//     if (isLoadingCalls) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (filteredStaffCalls.isEmpty) {
//       return RefreshIndicator(
//         onRefresh: _handleRefresh,
//         child: ListView(
//           children: [
//             SizedBox(
//               height: MediaQuery.of(context).size.height * 0.6,
//               child: Center(
//                 child: Text(
//                   selectedStaffName == 'All Staff'
//                       ? "No calls found"
//                       : "No calls found for $selectedStaffName",
//                   style: const TextStyle(fontSize: 16, color: Colors.grey),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     return RefreshIndicator(
//       onRefresh: _handleRefresh,
//       child: ListView.builder(
//         itemCount: filteredStaffCalls.length,
//         itemBuilder: (context, index) {
//           final staff = filteredStaffCalls[index];
//           final calls = staff.calls;

//           return Card(
//             margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             elevation: 4,
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         staff.staffName,
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.deepPurple,
//                         ),
//                       ),
//                       Chip(
//                         label: Text(
//                           "Total Called: ${staff.totalCalls}",
//                           style: const TextStyle(color: Colors.white),
//                         ),
//                         backgroundColor: Colors.deepPurple,
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       Chip(
//                         label: Text(
//                           "Login: ${staff.loginTime}",
//                           style: const TextStyle(color: Colors.green),
//                         ),
//                         backgroundColor: Colors.green.shade50,
//                       ),
//                       const SizedBox(width: 8),
//                       Chip(
//                         label: Text(
//                           "Logout: ${staff.logoutTime}",
//                           style: const TextStyle(color: Colors.red),
//                         ),
//                         backgroundColor: Colors.red.shade50,
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 12),
//                   ...calls.map((call) {
//                     return Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Column(
//                           children: [
//                             Container(
//                               width: 16,
//                               height: 16,
//                               decoration: const BoxDecoration(
//                                 color: Colors.teal,
//                                 shape: BoxShape.circle,
//                               ),
//                               child: const Icon(
//                                 Icons.phone,
//                                 size: 10,
//                                 color: Colors.white,
//                               ),
//                             ),
//                             Container(
//                               width: 2,
//                               height: 40,
//                               color: Colors.teal.shade200,
//                             ),
//                           ],
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Container(
//                             margin: const EdgeInsets.only(bottom: 12),
//                             padding: const EdgeInsets.all(12),
//                             decoration: BoxDecoration(
//                               color: Colors.teal.shade50,
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   call.name != "null" ?
//                                   call.name : "Unknown",
//                                   //call.name,
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 14,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   "Duration: ${call.duration}",
//                                   style: const TextStyle(
//                                     fontSize: 13,
//                                     color: Colors.black54,
//                                   ),
//                                 ),
//                                 if (call.startTime != null &&
//                                     call.endTime != null)
//                                   Text(
//                                     "Time: ${DateFormat('hh:mm a').format(call.startTime!)} - ${DateFormat('hh:mm a').format(call.endTime!)}",
//                                     style: const TextStyle(
//                                       fontSize: 12,
//                                       color: Colors.black45,
//                                     ),
//                                   ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     );
//                   }),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Work Summary'),
//         backgroundColor: const Color.fromARGB(255, 77, 155, 228),
//         foregroundColor: Colors.white,
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: const [
//             const Tab(
//               child: Text(
//                 'Work',
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//             const Tab(
//               child: Text(
//                 'Phonecall',
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.calendar_month),
//             onPressed: () => _selectDate(context),
//           ),
//           IconButton(
//             icon: Icon(showSearchField ? Icons.list : Icons.search),
//             onPressed: () {
//               setState(() {
//                 showSearchField = !showSearchField;
//                 if (!showSearchField) {
//                   searchQuery = '';
//                   _filterData();
//                 }
//               });
//             },
//           ),
//         ],
//       ),
//       body: WorkTimerOverlay(
//         onTimerReturn: _handleRefresh,
//         child: SafeArea(
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//               child: Row(
//                 children: [
//                   const Icon(Icons.calendar_today, color: Colors.indigo),
//                   const SizedBox(width: 8),
//                   Text(
//                     getFormattedDisplayDate(),
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const Spacer(),
//                   Text(
//                     selectedStaffName,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.indigo,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               child: showSearchField
//                   ? _buildSearchField()
//                   : SizedBox(
//                       height: 50,
//                       child: _buildStaffList(),
//                     ),
//             ),
//             const SizedBox(height: 8),
//             Expanded(
//               child: TabBarView(
//                 controller: _tabController,
//                 children: [
//                   buildWorkTab(),
//                   buildPhoneCallTab(),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/app_colors.dart';
import 'package:login2/models/expense/staffListModel.dart';
import 'dart:async';

import 'package:login2/models/lead_management/staffCallSummaryModel.dart';
import 'package:login2/models/lead_management/staffWorkSummaryModel.dart';
import 'package:login2/screens/leadManagement/AssignReport.dart';
import 'package:login2/service/service.dart';
import 'package:login2/widgets/work_timer_overlay.dart';

class TotalSummeryPage extends StatefulWidget {
  const TotalSummeryPage({super.key});

  @override
  State<TotalSummeryPage> createState() => _TotalSummeryPageState();
}

class _TotalSummeryPageState extends State<TotalSummeryPage>
    with TickerProviderStateMixin {
  late DateTime selectedDate;
  late TabController _tabController;

  List<StaffWork> allStaffWorks = [];
  List<StaffCalls> allStaffCalls = [];
  List<StaffWork> filteredStaffWorks = [];
  List<StaffCalls> filteredStaffCalls = [];
  List<Staff> allStaffs = [];
  String selectedStaffName = 'All Staff';
  String? selectedStaffId;
  String searchQuery = '';

  bool isLoadingWorks = true;
  bool isLoadingCalls = true;
  bool isLoadingStaffs = true;
  bool showSearchField = false;

  late AnimationController _blinkController;
  final ScrollController _staffListController = ScrollController();

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    _tabController = TabController(length: 2, vsync: this);
    _blinkController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    fetchStaffs(selectedDate);
    fetchDoneWorks(selectedDate);
    fetchDoneCalls(selectedDate);
  }

  @override
  void dispose() {
    _blinkController.dispose();
    _staffListController.dispose();
    super.dispose();
  }

  Future<void> fetchStaffs(DateTime date) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    setState(() => isLoadingStaffs = true);
    try {
      final response = await HttpService.getWorkedStaffs(formattedDate);
      if (response != null && response.status) {
        setState(() {
          allStaffs = response.data;
          // Add "All Staff" option at the beginning
          allStaffs.insert(
              0,
              Staff(
                id: '',
                name: 'All Staff',
                userIdStaff: '',
              ));
        });
      }
    } catch (e) {
      print("Error fetching staffs: $e");
    } finally {
      setState(() => isLoadingStaffs = false);
    }
  }

  Future<void> fetchDoneWorks(DateTime date) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    setState(() => isLoadingWorks = true);
    try {
      final response = await HttpService.getAllDoneworks(formattedDate);
      if (response != null) {
        setState(() {
          allStaffWorks = response.data;
          _filterData();
        });
      }
    } catch (e) {
      print("Error fetching done works: $e");
    } finally {
      setState(() => isLoadingWorks = false);
    }
  }

  Future<void> fetchDoneCalls(DateTime date) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    setState(() => isLoadingCalls = true);
    try {
      final response = await HttpService.getAllDonecalls(formattedDate);
      if (response != null) {
        setState(() {
          allStaffCalls = response.data;
          _filterData();
        });
      }
    } catch (e) {
      print("Error fetching done calls: $e");
    } finally {
      setState(() => isLoadingCalls = false);
    }
  }

  Future<void> _handleRefresh() async {
    await Future.wait([
      fetchStaffs(selectedDate),
      fetchDoneWorks(selectedDate),
      fetchDoneCalls(selectedDate),
    ]);
  }

  void _filterData() {
    // First filter by selected staff
    if (selectedStaffName == 'All Staff') {
      filteredStaffWorks = List.from(allStaffWorks);
      filteredStaffCalls = List.from(allStaffCalls);
    } else {
      filteredStaffWorks = allStaffWorks
          .where((staff) => staff.staffName == selectedStaffName)
          .toList();
      filteredStaffCalls = allStaffCalls
          .where((staff) => staff.staffName == selectedStaffName)
          .toList();
    }

    // Then apply search filter if searchQuery is not empty
    if (searchQuery.isNotEmpty) {
      filteredStaffWorks = filteredStaffWorks
          .where((staff) =>
              staff.staffName.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
      filteredStaffCalls = filteredStaffCalls
          .where((staff) =>
              staff.staffName.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      fetchStaffs(selectedDate);
      fetchDoneWorks(selectedDate);
      fetchDoneCalls(selectedDate);
    }
  }

  String getFormattedDisplayDate() {
    return DateFormat('dd-MM-yyyy').format(selectedDate);
  }

  // ------------------------------------------------------------------
  // Status helpers (presentation only)
  // ------------------------------------------------------------------
  Color _statusColor(String status) {
    switch (status) {
      case '1':
        return AppColors.halfDay; // To-do (blue)
      case '2':
        return AppColors.pending; // Pending (orange)
      case '3':
        return AppColors.success; // Completed (green)
      case '4':
        return AppColors.running; // Running
      case '5':
        return AppColors.danger; // Cancelled
      default:
        return AppColors.statusDefault;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case '1':
        return 'To-do';
      case '2':
        return 'Pending';
      case '3':
        return 'Completed';
      case '4':
        return 'Running';
      case '5':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  Widget _pill(String label, Color color, {bool strike = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.tint(color),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
          decoration: strike ? TextDecoration.lineThrough : null,
        ),
      ),
    );
  }

  /// Modified to handle isCompleted check
  Widget buildStatusText(String status, String isCompleted) {
    // ✅ Custom condition: if isCompleted is 1
    if (isCompleted == "1") {
      // First resolve the status label from the status code
      final String label = _statusLabel(status);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _pill(label, AppColors.danger, strike: true), // 🔥 cut line
          const SizedBox(height: 4),
          _pill("Completed", AppColors.success),
        ],
      );
    }

    final Color color = _statusColor(status);
    final String label = _statusLabel(status);

    if (status == '1' || status == '2') {
      return AnimatedBuilder(
        animation: _blinkController,
        builder: (context, child) {
          return Opacity(
            opacity: _blinkController.value,
            child: _pill(label, color),
          );
        },
      );
    }

    return _pill(label, color);
  }

  Color _getStatusBackgroundColor(String status, String isCompleted) {
    if (isCompleted == "1") {
      return AppColors.successTint;
    }
    switch (status) {
      case '1': // To-do
        return AppColors.tint(AppColors.halfDay, 0.07);
      case '2': // Pending
        return AppColors.warningTint;
      case '3': // Completed
        return AppColors.successTint;
      case '4': // Running
        return AppColors.runningTint;
      case '5': // Cancelled
        return AppColors.dangerTint;
      default:
        return AppColors.sheetBackground;
    }
  }

  // ------------------------------------------------------------------
  // Small reusable UI pieces
  // ------------------------------------------------------------------
  Widget _timeChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.tint(color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar(String name, {double radius = 18}) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.tint(AppColors.primary, 0.12),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.85,
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      );

  Widget _emptyState(IconData icon, String text) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _handleRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,
                    size: 56, color: AppColors.tint(AppColors.primary, 0.35)),
                const SizedBox(height: 12),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMedium,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Pull down to refresh or pick another date",
                  style: TextStyle(fontSize: 12.5, color: AppColors.textGrey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _skeletonList() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
      itemCount: 4,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        height: 130,
        padding: const EdgeInsets.all(12),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                    radius: 18, backgroundColor: AppColors.skeletonBase),
                const SizedBox(width: 10),
                Container(
                  height: 12,
                  width: 130,
                  decoration: BoxDecoration(
                    color: AppColors.skeletonBase,
                    borderRadius: BorderRadius.circular(6),
                  ),
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
    );
  }

  // ------------------------------------------------------------------
  // Staff popup (same logic, restyled)
  // ------------------------------------------------------------------
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
                  top: position.top + 30,
                  right: 8,
                  child: Material(
                    elevation: 8,
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 220,
                      height: 400,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: const BoxDecoration(
                                color: AppColors.sheetBackground,
                                border: Border(
                                  bottom: BorderSide(color: AppColors.border),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.search_rounded,
                                      size: 20, color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: searchController,
                                      decoration: const InputDecoration(
                                        hintText: 'Search staff...',
                                        hintStyle: TextStyle(
                                            color: AppColors.textLight),
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      autofocus: true,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textDark),
                                      onChanged: (value) {
                                        setDialogState(() {
                                          searchQuery = value;
                                          showAll = false;
                                        });
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close_rounded,
                                        size: 18, color: AppColors.textGrey),
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
                                            color: AppColors.textGrey,
                                          ),
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      padding: const EdgeInsets.all(0),
                                      itemCount: displayStaffs.length,
                                      itemBuilder: (context, index) {
                                        final staff = displayStaffs[index];
                                        final bool selected =
                                            staff.name == selectedStaffName;
                                        return InkWell(
                                          onTap: () {
                                            setState(() {
                                              selectedStaffName = staff.name;
                                              selectedStaffId =
                                                  staff.userIdStaff;
                                              _filterData();
                                            });
                                            Navigator.pop(context);
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              color: selected
                                                  ? AppColors.tint(
                                                      AppColors.primary, 0.08)
                                                  : null,
                                              border: const Border(
                                                bottom: BorderSide(
                                                  color: AppColors.divider,
                                                ),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                _avatar(staff.name, radius: 12),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    staff.name,
                                                    style: TextStyle(
                                                      fontSize: 13.5,
                                                      fontWeight: selected
                                                          ? FontWeight.w700
                                                          : FontWeight.w500,
                                                      color: AppColors.textDark,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                            if (filteredStaffs.length > 15)
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: AppColors.border),
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
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        showAll
                                            ? Icons.arrow_drop_up
                                            : Icons.arrow_drop_down,
                                        size: 16,
                                        color: AppColors.primary,
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
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ------------------------------------------------------------------
  // Staff chips row
  // ------------------------------------------------------------------
  Widget _buildStaffList() {
    if (isLoadingStaffs) {
      return const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
              strokeWidth: 2.5, color: AppColors.primary),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _staffListController,
            scrollDirection: Axis.horizontal,
            itemCount: allStaffs.length,
            itemBuilder: (context, index) {
              final staff = allStaffs[index];
              final isSelected = staff.name == selectedStaffName;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedStaffName = staff.name;
                    selectedStaffId = staff.userIdStaff;
                    _filterData();
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: EdgeInsets.only(
                    left: index == 0 ? 0 : 8,
                    right: index == allStaffs.length - 1 ? 8 : 0,
                    top: 6,
                    bottom: 6,
                  ),
                  padding: const EdgeInsets.fromLTRB(5, 4, 12, 4),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 11,
                        backgroundColor: isSelected
                            ? AppColors.textOnColor
                            : AppColors.tint(AppColors.primary, 0.12),
                        child: Text(
                          staff.name.isNotEmpty
                              ? staff.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        staff.name,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppColors.textOnColor
                              : AppColors.textMedium,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Builder(
          builder: (context) => IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.tint(AppColors.primary, 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.person_search_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            onPressed: () => _showSmallStaffPopup(context),
            tooltip: 'Filter Staff',
            padding: EdgeInsets.zero,
          ),
        ),
      ],
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
        controller: TextEditingController(text: searchQuery),
        style: const TextStyle(fontSize: 14, color: AppColors.textDark),
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: "Search by staff name...",
          hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded,
              size: 20, color: AppColors.textGrey),
          suffixIcon: IconButton(
            icon: const Icon(Icons.close_rounded,
                size: 18, color: AppColors.textGrey),
            onPressed: () {
              setState(() {
                searchQuery = '';
                _filterData();
              });
            },
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: (value) {
          setState(() {
            searchQuery = value;
            _filterData();
          });
        },
      ),
    );
  }

  // ------------------------------------------------------------------
  // Work tab
  // ------------------------------------------------------------------
  Widget buildWorkTab() {
    if (isLoadingWorks) {
      return _skeletonList();
    }

    if (filteredStaffWorks.isEmpty) {
      return _emptyState(
        Icons.work_off_outlined,
        selectedStaffName == 'All Staff'
            ? "No work found"
            : "No work found for $selectedStaffName",
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _handleRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
        itemCount: filteredStaffWorks.length,
        itemBuilder: (context, index) {
          final staff = filteredStaffWorks[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: _cardDecoration(),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _avatar(staff.staffName),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          staff.staffName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _timeChip(Icons.login_rounded,
                          "Login: ${staff.loginTime}", AppColors.present),
                      _timeChip(Icons.logout_rounded,
                          "Logout: ${staff.logoutTime}", AppColors.danger),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...staff.projects.map((project) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          // onTap: () {
                          //   Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //       builder: (context) => AssignReport(
                          //         workId: project.projectId,
                          //         sectionId: "",
                          //       ),
                          //     ),
                          //   );
                          // },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.softGrey,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.folder_open_rounded,
                                    size: 16, color: AppColors.primary),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    "${project.customerName ?? "No title"} [${project.projectName}]",
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // const SizedBox(height: 12),
                        // Text(
                        //   "Module: ${project.moduleName}",
                        //   style: const TextStyle(
                        //     fontSize: 14,
                        //     fontWeight: FontWeight.w600,
                        //   ),
                        // ),
                        const SizedBox(height: 10),
                        Column(
                          children: project.tasks.map((task) {
                            final isCompleted =
                                task.status.toLowerCase() == "completed";
                            final bgColor = _getStatusBackgroundColor(
                                task.status, task.isCompleted);

                            return IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                        width: 24,
                                        alignment: Alignment.center,
                                        child: Icon(
                                          isCompleted
                                              ? Icons.check_circle
                                              : Icons.access_time,
                                          color: isCompleted
                                              ? AppColors.success
                                              : AppColors.pending,
                                          size: 20,
                                        ),
                                      ),
                                      if (project.tasks.last != task)
                                        Expanded(
                                          child: Container(
                                            width: 2,
                                            color: AppColors.border,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AssignReport(
                                              workId: task.workId,
                                              sectionId: "",
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 10),
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: bgColor,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: AppColors.border),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Module: ${task.moduleName ?? 'N/A'}",
                                              style: const TextStyle(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textGrey,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              task.taskName,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.textDark,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Icon(
                                                        Icons.schedule_rounded,
                                                        size: 13,
                                                        color:
                                                            AppColors.textGrey),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      '${task.startTime} - ${task.endTime}',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            AppColors.textGrey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                buildStatusText(
                                                  task.status,
                                                  task.isCompleted,
                                                ),
                                              ],
                                            ),
                                            if (task.remarks.isNotEmpty) ...[
                                              const SizedBox(height: 6),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children:
                                                    task.remarks.map((remark) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 4.0),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const Text(
                                                          "• ",
                                                          style: TextStyle(
                                                            color: AppColors
                                                                .textGrey,
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            remark,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 12.5,
                                                              color: AppColors
                                                                  .textMedium,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        const Divider(thickness: 1, color: AppColors.divider),
                        const SizedBox(height: 6),
                      ],
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------------
  // Phone call tab
  // ------------------------------------------------------------------
  Widget buildPhoneCallTab() {
    if (isLoadingCalls) {
      return _skeletonList();
    }

    if (filteredStaffCalls.isEmpty) {
      return _emptyState(
        Icons.phone_disabled_rounded,
        selectedStaffName == 'All Staff'
            ? "No calls found"
            : "No calls found for $selectedStaffName",
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _handleRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
        itemCount: filteredStaffCalls.length,
        itemBuilder: (context, index) {
          final staff = filteredStaffCalls[index];
          final calls = staff.calls;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: _cardDecoration(),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _avatar(staff.staffName),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          staff.staffName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Total Called: ${staff.totalCalls}",
                          style: const TextStyle(
                            color: AppColors.textOnColor,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _timeChip(Icons.login_rounded,
                          "Login: ${staff.loginTime}", AppColors.present),
                      _timeChip(Icons.logout_rounded,
                          "Logout: ${staff.logoutTime}", AppColors.danger),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...calls.map((call) {
                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.phone,
                                  size: 11,
                                  color: AppColors.textOnColor,
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  width: 2,
                                  color: AppColors.border,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.softGrey,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    call.name != "null" ? call.name : "Unknown",
                                    //call.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.timer_outlined,
                                          size: 13, color: AppColors.textGrey),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Duration: ${call.duration}",
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          color: AppColors.textMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (call.startTime != null &&
                                      call.endTime != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.schedule_rounded,
                                              size: 13,
                                              color: AppColors.textLight),
                                          const SizedBox(width: 4),
                                          Text(
                                            "Time: ${DateFormat('hh:mm a').format(call.startTime!)} - ${DateFormat('hh:mm a').format(call.endTime!)}",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textGrey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
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
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Work Summary',
          style: TextStyle(
            color: AppColors.textOnColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textOnColor,
        iconTheme: const IconThemeData(color: AppColors.textOnColor),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.appBarGradient),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.textOnColor,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: AppColors.textOnColor,
          unselectedLabelColor: AppColors.tint(AppColors.textOnColor, 0.7),
          labelStyle:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          tabs: const [
            const Tab(
              child: Text(
                'Work',
              ),
            ),
            const Tab(
              child: Text(
                'Phonecall',
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () => _selectDate(context),
          ),
          IconButton(
            icon: Icon(showSearchField ? Icons.list : Icons.search),
            onPressed: () {
              setState(() {
                showSearchField = !showSearchField;
                if (!showSearchField) {
                  searchQuery = '';
                  _filterData();
                }
              });
            },
          ),
        ],
      ),
      body: WorkTimerOverlay(
        onTimerReturn: _handleRefresh,
        child: SafeArea(
          child: Column(
            children: [
              // Date + selected staff summary row
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                child: Row(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.tint(AppColors.primary, 0.10),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today_rounded,
                                size: 14, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text(
                              getFormattedDisplayDate(),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down_rounded,
                                size: 16, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.person_rounded,
                                size: 14, color: AppColors.textGrey),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                selectedStaffName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
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
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: showSearchField
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: _buildSearchField(),
                      )
                    : SizedBox(
                        height: 50,
                        child: _buildStaffList(),
                      ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    buildWorkTab(),
                    buildPhoneCallTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

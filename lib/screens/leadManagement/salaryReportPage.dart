// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:login2/models/lead_management/salaryListModel.dart';
// import 'package:login2/screens/leadManagement/salaryDetailPage.dart';
// import 'package:login2/service/service.dart';
// import 'package:login2/widgets/work_timer_overlay.dart';

// class SalaryReportPage extends StatefulWidget {
//   const SalaryReportPage({super.key});
//   @override
//   State<SalaryReportPage> createState() => _SalaryReportPageState();
// }

// class _SalaryReportPageState extends State<SalaryReportPage> {
//   DateTime selectedDate =
//       DateTime(DateTime.now().year, DateTime.now().month - 1);
//   final List<String> months = List.generate(
//     12,
//     (index) => DateFormat.MMMM().format(DateTime(0, index + 1)),
//   );
//   late List<int> years;
//   String tempMonth = "";
//   int tempYear = 0;
//   String filterStatus = "Active";
//   List<SalaryOnList> fullData = [];
//   List<SalaryOnList> filteredData = [];
//   bool isLoading = false;
//   TextEditingController searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     int currentYear = DateTime.now().year;
//     years = List.generate(11, (index) => currentYear - 5 + index);
//     fetchSalaryData();
//   }

//   String getMonthYearParam(DateTime date) {
//     return DateFormat("yyyy-MM").format(date);
//   }

//   Future<void> fetchSalaryData() async {
//     setState(() => isLoading = true);
//     try {
//       String monthYear = getMonthYearParam(selectedDate);
//       final salaryList = await HttpService.getSalaryList(monthYear: monthYear);

//       if (salaryList != null && salaryList.status == true) {
//         fullData = salaryList.data;
//         applyFilter();
//       } else {
//         fullData = [];
//         filteredData = [];
//       }
//     } catch (e) {
//       fullData = [];
//       filteredData = [];
//       debugPrint("❌ Error in fetchSalaryData: $e");
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   void applyFilter() {
//     setState(() {
//       List<SalaryOnList> tempList = [];

//       if (filterStatus == "All") {
//         tempList = fullData;
//       } else {
//         tempList = fullData.where((e) => e.status == filterStatus).toList();
//       }

//       if (searchController.text.isNotEmpty) {
//         tempList = tempList
//             .where((e) => e.staffName
//                 .toLowerCase()
//                 .contains(searchController.text.toLowerCase()))
//             .toList();
//       }

//       filteredData = tempList;
//     });
//   }

//   Future<void> showMonthYearDialog() async {
//     tempMonth = DateFormat.MMMM().format(selectedDate);
//     tempYear = selectedDate.year;

//     await showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               title: const Text("Select Month & Year"),
//               content: Row(
//                 children: [
//                   Expanded(
//                     child: DropdownButton<String>(
//                       isExpanded: true,
//                       value: tempMonth,
//                       items: months.map((month) {
//                         return DropdownMenuItem(
//                           value: month,
//                           child: Text(month),
//                         );
//                       }).toList(),
//                       onChanged: (value) {
//                         if (value != null) {
//                           setState(() {
//                             tempMonth = value;
//                           });
//                         }
//                       },
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: DropdownButton<int>(
//                       isExpanded: true,
//                       value: tempYear,
//                       items: years.map((year) {
//                         return DropdownMenuItem(
//                           value: year,
//                           child: Text(year.toString()),
//                         );
//                       }).toList(),
//                       onChanged: (value) {
//                         if (value != null) {
//                           setState(() {
//                             tempYear = value;
//                           });
//                         }
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text("Cancel"),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     setState(() {
//                       selectedDate =
//                           DateTime(tempYear, months.indexOf(tempMonth) + 1);
//                     });
//                     Navigator.pop(context);
//                     fetchSalaryData();
//                   },
//                   child: const Text("OK"),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     String displayMonthYear = DateFormat("MMMM yyyy").format(selectedDate);
//     return Scaffold(
//       appBar: AppBar(
//         title:
//             const Text("Salary Report", style: TextStyle(color: Colors.white)),
//         backgroundColor: Colors.blue,
//         iconTheme: const IconThemeData(color: Colors.white),
//         actions: [
//           TextButton.icon(
//             onPressed: showMonthYearDialog,
//             icon: const Icon(Icons.calendar_month, color: Colors.white),
//             label: Text(displayMonthYear,
//                 style: const TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//       body: WorkTimerOverlay(
//         onTimerReturn: fetchSalaryData,
//         child: Column(
//         children: [
//           const SizedBox(height: 10),

//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             child: TextField(
//               controller: searchController,
//               onChanged: (value) => applyFilter(),
//               decoration: InputDecoration(
//                 hintText: 'Search staff name...',
//                 prefixIcon: const Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide.none,
//                 ),
//                 filled: true,
//                 fillColor: Colors.white,
//                 contentPadding: const EdgeInsets.symmetric(vertical: 0),
//               ),
//             ),
//           ),

//           // Toggle Filter
//           ToggleButtons(
//             isSelected: ["Active", "Inactive", "All"]
//                 .map((e) => filterStatus == e)
//                 .toList(),
//             onPressed: (index) {
//               filterStatus = ["Active", "Inactive", "All"][index];
//               applyFilter();
//             },
//             children: const [
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 12),
//                 child: Text("Active"),
//               ),
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 12),
//                 child: Text("Inactive"),
//               ),
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 12),
//                 child: Text("All"),
//               ),
//             ],
//           ),

//           const SizedBox(height: 10),

//           Expanded(
//               child: isLoading
//                   ? const Center(child: CircularProgressIndicator())
//                   : filteredData.isEmpty
//                       ? const Center(child: Text("No data found"))
//                       : ListView.builder(
//                           itemCount: filteredData.length,
//                           itemBuilder: (context, index) {
//                             final staff = filteredData[index];
//                             return Padding(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 12, vertical: 6),
//                               child: Card(
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 child: ListTile(
//                                   onTap: () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (_) => SalaryDetailPage(
//                                           staffName: staff.staffName,
//                                           Id: staff.id ?? '',
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                   leading: CircleAvatar(
//                                     radius: 22,
//                                     backgroundColor: Colors.blue.shade100,
//                                     child: Text(
//                                       staff.staffName.isNotEmpty
//                                           ? staff.staffName[0].toUpperCase()
//                                           : '',
//                                       style: const TextStyle(
//                                         color: Colors.blue,
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ),
//                                   title: Text(
//                                     staff.staffName,
//                                     style: const TextStyle(
//                                         fontWeight: FontWeight.bold),
//                                   ),
//                                   subtitle: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text("Worked Days: ${staff.workedDays}"),
//                                       Text(
//                                         "LOP Days: ${staff.lopDays}",
//                                         style: TextStyle(
//                                           color: (double.tryParse(staff.lopDays
//                                                           .toString()) ??
//                                                       0) >
//                                                   0
//                                               ? Colors.red
//                                               : Colors.black,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                       if (staff.remarks != null &&
//                                           staff.remarks.toString().trim().isNotEmpty &&
//                                           staff.remarks.toString() != "null")
//                                         Padding(
//                                           padding: const EdgeInsets.only(top: 4),
//                                           child: Row(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Icon(Icons.comment_outlined,
//                                                   size: 13,
//                                                   color: Colors.grey.shade600),
//                                               const SizedBox(width: 4),
//                                               Expanded(
//                                                 child: Text.rich(
//                                                   TextSpan(
//                                                     children: [
//                                                       TextSpan(
//                                                         text: "Remarks: ",
//                                                         style: TextStyle(
//                                                           fontSize: 12,
//                                                           fontWeight:
//                                                               FontWeight.w600,
//                                                           color: Colors
//                                                               .grey.shade700,
//                                                         ),
//                                                       ),
//                                                       TextSpan(
//                                                         text: "${staff.remarks}",
//                                                         style: TextStyle(
//                                                           fontSize: 12,
//                                                           color: Colors
//                                                               .grey.shade800,
//                                                           fontStyle:
//                                                               FontStyle.italic,
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                     ],
//                                   ),
//                                   trailing: Column(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Text(
//                                         "₹${staff.monthlySalary}",
//                                         style: const TextStyle(
//                                           color: Colors.green,
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 16,
//                                         ),
//                                       ),
//                                       Text(staff.status),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             );
//                           },
//                         )),
//         ],
//       ),
//     ),
//     );
//   }
// }

//above is old code 
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/app_colors.dart'; 
import 'package:login2/models/lead_management/salaryListModel.dart';
import 'package:login2/screens/leadManagement/salaryDetailPage.dart';
import 'package:login2/service/service.dart';
import 'package:login2/widgets/work_timer_overlay.dart';

class SalaryReportPage extends StatefulWidget {
  const SalaryReportPage({super.key});
  @override
  State<SalaryReportPage> createState() => _SalaryReportPageState();
}

class _SalaryReportPageState extends State<SalaryReportPage> {
  DateTime selectedDate =
      DateTime(DateTime.now().year, DateTime.now().month - 1);
  final List<String> months = List.generate(
    12,
    (index) => DateFormat.MMMM().format(DateTime(0, index + 1)),
  );
  late List<int> years;
  String tempMonth = "";
  int tempYear = 0;
  String filterStatus = "Active";
  List<SalaryOnList> fullData = [];
  List<SalaryOnList> filteredData = [];
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();

  static const List<String> _filters = ["Active", "Inactive", "All"];

  @override
  void initState() {
    super.initState();
    int currentYear = DateTime.now().year;
    years = List.generate(11, (index) => currentYear - 5 + index);
    fetchSalaryData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String getMonthYearParam(DateTime date) {
    return DateFormat("yyyy-MM").format(date);
  }

  Future<void> fetchSalaryData() async {
    setState(() => isLoading = true);
    try {
      String monthYear = getMonthYearParam(selectedDate);
      final salaryList = await HttpService.getSalaryList(monthYear: monthYear);

      if (salaryList != null && salaryList.status == true) {
        fullData = salaryList.data;
        applyFilter();
      } else {
        fullData = [];
        filteredData = [];
      }
    } catch (e) {
      fullData = [];
      filteredData = [];
      debugPrint("❌ Error in fetchSalaryData: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void applyFilter() {
    setState(() {
      List<SalaryOnList> tempList = [];

      if (filterStatus == "All") {
        tempList = fullData;
      } else {
        tempList = fullData.where((e) => e.status == filterStatus).toList();
      }

      if (searchController.text.isNotEmpty) {
        tempList = tempList
            .where((e) => e.staffName
                .toLowerCase()
                .contains(searchController.text.toLowerCase()))
            .toList();
      }

      filteredData = tempList;
    });
  }

  // ------------------------------------------------------------------
  // Month / Year dialog
  // ------------------------------------------------------------------
  Future<void> showMonthYearDialog() async {
    tempMonth = DateFormat.MMMM().format(selectedDate);
    tempYear = selectedDate.year;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Widget box(Widget child) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.softGrey,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: child,
                );

            return AlertDialog(
              backgroundColor: AppColors.card,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
              contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              title: const Text(
                "Select Month & Year",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              content: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: box(
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: tempMonth,
                          style: const TextStyle(
                              color: AppColors.textDark, fontSize: 14),
                          items: months.map((month) {
                            return DropdownMenuItem(
                              value: month,
                              child: Text(month),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                tempMonth = value;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: box(
                      DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: tempYear,
                          style: const TextStyle(
                              color: AppColors.textDark, fontSize: 14),
                          items: years.map((year) {
                            return DropdownMenuItem(
                              value: year,
                              child: Text(year.toString()),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                tempYear = value;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              actionsPadding: const EdgeInsets.fromLTRB(12, 8, 16, 12),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                      foregroundColor: AppColors.textGrey),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    setState(() {
                      selectedDate =
                          DateTime(tempYear, months.indexOf(tempMonth) + 1);
                    });
                    Navigator.pop(context);
                    fetchSalaryData();
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ------------------------------------------------------------------
  // UI pieces
  // ------------------------------------------------------------------
  PreferredSizeWidget _buildAppBar(String displayMonthYear) {
    return AppBar(
      elevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.textOnColor,
      iconTheme: const IconThemeData(color: AppColors.textOnColor),
      flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: AppColors.appBarGradient),
      ),
      title: const Text(
        "Salary Report",
        style: TextStyle(
          color: AppColors.textOnColor,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: showMonthYearDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.tint(AppColors.textOnColor, 0.18),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_month_rounded,
                      size: 16, color: AppColors.textOnColor),
                  const SizedBox(width: 6),
                  Text(
                    displayMonthYear,
                    style: const TextStyle(
                      color: AppColors.textOnColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      size: 18, color: AppColors.textOnColor),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: TextField(
        controller: searchController,
        onChanged: (value) => applyFilter(),
        style: const TextStyle(fontSize: 14, color: AppColors.textDark),
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: 'Search staff name...',
          hintStyle:
              const TextStyle(color: AppColors.textLight, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded,
              size: 20, color: AppColors.textGrey),
          suffixIcon: searchController.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close_rounded,
                      size: 18, color: AppColors.textGrey),
                  onPressed: () {
                    searchController.clear();
                    applyFilter();
                  },
                ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildSegmentedFilter() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.softGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: _filters.map((label) {
          final selected = filterStatus == label;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                filterStatus = label;
                applyFilter();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? AppColors.textOnColor
                        : AppColors.textMedium,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _infoChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.tint(color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
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

  Widget _buildStaffCard(SalaryOnList staff) {
    final bool hasLop = (double.tryParse(staff.lopDays.toString()) ?? 0) > 0;
    final bool isActive = staff.status == "Active";
    final Color statusColor = isActive ? AppColors.success : AppColors.danger;
    final bool hasRemarks = staff.remarks != null &&
        staff.remarks.toString().trim().isNotEmpty &&
        staff.remarks.toString() != "null";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SalaryDetailPage(
                  staffName: staff.staffName,
                  Id: staff.id ?? '',
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.tint(AppColors.primary, 0.12),
                  child: Text(
                    staff.staffName.isNotEmpty
                        ? staff.staffName[0].toUpperCase()
                        : '',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Name + chips + remarks
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        staff.staffName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _infoChip(
                            icon: Icons.event_available_rounded,
                            text: "Worked ${staff.workedDays}",
                            color: AppColors.present,
                          ),
                          _infoChip(
                            icon: Icons.event_busy_rounded,
                            text: "LOP ${staff.lopDays}",
                            color: hasLop
                                ? AppColors.danger
                                : AppColors.textGrey,
                          ),
                        ],
                      ),
                      if (hasRemarks) ...[
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 1),
                              child: Icon(Icons.notes_rounded,
                                  size: 13, color: AppColors.textLight),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "${staff.remarks}",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontStyle: FontStyle.italic,
                                  color: AppColors.textGrey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Salary + status
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "₹${staff.monthlySalary}",
                      style: const TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.tint(statusColor),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        staff.status,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Icon(Icons.chevron_right_rounded,
                      size: 20, color: AppColors.textLight),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        height: 76,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const CircleAvatar(
                radius: 20, backgroundColor: AppColors.skeletonBase),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      height: 12,
                      width: 140,
                      decoration: BoxDecoration(
                          color: AppColors.skeletonBase,
                          borderRadius: BorderRadius.circular(6))),
                  const SizedBox(height: 10),
                  Container(
                      height: 10,
                      width: 90,
                      decoration: BoxDecoration(
                          color: AppColors.skeletonHighlight,
                          borderRadius: BorderRadius.circular(6))),
                ],
              ),
            ),
            Container(
                height: 14,
                width: 54,
                decoration: BoxDecoration(
                    color: AppColors.skeletonBase,
                    borderRadius: BorderRadius.circular(6))),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      // scrollable so pull-to-refresh still works
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 80),
        Icon(Icons.receipt_long_rounded,
            size: 56, color: AppColors.tint(AppColors.primary, 0.35)),
        const SizedBox(height: 12),
        const Center(
          child: Text(
            "No data found",
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
            "Try another month or change the filter",
            style: TextStyle(fontSize: 12.5, color: AppColors.textGrey),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    String displayMonthYear = DateFormat("MMM yyyy").format(selectedDate);

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: _buildAppBar(displayMonthYear),
      body: WorkTimerOverlay(
        onTimerReturn: fetchSalaryData,
        child: Column(
          children: [
            // Search + filter (compact header)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
              child: Column(
                children: [
                  _buildSearchField(),
                  const SizedBox(height: 8),
                  _buildSegmentedFilter(),
                ],
              ),
            ),

            // Result count
            if (!isLoading)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 4),
                child: Row(
                  children: [
                    Text(
                      "${filteredData.length} staff",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),

            // List
            Expanded(
              child: isLoading
                  ? _buildSkeletonList()
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: fetchSalaryData,
                      child: filteredData.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 16),
                              itemCount: filteredData.length,
                              itemBuilder: (context, index) =>
                                  _buildStaffCard(filteredData[index]),
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

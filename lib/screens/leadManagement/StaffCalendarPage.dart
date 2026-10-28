import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/expense/staffListModel.dart';
import 'package:login2/models/lead_management/attendnceListModel.dart';
import 'package:login2/models/lead_management/getAttendanceReportModel.dart';
import 'package:login2/models/lead_management/staffwiseWorkDataCountModel.dart';
import 'package:login2/models/lead_management/workDetailsCompanyModel.dart';
import 'package:login2/screens/leadManagement/AttendanceReportListPage.dart';
import 'package:login2/screens/leadManagement/AttendanceHistory.dart';
import 'package:login2/screens/leadManagement/viewwork_page.dart';
import 'package:login2/screens/staff_reports/timeline_page.dart';
import 'package:login2/service/service.dart';
import 'package:table_calendar/table_calendar.dart';

class StaffCalendarPage extends StatefulWidget {
  final String staffId;
  final DateTime selectedDate;
  final String staffName;
  const StaffCalendarPage({
    super.key,
    required this.staffId,
    required this.selectedDate,
    required this.staffName,
  });

  @override
  State<StaffCalendarPage> createState() => _StaffCalendarPageState();
}

class _StaffCalendarPageState extends State<StaffCalendarPage> {
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, Map<String, String>> attendanceMap = {};
  bool isLoading = true;
  bool isLoadingStaffs = true;
  bool isLoadingWorkData = true;
  WorkCompanyDetailsModel? workStatusDetails;
  String searchText = '';
  List<Staff> staffList = [];
  List<Staff> allStaffs = [];
  StaffListModel? staffListModel;
  StaffwiseWorkDataCountModel? workDataCounts;
  GetAttendanceReportModel? attendanceReport;
  String? selectedStaffName;
  String? selectedStaffId;
  String? markAttendance;
  @override
  void initState() {
    super.initState();
    fetchAttendanceData();
    fetchWorkStatusDetails();
    fetchStaffs();
    fetchWorkDataCounts();
  }

  Future<void> fetchWorkDataCounts([DateTime? selectedMonth]) async {
    setState(() {
      isLoadingWorkData = true;
    });
    final DateTime currentMonth = selectedMonth ?? _focusedDay;

    final String yearMonth =
        "${currentMonth.year.toString().padLeft(4, '0')}-${currentMonth.month.toString().padLeft(2, '0')}";
    try {
      final result = await HttpService()
          .getStaffwiseWorkDataCounts(widget.staffId, yearMonth);

      if (result != null && result.status) {
        setState(() {
          workDataCounts = result;
        });
      }

      // Fetch Attendance Report Summary
      final firstDayOfMonth =
          DateTime(currentMonth.year, currentMonth.month, 1);
      final lastDayOfMonth =
          DateTime(currentMonth.year, currentMonth.month + 1, 0);
      final fromDateStr = DateFormat('yyyy-MM-dd').format(firstDayOfMonth);
      final toDateStr = DateFormat('yyyy-MM-dd').format(lastDayOfMonth);

      final reportResult = await HttpService.getAttendanceReport(
        fromDateStr,
        toDateStr,
        widget.staffId,
      );

      if (reportResult != null && reportResult.status == true) {
        if (reportResult.data?.list != null) {
          for (var item in reportResult.data!.list!) {
            final itemDate = _parseDateString(item.date);
            if (itemDate != null) {
              final key =
                  DateTime.utc(itemDate.year, itemDate.month, itemDate.day);
              if (attendanceMap.containsKey(key)) {
                if (item.leaveReason != null && item.leaveReason!.isNotEmpty) {
                  attendanceMap[key]!["leave_reason"] = item.leaveReason!;
                  attendanceMap[key]!["reason"] = item.leaveReason!;
                }
                if (item.status?.toLowerCase() == 'leave') {
                  attendanceMap[key]!["status"] = "leave";
                  if (attendanceMap[key]!["title"] == "Not Added" ||
                      attendanceMap[key]!["title"] == "Absent") {
                    attendanceMap[key]!["title"] = "Leave";
                  }
                }
              } else {
                attendanceMap[key] = {
                  "title": item.status ?? "Leave",
                  "status": item.status?.toLowerCase() == "leave"
                      ? "leave"
                      : (item.status ?? "leave"),
                  "login": item.loginTime?.isNotEmpty == true
                      ? item.loginTime!
                      : "--",
                  "logout": item.logoutTime?.isNotEmpty == true
                      ? item.logoutTime!
                      : "--",
                  "totalDuration": "--",
                  "ideal_time": item.idleTime?.isNotEmpty == true
                      ? item.idleTime!
                      : "--",
                  "work_time": item.workingTime?.isNotEmpty == true
                      ? item.workingTime!
                      : "--",
                  "reason": item.leaveReason ?? "--",
                  "leave_reason": item.leaveReason ?? "--",
                };
              }
            }
          }
        }
        setState(() {
          attendanceReport = reportResult;
          isLoadingWorkData = false;
        });
      } else {
        setState(() {
          isLoadingWorkData = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching work data counts: $e");
      setState(() {
        isLoadingWorkData = false;
      });
    }
  }

  Future<void> fetchStaffs() async {
    setState(() {
      isLoadingStaffs = true;
    });

    final result = await HttpService.getStaffsAccessible();
    if (result != null && result.status) {
      setState(() {
        staffListModel = result;
        staffList = result.data;
        allStaffs = result.data;
        isLoadingStaffs = false;
      });
      fetchWorkDataCounts();
    } else {
      setState(() {
        isLoadingStaffs = false;
      });
    }
  }

  Future<void> fetchWorkStatusDetails() async {
    final currentDate = DateFormat('yyyy-MM-dd').format(widget.selectedDate);

    final response = await HttpService.getWorkCompanyStatusDetails(currentDate);
    setState(() {
      workStatusDetails = response;
      isLoading = false;
    });
  }

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
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 200,
                      height: 400,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                              ),
                              border: Border(
                                bottom: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.search,
                                    size: 20, color: Colors.blue),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: searchController,
                                    decoration: const InputDecoration(
                                      hintText: 'Search staff...',
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    autofocus: true,
                                    style: const TextStyle(fontSize: 14),
                                    onChanged: (value) {
                                      setDialogState(() {
                                        searchQuery = value;
                                        showAll = false;
                                      });
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 18),
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
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.all(0),
                                    itemCount: displayStaffs.length,
                                    itemBuilder: (context, index) {
                                      final staff = displayStaffs[index];
                                      return InkWell(
                                        onTap: () {
                                          setState(() {
                                            selectedStaffName = staff.name;
                                            selectedStaffId = staff.userIdStaff;
                                          });
                                          Navigator.pop(context);
                                          // Navigate to the selected staff's calendar
                                          if (staff.userIdStaff !=
                                              widget.staffId) {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    StaffCalendarPage(
                                                  staffId: staff.userIdStaff,
                                                  selectedDate:
                                                      widget.selectedDate,
                                                  staffName: staff.name,
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: Colors.grey.shade200,
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            staff.name,
                                            style:
                                                const TextStyle(fontSize: 14),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                          if (filteredStaffs.length > 15)
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: Colors.grey.shade300),
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
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      showAll
                                          ? Icons.arrow_drop_up
                                          : Icons.arrow_drop_down,
                                      size: 16,
                                      color: Colors.blue,
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
              ],
            );
          },
        );
      },
    );
  }

  Future<void> fetchAttendanceData([DateTime? selectedMonth]) async {
    try {
      final DateTime currentMonth = selectedMonth ?? _focusedDay;
      markAttendance = await Common.getSharedPref("markAttendance") ?? '';
      final String yearMonth =
          "${currentMonth.year.toString().padLeft(4, '0')}-${currentMonth.month.toString().padLeft(2, '0')}";
      final AttendanceDataModel? result = await HttpService.getAttendanceData(
          widget.staffId, yearMonth,
          monthYear: '');
      if (result != null) {
        Map<DateTime, Map<String, String>> parsedData = {};
        for (var item in result.data.calendarData) {
          final date =
              DateTime.utc(item.date.year, item.date.month, item.date.day);
          String status = "unknown";
          if (item.type == "holiday") {
            status = "holiday";
          } else if (item.type == "leave") {
            if (item.title.toLowerCase().contains("half")) {
              status = "half";
            } else {
              status = "leave";
            }
          } else if (item.title.toLowerCase().contains("full")) {
            status = "present";
          } else if (item.title.toLowerCase().contains("half")) {
            status = "half";
          } else {
            status = "present";
          }
          parsedData[date] = {
            "title": item.title,
            "status": status,
            "login": item.loginTime.isNotEmpty ? item.loginTime : "--",
            "logout": item.logoutTime.isNotEmpty ? item.logoutTime : "--",
            "totalDuration":
                item.totalDuration.isNotEmpty ? item.totalDuration : "--",
            "ideal_time": item.idealTime.isNotEmpty ? item.idealTime : "--",
            "work_time": item.workTime.isNotEmpty ? item.workTime : "--",
            "reason": item.reason.isNotEmpty ? item.reason : "--",
            "leave_reason": item.reason.isNotEmpty ? item.reason : "--",
          };
        }
        final firstDay = DateTime.utc(currentMonth.year, currentMonth.month, 1);
        final lastDay =
            DateTime.utc(currentMonth.year, currentMonth.month + 1, 0);
        final today = DateTime.now();

        for (DateTime date = firstDay;
            !date.isAfter(lastDay);
            date = date.add(const Duration(days: 1))) {
          if (!parsedData.containsKey(date)) {
            if (!date.isAfter(today)) {
              parsedData[date] = {
                "title": "Absent",
                "status": "absent",
                "login": "--",
                "logout": "--",
                "totalDuration": "--",
                "ideal_time": "--",
                "work_time": "--",
              };
            } else {
              parsedData[date] = {
                "title": "Not Added",
                "status": "not_added",
                "login": "--",
                "logout": "--",
                "totalDuration": "--",
                "ideal_time": "--",
                "work_time": "--",
              };
            }
          }
        }

        if (attendanceReport?.data?.list != null) {
          for (var item in attendanceReport!.data!.list!) {
            final itemDate = _parseDateString(item.date);
            if (itemDate != null) {
              final dateKey =
                  DateTime.utc(itemDate.year, itemDate.month, itemDate.day);
              if (parsedData.containsKey(dateKey)) {
                if (item.leaveReason != null && item.leaveReason!.isNotEmpty) {
                  parsedData[dateKey]!["leave_reason"] = item.leaveReason!;
                  parsedData[dateKey]!["reason"] = item.leaveReason!;
                }
                if (item.status?.toLowerCase() == 'leave') {
                  parsedData[dateKey]!["status"] = "leave";
                  if (parsedData[dateKey]!["title"] == "Not Added" ||
                      parsedData[dateKey]!["title"] == "Absent") {
                    parsedData[dateKey]!["title"] = "Leave";
                  }
                }
              } else {
                parsedData[dateKey] = {
                  "title": item.status ?? "Leave",
                  "status": item.status?.toLowerCase() == "leave"
                      ? "leave"
                      : (item.status ?? "leave"),
                  "login": item.loginTime?.isNotEmpty == true
                      ? item.loginTime!
                      : "--",
                  "logout": item.logoutTime?.isNotEmpty == true
                      ? item.logoutTime!
                      : "--",
                  "totalDuration": "--",
                  "ideal_time": item.idleTime?.isNotEmpty == true
                      ? item.idleTime!
                      : "--",
                  "work_time": item.workingTime?.isNotEmpty == true
                      ? item.workingTime!
                      : "--",
                  "reason": item.leaveReason ?? "--",
                  "leave_reason": item.leaveReason ?? "--",
                };
              }
            }
          }
        }

        setState(() {
          attendanceMap = parsedData;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching attendance: $e");
      setState(() => isLoading = false);
    }
  }

  Color _getDayColor(DateTime day) {
    final key = DateTime.utc(day.year, day.month, day.day);
    final data = attendanceMap[key];
    if (data == null) return Colors.transparent;

    switch (data["status"]) {
      case "present":
        return Colors.green.shade400;
      case "half":
        return Colors.orange.shade400;
      case "holiday":
        return Colors.blue.shade400;
      case "absent":
      case "leave":
        return Colors.red.shade400;
      default:
        return Colors.transparent;
    }
  }

  DateTime? _parseDateString(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return null;
    final trimmed = dateStr.trim();
    try {
      return DateFormat('dd-MM-yyyy').parse(trimmed);
    } catch (_) {}
    try {
      return DateFormat('yyyy-MM-dd').parse(trimmed);
    } catch (_) {}
    try {
      return DateTime.parse(trimmed);
    } catch (_) {}
    return null;
  }

  bool _isSameDate(String? itemDateStr, DateTime targetDay) {
    if (itemDateStr == null || itemDateStr.trim().isEmpty) return false;
    final trimmed = itemDateStr.trim();
    final d1 = DateFormat('dd-MM-yyyy').format(targetDay);
    final d2 = DateFormat('yyyy-MM-dd').format(targetDay);
    if (trimmed == d1 || trimmed == d2) return true;
    final parsed = _parseDateString(trimmed);
    if (parsed != null) {
      return parsed.year == targetDay.year &&
          parsed.month == targetDay.month &&
          parsed.day == targetDay.day;
    }
    return false;
  }

  Future<void> _showLoginLogoutPopup(DateTime day) async {
    final firstDayOfMonth = DateTime(day.year, day.month, 1);
    final lastDayOfMonth = DateTime(day.year, day.month + 1, 0);
    final fromDateStr = DateFormat('yyyy-MM-dd').format(firstDayOfMonth);
    final toDateStr = DateFormat('yyyy-MM-dd').format(lastDayOfMonth);

    if (attendanceReport == null || attendanceReport!.data == null) {
      try {
        final reportResult = await HttpService.getAttendanceReport(
          fromDateStr,
          toDateStr,
          widget.staffId,
        );
        if (reportResult != null && reportResult.status == true) {
          if (mounted) {
            setState(() {
              attendanceReport = reportResult;
            });
          }
        }
      } catch (e) {
        debugPrint("Error fetching attendance report for popup: $e");
      }
    }
    if (!mounted) return;

    final key = DateTime.utc(day.year, day.month, day.day);
    final data = attendanceMap[key];
    String title = data?["title"] ?? "Not Added";
    String status = data?["status"] ?? "Not Added";
    String login = data?["login"] ?? "--";
    String logout = data?["logout"] ?? "--";
    String totalDuration = data?["totalDuration"] ?? "--";
    String ideal_time = data?["ideal_time"] ?? "--";
    String work_time = data?["work_time"] ?? "--";
    String reason = data?["leave_reason"] ?? data?["reason"] ?? "--";

    // Match item in attendanceReport for the selected date
    ListData? reportItem;
    if (attendanceReport?.data?.list != null) {
      for (final item in attendanceReport!.data!.list!) {
        if (_isSameDate(item.date, day)) {
          reportItem = item;
          break;
        }
      }
    }

    if (reportItem != null) {
      final isLeave = (reportItem.status != null &&
              reportItem.status!.toLowerCase() == 'leave') ||
          status.toLowerCase() == 'leave' ||
          title.toLowerCase().contains('leave');

      if (isLeave) {
        status = reportItem.status?.isNotEmpty == true
            ? reportItem.status!
            : "Leave";
        if (title == "Not Added" ||
            title == "Absent" ||
            title.toLowerCase() == "unknown") {
          title = status;
        }
        if (reportItem.leaveReason != null &&
            reportItem.leaveReason!.trim().isNotEmpty) {
          reason = reportItem.leaveReason!.trim();
        } else if (reportItem.remarks != null &&
            reportItem.remarks!.trim().isNotEmpty) {
          reason = reportItem.remarks!.trim();
        }
      } else {
        if ((status == "Not Added" || status == "not_added") &&
            reportItem.status != null &&
            reportItem.status!.isNotEmpty) {
          status = reportItem.status!;
          title = reportItem.status!;
        }
      }

      if (login == "--" &&
          reportItem.loginTime != null &&
          reportItem.loginTime!.isNotEmpty) {
        login = reportItem.loginTime!;
      }
      if (logout == "--" &&
          reportItem.logoutTime != null &&
          reportItem.logoutTime!.isNotEmpty) {
        logout = reportItem.logoutTime!;
      }
      if (work_time == "--" &&
          reportItem.workingTime != null &&
          reportItem.workingTime!.isNotEmpty) {
        work_time = reportItem.workingTime!;
      }
      if (ideal_time == "--" &&
          reportItem.idleTime != null &&
          reportItem.idleTime!.isNotEmpty) {
        ideal_time = reportItem.idleTime!;
      }
    }

    if (reason.trim().isEmpty) {
      reason = "--";
    }

    // Dialog state
    bool isEditing = false;
    String selectedAction = '';
    String selectedLeaveType = '';
    String selectedWorkStatus = 'Full Day';
    String selectedWorkStatusHalf = 'Half Day';
    bool isStepTwo = false;
    bool showHalfDaySection = false;
    final reasonController = TextEditingController();

    List<String> leaveTypes = ["Sick Leave", "Casual Leave", "LOP", "Other"];
    List<String> workStatusOptions = ["Full Day", "Half Day"];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: 500,
          height: MediaQuery.of(context).size.height * 0.8,
          child: StatefulBuilder(
            builder: (context, setStateDialog) {
              return Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('EEEE, MMM d, yyyy').format(day),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isEditing
                                    ? (isStepTwo
                                        ? 'Step 2: Mark Details'
                                        : 'Step 1: Select Action')
                                    : 'Attendance Details',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            size: 20,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),

                  // Content Area
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isEditing) ...[
                            // Show attendance details with edit button
                            _buildAttendanceDetailsSection(
                              widget.staffName,
                              title,
                              status,
                              login,
                              logout,
                              totalDuration,
                              ideal_time,
                              work_time,
                              reason,
                              () {
                                setStateDialog(() {
                                  isEditing = true;
                                });
                              },
                            ),
                          ] else if (!isStepTwo) ...[
                            _buildActionSelectionList(
                              selectedAction,
                              (val) => setStateDialog(() {
                                selectedAction = val;
                              }),
                            ),
                          ] else ...[
                            if (selectedAction == 'attendance') ...[
                              _buildAttendanceSection(
                                selectedAction,
                                selectedWorkStatus,
                                workStatusOptions,
                                setStateDialog,
                              ),
                            ] else if (selectedAction == 'leave' ||
                                selectedAction == 'halfDayLeave') ...[
                              _buildLeaveSection(
                                selectedAction,
                                selectedLeaveType,
                                reasonController,
                                leaveTypes,
                                showHalfDaySection,
                                setStateDialog,
                                (val) => setStateDialog(
                                    () => selectedLeaveType = val),
                                (val) => setStateDialog(
                                    () => showHalfDaySection = val),
                              ),
                            ] else if (selectedAction == 'halfDay') ...[
                              _buildAttendanceSection(
                                selectedAction,
                                selectedWorkStatusHalf,
                                workStatusOptions,
                                setStateDialog,
                              ),
                            ]
                          ],
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),

                  // Footer
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (isEditing && isStepTwo) ...[
                          // Back button for Step 2
                          TextButton(
                            onPressed: () => setStateDialog(() {
                              isStepTwo = false;
                            }),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              foregroundColor: Colors.grey.shade700,
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.arrow_back, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'Back',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          )
                        ] else if (isEditing && !isStepTwo) ...[
                          TextButton(
                            onPressed: () => setStateDialog(() {
                              isEditing = false;
                              selectedAction = '';
                            }),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              foregroundColor: Colors.grey.shade700,
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.arrow_back, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'Back to Details',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          )
                        ] else ...[
                          const SizedBox(), // Empty spacer for view mode
                        ],

                        // const Spacer(),

                        // // Cancel button
                        // TextButton(
                        //   onPressed: () => Navigator.pop(context),
                        //   style: TextButton.styleFrom(
                        //     padding: const EdgeInsets.symmetric(
                        //         horizontal: 20, vertical: 10),
                        //     foregroundColor: Colors.grey.shade700,
                        //   ),
                        //   child: const Text(
                        //     'Cancel',
                        //     style: TextStyle(fontSize: 14),
                        //   ),
                        // ),

                        const SizedBox(width: 8),

                        // Action buttons
                        if (!isEditing) ...[
                          // View mode buttons
                          Row(
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 125, 90, 207),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AttendanceHistory(
                                        staffName: widget.staffName,
                                        staffId: widget.staffId,
                                        selectedDate: day,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "View History",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  final filteredList = workStatusDetails?.data
                                          .where((staff) => staff.name
                                              .toLowerCase()
                                              .contains(
                                                  searchText.toLowerCase()))
                                          .toList() ??
                                      [];

                                  if (filteredList.isNotEmpty) {
                                    final staff = filteredList.firstWhere(
                                      (s) => s.staffId == widget.staffId,
                                      orElse: () => WorkCompany(
                                        staffId: widget.staffId,
                                        name: '',
                                        taskName: '',
                                        firstLoginTime: '',
                                        lastLogoutTime: '',
                                        status: '',
                                        multiple: 'false',
                                      ),
                                    );
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
                                                      builder: (_) =>
                                                          ViewWorkPage(
                                                        staffName: staff.name,
                                                        staffId: staff.staffId,
                                                        selectedDate: day,
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
                                                          "staffId":
                                                              staff.staffId,
                                                          "selectedDate": day,
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
                                    } else if (staff.taskName.isEmpty) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ViewWorkPage(
                                            staffName: staff.name,
                                            staffId: staff.staffId,
                                            selectedDate: day,
                                          ),
                                        ),
                                      );
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const TimelinePage(),
                                          settings: RouteSettings(
                                            arguments: {
                                              "staffId": staff.staffId,
                                              "selectedDate": day,
                                            },
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 25, 180, 241),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text("View Works"),
                              ),
                            ],
                          ),
                        ] else if (isEditing && !isStepTwo) ...[
                          // Next button for Step 1
                          ElevatedButton(
                            onPressed: () {
                              if (selectedAction.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Please select an action"),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }
                              setStateDialog(() {
                                isStepTwo = true;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Text(
                                  'Next',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          )
                        ] else if (isEditing && isStepTwo) ...[
                          // Submit button for Step 2
                          ElevatedButton(
                            onPressed: () async {
                              print('=== SUBMIT BUTTON PRESSED ===');
                              print('Selected Action: $selectedAction');
                              print(
                                  'Selected Leave Type: "$selectedLeaveType"');
                              print(
                                  'Selected Leave Type isEmpty: ${selectedLeaveType.isEmpty}');
                              print(
                                  'Selected Leave Type length: ${selectedLeaveType.length}');
                              if ((selectedAction == 'leave' ||
                                      selectedAction == 'halfDayLeave') &&
                                  selectedLeaveType.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Please select a leave type"),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }

                              final dateStr =
                                  "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";

                              bool success = false;

                              try {
                                if (selectedAction == 'leave' ||
                                    selectedAction == 'halfDayLeave') {
                                  // For halfDayLeave, always set isHalfDay to true
                                  // For regular leave, use showHalfDaySection value
                                  success = await HttpService.saveLeave(
                                    staffId: widget.staffId,
                                    date: dateStr,
                                    remarks: reasonController.text,
                                    leaveType: selectedLeaveType,
                                    isHalfDay: selectedAction == 'halfDayLeave'
                                        ? true // halfDayLeave is always half day
                                        : showHalfDaySection, // regular leave can be full or half
                                  );
                                } else if (selectedAction == 'attendance') {
                                  success = await HttpService.saveWork(
                                    staffId: widget.staffId,
                                    date: dateStr,
                                    workStatus: selectedWorkStatus,
                                  );
                                } else if (selectedAction == 'halfDay') {
                                  success = await HttpService.saveWork(
                                    staffId: widget.staffId,
                                    date: dateStr,
                                    workStatus: selectedWorkStatusHalf,
                                  );
                                }

                                Navigator.pop(context);
                                fetchAttendanceData(_focusedDay);
                                fetchWorkDataCounts(_focusedDay);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  selectedAction == 'leave'
                                      ? SnackBar(
                                          content: Text(
                                            success
                                                ? "Leave updated successfully!"
                                                : "Failed to update leave.",
                                          ),
                                          backgroundColor: success
                                              ? Colors.green
                                              : Colors.red,
                                        )
                                      : SnackBar(
                                          content: Text(
                                            success
                                                ? "Attendance updated successfully!"
                                                : "Failed to update attendance.",
                                          ),
                                          backgroundColor: success
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                );
                              } catch (e) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Error: $e"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _getColorForAction(selectedAction),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              _getSubmitButtonText(selectedAction),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          // ElevatedButton(
                          //   onPressed: () async {
                          //     // Validate based on action type
                          //     if ((selectedAction == 'leave' ||
                          //             selectedAction == 'halfDayLeave') &&
                          //         selectedLeaveType.isEmpty) {
                          //       ScaffoldMessenger.of(context).showSnackBar(
                          //         const SnackBar(
                          //           content: Text("Please select a leave type"),
                          //           backgroundColor: Colors.orange,
                          //         ),
                          //       );
                          //       return;
                          //     }

                          //     final dateStr =
                          //         "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";

                          //     bool success = false;

                          //     try {
                          //       if (selectedAction == 'leave' ||
                          //           selectedAction == 'halfDayLeave') {
                          //         success = await HttpService.saveLeave(
                          //           staffId: widget.staffId,
                          //           date: dateStr,
                          //           leaveType: selectedLeaveType,
                          //           isHalfDay: selectedAction == 'halfDayLeave'
                          //               ? true
                          //               : showHalfDaySection,
                          //         );
                          //       } else if (selectedAction == 'attendance') {
                          //         success = await HttpService.saveWork(
                          //           staffId: widget.staffId,
                          //           date: dateStr,
                          //           workStatus: selectedWorkStatus,
                          //         );
                          //       }
                          //        else if (selectedAction == 'halfDay') {
                          //         success = await HttpService.saveWork(
                          //           staffId: widget.staffId,
                          //           date: dateStr,
                          //           workStatus: selectedWorkStatusHalf,
                          //         );
                          //       }

                          //       Navigator.pop(context);
                          //       fetchAttendanceData(_focusedDay);
                          //       ScaffoldMessenger.of(context).showSnackBar(
                          //         SnackBar(
                          //           content: Text(
                          //             success
                          //                 ? "Attendance updated successfully!"
                          //                 : "Failed to update attendance.",
                          //           ),
                          //           backgroundColor:
                          //               success ? Colors.green : Colors.red,
                          //         ),
                          //       );
                          //     } catch (e) {
                          //       Navigator.pop(context);
                          //       ScaffoldMessenger.of(context).showSnackBar(
                          //         SnackBar(
                          //           content: Text("Error: $e"),
                          //           backgroundColor: Colors.red,
                          //         ),
                          //       );
                          //     }
                          //   },
                          //   style: ElevatedButton.styleFrom(
                          //     backgroundColor:
                          //         _getColorForAction(selectedAction),
                          //     padding: const EdgeInsets.symmetric(
                          //         horizontal: 20, vertical: 10),
                          //     shape: RoundedRectangleBorder(
                          //       borderRadius: BorderRadius.circular(8),
                          //     ),
                          //   ),
                          //   child: Text(
                          //     _getSubmitButtonText(selectedAction),
                          //     style: const TextStyle(
                          //       fontSize: 14,
                          //       color: Colors.white,
                          //       fontWeight: FontWeight.w500,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // Helper method to build action selection list
  Widget _buildActionSelectionList(
    String selectedAction,
    ValueChanged<String> onActionChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildActionRadioItem(
          icon: Icons.check_circle_outline,
          title: 'Mark Attendance',
          subtitle: 'Mark staff as present for full day',
          isSelected: selectedAction == 'attendance',
          actionType: 'attendance',
          color: Colors.green.shade600,
          onTap: () => onActionChanged('attendance'),
        ),
        const SizedBox(height: 12),
        _buildActionRadioItem(
          icon: Icons.access_time,
          title: 'Mark Half Day',
          subtitle: 'Mark staff as present for half day',
          isSelected: selectedAction == 'halfDay',
          actionType: 'halfDay',
          color: Colors.orange.shade600,
          onTap: () => onActionChanged('halfDay'),
        ),
        const SizedBox(height: 12),
        _buildActionRadioItem(
          icon: Icons.beach_access_outlined,
          title: 'Mark Leave',
          subtitle: 'Mark staff on leave with leave type',
          isSelected: selectedAction == 'leave',
          actionType: 'leave',
          color: Colors.blue.shade600,
          onTap: () => onActionChanged('leave'),
        ),
        // const SizedBox(height: 12),
        // _buildActionRadioItem(
        //   icon: Icons.timelapse_outlined,
        //   title: 'Mark Half Day Leave',
        //   subtitle: 'Mark staff on half day leave with leave type',
        //   isSelected: selectedAction == 'halfDayLeave',
        //   actionType: 'halfDayLeave',
        //   color: Colors.purple.shade600,
        //   onTap: () => onActionChanged('halfDayLeave'),
        // ),
      ],
    );
  }

  // Helper method to build action radio item
  Widget _buildActionRadioItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required Color color,
    required String actionType,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? color : Colors.grey.shade400,
                  width: 1.5,
                ),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: actionType,
              groupValue: isSelected ? actionType : null,
              onChanged: (value) => onTap(),
              activeColor: color,
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build attendance section
  Widget _buildAttendanceSection(
    String selectedAction,
    String selectedWorkStatus,
    List<String> workStatusOptions,
    void Function(void Function()) setStateDialog,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              selectedAction == 'halfDay'
                  ? Icons.access_time
                  : Icons.check_circle,
              size: 18,
              color: selectedAction == 'halfDay'
                  ? Colors.orange.shade600
                  : Colors.green.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              selectedAction == 'halfDay' ? 'Mark Half Day' : 'Mark Full Day',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: selectedAction == 'halfDay'
                    ? Colors.orange.shade700
                    : Colors.green.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          selectedAction == 'halfDay'
              ? 'Mark staff as present for half day'
              : 'Mark staff as present for full day',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 16),
        if (selectedAction == 'halfDay') ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Work Status',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 6),
              IgnorePointer(
                ignoring: true, // This disables all touch interactions
                child: Opacity(
                  opacity: 0.6, // Makes it look disabled
                  child: DropdownButtonFormField<String>(
                    value: selectedWorkStatus,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      prefixIcon: Icon(
                        Icons.work_outline,
                        size: 20,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    items: workStatusOptions.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (value) {},
                    isExpanded: true,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

// Helper method to build leave section
  Widget _buildLeaveSection(
    String selectedAction,
    String selectedLeaveType,
    TextEditingController reasonController,
    List<String> leaveTypes,
    bool showHalfDaySection,
    void Function(void Function()) setStateDialog,
    ValueChanged<String> onLeaveTypeChanged,
    ValueChanged<bool> onHalfDayChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.beach_access_outlined,
              size: 18,
              color: Colors.blue.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              selectedAction == 'halfDayLeave'
                  ? 'Mark Half Day Leave'
                  : 'Mark Leave',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          selectedAction == 'halfDayLeave'
              ? 'Select leave type and mark as half day leave'
              : 'Select leave type and details',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 16),

        // Leave Type - Mandatory for both leave and halfDayLeave
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Leave Type',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '*',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.red.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: selectedLeaveType.isEmpty ? null : selectedLeaveType,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(
                  Icons.category_outlined,
                  size: 20,
                  color: Colors.blue.shade600,
                ),
                errorStyle: const TextStyle(fontSize: 12),
              ),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
              hint: Text(
                'Select Leave Type',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              items: leaveTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                onLeaveTypeChanged(value ?? '');
              },
              validator: (value) {
                print('=== VALIDATOR CALLED ===');
                print('Validator value: $value');
                print('selectedLeaveType at validation: $selectedLeaveType');

                if (value == null || value.isEmpty) {
                  print('Validation FAILED - value is null or empty');
                  return 'Please select a leave type';
                }
                print('Validation PASSED - value: $value');
                return null;
              },
              isExpanded: true,
            ),
          ],
        ),

        const SizedBox(height: 12),
        // if (selectedAction == 'leave') ...[
        //   // Half Day Leave Checkbox
        //   CheckboxListTile(
        //     contentPadding: EdgeInsets.zero,
        //     title: const Text("Half Day Leave"),
        //     value: showHalfDaySection,
        //     onChanged: (val) => onHalfDayChanged(val ?? false),
        //     activeColor: Colors.blue.shade600,
        //   ),
        //   const SizedBox(height: 12),
        // ],

        // Reason (Optional)
        TextField(
          controller: reasonController,
          style: const TextStyle(fontSize: 14),
          maxLines: 2,
          decoration: InputDecoration(
            labelText: 'Reason (Optional)',
            labelStyle: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            prefixIcon: Icon(
              Icons.note_outlined,
              size: 20,
              color: Colors.blue.shade600,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
      ],
    );
  }

  // Helper method to build attendance details section
  Widget _buildAttendanceDetailsSection(
    String staffName,
    String title,
    String status,
    String login,
    String logout,
    String totalDuration,
    String idealTime,
    String workTime,
    String reason,
    VoidCallback onEdit,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              staffName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            markAttendance == "true"
                ? IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue, size: 22),
                    onPressed: onEdit,
                  )
                : SizedBox(),
          ],
        ),
        const SizedBox(height: 20),
        _buildDetailRow("Title", title.toUpperCase()),
        _buildDetailRow("Status", status.toUpperCase()),
        _buildDetailRow("Login/Logout", "$login - $logout"),
        if (totalDuration != "--")
          _buildDetailRow("Total Duration", totalDuration),
        _buildDetailRow("Ideal Time", idealTime),
        _buildDetailRow("Work Time", workTime),
        _buildDetailRow("Reason", reason.isNotEmpty ? reason : "--"),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get color for action
  Color _getColorForAction(String action) {
    switch (action) {
      case 'attendance':
        return Colors.green.shade600;
      case 'halfDay':
        return Colors.orange.shade600;
      case 'leave':
        return Colors.blue.shade600;
      case 'halfDayLeave':
        return Colors.purple.shade600;
      default:
        return Colors.blue.shade600;
    }
  }

  // Helper method to get submit button text
  String _getSubmitButtonText(String action) {
    switch (action) {
      case 'attendance':
        return 'Save Full Day';
      case 'halfDay':
        return 'Save Half Day';
      case 'leave':
        return 'Save Full Day Leave';
      case 'halfDayLeave':
        return 'Save Half Day Leave';
      default:
        return 'Save';
    }
  }

  Widget _infoRow(String label, String value) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
                flex: 2,
                child: Text("$label:",
                    style: const TextStyle(color: Colors.grey))),
            Expanded(
                flex: 3,
                child: Text(value,
                    style: const TextStyle(fontWeight: FontWeight.bold))),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = workStatusDetails?.data
            .where((staff) =>
                staff.name.toLowerCase().contains(searchText.toLowerCase()))
            .toList() ??
        [];
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.staffName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Attendance Calendar",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: Color.fromARGB(255, 44, 126, 180),
        foregroundColor: Colors.white,
        centerTitle: false,
      ),
      body: isLoading || isLoadingStaffs || isLoadingWorkData
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  height: 60,
                  color: Colors.white,
                  child: Column(
                    children: [
                      Container(
                        height: 50,
                        child: Row(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: staffList.length,
                                itemBuilder: (context, index) {
                                  final staff = staffList[index];
                                  final isSelected =
                                      staff.userIdStaff == widget.staffId;

                                  return GestureDetector(
                                    onTap: () {
                                      if (staff.userIdStaff != widget.staffId) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                StaffCalendarPage(
                                              staffId: staff.userIdStaff,
                                              selectedDate: widget.selectedDate,
                                              staffName: staff.name,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(
                                        left: index == 0 ? 16 : 8,
                                        right: index == staffList.length - 1
                                            ? 8
                                            : 0,
                                        top: 8,
                                        bottom: 8,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Color.fromARGB(255, 44, 126, 180)
                                            : Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isSelected
                                              ? Color.fromARGB(
                                                  255, 44, 126, 180)
                                              : Colors.grey.shade300,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 12,
                                            backgroundColor: isSelected
                                                ? Colors.white
                                                : Colors.blueAccent,
                                            child: Text(
                                              staff.name.isNotEmpty
                                                  ? staff.name[0].toUpperCase()
                                                  : '?',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: isSelected
                                                    ? Colors.blueAccent
                                                    : Colors.white,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            staff.name,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.black87,
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
                                icon: const Icon(
                                  Icons.person,
                                  color: Colors.blueAccent,
                                  size: 24,
                                ),
                                onPressed: () => _showSmallStaffPopup(context),
                                tooltip: 'Filter Staff',
                                padding: const EdgeInsets.only(right: 0),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 1,
                        color: Colors.grey.shade300,
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: TableCalendar(
                              firstDay: DateTime.utc(2024, 1, 1),
                              lastDay: DateTime.utc(2026, 12, 31),
                              focusedDay: _focusedDay,
                              calendarFormat: CalendarFormat.month,
                              availableCalendarFormats: const {
                                CalendarFormat.month: 'Month',
                              },
                              headerStyle: HeaderStyle(
                                formatButtonVisible: false,
                                titleCentered: true,
                                leftChevronIcon: const Icon(Icons.chevron_left),
                                rightChevronIcon:
                                    const Icon(Icons.chevron_right),
                                headerPadding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                formatButtonShowsNext: false,
                              ),
                              onDaySelected: (selectedDay, focusedDay) {
                                setState(() {
                                  _focusedDay = focusedDay;
                                });
                                _showLoginLogoutPopup(selectedDay);
                              },
                              onPageChanged: (focusedDay) {
                                setState(() {
                                  _focusedDay = focusedDay;
                                  isLoading = true;
                                });
                                fetchAttendanceData(focusedDay);
                                fetchWorkDataCounts(focusedDay);
                              },
                              calendarStyle: CalendarStyle(
                                weekendTextStyle:
                                    const TextStyle(color: Colors.red),
                                defaultTextStyle: const TextStyle(fontSize: 15),
                                todayDecoration: BoxDecoration(
                                  color: Colors.teal.shade600,
                                  shape: BoxShape.circle,
                                ),
                                defaultDecoration:
                                    const BoxDecoration(shape: BoxShape.circle),
                                outsideDaysVisible: false,
                              ),
                              calendarBuilders: CalendarBuilders(
                                defaultBuilder: (context, day, _) {
                                  final key = DateTime.utc(
                                      day.year, day.month, day.day);
                                  final data = attendanceMap[key];
                                  final isHoliday = data != null &&
                                      data["status"] == "holiday";
                                  final color = _getDayColor(day);

                                  if (isHoliday) {
                                    return Container(
                                      margin: const EdgeInsets.all(6.0),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade400,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.red,
                                          width: 2.0,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '${day.day}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  } else {
                                    return Container(
                                      margin: const EdgeInsets.all(6.0),
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '${day.day}',
                                        style: TextStyle(
                                          color: color == Colors.transparent
                                              ? Colors.black
                                              : Colors.white,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                todayBuilder: (context, day, _) {
                                  final key = DateTime.utc(
                                      day.year, day.month, day.day);
                                  final data = attendanceMap[key];
                                  final isHoliday = data != null &&
                                      data["status"] == "holiday";

                                  if (isHoliday) {
                                    return Container(
                                      margin: const EdgeInsets.all(6.0),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade400,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.red,
                                          width: 2.0,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '${day.day}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  } else {
                                    return Container(
                                      margin: const EdgeInsets.all(6.0),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.green,
                                          width: 2.0,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '${day.day}',
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Card(
                          elevation: 4,
                          shadowColor: Colors.black.withOpacity(0.08),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                                color: Colors.grey.shade100, width: 1),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade600,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      "Legend",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                        color: Colors.grey.shade800,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildLegendItem(
                                            color: Colors.green.shade500,
                                            backgroundColor:
                                                Colors.green.shade50,
                                            text: "Present",
                                            icon: Icons.check_circle_rounded,
                                          ),
                                          const SizedBox(height: 14),
                                          _buildLegendItem(
                                            color: Colors.orange.shade500,
                                            backgroundColor:
                                                Colors.orange.shade50,
                                            text: "Half Day",
                                            icon: Icons.timelapse_rounded,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildLegendItem(
                                            color: Colors.red.shade500,
                                            backgroundColor: Colors.red.shade50,
                                            text: "Absent / Leave",
                                            icon: Icons.cancel_rounded,
                                          ),
                                          const SizedBox(height: 14),
                                          _buildLegendItem(
                                            color: Colors.blue.shade600,
                                            backgroundColor:
                                                Colors.blue.shade50,
                                            text: "Holiday",
                                            icon: Icons.beach_access_rounded,
                                            hasBorder: true,
                                            borderColor: Colors.blue.shade200,
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
                        // Card(
                        //   elevation: 3,
                        //   shape: RoundedRectangleBorder(
                        //     borderRadius: BorderRadius.circular(12),
                        //   ),
                        //   child: Padding(
                        //     padding: const EdgeInsets.symmetric(
                        //         horizontal: 16, vertical: 14),
                        //     child: Column(
                        //       crossAxisAlignment: CrossAxisAlignment.start,
                        //       children: [
                        //         Text(
                        //           "Legend",
                        //           style: TextStyle(
                        //             fontWeight: FontWeight.bold,
                        //             fontSize: 16,
                        //           ),
                        //         ),
                        //         const SizedBox(height: 12),
                        //         Row(
                        //           crossAxisAlignment: CrossAxisAlignment.start,
                        //           children: [
                        //             Expanded(
                        //               child: Column(
                        //                 crossAxisAlignment:
                        //                     CrossAxisAlignment.start,
                        //                 children: [
                        //                   LegendRow(
                        //                     color: Colors.green,
                        //                     borderColor: Colors.white,
                        //                     text: "Present",
                        //                     icon: Icons.check_circle,
                        //                   ),
                        //                   const SizedBox(height: 8),
                        //                   LegendRow(
                        //                     color: Colors.orange,
                        //                     borderColor: Colors.white,
                        //                     text: "Half Day",
                        //                     icon: Icons.timelapse,
                        //                   ),
                        //                 ],
                        //               ),
                        //             ),
                        //             Expanded(
                        //               child: Column(
                        //                 crossAxisAlignment:
                        //                     CrossAxisAlignment.start,
                        //                 children: [
                        //                   LegendRow(
                        //                     color: Colors.red,
                        //                     borderColor: Colors.white,
                        //                     text: "Absent/Leave",
                        //                     icon: Icons.cancel,
                        //                   ),
                        //                   const SizedBox(height: 8),
                        //                   LegendRow(
                        //                     color: Colors.blue,
                        //                     borderColor: Colors.red,
                        //                     text: "Holiday",
                        //                     icon: Icons.beach_access,
                        //                     hasBorder: true,
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
                        const SizedBox(height: 24),
                        Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Work Data",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (workDataCounts != null &&
                                    workDataCounts!.data.isNotEmpty)
                                  Column(
                                    children: [
                                      WorkRow(
                                        color: const Color.fromARGB(
                                            255, 63, 43, 151),
                                        borderColor: const Color.fromARGB(
                                            255, 34, 33, 33),
                                        label: "Total Working Days",
                                        count: workDataCounts!
                                            .data.first.totalWorkingDays,
                                        icon: Icons.work,
                                      ),
                                      const SizedBox(height: 5),
                                      WorkRow(
                                        color: const Color.fromARGB(
                                            255, 40, 155, 92),
                                        borderColor: const Color.fromARGB(
                                            255, 34, 33, 33),
                                        label: "Worked Days",
                                        count: workDataCounts!
                                            .data.first.workedDays,
                                        icon: Icons.work_history,
                                      ),
                                      const SizedBox(height: 5),
                                      WorkRow(
                                        color: const Color.fromARGB(
                                            255, 170, 25, 25),
                                        borderColor: const Color.fromARGB(
                                            255, 34, 33, 33),
                                        label: "Leave",
                                        count: workDataCounts!
                                            .data.first.leaveDays,
                                        icon: Icons.work_off,
                                      ),
                                    ],
                                  )
                                else
                                  Column(
                                    children: [
                                      WorkRow(
                                        color: const Color.fromARGB(
                                            255, 63, 43, 151),
                                        borderColor: const Color.fromARGB(
                                            255, 34, 33, 33),
                                        label: "Total Working Days",
                                        count: "0",
                                        icon: Icons.work,
                                      ),
                                      const SizedBox(height: 5),
                                      WorkRow(
                                        color: const Color.fromARGB(
                                            255, 40, 155, 92),
                                        borderColor: const Color.fromARGB(
                                            255, 34, 33, 33),
                                        label: "Worked Days",
                                        count: "0",
                                        icon: Icons.work_history,
                                      ),
                                      const SizedBox(height: 5),
                                      WorkRow(
                                        color: const Color.fromARGB(
                                            255, 170, 25, 25),
                                        borderColor: const Color.fromARGB(
                                            255, 34, 33, 33),
                                        label: "Leave",
                                        count: "0",
                                        icon: Icons.work_off,
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Attendance Report",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        final firstDayOfMonth = DateTime(
                                          _focusedDay.year,
                                          _focusedDay.month,
                                          1,
                                        );
                                        final lastDayOfMonth = DateTime(
                                          _focusedDay.year,
                                          _focusedDay.month + 1,
                                          0,
                                        );
                                        final fromDateStr =
                                            DateFormat('yyyy-MM-dd')
                                                .format(firstDayOfMonth);
                                        final toDateStr =
                                            DateFormat('yyyy-MM-dd')
                                                .format(lastDayOfMonth);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AttendanceReportListPage(
                                              staffId: widget.staffId,
                                              staffName: widget.staffName,
                                              fromDate: fromDateStr,
                                              toDate: toDateStr,
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.arrow_forward_ios,
                                          size: 18, color: Colors.blue),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (attendanceReport != null &&
                                    attendanceReport!.data != null &&
                                    attendanceReport!.data!.summary != null)
                                  Column(
                                    children: [
                                      _buildReportRow(
                                        context: context,
                                        color: const Color.fromARGB(
                                            255, 143, 46, 78),
                                        label: "Total Workable Hours",
                                        count: attendanceReport!.data!.summary!
                                                .totalWorkableTime ??
                                            "0",
                                        icon: Icons.timer,
                                      ),
                                      const SizedBox(height: 5),
                                      _buildReportRow(
                                        context: context,
                                        color: const Color.fromARGB(
                                            255, 48, 139, 139),
                                        label: "Total Worked Hours",
                                        count: attendanceReport!.data!.summary!
                                                .totalWorkingTime ??
                                            "0",
                                        icon: Icons.timer_sharp,
                                      ),
                                      const SizedBox(height: 5),
                                      _buildReportRow(
                                        context: context,
                                        color: const Color.fromARGB(
                                            255, 23, 109, 124),
                                        label: "Allowed Break Time",
                                        count: attendanceReport!.data!.summary!
                                                .totalAllowedIdleTime ??
                                            "0",
                                        icon: Icons.timeline,
                                      ),
                                      const SizedBox(height: 5),
                                      _buildReportRow(
                                        context: context,
                                        color: const Color.fromARGB(
                                            255, 21, 104, 129),
                                        label: "Break Time Taken",
                                        count: attendanceReport!
                                                .data!.summary!.totalIdleTime ??
                                            "0",
                                        icon: Icons.work_off,
                                      ),
                                      const SizedBox(height: 5),
                                      _buildReportRow(
                                        context: context,
                                        color: const Color.fromARGB(
                                            255, 20, 116, 139),
                                        label: "Effective Working Hours",
                                        count: attendanceReport!
                                                .data!.summary!.effectiveTime ??
                                            "0",
                                        icon: Icons.work_history,
                                      ),
                                    ],
                                  )
                                else
                                  Column(
                                    children: [
                                      _buildReportRow(
                                        context: context,
                                        color: const Color.fromARGB(
                                            255, 143, 46, 78),
                                        label: "Total Workable Hours",
                                        count: "0",
                                        icon: Icons.timer,
                                      ),
                                      const SizedBox(height: 5),
                                      _buildReportRow(
                                        context: context,
                                        color: const Color.fromARGB(
                                            255, 48, 139, 139),
                                        label: "Total Worked Hours",
                                        count: "0",
                                        icon: Icons.timer,
                                      ),
                                      const SizedBox(height: 5),
                                      _buildReportRow(
                                        context: context,
                                        color: const Color.fromARGB(
                                            255, 23, 109, 124),
                                        label: "Allowed Break Time",
                                        count: "0",
                                        icon: Icons.timeline,
                                      ),
                                      const SizedBox(height: 5),
                                      _buildReportRow(
                                        context: context,
                                        color: const Color.fromARGB(
                                            255, 21, 104, 129),
                                        label: "Break Time Taken",
                                        count: "0",
                                        icon: Icons.work_off,
                                      ),
                                      const SizedBox(height: 5),
                                      _buildReportRow(
                                        context: context,
                                        color: const Color.fromARGB(
                                            255, 20, 116, 139),
                                        label: "Effective Working Hours",
                                        count: "0",
                                        icon: Icons.work_history,
                                      ),
                                    ],
                                  ),
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
    );
  }
}

class LegendRow extends StatelessWidget {
  final Color color;
  final Color borderColor;
  final String text;
  final IconData icon;
  final bool hasBorder;

  const LegendRow({
    Key? key,
    required this.color,
    required this.borderColor,
    required this.text,
    required this.icon,
    this.hasBorder = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            border: hasBorder ? Border.all(color: borderColor, width: 2) : null,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            icon,
            size: 14,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}

Widget _buildReportRow({
  required BuildContext context,
  required Color color,
  required String label,
  required String count,
  required IconData icon,
}) {
  // Format the time string to be more compact
  String formattedCount = count;

  // Check if the count is in "X hr Y m Z s" format and simplify it
  if (count.contains('hr') && count.contains('m') && count.contains('s')) {
    // Remove spaces to make it more compact
    formattedCount = count.replaceAll(' ', '');
    // Or you can convert to a shorter format like "7h 45m"
    final hoursMatch = RegExp(r'(\d+)\s*hr').firstMatch(count);
    final minutesMatch = RegExp(r'(\d+)\s*m').firstMatch(count);

    if (hoursMatch != null && minutesMatch != null) {
      final hours = hoursMatch.group(1);
      final minutes = minutesMatch.group(1);
      formattedCount = '${hours}h ${minutes}m';
    }
  }

  return Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
    ),
    child: Row(
      children: [
        // Icon container
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        // Label - Expanded to take available space
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Value - Fixed width for numbers
        Container(
          constraints: const BoxConstraints(minWidth: 80),
          child: Text(
            formattedCount,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

Widget _buildLegendItem({
  required Color color,
  required Color backgroundColor,
  required String text,
  required IconData icon,
  bool hasBorder = false,
  Color? borderColor,
}) {
  return Row(
    children: [
      Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: hasBorder && borderColor != null
              ? Border.all(color: borderColor, width: 1.5)
              : null,
        ),
        child: Icon(
          icon,
          size: 18,
          color: color,
        ),
      ),
      const SizedBox(width: 12),
      Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade700,
        ),
      ),
    ],
  );
}

class WorkRow extends StatelessWidget {
  final Color color;
  final Color borderColor;
  final String label;
  final String count;
  final IconData icon;
  final bool hasBorder;

  const WorkRow({
    Key? key,
    required this.color,
    required this.borderColor,
    required this.label,
    required this.count,
    required this.icon,
    this.hasBorder = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: hasBorder
                      ? Border.all(color: borderColor, width: 2)
                      : null,
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(
            width: 42,
          ),
          Text(
            count,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

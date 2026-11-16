import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/lead_management/getAttendanceReportModel.dart';
import 'package:login2/service/service.dart';

class AttendanceReportListPage extends StatefulWidget {
  final String staffId;
  final String staffName;
  final String fromDate;
  final String toDate;

  const AttendanceReportListPage({
    super.key,
    required this.staffId,
    required this.staffName,
    required this.fromDate,
    required this.toDate,
  });

  @override
  State<AttendanceReportListPage> createState() =>
      _AttendanceReportListPageState();
}

class _AttendanceReportListPageState extends State<AttendanceReportListPage> {
  late Future<GetAttendanceReportModel?> reportFuture;
  late String _fromDate;
  late String _toDate;
  late TextEditingController _remarkController;
  bool _isSubmittingRemark = false;
  @override
  void initState() {
    super.initState();
    _fromDate = widget.fromDate;
    _toDate = widget.toDate;
    _remarkController = TextEditingController();
    _loadData();
  }

  String? addAttendanceRemarks;
  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    addAttendanceRemarks = await Common.getSharedPref("addAttendanceRemarks");
    setState(() {
      reportFuture = HttpService.getAttendanceReport(
        _fromDate,
        _toDate,
        widget.staffId,
      );
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: DateFormat('yyyy-MM-dd').parse(_fromDate),
        end: DateFormat('yyyy-MM-dd').parse(_toDate),
      ),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _fromDate = DateFormat('yyyy-MM-dd').format(picked.start);
        _toDate = DateFormat('yyyy-MM-dd').format(picked.end);
        _loadData();
      });
    }
  }

  Future<void> _submitRemark(ListData item) async {
    if (_remarkController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a remark"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmittingRemark = true;
    });

    try {
      final response = await HttpService.updateAttendanceRemark(
        attendanceId: item.id ?? "",
        // staffId: widget.staffId,
        //   date: item.date,
        remark: _remarkController.text.trim(),
      );
      if (response != null && response['status'] == true) {
        if (mounted) Navigator.pop(context);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Remark updated successfully"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
        _loadData();
      } else {
        throw Exception(response?['message'] ?? "Failed to update remark");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingRemark = false;
        });
      }
    }
  }

  // Future<void> _submitRemark(ListData item) async {
  //   if (_remarkController.text.trim().isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text("Please enter a remark"),
  //         backgroundColor: Colors.orange,
  //       ),
  //     );
  //     return;
  //   }

  //   setState(() {
  //     _isSubmittingRemark = true;
  //   });

  //   try {
  //     final response = await HttpService.updateAttendanceRemark(
  //       attendanceId: item.id ?? "",
  //      // staffId: widget.staffId,
  //     //  date: item.date,
  //       remark: _remarkController.text.trim(),
  //     );

  //     if (response != null && response['success'] == true) {
  //       if (mounted) Navigator.pop(context);
  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //             content: Text("Remark updated successfully"),
  //             backgroundColor: Colors.green,
  //             duration: Duration(seconds: 2),
  //           ),
  //         );
  //       }
  //       _loadData();
  //     } else {
  //       throw Exception(response?['message'] ?? "Failed to update remark");
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text("Error: ${e.toString()}"),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   } finally {
  //     if (mounted) {
  //       setState(() {
  //         _isSubmittingRemark = false;
  //       });
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Attendance Report",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Text(
              widget.staffName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 44, 126, 180),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.date_range),
              onPressed: () => _selectDateRange(context),
              tooltip: 'Select Date Range',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Date Range",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${_formatDateForDisplay(_fromDate)} - ${_formatDateForDisplay(_toDate)}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 44, 126, 180)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${_getDaysDifference(_fromDate, _toDate)} Days",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 44, 126, 180),
                    ),
                  ),
                ),
              ],
            ),
          ),
          FutureBuilder<GetAttendanceReportModel?>(
            future: reportFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data?.data?.summary != null) {
                final summary = snapshot.data!.data!.summary!;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildSummaryStats(summary),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Daily Reports",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                FutureBuilder<GetAttendanceReportModel?>(
                  future: reportFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data?.data?.list != null) {
                      return Text(
                        "${snapshot.data!.data!.list!.length} records",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
          // List View
          Expanded(
            child: FutureBuilder<GetAttendanceReportModel?>(
              future: reportFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text(
                          "Loading attendance data...",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Error: ${snapshot.error}",
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 44, 126, 180),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData ||
                    snapshot.data!.data == null ||
                    snapshot.data!.data!.list == null ||
                    snapshot.data!.data!.list!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No attendance records found",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Try selecting a different date range",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final list = snapshot.data!.data!.list!;
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return _buildAttendanceCard(item);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStats(Summary summary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color.fromARGB(255, 44, 126, 180),
            const Color.fromARGB(255, 77, 173, 252),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                label: "Worked Hours",
                value: _formatTimeShort(summary.totalWorkingTime ?? "0"),
                icon: Icons.access_time_filled,
                color: Colors.white,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildStatItem(
                label: "Break Taken",
                value: _formatTimeShort(summary.totalIdleTime ?? "0"),
                icon: Icons.coffee,
                color: Colors.white,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildStatItem(
                label: "Effective",
                value: _formatTimeShort(summary.effectiveTime ?? "0"),
                icon: Icons.work,
                color: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.white.withOpacity(0.3)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                label: "Workable Hours",
                value: _formatTimeShort(summary.totalWorkableTime ?? "0"),
                icon: Icons.schedule,
                color: Colors.white,
                small: true,
              ),
              _buildStatItem(
                label: "Allowed Break",
                value: _formatTimeShort(summary.totalAllowedIdleTime ?? "0"),
                icon: Icons.timeline,
                color: Colors.white,
                small: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    bool small = false,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: small ? 18 : 22, color: color.withOpacity(0.9)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: small ? 15 : 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: small ? 10 : 11,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(ListData item) {
    // Determine status color
    Color statusColor;
    IconData statusIcon;
    switch (item.status?.toLowerCase()) {
      case 'full day':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'half day':
        statusColor = Colors.orange;
        statusIcon = Icons.timelapse;
        break;
      case 'absent':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 'leave':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 'present':
        statusColor = Colors.yellow.shade700;
        statusIcon = Icons.check_circle;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    return Card(
      elevation: 2,
      color: item.status?.toLowerCase() == 'leave'
          ? Colors.red.shade50
          : Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          _showAttendanceDetailsDialog(item);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row with Date and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 44, 126, 180)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Color.fromARGB(255, 44, 126, 180),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatDate(item.date ?? "N/A"),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color.fromARGB(255, 44, 126, 180),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        item.logoutStatus == "Manual"
                            ? Icon(
                                Icons.check_circle,
                                size: 14,
                                color: Colors.green,
                              )
                            : Icon(
                                FontAwesomeIcons.robot,
                                size: 14,
                                color: Colors.green,
                              ),
                        const SizedBox(width: 4),
                        Text(
                          item.logoutStatus ?? "N/A",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            //color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcon,
                          size: 14,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.status ?? "N/A",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
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
                    child: _buildTimeCard(
                      label: "Login",
                      time: item.loginTime ?? "--:--",
                      icon: Icons.login,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTimeCard(
                      label: "Logout",
                      time: item.logoutTime ?? "--:--",
                      icon: Icons.logout,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: item.status?.toLowerCase() == 'leave'
                      ? Colors.red.shade100.withOpacity(0.5)
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatRow(
                            label: "Working Time",
                            value: _formatTimeShort(item.workingTime ?? "0"),
                            icon: Icons.timer,
                            color: Colors.blue,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.grey.shade300,
                        ),
                        Expanded(
                          child: _buildStatRow(
                            label: "Idle Time",
                            value: _formatTimeShort(item.idleTime ?? "0"),
                            icon: Icons.timer_off,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Colors.grey.shade300,
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Remarks",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.remarks?.isNotEmpty == true
                                      ? item.remarks!
                                      : "No remarks added",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: item.remarks?.isNotEmpty == true
                                        ? Colors.black87
                                        : Colors.grey.shade500,
                                    fontStyle: item.remarks?.isNotEmpty == true
                                        ? FontStyle.normal
                                        : FontStyle.italic,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          addAttendanceRemarks != "false"
                              ? IconButton(
                                  icon: const Icon(Icons.edit_note, size: 20),
                                  color:
                                      const Color.fromARGB(255, 44, 126, 180),
                                  onPressed: () => _showEditRemarkDialog(item),
                                  tooltip: "Edit Remark",
                                )
                              : SizedBox(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Container(
              //   padding: const EdgeInsets.all(12),
              //   decoration: BoxDecoration(
              //     color: Colors.grey.shade50,
              //     borderRadius: BorderRadius.circular(12),
              //   ),
              //   child: Row(
              //     children: [
              //       Expanded(
              //         child: _buildStatRow(
              //           label: "Working Time",
              //           value: _formatTimeShort(item.workingTime ?? "0"),
              //           icon: Icons.timer,
              //           color: Colors.blue,
              //         ),
              //       ),
              //       Container(
              //         width: 1,
              //         height: 30,
              //         color: Colors.grey.shade300,
              //       ),
              //       Expanded(
              //         child: _buildStatRow(
              //           label: "Idle Time",
              //           value: _formatTimeShort(item.idleTime ?? "0"),
              //           icon: Icons.timer_off,
              //           color: Colors.orange,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeCard({
    required String label,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 6),
          Text(
            time,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showAttendanceDetailsDialog(ListData item) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(item.date ?? "N/A"),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 28, 77, 109),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 24),
              _buildDetailRow("Status", item.status ?? "N/A"),
              const SizedBox(height: 12),
              _buildDetailRow("Login Time", item.loginTime ?? "--:--"),
              const SizedBox(height: 12),
              _buildDetailRow("Logout Time", item.logoutTime ?? "--:--"),
              const SizedBox(height: 12),
              _buildDetailRow("Working Time", item.workingTime ?? "0"),
              const SizedBox(height: 12),
              _buildDetailRow("Idle Time", item.idleTime ?? "0"),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 44, 126, 180),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Close"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  void _showEditRemarkDialog(ListData item) {
    _remarkController.text = item.remarks ?? "";

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.edit_note,
                  color: const Color.fromARGB(255, 44, 126, 180),
                ),
                const SizedBox(width: 8),
                const Text("Edit Remark"),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Date: ${_formatDate(item.date ?? "N/A")}",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _remarkController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Enter remark...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed:
                    _isSubmittingRemark ? null : () => _submitRemark(item),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 44, 126, 180),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSubmittingRemark
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("Save Remark",
                        style: TextStyle(fontSize: 14, color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateFormat('dd-MM-yyyy').parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _formatDateForDisplay(String dateStr) {
    try {
      final date = DateFormat('yyyy-MM-dd').parse(dateStr);
      return DateFormat('dd MMM').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _formatTimeShort(String timeStr) {
    if (timeStr == "0" || timeStr.isEmpty) return "0h";

    // Format "7 hr 45 m 24 s" to "7h 45m"
    final hoursMatch = RegExp(r'(\d+)\s*hr').firstMatch(timeStr);
    final minutesMatch = RegExp(r'(\d+)\s*m').firstMatch(timeStr);

    if (hoursMatch != null && minutesMatch != null) {
      return "${hoursMatch.group(1)}h ${minutesMatch.group(1)}m";
    } else if (hoursMatch != null) {
      return "${hoursMatch.group(1)}h";
    } else if (minutesMatch != null) {
      return "${minutesMatch.group(1)}m";
    }
    return timeStr;
  }

  int _getDaysDifference(String fromDate, String toDate) {
    try {
      final start = DateFormat('yyyy-MM-dd').parse(fromDate);
      final end = DateFormat('yyyy-MM-dd').parse(toDate);
      return end.difference(start).inDays + 1;
    } catch (e) {
      return 0;
    }
  }
}

// settings_menu_widget.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/screens/leadManagement/viewLeadsNew.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:login2/core/common.dart';
import 'package:login2/screens/callLogs/callLogs.dart';
import 'package:login2/screens/leadManagement/AssignReport.dart';
import 'package:login2/screens/leadManagement/ViewAllTargetReportPage.dart';
import 'package:login2/screens/leadManagement/allReport.dart';
import 'package:login2/screens/leadManagement/attendanceCalendar.dart';
import 'package:login2/screens/leadManagement/callHistoryPage.dart';
import 'package:login2/screens/leadManagement/pendingWorkPage.dart';
import 'package:login2/screens/leadManagement/salaryReportPage.dart';
import 'package:login2/screens/leadManagement/viewLeadCategory.dart';
import 'package:login2/screens/leadManagement/viewLeads.dart';
import 'package:login2/screens/leadManagement/viewallcompanyworks.dart';
import 'package:login2/screens/leadManagement/viewwork_page.dart';
import 'package:login2/screens/staff_reports/timeline_page.dart';
import 'package:login2/service/service.dart';

class SettingsMenuWidget extends StatefulWidget {
  final String token;
  final String? name;
  final String? userId;
  final String? staffId;
  final bool isExpired;
  final dynamic configure;
  final dynamic leadDashboard;
  final String fromdate;
  final String todate;
  final bool loadmore;
  final VoidCallback onDataRefresh;
  final VoidCallback onStaffwiseRefresh;

  const SettingsMenuWidget({
    super.key,
    required this.token,
    this.name,
    this.userId,
    this.staffId,
    required this.isExpired,
    this.configure,
    this.leadDashboard,
    required this.fromdate,
    required this.todate,
    required this.loadmore,
    required this.onDataRefresh,
    required this.onStaffwiseRefresh,
  });

  @override
  State<SettingsMenuWidget> createState() => _SettingsMenuWidgetState();
}

class _SettingsMenuWidgetState extends State<SettingsMenuWidget> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;

  // Permission variables
  String? adminCheckPermission;
  String? viewAllWorkPermission;
  String? viewAttendanceSection;
  String? approvePayroll;
  String? viewPendingWorks;
  String? assignWork;
  String? viewTargetReportPermission;
  String? multipleWorksCheck;
  String? viewWorkReportPermission;
  String? viewLeadPermission;
  String? accessCallHistoryPermission;
  bool accessCallRecordingPermission1 = false;
  bool createLeadCategory1 = false;
  bool updateLeadCategory1 = false;
  bool deleteLeadCategory1 = false;
  bool updateLeadPermission1 = false;
  bool deleteLeadPermission1 = false;
  bool cloudCallPermission1 = false;
  bool viewLeadCategoryPermission1 = false;

  @override
  void initState() {
    super.initState();
    _loadPermissions();
  }

  Future<void> _loadPermissions() async {
    final prefs = await SharedPreferences.getInstance();

    // Load string permissions
    adminCheckPermission = prefs.getString('adminCheckPermission') ?? '';
    viewAllWorkPermission = prefs.getString('viewAllWorkPermission') ?? '';
    viewAttendanceSection = prefs.getString('viewAttendanceSection') ?? '';
    approvePayroll = prefs.getString('approvePayroll') ?? '';
    viewPendingWorks = prefs.getString('viewPendingWorks') ?? '';
    assignWork = prefs.getString('assignWork') ?? '';
    viewTargetReportPermission =
        prefs.getString('viewTargetReportPermission') ?? '';
    multipleWorksCheck = prefs.getString('multipleWorks') ?? '';
    viewWorkReportPermission =
        prefs.getString('viewWorkReportPermission') ?? '';
    viewLeadPermission = prefs.getString('viewLeadPermission') ?? '';
    accessCallHistoryPermission =
        prefs.getString('accessCallHistoryPermission') ?? '';

    // Load boolean permissions
    final accessCallRecordingPermission =
        prefs.getString('accessCallRecordingPermission') ?? 'false';
    final createLeadCategory = prefs.getString('createLeadCategory') ?? 'false';
    final updateLeadCategory = prefs.getString('updateLeadCategory') ?? 'false';
    final deleteLeadCategory = prefs.getString('deleteLeadCategory') ?? 'false';
    final updateLeadPermission =
        prefs.getString('updateLeadPermission') ?? 'false';
    final deleteLeadPermission =
        prefs.getString('deleteLeadPermission') ?? 'false';
    final cloudCallPermission =
        prefs.getString('cloudCallPermission') ?? 'false';
    final viewLeadCategoryPermission =
        prefs.getString('viewLeadCategoryPermission') ?? 'false';
    accessCallRecordingPermission1 = accessCallRecordingPermission == 'true';
    createLeadCategory1 = createLeadCategory == 'true';
    updateLeadCategory1 = updateLeadCategory == 'true';
    deleteLeadCategory1 = deleteLeadCategory == 'true';
    updateLeadPermission1 = updateLeadPermission == 'true';
    deleteLeadPermission1 = deleteLeadPermission == 'true';
    cloudCallPermission1 = cloudCallPermission == 'true';
    viewLeadCategoryPermission1 = viewLeadCategoryPermission == 'true';

    if (mounted) {
      setState(() {});
    }
  }

  void _dialogue(BuildContext context, String permissionName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Access Denied"),
          content: Text("You don't have permission to access $permissionName"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.configure != null &&
        widget.isExpired == false &&
        widget.leadDashboard != null) {
      return _buildMenuButton(context);
    }
    return const SizedBox();
  }

  Widget _buildMenuButton(BuildContext context) {
    return Container(
      width: 35,
      height: 35,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(17.5),
        child: InkWell(
          borderRadius: BorderRadius.circular(17.5),
          onTap: () {
            _showSettingsDrawer(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              "assets/icons/menu.png",
              width: 20,
            ),
          ),
        ),
      ),
    );
  }

  void _showSettingsDrawer(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height,
              margin: const EdgeInsets.only(top: 0, right: 0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  topLeft: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header with gradient like in example
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 16),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF406dbe),
                          Colors.white,
                          Color(0xFF406dbe),
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.settings,
                            color: Colors.white, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Center(
                            child: Image.asset('assets/main/funriders.png',
                                height: 130, fit: BoxFit.contain),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildMenuItemsList(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );
  }

  Widget _buildMenuItemTitle({
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      decoration: TextDecoration.underline, // Add underline
                      decorationColor: Colors.blue, // Blue underline color
                      decorationThickness: 2.0, // Thickness of underline
                      decorationStyle: TextDecorationStyle.solid, // Solid line
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMenuItemsList(BuildContext context) {
    final menuItems = <Widget>[];

    // Quick Actions Section
    menuItems.addAll([
      //_buildSectionHeader('Quick Actions'),
      _buildMenuItemTitle(
        // icon: Icons.pending_actions_rounded,
        title: 'Quick Actions',
        onTap: () {
          // Navigator.pop(context);
          //  _handleMenuItemTap(context, 2);
        },
      ),
      _buildMenuItem(
        iconImage: "assets/icons/all_reports.png",
        title: 'All Report',
        onTap: () {
          Navigator.pop(context);
          _handleMenuItemTap(context, 9);
        },
      ),
      if (viewLeadCategoryPermission1)
        _buildMenuItem(
          iconImage: "assets/icons/leadCategory.png",
          title: 'Lead Category',
          onTap: () {
            Navigator.pop(context);
            _handleMenuItemTap(context, 2);
          },
        ),
      _buildMenuItem(
        iconImage: "assets/icons/callHistory.png",
        title: 'Call History',
        onTap: () {
          Navigator.pop(context);
          _handleMenuItemTap(context, 6);
        },
      ),
    ]);

    // Add View Target Report conditionally
    if (viewTargetReportPermission == 'true') {
      menuItems.add(_buildMenuItem(
        icon: Icons.track_changes,
        title: 'View Target Report',
        onTap: () {
          Navigator.pop(context);
          _handleMenuItemTap(context, 105);
        },
      ));
    }

    menuItems.add(_buildDivider());

    // Lead Management Section
    menuItems.add(
      // _buildSectionHeader('Lead Management')
      _buildMenuItemTitle(
        // icon: Icons.pending_actions_rounded,
        title: 'Lead Management',
        onTap: () {
          // Navigator.pop(context);
          //  _handleMenuItemTap(context, 2);
        },
      ),
    );

    if (viewLeadPermission == 'true') {
      menuItems.addAll([
        // _buildMenuItem(
        //   icon: Icons.people,
        //   title: 'View Leads',
        //   onTap: () {
        //     Navigator.pop(context);
        //     _handleMenuItemTap(context, 5);
        //   },
        // ),
        _buildMenuItem(
          icon: Icons.phone_missed,
          title: 'Missed Leads',
          onTap: () {
            Navigator.pop(context);
            _handleMenuItemTap(context, 7);
          },
        ),
        _buildMenuItem(
          icon: Icons.swap_horiz,
          title: 'Transfer Leads',
          onTap: () {
            Navigator.pop(context);
            _handleMenuItemTap(context, 8);
          },
        ),
      ]);
    }

    menuItems.add(_buildMenuItem(
      icon: Icons.phone,
      title: 'Call Logs',
      onTap: () {
        Navigator.pop(context);
        _handleMenuItemTap(context, 10);
      },
    ));
    menuItems.add(_buildDivider());

    return menuItems;
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Divider(
        height: 1,
        color: Colors.grey.shade300,
      ),
    );
  }

  Widget _buildMenuItem({
    IconData? icon,
    String? iconImage,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                // decoration: BoxDecoration(
                //   borderRadius: BorderRadius.circular(8),
                //   color: const Color.fromARGB(255, 2, 6, 15).withOpacity(0.1),
                // ),
                child: Center(
                  child: iconImage != null
                      ? Image.asset(
                          iconImage,
                          width: 22,
                          height: 22,
                          color: const Color.fromARGB(255, 1, 4, 8),
                        )
                      : Icon(
                          icon ?? Icons.settings, // Provide a default icon
                          size: 22,
                          color: const Color.fromARGB(255, 1, 4, 10),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    // fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMenuItemTap(BuildContext context, int value) {
    _onMenuItemSelected(context, value);
  }

  void _onMenuItemSelected(BuildContext context, int value) async {
    switch (value) {
      case 11:
        setState(() {
          isLoading = true;
        });
        await getSharedData();
        setState(() {
          isLoading = false;
        });
        break;

      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewLeadCategory(
              widget.token,
              createLeadCategory1,
              updateLeadCategory1,
              deleteLeadCategory1,
            ),
          ),
        );
        break;

      case 5:
        Common.saveSharedPref("statusWise", 'no');
        if (viewLeadPermission == 'true') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewLeadsNew(
                widget.token,
                updateLeadPermission1,
                deleteLeadPermission1,
                cloudCallPermission1,
                pageName: 'View Leads',
                fromDate: widget.fromdate,
                toDate: widget.todate,
              ),
            ),
          ).then((r) {
            widget.onDataRefresh();
            if (widget.loadmore) {
              widget.onStaffwiseRefresh();
            }
          });
        } else {
          _dialogue(context, 'View Leads');
        }
        break;

      case 6:
        if (accessCallHistoryPermission == 'true') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CallHistoryPage(
                widget.token,
                widget.name!,
                widget.userId!,
                accessCallRecordingPermission1,
              ),
            ),
          );
        } else {
          _dialogue(context, 'Call History');
        }
        break;

      case 7:
        Common.saveSharedPref("statusWise", 'no');
        if (viewLeadPermission == 'true') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewLeadsNew(
                widget.token,
                updateLeadPermission1,
                deleteLeadPermission1,
                cloudCallPermission1,
                pageName: 'Missed Leads',
                fromDate: widget.fromdate,
                toDate: widget.todate,
                leadType: '1',
                callStatus: "-1",
              ),
            ),
          ).then((r) {
            widget.onDataRefresh();
            if (widget.loadmore) {
              widget.onStaffwiseRefresh();
            }
          });
        } else {
          _dialogue(context, 'View Leads');
        }
        break;

      case 8:
        Common.saveSharedPref("statusWise", 'no');
        if (viewLeadPermission == 'true') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewLeadsNew(
                widget.token,
                updateLeadPermission1,
                deleteLeadPermission1,
                cloudCallPermission1,
                pageName: 'Transfer Leads',
                fromDate: widget.fromdate,
                toDate: widget.todate,
                leadType: '2',
              ),
            ),
          ).then((r) {
            widget.onDataRefresh();
            if (widget.loadmore) {
              widget.onStaffwiseRefresh();
            }
          });
        } else {
          _dialogue(context, 'View Leads');
        }
        break;

      case 9:
        Common.saveSharedPref("statusWise", 'no');
        if (viewLeadPermission == 'true') {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => AllReport(
          //       widget.token,
          //       updateLeadPermission1,
          //       deleteLeadPermission1,
          //       cloudCallPermission1,
          //       pageName: 'AllLeads',
          //     ),
          //   ),
          // );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewLeadsNew(
                widget.token,
                updateLeadPermission1,
                deleteLeadPermission1,
                cloudCallPermission1,
                pageName: 'All Leads',
                isAllLeads: "1",
                fromDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                toDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
              ),
            ),
          );
        } else {
          _dialogue(context, 'View Leads');
        }
        break;

      case 10:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CallLogs(
              widget.token,
              widget.name,
              widget.userId,
            ),
          ),
        ).then((r) {
          widget.onDataRefresh();
          if (widget.loadmore) {
            widget.onStaffwiseRefresh();
          }
        });
        break;

      case 100: // View Works
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ViewCompanyWorkPage(),
          ),
        );
        break;

      case 101: // View Attendance
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ViewCalendarPage(),
          ),
        );
        break;

      case 102: // Salary Report
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SalaryReportPage(),
          ),
        );
        break;

      case 103: // Pending Works
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PendingWorkPage(),
          ),
        );
        break;

      case 104: // Assigned Works
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AssignReport(workId: "", sectionId: ""),
          ),
        );
        break;

      case 105: // View Target Report
        if (widget.userId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewAllTargetReportPage(id: widget.userId!),
            ),
          );
        }
        break;

      case 106: // View Work
        _handleViewWork(context);
        break;

      case 107: // View Work Report
        if (widget.userId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TimelinePage(),
              settings: RouteSettings(arguments: {
                "staffId": widget.userId,
              }),
            ),
          );
        }
        break;
    }
  }

  Future<void> _handleViewWork(BuildContext context) async {
    if (widget.staffId == null) return;

    final workStatusModel = await HttpService.getWorkStatus();

    if (multipleWorksCheck == "true") {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Phone Call Log"),
            content: const Text("Choose an action below"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ViewWorkPage(staffId: widget.staffId!),
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
                      builder: (_) => const TimelinePage(),
                      settings:
                          RouteSettings(arguments: {"staffId": widget.userId}),
                    ),
                  );
                },
                child: const Text("Call Log"),
              ),
            ],
          );
        },
      );
    } else if (multipleWorksCheck == "phone") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const TimelinePage(),
          settings: RouteSettings(arguments: {"staffId": widget.staffId}),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ViewWorkPage(staffId: widget.staffId!),
        ),
      );
    }
  }

  Future<void> getSharedData() async {
    // Implement your shared data fetching logic here
  }
}

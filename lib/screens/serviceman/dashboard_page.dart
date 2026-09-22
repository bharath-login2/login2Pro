import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/commonConfigureModel.dart';
import 'package:login2/screens/accounts/dashboard/accounts_dashboard.dart';
import 'package:login2/screens/accounts/renewal_mannagement/renewal_dashboard.dart';
import 'package:login2/screens/authentication/login.dart';
import 'package:login2/screens/bottom_navigation_bar.dart';
import 'package:login2/screens/homePage.dart';
import 'package:login2/screens/leadManagement/dashboard.dart';
import 'package:login2/screens/leadManagement/dashboardLeadsNewUpdated2.dart';
import 'package:login2/screens/leadManagement/minimalDashboard.dart';
import 'package:login2/screens/leadManagement/projectDashboard.dart';
import 'package:login2/screens/serviceman/bottomNavBar.dart';
import 'package:login2/screens/serviceman/dashboard_card.dart';
import 'package:login2/screens/serviceman/notificationPage.dart';
import 'package:login2/screens/serviceman/sideBar.dart';
import 'package:login2/screens/serviceman/workCategoryWidget.dart';
import 'package:login2/screens/serviceman/workList.dart';
import 'package:login2/screens/serviceman/work_card.dart';
import 'package:login2/service/service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'work_status_page.dart';
import 'work_category_page.dart';
import 'expense_income_page.dart';
import 'serviceCollectionListPage.dart';
import 'work_progress_page.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/serviceman/workModel.dart';
import 'package:login2/models/serviceman/serviceDashboardCountsModel.dart';
import 'package:login2/models/serviceman/serviceCollectionModel.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isSwitched = false;
  int _selectedIndex = 0;
  String staffName = "";
  String phoneCallLogPermission = '';
  String? ProjectDashboardPermission;
  String? AccountsDashboardPermission;
  String? MenuDashboard;
  String? RenewalDashboardPermission;
  String? NewleadDashboardPermission;
  String name = '';
  String role = '';
  String userId = '';
  String token = '';
  int notificationCount = 0;
  String profilePic = '';
  CommonConfigureModel? configure;

  List<WorkOrder> ongoingWorkOrders = [];
  bool isLoadingOngoingWorks = true;

  ServiceDashboardCountsData? dashboardCounts;
  bool isLoadingDashboardCounts = true;

  List<ServiceCollectionRecord> recentPaymentReports = [];
  bool isLoadingRecentPaymentReports = true;

  @override
  void initState() {
    super.initState();
    _loadStaffName();
    _setupFirebaseMessaging();
    _fetchOngoingWorks();
    _fetchDashboardCounts();
    _fetchRecentPaymentReports();
  }

  Future<void> _fetchOngoingWorks() async {
    setState(() => isLoadingOngoingWorks = true);
    final today = DateTime.now().toIso8601String().split('T').first;
    final staffId = await Common.getSharedPref("staff_id") ?? "1";
    try {
      final httpService = HttpService();
      final model = await httpService.getWorkList(
        staffId,
        today,
        "3",
      );
      if (model != null && model.data?.lists != null) {
        setState(() {
          ongoingWorkOrders = model.data!.lists!;
        });
      }
    } catch (e) {
      debugPrint("Error fetching ongoing work list: $e");
    } finally {
      setState(() => isLoadingOngoingWorks = false);
    }
  }

  Future<void> _fetchDashboardCounts() async {
    setState(() => isLoadingDashboardCounts = true);
    try {
      final httpService = HttpService();
      final model = await httpService.getServiceDashboardCounts();
      if (model != null && model.status == true && model.data != null) {
        setState(() {
          dashboardCounts = model.data;
        });
      }
    } catch (e) {
      debugPrint("Error fetching service dashboard counts: $e");
    } finally {
      setState(() => isLoadingDashboardCounts = false);
    }
  }

  Future<void> _fetchRecentPaymentReports() async {
    setState(() => isLoadingRecentPaymentReports = true);
    try {
      final httpService = HttpService();
      final model = await httpService.getServiceCollection(2);
      if (model != null && model.status == true && model.data?.records != null) {
        setState(() {
          recentPaymentReports = model.data!.records!;
        });
      }
    } catch (e) {
      debugPrint("Error fetching recent payment reports: $e");
    } finally {
      setState(() => isLoadingRecentPaymentReports = false);
    }
  }

  void _setupFirebaseMessaging() async {
    await Firebase.initializeApp();
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');
    String? token = await messaging.getToken();
    print('FCM Token: $token');
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message: ${message.notification?.title}');
      _showLocalNotification(message);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification clicked: ${message.data}');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => NotificationPageService()),
      );
    });
  }

  void _showLocalNotification(RemoteMessage message) {
    final snackBar = SnackBar(
      content: Text(
        message.notification?.title ?? "New Notification",
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: const Color(0xFF2a86c9),
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      debugPrint("Home clicked");
    } else if (index == 1) {
      debugPrint("Expense clicked");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ExpenseIncomePage()),
      );
    }
  }

  void _refreshPage() {
    debugPrint("Page Refreshed!");
    _fetchOngoingWorks();
    _fetchDashboardCounts();
    _fetchRecentPaymentReports();
    setState(() {});
  }

  String _formatAmount(num? amount) {
    if (amount == null || amount == 0) return "0";
    if (amount % 1 == 0) {
      return NumberFormat("#,##,##0", "en_IN").format(amount.toInt());
    }
    return NumberFormat("#,##,##0.00", "en_IN").format(amount);
  }

  Future<void> _loadStaffName() async {
    final prefs = await SharedPreferences.getInstance();
    phoneCallLogPermission =
        await Common.getSharedPref("phoneCallLogPermission");
    name = await Common.getSharedPref("name");
    role = await Common.getSharedPref("role");
    userId = await Common.getSharedPref("userId");
    token = await Common.getSharedPref("token");
    final String pPic = await Common.getSharedPref("profile_pic") ?? "";
    configure = await HttpService.configure(token);
    ProjectDashboardPermission =
        await Common.getSharedPref("ProjectDashboardPermission");
    AccountsDashboardPermission =
        await Common.getSharedPref("AccountsDashboardPermission");
    MenuDashboard = await Common.getSharedPref("MenuDashboard");
    RenewalDashboardPermission =
        await Common.getSharedPref("RenewalDashboardPermission");
    NewleadDashboardPermission =
        await Common.getSharedPref("NewleadDashboardPermission");
    setState(() {
      staffName = prefs.getString('staff_name') ?? "Staff";
      profilePic = pPic;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF2a86c9),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      key: _scaffoldKey,
      endDrawer: const SideBar(),
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(MediaQuery.of(context).size.height * 0.08),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: const BoxDecoration(
            gradient:
                LinearGradient(colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
          ),
          child: Padding(
            padding: const EdgeInsets.only(
                left: 10.0, top: 10.0, bottom: 10.0, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () async {
                        final shouldLogout = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Confirm Logout"),
                            content:
                                const Text("Are you sure you want to log out?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 145, 141, 141),
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Logout"),
                              ),
                            ],
                          ),
                        );
                        if (shouldLogout == true) {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.remove('token');
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const Login()),
                              (route) => false,
                            );
                          }
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 2,
                              color: Colors.grey.shade800,
                              offset: const Offset(0, 2.0),
                            )
                          ],
                          shape: BoxShape.circle,
                          color: const Color(0xFF2191ce),
                        ),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundImage: (profilePic.isNotEmpty)
                              ? NetworkImage(profilePic)
                              : const AssetImage(
                                      "assets/icons/profile_placeholder.png")
                                  as ImageProvider,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name.isNotEmpty ? name : staffName,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          role.isNotEmpty ? role : "Serviceman",
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NotificationPageService()),
                        ).then((r) {
                          _loadStaffName();
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Stack(
                          children: [
                            Image.asset("assets/icons/notification.png",
                                width: 20, color: Colors.white),
                            Positioned(
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                constraints: const BoxConstraints(
                                    minWidth: 12, minHeight: 12),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        _scaffoldKey.currentState!.openEndDrawer();
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Image.asset("assets/icons/menu.png",
                            width: 20, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Welcome Section
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2a86c9), Color(0xFF406dbe)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Welcome Back!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          name.isNotEmpty ? name : staffName,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.work,
                                  color: Colors.white, size: 14),
                              const SizedBox(width: 5),
                              Text(
                                role.isNotEmpty ? role : "Serviceman",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.engineering,
                        color: Colors.white, size: 40),
                  ),
                ],
              ),
            ),

            // Search Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Search work, tasks...",
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Color(0xFF2a86c9)),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 8 Modern Work & Financial Stat Cards Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.15,
                children: [
                  _buildModernStatCard(
                    title: "New Work",
                    value: isLoadingDashboardCounts
                        ? "..."
                        : "${dashboardCounts?.newOrders ?? 0}",
                    icon: Icons.fiber_new_rounded,
                    gradientColors: const [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WorkListPage(
                          pageTitle: "New Work",
                          typeId: "1",
                        ),
                      ),
                    ),
                  ),
                  _buildModernStatCard(
                    title: "Pending Work",
                    value: isLoadingDashboardCounts
                        ? "..."
                        : "${dashboardCounts?.pendingOrders ?? 0}",
                    icon: Icons.hourglass_top_rounded,
                    gradientColors: const [Color(0xFFF59E0B), Color(0xFFD97706)],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WorkListPage(
                          pageTitle: "Pending Work",
                          typeId: "2",
                        ),
                      ),
                    ),
                  ),
                  _buildModernStatCard(
                    title: "Ongoing Work",
                    value: isLoadingDashboardCounts
                        ? "..."
                        : "${dashboardCounts?.inprogressOrders ?? 0}",
                    icon: Icons.engineering_rounded,
                    gradientColors: const [Color(0xFF10B981), Color(0xFF059669)],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WorkListPage(
                          pageTitle: "Ongoing Work",
                          typeId: "3",
                        ),
                      ),
                    ),
                  ),
                  _buildModernStatCard(
                    title: "Completed Work",
                    value: isLoadingDashboardCounts
                        ? "..."
                        : "${dashboardCounts?.completedOrders ?? 0}",
                    icon: Icons.task_alt_rounded,
                    gradientColors: const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WorkListPage(
                          pageTitle: "Completed Work",
                          typeId: "4",
                        ),
                      ),
                    ),
                  ),
                  _buildModernStatCard(
                    title: "Overdue",
                    value: isLoadingDashboardCounts
                        ? "..."
                        : "${dashboardCounts?.overdueOrders ?? 0}",
                    icon: Icons.warning_amber_rounded,
                    gradientColors: const [Color(0xFFEF4444), Color(0xFFB91C1C)],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WorkListPage(
                          pageTitle: "Overdue Work",
                          typeId: "5",
                        ),
                      ),
                    ),
                  ),
                  _buildModernStatCard(
                    title: "Today Collected",
                    value: isLoadingDashboardCounts
                        ? "..."
                        : "₹${_formatAmount(dashboardCounts?.todaysCollection)}",
                    icon: Icons.today_rounded,
                    gradientColors: const [Color(0xFF06B6D4), Color(0xFF0891B2)],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ServiceCollectionListPage(
                          type: 1,
                          title: "Today Collected",
                        ),
                      ),
                    ),
                  ),
                  _buildModernStatCard(
                    title: "This Month Collection",
                    value: isLoadingDashboardCounts
                        ? "..."
                        : "₹${_formatAmount(dashboardCounts?.thisMonthCollection)}",
                    icon: Icons.account_balance_wallet_rounded,
                    gradientColors: const [Color(0xFF10B981), Color(0xFF047857)],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ServiceCollectionListPage(
                          type: 2,
                          title: "This Month Collection",
                        ),
                      ),
                    ),
                  ),
                  _buildModernStatCard(
                    title: "Balance to Receive",
                    value: isLoadingDashboardCounts
                        ? "..."
                        : "₹${_formatAmount(dashboardCounts?.dueCollection)}",
                    icon: Icons.pending_actions_rounded,
                    gradientColors: const [Color(0xFF6366F1), Color(0xFF4338CA)],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ServiceCollectionListPage(
                          type: 3,
                          title: "Balance to Receive",
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Section 1: Recent Ongoing Work List (5 Rows + See More)
            _buildSectionHeader(
              title: "Recent Ongoing Work",
              badgeText: isLoadingOngoingWorks
                  ? "Loading..."
                  : "${ongoingWorkOrders.length} Active",
              onSeeMore: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const WorkListPage(
                    pageTitle: "Ongoing Work",
                    typeId: "3",
                  ),
                ),
              ),
            ),

            if (isLoadingOngoingWorks)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF2A86C9)),
                ),
              )
            else if (ongoingWorkOrders.isEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: const [
                    Icon(Icons.assignment_turned_in_outlined,
                        size: 36, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      "No ongoing works available",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...ongoingWorkOrders.take(5).map((order) {
                final workId = (order.workOrderID?.isNotEmpty == true)
                    ? order.workOrderID!
                    : ((order.workOrderId?.isNotEmpty == true)
                        ? order.workOrderId!
                        : "WK-${order.custId ?? '0'}");
                final workTitle = (order.workCategory?.isNotEmpty == true)
                    ? order.workCategory!
                    : ((order.issueDescription?.isNotEmpty == true)
                        ? order.issueDescription!
                        : "Work Order");
                final clientName = order.customerName ?? "Customer";
                final location = (order.location?.isNotEmpty == true)
                    ? order.location!
                    : (order.address ?? "Location N/A");
                final date =
                    order.createdAt ?? order.preferredDateTime ?? "Today";
                final status = order.status ?? "Ongoing";

                return _buildOngoingWorkCard(
                  workId: workId,
                  workTitle: workTitle,
                  clientName: clientName,
                  location: location,
                  date: date,
                  progress: status.toLowerCase().contains("progress")
                      ? 0.75
                      : status.toLowerCase().contains("pending")
                          ? 0.35
                          : 0.50,
                  status: status,
                  statusColor: status.toLowerCase().contains("progress")
                      ? const Color(0xFF10B981)
                      : status.toLowerCase().contains("pending")
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFF3B82F6),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const WorkListPage(
                        pageTitle: "Ongoing Work",
                        typeId: "3",
                      ),
                    ),
                  ),
                );
              }),

            const SizedBox(height: 25),

            // Section 2: Payment Report List (5 Rows + See More)
            _buildSectionHeader(
              title: "Payment Report",
              badgeText: isLoadingRecentPaymentReports
                  ? "Loading..."
                  : "${recentPaymentReports.take(5).length} Recent",
              onSeeMore: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ServiceCollectionListPage(
                    type: 2,
                    title: "This Month Collection",
                  ),
                ),
              ),
            ),

            if (isLoadingRecentPaymentReports)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF2A86C9)),
                ),
              )
            else if (recentPaymentReports.isEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: const [
                    Icon(Icons.receipt_long_outlined,
                        size: 36, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      "No payment reports available",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...recentPaymentReports.take(5).map((record) {
                final String invNo = (record.invoiceNumber?.isNotEmpty == true)
                    ? "Inv #${record.invoiceNumber}"
                    : ((record.invoiceId?.isNotEmpty == true)
                        ? "Inv #${record.invoiceId}"
                        : "Invoice");
                final String clientName = record.customerName?.isNotEmpty == true
                    ? record.customerName!
                    : "Customer";
                final String serviceTitle = (record.createdByName?.isNotEmpty == true)
                    ? "Created by: ${record.createdByName}"
                    : "Service Invoice";
                final String date = (record.invoiceDate?.isNotEmpty == true)
                    ? record.invoiceDate!
                    : (record.createdAt ?? "N/A");
                final String status = record.paymentStatus?.isNotEmpty == true
                    ? record.paymentStatus!.toUpperCase()
                    : "RECEIVED";
                final num displayAmount = record.totalAmount ?? record.paidAmount ?? 0;
                final String amount = "+ ₹${_formatAmount(displayAmount)}";
                final String paymentMode = (record.paidAmount != null && record.paidAmount! > 0)
                    ? "Paid"
                    : "Pending";

                return _buildPaymentReportCard(
                  invoiceNo: invNo,
                  clientName: clientName,
                  serviceTitle: serviceTitle,
                  date: date,
                  paymentMode: paymentMode,
                  amount: amount,
                  status: status,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ServiceCollectionListPage(
                        type: 2,
                        title: "This Month Collection",
                      ),
                    ),
                  ),
                );
              }),

            const SizedBox(height: 35),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2a86c9),
        onPressed: () {
          ProjectDashboardPermission == "true"
              ? Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => ProjectDashboard()))
              : AccountsDashboardPermission == "true"
                  ? Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              AccountsDashboard(token: token!)))
                  : MenuDashboard == "true"
                      ? Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomePage(token)))
                      : RenewalDashboardPermission == "true"
                          ? Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RenewalDashboard()))
                          : NewleadDashboardPermission == "true"
                              ? Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          MinimalDashboard(token)))
                              : Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          DashboardLeadNewUpdatedTwo(token)));
        },
        child: const Icon(Icons.dashboard, color: Colors.white),
      ),
      bottomNavigationBar: configure != null
          ? BottomNavigation(
              token,
              phoneCallLogPermission: phoneCallLogPermission,
              name: name,
              userId: userId,
            )
          : const SizedBox(),
    );
  }

  Widget _buildModernStatCard({
    required String title,
    required String value,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    final primaryColor = gradientColors.first;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: primaryColor.withOpacity(0.18),
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 10,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: primaryColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A5568),
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String badgeText,
    required VoidCallback onSeeMore,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A86C9).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeText,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2A86C9),
                  ),
                ),
              ),
            ],
          ),
          InkWell(
            onTap: onSeeMore,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                children: const [
                  Text(
                    "See More",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2A86C9),
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 11,
                    color: Color(0xFF2A86C9),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOngoingWorkCard({
    required String workId,
    required String workTitle,
    required String clientName,
    required String location,
    required String date,
    required double progress,
    required String status,
    required Color statusColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        workId,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            status,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  workTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.person_outline,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      clientName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF475569),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Progress",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                "${(progress * 100).toInt()}%",
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2A86C9),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 5,
                              backgroundColor: Colors.grey.shade100,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF2A86C9)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 15),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          date,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentReportCard({
    required String invoiceNo,
    required String clientName,
    required String serviceTitle,
    required String date,
    required String paymentMode,
    required String amount,
    required String status,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Color(0xFF10B981),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            clientName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            amount,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              serviceTitle,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD1FAE5), // Emerald 100
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              status,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF047857), // Emerald 700
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  paymentMode,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                invoiceNo,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            date,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
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
}

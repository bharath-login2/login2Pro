import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/commonConfigureModel.dart';
import 'package:login2/models/rental/rentalDashbaordModel.dart';
import 'package:login2/screens/accounts/dashboard/accounts_dashboard.dart';
import 'package:login2/screens/accounts/renewal_mannagement/renewal_dashboard.dart';
import 'package:login2/screens/bottom_navigation_bar.dart';
import 'package:login2/screens/homePage.dart';
import 'package:login2/screens/leadManagement/dashboard.dart';
import 'package:login2/screens/leadManagement/dashboardLeadsNewUpdated2.dart';
import 'package:login2/screens/leadManagement/minimalDashboard.dart';
import 'package:login2/screens/leadManagement/projectDashboard.dart';
import 'package:login2/screens/rental/paymentReportListPage.dart';
import 'package:login2/screens/rental/rentIssueListPage.dart';
import 'package:login2/screens/rental/rentalReturnList.dart';
import 'package:login2/screens/rental/damagedListPage.dart';
import 'package:login2/screens/rental/expiredListPage.dart';
import 'package:login2/screens/rental/overdueReturnsPage.dart';
import 'package:login2/screens/drawerScreen.dart';
import 'package:login2/service/service.dart';

class RentalDashboard extends StatefulWidget {
  final String token;
  final String name;
  final String userId;
  final String? phoneCallLogPermission;
  final String? custId;

  const RentalDashboard({
    super.key,
    required this.token,
    required this.name,
    required this.userId,
    this.phoneCallLogPermission,
    this.custId,
  });

  @override
  State<RentalDashboard> createState() => _RentalDashboardState();
}

class _RentalDashboardState extends State<RentalDashboard> {
  CommonConfigureModel? configure;
  RentalDashboardModel? dashboardData;
  bool isLoading = true;
  bool isRefreshing = false;
  String? ProjectDashboardPermission;
  String? AccountsDashboardPermission;
  String? MenuDashboard;
  String? RenewalDashboardPermission;
  String? NewleadDashboardPermission;

  // Date filter variables
  DateTime _selectedDate = DateTime.now();
  final DateFormat _dateFormat = DateFormat('dd-MM-yyyy');
  final DateFormat _apiDateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _permissionsCheck();
    _loadConfiguration();
    _loadDashboardData();
  }

  Future<void> _permissionsCheck() async {
    ProjectDashboardPermission =
        await Common.getSharedPref("ProjectDashboardPermission");
    AccountsDashboardPermission =
        await Common.getSharedPref("AccountsDashboardPermission");
    MenuDashboard = await Common.getSharedPref("MenuDashboard");
    RenewalDashboardPermission =
        await Common.getSharedPref("RenewalDashboardPermission");
    NewleadDashboardPermission =
        await Common.getSharedPref("NewleadDashboardPermission");
  }

  Future<void> _loadConfiguration() async {
    try {
      configure = await HttpService.configure(widget.token);
    } catch (e) {
      print("Error loading configuration: $e");
    }
  }

  Future<void> _loadDashboardData() async {
    if (mounted) {
      setState(() {
        isRefreshing = true;
      });
    }

    try {
      final dateString = _apiDateFormat.format(_selectedDate);
      final data = await HttpService.getRentalDashboard(dateString);

      if (mounted) {
        setState(() {
          dashboardData = data;
          isLoading = false;
          isRefreshing = false;
        });
      }
    } catch (e) {
      print("Error loading dashboard data: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
          isRefreshing = false;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      await _loadDashboardData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadDashboardData,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date Filter Row
                      _buildDateFilter(context),
                      const SizedBox(height: 20),

                      // Show error message if API returned false status
                      if (dashboardData != null && !dashboardData!.status)
                        _buildErrorMessage(),

                      // Top Stats Section
                      _buildTopStats(context),
                      const SizedBox(height: 20),

                      // Overdue Returns Section
                      _buildOverdueReturns(),
                    ],
                  ),
                ),
              ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {
          ProjectDashboardPermission == "true"
              ? Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ProjectDashboard()),
                )
              : AccountsDashboardPermission == "true"
                  ? Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              AccountsDashboard(token: widget.token)),
                    )
                  : MenuDashboard == "true"
                      ? Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomePage(widget.token)),
                        )
                      : RenewalDashboardPermission == "true"
                          ? Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RenewalDashboard()),
                            )
                          : NewleadDashboardPermission == "true"
                              ? Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          MinimalDashboard(widget.token)),
                                )
                              : Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          DashboardLeadNewUpdatedTwo(
                                              widget.token)),
                                );
        },
        child: Image.asset("assets/icons/menu.png", width: 25),
      ),
      bottomNavigationBar: configure != null
          ? BottomNavigation(
              widget.token,
              phoneCallLogPermission: widget.phoneCallLogPermission ?? 'false',
              name: widget.name,
              userId: widget.userId,
            )
          : const SizedBox(),
    );
  }

  Widget _buildDateFilter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Date:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          InkWell(
            onTap: () => _selectDate(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _dateFormat.format(_selectedDate),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                  if (isRefreshing) ...[
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    if (dashboardData == null || dashboardData!.status) return const SizedBox();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber,
            color: Colors.orange[700],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              dashboardData!.message.isNotEmpty
                  ? dashboardData!.message
                  : 'Failed to load dashboard data',
              style: TextStyle(
                fontSize: 14,
                color: Colors.orange[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // App Bar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          InkWell(
            onTap: () => logout(context),
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
              child: const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Rental Dashboard',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) {
            if (value == 'damaged_list') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DamagedListPage(token: widget.token),
                ),
              );
            }else if (value == 'expired_list') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExpiredListPage(token: widget.token),
                ),
              );
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'damaged_list',
              child: Row(
                children: [
                  Icon(Icons.report_problem_outlined, color: Colors.red),
                  SizedBox(width: 10),
                  Text('Damaged List'),
                ],
              ),
            ),
             const PopupMenuItem(
              value: 'expired_list',
              child: Row(
                children: [
                  Icon(Icons.date_range, color: Colors.red),
                  SizedBox(width: 10),
                  Text('Expired List'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopStats(BuildContext context) {
    final data = dashboardData?.data;
    
    // Calculate pending returns
    final pendingReturn = (data?.pendingReturn ?? 0);
    final overdueCount = (data?.overdueCount ?? 0);

    // Calculate today's total payment
    final todayCash = (data?.todayCash ?? 0);
    final todayBank = (data?.todayBank ?? 0);
    final todayTotalPayment = todayCash + todayBank;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => RentalReturnListPage(),
                    ),
                  );
                },
                child: _statCard(
                  title: 'Return Status',
                  total: pendingReturn.toString(),
                  totalLabel: 'Pending',
                  sub: 'Overdue',
                  subValue: overdueCount.toString(),
                  icon: Icons.leaderboard_outlined,
                  color: const Color(0xFF667eea),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => RentalIssueListPage(),
                    ),
                  );
                },
                child: _statCard(
                  title: 'Todays Report',
                  total: (data?.rentIssued ?? 0).toString(),
                  totalLabel: 'Issued',
                  sub: 'Returned',
                  subValue: (data?.rentReturned ?? 0).toString(),
                  icon: Icons.calendar_month,
                  color: const Color(0xFF43e97b),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PaymentReportListPage(
                        initialDate: _apiDateFormat.format(_selectedDate),
                      ),
                    ),
                  );
                },
                child: _statCardNew(
                  title: 'Todays Payment (${data?.todayPayment ?? 0})',
                  total: todayCash.toString(),
                  totalLabel: 'Cash Collection',
                  sub: 'Bank Collection',
                  subValue: todayBank.toString(),
                  icon: Icons.attach_money_rounded,
                  color: const Color(0xFFf093fb),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statCard({
    required String title,
    required String total,
    required String totalLabel,
    required String sub,
    required String subValue,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      totalLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            total,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.check_circle,
                          color: Colors.green[500],
                          size: 16,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      sub,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.end,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            subValue,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.check_circle,
                          color: Colors.green[500],
                          size: 16,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCardNew({
    required String title,
    required String total,
    required String totalLabel,
    required String sub,
    required String subValue,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        color: color,
                        size: 20,
                      ),
                      const SizedBox(width: 25),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      totalLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            total,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.check_circle,
                          color: Colors.green[500],
                          size: 16,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      sub,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.end,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            subValue,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.check_circle,
                          color: Colors.green[500],
                          size: 16,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverdueReturns() {
    final overdueList = dashboardData?.data.overdueList ?? [];
    final overdueCount = dashboardData?.data.overdueCount ?? 0;
    final displayList = overdueList.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  'Overdue Returns ($overdueCount)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey[900],
                    letterSpacing: -0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (overdueList.isNotEmpty)
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OverdueReturnsListPage(
                          token: widget.token,
                          initialOverdueList: overdueList,
                          selectedDateString:
                              _apiDateFormat.format(_selectedDate),
                        ),
                      ),
                    ).then((_) => _loadDashboardData());
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'See More',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.blue[700],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 13,
                          color: Colors.blue[700],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$overdueCount pending returns',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          if (displayList.isEmpty) _buildEmptyState(),
          Column(
            children: displayList.map((item) {
              return Column(
                children: [
                  _overdueRow(item: item),
                  if (displayList.indexOf(item) < displayList.length - 1)
                    const SizedBox(height: 16),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 48,
            color: Colors.green[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No overdue returns',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'All returns are up to date',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _overdueRow({required OverdueItem item}) {
    final totalDays = int.tryParse(item.totalDays) ?? 0;
    final amount = double.tryParse(item.grandTotal) ?? 0;

    // Format amount with Indian rupee symbol
    final formattedAmount = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 0,
    ).format(amount);

    // Parse the date
    DateTime? parsedDate;
    try {
      parsedDate = DateTime.parse(item.toDate);
    } catch (e) {
      print('Error parsing date: ${item.toDate}');
    }

    final formattedDate = parsedDate != null
        ? DateFormat('dd MMM yyyy').format(parsedDate)
        : item.toDate;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                Icons.warning_amber,
                color: Colors.orange,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey[900],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$totalDays Days Overdue',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formattedDate,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                formattedAmount,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1C1A79),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

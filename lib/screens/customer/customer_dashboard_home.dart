import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/customers/customerDashboardCountsModel.dart';
import 'package:login2/models/customers/customerGrowthModel.dart';
import 'package:login2/screens/accounts/clients/addClients.dart';
import 'package:login2/screens/accounts/clients/clientList.dart';
import 'package:login2/screens/customer/customer_followup_list_page.dart';
import 'package:login2/service/service.dart';

class CustomerDashboardHome extends StatefulWidget {
  final String token;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const CustomerDashboardHome({
    super.key,
    required this.token,
    this.scaffoldKey,
  });

  @override
  State<CustomerDashboardHome> createState() => _CustomerDashboardHomeState();
}

class _CustomerDashboardHomeState extends State<CustomerDashboardHome> {
  bool _isLoadingGrowth = true;
  bool _isLoadingCounts = true;
  String? _growthError;
  List<CustomerGrowthItem> _growthItems = [];
  int _selectedSpotIndex = 0;

  // Real-time summary counts from get_customer_dashboard_counts
  int followUp = 0;
  int totalCalled = 0;
  int missed = 0;
  int transferred = 0;
  String? countsFromDate;
  String? countsToDate;

  @override
  void initState() {
    super.initState();
    loadAllData();
  }

  /// Loads both Customer Growth Trend and Dashboard Counts concurrently
  Future<void> loadAllData() async {
    await Future.wait([
      fetchCustomerGrowthData(),
      fetchCustomerDashboardCounts(),
    ]);
  }

  /// Fetches real-time summary counts from get_customer_dashboard_counts
  Future<void> fetchCustomerDashboardCounts() async {
    setState(() {
      _isLoadingCounts = true;
    });

    try {
      final response = await HttpService.getCustomerDashboardCounts(
        token: widget.token,
      );

      if (mounted) {
        if (response != null && response.data != null) {
          setState(() {
            followUp = response.data!.followupCount;
            totalCalled = response.data!.calledCount;
            missed = response.data!.missedCount;
            transferred = response.data!.transferredCount;
            countsFromDate = response.data!.fromDate;
            countsToDate = response.data!.toDate;
            _isLoadingCounts = false;
          });
        } else {
          setState(() {
            _isLoadingCounts = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading customer dashboard counts: $e");
      if (mounted) {
        setState(() {
          _isLoadingCounts = false;
        });
      }
    }
  }

  /// Calculates start_date and end_date covering the last 5 months
  /// and fetches real-time customer growth trend from the API.
  Future<void> fetchCustomerGrowthData() async {
    setState(() {
      _isLoadingGrowth = true;
      _growthError = null;
    });

    final now = DateTime.now();
    // 5 months back: start from the 1st of the month 4 months prior
    final startDate = DateTime(now.year, now.month - 4, 1);
    final endDate = DateTime(now.year, now.month + 1, 0); // Last day of current month

    final startDateStr = DateFormat('yyyy-MM-dd').format(startDate);
    final endDateStr = DateFormat('yyyy-MM-dd').format(endDate);

    try {
      final response = await HttpService.getCustomerGrowthData(
        token: widget.token,
        startDate: startDateStr,
        endDate: endDateStr,
      );

      if (mounted) {
        if (response != null && response.data.isNotEmpty) {
          final items = response.data.length > 5
              ? response.data.sublist(response.data.length - 5)
              : response.data;
          setState(() {
            _growthItems = items;
            _selectedSpotIndex = items.isNotEmpty ? items.length - 1 : 0;
            _isLoadingGrowth = false;
          });
        } else {
          setState(() {
            _growthItems = [];
            _selectedSpotIndex = 0;
            _isLoadingGrowth = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading customer growth data: $e");
      if (mounted) {
        setState(() {
          _growthItems = [];
          _selectedSpotIndex = 0;
          _isLoadingGrowth = false;
        });
      }
    }
  }

  int get currentTotalCustomers {
    if (_growthItems.isNotEmpty) {
      return _growthItems.last.totalCustomers;
    }
    return 0;
  }

  String get growthPercentage {
    if (_growthItems.length >= 2) {
      final current = _growthItems.last.totalCustomers;
      final previous = _growthItems[_growthItems.length - 2].totalCustomers;
      if (previous > 0) {
        final diff = current - previous;
        final percent = (diff / previous) * 100;
        final sign = percent >= 0 ? '+' : '';
        return '$sign${percent.toStringAsFixed(2)}%';
      }
    }
    return '+0.00%';
  }

  void _navigateToClientList(String filterCategory) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClientList(
          widget.token,
          widget.scaffoldKey,
          filterCategory: filterCategory,
        ),
      ),
    );
  }

  void _navigateToFollowupList({
    required String filterType,
    int? filterCount,
    int? followupCount,
    int? calledCount,
    int? missedCount,
    int? transferredCount,
    String? fromDate,
    String? toDate,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerFollowupListPage(
          token: widget.token,
          filterType: filterType,
          filterCount: filterCount,
          followupCount: followupCount,
          calledCount: calledCount,
          missedCount: missedCount,
          transferredCount: transferredCount,
          fromDate: fromDate,
          toDate: toDate,
          scaffoldKey: widget.scaffoldKey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(MediaQuery.of(context).size.height * 0.08),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2a86c9), Color(0xFF406dbe)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 28,
                        width: 28,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 1.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_outlined,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Customer Dashboard',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Refresh',
                      onPressed: loadAllData,
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Add Customer',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddClients(
                              widget.token,
                              createOrder: true,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.add_circle,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: loadAllData,
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 850) {
              return _buildWideLayout();
            } else {
              return _buildMobileLayout();
            }
          },
        ),
      ),
    );
  }

  /// Wide layout matching the screenshot (Left: Large card with chart, Right: 2x2 grid)
  Widget _buildWideLayout() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side: Total Customers header + Customer Growth chart
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTotalCustomersHeader(
                    onTap: () => _navigateToClientList('Total Customers'),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Customer Growth Trend',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      if (_growthItems.isNotEmpty)
                        Text(
                          '${_growthItems.first.date} - ${_growthItems.last.date}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 260,
                    child: _isLoadingGrowth
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF2A86C9),
                            ),
                          )
                        : _buildLineChart(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          // Right side: 2x2 grid of summary tiles
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (countsFromDate != null && countsFromDate!.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0, left: 2.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.date_range_outlined,
                          size: 13,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Period: $countsFromDate to ${countsToDate?.split(' ').first ?? ''}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryTile(
                        title: 'FOLLOW-UP',
                        value: '$followUp',
                        subtitle: 'Pending follow-ups',
                        icon: Icons.calendar_today_outlined,
                        accentColor: const Color(0xFFF59E0B),
                        iconBgColor: const Color(0xFFFEF3C7),
                        iconColor: const Color(0xFFD97706),
                        isLoading: _isLoadingCounts,
                        onTap: () => _navigateToFollowupList(
                          filterType: 'Follow-up',
                          filterCount: followUp,
                          followupCount: followUp,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryTile(
                        title: 'TOTAL CALLED',
                        value: '$totalCalled',
                        subtitle: 'Completed calls',
                        icon: Icons.call_outlined,
                        accentColor: const Color(0xFF10B981),
                        iconBgColor: const Color(0xFFD1FAE5),
                        iconColor: const Color(0xFF059669),
                        isLoading: _isLoadingCounts,
                        onTap: () => _navigateToFollowupList(
                          filterType: 'Total Called',
                          filterCount: totalCalled,
                          calledCount: totalCalled,
                          fromDate: countsFromDate,
                          toDate: countsToDate,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryTile(
                        title: 'MISSED',
                        value: '$missed',
                        subtitle: 'Overdue follow-ups',
                        icon: Icons.phone_missed_outlined,
                        accentColor: const Color(0xFFEF4444),
                        iconBgColor: const Color(0xFFFEE2E2),
                        iconColor: const Color(0xFFDC2626),
                        isLoading: _isLoadingCounts,
                        onTap: () => _navigateToFollowupList(
                          filterType: 'Missed',
                          filterCount: missed,
                          missedCount: missed,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryTile(
                        title: 'TRANSFERRED',
                        value: '$transferred',
                        subtitle: 'Transferred calls',
                        icon: Icons.swap_horiz_rounded,
                        accentColor: const Color(0xFF6366F1),
                        iconBgColor: const Color(0xFFEDE9FE),
                        iconColor: const Color(0xFF6366F1),
                        isLoading: _isLoadingCounts,
                        onTap: () => _navigateToFollowupList(
                          filterType: 'Transferred',
                          filterCount: transferred,
                          transferredCount: transferred,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Mobile layout: Top section summary tiles, followed by the line chart card below
  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Total Customers full-width summary card
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: () => _navigateToClientList('Total Customers'),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Top blue accent bar
                    Container(
                      height: 3.5,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2A86C9),
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(10)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildTotalCustomersHeader(
                        onTap: () => _navigateToClientList('Total Customers'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          if (countsFromDate != null && countsFromDate!.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0, left: 2.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.date_range_outlined,
                    size: 13,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Period: $countsFromDate to ${countsToDate?.split(' ').first ?? ''}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
          // 2. 2x2 Grid of Follow-up, Total Called, Missed, Transferred
          Row(
            children: [
              Expanded(
                child: _buildSummaryTile(
                  title: 'FOLLOW-UP',
                  value: '$followUp',
                  subtitle: 'Pending follow-ups',
                  icon: Icons.calendar_today_outlined,
                  accentColor: const Color(0xFFF59E0B),
                  iconBgColor: const Color(0xFFFEF3C7),
                  iconColor: const Color(0xFFD97706),
                  isLoading: _isLoadingCounts,
                  onTap: () => _navigateToFollowupList(
                    filterType: 'Follow-up',
                    filterCount: followUp,
                    followupCount: followUp,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryTile(
                  title: 'TOTAL CALLED',
                  value: '$totalCalled',
                  subtitle: 'Completed calls',
                  icon: Icons.call_outlined,
                  accentColor: const Color(0xFF10B981),
                  iconBgColor: const Color(0xFFD1FAE5),
                  iconColor: const Color(0xFF059669),
                  isLoading: _isLoadingCounts,
                  onTap: () => _navigateToFollowupList(
                    filterType: 'Total Called',
                    filterCount: totalCalled,
                    calledCount: totalCalled,
                    fromDate: countsFromDate,
                    toDate: countsToDate,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryTile(
                  title: 'MISSED',
                  value: '$missed',
                  subtitle: 'Overdue follow-ups',
                  icon: Icons.phone_missed_outlined,
                  accentColor: const Color(0xFFEF4444),
                  iconBgColor: const Color(0xFFFEE2E2),
                  iconColor: const Color(0xFFDC2626),
                  isLoading: _isLoadingCounts,
                  onTap: () => _navigateToFollowupList(
                    filterType: 'Missed',
                    filterCount: missed,
                    missedCount: missed,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryTile(
                  title: 'TRANSFERRED',
                  value: '$transferred',
                  subtitle: 'Transferred calls',
                  icon: Icons.swap_horiz_rounded,
                  accentColor: const Color(0xFF6366F1),
                  iconBgColor: const Color(0xFFEDE9FE),
                  iconColor: const Color(0xFF6366F1),
                  isLoading: _isLoadingCounts,
                  onTap: () => _navigateToFollowupList(
                    filterType: 'Transferred',
                    filterCount: transferred,
                    transferredCount: transferred,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 3. Graph section — Customer Growth Trend Line Chart
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Customer Growth Trend',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                    if (_growthItems.isNotEmpty)
                      Text(
                        '${_growthItems.first.date} - ${_growthItems.last.date}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 230,
                  child: _isLoadingGrowth
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF2A86C9),
                          ),
                        )
                      : _buildLineChart(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Total Customers header widget matching the screenshot
  Widget _buildTotalCustomersHeader({required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                // User Avatar Circle
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEDF2F7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: Color(0xFF4A5568),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL CUSTOMERS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF718096),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    if (_isLoadingGrowth)
                      const SizedBox(
                        height: 28,
                        child: Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF2A86C9),
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      Text(
                        '$currentTotalCustomers',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A202C),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Pill badge ↗ +X.XX%
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.north_east_rounded,
                        size: 11,
                        color: Color(0xFF059669),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        growthPercentage,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'vs previous period',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF718096),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Summary tile card with colored top accent, icon, title, value, and subtitle
  Widget _buildSummaryTile({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required Color iconBgColor,
    required Color iconColor,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Colored top accent bar
              Container(
                height: 3.5,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(10)),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon Circle
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: iconBgColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: iconColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Title
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    // Value
                    if (isLoading)
                      const SizedBox(
                        height: 28,
                        child: Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF2A86C9),
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 4),
                    // Subtitle
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Line chart plotting total_customers dynamically on Y-axis and date on X-axis
  Widget _buildLineChart() {
    if (_growthItems.isEmpty) {
      return const Center(
        child: Text(
          'No customer growth data available',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
      );
    }

    final List<FlSpot> spots = [];
    for (int i = 0; i < _growthItems.length; i++) {
      spots.add(FlSpot(i.toDouble(), _growthItems[i].totalCustomers.toDouble()));
    }

    // Dynamic min and max calculation for Y-axis
    final values = _growthItems.map((e) => e.totalCustomers).toList();
    final minVal = values.reduce((a, b) => a < b ? a : b);
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final range = maxVal - minVal;

    final double paddingY = range > 0 ? (range * 0.25).clamp(2.0, 15.0) : 5.0;
    final double minY = (minVal - paddingY).clamp(0.0, double.infinity);
    final double maxY = maxVal + paddingY;

    double intervalY = (range / 4).ceilToDouble();
    if (intervalY <= 1) intervalY = 2;
    if (intervalY > 2 && intervalY <= 5) intervalY = 5;
    if (intervalY > 5 && intervalY <= 10) intervalY = 10;
    if (intervalY > 10 && intervalY <= 25) intervalY = 20;

    final selectedIndex = _selectedSpotIndex.clamp(0, _growthItems.length - 1);

    final lineBarData = LineChartBarData(
      spots: spots,
      isCurved: false,
      color: const Color(0xFF334155),
      barWidth: 2.5,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          final isSelected = index == selectedIndex;
          return FlDotCirclePainter(
            radius: isSelected ? 5.5 : 3.5,
            color: const Color(0xFF334155),
            strokeWidth: isSelected ? 2.5 : 1.5,
            strokeColor: Colors.white,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        color: const Color(0xFFEEF2F9),
      ),
    );

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          enabled: true,
          handleBuiltInTouches: true,
          touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
            if (response != null &&
                response.lineBarSpots != null &&
                response.lineBarSpots!.isNotEmpty) {
              final spotIdx = response.lineBarSpots!.first.spotIndex;
              if (spotIdx != _selectedSpotIndex) {
                setState(() {
                  _selectedSpotIndex = spotIdx;
                });
              }
            }
          },
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.white,
            tooltipRoundedRadius: 8,
            tooltipBorder: const BorderSide(
              color: Color(0xFFCBD5E1),
              width: 1,
            ),
            tooltipPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                final idx = touchedSpot.x.toInt();
                final item = (idx >= 0 && idx < _growthItems.length)
                    ? _growthItems[idx]
                    : null;
                final monthName = item?.date ?? '';
                final count = item?.totalCustomers ?? touchedSpot.y.toInt();
                return LineTooltipItem(
                  'Month: $monthName\n',
                  const TextStyle(
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    height: 1.3,
                  ),
                  children: [
                    TextSpan(
                      text: 'Total Customers: $count',
                      style: const TextStyle(
                        color: Color(0xFF475569),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
        showingTooltipIndicators: [
          ShowingTooltipIndicators([
            LineBarSpot(
              lineBarData,
              0,
              lineBarData.spots[selectedIndex],
            ),
          ]),
        ],
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: intervalY,
          getDrawingHorizontalLine: (value) {
            return const FlLine(
              color: Color(0xFFF1F5F9),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: 1,
              getTitlesWidget: (double value, TitleMeta meta) {
                final int index = value.toInt();
                if (index >= 0 && index < _growthItems.length && value == index.toDouble()) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _growthItems[index].date,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: intervalY,
              reservedSize: 36,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.left,
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (_growthItems.length - 1).toDouble(),
        minY: minY,
        maxY: maxY,
        lineBarsData: [lineBarData],
      ),
    );
  }
}

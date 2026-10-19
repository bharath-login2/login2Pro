import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:intl/intl.dart';
import 'package:login2/screens/leadManagement/dashboardLeadsNewUpdated2.dart';
import 'package:login2/screens/leadManagement/playWidget.dart';
import 'package:lottie/lottie.dart';
import '../../core/common.dart';
import '../../models/callLogs/callLogHistoryModel.dart';
import '../../models/lead_management/callHistoryModel.dart';

import '../../service/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:login2/screens/leadManagement/lead_details_popup.dart';
import 'package:login2/models/lead_management/leadDetailsModel.dart';
import 'package:login2/models/lead_management/leadDetailsModelAdd.dart';
import 'package:login2/models/lead_management/leadMileStoneListModel.dart';
import 'package:login2/models/lead_management/leadFollowupAdd.dart' as af;
import 'package:login2/models/lead_management/listFolderName.dart';

// Custom Colors
class AppColors {
  static const Color primary = Color(0xFF1E88E5);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color secondary = Color(0xFF00ACC1);
  static const Color accent = Color(0xFFFF6B6B);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color background = Color(0xFFF5F7FA);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color border = Color(0xFFE0E0E0);
}

class CallHistoryPageTwo extends StatefulWidget {
  final String token;
  final String name;
  final String userId;
  final bool accessCallRecord;

  const CallHistoryPageTwo(
    this.token,
    this.name,
    this.userId,
    this.accessCallRecord, {
    super.key,
  });

  @override
  State<CallHistoryPageTwo> createState() => _CallHistoryPageTwoState();
}

class _CallHistoryPageTwoState extends State<CallHistoryPageTwo>
    with SingleTickerProviderStateMixin {
  CallHistoryModel? callHistory;
  String fromdate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String todate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  CallLogHistoryModel? logHistory;
  String assignStaff = '';
  String assignStaffId = '';
  String callType = 'All';
  String callTypeValue = '';
  bool? result = true;
  bool? result1 = true;
  bool search = false;
  bool isLoading = true;
  int selectedTabIndex = 0;
  int callHistoryCount = 0;
  String updateLeadPermission = '';
  String deleteLeadPermission = '';
  String cloudCallPermission = '';
  bool updateLeadPermission1 = false;
  bool deleteLeadPermission1 = false;
  bool cloudCallPermission1 = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Color> _statusColors = [
    const Color(0xFF1E88E5), // Blue - New
    const Color(0xFF4CAF50), // Green - Contacted
    const Color(0xFFFF9800), // Orange - Follow Up
    const Color(0xFFF44336), // Red - Lost
    const Color(0xFF9C27B0), // Purple - Converted
    const Color(0xFF00BCD4), // Cyan - Interested
    const Color(0xFFFFC107), // Amber - Not Interested
    const Color(0xFF795548), // Brown - Call Back
  ];

  final List<Map<String, dynamic>> _tabs = [
    {'title': 'Call History', 'icon': Icons.call, 'color': AppColors.primary},
    {
      'title': 'Follow-ups',
      'icon': Icons.event_note,
      'color': AppColors.secondary
    },
    {'title': 'Call Logs', 'icon': Icons.history, 'color': AppColors.accent},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
    assignStaff = widget.name;
    assignStaffId = widget.userId;
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    await _checkConnectivity();
    await _loadPermissions();
    await _fetchCallHistory();
    await _fetchCallLogHistory();
    setState(() => isLoading = false);
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult is List<ConnectivityResult>) {
      setState(() {
        result = connectivityResult.contains(ConnectivityResult.mobile) ||
            connectivityResult.contains(ConnectivityResult.wifi);
      });
    } else {
      setState(() => result = false);
    }
  }

  Future<void> _loadPermissions() async {
    updateLeadPermission = await Common.getSharedPref("updateLeadPermission");
    deleteLeadPermission = await Common.getSharedPref("deleteLeadPermission");
    cloudCallPermission = await Common.getSharedPref("cloudCallPermission");
    updateLeadPermission1 = updateLeadPermission == 'true';
    deleteLeadPermission1 = deleteLeadPermission == 'true';
    cloudCallPermission1 = cloudCallPermission == 'true';
  }

  Future<void> _fetchCallHistory() async {
    callHistory = await HttpService.callHistory(
      widget.token,
      assignStaffId,
      fromdate,
      todate,
      callType: callTypeValue,
    );
    if (callHistory != null) {
      _calculateHistoryCount();
    }
  }

  Future<void> _fetchCallLogHistory() async {
    logHistory = await HttpService.callLogHistory(
      widget.token,
      fromdate,
      todate,
      assignStaffId,
      callType: callTypeValue,
    );
  }

  void _calculateHistoryCount() {
    callHistoryCount = 0;
    for (int i = 0; i < callHistory!.data!.callHistory!.length; i++) {
      callHistoryCount += callHistory!.data!.callHistory![i].history!.length;
    }
  }

  Future<void> _search() async {
    setState(() {
      search = true;
      isLoading = true;
    });
    await _fetchCallHistory();
    await _fetchCallLogHistory();
    setState(() => isLoading = false);
  }

  void _showStaffSelectionDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Select Staff',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: callHistory?.data?.staffList?.length ?? 0,
                  itemBuilder: (context, index) {
                    final staff = callHistory!.data!.staffList![index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: Text(
                            staff.staffName![0].toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          staff.staffName!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            assignStaff = staff.staffName!;
                            assignStaffId = staff.userId!;
                          });
                          Navigator.pop(context);
                          _search();
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectDate(bool isFromDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.cardBackground,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() {
        if (isFromDate) {
          fromdate = DateFormat('yyyy-MM-dd').format(date);
        } else {
          todate = DateFormat('yyyy-MM-dd').format(date);
        }
      });
    }
  }

  Widget _buildSearchSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDatePicker(
                  label: 'From Date',
                  date: fromdate,
                  onTap: () => _selectDate(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDatePicker(
                  label: 'To Date',
                  date: todate,
                  onTap: () => _selectDate(false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildCallTypeSelector(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStaffSelector(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSearchButtonWidget(),
        ],
      ),
    );
  }

  Widget _buildSearchButtonWidget() {
    return SizedBox(
      width: double.infinity,
      child: _buildSearchButton(),
    );
  }

  Widget _buildCallTypeSelector() {
    return InkWell(
      onTap: _showCallTypeSelectionDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Icon(Icons.compare_arrows, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                callType,
                style: const TextStyle(fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  void _showCallTypeSelectionDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Select Call Type',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _buildCallTypeOption('All', ''),
              _buildCallTypeOption('Incoming', 'Inbound'),
              _buildCallTypeOption('Outgoing', 'Outbound'),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCallTypeOption(String label, String value) {
    bool isSelected = callType == label;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: AppColors.primary)
            : null,
        onTap: () {
          setState(() {
            callType = label;
            callTypeValue = value;
          });
          Navigator.pop(context);
          _search();
        },
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required String date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                DateFormat('dd MMM yyyy').format(DateTime.parse(date)),
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffSelector() {
    return InkWell(
      onTap: _showStaffSelectionDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Icon(Icons.person_outline, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                assignStaff.isNotEmpty ? assignStaff : 'Select Staff',
                style: TextStyle(
                  fontSize: 13,
                  color: assignStaff.isNotEmpty
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchButton() {
    return InkWell(
      onTap: _search,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: const [
            Icon(Icons.search, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text(
              'Search',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 48,
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = selectedTabIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => selectedTabIndex = index);
                HapticFeedback.lightImpact();
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color:
                      isSelected ? _tabs[index]['color'] : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color:
                        isSelected ? _tabs[index]['color'] : AppColors.border,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _tabs[index]['icon'],
                      size: 18,
                      color:
                          isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _tabs[index]['title'],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color:
                            isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCallHistoryList() {
    if (callHistory?.data?.callHistory?.isEmpty ?? true) {
      return _buildEmptyState();
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: callHistory!.data!.callHistory!.length,
      itemBuilder: (context, i) {
        final dateGroup = callHistory!.data!.callHistory![i];
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 3,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    dateGroup.date!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            ...List.generate(dateGroup.history!.length, (ind) {
              final call = dateGroup.history![ind];
              return _buildCallHistoryCard(call);
            }),
          ],
        );
      },
    );
  }

  Widget _buildCallHistoryCard(dynamic call) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
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
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (call.callMasterId != null) {
              _openLeadDetails(call.callMasterId!);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: call.direction == 'Incoming'
                            ? Colors.green.withOpacity(0.1)
                            : Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        call.direction == 'Incoming'
                            ? Icons.call_received
                            : Icons.call_made,
                        color: call.direction == 'Incoming'
                            ? Colors.green
                            : AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            call.clientName ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(call.callResult)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  call.callResult ?? 'No Result',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: _getStatusColor(call.callResult),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                call.time ?? '',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (call.callDurationHr != null &&
                        call.callDurationHr!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.access_time,
                                size: 12, color: AppColors.success),
                            const SizedBox(width: 4),
                            Text(
                              call.callDurationHr!,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                if (call.remarks != null && call.remarks!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.note_outlined,
                              size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              call.remarks!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (call.resourceURL != null &&
                    call.resourceURL!.isNotEmpty &&
                    widget.accessCallRecord)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: AudioItems(
                      call.direction.toString(),
                      call.time.toString(),
                      call.isAttended!,
                      call.calledTime.toString(),
                      call.status.toString(),
                      call.resourceURL.toString(),
                      call.callDurationHr.toString(),
                      widget.accessCallRecord,
                      call.clientName.toString(),
                      call.leadCategory.toString(),
                      call.callResult.toString(),
                      call.callHistoryImage.toString(),
                      fromdate.toString(),
                      todate.toString(),
                      updateLeadPermission1,
                      deleteLeadPermission1,
                      cloudCallPermission1,
                      call.callMasterId.toString(),
                      widget.token,
                      widget.name,
                      widget.userId,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    if (status == null) return AppColors.textSecondary;
    final hash = status.hashCode.abs();
    return _statusColors[hash % _statusColors.length];
  }

  Widget _buildFollowUpList() {
    if (callHistory?.data?.followupHistory?.isEmpty ?? true) {
      return _buildEmptyState();
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: callHistory!.data!.followupHistory!.length,
      itemBuilder: (context, index) {
        final followup = callHistory!.data!.followupHistory![index];
        return GestureDetector(
            onTap: () {
              if (followup.callMasterId != null) {
                _openLeadDetails(followup.callMasterId!);
              }
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.secondary.withOpacity(0.1),
                          child: Text(
                            followup.clientName![0].toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                followup.clientName!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                followup.contactNumber1!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(followup.callResult)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            followup.callResult ?? 'Pending',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _getStatusColor(followup.callResult),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildInfoChip(
                          icon: Icons.person_outline,
                          label: followup.staffName ?? '',
                        ),
                        const SizedBox(width: 8),
                        _buildInfoChip(
                          icon: Icons.calendar_today,
                          label: followup.scheduledDate ?? '',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (followup.remarks != null &&
                        followup.remarks!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          followup.remarks!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    if (followup.voiceFile != null &&
                        followup.voiceFile!.isNotEmpty &&
                        followup.playVoicePermission == true)
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: AudioItems(
                          "",
                          followup.calledTime.toString(),
                          true,
                          followup.calledTime.toString(),
                          followup.callResult.toString(),
                          followup.voiceFile.toString(),
                          "",
                          widget.accessCallRecord,
                          followup.clientName.toString(),
                          "",
                          followup.callResult.toString(),
                          followup.proPicThumb.toString(),
                          fromdate.toString(),
                          todate.toString(),
                          updateLeadPermission1,
                          deleteLeadPermission1,
                          cloudCallPermission1,
                          followup.callMasterId.toString(),
                          widget.token,
                          widget.name,
                          widget.userId,
                        ),
                      ),
                  ],
                ),
              ),
            ));
      },
    );
  }

  Future<void> _openLeadDetails(String cmId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          ),
        );
      },
    );

    try {
      final results = await Future.wait([
        HttpService.leadDetails(widget.token, cmId),
        HttpService.listAddonDet(widget.token, cmId),
        HttpService.listFolderAndFiles(widget.token, cmId, ''),
        HttpService.leadMileStone(widget.token, cmId),
        HttpService.leadFollowupData(widget.token, cmId),
      ]);

      if (!mounted) return;

      Navigator.pop(context);

      final leadDetails = results[0] as LeadDeatailsModel?;
      if (leadDetails == null) {
        Common.toastMessaage("Failed to load lead details", Colors.red);
        return;
      }

      final leadDetailsAdditional = results[1] as LeadDeatailsModelAdd?;
      final listFolder = results[2] as ListFolderNameModel?;
      final mileStone = results[3] as LeadMileStoneListModel?;
      final leadDetailsFollowup = results[4] as af.LeadFollowupData?;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => LeadDetailsPopup(
          token: widget.token,
          editLead: updateLeadPermission1,
          deleteLead: deleteLeadPermission1,
          cloudCall: cloudCallPermission1,
          callMasterId: cmId,
          leadDetails: leadDetails,
          leadDetailsAdditional: leadDetailsAdditional,
          listFolder: listFolder,
          mileStone: mileStone,
          leadDetailsFollowup: leadDetailsFollowup,
          pageName: 'callHistory',
          onDataChanged: () {
            _loadData();
          },
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      Common.toastMessaage("Error loading lead details", Colors.red);
    }
  }

  Widget _buildCallLogList() {
    if (logHistory?.data?.lists?.isEmpty ?? true) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        if (logHistory?.data?.totalDuration != null)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Call Duration',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.timer, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      logHistory!.data!.totalDuration!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: logHistory!.data!.lists!.length,
          itemBuilder: (context, index) {
            final log = logHistory!.data!.lists![index];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: Text(
                            log.name![0].toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                log.name!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                log.phoneNumber!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 6),
                            Text(
                              log.dateTime!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.timer,
                                size: 16, color: AppColors.success),
                            const SizedBox(width: 6),
                            Text(
                              log.duration!,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            log.callType ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (log.recordingUrl != null &&
                        log.recordingUrl!.isNotEmpty &&
                        widget.accessCallRecord)
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: AudioItems(
                          log.callType.toString(),
                          log.dateTime.toString(),
                          true,
                          log.dateTime.toString(),
                          log.callType.toString(),
                          log.recordingUrl.toString(),
                          log.duration.toString(),
                          widget.accessCallRecord,
                          log.name.toString(),
                          "",
                          "",
                          "",
                          fromdate.toString(),
                          todate.toString(),
                          updateLeadPermission1,
                          deleteLeadPermission1,
                          cloudCallPermission1,
                          "",
                          widget.token,
                          widget.name,
                          widget.userId,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            const Text(
              'No Records Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No data available for the selected criteria',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DashboardLeadNewUpdatedTwo(widget.token),
                  ),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text(
                'Go Back',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoNetworkScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/icons/noNetwork.jpg',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 24),
            const Text(
              'No Internet Connection',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please check your internet connection\nand try again',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (result == false) {
      return _buildNoNetworkScreen();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.only(left: 8),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.2),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            title: const Text(
              'Call History',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            //  centerTitle: true,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primary,
        child: isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'assets/main/loading.json',
                      width: 100,
                      height: 100,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading...',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      _buildSearchSection(),
                      _buildTabs(),
                      const SizedBox(height: 16),
                      IndexedStack(
                        index: selectedTabIndex,
                        children: [
                          _buildCallHistoryList(),
                          _buildFollowUpList(),
                          _buildCallLogList(),
                        ],
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

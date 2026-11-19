import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/core/app_colors.dart';
import 'package:login2/models/lead_management/attendanceAllmodel.dart';
import 'package:login2/models/lead_management/calendarDataModel.dart';
import 'package:login2/models/lead_management/dailyAllCountModel.dart';
import 'package:login2/screens/leadManagement/viewwork_page.dart';
import 'package:login2/service/service.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/expense/staffListModel.dart';
import 'package:login2/widgets/work_timer_overlay.dart';

class ViewCalendarPage extends StatefulWidget {
  const ViewCalendarPage({super.key});

  @override
  State<ViewCalendarPage> createState() => _ViewCalendarPageState();
}

class _ViewCalendarPageState extends State<ViewCalendarPage>
    with TickerProviderStateMixin {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Staff> _staffList = [];
  final Map<DateTime, String> _holidays = {};
  final Set<DateTime> _markedDates = {};
  List<AttendanceItem> _attendanceList = [];
  List<LeaveItem> _leaveList = [];
  CalendarDataAllModel? calendarDetails;
  List<DailyItem> _dailyList = [];
  bool _isLoading = false;
  String? markAttendance;
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _fetchStaffs(),
      _fetchAttendanceData(_focusedDay),
      fetchWorkCalendar(_focusedDay),
      fetchDailyCount(_focusedDay),
    ]);
    setState(() => _isLoading = false);
  }

  Future<void> _fetchStaffs() async {
    final staffData = await HttpService.getStaffs();
    if (staffData != null && staffData.data.isNotEmpty) {
      setState(() => _staffList = staffData.data);
    }
  }

  Future<void> _fetchAttendanceData(DateTime date) async {
    markAttendance = await Common.getSharedPref("markAttendance");
    final String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final attendanceData =
        await HttpService.getAttendanceAllData(date: formattedDate);
    if (attendanceData != null) {
      setState(() {
        _attendanceList = attendanceData.data.attendance;
        _leaveList = attendanceData.data.leave;
      });
    } else {
      setState(() {
        _attendanceList = [];
        _leaveList = [];
      });
    }
  }

  Future<void> fetchDailyCount(DateTime date) async {
    final String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final dailyData = await HttpService.getDailyCount(date: formattedDate);
    setState(() {
      _dailyList = dailyData?.data ?? [];
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    await Future.wait([
      _fetchAttendanceData(selectedDay),
      fetchDailyCount(selectedDay),
    ]);
  }

  void _showDayActionDialog(BuildContext context, DateTime date,
      {bool showHolidayInitially = false}) {
    final holidayNameController = TextEditingController();
    final holidayDescController = TextEditingController();
    final reasonController = TextEditingController();
    final today = DateTime.now();
    final selectedDateOnly = DateTime(date.year, date.month, date.day);
    final todayOnly = DateTime(today.year, today.month, today.day);
    final isFutureDate = selectedDateOnly.isAfter(todayOnly);

    if (showHolidayInitially) {
      final holidayKey = DateTime(date.year, date.month, date.day);
      holidayNameController.text = _holidays[holidayKey] ?? '';
    }

    // Create a state class to hold all dialog state
    final dialogState = _DialogState(
      selectedAction: '',
      selectedLeaveType: '',
      isStepTwo: false,
      showHolidaySection: showHolidayInitially,
      selectedStaffIds: {},
    );

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: 500,
          height: MediaQuery.of(context).size.height * 0.8,
          child: StatefulBuilder(builder: (context, setStateDialog) {
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
                        color: const Color.fromARGB(255, 255, 255, 255),
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('EEEE, MMM d, yyyy').format(date),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              dialogState.isStepTwo
                                  ? 'Step 2: Mark Details'
                                  : 'Step 1: Select Action',
                              style: TextStyle(
                                fontSize: 12,
                                color: const Color.fromARGB(255, 255, 255, 255),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          size: 20,
                          color: const Color.fromARGB(255, 255, 255, 255),
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
                        if (dialogState.selectedAction == 'holiday' ||
                            dialogState.showHolidaySection) ...[
                          _buildHolidaySection(
                            holidayNameController,
                            holidayDescController,
                            setStateDialog,
                          ),
                        ] else if (!isFutureDate) ...[
                          if (dialogState.isStepTwo) ...[
                            // Step 2: Marking Details
                            if (dialogState.selectedAction == 'attendance' ||
                                dialogState.selectedAction == 'halfDay') ...[
                              _buildAttendanceSection(
                                setStateDialog,
                                dialogState.selectedStaffIds,
                                dialogState.selectedAction,
                              ),
                            ] else if (dialogState.selectedAction ==
                                'leave') ...[
                              _buildLeaveSection(
                                dialogState.selectedLeaveType,
                                reasonController,
                                setStateDialog,
                                dialogState.selectedStaffIds,
                                (val) => setStateDialog(
                                    () => dialogState.selectedLeaveType = val),
                              ),
                            ],
                          ] else ...[
                            // Step 1: Action Selection List
                            _buildActionSelectionList(
                              dialogState,
                              setStateDialog,
                            ),
                          ],
                        ] else ...[
                          _buildFutureDateMessage(),
                        ],
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                if (dialogState.selectedAction.isEmpty) ...[
                  // No footer - just empty space
                  const SizedBox(height: 16),
                ] else ...[
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
                        if (dialogState.isStepTwo)
                          TextButton(
                            onPressed: () => setStateDialog(() {
                              dialogState.isStepTwo = false;
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
                        else
                          const SizedBox(),
                        const Spacer(),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            foregroundColor: Colors.grey.shade700,
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (!isFutureDate) ...[
                          if (dialogState.selectedAction == 'holiday' ||
                              dialogState.showHolidaySection)
                            ElevatedButton(
                              onPressed: () => _handleSaveHoliday(
                                context,
                                date,
                                holidayNameController.text,
                                holidayDescController.text,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange.shade600,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Save Holiday',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          else if (!dialogState.isStepTwo &&
                              dialogState.selectedAction.isNotEmpty)
                            ElevatedButton(
                              onPressed: () {
                                setStateDialog(() {
                                  dialogState.isStepTwo = true;
                                  if (dialogState.selectedAction == 'holiday') {
                                    dialogState.showHolidaySection = true;
                                  }
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
                          else if (dialogState.isStepTwo)
                            ElevatedButton(
                              onPressed: () => _handleSaveAction(
                                context,
                                date,
                                dialogState.selectedAction,
                                dialogState.selectedLeaveType,
                                reasonController.text,
                                dialogState.selectedAction == 'halfDay',
                                dialogState.selectedStaffIds.toList(),
                                setStateDialog,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _getColorForAction(
                                    dialogState.selectedAction),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Add',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ]
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildActionSelectionList(
    _DialogState dialogState,
    void Function(void Function()) setStateDialog,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ActionRadioItem(
          icon: Icons.check_circle_outline,
          title: 'Mark Attendance',
          subtitle: 'Mark staff as present for full day',
          isSelected: dialogState.selectedAction == 'attendance',
          actionType: 'attendance',
          color: Colors.green.shade600,
          onTap: () => setStateDialog(() {
            dialogState.selectedAction = 'attendance';
            dialogState.isStepTwo = true;
          }),
        ),
        const SizedBox(height: 12),
        _ActionRadioItem(
          icon: Icons.access_time,
          title: 'Mark Half Day',
          subtitle: 'Mark staff as present for half day',
          isSelected: dialogState.selectedAction == 'halfDay',
          actionType: 'halfDay',
          color: Colors.orange.shade600,
          onTap: () => setStateDialog(() {
            dialogState.selectedAction = 'halfDay';
            dialogState.isStepTwo = true;
          }),
        ),
        const SizedBox(height: 12),
        _ActionRadioItem(
          icon: Icons.beach_access_outlined,
          title: 'Mark Leave',
          subtitle: 'Mark staff on leave with leave type',
          isSelected: dialogState.selectedAction == 'leave',
          actionType: 'leave',
          color: Colors.blue.shade600,
          onTap: () => setStateDialog(() {
            dialogState.selectedAction = 'leave';
            dialogState.isStepTwo = true;
          }),
        ),
        const SizedBox(height: 12),
        _ActionRadioItem(
          icon: Icons.celebration_outlined,
          title: 'Mark Holiday',
          subtitle: 'Mark this day as a holiday',
          isSelected: dialogState.selectedAction == 'holiday',
          actionType: 'holiday',
          color: Colors.purple.shade600,
          onTap: () => setStateDialog(() {
            dialogState.selectedAction = 'holiday';
            dialogState.isStepTwo = true;
            dialogState.showHolidaySection = true;
          }),
        ),
      ],
    );
  }

  Widget _buildHolidaySection(
    TextEditingController nameController,
    TextEditingController descController,
    void Function(void Function()) setStateDialog,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Holiday Details',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.purple.shade700,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: nameController,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            labelText: 'Holiday Name',
            labelStyle: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            prefixIcon: Icon(
              Icons.celebration_outlined,
              size: 20,
              color: Colors.purple.shade600,
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
        const SizedBox(height: 8),
        Text(
          'Quick Select',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _HolidayChip(
              label: 'Saturday',
              isSelected: nameController.text == 'Saturday',
              onSelected: () {
                nameController.text = 'Saturday';
                setStateDialog(() {});
              },
            ),
            _HolidayChip(
              label: 'Sunday',
              isSelected: nameController.text == 'Sunday',
              onSelected: () {
                nameController.text = 'Sunday';
                setStateDialog(() {});
              },
            ),
            _HolidayChip(
              label: 'Public Holiday',
              isSelected: nameController.text == 'Public Holiday',
              onSelected: () {
                nameController.text = 'Public Holiday';
                setStateDialog(() {});
              },
            ),
            _HolidayChip(
              label: 'Festival',
              isSelected: nameController.text == 'Festival',
              onSelected: () {
                nameController.text = 'Festival';
                setStateDialog(() {});
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: descController,
          style: const TextStyle(fontSize: 14),
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Description (Optional)',
            labelStyle: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            prefixIcon: Icon(
              Icons.description_outlined,
              size: 20,
              color: Colors.purple.shade600,
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

  Widget _buildAttendanceSection(
    void Function(void Function()) setStateDialog,
    Set<String> selectedStaffIds,
    String selectedAction,
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
        _buildStaffSelector(
          selectedStaffIds,
          setStateDialog,
          selectedAction == 'halfDay'
              ? 'Select Staff for Half Day'
              : 'Select Staff for Full Day',
          Colors.green.shade50,
        ),
      ],
    );
  }

  Widget _buildLeaveSection(
    String selectedLeaveType,
    TextEditingController reasonController,
    void Function(void Function()) setStateDialog,
    Set<String> selectedStaffIds,
    ValueChanged<String> onLeaveTypeChanged,
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
              'Mark Leave',
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
          'Select leave type and staff members',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 16),

        // Leave Type - Mandatory
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
                color: Color.fromARGB(255, 8, 8, 8),
              ),
              hint: Text(
                'Select Leave Type',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Casual Leave',
                  child: Text('Casual Leave'),
                ),
                DropdownMenuItem(
                  value: 'Sick Leave',
                  child: Text('Sick Leave'),
                ),
                DropdownMenuItem(
                  value: 'LOP',
                  child: Text('Loss of Pay (LOP)'),
                ),
                DropdownMenuItem(
                  value: 'Other',
                  child: Text('Other'),
                ),
              ],
              onChanged: (value) {
                print('Leave type selected: $value'); // Debug print
                onLeaveTypeChanged(value ?? '');
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a leave type';
                }
                return null;
              },
              isExpanded: true,
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Reason
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

        const SizedBox(height: 16),
        _buildStaffSelector(
          selectedStaffIds,
          setStateDialog,
          'Select Staff on Leave',
          Colors.blue.shade50,
        ),
      ],
    );
  }

  Widget _buildStaffSelector(
    Set<String> selectedIds,
    void Function(void Function()) setStateDialog,
    String title,
    Color backgroundColor,
  ) {
    TextEditingController searchController = TextEditingController();

    return StatefulBuilder(
      builder: (context, setStateInner) {
        List<Staff> filteredStaffList = _staffList.where((staff) {
          if (searchController.text.isEmpty) return true;
          return staff.name
              .toLowerCase()
              .contains(searchController.text.toLowerCase());
        }).toList();

        return Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    // TextButton(
                    //   onPressed: () => setStateDialog(() {
                    //     if (selectedIds.length == _staffList.length) {
                    //       selectedIds.clear();
                    //     } else {
                    //       selectedIds.addAll(_staffList.map((e) => e.id));
                    //     }
                    //   }),
                    //   style: TextButton.styleFrom(
                    //     padding: EdgeInsets.zero,
                    //     minimumSize: Size.zero,
                    //     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    //   ),
                    //   child: Text(
                    //     selectedIds.length == _staffList.length
                    //         ? 'Deselect All'
                    //         : 'Select All',
                    //     style: TextStyle(
                    //       fontSize: 13,
                    //       color: Colors.blue.shade600,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: searchController,
                  onChanged: (value) => setStateInner(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search staff by name...',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      size: 20,
                      color: Colors.grey.shade600,
                    ),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              size: 18,
                              color: Colors.grey.shade600,
                            ),
                            onPressed: () {
                              searchController.clear();
                              setStateInner(() {});
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => setStateDialog(() {
                        if (selectedIds.length == _staffList.length) {
                          selectedIds.clear();
                        } else {
                          selectedIds.addAll(_staffList.map((e) => e.id));
                        }
                      }),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        selectedIds.length == _staffList.length
                            ? 'Deselect All'
                            : 'Select All',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade600,
                        ),
                      ),
                    ),
                    Text(
                      '${filteredStaffList.length} found',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(maxHeight: 180),
                  child: filteredStaffList.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.person_off_outlined,
                                  size: 40,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  searchController.text.isEmpty
                                      ? 'No staff available'
                                      : 'No staff found for "${searchController.text}"',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: filteredStaffList.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            color: Colors.grey.shade200,
                          ),
                          itemBuilder: (context, index) {
                            final staff = filteredStaffList[index];
                            return Container(
                              decoration: BoxDecoration(
                                color: selectedIds.contains(staff.id)
                                    ? Colors.blue.shade50
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: CheckboxListTile(
                                title: Text(
                                  staff.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade800,
                                    fontWeight: selectedIds.contains(staff.id)
                                        ? FontWeight.w500
                                        : FontWeight.normal,
                                  ),
                                ),
                                value: selectedIds.contains(staff.id),
                                onChanged: (checked) => setStateDialog(() {
                                  if (checked ?? false) {
                                    selectedIds.add(staff.id);
                                  } else {
                                    selectedIds.remove(staff.id);
                                  }
                                }),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                dense: true,
                                activeColor: Colors.blue.shade600,
                                checkColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${selectedIds.length} of ${_staffList.length} selected',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFutureDateMessage() {
    return Center(
        child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_clock,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'Cannot mark for future dates',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You can only mark attendance, leave, or holiday for today or past dates.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    ));
  }

  Future<void> _handleSaveAction(
    BuildContext context,
    DateTime date,
    String action,
    String leaveType,
    String reason,
    bool isHalfDay,
    List<String> staffIds,
    void Function(void Function()) setStateDialog,
  ) async {
    print('=== _handleSaveAction Debug ===');
    print('Action: $action');
    print('Leave Type: "$leaveType"');
    print('Leave Type length: ${leaveType.length}');
    print('Reason: "$reason"');
    print('Staff IDs: $staffIds');
    print('isHalfDay: $isHalfDay');
    if (staffIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select at least one staff member'),
          backgroundColor: Colors.orange.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      return;
    }

    if (action == 'leave' && leaveType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a leave type'),
          backgroundColor: Colors.orange.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      return;
    }

    setStateDialog(() {});

    try {
      bool success = false;
      String message = '';

      if (action == 'attendance' || action == 'halfDay') {
        final response = await HttpService.markAttendance(
          date: DateFormat('yyyy-MM-dd').format(date),
          staffIds: staffIds,
          isHalfDay: action == 'halfDay',
        );
        success = response ?? false;
        message = success
            ? '${action == 'halfDay' ? 'Half Day' : 'Full Day'} attendance marked successfully!'
            : 'Failed to mark attendance';
      }
      // else if (action == 'leave') {
      //   final response = await HttpService.markLeave(
      //     date: DateFormat('yyyy-MM-dd').format(date),
      //     staffIds: staffIds,
      //     leaveType: leaveType,
      //     reason: reason,
      //     isHalfDay: isHalfDay,
      //   );
      //   success = response ?? false;
      //   message =
      //       success ? 'Leave marked successfully!' : 'Failed to mark leave';
      // }
      else if (action == 'leave') {
        // Debug print to check values
        print('=== Mark Leave Debug ===');
        print('Date: ${DateFormat('yyyy-MM-dd').format(date)}');
        print('Staff IDs: $staffIds');
        print('Leave Type: $leaveType');
        print('Reason: $reason');

        final response = await HttpService.markLeave(
          date: DateFormat('yyyy-MM-dd').format(date),
          staffIds: staffIds,
          leaveType: leaveType,
          reason: reason,
          isHalfDay: isHalfDay,
        );

        print('Response: $response');
        success = response ?? false;
        message =
            success ? 'Leave marked successfully!' : 'Failed to mark leave';
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        Navigator.pop(context);
        await _refreshData(date);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  Future<void> _handleSaveHoliday(
    BuildContext context,
    DateTime date,
    String name,
    String description,
  ) async {
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter holiday name'),
          backgroundColor: Colors.orange.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      return;
    }

    final response = await HttpService.markHoliday(
      date: DateFormat('yyyy-MM-dd').format(date),
      name: name,
      description: description,
    );

    if (response ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Holiday marked successfully!'),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      setState(() {
        _holidays[DateTime(date.year, date.month, date.day)] = name;
      });
      Navigator.pop(context);
      await fetchWorkCalendar(_focusedDay);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to mark holiday'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  List<AttendanceItem> get _halfDayList => _attendanceList
      .where((a) => a.status.toLowerCase().contains('half'))
      .toList();

  void _showAttendanceLeaveViewDialog(BuildContext context, DateTime date) {
    const Color blue = Color(0xFF2F7FD1);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // ------------------------------------------------ header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 10, 12, 18),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4D9BE4), blue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    // drag handle
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.calendar_month_rounded,
                              color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('EEEE').format(date),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                DateFormat('MMM d, yyyy').format(date),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (markAttendance == "true")
                          _headerButton(
                            icon: Icons.edit_outlined,
                            tooltip: 'Edit',
                            onTap: () {
                              Navigator.pop(context);
                              _showDayActionDialog(context, date);
                            },
                          ),
                        const SizedBox(width: 6),
                        _headerButton(
                          icon: Icons.close_rounded,
                          tooltip: 'Close',
                          onTap: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ------------------------------------------------ summary tiles
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: _SummaryTile(
                        icon: Icons.check_circle_rounded,
                        label: 'Present',
                        count: _attendanceList.length,
                        color: Colors.green.shade600,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SummaryTile(
                        icon: Icons.beach_access_rounded,
                        label: 'Leave',
                        count: _leaveList.length,
                        color: Colors.orange.shade700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SummaryTile(
                        icon: Icons.timelapse_rounded,
                        label: 'Half Day',
                        count: _halfDayList.length,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // ------------------------------------------------ tabs + lists
              Expanded(
                child: DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      // segmented tab bar
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: TabBar(
                          dividerColor: Colors.transparent,
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelColor: blue,
                          unselectedLabelColor: Colors.grey.shade600,
                          labelStyle: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700),
                          unselectedLabelStyle: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500),
                          splashBorderRadius: BorderRadius.circular(10),
                          indicator: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          tabs: const [
                            Tab(height: 36, text: 'Attendance'),
                            Tab(height: 36, text: 'Leave'),
                            Tab(height: 36, text: 'Half Day'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _tabList<dynamic>(
                              _attendanceList,
                              (item) => _AttendanceCard(item: item),
                              icon: Icons.people_outline_rounded,
                              title: 'No attendance marked',
                              subtitle:
                                  'Nobody is marked present for this day.',
                              color: Colors.green.shade600,
                            ),
                            _tabList<dynamic>(
                              _leaveList,
                              (item) => _LeaveCard(item: item),
                              icon: Icons.beach_access_outlined,
                              title: 'No leave marked',
                              subtitle: 'No leave requests for this day.',
                              color: Colors.orange.shade700,
                            ),
                            _tabList<dynamic>(
                              _halfDayList,
                              (item) => _AttendanceCard(item: item),
                              icon: Icons.timelapse_rounded,
                              title: 'No half day marked',
                              subtitle: 'No half-day entries for this day.',
                              color: Colors.blue.shade600,
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
        ),
      ),
    );
  }

  Widget _headerButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withOpacity(0.2),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _tabList<T>(
    List<T> items,
    Widget Function(T item) itemBuilder, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    if (items.isEmpty) {
      return _EmptyTab(
          icon: icon, title: title, subtitle: subtitle, color: color);
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) => itemBuilder(items[index]),
    );
  }

  Future<void> fetchWorkCalendar(DateTime date) async {
    final monthyear = DateFormat('yyyy-MM').format(date);
    final response = await HttpService.getMonthyearWork(monthyear: monthyear);
    if (response != null) {
      setState(() {
        calendarDetails = response;
        _holidays.clear();
        _markedDates.clear();

        for (var h in response.data.holiday) {
          final parts = h.date.split('-');
          final date = DateTime.parse('${parts[2]}-${parts[1]}-${parts[0]}');
          _holidays[date] = h.holidayName;
        }

        for (var a in response.data.attendance) {
          final parts = a.date.split('-');
          _markedDates
              .add(DateTime.parse('${parts[2]}-${parts[1]}-${parts[0]}'));
        }

        for (var l in response.data.leave) {
          final parts = l.date.split('-');
          _markedDates
              .add(DateTime.parse('${parts[2]}-${parts[1]}-${parts[0]}'));
        }
      });
    }
  }

  Future<void> _refreshData(DateTime date) async {
    await Future.wait([
      _fetchAttendanceData(date),
      fetchDailyCount(date),
      fetchWorkCalendar(_focusedDay),
    ]);
  }

  Color _getColorForAction(String action) {
    switch (action) {
      case 'attendance':
        return Colors.green.shade600;
      case 'halfDay':
        return Colors.orange.shade600;
      case 'leave':
        return Colors.blue.shade600;
      case 'holiday':
        return Colors.purple.shade600;
      default:
        return Colors.blue.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calendar',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        // centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.appBarGradient,
          ),
        ),
      ),
      body: WorkTimerOverlay(
        onTimerReturn: _loadInitialData,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                ),
              )
            : SingleChildScrollView(
              child: Column(
                children: [
                  // Calendar
                  Card(
                    margin: const EdgeInsets.all(16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TableCalendar(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) =>
                            isSameDay(_selectedDay, day),
                        onDaySelected: _onDaySelected,
                        onPageChanged: (focusedDay) {
                          setState(() => _focusedDay = focusedDay);
                          fetchWorkCalendar(focusedDay);
                        },
                        calendarStyle: CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: Colors.orange.shade600,
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: Colors.blue.shade600,
                            shape: BoxShape.circle,
                          ),
                          holidayDecoration: BoxDecoration(
                            color: Colors.red.shade50,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.red.shade400,
                              width: 2,
                            ),
                          ),
                          holidayTextStyle: TextStyle(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                          defaultTextStyle: const TextStyle(fontSize: 13),
                          weekendTextStyle: TextStyle(
                            color: Colors.red.shade400,
                          ),
                        ),
                        headerStyle: HeaderStyle(
                          titleCentered: true,
                          formatButtonVisible: false,
                          titleTextStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          leftChevronIcon: Icon(
                            Icons.chevron_left,
                            color: Colors.blue.shade600,
                          ),
                          rightChevronIcon: Icon(
                            Icons.chevron_right,
                            color: Colors.blue.shade600,
                          ),
                        ),
                        daysOfWeekStyle: const DaysOfWeekStyle(
                          weekdayStyle: TextStyle(fontWeight: FontWeight.w500),
                          weekendStyle: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                          ),
                        ),
                        holidayPredicate: (day) => _holidays.containsKey(
                            DateTime(day.year, day.month, day.day)),
                        calendarBuilders: CalendarBuilders(
                          markerBuilder: (context, day, events) {
                            final key = DateTime(day.year, day.month, day.day);

                            if (_holidays.containsKey(key)) {
                              return Stack(
                                children: [
                                  Positioned(
                                    bottom: 1,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade400,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        _holidays[key] ?? '',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            } else if (_markedDates.contains(key)) {
                              return const Positioned(
                                bottom: 1,
                                child: Icon(Icons.check_circle,
                                    size: 14, color: Colors.green),
                              );
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),

                  // Legend
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        _LegendItem(
                          color: Colors.orange.shade600,
                          label: 'Today',
                          icon: Icons.circle,
                        ),
                        _LegendItem(
                          color: Colors.blue.shade600,
                          label: 'Selected',
                          icon: Icons.circle,
                        ),
                        _LegendItem(
                          color: Colors.red.shade400,
                          label: 'Holiday',
                          icon: Icons.celebration,
                        ),
                        _LegendItem(
                          color: Colors.green,
                          label: 'Marked',
                          icon: Icons.check_circle,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 5),

                  // Statistics Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.analytics_outlined,
                                  color: Colors.blue.shade700,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Today\'s Summary',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  DateFormat('MMM d, yyyy')
                                      .format(_selectedDay ?? _focusedDay),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Column(
                              children: [
                                _StatListItem(
                                  icon: Icons.check_circle,
                                  label: 'Present Today',
                                  count: _dailyList.isNotEmpty
                                      ? _dailyList.first.presentCount
                                      : 0,
                                  color: Colors.green.shade600,
                                ),
                                const SizedBox(height: 12),
                                _StatListItem(
                                  icon: Icons.beach_access,
                                  label: 'Leave Today',
                                  count: _dailyList.isNotEmpty
                                      ? _dailyList.first.absentCount
                                      : 0,
                                  color: Colors.orange.shade600,
                                ),
                                const SizedBox(height: 12),
                                _StatListItem(
                                  icon: Icons.access_time,
                                  label: 'Half Day',
                                  count: _dailyList.isNotEmpty
                                      ? _dailyList.first.halfDayCount
                                      : 0,
                                  color: Colors.blue.shade600,
                                ),
                                const SizedBox(height: 4),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Action Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton(
                      onPressed: () {
                        final selectedDay = _selectedDay ?? _focusedDay;
                        final isHoliday = _holidays.containsKey(DateTime(
                            selectedDay.year,
                            selectedDay.month,
                            selectedDay.day));
                        if (isHoliday) {
                          _showDayActionDialog(context, selectedDay,
                              showHolidayInitially: true);
                        } else if (_attendanceList.isNotEmpty ||
                            _leaveList.isNotEmpty) {
                          _showAttendanceLeaveViewDialog(context, selectedDay);
                        } else {
                          _showDayActionDialog(context, selectedDay);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _attendanceList.isNotEmpty || _leaveList.isNotEmpty
                                ? Icons.remove_red_eye
                                : Icons.add,
                            size: 20,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _attendanceList.isNotEmpty || _leaveList.isNotEmpty
                                ? 'View Details'
                                : 'Add Attendance/Leave',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
      ),
    );
  }
}

// Dialog State Class
class _DialogState {
  String selectedAction;
  String selectedLeaveType;
  bool isStepTwo;
  bool showHolidaySection;
  Set<String> selectedStaffIds;

  _DialogState({
    required this.selectedAction,
    required this.selectedLeaveType,
    required this.isStepTwo,
    required this.showHolidaySection,
    required this.selectedStaffIds,
  });
}

// Supporting Widgets

class _ActionRadioItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final Color color;
  final String actionType;
  final VoidCallback onTap;

  const _ActionRadioItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.color,
    required this.actionType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
            Radio(
              value: actionType,
              groupValue: isSelected ? actionType : '',
              onChanged: (value) => onTap(),
              activeColor: color,
            ),
          ],
        ),
      ),
    );
  }
}

class _HolidayChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _HolidayChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: isSelected ? Colors.white : Colors.purple.shade700,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      backgroundColor: Colors.white,
      selectedColor: Colors.purple.shade600,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? Colors.purple.shade600 : Colors.grey.shade400,
          width: 1,
        ),
      ),
      checkmarkColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  final AttendanceItem item;

  const _AttendanceCard({required this.item});

  // show "--:--" when a time is empty / null
  static String _time(dynamic v) {
    final s = (v ?? '').toString().trim();
    return (s.isEmpty || s == 'null') ? '--:--' : s;
  }

  @override
  Widget build(BuildContext context) {
    final bool isFull = item.status == "Full Day";
    final Color color = isFull ? Colors.green.shade600 : Colors.orange.shade700;
    final String name = item.staffName.toString();
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: color.withOpacity(0.08),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ViewWorkPage(
                  staffId: item.staffId,
                  selectedDate: DateTime.now(),
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // avatar with status-coloured tint
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    initial,
                    style: TextStyle(
                      color: color,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // status chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              item.status.toString(),
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // in  ->  out
                      Row(
                        children: [
                          Icon(Icons.login_rounded,
                              size: 14, color: Colors.green.shade600),
                          const SizedBox(width: 4),
                          Text(
                            _time(item.loginTime),
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(Icons.arrow_forward_rounded,
                                size: 13, color: Colors.grey.shade400),
                          ),
                          Icon(Icons.logout_rounded,
                              size: 14, color: Colors.red.shade400),
                          const SizedBox(width: 4),
                          Text(
                            _time(item.logoutTime),
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: Colors.grey.shade400, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LeaveCard extends StatelessWidget {
  final LeaveItem item;

  const _LeaveCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final Color color = Colors.orange.shade700;
    final String name = item.staffName.toString();
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final String reason = item.reason.toString().trim();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // avatar
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  initial,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // name + leave type chip
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.beach_access_rounded,
                              size: 12, color: color),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              item.leaveType.toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // reason box (only when there is a reason)
          if (reason.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.notes_rounded,
                      size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      reason,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.35,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatListItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  const _StatListItem({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 15,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'staff',
                    style: TextStyle(
                      fontSize: 10,
                      color: color.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  const _StatBadge({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final IconData icon;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon == Icons.circle
            ? Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              )
            : Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  const _SummaryTile({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: count),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, __) => Text(
                    '$v',
                    style: TextStyle(
                      fontSize: 20,
                      height: 1.0,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyTab extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _EmptyTab({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: color.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color.withOpacity(0.8)),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

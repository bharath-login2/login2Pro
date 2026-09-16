import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/expense/expense_post.dart';
import 'package:login2/screens/leadManagement/AssignReport.dart';
import 'package:login2/screens/leadManagement/addWork_page.dart';
import 'package:login2/screens/leadManagement/login_summary_page.dart';
import 'package:login2/widgets/blinkngTime.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/lead_management/workDetailsModel.dart' as workDetails;
import 'package:login2/models/lead_management/workstatus_model.dart'
    as workStatus;
import '../../service/service.dart';

class ViewWorkPage extends StatefulWidget {
  final String? staffName;
  final String staffId;
  final DateTime? selectedDate;
  const ViewWorkPage(
      {super.key, this.selectedDate, required this.staffId, this.staffName});

  @override
  State<ViewWorkPage> createState() => _ViewWorkPageState();
}

class _ViewWorkPageState extends State<ViewWorkPage> {
  late String currentDate;
  workDetails.WorkDetailsModel? workStatusDetails;
  workStatus.WorkStatus? existingWork;
  bool isLoading = true;
  bool _isPanelOpen = false;
  final double _panelWidth = 200.0;
  double _panelPosition = -200.0;
  String token = "";
  //workDetails.Data? currentRunningItem;
  late DateTime selectedDate;
  CommonResponse? loginOrNot;
  bool? isLoggedIn;
  String? userId;
  String? addWorkPermission;
  // @override
  // void initState() {
  //   super.initState();
  //   // currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  //   selectedDate = widget.selectedDate ?? DateTime.now();
  //   currentDate =
  //       DateFormat('yyyy-MM-dd').format(widget.selectedDate ?? DateTime.now());

  //   print("Selected date passed to ViewWorkPage: ${widget.selectedDate}");
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     getWorkDuration(currentDate);
  //     checkExistingWorkStatus();
  //   });
  //   loadToken();
  // }
  // @override
  // void initState() {
  //   super.initState();
  //   selectedDate = widget.selectedDate ?? DateTime.now();
  //   currentDate = DateFormat('yyyy-MM-dd').format(selectedDate);
  //    final userId =  Common.getSharedPref("userId");
  //   print("Selected date passed to ViewWorkPage: ${widget.selectedDate}");
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     getWorkDuration(currentDate);
  //     checkExistingWorkStatus();
  //   });
  //   loadToken();
  //   loginorNot();
  //    getStaffid();
  // }
  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedDate ?? DateTime.now();
    currentDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    print("Selected date passed to ViewWorkPage: ${widget.selectedDate}");
    _initData();
    loginorNot();
  }

  Future<void> _initData() async {
    userId = await Common.getSharedPref("userId");
    addWorkPermission = await Common.getSharedPref("addWorkPermission");
    print("userId:$userId");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getWorkDuration(currentDate);
      checkExistingWorkStatus();
    });
    await loadToken();
    await loginorNot();
  }

  Future<void> loadToken() async {
    token = await Common.getSharedPref("token");
    setState(() {});
  }

  Future<void> checkExistingWorkStatus() async {
    final workStatusModel = await HttpService.getWorkStatus();
    setState(() {
      if (workStatusModel != null && workStatusModel.data.isNotEmpty) {
        existingWork = workStatusModel.data.first;
      } else {
        existingWork = null;
      }
    });
  }

  String formatDueDate(String? dueDate) {
    if (dueDate == null || dueDate.isEmpty) return '';
    try {
      DateTime? parsedDate;
      final formats = [
        DateFormat('dd-MM-yyyy hh:mm a'),
        DateFormat('dd-MM-yyyy HH:mm:ss'),
        DateFormat('dd-MM-yyyy HH:mm'),
        DateFormat('yyyy-MM-dd HH:mm:ss'),
        DateFormat('yyyy-MM-dd HH:mm'),
        DateFormat('dd-MM-yyyy'),
        DateFormat('yyyy-MM-dd'),
      ];
      for (var f in formats) {
        try {
          parsedDate = f.parse(dueDate.trim());
          break;
        } catch (_) {}
      }
      parsedDate ??= DateTime.tryParse(dueDate.trim());
      if (parsedDate != null) {
        if (parsedDate.hour != 0 || parsedDate.minute != 0) {
          return DateFormat('dd-MM-yyyy hh:mm a').format(parsedDate);
        }
        return DateFormat('dd-MM-yyyy').format(parsedDate);
      }
      return dueDate;
    } catch (e) {
      return dueDate;
    }
  }

  Future<void> loginorNot() async {
    final token = await Common.getSharedPref("token");
    final response = await HttpService.getLoginorNot(token);

    setState(() {
      if (response != null && response.data == true) {
        isLoggedIn = true;
      } else {
        isLoggedIn = false;
      }
    });
  }

  void _launchMap(String? latitude, String? longitude) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    final uri = Uri.parse(url);

    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        debugPrint('Could not launch URL: $url');
      }
    } catch (e) {
      debugPrint('Exception when launching URL: $e');
    }
  }

  Future<void> getWorkDuration(String date) async {
    final response =
        await HttpService.getWorkStatusDetails(date, staffId: widget.staffId);
    setState(() {
      workStatusDetails = response;
      isLoading = false;
    });
  }

  String getDurationSinceLogin(String? loginTimeString) {
    if (loginTimeString == null || loginTimeString.isEmpty) return "--";
    try {
      final loginTime = DateTime.parse(loginTimeString);
      final now = DateTime.now();
      final duration = now.difference(loginTime);
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      if (hours == 0 && minutes == 0) return "Just now";
      if (hours == 0) return "$minutes min ago";
      return "$hours hr ${minutes.toString().padLeft(2, '0')} min ago";
    } catch (e) {
      return "--";
    }
  }

  String _formatDuration(String? duration) {
    if (duration == null || duration.isEmpty) return "Started";
    try {
      if (duration.contains(':')) {
        final parts = duration.split(':');
        if (parts.length == 3) {
          final hours = int.parse(parts[0]);
          final minutes = int.parse(parts[1]);
          final seconds = int.parse(parts[2]);
          if (hours > 0) return "${hours}h ${minutes}m";
          if (minutes > 0) return "${minutes}m ${seconds}s";
          return "${seconds}s";
        }
      }
      final seconds = int.tryParse(duration) ?? 0;
      return "${seconds}s";
    } catch (e) {
      return "0s";
    }
  }

  void _togglePanel() {
    setState(() {
      _isPanelOpen = !_isPanelOpen;
      _panelPosition = _isPanelOpen ? 0 : -_panelWidth;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: widget.staffName != null && widget.staffName!.isNotEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.staffName != null && widget.staffName!.isNotEmpty)
                    Text(
                      widget.staffName!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const Text(
                    "Work Timeline",
                    style: TextStyle(
                      fontSize: 14,
                      // fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Work Timeline",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
        backgroundColor: const Color.fromARGB(255, 77, 155, 228),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked != null && picked != selectedDate) {
                setState(() {
                  selectedDate = picked;
                  currentDate = DateFormat('yyyy-MM-dd').format(picked);
                  isLoading = true;
                });
                await getWorkDuration(currentDate);
              }
            },
          ),
        ],
      ),
      floatingActionButton: ((widget.staffId != "")
                  ? (userId != null && widget.staffId == userId)
                  : (userId != null)) &&
              addWorkPermission == "true"
          ? (existingWork != null
              ? StreamBuilder<DateTime>(
                  stream: Stream.periodic(
                    const Duration(seconds: 1),
                    (_) => DateTime.now(),
                  ),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();
                    final now = snapshot.data!;
                    final createdAt = DateTime.parse(existingWork!.createdAt);
                    final diff = now.difference(createdAt);
                    String timeSince =
                        "${diff.inHours.toString().padLeft(2, '0')}:"
                        "${(diff.inMinutes % 60).toString().padLeft(2, '0')}:"
                        "${(diff.inSeconds % 60).toString().padLeft(2, '0')}";
                    return FloatingActionButton.extended(
                      onPressed: () async {
                        final workStatusModel =
                            await HttpService.getWorkStatus();
                        workStatus.WorkStatus? newExistingWork;
                        if (workStatusModel != null &&
                            workStatusModel.data.isNotEmpty) {
                          newExistingWork = workStatusModel.data.first;
                        }
                        final paused = await showDialog(
                          context: context,
                          builder: (context) => AddWorkPage(
                            workId: "",
                            existingWork: newExistingWork,
                            isAssigned: 1,
                            onSuccess: () {
                              setState(() {
                                getWorkDuration(currentDate);
                                checkExistingWorkStatus();
                              });
                            },
                          ),
                        );

                        if (paused == true) {
                          setState(() {
                            existingWork = null;
                          });
                          getWorkDuration(currentDate);
                        }
                      },
                      backgroundColor: Colors.red,
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            timeSince,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.pause, color: Colors.white),
                        ],
                      ),
                    );
                  },
                )
              : FloatingActionButton(
                  onPressed: () async {
                    if (isLoggedIn == true) {
                      final workStatusModel = await HttpService.getWorkStatus();
                      workStatus.WorkStatus? newExistingWork;

                      if (workStatusModel != null &&
                          workStatusModel.data.isNotEmpty) {
                        newExistingWork = workStatusModel.data.first;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddWorkPage(
                            workId: "",
                            existingWork: newExistingWork,
                            onSuccess: () {
                              setState(() {
                                getWorkDuration(currentDate);
                                checkExistingWorkStatus();
                              });
                            },
                          ),
                        ),
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Login Required'),
                            content: const Text('Please login to add work.'),
                            actions: [
                              TextButton(
                                child: const Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.add, color: Colors.white),
                ))
          : null,
      body: Stack(
        children: [
          // _buildMainContent(),
          GestureDetector(
            onTap: () {
              if (_isPanelOpen) {
                _togglePanel();
              }
            },
            child: AbsorbPointer(
              absorbing: _isPanelOpen,
              child: _buildMainContent(),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            right: _panelPosition,
            top: 0,
            bottom: 0,
            width: _panelWidth,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                if (details.delta.dx < 0) {
                  // Swiping left
                  setState(() {
                    _panelPosition = (_panelPosition - details.delta.dx)
                        .clamp(-_panelWidth, 0.0);
                  });
                } else if (details.delta.dx > 0) {
                  // Swiping right
                  setState(() {
                    _panelPosition = (_panelPosition - details.delta.dx)
                        .clamp(-_panelWidth, 0.0);
                  });
                }
              },
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity! < 0) {
                  // Swiped left
                  _togglePanel();
                } else if (details.primaryVelocity! > 0) {
                  // Swiped right
                  _togglePanel();
                } else {
                  // No significant velocity - snap to nearest state
                  if (_panelPosition.abs() > _panelWidth / 2) {
                    _togglePanel();
                  } else {
                    _togglePanel();
                  }
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(-3, 0),
                    ),
                  ],
                ),
                child: _buildTimeSummaryPanel(),
              ),
            ),
          ),
          if (!_isPanelOpen)
            Positioned(
              right: 0,
              top: MediaQuery.of(context).size.height / 2 - 50,
              child: GestureDetector(
                onTap: _togglePanel,
                child: Container(
                  width: 24,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(-2, 0),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : (workStatusDetails == null ||
                      workStatusDetails!.data.isEmpty ||
                      workStatusDetails!.data.first.tasks.isEmpty)
                  ? const Center(child: Text("No work data available"))
                  : RefreshIndicator(
                      onRefresh: () async {
                        setState(() {
                          isLoading = true;
                        });
                        await getWorkDuration(currentDate);
                        await checkExistingWorkStatus();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        itemCount: workStatusDetails!.data.length,
                        itemBuilder: (context, index) {
                          final item = workStatusDetails!.data[index];
                          final hasAssignment = item.assigns
                              .any((assign) => assign.assignedBy.isNotEmpty);
                          List<bool> expandedTasks =
                              List.generate(item.tasks.length, (index) => true);

                          final isInProgress = item.endTime == "00:00:00" ||
                              item.endTime.isEmpty;
                          final showDateHeader = index == 0 ||
                              _getDateFromTime(item.startTime) !=
                                  _getDateFromTime(workStatusDetails!
                                      .data[index - 1].startTime);
                          if (item.title != "") {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (showDateHeader)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8, bottom: 12),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade50,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              _getDayFromTime(currentDate),
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue.shade800,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          _getMonthYearFromTime(currentDate),
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      children: [
                                        Container(
                                          width: 16,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: isInProgress
                                                ? Colors.orange
                                                : Colors.green,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                        if (index !=
                                            workStatusDetails!.data.length - 1)
                                          Container(
                                            width: 2,
                                            height: _calculateItemHeight(
                                                    item.tasks) +
                                                210,
                                            color: Colors.grey.shade300,
                                          ),
                                      ],
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 8),
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: hasAssignment
                                                  ? const Color.fromARGB(
                                                      255, 255, 249, 220)
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.05),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 2),
                                                )
                                              ],
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Flexible(
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  AssignReport(
                                                                      workId: item
                                                                          .id,
                                                                      sectionId:
                                                                          ""),
                                                            ),
                                                          );
                                                        },
                                                        child: Text(
                                                          '${item.customerName ?? "No title"} [${item.projectName}]',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                          softWrap: true,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    (item.totalDuration
                                                                .isNotEmpty) &&
                                                            item.is_paused !=
                                                                "0"
                                                        ? Text(
                                                            "Worked:${item.totalDuration}",
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              color: Colors.grey
                                                                  .shade600,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          )
                                                        : (isInProgress ==
                                                                    false &&
                                                                userId !=
                                                                    null &&
                                                                widget.staffId ==
                                                                    userId
                                                            ? GestureDetector(
                                                                onTap: () async {
                                                                  await loginorNot();
                                                                  if (isLoggedIn ==
                                                                      true) {
                                                                    bool isAnyWorkInProgress = workStatusDetails!.data.any((w) =>
                                                                        w.endTime ==
                                                                            "00:00:00" ||
                                                                        w.endTime
                                                                            .isEmpty);
                                                                    if (isAnyWorkInProgress) {
                                                                      Common.toastMessaage(
                                                                          'Work is in progress. Please stop the work before restarting new work',
                                                                          Colors
                                                                              .red);
                                                                      return;
                                                                    }
                                                                    final workStatusModel =
                                                                        await HttpService
                                                                            .getWorkStatusPaused(
                                                                                item.id);
                                                                    workStatus
                                                                        .WorkStatus?
                                                                        newExistingWork;
                                                                    if (workStatusModel !=
                                                                            null &&
                                                                        workStatusModel
                                                                            .data
                                                                            .isNotEmpty) {
                                                                      newExistingWork =
                                                                          workStatusModel
                                                                              .data
                                                                              .first;
                                                                    }
                                                                    Navigator
                                                                        .push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                AddWorkPage(
                                                                          workId:
                                                                              item.id,
                                                                          existingWork:
                                                                              null,
                                                                          isPaused:
                                                                              0,
                                                                          Restart:
                                                                              1,
                                                                          onSuccess:
                                                                              () {
                                                                            setState(
                                                                                () {
                                                                              checkExistingWorkStatus();
                                                                            });
                                                                          },
                                                                        ),
                                                                      ),
                                                                    );
                                                                  } else {
                                                                    showDialog(
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (BuildContext
                                                                              context) {
                                                                        return AlertDialog(
                                                                          title:
                                                                              const Text('Login Required'),
                                                                          content:
                                                                              const Text('Please login to restart work.'),
                                                                          actions: [
                                                                            TextButton(
                                                                              child:
                                                                                  const Text('OK'),
                                                                              onPressed:
                                                                                  () {
                                                                                Navigator.of(context).pop();
                                                                              },
                                                                            ),
                                                                          ],
                                                                        );
                                                                      },
                                                                    );
                                                                  }
                                                                },
                                                                child:
                                                                    const Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    Icon(
                                                                      Icons
                                                                          .restart_alt,
                                                                      size: 20,
                                                                      color: Color.fromARGB(
                                                                          255,
                                                                          29,
                                                                          183,
                                                                          230),
                                                                    ),
                                                                    SizedBox(
                                                                        width:
                                                                            4),
                                                                    Text(
                                                                      "Restart",
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        color: Color.fromARGB(
                                                                            255,
                                                                            29,
                                                                            183,
                                                                            230),
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ],
                                                                ),
                                                              )
                                                            : Text(
                                                                "Running...",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 14,
                                                                  color: Colors
                                                                      .grey
                                                                      .shade600,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ))
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  "Module: ${item.titleName}",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    Text(
                                                      "Start: ${item.startTime}",
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: Colors
                                                            .grey.shade600,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    isInProgress
                                                        ? const Row(
                                                            children: [
                                                              Text(""),
                                                              BlinkingText(
                                                                text: "Running",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 13,
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          148,
                                                                          233,
                                                                          50),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        : Text(
                                                            "End: ${item.endTime}",
                                                            style: TextStyle(
                                                              fontSize: 13,
                                                              color: Colors.grey
                                                                  .shade600,
                                                            ),
                                                          ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                if (item.latitude.isNotEmpty &&
                                                    double.tryParse(
                                                            item.latitude) !=
                                                        0)
                                                  Row(
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () => _launchMap(
                                                            item.latitude,
                                                            item.longitude),
                                                        child: const Text(
                                                          "View Location",
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.blue,
                                                            decoration:
                                                                TextDecoration
                                                                    .underline,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ...item.tasks
                                                    .asMap()
                                                    .entries
                                                    .map((entry) {
                                                  int index = entry.key;
                                                  var task = entry.value;
                                                  return StatefulBuilder(
                                                    builder:
                                                        (context, setState) {
                                                      return Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          GestureDetector(
                                                            onTap: () {
                                                              setState(() {
                                                                expandedTasks[
                                                                        index] =
                                                                    !expandedTasks[
                                                                        index];
                                                              });
                                                            },
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      bottom:
                                                                          8),
                                                              child: Row(
                                                                children: [
                                                                  Container(
                                                                    width: 8,
                                                                    height: 8,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: _getStatusColor(
                                                                          task.status),
                                                                      shape: BoxShape
                                                                          .circle,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      width: 8),
                                                                  Expanded(
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          task.taskName,
                                                                          style:
                                                                              const TextStyle(fontSize: 14),
                                                                        ),
                                                                        const SizedBox(
                                                                            height:
                                                                                4),
                                                                        Row(
                                                                          children: [
                                                                            Text(
                                                                              '${task.taskStart} - ${task.taskEnd}',
                                                                              style: const TextStyle(
                                                                                fontSize: 12,
                                                                                color: Colors.grey,
                                                                              ),
                                                                            ),
                                                                            const SizedBox(width: 15),
                                                                            Container(
                                                                              padding: const EdgeInsets.symmetric(
                                                                                horizontal: 8,
                                                                                vertical: 2,
                                                                              ),
                                                                              decoration: BoxDecoration(
                                                                                color: _getStatusColor(task.status).withOpacity(0.2),
                                                                                borderRadius: BorderRadius.circular(4),
                                                                              ),
                                                                              child: Text(
                                                                                task.status,
                                                                                style: TextStyle(
                                                                                  fontSize: 12,
                                                                                  color: _getStatusColor(task.status),
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
                                                            ),
                                                          ),
                                                          AnimatedSize(
                                                            duration:
                                                                const Duration(
                                                                    milliseconds:
                                                                        300),
                                                            curve: Curves
                                                                .easeInOut,
                                                            child: expandedTasks[
                                                                    index]
                                                                ? Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            16,
                                                                        bottom:
                                                                            8),
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        const Text(
                                                                          'Remarks:',
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                13,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            color:
                                                                                Colors.black87,
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                            height:
                                                                                4),
                                                                        ...task
                                                                            .remarks
                                                                            .map((remark) {
                                                                          return Padding(
                                                                            padding:
                                                                                const EdgeInsets.symmetric(vertical: 2),
                                                                            child:
                                                                                Text(
                                                                              '• $remark',
                                                                              style: const TextStyle(
                                                                                fontSize: 12,
                                                                                color: Colors.black87,
                                                                              ),
                                                                            ),
                                                                          );
                                                                        }),
                                                                      ],
                                                                    ),
                                                                  )
                                                                : const SizedBox(),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                }),
                                                if (item.assigns.any((assign) =>
                                                    assign.assignedBy
                                                        .isNotEmpty)) ...[
                                                  const SizedBox(height: 12),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            12),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.grey.shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      border: Border.all(
                                                        color: Colors
                                                            .grey.shade300,
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const Text(
                                                          "Assignment Details",
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.blueGrey,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 8),
                                                        ...item.assigns
                                                            .map((assign) {
                                                          return Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              if (assign.dueDate
                                                                  .isNotEmpty)
                                                                // _buildAssignDetailRow(
                                                                //   "Due Date",
                                                                //   assign
                                                                //       .dueDate,
                                                                //   Icons
                                                                //       .calendar_today,
                                                                // ),
                                                                _buildAssignDetailRow(
                                                                  "Due Date",
                                                                  formatDueDate(
                                                                      assign
                                                                          .dueDate),
                                                                  Icons
                                                                      .calendar_today,
                                                                ),
                                                              if (assign
                                                                  .priority
                                                                  .isNotEmpty)
                                                                _buildAssignDetailRow(
                                                                  "Priority",
                                                                  _getPriorityText(
                                                                      assign
                                                                          .priority),
                                                                  Icons
                                                                      .priority_high,
                                                                ),
                                                              if (assign
                                                                  .assignedBy
                                                                  .isNotEmpty)
                                                                _buildAssignDetailRow(
                                                                  "Assigned By",
                                                                  assign
                                                                      .assignedBy,
                                                                  Icons.person,
                                                                ),
                                                            ],
                                                          );
                                                        }),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 12),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.05),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 2),
                                                )
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text(
                                                  "Ideal Time:",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                Text(
                                                  _formatDuration(
                                                      item.gapDuration),
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.redAccent,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildTimeSummaryPanel() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.blue,
          child: Row(
            children: [
              const Text(
                "Time Summary",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.white),
                onPressed: _togglePanel,
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTimeSummaryItem(
                  "Login",
                  (workStatusDetails != null &&
                          workStatusDetails!.data.isNotEmpty)
                      ? workStatusDetails!.data.first.loginTime
                      : "--",
                  Icons.login,
                  Colors.green,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginSummaryPage(
                          staffId: widget.staffId,
                          token: token,
                          date: widget.selectedDate ?? DateTime.now(),
                        ),
                      ),
                    );
                  },
                ),
                // _buildTimeSummaryItem(
                //   "Work Time",
                //   (workStatusDetails != null &&
                //           workStatusDetails!.data.isNotEmpty)
                //       ? workStatusDetails!.data.first.totalWorkingTime ?? "--"
                //       : "--",
                //   Icons.timer,
                //   Colors.purple,
                // ),

                _buildTimeSummaryItem(
                  "Ideal",
                  (workStatusDetails != null &&
                          workStatusDetails!.data.isNotEmpty)
                      ? workStatusDetails!.data.first.totalIdeaTime ?? "--"
                      : "--",
                  Icons.hourglass_empty,
                  Colors.orange,
                ),
                // _buildTimeSummaryItem(
                //   "Break",
                //   (workStatusDetails != null &&
                //           workStatusDetails!.data.isNotEmpty)
                //       ? workStatusDetails!.data.first.totalIdeaTime ?? "--"
                //       : "--",
                //   Icons.free_breakfast,
                //   Colors.blue,
                // ),

                _buildTimeSummaryItem(
                  "Loggedin Time",
                  (workStatusDetails != null &&
                          workStatusDetails!.data.isNotEmpty)
                      ? workStatusDetails!.data.first.TimeDifference
                      : "--",
                  Icons.timeline_rounded,
                  Colors.green,
                ),

                _buildTimeSummaryItem(
                  "Logout",
                  (workStatusDetails != null &&
                          workStatusDetails!.data.isNotEmpty)
                      ? workStatusDetails!.data.first.logoutTime ?? "--"
                      : "--",
                  Icons.logout,
                  Colors.redAccent,
                ),
                _buildTimeSummaryItem(
                  "Work Time",
                  (workStatusDetails != null &&
                          workStatusDetails!.data.isNotEmpty)
                      ? workStatusDetails!.data.first.totalWorkingTime ?? "--"
                      : "--",
                  Icons.timer,
                  Colors.deepPurpleAccent,
                  isHighlight: true,
                ),
                // _buildTimeSummaryItem(
                //   "Total",
                //   (workStatusDetails != null &&
                //           workStatusDetails!.data.isNotEmpty)
                //       ? workStatusDetails!.data.first.totalWorkingTime ?? "--"
                //       : "--",
                //   Icons.timer,
                //   Colors.purple,
                // ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSummaryItem(
    String title,
    String value,
    IconData icon,
    Color color, {
    bool isHighlight = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: title == "Work Time"
              ? Border.all(
                  color: Colors.deepPurpleAccent,
                  width: 2) // Only for Work Time
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black54)),
                  const SizedBox(height: 4),
                  Text(value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            isHighlight ? FontWeight.bold : FontWeight.normal,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateItemHeight(List<workDetails.Task> tasks) {
    return 60 + (tasks.length * 28.0);
  }

  Widget _buildAssignDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getPriorityText(String priority) {
    switch (priority) {
      case "1":
        return "Normal";
      case "2":
        return "High";
      case "3":
        return "Critical";
      default:
        return priority;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'complete':
        return Colors.green;
      case 'pending':
        return const Color.fromARGB(255, 172, 201, 7);
      case 'To Do':
        return Colors.blue;
      case 'in-progress':
        return const Color.fromARGB(255, 226, 117, 15);
      case 'cancelled':
        return const Color.fromARGB(255, 164, 21, 19);
      default:
        return const Color.fromARGB(255, 42, 188, 251);
    }
  }

  String _getDayFromTime(String? time) {
    final date = _parseDateTime(time);
    return date != null ? DateFormat('dd').format(date) : "--";
  }

  String _getMonthYearFromTime(String? time) {
    final date = _parseDateTime(time);
    return date != null ? DateFormat('MMM yyyy').format(date) : "--- ----";
  }

  String _getDateFromTime(String? time) {
    final date = _parseDateTime(time);
    return date != null ? DateFormat('yyyyMMdd').format(date) : "";
  }

  DateTime? _parseDateTime(String? time) {
    try {
      if (time == null) return null;
      if (time.contains('-') && time.length >= 10) {
        return DateTime.parse(time);
      }
      if (time.contains(':')) {
        final parts = time.split(':');
        if (parts.length == 3) {
          final now = DateTime.now();
          return DateTime(now.year, now.month, now.day, int.parse(parts[0]),
              int.parse(parts[1]), int.parse(parts[2]));
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}

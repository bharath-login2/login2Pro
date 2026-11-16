import 'package:flutter/material.dart';
import 'package:login2/models/lead_management/runningTaskModel.dart';
import 'package:login2/screens/leadManagement/viewwork_page.dart';
import 'package:login2/service/service.dart';
// import 'your_service_file.dart'; // file that contains getRunningTasks

class RunningTasksPage extends StatefulWidget {
  /// true  -> only 5 tasks
  /// false -> full list
  final bool fromDashboard;

  const RunningTasksPage({super.key, this.fromDashboard = false});

  @override
  State<RunningTasksPage> createState() => _RunningTasksPageState();
}

class _RunningTasksPageState extends State<RunningTasksPage> {
  bool _isLoading = true;
  String? _error;
  List<RunningTask> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Replace ApiService with the class that holds getRunningTasks
    final res = await HttpService.getRunningTasks(
      fromDashboard: widget.fromDashboard,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (res == null) {
        _error = 'Something went wrong. Please try again.';
      } else if (!res.status) {
        _error = res.message;
      } else {
        _tasks = res.data;
      }
    });
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '-';
    String two(int n) => n.toString().padLeft(2, '0');
    final hour12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final period = d.hour >= 12 ? 'PM' : 'AM';
    return '${two(d.day)}-${two(d.month)}-${d.year}, ${two(hour12)}:${two(d.minute)} $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Running Tasks',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadTasks,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_tasks.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadTasks,
        child: ListView(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.3),
            Icon(Icons.timelapse_rounded,
                size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Center(
              child: Text('No running tasks',
                  style: TextStyle(color: Colors.grey.shade600)),
            ),
          ],
        ),
      );
    }

    final displayTasks =
        widget.fromDashboard ? _tasks.take(5).toList() : _tasks;

    return RefreshIndicator(
      onRefresh: _loadTasks,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: displayTasks.length,
        itemBuilder: (context, index) => _taskCard(displayTasks[index]),
      ),
    );
  }

  Widget _taskCard(RunningTask task) {
    return GestureDetector(
      onTap: () {
        final staffName = task.assignedToName;
        final staffId = task.assignedTo;
        final selectedDate = DateTime.now(); // current date

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ViewWorkPage(
              staffName: staffName,
              staffId: staffId,
              selectedDate: selectedDate,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue.shade50,
                    child: Icon(Icons.timelapse_rounded,
                        color: Colors.blue.shade400, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.assignedToName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${task.projectName} • ${task.taskName}",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    task.totalDuration ?? '--:--:--',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Divider(height: 1, color: Colors.grey.shade200),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _infoText(Icons.person_outline_rounded,
                        'By: ${task.assignedFromName}'),
                  ),
                  if (task.priorityName != null)
                    _chip(task.priorityName!, Colors.orange),
                ],
              ),
              const SizedBox(height: 6),
              _infoText(
                  Icons.event_rounded, 'Due: ${_formatDate(task.dueDate)}'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style:
            TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

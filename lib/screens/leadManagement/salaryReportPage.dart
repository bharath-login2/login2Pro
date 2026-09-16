import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login2/models/lead_management/salaryListModel.dart';
import 'package:login2/screens/leadManagement/salaryDetailPage.dart';
import 'package:login2/service/service.dart';

class SalaryReportPage extends StatefulWidget {
  const SalaryReportPage({super.key});
  @override
  State<SalaryReportPage> createState() => _SalaryReportPageState();
}

class _SalaryReportPageState extends State<SalaryReportPage> {
  DateTime selectedDate =
      DateTime(DateTime.now().year, DateTime.now().month - 1);
  final List<String> months = List.generate(
    12,
    (index) => DateFormat.MMMM().format(DateTime(0, index + 1)),
  );
  late List<int> years;
  String tempMonth = "";
  int tempYear = 0;
  String filterStatus = "Active";
  List<SalaryOnList> fullData = [];
  List<SalaryOnList> filteredData = [];
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    int currentYear = DateTime.now().year;
    years = List.generate(11, (index) => currentYear - 5 + index);
    fetchSalaryData();
  }

  String getMonthYearParam(DateTime date) {
    return DateFormat("yyyy-MM").format(date);
  }

  Future<void> fetchSalaryData() async {
    setState(() => isLoading = true);
    try {
      String monthYear = getMonthYearParam(selectedDate);
      final salaryList = await HttpService.getSalaryList(monthYear: monthYear);

      if (salaryList != null && salaryList.status == true) {
        fullData = salaryList.data;
        applyFilter();
      } else {
        fullData = [];
        filteredData = [];
      }
    } catch (e) {
      fullData = [];
      filteredData = [];
      debugPrint("❌ Error in fetchSalaryData: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void applyFilter() {
    setState(() {
      List<SalaryOnList> tempList = [];

      if (filterStatus == "All") {
        tempList = fullData;
      } else {
        tempList = fullData.where((e) => e.status == filterStatus).toList();
      }

      if (searchController.text.isNotEmpty) {
        tempList = tempList
            .where((e) => e.staffName
                .toLowerCase()
                .contains(searchController.text.toLowerCase()))
            .toList();
      }

      filteredData = tempList;
    });
  }

  Future<void> showMonthYearDialog() async {
    tempMonth = DateFormat.MMMM().format(selectedDate);
    tempYear = selectedDate.year;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Select Month & Year"),
              content: Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: tempMonth,
                      items: months.map((month) {
                        return DropdownMenuItem(
                          value: month,
                          child: Text(month),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            tempMonth = value;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: tempYear,
                      items: years.map((year) {
                        return DropdownMenuItem(
                          value: year,
                          child: Text(year.toString()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            tempYear = value;
                          });
                        }
                      },
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
                  onPressed: () {
                    setState(() {
                      selectedDate =
                          DateTime(tempYear, months.indexOf(tempMonth) + 1);
                    });
                    Navigator.pop(context);
                    fetchSalaryData();
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String displayMonthYear = DateFormat("MMMM yyyy").format(selectedDate);
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Salary Report", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton.icon(
            onPressed: showMonthYearDialog,
            icon: const Icon(Icons.calendar_month, color: Colors.white),
            label: Text(displayMonthYear,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              controller: searchController,
              onChanged: (value) => applyFilter(),
              decoration: InputDecoration(
                hintText: 'Search staff name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // Toggle Filter
          ToggleButtons(
            isSelected: ["Active", "Inactive", "All"]
                .map((e) => filterStatus == e)
                .toList(),
            onPressed: (index) {
              filterStatus = ["Active", "Inactive", "All"][index];
              applyFilter();
            },
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("Active"),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("Inactive"),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("All"),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredData.isEmpty
                      ? const Center(child: Text("No data found"))
                      : ListView.builder(
                          itemCount: filteredData.length,
                          itemBuilder: (context, index) {
                            final staff = filteredData[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => SalaryDetailPage(
                                          staffName: staff.staffName,
                                          Id: staff.id ?? '',
                                        ),
                                      ),
                                    );
                                  },
                                  leading: CircleAvatar(
                                    radius: 22,
                                    backgroundColor: Colors.blue.shade100,
                                    child: Text(
                                      staff.staffName.isNotEmpty
                                          ? staff.staffName[0].toUpperCase()
                                          : '',
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    staff.staffName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Worked Days: ${staff.workedDays}"),
                                      Text(
                                        "LOP Days: ${staff.lopDays}",
                                        style: TextStyle(
                                          color: (double.tryParse(staff.lopDays
                                                          .toString()) ??
                                                      0) >
                                                  0
                                              ? Colors.red
                                              : Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (staff.remarks != null &&
                                          staff.remarks.toString().trim().isNotEmpty &&
                                          staff.remarks.toString() != "null")
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Icon(Icons.comment_outlined,
                                                  size: 13,
                                                  color: Colors.grey.shade600),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text.rich(
                                                  TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: "Remarks: ",
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors
                                                              .grey.shade700,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: "${staff.remarks}",
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors
                                                              .grey.shade800,
                                                          fontStyle:
                                                              FontStyle.italic,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "₹${staff.monthlySalary}",
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(staff.status),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        )),
        ],
      ),
    );
  }
}

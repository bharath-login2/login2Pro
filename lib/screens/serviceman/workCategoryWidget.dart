import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:login2/models/serviceman/workCategoryGraphModel.dart';
import 'package:login2/screens/serviceman/dashboard_card.dart';
import 'package:login2/screens/serviceman/work_category_page.dart';
import 'package:login2/service/service.dart';
class WorkCategoryCard extends StatefulWidget {
  const WorkCategoryCard({super.key});

  @override
  State<WorkCategoryCard> createState() => _WorkCategoryCardState();
}

class _WorkCategoryCardState extends State<WorkCategoryCard> {
  late Future<WorkCategoryModelGraph?> _futureGraph;

  final List<Color> chartColors = [
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.red,
    Colors.purple,
    Colors.teal,
    Colors.brown,
  ];

  @override
  void initState() {
    super.initState();
    _futureGraph = HttpService().getCategoryGraph();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WorkCategoryModelGraph?>(
      future: _futureGraph,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData ||
            snapshot.data == null ||
            snapshot.data!.data.isEmpty) {
          return const Center(child: Text("No data available"));
        }

        final graphData = snapshot.data!;
        final totalWorkOrders = graphData.totalWorkorders;
        final categories = graphData.data.take(5).toList(); // ✅ Only first 5

        return DashboardCard(
          title: "Issue Type",
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WorkCategoryPage()),
          ),
          child: SizedBox(
            height: 220,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  flex: 2,
                  child: ListView.builder(
                    itemCount: categories.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final color = chartColors[index % chartColors.length];
                      final item = categories[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                title: const Text(
                                  "Issue Type Details",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Category: ${item.workCategory}",
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Percentage: ${item.percentage}",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Close"),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: LegendItem(
                            color: color,
                            text: "${item.workCategory} (${item.percentage})",
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 12),
                Flexible(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 45,
                            sections: categories.asMap().entries.map((entry) {
                              final index = entry.key;
                              final item = entry.value;
                              final color =
                                  chartColors[index % chartColors.length];
                              final percentageValue =
                                  double.tryParse(
                                    item.percentage.replaceAll("%", ""),
                                  ) ??
                                  0.0;

                              return PieChartSectionData(
                                value: percentageValue,
                                color: color,
                                title: item.percentage,
                                radius: 45,
                                titleStyle: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        Text(
                          "$totalWorkOrders\nTotal",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 90, 89, 89),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const LegendItem({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}


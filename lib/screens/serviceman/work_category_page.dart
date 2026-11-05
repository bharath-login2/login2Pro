import 'package:flutter/material.dart';
import 'package:login2/models/serviceman/workCategoryGraphModel.dart';
import 'package:login2/service/service.dart';

class WorkCategoryPage extends StatefulWidget {
  const WorkCategoryPage({super.key});

  @override
  State<WorkCategoryPage> createState() => _WorkCategoryPageState();
}

class _WorkCategoryPageState extends State<WorkCategoryPage> {
  late Future<WorkCategoryModelGraph?> _futureData;

  @override
  void initState() {
    super.initState();
    _futureData = HttpService().getCategoryGraph();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Work Categories"),
        backgroundColor: const Color.fromARGB(255, 56, 48, 156),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: FutureBuilder<WorkCategoryModelGraph?>(
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null || snapshot.data!.data.isEmpty) {
            return const Center(
              child: Text(
                "No Issue Type data available",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final data = snapshot.data!;
          final categories = data.data;

          return Padding(
            padding: const EdgeInsets.all(12),
            child: ListView.separated(
              itemCount: categories.length,
              separatorBuilder: (_, __) => const Divider(thickness: 0.6),
              itemBuilder: (context, index) {
                final item = categories[index];

                double percent = double.tryParse(
                      item.percentage.replaceAll("%", ""),
                    ) ??
                    0.0;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          item.workCategory,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Percentage Bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: percent / 100,
                                minHeight: 8,
                                backgroundColor: Colors.grey.shade300,
                                color: const Color(0xFF94CC51),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "${item.percentage} (${item.totalUsed} used)",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}


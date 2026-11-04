import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class WorkOrderCardPreview extends StatelessWidget {
  final String pdfPath;
  final String workOrderId;

  const WorkOrderCardPreview({
    super.key,
    required this.pdfPath,
    required this.workOrderId,
  });

  Future<String> _getNewFilePath() async {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd_HH-mm-ss').format(now);

    final directory = await getTemporaryDirectory();

    return '${directory.path}/WorkOrder_${workOrderId}_$formattedDate.pdf';
  }

  Future<void> _downloadPDF(BuildContext context) async {
    try {
      final newPath = await _getNewFilePath();
      await File(pdfPath).copy(newPath);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("PDF saved successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving PDF: $e")),
      );
    }
  }

  Future<void> _sharePDF(BuildContext context) async {
    try {
      final newPath = await _getNewFilePath();
      final newFile = await File(pdfPath).copy(newPath);

      await Share.shareXFiles(
        [XFile(newFile.path)],
        text: 'Here is your Work Order Card PDF.',
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sharing PDF: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Work Order Preview',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: "Download PDF",
            onPressed: () => _downloadPDF(context),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: "Share PDF",
            onPressed: () => _sharePDF(context),
          ),
        ],
      ),
      body: SafeArea(
        child: PDFView(
          filePath: pdfPath,
          enableSwipe: true,
          swipeHorizontal: false,
          autoSpacing: true,
          pageFling: true,
          onError: (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error opening PDF: $error")),
            );
          },
        ),
      ),
    );
  }
}

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';

class AttendanceLogScreen extends StatelessWidget {
  const AttendanceLogScreen({super.key});

  void _exportCSV(BuildContext context, List<AttendanceLog> logs) {
    final rows = [
      ['Name', 'Student ID', 'Status', 'Timestamp', 'Course', 'Verification'],
      ...logs.map((e) => [e.name, e.studentId, e.action, e.timestamp, e.courseCode, e.verificationMethod]),
    ];
    final csv = const ListToCsvConverter().convert(rows);
    final bytes = Uint8List.fromList(csv.codeUnits);
    Printing.sharePdf(bytes: bytes, filename: 'attendance.csv');
  }

  void _exportPDF(BuildContext context, List<AttendanceLog> logs) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Table.fromTextArray(
          headers: ['Name', 'Student ID', 'Status', 'Timestamp', 'Course', 'Verification'],
          data: logs.map((e) => [e.name, e.studentId, e.action, e.timestamp, e.courseCode, e.verificationMethod]).toList(),
        ),
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    final logBox = Hive.box<AttendanceLog>('attendanceLogs');
    final logs = logBox.values.toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export CSV',
            onPressed: () => _exportCSV(context, logs),
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export PDF',
            onPressed: () => _exportPDF(context, logs),
          ),
        ],
      ),
      body: logs.isEmpty
          ? const Center(child: Text('No attendance records yet.'))
          : ListView.separated(
              itemCount: logs.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final log = logs[index];
                return ListTile(
                  leading: Icon(
                    log.action == 'Present' ? Icons.check_circle : Icons.cancel,
                    color: log.action == 'Present' ? Colors.green : Colors.red,
                  ),
                  title: Text('${log.name} (${log.studentId})'),
                  subtitle: Text('${log.action} @ ${log.timestamp}'),
                );
              },
            ),
    );
  }
}

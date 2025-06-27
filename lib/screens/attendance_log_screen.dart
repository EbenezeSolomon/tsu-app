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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/Logo.png', height: 60),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Attendance History',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                      Row(
                        children: [
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
                    ],
                  ),
                  const SizedBox(height: 16),
                  logs.isEmpty
                      ? const Center(child: Text('No attendance records yet.'))
                      : SizedBox(
                          height: 350,
                          child: ListView.separated(
                            itemCount: logs.length,
                            separatorBuilder: (_, __) => const Divider(),
                            itemBuilder: (context, index) {
                              final l = logs[index];
                              return ListTile(
                                title: Text('${l.name} (${l.studentId})'),
                                subtitle: Text('${l.courseCode} - ${l.timestamp}'),
                                trailing: Text(l.action, style: TextStyle(color: l.action == 'Present' ? Colors.green : Colors.red)),
                              );
                            },
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

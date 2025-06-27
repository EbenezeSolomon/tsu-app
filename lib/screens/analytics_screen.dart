import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final logBox = Hive.box<AttendanceLog>('attendanceLogs');
    final courseBox = Hive.box<Course>('courses');
    final studentBox = Hive.box<Student>('students');
    final logs = logBox.values.toList();
    final courses = courseBox.values.toList();
    final students = studentBox.values.toList();

    // Attendance count per course
    final Map<String, int> courseAttendance = {};
    for (var log in logs) {
      if (log.action == 'Present') {
        courseAttendance[log.courseCode] = (courseAttendance[log.courseCode] ?? 0) + 1;
      }
    }

    // Attendance count per student
    final Map<String, int> studentAttendance = {};
    for (var log in logs) {
      if (log.action == 'Present') {
        studentAttendance[log.studentId] = (studentAttendance[log.studentId] ?? 0) + 1;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Analytics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Attendance by Course', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ...courses.map((c) => ListTile(
                title: Text('${c.courseName} (${c.courseCode})'),
                trailing: Text('${courseAttendance[c.courseCode] ?? 0}'),
              )),
          const Divider(),
          const Text('Attendance by Student', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ...students.map((s) => ListTile(
                title: Text('${s.name} (${s.studentId})'),
                trailing: Text('${studentAttendance[s.studentId] ?? 0}'),
              )),
        ],
      ),
    );
  }
}

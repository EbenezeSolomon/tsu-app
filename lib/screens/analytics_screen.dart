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
                  const Text(
                    'Attendance Analytics',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                  const SizedBox(height: 16),
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
            ),
          ),
        ),
      ),
    );
  }
}

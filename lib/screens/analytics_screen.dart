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

    // Find top course and student
    String? topCourseCode;
    int topCourseCount = 0;
    courseAttendance.forEach((code, count) {
      if (count > topCourseCount) {
        topCourseCount = count;
        topCourseCode = code;
      }
    });
    String? topStudentId;
    int topStudentCount = 0;
    studentAttendance.forEach((id, count) {
      if (count > topStudentCount) {
        topStudentCount = count;
        topStudentId = id;
      }
    });
    final totalAttendance = logs.where((l) => l.action == 'Present').length;

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
          child: SingleChildScrollView(
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Image.asset('assets/Logo.png', height: 60)),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        'Attendance Analytics',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _statCard('Total Attendance', totalAttendance.toString(), Icons.bar_chart, Colors.blue),
                        _statCard('Courses', courses.length.toString(), Icons.menu_book, Colors.orange),
                        _statCard('Students', students.length.toString(), Icons.people, Colors.green),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (topCourseCode != null)
                      _highlightCard(
                        'Top Course',
                        courses.firstWhere((c) => c.courseCode == topCourseCode, orElse: () => courses.first).courseName,
                        topCourseCount,
                        Icons.star,
                        Colors.amber,
                      ),
                    if (topStudentId != null)
                      _highlightCard(
                        'Top Student',
                        students.firstWhere((s) => s.studentId == topStudentId, orElse: () => students.first).name,
                        topStudentCount,
                        Icons.emoji_events,
                        Colors.purple,
                      ),
                    const SizedBox(height: 24),
                    const Text('Attendance by Course', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ...courses.map((c) {
                      final count = courseAttendance[c.courseCode] ?? 0;
                      final percent = courses.isNotEmpty && totalAttendance > 0 ? (count / totalAttendance) : 0.0;
                      return Card(
                        color: Colors.blue[50],
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: Icon(Icons.menu_book, color: Colors.blue[700]),
                          title: Text('${c.courseName} (${c.courseCode})'),
                          subtitle: LinearProgressIndicator(
                            value: percent,
                            backgroundColor: Colors.blue[100],
                            color: Colors.blue[400],
                            minHeight: 8,
                          ),
                          trailing: Text('$count', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      );
                    }),
                    const Divider(),
                    const Text('Attendance by Student', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ...students.map((s) {
                      final count = studentAttendance[s.studentId] ?? 0;
                      final percent = students.isNotEmpty && totalAttendance > 0 ? (count / totalAttendance) : 0.0;
                      return Card(
                        color: Colors.green[50],
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: Icon(Icons.person, color: Colors.green[700]),
                          title: Text('${s.name} (${s.studentId})'),
                          subtitle: LinearProgressIndicator(
                            value: percent,
                            backgroundColor: Colors.green[100],
                            color: Colors.green[400],
                            minHeight: 8,
                          ),
                          trailing: Text('$count', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _highlightCard(String label, String name, int count, IconData icon, Color color) {
    return Card(
      color: color.withOpacity(0.15),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text('$label: $name', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        trailing: Text('$count', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
      ),
    );
  }
}

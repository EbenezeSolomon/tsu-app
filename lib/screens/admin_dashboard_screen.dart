import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';
import 'attendance_log_screen.dart';
import 'analytics_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lecturerBox = Hive.box<Lecturer>('lecturers');
    final courseBox = Hive.box<Course>('courses');
    final lecturers = lecturerBox.values.toList();
    final courses = courseBox.values.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: ListTile(
                leading: const Icon(Icons.analytics, color: Colors.deepPurple),
                title: const Text('View Analytics'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsScreen()));
                },
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: ListTile(
                leading: const Icon(Icons.list_alt, color: Colors.blue),
                title: const Text('View All Attendance Logs'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceLogScreen()));
                },
              ),
            ),
            const SizedBox(height: 24),
            const Text('Lecturers & Courses', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
            const SizedBox(height: 12),
            ...lecturers.map((lecturer) {
              final lecturerCourses = courses.where((c) => c.lecturer == lecturer.username).toList();
              return Card(
                color: Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ExpansionTile(
                  leading: const Icon(Icons.person, color: Colors.deepPurple),
                  title: Text(lecturer.name),
                  subtitle: Text('Username: ${lecturer.username}\nDept: ${lecturer.department}'),
                  children: lecturerCourses.isEmpty
                      ? [const ListTile(title: Text('No courses assigned.'))]
                      : lecturerCourses.map((course) => ListTile(
                          leading: const Icon(Icons.menu_book, color: Colors.blue),
                          title: Text('${course.courseName} (${course.courseCode})'),
                          subtitle: Text('Level: ${course.level}, Unit: ${course.unit}'),
                        )).toList(),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

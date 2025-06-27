import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';
import 'student_management_screen.dart';
import 'enroll_student_screen.dart';
import 'biometric_attendance_screen.dart';
import 'attendance_log_screen.dart';
import 'course_management_screen.dart';
import 'analytics_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lecturer Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EnrollStudentScreen()),
                );
              },
              child: const Text('Enroll Student'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CourseManagementScreen()),
                );
              },
              child: const Text('Manage Courses'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AttendanceLogScreen()),
                );
              },
              child: const Text('View Attendance Logs'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                // Select course first
                final courseBox = Hive.box<Course>('courses');
                final courses = courseBox.values.toList();
                Course? selectedCourse = await showDialog<Course>(
                  context: context,
                  builder: (context) => SimpleDialog(
                    title: const Text('Select Course'),
                    children: courses.isEmpty
                        ? [const Padding(padding: EdgeInsets.all(16), child: Text('No courses available.'))]
                        : courses.map((c) => SimpleDialogOption(
                              onPressed: () => Navigator.pop(context, c),
                              child: Text('${c.courseName} (${c.courseCode})'),
                            )).toList(),
                  ),
                );
                if (selectedCourse == null) return;
                // Then select student
                final selectedStudent = await Navigator.push<Student>(
                  context,
                  MaterialPageRoute(builder: (context) => const StudentManagementScreen()),
                );
                if (selectedStudent != null) {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BiometricAttendanceScreen(
                        student: selectedStudent,
                        course: selectedCourse,
                      ),
                    ),
                  );
                }
              },
              child: const Text('Mark Attendance for Student'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
                );
              },
              child: const Text('View Analytics'),
            ),
          ],
        ),
      ),
    );
  }
}

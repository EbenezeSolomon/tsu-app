import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';
import 'student_management_screen.dart';
import 'enroll_student_screen.dart';
import 'biometric_attendance_screen.dart';
import 'attendance_log_screen.dart';
import 'course_management_screen.dart';
import 'analytics_screen.dart';
import 'exam_attendance_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String lecturerUsername;
  const DashboardScreen({super.key, required this.lecturerUsername});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/Logo.png', height: 80),
                  const SizedBox(height: 16),
                  const Text(
                    'Taraba State University',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Lecturer Dashboard',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  _buildDashboardButton(
                    context,
                    icon: Icons.person_add_alt_1,
                    label: 'Enroll Student',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EnrollStudentScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildDashboardButton(
                    context,
                    icon: Icons.menu_book,
                    label: 'Manage Courses',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CourseManagementScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildDashboardButton(
                    context,
                    icon: Icons.list_alt,
                    label: 'View Attendance Logs',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AttendanceLogScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildDashboardButton(
                    context,
                    icon: Icons.fingerprint,
                    label: 'Biometric Attendance',
                    onTap: () async {
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
                  ),
                  const SizedBox(height: 16),
                  _buildDashboardButton(
                    context,
                    icon: Icons.analytics,
                    label: 'Analytics',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildDashboardButton(
                    context,
                    icon: Icons.verified_user,
                    label: 'Exam Biometric Attendance',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExamAttendanceScreen(lecturerUsername: widget.lecturerUsername),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 24),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(label, style: const TextStyle(fontSize: 16)),
        ),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: const Color(0xFF2C5364),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        onPressed: onTap,
      ),
    );
  }
}

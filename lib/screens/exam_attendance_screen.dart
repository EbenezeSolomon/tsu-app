import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_auth/local_auth.dart';
import '../models/models.dart';

class ExamAttendanceScreen extends StatefulWidget {
  final String lecturerUsername;
  const ExamAttendanceScreen({super.key, required this.lecturerUsername});

  @override
  State<ExamAttendanceScreen> createState() => _ExamAttendanceScreenState();
}

class _ExamAttendanceScreenState extends State<ExamAttendanceScreen> {
  String? _selectedCourseCode;
  final LocalAuthentication auth = LocalAuthentication();

  @override
  Widget build(BuildContext context) {
    final courseBox = Hive.box<Course>('courses');
    final studentBox = Hive.box<Student>('students');
    final logBox = Hive.box<AttendanceLog>('attendanceLogs');
    // Only show courses added by this lecturer
    final courses = courseBox.values.where((c) => c.lecturer == widget.lecturerUsername).toList();
    final students = _selectedCourseCode == null
        ? []
        : studentBox.values.where((s) => courses.firstWhere((c) => c.courseCode == _selectedCourseCode).enrolledStudents.contains(s.studentId)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Exam Biometric Attendance')),
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
                  const Text('Select Course', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  DropdownButton<String>(
                    value: _selectedCourseCode,
                    hint: const Text('Choose a course'),
                    items: courses.map((c) => DropdownMenuItem(
                      value: c.courseCode,
                      child: Text('${c.courseName} (${c.courseCode})'),
                    )).toList(),
                    onChanged: (val) => setState(() => _selectedCourseCode = val),
                  ),
                  const SizedBox(height: 24),
                  if (_selectedCourseCode != null && students.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final s = students[index];
                          final signInLog = logBox.values.where((l) => l.studentId == s.studentId && l.courseCode == _selectedCourseCode && l.action == 'ExamSignIn').toList();
                          final signOutLog = logBox.values.where((l) => l.studentId == s.studentId && l.courseCode == _selectedCourseCode && l.action == 'ExamSignOut').toList();
                          return Card(
                            color: Colors.blue[50],
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: Icon(Icons.person, color: Colors.blue[700]),
                              title: Text('${s.name} (${s.studentId})'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Sign In: ${signInLog.isNotEmpty ? signInLog.first.timestamp : 'Not signed in'}'),
                                  Text('Sign Out: ${signOutLog.isNotEmpty ? signOutLog.first.timestamp : 'Not signed out'}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.login, color: Colors.green),
                                    tooltip: 'Sign In',
                                    onPressed: signInLog.isNotEmpty ? null : () => _handleBiometric(s, 'ExamSignIn'),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.logout, color: Colors.red),
                                    tooltip: 'Sign Out',
                                    onPressed: signOutLog.isNotEmpty ? null : () => _handleBiometric(s, 'ExamSignOut'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  if (_selectedCourseCode != null && students.isEmpty)
                    const Text('No students enrolled for this course.'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleBiometric(Student student, String action) async {
    try {
      bool authenticated = await auth.authenticate(
        localizedReason: 'Scan your fingerprint to ${action == 'ExamSignIn' ? 'sign in' : 'sign out'}',
      );
      if (authenticated) {
        final logBox = Hive.box<AttendanceLog>('attendanceLogs');
        await logBox.add(AttendanceLog(
          name: student.name,
          studentId: student.studentId,
          action: action,
          timestamp: DateTime.now().toString(),
          courseCode: _selectedCourseCode!,
          verificationMethod: 'biometric',
        ));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${student.name} ${action == 'ExamSignIn' ? 'signed in' : 'signed out'} successfully!')),
        );
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biometric verification failed.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';

class BiometricAttendanceScreen extends StatefulWidget {
  final Course course;
  const BiometricAttendanceScreen({super.key, required this.course});

  @override
  State<BiometricAttendanceScreen> createState() => _BiometricAttendanceScreenState();
}

class _BiometricAttendanceScreenState extends State<BiometricAttendanceScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  late List<Student> students;
  late Box<AttendanceLog> logBox;

  @override
  void initState() {
    super.initState();
    final studentBox = Hive.box<Student>('students');
    students = studentBox.values
        .where((s) => widget.course.enrolledStudents.contains(s.studentId))
        .toList();
    logBox = Hive.box<AttendanceLog>('attendanceLogs');
  }

  Future<void> _handleBiometric(Student student, String action) async {
    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Scan your fingerprint to ${action == 'SignIn' ? 'sign in' : 'sign out'}',
        options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );
    } catch (e) {
      authenticated = false;
    }
    if (authenticated) {
      logBox.add(AttendanceLog(
        studentId: student.studentId,
        name: student.name,
        action: action,
        timestamp: DateTime.now().toString(),
        courseCode: widget.course.courseCode,
        verificationMethod: 'biometric',
      ));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biometric Attendance'),
        backgroundColor: const Color(0xFF2C5364),
        centerTitle: true,
      ),
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
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/Logo.png', height: 60),
                  const SizedBox(height: 12),
                  Text(
                    widget.course.courseName + ' (${widget.course.courseCode})',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enrolled Students',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 16),
                  students.isEmpty
                      ? const Text('No students enrolled for this course.', style: TextStyle(color: Colors.red))
                      : Expanded(
                          child: ListView.builder(
                            itemCount: students.length,
                            itemBuilder: (context, index) {
                              final s = students[index];
                              final signInLog = logBox.values.where((l) => l.studentId == s.studentId && l.courseCode == widget.course.courseCode && l.action == 'SignIn').toList();
                              final signOutLog = logBox.values.where((l) => l.studentId == s.studentId && l.courseCode == widget.course.courseCode && l.action == 'SignOut').toList();
                              return Card(
                                color: Colors.blue[50],
                                margin: const EdgeInsets.symmetric(vertical: 8),
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
                                        onPressed: signInLog.isNotEmpty ? null : () => _handleBiometric(s, 'SignIn'),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.logout, color: Colors.red),
                                        tooltip: 'Sign Out',
                                        onPressed: signOutLog.isNotEmpty ? null : () => _handleBiometric(s, 'SignOut'),
                                      ),
                                    ],
                                  ),
                                ),
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

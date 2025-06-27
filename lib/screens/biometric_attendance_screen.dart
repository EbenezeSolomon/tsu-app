import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:local_auth/local_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';
import 'attendance_log_screen.dart';
import 'student_management_screen.dart';

class BiometricAttendanceScreen extends StatefulWidget {
  final Student? student;
  final Course? course;
  const BiometricAttendanceScreen({super.key, this.student, this.course});

  @override
  State<BiometricAttendanceScreen> createState() => _BiometricAttendanceScreenState();
}

class _BiometricAttendanceScreenState extends State<BiometricAttendanceScreen> with SingleTickerProviderStateMixin {
  bool _scanning = false;
  bool _showResult = false;
  String _studentName = '';
  String _studentId = '';
  String _status = '';
  String _timestamp = '';
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _scaleAnim = Tween<double>(begin: 1, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut)
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startScan() async {
    setState(() {
      _scanning = true;
      _showResult = false;
    });
    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Scan your fingerprint to mark attendance',
        options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );
    } catch (e) {
      authenticated = false;
    }
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _scanning = false;
      _showResult = true;
      if (authenticated) {
        _studentName = widget.student?.name ?? 'Jane Doe';
        _studentId = widget.student?.studentId ?? 'TSU12345';
        _status = 'Present';
        _timestamp = DateTime.now().toString();
      } else {
        _studentName = widget.student?.name ?? '';
        _studentId = widget.student?.studentId ?? '';
        _status = 'Absent';
        _timestamp = DateTime.now().toString();
      }
    });
    // Save attendance log to Hive with course
    final logBox = Hive.box<AttendanceLog>('attendanceLogs');
    logBox.add(AttendanceLog(
      studentId: _studentId,
      name: _studentName,
      action: _status,
      timestamp: _timestamp,
      courseCode: widget.course?.courseCode ?? '',
      verificationMethod: 'biometric',
    ));
    if (context.mounted) {
      // Optionally pop or show a message
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient = LinearGradient(
      colors: isDark
          ? [const Color(0xFF232526), const Color(0xFF414345)]
          : [const Color(0xFFa8edea), const Color(0xFFfed6e3)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('Exam Attendance', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 8,
        shadowColor: Colors.black26,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.file_download),
        label: const Text('Export'),
        elevation: 8,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: gradient),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _scaleAnim,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scanning ? _scaleAnim.value : 1,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.black54 : Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: SvgPicture.asset(
                            'assets/fingerprint.svg',
                            width: 96,
                            height: 96,
                            color: isDark ? Colors.white : Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _scanning
                              ? 'Place your finger on the sensor...'
                              : 'Tap below to verify with fingerprint',
                          style: GoogleFonts.poppins(fontSize: 16),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _scanning ? null : _startScan,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  elevation: 8,
                  backgroundColor: isDark ? Colors.deepPurple : Colors.deepPurpleAccent,
                  shadowColor: Colors.black26,
                  textStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                child: _scanning
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Start Biometric Scan'),
              ),
              const SizedBox(height: 32),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: _showResult
                    ? AttendanceResultCard(
                        name: _studentName,
                        studentId: _studentId,
                        status: _status,
                        timestamp: _timestamp,
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AttendanceResultCard extends StatelessWidget {
  final String name;
  final String studentId;
  final String status;
  final String timestamp;

  const AttendanceResultCard({
    super.key,
    required this.name,
    required this.studentId,
    required this.status,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = status == 'Present' ? Colors.green : Colors.red;
    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: const EdgeInsets.symmetric(horizontal: 32),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  status,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Name: $name', style: GoogleFonts.poppins(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Student ID: $studentId', style: GoogleFonts.poppins(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Timestamp: $timestamp', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';

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
                  Image.asset('assets/Logo.png', height: 60),
                  const SizedBox(height: 16),
                  const Text(
                    'Biometric Attendance',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                  const SizedBox(height: 24),
                  ScaleTransition(
                    scale: _scaleAnim,
                    child: Icon(Icons.fingerprint, size: 64, color: Colors.blueGrey[700]),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.fingerprint),
                      label: Text(_scanning ? 'Scanning...' : 'Start Scan'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        backgroundColor: const Color(0xFF2C5364),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                      ),
                      onPressed: _scanning ? null : _startScan,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_showResult)
                    Column(
                      children: [
                        Text(_status, style: TextStyle(fontWeight: FontWeight.bold, color: _status == 'Present' ? Colors.green : Colors.red, fontSize: 18)),
                        const SizedBox(height: 8),
                        Text('Student: $_studentName ($_studentId)'),
                        Text('Time: $_timestamp'),
                      ],
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

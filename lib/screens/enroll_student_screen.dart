import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_auth/local_auth.dart';

import '../models/models.dart';

class EnrollStudentScreen extends StatefulWidget {
  const EnrollStudentScreen({super.key});

  @override
  State<EnrollStudentScreen> createState() => _EnrollStudentScreenState();
}

class _EnrollStudentScreenState extends State<EnrollStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _studentIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _departmentController = TextEditingController();
  final _unitController = TextEditingController();
  final _levelController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final LocalAuthentication auth = LocalAuthentication();
  bool _fingerprintVerified = false;

  Future<void> _verifyFingerprint() async {
    try {
      bool authenticated = await auth.authenticate(
        localizedReason: 'Scan your fingerprint to enroll student',
      );
      setState(() {
        _fingerprintVerified = authenticated;
      });
      if (!authenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fingerprint verification failed.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: \\${e.toString()}')),
      );
    }
  }

  void _enrollStudent() async {
    if (!_fingerprintVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please verify fingerprint before enrolling.')),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      final student = Student(
        studentId: _studentIdController.text,
        name: _nameController.text,
        department: _departmentController.text,
        unit: _unitController.text,
        level: _levelController.text,
        phone: _phoneController.text,
        email: _emailController.text,
      );
      final studentBox = Hive.box<Student>('students');
      await studentBox.put(student.studentId, student);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Student Enrolled'),
          content: Text('Student ${_nameController.text} enrolled successfully!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      // Clear form
      _formKey.currentState!.reset();
      _studentIdController.clear();
      _nameController.clear();
      _departmentController.clear();
      _unitController.clear();
      _levelController.clear();
      _phoneController.clear();
      _emailController.clear();
    }
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, {String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }

  String? _validateStudentId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter student ID';
    }
    // Accepts TSU/FSC/DEP/YY/NNNN where DEP is 2-3 uppercase letters, YY is 2 digits, NNNN is 4+ digits
    final regex = RegExp(r'^TSU\/FSC\/[A-Z]{2,3}\/\d{2}\/\d{4,} ?$');
    if (!regex.hasMatch(value)) {
      return 'Format: TSU/FSC/DEP/YY/NNNN (DEP=2-3 letters, NNNN=4+ digits)';
    }
    return null;
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
          child: SingleChildScrollView(
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
                      'Enroll Student',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                    ),
                    const SizedBox(height: 16),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildTextField(_studentIdController, 'Student ID', 'Enter Student ID', validator: _validateStudentId),
                          const SizedBox(height: 12),
                          _buildTextField(_nameController, 'Name', 'Enter Name'),
                          const SizedBox(height: 12),
                          _buildTextField(_departmentController, 'Department', 'Enter Department'),
                          const SizedBox(height: 12),
                          _buildTextField(_unitController, 'Unit', 'Enter Unit'),
                          const SizedBox(height: 12),
                          _buildTextField(_levelController, 'Level', 'Enter Level'),
                          const SizedBox(height: 12),
                          _buildTextField(_phoneController, 'Phone', 'Enter Phone'),
                          const SizedBox(height: 12),
                          _buildTextField(_emailController, 'Email', 'Enter Email'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.fingerprint),
                      label: const Text('Verify Fingerprint'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        backgroundColor: _fingerprintVerified ? Colors.green : const Color(0xFF2C5364),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                      ),
                      onPressed: _verifyFingerprint,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _enrollStudent,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          backgroundColor: const Color(0xFF2C5364),
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: const Text('Enroll Student', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

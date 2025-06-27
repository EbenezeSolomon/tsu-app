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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enroll Student')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _studentIdController,
                decoration: const InputDecoration(labelText: 'Student ID'),
                validator: (value) => value!.isEmpty ? 'Enter student ID' : null,
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Enter name' : null,
              ),
              TextFormField(
                controller: _departmentController,
                decoration: const InputDecoration(labelText: 'Department'),
                validator: (value) => value!.isEmpty ? 'Enter department' : null,
              ),
              TextFormField(
                controller: _unitController,
                decoration: const InputDecoration(labelText: 'Unit'),
                validator: (value) => value!.isEmpty ? 'Enter unit' : null,
              ),
              TextFormField(
                controller: _levelController,
                decoration: const InputDecoration(labelText: 'Level'),
                validator: (value) => value!.isEmpty ? 'Enter level' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                validator: (value) => value!.isEmpty ? 'Enter phone' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Enter email' : null,
              ),
              const SizedBox(height: 24),
              Column(
                children: [
                  Icon(
                    Icons.fingerprint,
                    size: 64,
                    color: _fingerprintVerified ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _fingerprintVerified
                        ? 'Fingerprint verified!'
                        : 'Tap below to verify fingerprint',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _verifyFingerprint,
                    icon: const Icon(Icons.fingerprint),
                    label: const Text('Verify Fingerprint'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _enrollStudent,
                child: const Text('Enroll'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

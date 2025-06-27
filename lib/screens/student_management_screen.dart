import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/models.dart';

class StudentManagementScreen extends StatefulWidget {
  const StudentManagementScreen({super.key});

  @override
  State<StudentManagementScreen> createState() => _StudentManagementScreenState();
}

class _StudentManagementScreenState extends State<StudentManagementScreen> {
  late Box<Student> studentBox;

  @override
  void initState() {
    super.initState();
    studentBox = Hive.box<Student>('students');
  }

  void _addStudent() async {
    final student = await showDialog<Student>(
      context: context,
      builder: (context) => const _StudentDialog(),
    );
    if (student != null) {
      await studentBox.put(student.studentId, student);
      setState(() {});
    }
  }

  void _editStudent(String key) async {
    final student = studentBox.get(key);
    if (student == null) return;
    final updated = await showDialog<Student>(
      context: context,
      builder: (context) => _StudentDialog(student: student),
    );
    if (updated != null) {
      await studentBox.put(key, updated);
      setState(() {});
    }
  }

  void _deleteStudent(String key) async {
    await studentBox.delete(key);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final students = studentBox.values.toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Student Management')),
      body: students.isEmpty
          ? const Center(child: Text('No students yet.'))
          : ListView.separated(
              itemCount: students.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final s = students[index];
                return ListTile(
                  title: Text('${s.name} (${s.studentId})'),
                  subtitle: Text('${s.department} - ${s.level}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editStudent(s.studentId),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteStudent(s.studentId),
                      ),
                      IconButton(
                        icon: const Icon(Icons.fingerprint),
                        tooltip: 'Mark Attendance',
                        onPressed: () {
                          Navigator.pop(context, s);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addStudent,
        child: const Icon(Icons.add),
        tooltip: 'Add Student',
      ),
    );
  }
}

class _StudentDialog extends StatefulWidget {
  final Student? student;
  const _StudentDialog({this.student});

  @override
  State<_StudentDialog> createState() => _StudentDialogState();
}

class _StudentDialogState extends State<_StudentDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _idController;
  late TextEditingController _nameController;
  late TextEditingController _departmentController;
  late TextEditingController _unitController;
  late TextEditingController _levelController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController(text: widget.student?.studentId ?? '');
    _nameController = TextEditingController(text: widget.student?.name ?? '');
    _departmentController = TextEditingController(text: widget.student?.department ?? '');
    _unitController = TextEditingController(text: widget.student?.unit ?? '');
    _levelController = TextEditingController(text: widget.student?.level ?? '');
    _phoneController = TextEditingController(text: widget.student?.phone ?? '');
    _emailController = TextEditingController(text: widget.student?.email ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.student == null ? 'Add Student' : 'Edit Student'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _idController,
                decoration: const InputDecoration(labelText: 'Student ID'),
                validator: (v) => v!.isEmpty ? 'Enter ID' : null,
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v!.isEmpty ? 'Enter name' : null,
              ),
              TextFormField(
                controller: _departmentController,
                decoration: const InputDecoration(labelText: 'Department'),
                validator: (v) => v!.isEmpty ? 'Enter department' : null,
              ),
              TextFormField(
                controller: _unitController,
                decoration: const InputDecoration(labelText: 'Unit'),
                validator: (v) => v!.isEmpty ? 'Enter unit' : null,
              ),
              TextFormField(
                controller: _levelController,
                decoration: const InputDecoration(labelText: 'Level'),
                validator: (v) => v!.isEmpty ? 'Enter level' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                validator: (v) => v!.isEmpty ? 'Enter phone' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => v!.isEmpty ? 'Enter email' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(
                context,
                Student(
                  studentId: _idController.text,
                  name: _nameController.text,
                  department: _departmentController.text,
                  unit: _unitController.text,
                  level: _levelController.text,
                  phone: _phoneController.text,
                  email: _emailController.text,
                ),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

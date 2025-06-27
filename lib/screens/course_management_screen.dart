import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';

class CourseManagementScreen extends StatefulWidget {
  const CourseManagementScreen({super.key});

  @override
  State<CourseManagementScreen> createState() => _CourseManagementScreenState();
}

class _CourseManagementScreenState extends State<CourseManagementScreen> {
  late Box<Course> courseBox;
  late Box<Student> studentBox;

  @override
  void initState() {
    super.initState();
    courseBox = Hive.box<Course>('courses');
    studentBox = Hive.box<Student>('students');
  }

  void _addOrEditCourse({Course? course, String? key}) async {
    final result = await showDialog<Course>(
      context: context,
      builder: (context) => _CourseDialog(
        course: course,
        allStudents: studentBox.values.toList(),
      ),
    );
    if (result != null) {
      if (key != null) {
        await courseBox.put(key, result);
      } else {
        await courseBox.put(result.courseCode, result);
      }
      setState(() {});
    }
  }

  void _deleteCourse(String key) async {
    await courseBox.delete(key);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final courses = courseBox.values.toList();
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
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/Logo.png', height: 60),
                  const SizedBox(height: 16),
                  const Text(
                    'Course Management',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                  const SizedBox(height: 16),
                  courses.isEmpty
                      ? const Center(child: Text('No courses yet.'))
                      : SizedBox(
                          height: 350,
                          child: ListView.separated(
                            itemCount: courses.length,
                            separatorBuilder: (_, __) => const Divider(),
                            itemBuilder: (context, index) {
                              final c = courses[index];
                              return ListTile(
                                title: Text('${c.courseName} (${c.courseCode})'),
                                subtitle: Text('${c.department} - ${c.unit}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => _addOrEditCourse(course: c, key: c.courseCode),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteCourse(c.courseCode),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add Course'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        backgroundColor: const Color(0xFF2C5364),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                      ),
                      onPressed: () => _addOrEditCourse(),
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

class _CourseDialog extends StatefulWidget {
  final Course? course;
  final List<Student> allStudents;
  const _CourseDialog({this.course, required this.allStudents});

  @override
  State<_CourseDialog> createState() => _CourseDialogState();
}

class _CourseDialogState extends State<_CourseDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeController;
  late TextEditingController _nameController;
  late TextEditingController _departmentController;
  late TextEditingController _unitController;
  late TextEditingController _lecturerController;
  late TextEditingController _semesterController;
  late TextEditingController _levelController;
  late List<String> _selectedStudents;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.course?.courseCode ?? '');
    _nameController = TextEditingController(text: widget.course?.courseName ?? '');
    _departmentController = TextEditingController(text: widget.course?.department ?? '');
    _unitController = TextEditingController(text: widget.course?.unit ?? '');
    _lecturerController = TextEditingController(text: widget.course?.lecturer ?? '');
    _semesterController = TextEditingController(text: widget.course?.semester ?? '');
    _levelController = TextEditingController(text: widget.course?.level ?? '');
    _selectedStudents = List<String>.from(widget.course?.enrolledStudents ?? []);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.course == null ? 'Add Course' : 'Edit Course'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: 'Course Code'),
                validator: (v) => v!.isEmpty ? 'Enter code' : null,
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Course Name'),
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
                controller: _lecturerController,
                decoration: const InputDecoration(labelText: 'Lecturer'),
                validator: (v) => v!.isEmpty ? 'Enter lecturer' : null,
              ),
              TextFormField(
                controller: _semesterController,
                decoration: const InputDecoration(labelText: 'Semester'),
                validator: (v) => v!.isEmpty ? 'Enter semester' : null,
              ),
              TextFormField(
                controller: _levelController,
                decoration: const InputDecoration(labelText: 'Level'),
                validator: (v) => v!.isEmpty ? 'Enter level' : null,
              ),
              const SizedBox(height: 12),
              const Text('Enrolled Students:'),
              ...widget.allStudents.map((student) => CheckboxListTile(
                    value: _selectedStudents.contains(student.studentId),
                    title: Text('${student.name} (${student.studentId})'),
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          _selectedStudents.add(student.studentId);
                        } else {
                          _selectedStudents.remove(student.studentId);
                        }
                      });
                    },
                  )),
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
                Course(
                  courseCode: _codeController.text,
                  courseName: _nameController.text,
                  department: _departmentController.text,
                  unit: _unitController.text,
                  lecturer: _lecturerController.text,
                  semester: _semesterController.text,
                  level: _levelController.text,
                  enrolledStudents: _selectedStudents,
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

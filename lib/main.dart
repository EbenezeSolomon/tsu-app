import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/models.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(DepartmentAdapter());
  Hive.registerAdapter(LecturerAdapter());
  Hive.registerAdapter(StudentAdapter());
  Hive.registerAdapter(CourseAdapter());
  Hive.registerAdapter(AttendanceLogAdapter());
  await Hive.openBox<Department>('departments');
  await Hive.openBox<Lecturer>('lecturers');
  await Hive.openBox<Student>('students');
  await Hive.openBox<Course>('courses');
  await Hive.openBox<AttendanceLog>('attendanceLogs');
  runApp(const TSUApp());
}

class TSUApp extends StatelessWidget {
  const TSUApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TSU APP',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}

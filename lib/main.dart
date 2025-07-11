import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/models.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/change_password_screen.dart';
import 'screens/change_username_screen.dart';
import 'screens/admin_login_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/lecturer_signup_screen.dart';

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
        '/signup': (context) => const SignupScreen(),
        '/change-password': (context) => const ChangePasswordScreen(username: 'admin'),
        '/change-username': (context) => const ChangeUsernameScreen(currentUsername: 'admin'),
        '/admin-login': (context) => const AdminLoginScreen(),
        '/admin-dashboard': (context) => const AdminDashboardScreen(),
        '/lecturer-signup': (context) => const LecturerSignupScreen(),
      },
    );
  }
}

import 'package:hive/hive.dart';

part 'models.g.dart';

@HiveType(typeId: 0)
class Department extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final List<String> units;

  Department({required this.id, required this.name, required this.units});
}

@HiveType(typeId: 1)
class Lecturer extends HiveObject {
  @HiveField(0)
  final String username;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String department;
  @HiveField(3)
  final String passwordHash;

  Lecturer({required this.username, required this.name, required this.department, required this.passwordHash});
}

@HiveType(typeId: 2)
class Student extends HiveObject {
  @HiveField(0)
  final String studentId;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String department;
  @HiveField(3)
  final String unit;
  @HiveField(4)
  final String level;
  @HiveField(5)
  final String phone;
  @HiveField(6)
  final String email;
  @HiveField(7)
  bool signedIn;

  Student({
    required this.studentId,
    required this.name,
    required this.department,
    required this.unit,
    required this.level,
    required this.phone,
    required this.email,
    this.signedIn = false,
  });
}

@HiveType(typeId: 3)
class Course extends HiveObject {
  @HiveField(0)
  final String courseCode;
  @HiveField(1)
  final String courseName;
  @HiveField(2)
  final String department;
  @HiveField(3)
  final String unit;
  @HiveField(4)
  final String lecturer;
  @HiveField(5)
  final String semester;
  @HiveField(6)
  final String level;
  @HiveField(7)
  final List<String> enrolledStudents;

  Course({
    required this.courseCode,
    required this.courseName,
    required this.department,
    required this.unit,
    required this.lecturer,
    required this.semester,
    required this.level,
    required this.enrolledStudents,
  });
}

@HiveType(typeId: 4)
class AttendanceLog extends HiveObject {
  @HiveField(0)
  final String studentId;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String action;
  @HiveField(3)
  final String timestamp;
  @HiveField(4)
  final String courseCode;
  @HiveField(5)
  final String verificationMethod;

  AttendanceLog({
    required this.studentId,
    required this.name,
    required this.action,
    required this.timestamp,
    required this.courseCode,
    required this.verificationMethod,
  });
}

class AdminCredentials {
  static const String _boxName = 'adminBox';
  static const String _usernameKey = 'username';
  static const String _passwordKey = 'password';

  static Future<void> save(String username, String password) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_usernameKey, username);
    await box.put(_passwordKey, password);
  }

  static Future<String?> getUsername() async {
    final box = await Hive.openBox(_boxName);
    return box.get(_usernameKey) as String?;
  }

  static Future<String?> getPassword() async {
    final box = await Hive.openBox(_boxName);
    return box.get(_passwordKey) as String?;
  }

  static Future<void> setUsername(String username) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_usernameKey, username);
  }

  static Future<void> setPassword(String password) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_passwordKey, password);
  }
}

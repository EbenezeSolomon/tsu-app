import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _error;

  void _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    // Check admin credentials
    final adminUsername = await AdminCredentials.getUsername() ?? 'admin';
    final adminPassword = await AdminCredentials.getPassword() ?? 'admin123';
    if (username == adminUsername && password == adminPassword) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardScreen(lecturerUsername: username),
        ),
      );
      return;
    }
    // Check lecturer credentials
    final lecturerBox = await Hive.openBox<Lecturer>('lecturers');
    Lecturer? lecturer;
    try {
      lecturer = lecturerBox.values.firstWhere(
        (l) => l.username == username && l.passwordHash == password,
      );
    } catch (e) {
      lecturer = null;
    }
    if (lecturer != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardScreen(lecturerUsername: lecturer!.username),
        ),
      );
    } else {
      setState(() {
        _error = 'Invalid credentials';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4B79A1), Color(0xFF283E51)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/Logo.png', height: 80),
                  const SizedBox(height: 16),
                  const Text(
                    'Taraba State University Jalingo',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Faculty of Science',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Biological Sciences Department.',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    obscureText: true,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.login),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            backgroundColor: Color(0xFF4B79A1),
                          ),
                          onPressed: _login,
                          label: const Text('Lecturer Login', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.admin_panel_settings),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            backgroundColor: Color(0xFF2C5364),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/admin-login');
                          },
                          label: const Text('Admin Login', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.person_add),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            backgroundColor: Color(0xFF2C5364),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/lecturer-signup');
                          },
                          label: const Text('Lecturer Sign Up', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () async {
                          final result = await Navigator.pushNamed(context, '/signup');
                          if (result is Map) {
                            await AdminCredentials.save(result['username'], result['password']);
                            setState(() {});
                          }
                        },
                        child: const Text('Sign up as Admin'),
                      ),
                      TextButton(
                        onPressed: () async {
                          final username = await AdminCredentials.getUsername() ?? 'admin';
                          final result = await Navigator.pushNamed(context, '/change-password', arguments: username);
                          if (result is String) {
                            await AdminCredentials.setPassword(result);
                          }
                        },
                        child: const Text('Change Password'),
                      ),
                      TextButton(
                        onPressed: () async {
                          final username = await AdminCredentials.getUsername() ?? 'admin';
                          final result = await Navigator.pushNamed(context, '/change-username', arguments: username);
                          if (result is String) {
                            await AdminCredentials.setUsername(result);
                          }
                        },
                        child: const Text('Change Username'),
                      ),
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

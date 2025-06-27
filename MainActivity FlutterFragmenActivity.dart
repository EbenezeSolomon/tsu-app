import 'package:flutter/material.dart';

// ...inside your widget build method:
Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Icon(
      Icons.fingerprint,
      size: 64,
      color: Colors.grey,
    ),
    SizedBox(height: 16),
    Text(
      'Tap to verify with fingerprint',
      style: TextStyle(fontSize: 18),
    ),
    // ...your authentication button or logic here...
  ],
)

class MainActivity: FlutterFragmentActivity()
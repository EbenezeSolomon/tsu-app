import 'package:flutter/material.dart';

class FingerprintPrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Biometric Verification')),
      body: Center(
        child: Column(
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
            // Add your authentication button or logic here
          ],
        ),
      ),
    );
  }
}

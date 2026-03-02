import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'dart:async';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Periodically check if email is verified
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      Provider.of<AuthProvider>(context, listen: false).reloadUser();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.email_outlined, size: 100, color: Color(0xFF1E3A8A)),
            const SizedBox(height: 32),
            const Text(
              'Verify your email',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'A verification email has been sent to ${authProvider.user?.email}. Please check your inbox and verify your email to continue.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => authProvider.reloadUser(),
              child: const Text('I have verified my email'),
            ),
            TextButton(
              onPressed: () => authProvider.logout(),
              child: const Text('Cancel / Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

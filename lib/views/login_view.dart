// lib/views/login_view.dart
import 'package:flutter/material.dart';
import 'home_view.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    // Vai direto para a Home sem login
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeView()),
      );
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.pets, size: 80, color: Colors.deepOrange),
            const SizedBox(height: 16),
            const Text(
              'PetFinder',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            CircularProgressIndicator(color: Colors.deepOrange[600]),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'landing_screen.dart';

class WalkerDashboard extends StatelessWidget {
  const WalkerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dog Walker Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LandingScreen()),
                (route) => false,
              );
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.directions_walk, size: 100, color: Colors.black54),
            SizedBox(height: 16),
            Text(
              "Welcome, Dog Walker!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text("Find pet walking requests here."),
          ],
        ),
      ),
    );
  }
}

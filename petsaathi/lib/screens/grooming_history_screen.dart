import 'package:flutter/material.dart';
import 'coming_soon_screen.dart';

class GroomingHistoryScreen extends StatelessWidget {
  const GroomingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ComingSoonScreen(
      title: 'Grooming & Care',
      description:
          'Schedule grooming appointments and track your pet\'s care history. Stay on top of your pet\'s wellness needs.',
      icon: Icons.spa_rounded,
    );
  }
}

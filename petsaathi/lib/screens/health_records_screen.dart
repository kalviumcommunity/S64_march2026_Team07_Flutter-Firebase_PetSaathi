import 'package:flutter/material.dart';
import 'coming_soon_screen.dart';

class HealthRecordsScreen extends StatelessWidget {
  const HealthRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ComingSoonScreen(
      title: 'Health Records',
      description:
          'Keep your pet\'s health information in one secure place. Track vaccinations, medical visits, and medications.',
      icon: Icons.health_and_safety_rounded,
    );
  }
}

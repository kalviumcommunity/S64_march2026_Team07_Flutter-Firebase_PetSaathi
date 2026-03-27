import 'package:flutter/material.dart';
import 'coming_soon_screen.dart';

class PetSettingsScreen extends StatelessWidget {
  const PetSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ComingSoonScreen(
      title: 'Pet Preferences',
      description:
          'Customize settings for each pet. Set preferences, dietary needs, emergency contacts, and special requirements.',
      icon: Icons.tune_rounded,
    );
  }
}

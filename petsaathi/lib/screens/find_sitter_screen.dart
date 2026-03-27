import 'package:flutter/material.dart';
import 'coming_soon_screen.dart';

class FindSitterScreen extends StatelessWidget {
  const FindSitterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ComingSoonScreen(
      title: 'Find Your Perfect Sitter',
      description:
          'Browse verified walkers and pet sitters in your area. Compare rates, reviews, and availability.',
      icon: Icons.person_add_rounded,
    );
  }
}

import 'package:flutter/material.dart';
import 'coming_soon_screen.dart';

class BookingsHistoryScreen extends StatelessWidget {
  const BookingsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ComingSoonScreen(
      title: 'Your Bookings',
      description:
          'View all your upcoming and completed walks. Track your pet\'s activity, sitter ratings, and payment history.',
      icon: Icons.calendar_month_rounded,
    );
  }
}

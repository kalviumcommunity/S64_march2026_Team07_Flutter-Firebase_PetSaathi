import 'package:flutter/material.dart';
import 'coming_soon_screen.dart';

class MessagesConversationScreen extends StatelessWidget {
  const MessagesConversationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ComingSoonScreen(
      title: 'Messages',
      description:
          'Chat directly with your pet sitters and walkers. Send updates, photos, and stay connected while you\'re away.',
      icon: Icons.mail_rounded,
    );
  }
}

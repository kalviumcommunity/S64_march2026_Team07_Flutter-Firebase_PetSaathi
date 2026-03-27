import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/petsaathi_data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'bookings_history_screen.dart';
import 'create_pet_profile_screen.dart';
import 'messages_conversation_screen.dart';
import 'owner_pets_screen.dart';

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key});

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  final _auth = AuthService();
  final _data = PetSaathiDataService();
  int _currentTab = 0;

  void _showPendingMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openCreatePetProfile() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CreatePetProfileScreen()),
    );

    if (!mounted) return;
    if (created == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pet profile created successfully.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _buildTabContent(_currentTab),
            ),
            _OwnerBottomNav(
              currentTab: _currentTab,
              onTabTap: (index) {
                setState(() => _currentTab = index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return _buildHomeTabContent();
      case 1:
        return const OwnerPetsScreen();
      case 2:
        return const MessagesConversationScreen();
      case 3:
        return const BookingsHistoryScreen();
      default:
        return _buildHomeTabContent();
    }
  }

  Widget _buildHomeTabContent() {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return Center(
        child: Text(
          'Session expired. Please log in again.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StreamBuilder<UserProfile?>(
            stream: _auth.watchCurrentUserProfile(),
            builder: (context, snapshot) {
              final profile = snapshot.data;
              final firstName = (profile?.name.isNotEmpty ?? false)
                  ? profile!.name.split(' ').first
                  : 'Pet Parent';

              return Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const SurfaceIconButton(
                          icon: Icons.pets_rounded,
                          onTap: _noop,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Welcome, $firstName',
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.6,
                                ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showPendingMessage('Profile page implementation is next in this rollout.'),
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: const Color(0xFFD7EEE0),
                            child: profile?.avatarUrl != null && profile!.avatarUrl!.isNotEmpty
                                ? ClipOval(
                                    child: Image.network(
                                      profile.avatarUrl!,
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(Icons.person_rounded, size: 26, color: AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: GradientActionButton(
                            label: 'Find Sitter',
                            onPressed: () => _showPendingMessage('Walker discovery page is next in the implementation queue.'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GradientActionButton(
                            label: 'Book Visit',
                            onPressed: _openCreatePetProfile,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 18),
          const AppSectionTitle(title: 'Active Pets'),
          const SizedBox(height: 10),
          StreamBuilder<List<PetSummary>>(
            stream: _data.watchOwnerPets(uid),
            builder: (context, snapshot) {
              final pets = snapshot.data ?? const [];

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 230,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (pets.isEmpty) {
                return _EmptyStateCard(
                  title: 'No active pets yet',
                  subtitle: 'Add your first pet profile to start booking trusted walkers.',
                  actionLabel: 'Add pet profile',
                  onTap: _openCreatePetProfile,
                );
              }

              return SizedBox(
                height: 250,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: pets.length,
                  separatorBuilder: (_, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final pet = pets[index];
                    return _PetCard(pet: pet);
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 18),
          const AppSectionTitle(title: 'Recent Activity'),
          const SizedBox(height: 10),
          StreamBuilder<List<ActivityEvent>>(
            stream: _data.watchRecentOwnerActivity(uid),
            builder: (context, snapshot) {
              final activities = snapshot.data ?? const [];

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 120,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (activities.isEmpty) {
                return _EmptyStateCard(
                  title: 'No activity yet',
                  subtitle: 'Once you request or complete bookings, updates will appear here.',
                  actionLabel: 'Create first booking',
                  onTap: () => _showPendingMessage('Booking creation flow wiring is planned next.'),
                );
              }

              return Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Column(
                  children: activities.map((event) => _ActivityTile(event: event)).toList(growable: false),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

void _noop() {}

class _PetCard extends StatelessWidget {
  final PetSummary pet;

  const _PetCard({required this.pet});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 285,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: double.infinity,
                height: 145,
                child: pet.imageUrl.isEmpty
                    ? Container(
                        color: const Color(0xFFE6ECE8),
                        alignment: Alignment.center,
                        child: const Icon(Icons.pets_rounded, size: 44),
                      )
                    : Image.network(
                        pet.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFFE6ECE8),
                          alignment: Alignment.center,
                          child: const Icon(Icons.pets_rounded, size: 44),
                        ),
                      ),
            ),
              ),
            const SizedBox(height: 12),
            Text(
              pet.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              pet.statusText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final ActivityEvent event;

  const _ActivityTile({required this.event});

  IconData get icon {
    switch (event.iconType) {
      case 'done':
        return Icons.task_alt_rounded;
      case 'schedule':
        return Icons.calendar_month_rounded;
      case 'cancel':
        return Icons.cancel_rounded;
      default:
        return Icons.pets_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF4F0),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(icon, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  event.subtitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onTap;

  const _EmptyStateCard({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 220,
            child: GradientActionButton(
              label: actionLabel,
              onPressed: onTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _OwnerBottomNav extends StatelessWidget {
  final int currentTab;
  final ValueChanged<int> onTabTap;

  const _OwnerBottomNav({
    required this.currentTab,
    required this.onTabTap,
  });

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_rounded, 'Home'),
      (Icons.pets_rounded, 'Pets'),
      (Icons.mail_outline_rounded, 'Messages'),
      (Icons.calendar_month_rounded, 'Bookings'),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(items.length, (index) {
          final selected = index == currentTab;
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => onTabTap(index),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    curve: Curves.easeOut,
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.mintStart : Colors.transparent,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Icon(
                      items[index].$1,
                      color: selected ? Colors.black87 : const Color(0xFF9A9A9A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    items[index].$2,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: selected ? Colors.black87 : const Color(0xFF9A9A9A),
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

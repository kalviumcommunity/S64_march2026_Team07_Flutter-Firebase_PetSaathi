import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/pet_service.dart';
import '../services/activity_service.dart';
import '../models/pet_model.dart';
import '../models/activity_log_model.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'bookings_history_screen.dart';
import 'create_pet_profile_screen.dart';
import 'messages_conversation_screen.dart';
import 'owner_pets_screen.dart';
import 'walker_discovery_screen.dart';

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key});

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  final _petService = PetService();
  final _activityService = ActivityService();
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

  void _openWalkerDiscovery() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WalkerDiscoveryScreen()),
    );
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
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    if (user == null) {
      return Center(
        child: Text(
          'Session expired. Please log in again.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }

    final firstName = user.name.isNotEmpty ? user.name.split(' ').first : 'Pet Parent';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.xl),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.65)),
              boxShadow: AppShadows.card(context),
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
                        backgroundColor: AppColors.accentSoft,
                        child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  user.avatarUrl!,
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
                        label: 'Find Walker',
                        onPressed: _openWalkerDiscovery,
                        icon: Icons.search_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GradientActionButton(
                        label: 'Add Pet',
                        onPressed: _openCreatePetProfile,
                        icon: Icons.add_rounded,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const AppSectionTitle(title: 'Active Pets'),
          const SizedBox(height: 10),
          StreamBuilder<List<PetModel>>(
            stream: _petService.watchOwnerPets(user.uid),
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
          const SizedBox(height: 24),
          const AppSectionTitle(title: 'Recent Activity'),
          const SizedBox(height: 10),
          StreamBuilder<List<ActivityLog>>(
            stream: _activityService.watchUserActivity(user.uid),
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
                  actionLabel: 'Find a Walker',
                  onTap: _openWalkerDiscovery,
                );
              }

              return Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  border: Border.all(color: AppColors.border.withValues(alpha: 0.55)),
                  boxShadow: AppShadows.card(context),
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
  final PetModel pet;

  const _PetCard({required this.pet});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 285,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
          boxShadow: AppShadows.card(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: double.infinity,
                height: 145,
                child: pet.photoUrl.isEmpty
                    ? Container(
                        color: AppColors.accentSoft.withValues(alpha: 0.65),
                        alignment: Alignment.center,
                        child: const Icon(Icons.pets_rounded, size: 44, color: AppColors.mintDeep),
                      )
                    : Image.network(
                        pet.photoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.accentSoft.withValues(alpha: 0.65),
                          alignment: Alignment.center,
                          child: const Icon(Icons.pets_rounded, size: 44, color: AppColors.mintDeep),
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
  final ActivityLog event;

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
        return Icons.pending_actions_rounded;
    }
  }

  Color get iconColor {
    switch (event.iconType) {
      case 'done':
        return AppColors.success;
      case 'schedule':
        return AppColors.info;
      case 'cancel':
        return AppColors.error;
      default:
        return AppColors.warning;
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
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(icon, color: iconColor),
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
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.55)),
        boxShadow: AppShadows.card(context),
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
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A3328).withValues(alpha: 0.08),
            blurRadius: 28,
            offset: const Offset(0, -6),
          ),
        ],
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
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: selected
                          ? const LinearGradient(
                              colors: [AppColors.mintStart, AppColors.mintEnd],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: selected ? null : Colors.transparent,
                      borderRadius: BorderRadius.circular(99),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: AppColors.mintStart.withValues(alpha: 0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      items[index].$1,
                      color: selected ? Colors.white : AppColors.navInactive,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    items[index].$2,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: selected ? AppColors.mintDeep : AppColors.navInactive,
                          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                          letterSpacing: 0.2,
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

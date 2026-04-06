import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/pet_service.dart';
import '../services/activity_service.dart';
import '../services/request_service.dart';
import '../models/pet_model.dart';
import '../models/activity_log_model.dart';
import '../models/walk_request_model.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/paw_widgets.dart';
import 'booking_detail_screen.dart';
import 'bookings_history_screen.dart';
import 'create_pet_profile_screen.dart';
import 'messages_conversation_screen.dart';
import 'owner_pets_screen.dart';
import 'profile_screen.dart';
import 'walker_discovery_screen.dart';

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key});

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  final _petService = PetService();
  final _activityService = ActivityService();
  final _requestService = RequestService();
  int _currentTab = 0;

  Future<void> _openProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
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
                      onTap: _openProfile,
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
                        label: 'Request Walker',
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
          const AppSectionTitle(title: 'Current Booking'),
          const SizedBox(height: 10),
          StreamBuilder<WalkRequest?>(
            stream: _requestService.watchOwnerActiveRequest(user.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final active = snapshot.data;
              if (active == null) {
                return _EmptyStateCard(
                  title: 'No active booking',
                  subtitle: 'Create a broadcast request to get matched with an available walker.',
                  actionLabel: 'Request now',
                  onTap: _openWalkerDiscovery,
                );
              }

              return _ActiveBookingCard(request: active);
            },
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
                height: 280,
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
          const AppSectionTitle(title: 'Recent Bookings'),
          const SizedBox(height: 10),
          StreamBuilder<List<WalkRequest>>(
            stream: _requestService.watchOwnerRequests(user.uid),
            builder: (context, snapshot) {
              final allRequests = snapshot.data ?? [];
              final recentWalks = allRequests.where((r) => r.status == 'completed').take(3).toList();

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 120,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (recentWalks.isEmpty) {
                return _EmptyStateCard(
                  title: 'No recent walks',
                  subtitle: 'Completed walk bookings will appear here for your review.',
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
                  children: recentWalks.map((walk) => _RecentWalkTile(request: walk)).toList(growable: false),
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
                height: 155,
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
                maxLines: 1,
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

class _RecentWalkTile extends StatelessWidget {
  final WalkRequest request;

  const _RecentWalkTile({required this.request});

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
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(Icons.check_circle_rounded, color: AppColors.success),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Walk for ${request.petName}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  'Completed by ${request.walkerName ?? 'Walker'}',
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

class _ActiveBookingCard extends StatelessWidget {
  final WalkRequest request;

  const _ActiveBookingCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.mintStart.withValues(alpha: 0.45)),
        boxShadow: AppShadows.card(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Walk for ${request.petName}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              StatusBadge(status: request.status),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            request.walkerName == null
                ? 'Waiting for a walker to accept your request.'
                : 'Matched with ${request.walkerName}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BookingDetailScreen(requestId: request.id)),
              );
            },
            icon: const Icon(Icons.visibility_rounded),
            label: const Text('View detail'),
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

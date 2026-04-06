import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/request_service.dart';
import '../models/user_model.dart';
import '../models/walk_request_model.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/paw_widgets.dart';
import 'booking_detail_screen.dart';
import 'bookings_history_screen.dart';
import 'landing_screen.dart';
import 'messages_conversation_screen.dart';
import 'profile_screen.dart';

class WalkerDashboard extends StatefulWidget {
  const WalkerDashboard({super.key});

  @override
  State<WalkerDashboard> createState() => _WalkerDashboardState();
}

class _WalkerDashboardState extends State<WalkerDashboard> {
  int _selectedBottomNavIndex = 0;
  final _requestService = RequestService();

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LandingScreen()),
      (route) => false,
    );
  }

  void _showActionFeedback(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final textTheme = Theme.of(context).textTheme;
    const accent = AppColors.mintStart;
    const darkText = AppColors.textPrimary;
    const mutedText = AppColors.textMuted;
    const shell = AppColors.background;

    return Scaffold(
      backgroundColor: shell,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _buildTabContent(_selectedBottomNavIndex, user, auth, textTheme, accent, darkText, mutedText),
            ),
            _BottomNavigation(
              selectedIndex: _selectedBottomNavIndex,
              accent: accent,
              textTheme: textTheme,
              onTap: (index) {
                setState(() => _selectedBottomNavIndex = index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(int index, UserModel user, AuthProvider auth, TextTheme textTheme, Color accent, Color darkText, Color mutedText) {
    switch (index) {
      case 0:
        return _buildHomeTab(user, auth, textTheme, accent, darkText, mutedText);
      case 1:
        return const BookingsHistoryScreen();
      case 2:
        return const MessagesConversationScreen();
      case 3:
        return const ProfileScreen();
      default:
        return _buildHomeTab(user, auth, textTheme, accent, darkText, mutedText);
    }
  }

  Widget _buildHomeTab(UserModel user, AuthProvider auth, TextTheme textTheme, Color accent, Color darkText, Color mutedText) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DashboardHeader(
            accent: accent,
            textTheme: textTheme,
            user: user,
            onLogoutPressed: _logout,
            onProfileTap: _openProfile,
          ),
          const SizedBox(height: 22),
          Text(
            'Hi ${user.name.split(' ').first},\nManage your walks',
            style: textTheme.headlineMedium?.copyWith(
              color: darkText,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.7,
              height: 1.18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Accept requests faster and keep your daily schedule clean.',
            style: textTheme.bodyMedium?.copyWith(
              color: mutedText,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          _SearchAndFilterBar(
            accent: accent,
            textTheme: textTheme,
          ),
          const SizedBox(height: 16),
          _StatsRow(
            accent: accent,
            textTheme: textTheme,
            userId: user.uid,
          ),
          const SizedBox(height: 18),
          _AvailabilityCard(
            accent: accent,
            textTheme: textTheme,
            isAvailableNow: user.isAvailable,
            onChanged: (value) async {
              await auth.updateProfile(
                name: user.name,
                location: user.location,
                isAvailable: value,
              );
            },
          ),
          const SizedBox(height: 16),
          StreamBuilder<WalkRequest?>(
            stream: _requestService.watchWalkerActiveJob(user.uid),
            builder: (context, snapshot) {
              final activeJob = snapshot.data;
              if (activeJob == null) {
                return const SizedBox.shrink();
              }
              return _ActiveJobCard(request: activeJob);
            },
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Booking Requests',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: darkText,
                    ),
                  ),
                  const SizedBox(width: 8),
                  StreamBuilder<List<WalkRequest>>(
                    stream: _requestService.watchNearbyRequests(walkerId: user.uid),
                    builder: (context, snapshot) {
                      final count = (snapshot.data ?? const <WalkRequest>[]).length;
                      if (count == 0) {
                        return const SizedBox.shrink();
                      }
                      return Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          count > 99 ? '99+' : '$count',
                          style: textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              TextButton(
                onPressed: () => _showActionFeedback('Refreshing...'),
                style: TextButton.styleFrom(foregroundColor: AppColors.mintDeep),
                child: Text(
                  'View all',
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          StreamBuilder<List<WalkRequest>>(
            stream: _requestService.watchNearbyRequests(walkerId: user.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading requests',
                          style: TextStyle(color: accent, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Error: ${snapshot.error}',
                          style: TextStyle(color: mutedText, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }
              final requests = snapshot.data ?? [];
              if (requests.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Text('No new requests found.', style: TextStyle(color: mutedText)),
                  ),
                );
              }

              return Column(
                children: [
                  _IncomingRequestBanner(count: requests.length),
                  const SizedBox(height: 10),
                  ...requests.map((request) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _RequestCard(
                          request: request,
                          accent: accent,
                          textTheme: textTheme,
                          onViewBrief: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => BookingDetailScreen(requestId: request.id)),
                            );
                          },
                          onAccept: () async {
                            final accepted = await _requestService.updateRequestStatus(
                              request.id,
                              'accepted',
                              walkerId: user.uid,
                              walkerName: user.name,
                            );
                            if (!context.mounted) return;
                            if (accepted) {
                              _showActionFeedback('Accepted ${request.petName}\'s walk!');
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => BookingDetailScreen(requestId: request.id)),
                              );
                            } else {
                              _showActionFeedback('This request was already taken or expired.');
                            }
                          },
                          onReject: () async {
                            await _requestService.updateRequestStatus(
                              request.id,
                              'rejected',
                              walkerId: user.uid,
                              walkerName: user.name,
                            );
                            _showActionFeedback('Request removed from your queue.');
                          },
                        ),
                      )),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  final Color accent;
  final TextTheme textTheme;
  final UserModel user;
  final VoidCallback onLogoutPressed;
  final VoidCallback onProfileTap;

  const _DashboardHeader({
    required this.accent,
    required this.textTheme,
    required this.user,
    required this.onLogoutPressed,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CircleIconButton(
          icon: Icons.menu,
          onTap: () {},
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'PETSAATHI',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 2.4,
              color: AppColors.mintDeep,
            ),
          ),
        ),
        _CircleIconButton(
          icon: Icons.logout_rounded,
          onTap: onLogoutPressed,
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onProfileTap,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: AppColors.mintStart.withValues(alpha: 0.65), width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.mintStart.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                ? ClipOval(child: Image.network(user.avatarUrl!, fit: BoxFit.cover))
                : const Icon(Icons.pets_rounded, size: 20, color: AppColors.mintDeep),
          ),
        ),
      ],
    );
  }
}

class _SearchAndFilterBar extends StatelessWidget {
  final Color accent;
  final TextTheme textTheme;

  const _SearchAndFilterBar({
    required this.accent,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.85)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A3328).withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(Icons.search_rounded, color: AppColors.textMuted.withValues(alpha: 0.85)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Search jobs...',
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.mintStart, AppColors.mintEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(99),
              boxShadow: [
                BoxShadow(
                  color: AppColors.mintStart.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.tune_rounded, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final Color accent;
  final TextTheme textTheme;
  final String userId;

  const _StatsRow({
    required this.accent,
    required this.textTheme,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<WalkRequest>>(
      stream: RequestService().watchWalkerCompletedJobsToday(userId),
      builder: (context, snapshot) {
        final jobs = snapshot.data ?? [];
        final earnings = jobs.fold(0.0, (sum, item) => sum + item.amount);
        final count = jobs.length;

        return Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Earnings Today',
                value: '\$${earnings.toStringAsFixed(2)}',
                icon: Icons.payments_rounded,
                textTheme: textTheme,
                accent: accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Jobs Done',
                value: '$count',
                icon: Icons.directions_walk_rounded,
                textTheme: textTheme,
                accent: accent,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final TextTheme textTheme;
  final Color accent;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.textTheme,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.65)),
        boxShadow: AppShadows.card(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accent, AppColors.mintEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 16, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailabilityCard extends StatelessWidget {
  final Color accent;
  final TextTheme textTheme;
  final bool isAvailableNow;
  final ValueChanged<bool> onChanged;

  const _AvailabilityCard({
    required this.accent,
    required this.textTheme,
    required this.isAvailableNow,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        boxShadow: AppShadows.card(context),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.bolt_rounded, color: Colors.black87),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available for jobs',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isAvailableNow
                      ? 'You are visible to pet owners.'
                      : 'You are currently offline.',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isAvailableNow,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.mintStart,
            inactiveThumbColor: AppColors.textMuted,
            inactiveTrackColor: AppColors.border,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final WalkRequest request;
  final Color accent;
  final TextTheme textTheme;
  final VoidCallback onViewBrief;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _RequestCard({
    required this.request,
    required this.accent,
    required this.textTheme,
    required this.onViewBrief,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (request.imageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: Image.network(
                request.imageUrl!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      request.petName,
                      style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '\$${request.amount.toStringAsFixed(0)}',
                      style: textTheme.titleLarge?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Owner: ${request.ownerName}',
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on_rounded, size: 16, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      request.location ?? 'Nearby',
                      style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onViewBrief,
                        child: const Text('View Brief'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onReject,
                        child: const Text('Reject'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.mintStart, AppColors.mintEnd],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(AppRadii.md),
                          boxShadow: AppShadows.primaryGlow,
                        ),
                        child: ElevatedButton(
                          onPressed: onAccept,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadii.md),
                            ),
                          ),
                          child: const Text('Accept', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveJobCard extends StatelessWidget {
  final WalkRequest request;

  const _ActiveJobCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.mintStart.withValues(alpha: 0.6)),
        boxShadow: AppShadows.card(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_walk_rounded, color: AppColors.mintDeep),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Current Job: ${request.petName}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              StatusBadge(status: request.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Open detailed brief and next action timeline.',
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
            label: const Text('Open Job Detail'),
          ),
        ],
      ),
    );
  }
}

class _IncomingRequestBanner extends StatelessWidget {
  final int count;

  const _IncomingRequestBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.mintStart.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_active_rounded, color: AppColors.mintDeep),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$count new request${count == 1 ? '' : 's'} waiting for action',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Color accent;
  final TextTheme textTheme;
  final ValueChanged<int> onTap;

  const _BottomNavigation({
    required this.selectedIndex,
    required this.accent,
    required this.textTheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_rounded, 'Home'),
      (Icons.calendar_month_rounded, 'Walk History'),
      (Icons.mail_outline_rounded, 'Messages'),
      (Icons.person_rounded, 'Profile'),
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
          final selected = index == selectedIndex;
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => onTap(index),
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
                    style: textTheme.labelSmall?.copyWith(
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

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: Ink(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.9)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A3328).withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, size: 20, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

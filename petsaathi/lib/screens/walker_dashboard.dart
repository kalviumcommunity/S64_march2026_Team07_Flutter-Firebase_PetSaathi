import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/request_service.dart';
import '../models/user_model.dart';
import '../models/walk_request_model.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/paw_widgets.dart';
import 'landing_screen.dart';

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DashboardHeader(
                      accent: accent,
                      textTheme: textTheme,
                      user: user,
                      onLogoutPressed: _logout,
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
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Booking Requests',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: darkText,
                          ),
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
                      stream: _requestService.watchNearbyRequests(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
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
                          children: requests.map((request) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _RequestCard(
                              request: request,
                              accent: accent,
                              textTheme: textTheme,
                              onAccept: () async {
                                await _requestService.updateRequestStatus(
                                  request.id,
                                  'accepted',
                                  walkerId: user.uid,
                                  walkerName: user.name,
                                );
                                _showActionFeedback('Accepted ${request.petName}\'s walk!');
                              },
                              onReject: () async {
                                _showActionFeedback('Request hidden.');
                              },
                            ),
                          )).toList(),
                        );
                      }
                    ),
                  ],
                ),
              ),
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
}

class _DashboardHeader extends StatelessWidget {
  final Color accent;
  final TextTheme textTheme;
  final UserModel user;
  final VoidCallback onLogoutPressed;

  const _DashboardHeader({
    required this.accent,
    required this.textTheme,
    required this.user,
    required this.onLogoutPressed,
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
        Container(
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
          child: user.avatarUrl != null
              ? ClipOval(child: Image.network(user.avatarUrl!, fit: BoxFit.cover))
              : const Icon(Icons.pets_rounded, size: 20, color: AppColors.mintDeep),
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

  const _StatsRow({
    required this.accent,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Earnings Today',
            value: '\$0.00',
            icon: Icons.payments_rounded,
            textTheme: textTheme,
            accent: accent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Jobs Done',
            value: '0',
            icon: Icons.directions_walk_rounded,
            textTheme: textTheme,
            accent: accent,
          ),
        ),
      ],
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
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _RequestCard({
    required this.request,
    required this.accent,
    required this.textTheme,
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
      (Icons.calendar_today_rounded, 'Schedule'),
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

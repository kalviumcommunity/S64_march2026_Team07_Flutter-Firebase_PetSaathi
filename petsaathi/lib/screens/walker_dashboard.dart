import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'landing_screen.dart';

class WalkerDashboard extends StatefulWidget {
  const WalkerDashboard({super.key});

  @override
  State<WalkerDashboard> createState() => _WalkerDashboardState();
}

class _WalkerDashboardState extends State<WalkerDashboard> {
  int _selectedBottomNavIndex = 0;
  bool _isAvailableNow = true;
  int _selectedFilterIndex = 0;

  final List<String> _filters = const [
    'All Requests',
    'Nearby',
    'High Pay',
    'Recurring',
  ];

  final List<_BookingRequest> _requests = const [
    _BookingRequest(
      dogName: 'Buddy',
      breed: 'Golden Retriever',
      ownerName: 'Sarah Miller',
      location: 'Upper East Side',
      distanceKm: 2.0,
      timeLabel: 'TODAY, 10:00 AM',
      payout: 25,
      rating: 4.9,
      tags: ['Friendly', 'Leash Trained', 'Morning Walk'],
      imageUrl:
          'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?w=900&auto=format&fit=crop&q=80',
    ),
    _BookingRequest(
      dogName: 'Cooper',
      breed: 'Beagle',
      ownerName: 'David Chen',
      location: 'Downtown',
      distanceKm: 4.5,
      timeLabel: 'TODAY, 2:30 PM',
      payout: 32,
      rating: 4.8,
      tags: ['Energetic', 'Evening Preferred'],
      imageUrl:
          'https://images.unsplash.com/photo-1596492784531-6e6eb5ea9993?w=900&auto=format&fit=crop&q=80',
    ),
    _BookingRequest(
      dogName: 'Milo',
      breed: 'Indie',
      ownerName: 'Maya Rodriguez',
      location: 'Riverside',
      distanceKm: 1.3,
      timeLabel: 'TOMORROW, 8:15 AM',
      payout: 20,
      rating: 5.0,
      tags: ['Calm', 'Small Breed'],
      imageUrl:
          'https://images.unsplash.com/photo-1450778869180-41d0601e046e?w=900&auto=format&fit=crop&q=80',
    ),
  ];

  Future<void> _logout() async {
    await AuthService().logout();
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
                      onLogoutPressed: _logout,
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Manage your dog walks\nwithout the chaos',
                      style: textTheme.headlineMedium?.copyWith(
                        color: darkText,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.7,
                        height: 1.18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Accept requests faster, track earnings, and keep your daily schedule clean.',
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
                      isAvailableNow: _isAvailableNow,
                      onChanged: (value) {
                        setState(() => _isAvailableNow = value);
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
                          onPressed: () => _showActionFeedback('Opening all booking requests...'),
                          child: Text(
                            'View all',
                            style: textTheme.labelLarge?.copyWith(
                              color: Colors.black87,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _filters.length,
                        separatorBuilder: (_, index) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final selected = _selectedFilterIndex == index;
                          return ChoiceChip(
                            showCheckmark: false,
                            selected: selected,
                            label: Text(
                              _filters[index],
                              style: textTheme.labelLarge?.copyWith(
                                color: selected ? darkText : mutedText,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            selectedColor: accent,
                            backgroundColor: const Color(0xFFE8E8E8),
                            side: BorderSide.none,
                            onSelected: (_) {
                              setState(() => _selectedFilterIndex = index);
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    ..._requests.map(
                      (request) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _RequestCard(
                          request: request,
                          accent: accent,
                          textTheme: textTheme,
                          onAccept: () => _showActionFeedback(
                            'Accepted ${request.dogName} (${request.timeLabel})',
                          ),
                          onReject: () => _showActionFeedback(
                            'Rejected ${request.dogName} request',
                          ),
                        ),
                      ),
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
  final VoidCallback onLogoutPressed;

  const _DashboardHeader({
    required this.accent,
    required this.textTheme,
    required this.onLogoutPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CircleIconButton(
          icon: Icons.menu,
          onTap: () {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(content: Text('Menu actions can be added here.')),
              );
          },
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'PETSAATHI',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.1,
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: accent, width: 2),
          ),
          child: const Icon(Icons.pets_rounded, size: 20),
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
        color: const Color(0xFFEAEAEA),
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.search_rounded, color: Color(0xFF686868)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Search by dog name or location...',
              style: textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF686868),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(99),
            ),
            child: IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(content: Text('Filter drawer can be connected here.')),
                  );
              },
              icon: const Icon(Icons.tune_rounded, color: Colors.black87),
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
            value: '\$124.50',
            icon: Icons.payments_rounded,
            textTheme: textTheme,
            accent: accent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Walks Left',
            value: '4',
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(icon, size: 16, color: Colors.black87),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF767676),
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
              color: const Color(0xFF171717),
              letterSpacing: -0.2,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
                  'Available for instant bookings',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF171717),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isAvailableNow
                      ? 'Your profile is visible to nearby pet owners.'
                      : 'You are hidden from instant requests right now.',
                  style: textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF717171),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isAvailableNow,
            activeThumbColor: Colors.black,
            activeTrackColor: accent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final _BookingRequest request;
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Stack(
              children: [
                SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: Image.network(
                    request.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFF0F0F0),
                      alignment: Alignment.center,
                      child: const Icon(Icons.pets_rounded, size: 42),
                    ),
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          request.rating.toStringAsFixed(1),
                          style: textTheme.labelLarge?.copyWith(
                            color: const Color(0xFF202020),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${request.dogName} · ${request.breed}',
                            style: textTheme.titleLarge?.copyWith(
                              color: const Color(0xFF1A1A1A),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${request.ownerName} · ${request.timeLabel}',
                            style: textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF596050),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${request.payout}',
                          style: textTheme.headlineSmall?.copyWith(
                            color: const Color(0xFF141414),
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                        ),
                        Text(
                          'per session',
                          style: textTheme.labelSmall?.copyWith(
                            color: const Color(0xFF8A8A8A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 17, color: Color(0xFF6A6A6A)),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        '${request.location} · ${request.distanceKm.toStringAsFixed(1)} km away',
                        style: textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF707070),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: request.tags
                      .map(
                        (tag) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFEFEF),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            tag,
                            style: textTheme.labelMedium?.copyWith(
                              color: const Color(0xFF565656),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onReject,
                        icon: const Icon(Icons.close_rounded, size: 18),
                        label: const Text('Reject'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF272727),
                          side: const BorderSide(color: Color(0xFFCDCDCD)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size.fromHeight(46),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onAccept,
                        icon: const Icon(Icons.check_circle_rounded, size: 18),
                        label: const Text('Accept'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size.fromHeight(46),
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
      (Icons.payments_rounded, 'Earnings'),
      (Icons.person_rounded, 'Profile'),
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
          final selected = index == selectedIndex;
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => onTap(index),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    curve: Curves.easeOut,
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: selected ? accent : Colors.transparent,
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
                    style: textTheme.labelSmall?.copyWith(
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

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Icon(icon, color: Colors.black87),
      ),
    );
  }
}

class _BookingRequest {
  final String dogName;
  final String breed;
  final String ownerName;
  final String location;
  final double distanceKm;
  final String timeLabel;
  final int payout;
  final double rating;
  final List<String> tags;
  final String imageUrl;

  const _BookingRequest({
    required this.dogName,
    required this.breed,
    required this.ownerName,
    required this.location,
    required this.distanceKm,
    required this.timeLabel,
    required this.payout,
    required this.rating,
    required this.tags,
    required this.imageUrl,
  });
}

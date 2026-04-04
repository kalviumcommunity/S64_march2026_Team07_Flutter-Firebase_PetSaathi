import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../services/request_service.dart';
import '../models/walk_request_model.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/paw_widgets.dart';

class BookingsHistoryScreen extends StatefulWidget {
  const BookingsHistoryScreen({super.key});

  @override
  State<BookingsHistoryScreen> createState() => _BookingsHistoryScreenState();
}

class _BookingsHistoryScreenState extends State<BookingsHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    if (user == null) {
      return const Center(child: Text('Please log in to view bookings.'));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Your Bookings'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _RequestList(userId: user.uid, upcoming: true),
          _RequestList(userId: user.uid, upcoming: false),
        ],
      ),
    );
  }
}

class _RequestList extends StatelessWidget {
  final String userId;
  final bool upcoming;
  final _requestService = RequestService();

  _RequestList({required this.userId, required this.upcoming});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<WalkRequest>>(
      stream: _requestService.watchOwnerRequests(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final allRequests = snapshot.data ?? [];
        final requests = upcoming
            ? allRequests.where((r) => r.status != 'completed' && r.status != 'cancelled' && r.status != 'rejected').toList()
            : allRequests.where((r) => r.status == 'completed' || r.status == 'cancelled' || r.status == 'rejected').toList();

        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  upcoming ? Icons.calendar_today_rounded : Icons.history_rounded,
                  size: 64,
                  color: AppColors.textMuted.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    upcoming ? 'No upcoming walks scheduled yet.' : 'No past walks found in your history.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: requests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return _RequestCard(request: requests[index]);
          },
        );
      },
    );
  }
}

class _RequestCard extends StatelessWidget {
  final WalkRequest request;

  const _RequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEE, MMM d').format(request.scheduledAt);
    final timeStr = DateFormat('h:mm a').format(request.scheduledAt);

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.mintStart.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.directions_walk_rounded, color: AppColors.mintEnd),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Walk for ${request.petName}',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      request.walkerName != null ? 'with ${request.walkerName}' : 'Waiting for a walker...',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${request.amount.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  StatusBadge(status: request.status),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Text('$dateStr at $timeStr', style: const TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
              if (request.status == 'accepted')
                TextButton(
                  onPressed: () {
                    // Logic to contact walker
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Chat with walker coming soon.')),
                    );
                  },
                  child: const Text('Contact', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

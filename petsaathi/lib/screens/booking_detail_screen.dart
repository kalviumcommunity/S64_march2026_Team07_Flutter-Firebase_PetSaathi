import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/walk_request_model.dart';
import '../providers/auth_provider.dart';
import '../services/request_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/paw_widgets.dart';

class BookingDetailScreen extends StatelessWidget {
  final String requestId;

  const BookingDetailScreen({super.key, required this.requestId});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final requestService = RequestService();
    final isWalker = user.role == 'walker';

    return Scaffold(
      appBar: AppBar(title: const Text('Booking Detail')),
      body: StreamBuilder<WalkRequest?>(
        stream: requestService.watchRequestById(requestId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final request = snapshot.data;
          if (request == null) {
            return const Center(child: Text('Booking not found.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _OverviewCard(request: request, isWalker: isWalker),
                const SizedBox(height: 14),
                _BriefCard(request: request),
                const SizedBox(height: 14),
                _TimelineCard(status: request.status),
                const SizedBox(height: 16),
                _ActionBlock(
                  request: request,
                  isWalker: isWalker,
                  userId: user.uid,
                  userName: user.name,
                  requestService: requestService,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final WalkRequest request;
  final bool isWalker;

  const _OverviewCard({required this.request, required this.isWalker});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
        boxShadow: AppShadows.card(context),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.accentSoft,
            backgroundImage: request.imageUrl != null && request.imageUrl!.isNotEmpty
                ? NetworkImage(request.imageUrl!)
                : null,
            child: request.imageUrl == null || request.imageUrl!.isEmpty
                ? const Icon(Icons.pets_rounded, size: 28, color: AppColors.mintDeep)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Walk for ${request.petName}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  isWalker
                      ? 'Owner: ${request.ownerName}'
                      : 'Walker: ${request.walkerName ?? 'Waiting for acceptance'}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 6),
                StatusBadge(status: request.status),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BriefCard extends StatelessWidget {
  final WalkRequest request;

  const _BriefCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('EEE, MMM d, h:mm a').format(request.scheduledAt);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
        boxShadow: AppShadows.card(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Booking Brief', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          _BriefLine(icon: Icons.calendar_today_rounded, label: 'Schedule', value: date),
          const SizedBox(height: 8),
          _BriefLine(icon: Icons.location_on_rounded, label: 'Pickup', value: request.location ?? 'Not provided'),
          const SizedBox(height: 8),
          _BriefLine(icon: Icons.payments_rounded, label: 'Amount', value: '\$${request.amount.toStringAsFixed(0)}'),
          const SizedBox(height: 8),
          _BriefLine(
            icon: Icons.notes_rounded,
            label: 'Notes',
            value: request.requestNote == null || request.requestNote!.trim().isEmpty
                ? 'No extra instructions'
                : request.requestNote!,
          ),
        ],
      ),
    );
  }
}

class _BriefLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _BriefLine({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Text('$label: ', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final String status;

  const _TimelineCard({required this.status});

  int _stepForStatus() {
    switch (status) {
      case 'pending':
        return 1;
      case 'accepted':
        return 2;
      case 'in-progress':
        return 3;
      case 'completed':
        return 4;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _stepForStatus();
    const labels = ['Requested', 'Accepted', 'In Progress', 'Completed'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
        boxShadow: AppShadows.card(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Live Timeline', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Row(
            children: List.generate(labels.length, (index) {
              final active = step >= index + 1;
              return Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: active ? AppColors.mintStart : AppColors.border,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Icon(
                        active ? Icons.check_rounded : Icons.radio_button_unchecked_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      labels[index],
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: active ? AppColors.textPrimary : AppColors.textMuted,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ActionBlock extends StatelessWidget {
  final WalkRequest request;
  final bool isWalker;
  final String userId;
  final String userName;
  final RequestService requestService;

  const _ActionBlock({
    required this.request,
    required this.isWalker,
    required this.userId,
    required this.userName,
    required this.requestService,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isWalker && request.status == 'accepted')
          GradientActionButton(
            label: 'Start Walk',
            icon: Icons.play_arrow_rounded,
            onPressed: () async {
              await requestService.updateRequestStatus(
                request.id,
                'in-progress',
                walkerId: userId,
                walkerName: userName,
              );
            },
          ),
        if (isWalker && request.status == 'in-progress')
          GradientActionButton(
            label: 'Mark Completed',
            icon: Icons.task_alt_rounded,
            onPressed: () async {
              await requestService.updateRequestStatus(
                request.id,
                'completed',
                walkerId: userId,
                walkerName: userName,
              );
            },
          ),
        if (!isWalker && (request.status == 'pending' || request.status == 'accepted'))
          OutlinedButton.icon(
            onPressed: () async {
              await requestService.updateRequestStatus(request.id, 'cancelled');
            },
            icon: const Icon(Icons.cancel_rounded),
            label: const Text('Cancel Request'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
            ),
          ),
      ],
    );
  }
}
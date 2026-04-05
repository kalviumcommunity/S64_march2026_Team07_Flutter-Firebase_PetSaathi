import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/pet_model.dart';
import '../models/walk_request_model.dart';
import '../providers/auth_provider.dart';
import '../services/pet_service.dart';
import '../services/request_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/paw_widgets.dart';
import 'booking_detail_screen.dart';

class WalkerDiscoveryScreen extends StatefulWidget {
  const WalkerDiscoveryScreen({super.key});

  @override
  State<WalkerDiscoveryScreen> createState() => _WalkerDiscoveryScreenState();
}

class _WalkerDiscoveryScreenState extends State<WalkerDiscoveryScreen> {
  final _petService = PetService();
  final _requestService = RequestService();

  PetModel? _selectedPet;
  DateTime _scheduledAt = DateTime.now().add(const Duration(hours: 2));
  final _locationController = TextEditingController();
  final _noteController = TextEditingController();
  double _amount = 25;
  bool _submitting = false;

  @override
  void dispose() {
    _locationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickSchedule() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      initialDate: _scheduledAt,
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledAt),
    );
    if (time == null) return;

    setState(() {
      _scheduledAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _submitRequest() async {
    final auth = context.read<AuthProvider>();
    final owner = auth.user;
    if (owner == null) return;

    if (_selectedPet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a pet first.')),
      );
      return;
    }

    if (_locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add pickup address.')),
      );
      return;
    }

    setState(() => _submitting = true);

    final request = WalkRequest(
      id: '',
      petId: _selectedPet!.id,
      petName: _selectedPet!.name,
      ownerId: owner.uid,
      ownerName: owner.name,
      status: 'pending',
      scheduledAt: _scheduledAt,
      amount: _amount,
      location: _locationController.text.trim(),
      requestNote: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      imageUrl: _selectedPet!.photoUrl,
      tags: const ['broadcast'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      final requestId = await _requestService.createRequest(request);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BookingDetailScreen(requestId: requestId)),
      );
    } on StateError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message.toString())),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not send request right now.')),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final owner = auth.user;

    if (owner == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_locationController.text.isEmpty && owner.address != null) {
      _locationController.text = owner.address!;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Request a Walker')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<WalkRequest?>(
              stream: _requestService.watchOwnerActiveRequest(owner.uid),
              builder: (context, snapshot) {
                final active = snapshot.data;
                if (active == null) {
                  return const SizedBox.shrink();
                }

                return _ActiveRequestCard(request: active);
              },
            ),
            const SizedBox(height: 14),
            Text(
              'Broadcast Request',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              'Your request is sent to available walkers. First valid accept wins.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 14),
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select Pet', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  StreamBuilder<List<PetModel>>(
                    stream: _petService.watchOwnerPets(owner.uid),
                    builder: (context, snapshot) {
                      final pets = snapshot.data ?? const [];
                      if (pets.isEmpty) {
                        return Text(
                          'Add at least one pet profile before requesting a walker.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
                        );
                      }

                      return SizedBox(
                        height: 112,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: pets.length,
                          separatorBuilder: (context, index) => const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final pet = pets[index];
                            final selected = _selectedPet?.id == pet.id;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedPet = pet),
                              child: Container(
                                width: 94,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: selected ? AppColors.accentSoft : AppColors.background,
                                  borderRadius: BorderRadius.circular(AppRadii.md),
                                  border: Border.all(
                                    color: selected ? AppColors.mintStart : AppColors.border,
                                    width: selected ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundImage: pet.photoUrl.isNotEmpty ? NetworkImage(pet.photoUrl) : null,
                                      child: pet.photoUrl.isEmpty ? const Icon(Icons.pets_rounded) : null,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      pet.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              child: Column(
                children: [
                  _FieldLabel(text: 'Preferred schedule'),
                  OutlinedButton.icon(
                    onPressed: _pickSchedule,
                    icon: const Icon(Icons.calendar_month_rounded),
                    label: Text(DateFormat('EEE, MMM d • h:mm a').format(_scheduledAt)),
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  ),
                  const SizedBox(height: 12),
                  _FieldLabel(text: 'Pickup address'),
                  TextFormField(
                    controller: _locationController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.location_on_rounded),
                      hintText: 'Street and area',
                    ),
                  ),
                  const SizedBox(height: 12),
                  _FieldLabel(text: 'Special instructions'),
                  TextFormField(
                    controller: _noteController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.notes_rounded),
                      hintText: 'Medication, leash preferences, behavior notes...',
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Budget', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      Text(
                        '\$${_amount.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _amount,
                    min: 10,
                    max: 120,
                    divisions: 22,
                    onChanged: (value) => setState(() => _amount = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GradientActionButton(
              label: _submitting ? 'Sending...' : 'Broadcast Request',
              icon: Icons.campaign_rounded,
              onPressed: _submitting ? null : _submitRequest,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveRequestCard extends StatelessWidget {
  final WalkRequest request;

  const _ActiveRequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.mintStart.withValues(alpha: 0.55)),
        boxShadow: AppShadows.card(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_active_rounded, color: AppColors.mintDeep),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Active Request: ${request.petName}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              StatusBadge(status: request.status),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Track this request live while walkers respond.',
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
            label: const Text('View Detail'),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.65)),
        boxShadow: AppShadows.card(context),
      ),
      child: child,
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

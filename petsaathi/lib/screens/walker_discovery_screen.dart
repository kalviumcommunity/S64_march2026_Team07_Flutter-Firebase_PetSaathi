import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../models/pet_model.dart';
import '../models/walk_request_model.dart';
import '../services/walker_service.dart';
import '../services/pet_service.dart';
import '../services/request_service.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/paw_widgets.dart';

class WalkerDiscoveryScreen extends StatefulWidget {
  const WalkerDiscoveryScreen({super.key});

  @override
  State<WalkerDiscoveryScreen> createState() => _WalkerDiscoveryScreenState();
}

class _WalkerDiscoveryScreenState extends State<WalkerDiscoveryScreen> {
  final _walkerService = WalkerService();
  final _petService = PetService();
  final _requestService = RequestService();

  void _showBookingDialog(UserModel walker) {
    final auth = context.read<AuthProvider>();
    final owner = auth.user;
    if (owner == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BookingSheet(
        walker: walker,
        owner: owner,
        petService: _petService,
        onRequest: (request) async {
          await _requestService.createRequest(request);
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Walk requested for ${request.petName}!')),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Find a Sitter'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: _walkerService.watchAvailableWalkers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final walkers = snapshot.data ?? [];

          if (walkers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_search_rounded, size: 60, color: AppColors.textMuted),
                  const SizedBox(height: 16),
                  Text(
                    'No available walkers found nearby.',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: walkers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final walker = walkers[index];
              return _WalkerCard(
                walker: walker,
                onBook: () => _showBookingDialog(walker),
              );
            },
          );
        },
      ),
    );
  }
}

class _WalkerCard extends StatelessWidget {
  final UserModel walker;
  final VoidCallback onBook;
  const _WalkerCard({required this.walker, required this.onBook});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.mintStart.withOpacity(0.2),
            child: walker.avatarUrl != null && walker.avatarUrl!.isNotEmpty
                ? ClipOval(child: Image.network(walker.avatarUrl!, fit: BoxFit.cover, width: 60, height: 60))
                : const Icon(Icons.person, size: 30, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  walker.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  walker.location ?? 'Nearby',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      walker.trustScore.toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 10),
                    const StatusBadge(status: 'Available'),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onBook,
            icon: const Icon(Icons.calendar_month_rounded),
            color: AppColors.mintEnd,
          ),
        ],
      ),
    );
  }
}

class _BookingSheet extends StatefulWidget {
  final UserModel walker;
  final UserModel owner;
  final PetService petService;
  final Function(WalkRequest) onRequest;

  const _BookingSheet({
    required this.walker,
    required this.owner,
    required this.petService,
    required this.onRequest,
  });

  @override
  State<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<_BookingSheet> {
  PetModel? _selectedPet;
  double _amount = 25.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Book ${widget.walker.name}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Select Pet', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            StreamBuilder<List<PetModel>>(
              stream: widget.petService.watchOwnerPets(widget.owner.uid),
              builder: (context, snapshot) {
                final pets = snapshot.data ?? [];
                if (pets.isEmpty) return const Text('Add a pet profile first!');

                return SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: pets.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final pet = pets[index];
                      final isSelected = _selectedPet?.id == pet.id;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedPet = pet),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 80,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.mintStart.withOpacity(0.2) : Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppColors.mintStart : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundImage: pet.photoUrl.isNotEmpty ? NetworkImage(pet.photoUrl) : null,
                                child: pet.photoUrl.isEmpty ? const Icon(Icons.pets) : null,
                              ),
                              const SizedBox(height: 4),
                              Text(pet.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Proposed Amount', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  '\$${_amount.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.green),
                ),
              ],
            ),
            Slider(
              value: _amount,
              min: 10,
              max: 100,
              divisions: 18,
              activeColor: AppColors.mintEnd,
              onChanged: (val) => setState(() => _amount = val),
            ),
            const SizedBox(height: 24),
            GradientActionButton(
              label: 'Send Request',
              onPressed: _selectedPet == null
                  ? null
                  : () {
                      final req = WalkRequest(
                        id: '',
                        petId: _selectedPet!.id,
                        petName: _selectedPet!.name,
                        ownerId: widget.owner.uid,
                        ownerName: widget.owner.name,
                        status: 'pending',
                        scheduledAt: DateTime.now().add(const Duration(hours: 2)),
                        amount: _amount,
                        location: widget.owner.location ?? 'Nearby',
                        imageUrl: _selectedPet!.photoUrl,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      );
                      widget.onRequest(req);
                    },
            ),
          ],
        ),
      ),
    );
  }
}

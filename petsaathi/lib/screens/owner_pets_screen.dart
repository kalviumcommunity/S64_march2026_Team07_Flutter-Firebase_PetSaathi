import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/petsaathi_data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'create_pet_profile_screen.dart';
import 'edit_pet_profile_screen.dart';

class OwnerPetsScreen extends StatefulWidget {
  const OwnerPetsScreen({super.key});

  @override
  State<OwnerPetsScreen> createState() => _OwnerPetsScreenState();
}

class _OwnerPetsScreenState extends State<OwnerPetsScreen> {
  final _auth = AuthService();
  final _data = PetSaathiDataService();

  Future<void> _openCreatePetProfile() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CreatePetProfileScreen()),
    );

    if (!mounted) return;
    if (created == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pet profile created successfully!')),
      );
    }
  }

  void _showPendingMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Pets'),
          elevation: 0,
          backgroundColor: AppColors.background,
        ),
        body: Center(
          child: Text(
            'Session expired. Please log in again.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pets'),
        elevation: 0,
        backgroundColor: AppColors.background,
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SurfaceIconButton(
              icon: Icons.add_rounded,
              onTap: _openCreatePetProfile,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Owner Profile Card
              StreamBuilder<UserProfile?>(
                stream: _auth.watchCurrentUserProfile(),
                builder: (context, snapshot) {
                  final profile = snapshot.data;
                  final firstName = (profile?.name.isNotEmpty ?? false)
                      ? profile!.name.split(' ').first
                      : 'Pet Parent';

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: const Color(0xFFD7EEE0),
                              child: profile?.avatarUrl != null &&
                                      profile!.avatarUrl!.isNotEmpty
                                  ? ClipOval(
                                      child: Image.network(
                                        profile.avatarUrl!,
                                        width: 56,
                                        height: 56,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Icon(Icons.person_rounded,
                                      size: 28, color: AppColors.textPrimary),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    firstName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    profile?.email ?? 'pet@petsaathi.com',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppColors.textMuted,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _showPendingMessage(
                                'Profile editing is coming soon!',
                              ),
                              child: const Icon(
                                Icons.edit_rounded,
                                size: 20,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF4F0),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: StreamBuilder<List<PetSummary>>(
                            stream: _data.watchOwnerPets(uid),
                            builder: (context, petSnapshot) {
                              final petCount = petSnapshot.data?.length ?? 0;
                              return Text(
                                '$petCount ${petCount == 1 ? 'pet' : 'pets'} in your care',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: const Color(0xFF5FCD85),
                                      fontWeight: FontWeight.w600,
                                    ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 22),

              // Pets List Section
              Text(
                'Your Pets',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),

              StreamBuilder<List<PetSummary>>(
                stream: _data.watchOwnerPets(uid),
                builder: (context, snapshot) {
                  final pets = snapshot.data ?? const [];

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (pets.isEmpty) {
                    return _EmptyPetsCard(
                      onTap: _openCreatePetProfile,
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: pets.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final pet = pets[index];
                      return _PetListCard(
                        pet: pet,
                        onEdit: () => _openEditPet(pet),
                        onDelete: () => _confirmDeletePet(pet),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openEditPet(PetSummary pet) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditPetProfileScreen(petId: pet.id),
      ),
    );

    if (!mounted) return;
    if (updated == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pet profile updated successfully!')),
      );
    }
  }

  void _confirmDeletePet(PetSummary pet) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(
            'Delete ${pet.name}?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: const Text(
            'This action cannot be undone. Are you sure you want to delete this pet profile?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deletePet(pet.id);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePet(String petId) async {
    try {
      await _data.deletePetProfile(petId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pet profile deleted.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting pet: $e')),
      );
    }
  }
}

class _PetListCard extends StatelessWidget {
  final PetSummary pet;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PetListCard({
    required this.pet,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Pet Image
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 100,
              height: 100,
              child: pet.imageUrl.isEmpty
                  ? Container(
                      color: const Color(0xFFE6ECE8),
                      alignment: Alignment.center,
                      child: const Icon(Icons.pets_rounded, size: 40),
                    )
                  : Image.network(
                      pet.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFFE6ECE8),
                        alignment: Alignment.center,
                        child: const Icon(Icons.pets_rounded, size: 40),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),

          // Pet Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  pet.statusText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Action Buttons
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.edit_rounded,
                      size: 18, color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEEEE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.delete_rounded,
                      size: 18, color: Colors.red),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyPetsCard extends StatelessWidget {
  final VoidCallback onTap;

  const _EmptyPetsCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No pets yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first pet to get started with booking trusted walkers.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textMuted,
                ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: 220,
            child: GradientActionButton(
              label: 'Add Pet Profile',
              onPressed: onTap,
            ),
          ),
        ],
      ),
    );
  }
}

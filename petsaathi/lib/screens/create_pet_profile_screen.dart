import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/petsaathi_data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class CreatePetProfileScreen extends StatefulWidget {
  const CreatePetProfileScreen({super.key});

  @override
  State<CreatePetProfileScreen> createState() => _CreatePetProfileScreenState();
}

class _CreatePetProfileScreenState extends State<CreatePetProfileScreen> {
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  final _dataService = PetSaathiDataService();

  String _petType = 'Dog';
  String _ageGroup = 'Adult';
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final ownerId = FirebaseAuth.instance.currentUser?.uid;
    final petName = _nameController.text.trim();

    if (ownerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expired. Please login again.')),
      );
      return;
    }

    if (petName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter pet name.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _dataService.createPetProfile(
        ownerId: ownerId,
        input: CreatePetProfileInput(
          name: petName,
          petType: _petType,
          ageGroup: _ageGroup,
          notes: _notesController.text.trim(),
        ),
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save pet profile. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Pet Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Just the essentials',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'These details help us match the right walker quickly.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textMuted,
                    ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Pet name',
                  prefixIcon: Icon(Icons.pets_rounded),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _petType,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: const [
                  DropdownMenuItem(value: 'Dog', child: Text('Dog')),
                  DropdownMenuItem(value: 'Cat', child: Text('Cat')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _petType = value);
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _ageGroup,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.schedule_outlined),
                ),
                items: const [
                  DropdownMenuItem(value: 'Puppy/Kitten', child: Text('Puppy/Kitten')),
                  DropdownMenuItem(value: 'Adult', child: Text('Adult')),
                  DropdownMenuItem(value: 'Senior', child: Text('Senior')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _ageGroup = value);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                maxLines: 3,
                maxLength: 120,
                decoration: const InputDecoration(
                  hintText: 'Quick notes (optional)',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
              ),
              const SizedBox(height: 10),
              if (_isSaving)
                const Center(child: CircularProgressIndicator())
              else
                GradientActionButton(
                  label: 'Save Pet Profile',
                  onPressed: _saveProfile,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

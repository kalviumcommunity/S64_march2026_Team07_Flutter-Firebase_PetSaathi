import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../services/pet_service.dart';
import '../models/pet_model.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class CreatePetProfileScreen extends StatefulWidget {
  const CreatePetProfileScreen({super.key});

  @override
  State<CreatePetProfileScreen> createState() => _CreatePetProfileScreenState();
}

class _CreatePetProfileScreenState extends State<CreatePetProfileScreen> {
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _thingsToKnowController = TextEditingController();
  final _medicalHealthController = TextEditingController();
  final _petService = PetService();
  final _picker = ImagePicker();

  String _petType = 'Dog';
  String _ageGroup = 'Adult';
  File? _imageFile;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _descriptionController.dispose();
    _thingsToKnowController.dispose();
    _medicalHealthController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _saveProfile() async {
    final auth = context.read<AuthProvider>();
    final ownerId = auth.user?.uid;
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
      String photoUrl = '';
      if (_imageFile != null) {
        photoUrl = await _petService.uploadPetPhoto(ownerId, _imageFile!);
      }

      final pet = PetModel(
        id: '',
        ownerId: ownerId,
        name: petName,
        petType: _petType,
        breed: _breedController.text.trim(),
        ageGroup: _ageGroup,
        description: _descriptionController.text.trim(),
        thingsToKnow: _thingsToKnowController.text.trim(),
        medicalHealth: _medicalHealthController.text.trim(),
        photoUrl: photoUrl,
        statusText: 'Healthy & Happy',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _petService.createPetProfile(pet);

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save pet profile: $e')),
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
              _buildImagePicker(),
              const SizedBox(height: 24),
              Text(
                'Tell us about your pet',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Details about habits and health help sitters provide better care.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textMuted,
                    ),
              ),
              const SizedBox(height: 24),
              _buildTextField(_nameController, 'Pet Name', Icons.pets_rounded),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildTypeDropdown()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildAgeDropdown()),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField(_breedController, 'Breed', Icons.category_outlined),
              const SizedBox(height: 12),
              _buildTextField(_descriptionController, 'Habits & Behavior', Icons.psychology_outlined, maxLines: 3),
              const SizedBox(height: 12),
              _buildTextField(_thingsToKnowController, 'Things to know about pet', Icons.info_outline_rounded, maxLines: 2),
              const SizedBox(height: 12),
              _buildTextField(_medicalHealthController, 'Medical Health info', Icons.medical_services_outlined, maxLines: 2),
              const SizedBox(height: 24),
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

  Widget _buildImagePicker() {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.border, width: 2),
          ),
          child: _imageFile != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Image.file(_imageFile!, fit: BoxFit.cover),
                )
              : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo_outlined, size: 32, color: AppColors.textMuted),
                    SizedBox(height: 4),
                    Text('Add Photo', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _petType,
      decoration: const InputDecoration(prefixIcon: Icon(Icons.category_outlined)),
      items: const [
        DropdownMenuItem(value: 'Dog', child: Text('Dog')),
        DropdownMenuItem(value: 'Cat', child: Text('Cat')),
      ],
      onChanged: (value) {
        if (value != null) setState(() => _petType = value);
      },
    );
  }

  Widget _buildAgeDropdown() {
    return DropdownButtonFormField<String>(
      value: _ageGroup,
      decoration: const InputDecoration(prefixIcon: Icon(Icons.schedule_outlined)),
      items: const [
        DropdownMenuItem(value: 'Puppy/Kitten', child: Text('Puppy/Kitten')),
        DropdownMenuItem(value: 'Adult', child: Text('Adult')),
        DropdownMenuItem(value: 'Senior', child: Text('Senior')),
      ],
      onChanged: (value) {
        if (value != null) setState(() => _ageGroup = value);
      },
    );
  }
}

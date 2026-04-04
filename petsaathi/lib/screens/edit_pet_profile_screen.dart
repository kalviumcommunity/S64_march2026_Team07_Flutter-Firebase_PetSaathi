import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../services/pet_service.dart';
import '../models/pet_model.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class EditPetProfileScreen extends StatefulWidget {
  final String petId;

  const EditPetProfileScreen({super.key, required this.petId});

  @override
  State<EditPetProfileScreen> createState() => _EditPetProfileScreenState();
}

class _EditPetProfileScreenState extends State<EditPetProfileScreen> {
  final _petService = PetService();
  final _picker = ImagePicker();
  
  late TextEditingController _nameController;
  late TextEditingController _breedController;
  late TextEditingController _descriptionController;
  late TextEditingController _thingsToKnowController;
  late TextEditingController _medicalHealthController;
  
  late String _petType;
  late String _ageGroup;
  String? _currentPhotoUrl;
  File? _newImageFile;
  
  PetModel? _pet;
  bool _isSaving = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _breedController = TextEditingController();
    _descriptionController = TextEditingController();
    _thingsToKnowController = TextEditingController();
    _medicalHealthController = TextEditingController();
    _petType = 'Dog';
    _ageGroup = 'Adult';
    _loadPetData();
  }

  Future<void> _loadPetData() async {
    try {
      final pet = await _petService.getPetDetail(widget.petId);
      if (!mounted) return;

      if (pet == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Pet not found';
        });
        return;
      }

      setState(() {
        _pet = pet;
        _nameController.text = pet.name;
        _breedController.text = pet.breed;
        _petType = pet.petType;
        _ageGroup = pet.ageGroup;
        _descriptionController.text = pet.description;
        _thingsToKnowController.text = pet.thingsToKnow;
        _medicalHealthController.text = pet.medicalHealth;
        _currentPhotoUrl = pet.photoUrl;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading pet data: $e';
      });
    }
  }

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
      setState(() => _newImageFile = File(pickedFile.path));
    }
  }

  Future<void> _saveProfile() async {
    final auth = context.read<AuthProvider>();
    final ownerId = auth.user?.uid;
    final petName = _nameController.text.trim();

    if (ownerId == null || _pet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expired. Please login again.')),
      );
      return;
    }

    if (petName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a pet name')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String photoUrl = _currentPhotoUrl ?? '';
      if (_newImageFile != null) {
        photoUrl = await _petService.uploadPetPhoto(ownerId, _newImageFile!);
      }

      final updatedPet = PetModel(
        id: widget.petId,
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
        createdAt: _pet!.createdAt,
        updatedAt: DateTime.now(),
      );

      await _petService.updatePetProfile(updatedPet);

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving pet profile: $e')),
      );
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(
            'Delete ${_nameController.text}?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: const Text(
            'This cannot be undone. The pet profile and all associated data will be permanently deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deletePet();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePet() async {
    try {
      await _petService.deletePetProfile(widget.petId);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting pet: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Pet Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Pet Profile')),
        body: Center(child: Text(_errorMessage!)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Pet Profile'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImagePicker(),
              const SizedBox(height: 24),
              _buildLabel('Pet Name'),
              _buildTextField(_nameController, 'e.g., Max, Bella', Icons.pets_rounded),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Type'),
                        _buildTypeDropdown(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Age Group'),
                        _buildAgeDropdown(),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildLabel('Breed'),
              _buildTextField(_breedController, 'e.g., Golden Retriever', Icons.category_rounded),
              const SizedBox(height: 16),
              _buildLabel('Habits & Behavior'),
              _buildTextField(_descriptionController, 'Daily habits, behavior around others...', Icons.psychology_rounded, maxLines: 3),
              const SizedBox(height: 16),
              _buildLabel('Things to know'),
              _buildTextField(_thingsToKnowController, 'Feeding schedule, emergency contacts...', Icons.info_outline_rounded, maxLines: 2),
              const SizedBox(height: 16),
              _buildLabel('Medical Health'),
              _buildTextField(_medicalHealthController, 'Conditions, allergies, medication...', Icons.medical_services_rounded, maxLines: 2),
              const SizedBox(height: 28),
              if (_isSaving)
                const Center(child: CircularProgressIndicator())
              else ...[
                GradientActionButton(
                  label: 'Save Changes',
                  onPressed: _saveProfile,
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _confirmDelete,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Delete Profile', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
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
          child: _newImageFile != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Image.file(_newImageFile!, fit: BoxFit.cover),
                )
              : (_currentPhotoUrl != null && _currentPhotoUrl!.isNotEmpty)
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.network(_currentPhotoUrl!, fit: BoxFit.cover),
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined, size: 32, color: AppColors.textMuted),
                        SizedBox(height: 4),
                        Text('Change Photo', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {int maxLines = 1}) {
    return TextFormField(
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

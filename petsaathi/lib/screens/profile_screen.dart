import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/pet_service.dart';
import '../models/pet_model.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'landing_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _avatarUrlController = TextEditingController();
  final _bioController = TextEditingController();
  final _priceController = TextEditingController();
  final _scheduleController = TextEditingController();

  bool _initialized = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _avatarUrlController.dispose();
    _bioController.dispose();
    _priceController.dispose();
    _scheduleController.dispose();
    super.dispose();
  }

  void _initializeFields(AuthProvider auth) {
    if (_initialized || auth.user == null) return;
    final user = auth.user!;
    _nameController.text = user.name;
    _phoneController.text = user.phone ?? '';
    _cityController.text = user.city ?? user.location ?? '';
    _addressController.text = user.address ?? '';
    _avatarUrlController.text = user.avatarUrl ?? '';
    _bioController.text = user.bio ?? '';
    _priceController.text = user.pricePerWalk?.toStringAsFixed(0) ?? '';
    _scheduleController.text = user.availabilitySchedule.join(', ');
    _initialized = true;
  }

  Future<void> _saveProfile(AuthProvider auth) async {
    final user = auth.user;
    if (user == null) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final isWalker = user.role == 'walker';
    final parsedPrice = double.tryParse(_priceController.text.trim());
    final schedule = _scheduleController.text
        .split(',')
        .map((slot) => slot.trim())
        .where((slot) => slot.isNotEmpty)
        .toList();

    try {
      await auth.updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        city: _cityController.text.trim(),
        location: _cityController.text.trim(),
        address: _addressController.text.trim(),
        avatarUrl: _avatarUrlController.text.trim().isEmpty ? null : _avatarUrlController.text.trim(),
        bio: isWalker ? _bioController.text.trim() : null,
        pricePerWalk: isWalker ? parsedPrice : null,
        availabilitySchedule: isWalker ? schedule : null,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to update profile right now.')),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LandingScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    _initializeFields(auth);
    final isWalker = user.role == 'walker';
    final title = isWalker ? 'Walker Profile' : 'Owner Profile';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  border: Border.all(color: AppColors.border.withValues(alpha: 0.75)),
                  boxShadow: AppShadows.card(context),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.accentSoft,
                      backgroundImage: _avatarUrlController.text.trim().isNotEmpty
                          ? NetworkImage(_avatarUrlController.text.trim())
                          : null,
                      child: _avatarUrlController.text.trim().isEmpty
                          ? const Icon(Icons.person_rounded, size: 28, color: AppColors.textPrimary)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 2),
                          Text(user.email, style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: 4),
                          Text(
                            isWalker ? 'Walker account' : 'Owner account',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _FieldLabel(text: 'Full name'),
              TextFormField(
                controller: _nameController,
                validator: (value) => value == null || value.trim().isEmpty ? 'Name is required' : null,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.person_rounded), hintText: 'Your full name'),
              ),
              const SizedBox(height: 12),
              _FieldLabel(text: 'Phone'),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.trim().isEmpty ? 'Phone is required' : null,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.call_rounded), hintText: 'Phone number'),
              ),
              const SizedBox(height: 12),
              _FieldLabel(text: 'City'),
              TextFormField(
                controller: _cityController,
                validator: (value) => value == null || value.trim().isEmpty ? 'City is required' : null,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.location_city_rounded), hintText: 'City'),
              ),
              const SizedBox(height: 12),
              _FieldLabel(text: 'Address'),
              TextFormField(
                controller: _addressController,
                minLines: 2,
                maxLines: 3,
                validator: (value) => value == null || value.trim().isEmpty ? 'Address is required' : null,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.home_rounded), hintText: 'Street address'),
              ),
              const SizedBox(height: 12),
              _FieldLabel(text: 'Profile photo URL'),
              TextFormField(
                controller: _avatarUrlController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.image_rounded), hintText: 'https://...'),
              ),
              if (isWalker) ...[
                const SizedBox(height: 12),
                _FieldLabel(text: 'Bio and experience'),
                TextFormField(
                  controller: _bioController,
                  minLines: 3,
                  maxLines: 5,
                  validator: (value) => value == null || value.trim().isEmpty ? 'Bio is required for walkers' : null,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.badge_rounded),
                    hintText: 'Tell owners about your experience and care style',
                  ),
                ),
                const SizedBox(height: 12),
                _FieldLabel(text: 'Price per walk (USD)'),
                TextFormField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Price is required for walkers';
                    final parsed = double.tryParse(value.trim());
                    if (parsed == null || parsed <= 0) return 'Enter a valid price';
                    return null;
                  },
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.payments_rounded), hintText: 'Example: 25'),
                ),
                const SizedBox(height: 12),
                _FieldLabel(text: 'Availability schedule'),
                TextFormField(
                  controller: _scheduleController,
                  validator: (value) => value == null || value.trim().isEmpty ? 'Schedule is required for walkers' : null,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.schedule_rounded),
                    hintText: 'Example: Mon 8-11, Tue 6-9, Sat 10-2',
                  ),
                ),
              ],
              if (!isWalker) ...[
                const SizedBox(height: 24),
                _FieldLabel(text: 'Active Pets'),
                StreamBuilder<List<PetModel>>(
                  stream: PetService().watchOwnerPets(user.uid),
                  builder: (context, snapshot) {
                    final pets = snapshot.data ?? [];
                    if (pets.isEmpty) {
                      return Text('No active pets found.', style: TextStyle(color: AppColors.textMuted));
                    }
                    return Column(
                      children: pets.map((pet) => _PetListTile(pet: pet)).toList(),
                    );
                  },
                ),
              ],
              const SizedBox(height: 18),
              GradientActionButton(
                label: _saving ? 'Saving...' : 'Save profile',
                onPressed: _saving ? null : () => _saveProfile(auth),
                icon: Icons.check_circle_rounded,
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _saving ? null : _logout,
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Logout'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error, width: 1.2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PetListTile extends StatelessWidget {
  final PetModel pet;

  const _PetListTile({required this.pet});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: pet.photoUrl.isNotEmpty ? NetworkImage(pet.photoUrl) : null,
            child: pet.photoUrl.isEmpty ? const Icon(Icons.pets_rounded, size: 20, color: AppColors.mintDeep) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pet.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(pet.breed, style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
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
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
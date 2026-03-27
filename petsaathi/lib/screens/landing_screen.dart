import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  String _selectedRole = 'owner';

  void _openLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen(role: _selectedRole)),
    );
  }

  void _openSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SignupScreen(role: _selectedRole)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(90),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEAF8EE), Color(0xFFDDF3E3)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Icon(Icons.pets_rounded, size: 88, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'One Home for All\nYour Pet\'s Needs',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.7,
                          ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Choose your role to continue with the right dashboard and tools.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 24),
                    _RoleSelector(
                      selectedRole: _selectedRole,
                      onChange: (role) => setState(() => _selectedRole = role),
                    ),
                  ],
                ),
              ),
              GradientActionButton(
                label: 'Log in',
                onPressed: _openLogin,
              ),
              const SizedBox(height: 12),
              GradientActionButton(
                label: 'Register',
                onPressed: _openSignup,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Social login will be enabled in the next milestone.')),
                  );
                },
                icon: const Icon(Icons.apple_rounded),
                label: const Text('Sign in with Apple'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleSelector extends StatelessWidget {
  final String selectedRole;
  final ValueChanged<String> onChange;

  const _RoleSelector({
    required this.selectedRole,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _RoleChip(
            label: 'Pet Owner',
            selected: selectedRole == 'owner',
            onTap: () => onChange('owner'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _RoleChip(
            label: 'Dog Walker',
            selected: selectedRole == 'walker',
            onTap: () => onChange('walker'),
          ),
        ),
      ],
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RoleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.surface : const Color(0xFFE9EEEB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? AppColors.mintStart : AppColors.border),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.textPrimary : AppColors.textMuted,
              ),
        ),
      ),
    );
  }
}

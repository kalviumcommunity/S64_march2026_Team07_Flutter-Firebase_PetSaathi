import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'owner_dashboard.dart';
import 'walker_dashboard.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../providers/auth_provider.dart';

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
    final auth = context.watch<AuthProvider>();

    // Initial load/Auto-login
    if (auth.isAuthenticated && auth.user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (auth.user?.role == 'owner') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const OwnerDashboard()),
            (route) => false,
          );
        } else if (auth.user?.role == 'walker') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const WalkerDashboard()),
            (route) => false,
          );
        }
      });

      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.accentSoft.withValues(alpha: 0.55),
                    AppColors.background,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: -100,
            right: -70,
            child: IgnorePointer(
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.mintEnd.withValues(alpha: 0.18),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            left: -40,
            child: IgnorePointer(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.mintStart.withValues(alpha: 0.1),
                ),
              ),
            ),
          ),
          SafeArea(
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
                          width: 184,
                          height: 184,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(92),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE8F8EF), Color(0xFFD4F0E0)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.mintStart.withValues(alpha: 0.22),
                                blurRadius: 32,
                                offset: const Offset(0, 14),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.85),
                              width: 3,
                            ),
                          ),
                          child: const Icon(Icons.pets_rounded, size: 86, color: AppColors.mintDeep),
                        ),
                    const SizedBox(height: 28),
                    Text(
                      'One Home for All\nYour Pet\'s Needs',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.9,
                            height: 1.12,
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
                icon: const Icon(Icons.apple_rounded, size: 22),
                label: const Text('Sign in with Apple'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  foregroundColor: AppColors.textPrimary,
                  backgroundColor: AppColors.surface,
                  side: BorderSide(color: AppColors.border.withValues(alpha: 0.95), width: 1.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.pill)),
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
        ],
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
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.surface : AppColors.surface.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: selected ? AppColors.mintStart : AppColors.border,
            width: selected ? 1.8 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.mintStart.withValues(alpha: 0.2),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
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

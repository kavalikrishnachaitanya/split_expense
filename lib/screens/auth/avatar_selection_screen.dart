import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:split_expense/providers/auth_provider.dart';

class AvatarSelectionScreen extends StatefulWidget {
  const AvatarSelectionScreen({super.key});

  @override
  State<AvatarSelectionScreen> createState() => _AvatarSelectionScreenState();
}

class _AvatarSelectionScreenState extends State<AvatarSelectionScreen> {
  String? _selectedAvatar;
  String? _selectedGender;

  final List<String> _avatars = [
    'assets/images/avatars/avatar_1.png',
    'assets/images/avatars/avatar_2.png',
    'assets/images/avatars/avatar_3.png',
    'assets/images/avatars/avatar_4.png',
    'assets/images/avatars/avatar_5.png',
    'assets/images/avatars/avatar_6.png',
  ];

  Future<void> _continue() async {
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your gender')),
      );
      return;
    }

    if (_selectedAvatar == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an avatar')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.completeGoogleSignUp(
      _selectedAvatar!,
      gender: _selectedGender,
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Failed to complete profile'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
    // Note: Navigation is handled by main.dart based on userModel state
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Spacer(),
                        
                        // Welcome message
                        Icon(
                          Icons.account_circle_outlined,
                          size: 80,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(height: 24),
                        
                        Text(
                          'Choose Your Avatar',
                          textAlign: TextAlign.center,
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        Text(
                          'Pick an avatar to personalize your profile',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Gender Selection
                        Text(
                          'Gender',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _GenderCard(
                                label: 'Male',
                                icon: Icons.male_rounded,
                                isSelected: _selectedGender == 'Male',
                                onTap: () => setState(() => _selectedGender = 'Male'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _GenderCard(
                                label: 'Female',
                                icon: Icons.female_rounded,
                                isSelected: _selectedGender == 'Female',
                                onTap: () => setState(() => _selectedGender = 'Female'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _GenderCard(
                                label: 'Other',
                                icon: Icons.transgender_rounded,
                                isSelected: _selectedGender == 'Other',
                                onTap: () => setState(() => _selectedGender = 'Other'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Avatar Selection Title
                        Text(
                          'Choose Your Avatar',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Avatar List (Horizontal)
                        SizedBox(
                          height: 120,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: _avatars.length,
                            separatorBuilder: (context, index) => const SizedBox(width: 16),
                            itemBuilder: (context, index) {
                              final avatar = _avatars[index];
                              final isSelected = _selectedAvatar == avatar;
                              return Center(
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedAvatar = avatar),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: isSelected ? 100 : 90,
                                    height: isSelected ? 100 : 90,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: isSelected
                                          ? Border.all(
                                              color: colorScheme.primary,
                                              width: 3,
                                            )
                                          : Border.all(color: Colors.transparent, width: 3),
                                      boxShadow: [
                                        if (isSelected)
                                          BoxShadow(
                                            color: colorScheme.primary.withOpacity(0.4),
                                            blurRadius: 12,
                                            spreadRadius: 2,
                                            offset: const Offset(0, 4),
                                          )
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      backgroundColor: colorScheme.surfaceContainerHighest,
                                      backgroundImage: AssetImage(avatar),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        
                        const Spacer(),

                        // Continue Button
                        SizedBox(
                          height: 56,
                          child: FilledButton(
                            onPressed: authProvider.isLoading ? null : _continue,
                            style: FilledButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              shadowColor: colorScheme.primary.withOpacity(0.4),
                              elevation: 8,
                            ),
                            child: authProvider.isLoading
                                ? SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: colorScheme.onPrimary,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    'Continue',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: colorScheme.primary, width: 2) : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:split_expense/providers/auth_provider.dart';
import 'package:split_expense/widgets/google_sign_in_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  String? _selectedAvatar;
  bool _isEditing = false;

  final List<String> _avatars = [
    'assets/images/avatars/avatar_1.png',
    'assets/images/avatars/avatar_2.png',
    'assets/images/avatars/avatar_3.png',
    'assets/images/avatars/avatar_4.png',
    'assets/images/avatars/avatar_5.png',
    'assets/images/avatars/avatar_6.png',
  ];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().userModel;
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _selectedAvatar = user?.photoUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await context.read<AuthProvider>().updateProfile(
          _nameController.text.trim(),
          _selectedAvatar,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      setState(() => _isEditing = false);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<AuthProvider>().error ?? 'Update failed'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.\n\n'
          'Note: You can only delete your account if you have NO outstanding dues in any group.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<AuthProvider>().deleteAccount();
      if (success && mounted) {
        // Navigation to login is usually handled by auth listener in main.dart
        Navigator.popUntil(context, (route) => route.isFirst);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.read<AuthProvider>().error ?? 'Deletion failed'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 5), // Longer duration to read error
          ),
        );
      }
    }
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => SizedBox(
        height: 200,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          scrollDirection: Axis.horizontal,
          itemCount: _avatars.length,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (context, index) {
            final avatar = _avatars[index];
            final isSelected = _selectedAvatar == avatar;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedAvatar = avatar);
                Navigator.pop(context);
              },
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 3,
                        )
                      : null,
                ),
                child: CircleAvatar(
                  backgroundImage: AssetImage(avatar),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().userModel;
    final isLoading = context.watch<AuthProvider>().isLoading;
    final colorScheme = Theme.of(context).colorScheme;

    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                // Cancel editing, revert changes
                _nameController.text = user.displayName ?? '';
                _selectedAvatar = user.photoUrl;
              }
              setState(() => _isEditing = !_isEditing);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar
              GestureDetector(
                onTap: _isEditing ? _showAvatarPicker : null,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      backgroundImage: _selectedAvatar != null
                          ? AssetImage(_selectedAvatar!)
                          : null,
                      child: _selectedAvatar == null
                          ? Icon(Icons.person, size: 60, color: colorScheme.onSurfaceVariant)
                          : null,
                    ),
                    if (_isEditing)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: colorScheme.primary,
                          child: Icon(Icons.camera_alt, size: 18, color: colorScheme.onPrimary),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Name Field
              TextFormField(
                controller: _nameController,
                enabled: _isEditing,
                decoration: const InputDecoration(
                  labelText: 'Display Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Action Buttons
              if (_isEditing)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FilledButton(
                      onPressed: isLoading ? null : _updateProfile,
                      child: isLoading
                          ? const SizedBox(
                              height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Save Changes'),
                    ),
                  ],
                ),

              if (!_isEditing) ...[
                const Divider(height: 48),
                
                // Danger Zone
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.error.withOpacity(0.5)),
                  ),
                  child: Column(
                    children: [
                       Row(
                         children: [
                           Icon(Icons.warning_amber_rounded, color: colorScheme.error),
                           const SizedBox(width: 12),
                           Text(
                             'Danger Zone',
                             style: TextStyle(
                               fontWeight: FontWeight.bold, 
                               color: colorScheme.error
                             ),
                           ),
                         ],
                       ),
                       const SizedBox(height: 16),
                       Text(
                         'Delete your account permanently. This action is only possible if you have settled all debts.',
                         style: TextStyle(color: colorScheme.onErrorContainer),
                       ),
                       const SizedBox(height: 16),
                       SizedBox(
                         width: double.infinity,
                         child: OutlinedButton(
                           onPressed: isLoading ? null : _deleteAccount,
                           style: OutlinedButton.styleFrom(
                             foregroundColor: colorScheme.error,
                             side: BorderSide(color: colorScheme.error),
                           ),
                           child: isLoading 
                             ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.error))
                             : const Text('Delete Account'),
                         ),
                       ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

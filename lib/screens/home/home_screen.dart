import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:split_expense/providers/auth_provider.dart';
import 'package:split_expense/providers/group_provider.dart';
import 'package:split_expense/providers/expense_provider.dart';
import 'package:split_expense/screens/groups/create_group_screen.dart';
import 'package:split_expense/widgets/group_card.dart';
import 'package:split_expense/screens/groups/group_detail_screen.dart'; // Added
import 'package:split_expense/utils/constants.dart'; // Added
import 'package:split_expense/screens/profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  void _loadGroups() {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user != null) {
      context.read<GroupProvider>().loadUserGroups(authProvider.user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileScreen()),
                );
              } else if (value == 'logout') {
                _confirmSignOut(context);
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Sign Out'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<GroupProvider>(
        builder: (context, groupProvider, child) {
          if (groupProvider.error != null) {
             // Show error if present, especially useful for missing index
             return Center(
               child: Padding(
                 padding: const EdgeInsets.all(16),
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     Icon(
                       Icons.error_outline,
                       size: 60,
                       color: colorScheme.error,
                     ),
                     const SizedBox(height: 16),
                     Text(
                       'Something went wrong',
                       style: Theme.of(context).textTheme.titleLarge,
                     ),
                     const SizedBox(height: 8),
                     SelectableText(
                       groupProvider.error!,
                       style: TextStyle(color: colorScheme.error),
                       textAlign: TextAlign.center,
                     ),
                     const SizedBox(height: 24),
                     FilledButton(
                       onPressed: () => _loadGroups(),
                       child: const Text('Retry'),
                     ),
                   ],
                 ),
               ),
             );
          }

          if (groupProvider.groups.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.group_add_outlined,
                    size: 80,
                    color: colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppConstants.noGroups,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => _navigateToCreateGroup(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Group'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadGroups(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: groupProvider.groups.length,
              itemBuilder: (context, index) {
                final group = groupProvider.groups[index];
                return GroupCard(
                  group: group,
                  onTap: () {
                    groupProvider.selectGroup(group);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroupDetailScreen(group: group),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreateGroup(context),
        icon: const Icon(Icons.add),
        label: const Text('New Group'),
      ),
    );
  }

  void _navigateToCreateGroup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateGroupScreen(),
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<GroupProvider>().clearData();
      context.read<ExpenseProvider>().clearData();
      await context.read<AuthProvider>().signOut();
    }
  }
}

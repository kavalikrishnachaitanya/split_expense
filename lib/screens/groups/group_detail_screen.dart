import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:split_expense/models/group_model.dart';
import 'package:split_expense/models/user_model.dart';
import 'package:split_expense/providers/auth_provider.dart';
import 'package:split_expense/providers/expense_provider.dart';
import 'package:split_expense/providers/group_provider.dart';
import 'package:split_expense/services/firestore_service.dart';
import 'package:split_expense/utils/constants.dart';
import 'package:split_expense/utils/helpers.dart';
import 'package:split_expense/widgets/expense_tile.dart';
import 'package:split_expense/widgets/balance_summary.dart';
import 'package:split_expense/screens/expenses/add_expense_screen.dart';
import 'package:split_expense/widgets/user_avatar.dart';

class GroupDetailScreen extends StatefulWidget {
  final GroupModel group;

  const GroupDetailScreen({super.key, required this.group});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild to update FAB visibility
    });
    _loadExpenses();
  }

  void _loadExpenses() {
    context.read<ExpenseProvider>().loadGroupExpenses(widget.group.id);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddMemberDialog() {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Member'),
        content: TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'Enter member email',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (emailController.text.trim().isNotEmpty) {
                final groupProvider = context.read<GroupProvider>();
                final success = await groupProvider.addMemberByEmail(
                  widget.group.id,
                  emailController.text.trim(),
                );

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Member added successfully!'
                            : groupProvider.error ?? 'Failed to add member',
                      ),
                      backgroundColor:
                          success ? null : Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentUserId = context.read<AuthProvider>().user?.uid;
    final firestoreService = FirestoreService(); // Or inject via provider

    return StreamBuilder<GroupModel?>(
      stream: firestoreService.getGroupStream(widget.group.id),
      initialData: widget.group,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          // Group might have been deleted
          return Scaffold(
            appBar: AppBar(title: const Text('Unavailable')),
            body: const Center(child: Text('Group no longer resides here.')),
          );
        }

        final group = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: Text(group.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.person_add_outlined),
                onPressed: _showAddMemberDialog,
                tooltip: 'Add Member',
              ),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'delete') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Group'),
                        content: const Text(
                          'Are you sure you want to delete this group? This action cannot be undone.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: FilledButton.styleFrom(
                              backgroundColor: colorScheme.error,
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && mounted) {
                      final success = await context
                          .read<GroupProvider>()
                          .deleteGroup(group.id);
                      if (success && mounted) {
                        Navigator.pop(context); // Go back to home
                      }
                    }
                  } else if (value == 'leave') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Leave Group'),
                        content: const Text(
                          'Are you sure you want to leave this group?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: FilledButton.styleFrom(
                              backgroundColor: colorScheme.error,
                            ),
                            child: const Text('Leave'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && mounted) {
                      final success = await context
                          .read<GroupProvider>()
                          .removeMember(group.id, currentUserId!);
                      if (success && mounted) {
                        Navigator.pop(context); // Go back to home
                      }
                    }
                  }
                },
                itemBuilder: (BuildContext context) {
                  final isOwner = currentUserId == group.createdBy;
                  return [
                    if (isOwner)
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Text(
                          'Delete Group',
                          style: TextStyle(color: colorScheme.error),
                        ),
                      )
                    else
                      PopupMenuItem<String>(
                        value: 'leave',
                        child: Text(
                          'Leave Group',
                          style: TextStyle(color: colorScheme.error),
                        ),
                      ),
                  ];
                },
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Expenses'),
                Tab(text: 'Balances'),
                Tab(text: 'Members'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // Expenses Tab
              Consumer<ExpenseProvider>(
                builder: (context, expenseProvider, child) {
                  if (expenseProvider.error != null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                            const SizedBox(height: 16),
                            Text(
                              'Unable to load expenses',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              expenseProvider.error!, // This will show "Permission Denied" or "Missing Index"
                              style: TextStyle(color: colorScheme.error),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed: () => _loadExpenses(),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (expenseProvider.expenses.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 80,
                            color: colorScheme.primary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppConstants.noExpenses,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      _loadExpenses();
                      // Wait a bit to show the spinner, though the listener updates automatically
                      await Future.delayed(const Duration(seconds: 1));
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: expenseProvider.expenses.length,
                      itemBuilder: (context, index) {
                        final expense = expenseProvider.expenses[index];
                        return ExpenseTile(
                          expense: expense,
                          currentUserId: currentUserId ?? '',
                          onDelete: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Expense'),
                                content: const Text(
                                  'Are you sure you want to delete this expense?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  FilledButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              final success = await expenseProvider.deleteExpense(
                                expenseId: expense.id,
                                groupId: group.id,
                                groupMemberIds: group.memberIds,
                                performedBy: currentUserId ?? '',
                                performedByName: group.memberNames[currentUserId] ?? 'Unknown',
                              );

                              if (success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Expense deleted successfully'),
                                  ),
                                );
                              }
                            }
                          },
                        );
                      },
                    ),
                  );
                },
              ),

              // Balances Tab
              Consumer<ExpenseProvider>(
                builder: (context, expenseProvider, child) {
                    return BalanceSummary(
                      balances: expenseProvider.balances,
                      settlements: expenseProvider.settlements,
                      memberNames: group.memberNames,
                      currentUserId: currentUserId ?? '',
                      groupId: group.id,
                      expenses: expenseProvider.expenses,
                    );
                },
              ),

              // Members Tab
              // Use 'group' from snapshot, not provider
              Builder(
                builder: (context) {
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: group.memberIds.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final memberId = group.memberIds[index];
                      final memberName = group.memberNames[memberId] ?? 'Unknown';
                      final isCreator = memberId == group.createdBy;
                      final isCurrentUser = memberId == currentUserId;

                      return FutureBuilder<UserModel?>(
                        future: context.read<GroupProvider>().getUserDetails(memberId),
                        builder: (context, snapshot) {
                          final user = snapshot.data;
                          final email = user?.email ?? 'Loading...';
                          final displayName = user?.displayName ?? memberName;
                          
                          return Container(
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.shadow.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: UserAvatar(
                                photoUrl: user?.photoUrl,
                                displayName: displayName,
                              ),
                              title: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      displayName,
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isCurrentUser) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primaryContainer,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'You',
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                              color: colorScheme.onPrimaryContainer,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(email, style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                                  if (isCreator)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.star_rounded, size: 14, color: colorScheme.primary),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Group Owner',
                                            style: TextStyle(
                                              color: colorScheme.primary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              trailing: (currentUserId == group.createdBy && !isCurrentUser)
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.person_remove_rounded,
                                        color: colorScheme.error,
                                      ),
                                      tooltip: 'Remove Member',
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Remove Member'),
                                            content: Text(
                                              'Are you sure you want to remove $displayName from the group?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context, false),
                                                child: const Text('Cancel'),
                                              ),
                                              FilledButton(
                                                onPressed: () =>
                                                    Navigator.pop(context, true),
                                                style: FilledButton.styleFrom(
                                                  backgroundColor:
                                                      colorScheme.error,
                                                ),
                                                child: const Text('Remove'),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirm == true && context.mounted) {
                                          final success = await context
                                              .read<GroupProvider>()
                                              .removeMember(
                                                  group.id, memberId);
                                          
                                          if (success && context.mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Member removed successfully'),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                    )
                                  : null,
                            ),
                          );
                        }
                      );
                    },
                  );
                },
              ),
            ],
          ),
          floatingActionButton: _tabController.index == 0
              ? FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddExpenseScreen(group: group),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Expense'),
                )
              : null,
        );
      },
    );
  }
}

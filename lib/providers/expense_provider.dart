import 'package:flutter/material.dart';
import 'package:split_expense/models/expense_model.dart';

import 'package:split_expense/services/firestore_service.dart';
import 'package:split_expense/utils/helpers.dart';
import 'dart:async';

/// Provider for expense management
class ExpenseProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  StreamSubscription? _expensesSubscription;

  List<ExpenseModel> _expenses = [];
  Map<String, double> _balances = {};
  List<Map<String, dynamic>> _settlements = [];
  bool _isLoading = false;
  String? _error;

  List<ExpenseModel> get expenses => _expenses;
  Map<String, double> get balances => _balances;
  List<Map<String, dynamic>> get settlements => _settlements;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load expenses for a group
  void loadGroupExpenses(String groupId) {
    _expensesSubscription?.cancel();
    _expenses = []; // Clear old data immediately
    _balances = {};
    _settlements = [];
    notifyListeners();

    _expensesSubscription = _firestoreService.getGroupExpenses(groupId).listen(
      (expenses) {
        _expenses = expenses;
        _calculateBalances();
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  /// Calculate balances for current group
  void _calculateBalances() {
    try {
      _balances = _firestoreService.calculateBalances(_expenses);
      _settlements = _firestoreService.calculateSettlements(_expenses);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  /// Add a new expense
  Future<String?> addExpense({
    required String groupId,
    required String description,
    required double amount,
    required String paidBy,
    required String paidByName,
    required List<String> splitAmongIds,
    required Map<String, String> memberNames,
    required List<String> groupMemberIds,
    bool isSettlement = false,
  }) async {
    _setLoading(true);
    _error = null;

    // Calculate equal split
    final splitAmount = amount / splitAmongIds.length;
    final splitAmong = <String, double>{};
    for (final userId in splitAmongIds) {
      splitAmong[userId] = splitAmount;
    }

    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    final expense = ExpenseModel(
      id: tempId, // Temporary ID
      groupId: groupId,
      description: description,
      amount: amount,
      paidBy: paidBy,
      paidByName: paidByName,
      splitAmong: splitAmong,
      createdAt: DateTime.now(),
      isSettlement: isSettlement,
    );

    // Optimistic Update: Add locally first
    final previousExpenses = List<ExpenseModel>.from(_expenses);
    _expenses.insert(0, expense); // Add to top
    _calculateBalances();
    notifyListeners();

    try {
      final expenseId = await _firestoreService.addExpense(expense);
      
      // Update the ID of the optimistically added expense
      final index = _expenses.indexWhere((e) => e.id == tempId);
      if (index != -1) {
        _expenses[index] = ExpenseModel(
          id: expenseId,
          groupId: groupId,
          description: description,
          amount: amount,
          paidBy: paidBy,
          paidByName: paidByName,
          splitAmong: splitAmong,
          createdAt: expense.createdAt,
          isSettlement: isSettlement,
        );
      }

      _setLoading(false);
      return expenseId;
    } catch (e) {
      // Revert if failed
      _expenses = previousExpenses;
      _calculateBalances();
      
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return null;
    }
  }

  /// Delete an expense
  Future<bool> deleteExpense({
    required String expenseId,
    required String groupId,
    required List<String> groupMemberIds,
    required String performedBy,
    required String performedByName,
  }) async {
    _setLoading(true);
    _error = null;

    // Optimistic Update: Remove locally first
    final previousExpenses = List<ExpenseModel>.from(_expenses);
    final deletedExpense = _expenses.firstWhere((e) => e.id == expenseId,
        orElse: () => previousExpenses.first); // Graceful fallback
    _expenses.removeWhere((e) => e.id == expenseId);
    _calculateBalances();
    notifyListeners();

    try {
      await _firestoreService.deleteExpense(expenseId);

      _setLoading(false);
      return true;
    } catch (e) {
      // Revert if failed
      _expenses = previousExpenses;
      _calculateBalances();
      
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// Clear expenses (when leaving a group)
  void clearData() {
    _expensesSubscription?.cancel();
    _expenses = [];
    _balances = {};
    _settlements = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _expensesSubscription?.cancel();
    super.dispose();
  }
}

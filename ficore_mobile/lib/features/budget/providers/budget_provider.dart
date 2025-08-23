import 'package:flutter/foundation.dart';

import '../../../core/config/app_config.dart';
import '../../../core/models/api_response.dart';
import '../../../core/services/api_service.dart';
import '../models/budget_model.dart';

enum BudgetState {
  initial,
  loading,
  loaded,
  error,
}

class BudgetProvider extends ChangeNotifier {
  final ApiService _apiService;

  BudgetProvider(this._apiService);

  BudgetState _state = BudgetState.initial;
  List<Budget> _budgets = [];
  Budget? _currentBudget;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  BudgetState get state => _state;
  List<Budget> get budgets => List.unmodifiable(_budgets);
  Budget? get currentBudget => _currentBudget;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get hasBudgets => _budgets.isNotEmpty;
  Budget? get latestBudget => _budgets.isNotEmpty ? _budgets.first : null;

  // Load all budgets
  Future<void> loadBudgets() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.get<List<dynamic>>(
        AppConfig.budgetEndpoint,
        fromJson: (data) => data as List<dynamic>,
      );

      if (response.isSuccess && response.data != null) {
        _budgets = response.data!
            .map((json) => Budget.fromJson(json as Map<String, dynamic>))
            .toList();
        
        // Sort by creation date (newest first)
        _budgets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        
        _setState(BudgetState.loaded);
      } else {
        _setError(response.errorMessage);
      }
    } catch (e) {
      _setError('Failed to load budgets: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Load a specific budget
  Future<void> loadBudget(String budgetId) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '${AppConfig.budgetEndpoint}/$budgetId',
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.isSuccess && response.data != null) {
        _currentBudget = Budget.fromJson(response.data!);
        _setState(BudgetState.loaded);
      } else {
        _setError(response.errorMessage);
      }
    } catch (e) {
      _setError('Failed to load budget: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Create a new budget
  Future<bool> createBudget(BudgetRequest budgetRequest) async {
    _setLoading(true);
    _clearError();

    try {
      // Validate request
      if (!budgetRequest.isValid) {
        _setError(budgetRequest.validationErrors.join(', '));
        return false;
      }

      final response = await _apiService.post<Map<String, dynamic>>(
        AppConfig.budgetNewEndpoint,
        data: {
          'action': 'create_budget',
          ...budgetRequest.toJson(),
        },
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.isSuccess) {
        // Reload budgets to get the updated list
        await loadBudgets();
        return true;
      } else {
        _setError(response.errorMessage);
        return false;
      }
    } catch (e) {
      _setError('Failed to create budget: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update an existing budget
  Future<bool> updateBudget(String budgetId, BudgetRequest budgetRequest) async {
    _setLoading(true);
    _clearError();

    try {
      // Validate request
      if (!budgetRequest.isValid) {
        _setError(budgetRequest.validationErrors.join(', '));
        return false;
      }

      final response = await _apiService.put<Map<String, dynamic>>(
        '${AppConfig.budgetEndpoint}/$budgetId',
        data: budgetRequest.toJson(),
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.isSuccess && response.data != null) {
        final updatedBudget = Budget.fromJson(response.data!);
        
        // Update the budget in the list
        final index = _budgets.indexWhere((b) => b.id == budgetId);
        if (index != -1) {
          _budgets[index] = updatedBudget;
        }
        
        // Update current budget if it's the same one
        if (_currentBudget?.id == budgetId) {
          _currentBudget = updatedBudget;
        }
        
        notifyListeners();
        return true;
      } else {
        _setError(response.errorMessage);
        return false;
      }
    } catch (e) {
      _setError('Failed to update budget: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete a budget
  Future<bool> deleteBudget(String budgetId) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.delete<void>(
        '${AppConfig.budgetEndpoint}/$budgetId',
      );

      if (response.isSuccess) {
        // Remove from local list
        _budgets.removeWhere((budget) => budget.id == budgetId);
        
        // Clear current budget if it was deleted
        if (_currentBudget?.id == budgetId) {
          _currentBudget = null;
        }
        
        notifyListeners();
        return true;
      } else {
        _setError(response.errorMessage);
        return false;
      }
    } catch (e) {
      _setError('Failed to delete budget: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get budget statistics
  Map<String, dynamic> getBudgetStatistics() {
    if (_budgets.isEmpty) {
      return {
        'totalBudgets': 0,
        'averageIncome': 0.0,
        'averageExpenses': 0.0,
        'averageSurplus': 0.0,
        'budgetsWithSurplus': 0,
        'budgetsWithDeficit': 0,
      };
    }

    final totalBudgets = _budgets.length;
    final totalIncome = _budgets.fold(0.0, (sum, budget) => sum + budget.income);
    final totalExpenses = _budgets.fold(0.0, (sum, budget) => sum + budget.totalExpenses);
    final totalSurplus = _budgets.fold(0.0, (sum, budget) => sum + budget.surplusDeficit);
    final budgetsWithSurplus = _budgets.where((budget) => budget.hasSurplus).length;
    final budgetsWithDeficit = _budgets.where((budget) => budget.hasDeficit).length;

    return {
      'totalBudgets': totalBudgets,
      'averageIncome': totalIncome / totalBudgets,
      'averageExpenses': totalExpenses / totalBudgets,
      'averageSurplus': totalSurplus / totalBudgets,
      'budgetsWithSurplus': budgetsWithSurplus,
      'budgetsWithDeficit': budgetsWithDeficit,
    };
  }

  // Get expense trends (for charts)
  List<Map<String, dynamic>> getExpenseTrends() {
    return _budgets.map((budget) {
      return {
        'date': budget.createdAt,
        'income': budget.income,
        'expenses': budget.totalExpenses,
        'surplus': budget.surplusDeficit,
      };
    }).toList();
  }

  // Get category breakdown for the latest budget
  Map<String, double> getCategoryBreakdown() {
    if (latestBudget == null) return {};
    return latestBudget!.expenseBreakdown;
  }

  // Search budgets
  List<Budget> searchBudgets(String query) {
    if (query.isEmpty) return _budgets;
    
    final lowercaseQuery = query.toLowerCase();
    return _budgets.where((budget) {
      // Search in custom category names
      final categoryNames = budget.customCategories
          .map((category) => category.name.toLowerCase())
          .join(' ');
      
      return categoryNames.contains(lowercaseQuery) ||
             budget.income.toString().contains(query) ||
             budget.totalExpenses.toString().contains(query);
    }).toList();
  }

  // Filter budgets by date range
  List<Budget> filterBudgetsByDateRange(DateTime startDate, DateTime endDate) {
    return _budgets.where((budget) {
      return budget.createdAt.isAfter(startDate) && 
             budget.createdAt.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  // Filter budgets by surplus/deficit
  List<Budget> filterBudgetsBySurplus({bool? hasSurplus}) {
    if (hasSurplus == null) return _budgets;
    
    return _budgets.where((budget) {
      return hasSurplus ? budget.hasSurplus : budget.hasDeficit;
    }).toList();
  }

  // Set current budget
  void setCurrentBudget(Budget budget) {
    _currentBudget = budget;
    notifyListeners();
  }

  // Clear current budget
  void clearCurrentBudget() {
    _currentBudget = null;
    notifyListeners();
  }

  // Refresh data
  Future<void> refresh() async {
    await loadBudgets();
  }

  // Private helper methods
  void _setState(BudgetState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _state = BudgetState.error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    if (_state == BudgetState.error) {
      _state = _budgets.isNotEmpty ? BudgetState.loaded : BudgetState.initial;
    }
    notifyListeners();
  }

  // Clear error manually
  void clearError() {
    _clearError();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
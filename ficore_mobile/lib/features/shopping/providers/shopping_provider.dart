import 'package:flutter/foundation.dart';

import '../../../core/config/app_config.dart';
import '../../../core/models/api_response.dart';
import '../../../core/services/api_service.dart';
import '../models/shopping_model.dart';

enum ShoppingState {
  initial,
  loading,
  loaded,
  error,
}

class ShoppingProvider extends ChangeNotifier {
  final ApiService _apiService;

  ShoppingProvider(this._apiService);

  ShoppingState _state = ShoppingState.initial;
  List<ShoppingList> _shoppingLists = [];
  List<ShoppingItem> _currentItems = [];
  ShoppingList? _currentList;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  ShoppingState get state => _state;
  List<ShoppingList> get shoppingLists => List.unmodifiable(_shoppingLists);
  List<ShoppingItem> get currentItems => List.unmodifiable(_currentItems);
  ShoppingList? get currentList => _currentList;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get hasLists => _shoppingLists.isNotEmpty;

  // Load all shopping lists
  Future<void> loadShoppingLists() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.get<List<dynamic>>(
        AppConfig.shoppingEndpoint,
        fromJson: (data) => data as List<dynamic>,
      );

      if (response.isSuccess && response.data != null) {
        _shoppingLists = response.data!
            .map((json) => ShoppingList.fromJson(json as Map<String, dynamic>))
            .toList();
        
        // Sort by updated date (newest first)
        _shoppingLists.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        
        _setState(ShoppingState.loaded);
      } else {
        _setError(response.errorMessage);
      }
    } catch (e) {
      _setError('Failed to load shopping lists: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Load items for a specific list
  Future<void> loadListItems(String listId) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.get<List<dynamic>>(
        '${AppConfig.shoppingEndpoint}/$listId/items',
        fromJson: (data) => data as List<dynamic>,
      );

      if (response.isSuccess && response.data != null) {
        _currentItems = response.data!
            .map((json) => ShoppingItem.fromJson(json as Map<String, dynamic>))
            .toList();
        
        // Sort by creation date
        _currentItems.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        
        _setState(ShoppingState.loaded);
      } else {
        _setError(response.errorMessage);
      }
    } catch (e) {
      _setError('Failed to load list items: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Create a new shopping list
  Future<bool> createShoppingList(Map<String, dynamic> listData) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        AppConfig.shoppingNewEndpoint,
        data: {
          'action': 'create_list',
          ...listData,
        },
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.isSuccess) {
        // Reload lists to get the updated list
        await loadShoppingLists();
        return true;
      } else {
        _setError(response.errorMessage);
        return false;
      }
    } catch (e) {
      _setError('Failed to create shopping list: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Add item to shopping list
  Future<bool> addItemToList(String listId, Map<String, dynamic> itemData) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '${AppConfig.shoppingEndpoint}/$listId/items',
        data: itemData,
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.isSuccess) {
        // Reload items for the current list
        if (_currentList?.id == listId) {
          await loadListItems(listId);
        }
        return true;
      } else {
        _setError(response.errorMessage);
        return false;
      }
    } catch (e) {
      _setError('Failed to add item: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update item status (mark as bought/to buy)
  Future<bool> updateItemStatus(String itemId, String newStatus) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.put<Map<String, dynamic>>(
        '${AppConfig.shoppingEndpoint}/items/$itemId',
        data: {'status': newStatus},
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.isSuccess && response.data != null) {
        final updatedItem = ShoppingItem.fromJson(response.data!);
        
        // Update the item in the current list
        final index = _currentItems.indexWhere((item) => item.id == itemId);
        if (index != -1) {
          _currentItems[index] = updatedItem;
        }
        
        notifyListeners();
        return true;
      } else {
        _setError(response.errorMessage);
        return false;
      }
    } catch (e) {
      _setError('Failed to update item: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete shopping list
  Future<bool> deleteShoppingList(String listId) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.delete<void>(
        '${AppConfig.shoppingEndpoint}/$listId',
      );

      if (response.isSuccess) {
        // Remove from local list
        _shoppingLists.removeWhere((list) => list.id == listId);
        
        // Clear current list if it was deleted
        if (_currentList?.id == listId) {
          _currentList = null;
          _currentItems.clear();
        }
        
        notifyListeners();
        return true;
      } else {
        _setError(response.errorMessage);
        return false;
      }
    } catch (e) {
      _setError('Failed to delete shopping list: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete shopping item
  Future<bool> deleteShoppingItem(String itemId) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.delete<void>(
        '${AppConfig.shoppingEndpoint}/items/$itemId',
      );

      if (response.isSuccess) {
        // Remove from current items
        _currentItems.removeWhere((item) => item.id == itemId);
        notifyListeners();
        return true;
      } else {
        _setError(response.errorMessage);
        return false;
      }
    } catch (e) {
      _setError('Failed to delete item: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get shopping statistics
  Map<String, dynamic> getShoppingStatistics() {
    if (_shoppingLists.isEmpty) {
      return {
        'totalLists': 0,
        'activeLists': 0,
        'totalBudget': 0.0,
        'totalSpent': 0.0,
        'averageBudget': 0.0,
        'listsOverBudget': 0,
      };
    }

    final activeLists = _shoppingLists.where((list) => list.isActive).length;
    final totalBudget = _shoppingLists.fold(0.0, (sum, list) => sum + list.budget);
    final totalSpent = _shoppingLists.fold(0.0, (sum, list) => sum + list.totalSpent);
    final listsOverBudget = _shoppingLists.where((list) => list.isOverBudget).length;

    return {
      'totalLists': _shoppingLists.length,
      'activeLists': activeLists,
      'totalBudget': totalBudget,
      'totalSpent': totalSpent,
      'averageBudget': totalBudget / _shoppingLists.length,
      'listsOverBudget': listsOverBudget,
    };
  }

  // Search shopping lists
  List<ShoppingList> searchShoppingLists(String query) {
    if (query.isEmpty) return _shoppingLists;
    
    final lowercaseQuery = query.toLowerCase();
    return _shoppingLists.where((list) {
      return list.name.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Search items in current list
  List<ShoppingItem> searchItems(String query) {
    if (query.isEmpty) return _currentItems;
    
    final lowercaseQuery = query.toLowerCase();
    return _currentItems.where((item) {
      return item.name.toLowerCase().contains(lowercaseQuery) ||
             item.category.toLowerCase().contains(lowercaseQuery) ||
             (item.store?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  // Filter items by status
  List<ShoppingItem> filterItemsByStatus(String status) {
    return _currentItems.where((item) => item.status == status).toList();
  }

  // Filter items by category
  List<ShoppingItem> filterItemsByCategory(String category) {
    return _currentItems.where((item) => item.category == category).toList();
  }

  // Set current shopping list
  void setCurrentList(ShoppingList list) {
    _currentList = list;
    notifyListeners();
  }

  // Clear current list
  void clearCurrentList() {
    _currentList = null;
    _currentItems.clear();
    notifyListeners();
  }

  // Refresh data
  Future<void> refresh() async {
    await loadShoppingLists();
  }

  // Private helper methods
  void _setState(ShoppingState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _state = ShoppingState.error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    if (_state == ShoppingState.error) {
      _state = _shoppingLists.isNotEmpty ? ShoppingState.loaded : ShoppingState.initial;
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
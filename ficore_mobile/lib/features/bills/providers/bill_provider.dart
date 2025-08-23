import 'package:flutter/foundation.dart';

import '../../../core/config/app_config.dart';
import '../../../core/models/api_response.dart';
import '../../../core/services/api_service.dart';
import '../models/bill_model.dart';

enum BillState {
  initial,
  loading,
  loaded,
  error,
}

class BillProvider extends ChangeNotifier {
  final ApiService _apiService;

  BillProvider(this._apiService);

  BillState _state = BillState.initial;
  List<Bill> _bills = [];
  Bill? _currentBill;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  BillState get state => _state;
  List<Bill> get bills => List.unmodifiable(_bills);
  Bill? get currentBill => _currentBill;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get hasBills => _bills.isNotEmpty;

  // Filtered lists
  List<Bill> get pendingBills => _bills.where((bill) => bill.isPending).toList();
  List<Bill> get paidBills => _bills.where((bill) => bill.isPaid).toList();
  List<Bill> get overdueBills => _bills.where((bill) => bill.isOverdue).toList();
  List<Bill> get upcomingBills => _bills.where((bill) => bill.isDueThisWeek && !bill.isOverdue).toList();

  // Load all bills
  Future<void> loadBills() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.get<List<dynamic>>(
        AppConfig.billEndpoint,
        fromJson: (data) => data as List<dynamic>,
      );

      if (response.isSuccess && response.data != null) {
        _bills = response.data!
            .map((json) => Bill.fromJson(json as Map<String, dynamic>))
            .toList();
        
        // Sort by due date
        _bills.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        
        _setState(BillState.loaded);
      } else {
        _setError(response.errorMessage);
      }
    } catch (e) {
      _setError('Failed to load bills: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Create a new bill
  Future<bool> createBill(Map<String, dynamic> billData) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        AppConfig.billNewEndpoint,
        data: {
          'action': 'add_bill',
          ...billData,
        },
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.isSuccess) {
        // Reload bills to get the updated list
        await loadBills();
        return true;
      } else {
        _setError(response.errorMessage);
        return false;
      }
    } catch (e) {
      _setError('Failed to create bill: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update bill status
  Future<bool> updateBillStatus(String billId, String newStatus) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.put<Map<String, dynamic>>(
        '${AppConfig.billEndpoint}/$billId',
        data: {'status': newStatus},
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.isSuccess && response.data != null) {
        final updatedBill = Bill.fromJson(response.data!);
        
        // Update the bill in the list
        final index = _bills.indexWhere((b) => b.id == billId);
        if (index != -1) {
          _bills[index] = updatedBill;
        }
        
        // Update current bill if it's the same one
        if (_currentBill?.id == billId) {
          _currentBill = updatedBill;
        }
        
        notifyListeners();
        return true;
      } else {
        _setError(response.errorMessage);
        return false;
      }
    } catch (e) {
      _setError('Failed to update bill: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete a bill
  Future<bool> deleteBill(String billId) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.delete<void>(
        '${AppConfig.billEndpoint}/$billId',
      );

      if (response.isSuccess) {
        // Remove from local list
        _bills.removeWhere((bill) => bill.id == billId);
        
        // Clear current bill if it was deleted
        if (_currentBill?.id == billId) {
          _currentBill = null;
        }
        
        notifyListeners();
        return true;
      } else {
        _setError(response.errorMessage);
        return false;
      }
    } catch (e) {
      _setError('Failed to delete bill: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get bill statistics
  Map<String, dynamic> getBillStatistics() {
    if (_bills.isEmpty) {
      return {
        'totalBills': 0,
        'pendingBills': 0,
        'paidBills': 0,
        'overdueBills': 0,
        'totalAmount': 0.0,
        'pendingAmount': 0.0,
        'paidAmount': 0.0,
        'overdueAmount': 0.0,
      };
    }

    final totalAmount = _bills.fold(0.0, (sum, bill) => sum + bill.amount);
    final pendingAmount = pendingBills.fold(0.0, (sum, bill) => sum + bill.amount);
    final paidAmount = paidBills.fold(0.0, (sum, bill) => sum + bill.amount);
    final overdueAmount = overdueBills.fold(0.0, (sum, bill) => sum + bill.amount);

    return {
      'totalBills': _bills.length,
      'pendingBills': pendingBills.length,
      'paidBills': paidBills.length,
      'overdueBills': overdueBills.length,
      'totalAmount': totalAmount,
      'pendingAmount': pendingAmount,
      'paidAmount': paidAmount,
      'overdueAmount': overdueAmount,
    };
  }

  // Search bills
  List<Bill> searchBills(String query) {
    if (query.isEmpty) return _bills;
    
    final lowercaseQuery = query.toLowerCase();
    return _bills.where((bill) {
      return bill.billName.toLowerCase().contains(lowercaseQuery) ||
             bill.category.toLowerCase().contains(lowercaseQuery) ||
             bill.amount.toString().contains(query);
    }).toList();
  }

  // Filter bills by status
  List<Bill> filterBillsByStatus(String status) {
    return _bills.where((bill) => bill.status == status).toList();
  }

  // Filter bills by category
  List<Bill> filterBillsByCategory(String category) {
    return _bills.where((bill) => bill.category == category).toList();
  }

  // Set current bill
  void setCurrentBill(Bill bill) {
    _currentBill = bill;
    notifyListeners();
  }

  // Clear current bill
  void clearCurrentBill() {
    _currentBill = null;
    notifyListeners();
  }

  // Refresh data
  Future<void> refresh() async {
    await loadBills();
  }

  // Private helper methods
  void _setState(BillState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _state = BillState.error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    if (_state == BillState.error) {
      _state = _bills.isNotEmpty ? BillState.loaded : BillState.initial;
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
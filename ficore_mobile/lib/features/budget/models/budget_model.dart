import 'package:json_annotation/json_annotation.dart';

part 'budget_model.g.dart';

@JsonSerializable()
class Budget {
  @JsonKey(name: '_id')
  final String id;
  
  @JsonKey(name: 'user_id')
  final String userId;
  
  @JsonKey(name: 'session_id')
  final String? sessionId;
  
  final double income;
  
  @JsonKey(name: 'fixed_expenses')
  final double fixedExpenses;
  
  @JsonKey(name: 'variable_expenses')
  final double variableExpenses;
  
  @JsonKey(name: 'savings_goal')
  final double savingsGoal;
  
  @JsonKey(name: 'surplus_deficit')
  final double surplusDeficit;
  
  final double housing;
  final double food;
  final double transport;
  final int dependents;
  final double miscellaneous;
  final double others;
  
  @JsonKey(name: 'custom_categories')
  final List<CustomCategory> customCategories;
  
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const Budget({
    required this.id,
    required this.userId,
    this.sessionId,
    required this.income,
    required this.fixedExpenses,
    required this.variableExpenses,
    required this.savingsGoal,
    required this.surplusDeficit,
    required this.housing,
    required this.food,
    required this.transport,
    required this.dependents,
    required this.miscellaneous,
    required this.others,
    required this.customCategories,
    required this.createdAt,
  });

  factory Budget.fromJson(Map<String, dynamic> json) => _$BudgetFromJson(json);
  
  Map<String, dynamic> toJson() => _$BudgetToJson(this);

  Budget copyWith({
    String? id,
    String? userId,
    String? sessionId,
    double? income,
    double? fixedExpenses,
    double? variableExpenses,
    double? savingsGoal,
    double? surplusDeficit,
    double? housing,
    double? food,
    double? transport,
    int? dependents,
    double? miscellaneous,
    double? others,
    List<CustomCategory>? customCategories,
    DateTime? createdAt,
  }) {
    return Budget(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
      income: income ?? this.income,
      fixedExpenses: fixedExpenses ?? this.fixedExpenses,
      variableExpenses: variableExpenses ?? this.variableExpenses,
      savingsGoal: savingsGoal ?? this.savingsGoal,
      surplusDeficit: surplusDeficit ?? this.surplusDeficit,
      housing: housing ?? this.housing,
      food: food ?? this.food,
      transport: transport ?? this.transport,
      dependents: dependents ?? this.dependents,
      miscellaneous: miscellaneous ?? this.miscellaneous,
      others: others ?? this.others,
      customCategories: customCategories ?? this.customCategories,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Calculated properties
  double get totalExpenses => fixedExpenses + variableExpenses;
  
  double get totalFixedExpenses => housing + food + transport + miscellaneous + others;
  
  double get totalCustomExpenses => customCategories.fold(0.0, (sum, category) => sum + category.amount);
  
  bool get hasSurplus => surplusDeficit > 0;
  
  bool get hasDeficit => surplusDeficit < 0;
  
  bool get isBalanced => surplusDeficit == 0;
  
  double get savingsRate => income > 0 ? (savingsGoal / income) * 100 : 0;
  
  double get expenseRate => income > 0 ? (totalExpenses / income) * 100 : 0;

  // Get expense breakdown for charts
  Map<String, double> get expenseBreakdown {
    final breakdown = <String, double>{
      'Housing': housing,
      'Food': food,
      'Transport': transport,
      'Miscellaneous': miscellaneous,
      'Others': others,
    };
    
    // Add custom categories
    for (final category in customCategories) {
      breakdown[category.name] = category.amount;
    }
    
    // Remove zero values
    breakdown.removeWhere((key, value) => value <= 0);
    
    return breakdown;
  }

  // Get category color for charts
  static Map<String, String> get categoryColors {
    return {
      'Housing': '#FF6B6B',
      'Food': '#4ECDC4',
      'Transport': '#45B7D1',
      'Miscellaneous': '#96CEB4',
      'Others': '#FFEAA7',
      // Custom categories will use a rotating set of colors
    };
  }

  @override
  String toString() {
    return 'Budget(id: $id, income: $income, totalExpenses: $totalExpenses, surplusDeficit: $surplusDeficit)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Budget && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

@JsonSerializable()
class CustomCategory {
  final String name;
  final double amount;

  const CustomCategory({
    required this.name,
    required this.amount,
  });

  factory CustomCategory.fromJson(Map<String, dynamic> json) => _$CustomCategoryFromJson(json);
  
  Map<String, dynamic> toJson() => _$CustomCategoryToJson(this);

  CustomCategory copyWith({
    String? name,
    double? amount,
  }) {
    return CustomCategory(
      name: name ?? this.name,
      amount: amount ?? this.amount,
    );
  }

  @override
  String toString() {
    return 'CustomCategory(name: $name, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CustomCategory && 
           other.name == name && 
           other.amount == amount;
  }

  @override
  int get hashCode => name.hashCode ^ amount.hashCode;
}

// Budget creation/update request model
@JsonSerializable()
class BudgetRequest {
  final double income;
  final double housing;
  final double food;
  final double transport;
  final int dependents;
  final double miscellaneous;
  final double others;
  @JsonKey(name: 'savings_goal')
  final double savingsGoal;
  @JsonKey(name: 'custom_categories')
  final List<CustomCategory> customCategories;

  const BudgetRequest({
    required this.income,
    required this.housing,
    required this.food,
    required this.transport,
    required this.dependents,
    required this.miscellaneous,
    required this.others,
    required this.savingsGoal,
    required this.customCategories,
  });

  factory BudgetRequest.fromJson(Map<String, dynamic> json) => _$BudgetRequestFromJson(json);
  
  Map<String, dynamic> toJson() => _$BudgetRequestToJson(this);

  // Calculate derived values
  double get fixedExpenses => housing + food + transport + miscellaneous + others;
  double get variableExpenses => customCategories.fold(0.0, (sum, category) => sum + category.amount);
  double get totalExpenses => fixedExpenses + variableExpenses;
  double get surplusDeficit => income - totalExpenses;

  // Validation
  bool get isValid {
    return income > 0 && 
           housing >= 0 && 
           food >= 0 && 
           transport >= 0 && 
           dependents >= 0 && 
           miscellaneous >= 0 && 
           others >= 0 && 
           savingsGoal >= 0 &&
           customCategories.every((category) => 
             category.name.isNotEmpty && category.amount >= 0);
  }

  List<String> get validationErrors {
    final errors = <String>[];
    
    if (income <= 0) errors.add('Income must be greater than 0');
    if (housing < 0) errors.add('Housing amount cannot be negative');
    if (food < 0) errors.add('Food amount cannot be negative');
    if (transport < 0) errors.add('Transport amount cannot be negative');
    if (dependents < 0) errors.add('Number of dependents cannot be negative');
    if (miscellaneous < 0) errors.add('Miscellaneous amount cannot be negative');
    if (others < 0) errors.add('Others amount cannot be negative');
    if (savingsGoal < 0) errors.add('Savings goal cannot be negative');
    
    for (int i = 0; i < customCategories.length; i++) {
      final category = customCategories[i];
      if (category.name.isEmpty) {
        errors.add('Custom category ${i + 1} name cannot be empty');
      }
      if (category.amount < 0) {
        errors.add('Custom category ${i + 1} amount cannot be negative');
      }
    }
    
    // Check for duplicate category names
    final categoryNames = customCategories.map((c) => c.name.toLowerCase()).toList();
    final uniqueNames = categoryNames.toSet();
    if (categoryNames.length != uniqueNames.length) {
      errors.add('Custom category names must be unique');
    }
    
    return errors;
  }
}
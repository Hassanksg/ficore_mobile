import 'package:json_annotation/json_annotation.dart';

part 'shopping_model.g.dart';

@JsonSerializable()
class ShoppingList {
  @JsonKey(name: '_id')
  final String id;
  
  @JsonKey(name: 'user_id')
  final String userId;
  
  @JsonKey(name: 'session_id')
  final String? sessionId;
  
  final String name;
  final double budget;
  
  @JsonKey(name: 'total_spent')
  final double totalSpent;
  
  final String status;
  final List<String> collaborators;
  
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const ShoppingList({
    required this.id,
    required this.userId,
    this.sessionId,
    required this.name,
    required this.budget,
    required this.totalSpent,
    required this.status,
    required this.collaborators,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ShoppingList.fromJson(Map<String, dynamic> json) => _$ShoppingListFromJson(json);
  
  Map<String, dynamic> toJson() => _$ShoppingListToJson(this);

  // Computed properties
  double get remaining => budget - totalSpent;
  bool get isOverBudget => totalSpent > budget;
  bool get isActive => status == 'active';
  double get budgetUsagePercentage => budget > 0 ? (totalSpent / budget) * 100 : 0;

  ShoppingList copyWith({
    String? id,
    String? userId,
    String? sessionId,
    String? name,
    double? budget,
    double? totalSpent,
    String? status,
    List<String>? collaborators,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShoppingList(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
      name: name ?? this.name,
      budget: budget ?? this.budget,
      totalSpent: totalSpent ?? this.totalSpent,
      status: status ?? this.status,
      collaborators: collaborators ?? this.collaborators,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ShoppingList(id: $id, name: $name, budget: $budget, totalSpent: $totalSpent)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShoppingList && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

@JsonSerializable()
class ShoppingItem {
  @JsonKey(name: '_id')
  final String id;
  
  @JsonKey(name: 'user_id')
  final String userId;
  
  @JsonKey(name: 'session_id')
  final String? sessionId;
  
  @JsonKey(name: 'list_id')
  final String listId;
  
  final String name;
  final int quantity;
  final double price;
  final String category;
  final String status;
  final String unit;
  final String? store;
  final int frequency;
  
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const ShoppingItem({
    required this.id,
    required this.userId,
    this.sessionId,
    required this.listId,
    required this.name,
    required this.quantity,
    required this.price,
    required this.category,
    required this.status,
    required this.unit,
    this.store,
    required this.frequency,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ShoppingItem.fromJson(Map<String, dynamic> json) => _$ShoppingItemFromJson(json);
  
  Map<String, dynamic> toJson() => _$ShoppingItemToJson(this);

  // Computed properties
  double get totalPrice => quantity * price;
  bool get isBought => status == 'bought';
  bool get isToBuy => status == 'to_buy';

  ShoppingItem copyWith({
    String? id,
    String? userId,
    String? sessionId,
    String? listId,
    String? name,
    int? quantity,
    double? price,
    String? category,
    String? status,
    String? unit,
    String? store,
    int? frequency,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
      listId: listId ?? this.listId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      category: category ?? this.category,
      status: status ?? this.status,
      unit: unit ?? this.unit,
      store: store ?? this.store,
      frequency: frequency ?? this.frequency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ShoppingItem(id: $id, name: $name, quantity: $quantity, price: $price, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShoppingItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
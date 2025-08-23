import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class User {
  @JsonKey(name: '_id')
  final String id;
  
  final String email;
  
  @JsonKey(name: 'display_name')
  final String? displayName;
  
  final String role;
  
  @JsonKey(name: 'ficore_credit_balance')
  final double ficoreCreditBalance;
  
  final String? language;
  
  @JsonKey(name: 'dark_mode')
  final bool? darkMode;
  
  @JsonKey(name: 'is_admin')
  final bool isAdmin;
  
  @JsonKey(name: 'setup_complete')
  final bool setupComplete;
  
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  
  @JsonKey(name: 'first_name')
  final String? firstName;
  
  @JsonKey(name: 'last_name')
  final String? lastName;
  
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  
  final String? address;

  const User({
    required this.id,
    required this.email,
    this.displayName,
    required this.role,
    required this.ficoreCreditBalance,
    this.language,
    this.darkMode,
    required this.isAdmin,
    required this.setupComplete,
    this.createdAt,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.address,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? role,
    double? ficoreCreditBalance,
    String? language,
    bool? darkMode,
    bool? isAdmin,
    bool? setupComplete,
    DateTime? createdAt,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? address,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      ficoreCreditBalance: ficoreCreditBalance ?? this.ficoreCreditBalance,
      language: language ?? this.language,
      darkMode: darkMode ?? this.darkMode,
      isAdmin: isAdmin ?? this.isAdmin,
      setupComplete: setupComplete ?? this.setupComplete,
      createdAt: createdAt ?? this.createdAt,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
    );
  }

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return displayName ?? email.split('@').first;
  }

  String get initials {
    if (firstName != null && lastName != null) {
      return '${firstName!.substring(0, 1)}${lastName!.substring(0, 1)}';
    }
    final name = displayName ?? email.split('@').first;
    return name.length >= 2 ? name.substring(0, 2).toUpperCase() : name.toUpperCase();
  }

  bool get isPersonalUser => role == 'personal';
  bool get isAdminUser => role == 'admin' || isAdmin;

  @override
  String toString() {
    return 'User(id: $id, email: $email, role: $role, credits: $ficoreCreditBalance)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id && other.email == email;
  }

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}
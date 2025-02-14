import 'package:escapeberlin/backend/types/role.dart';

class Player {
  final String id;
  final String name;
  final String hideoutId;
  Role role;
  
  Player({
    required this.id,
    required this.name,
    required this.hideoutId,
    this.role = Role.refugee,
  });

  void updateRole(Role newRole) {
    role = newRole;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'hideoutId': hideoutId,
    'role': role.name,
  };
}
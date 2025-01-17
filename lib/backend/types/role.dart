enum Role {
  refugee,
  spy,
  smuggler,
  coordinator,
  counterfeiter,
  escapeHelper
}
extension RoleExtension on Role {
  String get name {
    switch (this) {
      case Role.refugee:
        return 'Flüchtling';
      case Role.spy:
        return 'Spitzel';
      case Role.smuggler:
        return 'Schmuggler';
      case Role.coordinator:
        return 'Koordinator';
      case Role.counterfeiter:
        return 'Fälscher';
      case Role.escapeHelper:
        return 'Fluchthelfer';
    }
  }
}
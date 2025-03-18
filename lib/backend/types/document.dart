class GameDocument {
  final String id;
  final String title;
  final String content;
  final String roleRequirement;
  final String sharedBy;  // Neues Feld für den teilenden Benutzer

  GameDocument({
    required this.id,
    this.title = '',
    this.content = '',
    this.roleRequirement = '',
    this.sharedBy = '',  // Standardwert für Abwärtskompatibilität
  });
}
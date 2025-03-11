class GameDocument {
  final String id;
  final String title;
  final String content;
  final String roleRequirement;

  GameDocument({
    required this.id,
    required this.title,
    required this.content,
    required this.roleRequirement,
  });

  factory GameDocument.fromJson(Map<String, dynamic> json) {
    return GameDocument(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      roleRequirement: json['roleRequirement'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'roleRequirement': roleRequirement,
    };
  }
}
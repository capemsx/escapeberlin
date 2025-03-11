class RoundObjective {
  final int roundNumber;
  final String title;
  final String description;

  RoundObjective({
    required this.roundNumber,
    required this.title,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'roundNumber': roundNumber,
      'title': title,
      'description': description,
    };
  }

  factory RoundObjective.fromJson(Map<String, dynamic> json) {
    return RoundObjective(
      roundNumber: json['roundNumber'],
      title: json['title'],
      description: json['description'],
    );
  }
}
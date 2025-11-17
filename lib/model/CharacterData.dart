class CharacterData {
  final int classCode;
  final String expr;
  final String imageUrl;
  final int jobCode;
  final int level;
  final int world;

  CharacterData({
    required this.classCode,
    required this.expr,
    required this.imageUrl,
    required this.jobCode,
    required this.level,
    required this.world,
  });

  factory CharacterData.fromJson(Map<String, dynamic> json) {
    return CharacterData(
      classCode: json['classCode'] ?? 0,
      expr: json['expr'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      jobCode: json['jobCode'] ?? 0,
      level: json['level'] ?? 0,
      world: json['world'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'classCode': classCode,
      'expr': expr,
      'imageUrl': imageUrl,
      'jobCode': jobCode,
      'level': level,
      'world': world,
    };
  }
}

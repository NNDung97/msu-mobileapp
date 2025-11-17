// lib/model/boss_model.dart (Đã Cập Nhật)

class BossReward {
  final String name;
  final String image;
  final int itemID;
  final String link;

  BossReward({
    required this.name,
    required this.image,
    required this.itemID,
    required this.link,
  });

  factory BossReward.fromJson(Map<String, dynamic> json) {
    return BossReward(
      name: json['name'] as String? ?? 'Unknown Reward',
      image: json['image'] as String? ?? '',
      itemID: json['itemID'] as int? ?? 0,
      link: json['link'] as String? ?? '',
    );
  }
}

class BossDifficulty {
  final String name;
  final int level;
  final int entryLevel;
  final String hp; // Thêm HP
  final String defense; // Thêm Defense
  final String resetType; // Thêm resetType
  final List<BossReward> rewards;

  BossDifficulty({
    required this.name,
    required this.level,
    required this.entryLevel,
    required this.hp, // Cập nhật Constructor
    required this.defense, // Cập nhật Constructor
    required this.resetType, // Cập nhật Constructor
    required this.rewards,
  });

  factory BossDifficulty.fromJson(Map<String, dynamic> json) {
    return BossDifficulty(
      name: json['name'] as String? ?? 'Unknown',
      level: json['level'] as int? ?? 0,
      entryLevel: json['entryLevel'] as int? ?? 0,
      hp: json['hp'] as String? ?? 'N/A', // Parse HP
      defense: json['defense'] as String? ?? 'N/A', // Parse Defense
      resetType: json['resetType'] as String? ?? 'N/A', // Parse Reset Type
      rewards: (json['rewards'] as List<dynamic>?)
              ?.map((r) => BossReward.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class Boss {
  final String id;
  final String name;
  final String type; // 'daily' or 'weekly'
  final String image;
  final List<BossDifficulty> difficulties;

  Boss({
    required this.id,
    required this.name,
    required this.type,
    required this.image,
    required this.difficulties,
  });

  factory Boss.fromJson(Map<String, dynamic> json) {
    return Boss(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown Boss',
      type: json['type'] as String? ?? 'Unknown',
      image: json['image'] as String? ?? '',
      difficulties: (json['difficulties'] as List<dynamic>?)
              ?.map(
                  (d) => BossDifficulty.fromJson(d as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class BossList {
  final List<Boss> daily;
  final List<Boss> weekly;

  BossList({required this.daily, required this.weekly});

  factory BossList.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};

    return BossList(
      daily: (data['daily'] as List<dynamic>?)
              ?.map((b) => Boss.fromJson(b as Map<String, dynamic>))
              .toList() ??
          [],
      weekly: (data['weekly'] as List<dynamic>?)
              ?.map((b) => Boss.fromJson(b as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
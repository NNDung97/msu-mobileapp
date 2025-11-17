import "CharacterData.dart";

class Character {
  final String assetKey;
  final int categoryNo;
  final CharacterData data;
  final String name;
  final String tokenId;

  Character({
    required this.assetKey,
    required this.categoryNo,
    required this.data,
    required this.name,
    required this.tokenId,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      assetKey: json['assetKey'] ?? '',
      categoryNo: json['categoryNo'] ?? 0,
      data: CharacterData.fromJson(json['data'] ?? {}),
      name: json['name'] ?? '',
      tokenId: json['tokenId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assetKey': assetKey,
      'categoryNo': categoryNo,
      'data': data.toJson(),
      'name': name,
      'tokenId': tokenId,
    };
  }
}

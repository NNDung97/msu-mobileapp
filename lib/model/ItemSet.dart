import 'dart:convert';

enum ViewType { NORMAL, IMAGE_EMBEDDED }

class ItemSet {
  final int? setId;
  final String? setName;
  final ViewType viewType;
  final List<SetPiece> pieces;
  final List<SetEffect> effects;

  ItemSet({
    required this.setId,
    required this.setName,
    this.viewType = ViewType.NORMAL,
    required this.pieces,
    required this.effects,
  });

  factory ItemSet.fromJson(Map<String, dynamic> json) => ItemSet(
        setId: json['setId'],
        setName: json['setName'],
        viewType: _viewTypeFromString(json['viewType']),
        pieces: json['pieces'] != null
            ? List<SetPiece>.from(
                json['pieces'].map((x) => SetPiece.fromJson(x)))
            : [],
        effects: json['effects'] != null
            ? List<SetEffect>.from(
                json['effects'].map((x) => SetEffect.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        'setId': setId,
        'setName': setName,
        'viewType': viewType.name,
        'pieces': pieces.map((x) => x.toJson()).toList(),
        'effects': effects.map((x) => x.toJson()).toList(),
      };

  static ViewType _viewTypeFromString(String? value) {
    switch (value) {
      case 'IMAGE_EMBEDDED':
        return ViewType.IMAGE_EMBEDDED;
      case 'NORMAL':
      default:
        return ViewType.NORMAL;
    }
  }
}

class SetPiece {
  final String representName;
  final String typeName;
  final int itemId;
  final List<SetPieceSubItem> subItems;
  final String imageUrl;

  SetPiece({
    required this.representName,
    required this.typeName,
    required this.itemId,
    required this.subItems,
    required this.imageUrl,
  });

  factory SetPiece.fromJson(Map<String, dynamic> json) => SetPiece(
        representName: json['representName'],
        typeName: json['typeName'],
        itemId: json['itemId'],
        subItems: json['subItems'] != null
            ? List<SetPieceSubItem>.from(
                json['subItems'].map((x) => SetPieceSubItem.fromJson(x)))
            : [],
        imageUrl: json['imageUrl'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'representName': representName,
        'typeName': typeName,
        'itemId': itemId,
        'subItems': subItems.map((x) => x.toJson()).toList(),
        'imageUrl': imageUrl,
      };
}

class SetPieceSubItem {
  final int itemId;
  final String itemName;

  SetPieceSubItem({
    required this.itemId,
    required this.itemName,
  });

  factory SetPieceSubItem.fromJson(Map<String, dynamic> json) =>
      SetPieceSubItem(
        itemId: json['itemId'],
        itemName: json['itemName'],
      );

  Map<String, dynamic> toJson() => {
        'itemId': itemId,
        'itemName': itemName,
      };
}

class SetEffect {
  final int equipCount;
  final List<String> desc;

  SetEffect({
    required this.equipCount,
    required this.desc,
  });

  factory SetEffect.fromJson(Map<String, dynamic> json) => SetEffect(
        equipCount: json['equipCount'],
        desc: json['desc'] != null
            ? List<String>.from(json['desc'])
            : [],
      );

  Map<String, dynamic> toJson() => {
        'equipCount': equipCount,
        'desc': desc,
      };
}

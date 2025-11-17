class ItemCommon {
  final int itemId;
  final String itemName;
  final bool enableStarforce;
  final bool enablePotential;
  final bool enableExtraOption;
  final int maxStarforce;
  final String desc;

  ItemCommon({
    required this.itemId,
    required this.itemName,
    required this.enableStarforce,
    required this.enablePotential,
    required this.enableExtraOption,
    required this.maxStarforce,
    required this.desc,
  });

  factory ItemCommon.fromJson(Map<String, dynamic> json) {
    return ItemCommon(
      itemId: json['itemId'] ?? 0,
      itemName: json['itemName'] ?? '',
      enableStarforce: json['enableStarforce'] ?? false,
      enablePotential: json['enablePotential'] ?? false,
      enableExtraOption: json['enableExtraOption'] ?? false,
      maxStarforce: json['maxStarforce'] ?? 0,
      desc: json['desc'] ?? '',
    );
  }
}

class ItemStatValue {
  final int base;
  final int enhance;
  final int extra;
  final int total;

  ItemStatValue({
    required this.base,
    required this.enhance,
    required this.extra,
    required this.total,
  });

  factory ItemStatValue.fromJson(Map<String, dynamic> json) {
    return ItemStatValue(
      base: json['base'] ?? 0,
      enhance: json['enhance'] ?? 0,
      extra: json['extra'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}

class ItemStats {
  final ItemStatValue str;
  final ItemStatValue dex;
  final ItemStatValue luk;
  final ItemStatValue int;
  final ItemStatValue pad;
  final ItemStatValue mad;
  final ItemStatValue pdd;
  final ItemStatValue maxHp;

  ItemStats({
    required this.str,
    required this.dex,
    required this.luk,
    required this.int,
    required this.pad,
    required this.mad,
    required this.pdd,
    required this.maxHp,
  });

  factory ItemStats.fromJson(Map<String, dynamic> json) {
    return ItemStats(
      str: ItemStatValue.fromJson(json['str'] ?? {}),
      dex: ItemStatValue.fromJson(json['dex'] ?? {}),
      luk: ItemStatValue.fromJson(json['luk'] ?? {}),
      int: ItemStatValue.fromJson(json['int'] ?? {}),
      pad: ItemStatValue.fromJson(json['pad'] ?? {}),
      mad: ItemStatValue.fromJson(json['mad'] ?? {}),
      pdd: ItemStatValue.fromJson(json['pdd'] ?? {}),
      maxHp: ItemStatValue.fromJson(json['maxHp'] ?? {}),
    );
  }
}

class ItemDetail {
  final ItemCommon common;
  final ItemStats stats;

  ItemDetail({
    required this.common,
    required this.stats,
  });

  factory ItemDetail.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final stats = json['stats'] ?? {};
    return ItemDetail(
      common: ItemCommon.fromJson(data['common'] ?? {}),
      stats: ItemStats.fromJson(stats['data']?['stats'] ?? {}),
    );
  }
}

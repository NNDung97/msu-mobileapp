// File: lib/model/item_detail_model.dart (HOÀN CHỈNH)

// Hàm tiện ích để xử lý ép kiểu int/double thành int
int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.round(); 
  return 0; 
}

// -------------------------------------------------------------------

class ItemDetailList {
    final int itemId;
    final String name;
    final String description;
    final String icon;
    final ItemCommon common;
    final ItemStats stats;

    ItemDetailList({
        required this.itemId,
        required this.name,
        required this.description,
        required this.icon,
        required this.common,
        required this.stats,
    });

    factory ItemDetailList.fromJson(Map<String, dynamic> json) {
        
        // --- Xử lý Dữ liệu Common (Cấp Root) ---
        final rootData = (json['data'] as Map<dynamic, dynamic>?)?.cast<String, dynamic>() ?? {};
        final common = (rootData['common'] as Map<dynamic, dynamic>?)?.cast<String, dynamic>() ?? {};
        
        // --- Xử lý Dữ liệu Stats ---
        final statsRoot = (json['stats'] as Map<dynamic, dynamic>?)?.cast<String, dynamic>() ?? {};
        final statsData = (statsRoot['data'] as Map<dynamic, dynamic>?)?.cast<String, dynamic>() ?? {};
        final stats = (statsData['baseStats'] as Map<dynamic, dynamic>?)?.cast<String, dynamic>() ?? {};

        return ItemDetailList(
            // Lấy ID, Name, Desc từ Map 'common'
            itemId: _parseInt(common['itemId']),
            name: common['itemName'] ?? 'Unknown', 
            description: common['desc'] ?? '', 
            icon: '', // Giữ nguyên
            
            common: ItemCommon.fromJson(common), 
            stats: ItemStats.fromJson(stats),   
        );
    }
}

// -------------------------------------------------------------------

class ItemCommon {
    final int maxStarforce;
    final bool isCash;
    final bool isBossReward;
    final int setItemId;

    ItemCommon({
        required this.maxStarforce,
        required this.isCash,
        required this.isBossReward,
        required this.setItemId,
    });

    factory ItemCommon.fromJson(Map<String, dynamic> json) => ItemCommon(
            maxStarforce: _parseInt(json['maxStarforce']), // SỬA
            isCash: json['isCash'] ?? false, 
            isBossReward: json['isBossReward'] ?? false,
            setItemId: _parseInt(json['setItemId']), // SỬA
        );
}

// -------------------------------------------------------------------

class ItemStats {
    final int str;
    final int dex;
    final int intt;
    final int luk;
    final int pad;
    final int mad;
    final int pdd;
    final int maxHp;
    final int maxMp;
    final int speed;
    final int jump;

    ItemStats({
        required this.str,
        required this.dex,
        required this.intt,
        required this.luk,
        required this.pad,
        required this.mad,
        required this.pdd,
        required this.maxHp,
        required this.maxMp,
        required this.speed,
        required this.jump,
    });

    factory ItemStats.fromJson(Map<String, dynamic> json) => ItemStats(
            // Áp dụng _parseInt cho tất cả các chỉ số
            str: _parseInt(json['str']),
            dex: _parseInt(json['dex']),
            intt: _parseInt(json['int']), 
            luk: _parseInt(json['luk']),
            pad: _parseInt(json['pad']),
            mad: _parseInt(json['mad']),
            pdd: _parseInt(json['pdd']),
            maxHp: _parseInt(json['maxHp']),
            maxMp: _parseInt(json['maxMp']),
            speed: _parseInt(json['speed']),
            jump: _parseInt(json['jump']),
        );
}
class ItemResponse {
  final bool success;
  final List<Item> data;
  final int total;
  final int page;
  final int totalPages;

  ItemResponse({
    required this.success,
    required this.data,
    required this.total,
    required this.page,
    required this.totalPages,
  });

  factory ItemResponse.fromJson(Map<String, dynamic> json) {
    return ItemResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => Item.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
    );
  }
}

class Item {
  final String id;
  final int itemID;
  final String? name;
  final String? link;
  final String? image;
  final String? type;
  final String? category;
  final String? slot;
  final int? level;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  Item({
    required this.id,
    required this.itemID,
    this.name,
    this.link,
    this.image,
    this.type,
    this.category,
    this.slot,
    this.level,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['_id']?.toString() ?? '',
      itemID: json['itemID'] ?? 0,
      name: json['name'],
      link: json['link'],
      image: json['image'],
      type: json['type'],
      category: json['category'],
      slot: json['slot'],
      level: json['level'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      v: json['__v'],
    );
  }
}

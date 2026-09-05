import 'zikr.dart';

class CategoryModel {
  final int id;
  final String code;
  final String nameAr;
  final String nameEn;
  final String description;
  final String icon;
  final String colorHex;
  final int orderIndex;
  final List<ZikrModel> azkar;

  CategoryModel({
    required this.id,
    required this.code,
    required this.nameAr,
    required this.nameEn,
    required this.description,
    required this.icon,
    required this.colorHex,
    required this.orderIndex,
    this.azkar = const [],
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    var azkarList = <ZikrModel>[];
    if (json['azkar'] != null) {
      azkarList = (json['azkar'] as List)
          .map((item) => ZikrModel.fromJson(item))
          .toList();
    }
    return CategoryModel(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      nameAr: json['name_ar'] ?? '',
      nameEn: json['name_en'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? 'bookmark',
      colorHex: json['color_hex'] ?? '#0A5C36',
      orderIndex: json['order_index'] ?? 0,
      azkar: azkarList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name_ar': nameAr,
      'name_en': nameEn,
      'description': description,
      'icon': icon,
      'color_hex': colorHex,
      'order_index': orderIndex,
      'azkar': azkar.map((z) => z.toJson()).toList(),
    };
  }
}

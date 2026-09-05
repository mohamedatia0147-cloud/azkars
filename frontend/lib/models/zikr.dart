class ZikrModel {
  final int id;
  final int order;
  final String text;
  final int targetCount;
  final String fadl;
  final String reference;
  int currentCount;
  bool isFavorite;

  ZikrModel({
    required this.id,
    required this.order,
    required this.text,
    required this.targetCount,
    required this.fadl,
    required this.reference,
    this.currentCount = 0,
    this.isFavorite = false,
  });

  bool get isCompleted => currentCount >= targetCount;
  int get remainingCount => (targetCount - currentCount) > 0 ? (targetCount - currentCount) : 0;
  double get progress => targetCount > 0 ? (currentCount / targetCount).clamp(0.0, 1.0) : 0.0;

  void increment() {
    if (currentCount < targetCount) {
      currentCount++;
    }
  }

  void reset() {
    currentCount = 0;
  }

  factory ZikrModel.fromJson(Map<String, dynamic> json) {
    return ZikrModel(
      id: json['id'] ?? 0,
      order: json['order'] ?? json['item_order'] ?? 0,
      text: json['text'] ?? json['text_ar'] ?? '',
      targetCount: json['target_count'] ?? 1,
      fadl: json['fadl'] ?? json['fadl_virtue'] ?? '',
      reference: json['reference'] ?? json['reference_sanad'] ?? '',
      isFavorite: json['is_favorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order': order,
      'text': text,
      'target_count': targetCount,
      'fadl': fadl,
      'reference': reference,
      'is_favorite': isFavorite,
    };
  }
}

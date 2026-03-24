class TemplateModel {
  final String id;
  final String imagePath;
  final String name;
  final double textX;
  final double textY;
  final double textWidth;
  final DateTime addedAt;

  const TemplateModel({
    required this.id,
    required this.imagePath,
    required this.name,
    required this.textX,
    required this.textY,
    required this.textWidth,
    required this.addedAt,
  });

  TemplateModel copyWith({
    String? id,
    String? imagePath,
    String? name,
    double? textX,
    double? textY,
    double? textWidth,
    DateTime? addedAt,
  }) {
    return TemplateModel(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      name: name ?? this.name,
      textX: textX ?? this.textX,
      textY: textY ?? this.textY,
      textWidth: textWidth ?? this.textWidth,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'imagePath': imagePath,
        'name': name,
        'textX': textX,
        'textY': textY,
        'textWidth': textWidth,
        'addedAt': addedAt.toIso8601String(),
      };

  factory TemplateModel.fromJson(Map<String, dynamic> json) => TemplateModel(
        id: json['id'] as String,
        imagePath: json['imagePath'] as String,
        name: json['name'] as String,
        textX: (json['textX'] as num).toDouble(),
        textY: (json['textY'] as num).toDouble(),
        textWidth: (json['textWidth'] as num).toDouble(),
        addedAt: DateTime.parse(json['addedAt'] as String),
      );
}

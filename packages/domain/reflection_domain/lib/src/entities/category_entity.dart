class CategoryEntity {
  final String id;
  final String name;
  final String? color;

  const CategoryEntity({required this.id, required this.name, this.color});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'color': color};

  factory CategoryEntity.fromJson(Map<String, dynamic> json) => CategoryEntity(
    id: json['id'] as String,
    name: json['name'] as String,
    color: json['color'] as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          color == other.color;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ color.hashCode;
}

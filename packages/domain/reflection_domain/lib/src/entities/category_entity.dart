class CategoryEntity {
  final String id;
  final String name;
  final String? color;

  const CategoryEntity({
    required this.id,
    required this.name,
    this.color,
  });

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

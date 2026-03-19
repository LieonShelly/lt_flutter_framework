class UserEntity {
  final String id;
  final String name;
  final String? email;
  final String? avatar;

  const UserEntity({
    required this.id,
    required this.name,
    this.email,
    this.avatar,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ email.hashCode;
}

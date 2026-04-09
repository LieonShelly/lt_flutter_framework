class IconEntity {
  final IconStatus status;
  final String url;

  const IconEntity({required this.status, required this.url});

  Map<String, dynamic> toJson() => {'status': status.name, 'url': url};

  factory IconEntity.fromJson(Map<String, dynamic> json) => IconEntity(
    status: IconStatus.fromString((json['status'] as String?)?.toUpperCase()),
    url: json['url'] as String,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IconEntity &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          url == other.url;

  @override
  int get hashCode => status.hashCode ^ url.hashCode;
}

enum IconStatus {
  generated,
  pending,
  failed,
  unknown;

  static IconStatus fromString(String? status) {
    if (status == null) return IconStatus.unknown;
    switch (status) {
      case "GENERATED":
        return IconStatus.generated;
      case "PENDING":
        return IconStatus.pending;
      case "FAILED":
        return IconStatus.failed;
      default:
        return IconStatus.unknown;
    }
  }
}

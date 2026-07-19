enum StoreNotificationType { order, offer, stock }

class StoreNotificationModel {
  const StoreNotificationModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.createdAt,
    required this.type,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final DateTime createdAt;
  final StoreNotificationType type;
  final bool isRead;

  StoreNotificationModel copyWith({bool? isRead}) => StoreNotificationModel(
    id: id,
    title: title,
    subtitle: subtitle,
    createdAt: createdAt,
    type: type,
    isRead: isRead ?? this.isRead,
  );

  Map<String, Object> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'createdAt': createdAt.toIso8601String(),
    'type': type.name,
    'isRead': isRead,
  };

  static StoreNotificationModel? tryFromJson(Object? json) {
    if (json is! Map) return null;
    final id = json['id'];
    final title = json['title'];
    final subtitle = json['subtitle'];
    final date = DateTime.tryParse(json['createdAt']?.toString() ?? '');
    final type = StoreNotificationType.values
        .where((value) => value.name == json['type'])
        .firstOrNull;
    if (id is! String ||
        title is! String ||
        subtitle is! String ||
        date == null ||
        type == null) {
      return null;
    }
    return StoreNotificationModel(
      id: id,
      title: title,
      subtitle: subtitle,
      createdAt: date,
      type: type,
      isRead: json['isRead'] == true,
    );
  }
}

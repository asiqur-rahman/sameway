import 'package:sameway/core/api/api_client.dart';

class NotificationsRepository {
  NotificationsRepository._();

  static final NotificationsRepository instance = NotificationsRepository._();
  final _client = ApiClient.instance;

  Future<NotificationPage> list({int page = 1, int limit = 30}) async {
    final data = await _client.get('/notifications', query: {'page': page, 'limit': limit});
    final items = (data['items'] as List<dynamic>? ?? [])
        .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
        .toList();
    return NotificationPage(
      items: items,
      total: data['total'] as int? ?? items.length,
      unreadCount: data['unreadCount'] as int? ?? 0,
    );
  }

  Future<void> markAllRead() async {
    await _client.patch('/notifications');
  }

  Future<void> markRead(String id) async {
    await _client.patch('/notifications/$id/read');
  }
}

class NotificationPage {
  const NotificationPage({
    required this.items,
    required this.total,
    required this.unreadCount,
  });

  final List<AppNotification> items;
  final int total;
  final int unreadCount;
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.read,
    required this.createdAt,
    this.payload,
  });

  final String id;
  final String type;
  final String title;
  final String body;
  final bool read;
  final DateTime createdAt;
  final Map<String, dynamic>? payload;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'GENERAL',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      read: json['read'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      payload: json['payload'] as Map<String, dynamic>?,
    );
  }

  String get icon {
    return switch (type) {
      'DRIVER_ETA' || 'DRIVER_HEADING_OUT' => '🚗',
      'RIDE_CONFIRMED' => '✅',
      'NEW_MESSAGE' || 'CHAT' => '💬',
      'RIDE_COMPLETED' => '🎉',
      'REVIEW' => '⭐',
      _ => '🔔',
    };
  }
}

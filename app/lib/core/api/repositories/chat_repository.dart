import 'package:intl/intl.dart';
import 'package:sameway/core/api/api_client.dart';
import 'package:sameway/core/session/app_data_models.dart';
import 'package:sameway/core/session/app_session.dart';

class ChatRepository {
  ChatRepository._();

  static final ChatRepository instance = ChatRepository._();
  final _client = ApiClient.instance;

  Future<List<ChatThread>> fetchConversations() async {
    final rows = await _client.getList('/chat/conversations');
    final myId = AppSession.instance.currentUser?.id;
    return rows.map((e) => _threadFromJson(e as Map<String, dynamic>, myId)).toList();
  }

  Future<List<ChatMessage>> fetchMessages(String conversationId) async {
    final rows = await _client.getList('/chat/conversations/$conversationId/messages');
    final myId = AppSession.instance.currentUser?.id;
    return rows
        .map((e) => _messageFromJson(e as Map<String, dynamic>, myId))
        .toList();
  }

  Future<void> sendMessage(String conversationId, String body) async {
    await _client.post('/chat/conversations/$conversationId/messages', data: {
      'body': body,
    });
  }

  Future<void> markRead(String conversationId) async {
    await _client.patch('/chat/conversations/$conversationId/messages');
  }

  ChatThread _threadFromJson(Map<String, dynamic> json, String? myId) {
    final participants = json['participants'] as List<dynamic>? ?? [];
    Map<String, dynamic>? peer;
    for (final p in participants) {
      final part = p as Map<String, dynamic>;
      final user = part['user'] as Map<String, dynamic>?;
      if (user != null && user['id'] != myId) {
        peer = user;
        break;
      }
    }

    final messages = json['messages'] as List<dynamic>? ?? [];
    final lastMsg = messages.isNotEmpty ? messages.first as Map<String, dynamic> : null;
    final ride = json['ride'] as Map<String, dynamic>?;

    String rideContext = '';
    if (ride != null) {
      final dep = ride['departureAt'] as String?;
      final time = dep != null ? _formatTime(dep) : '';
      rideContext =
          '${ride['startAddress'] ?? ''} → ${ride['endAddress'] ?? ''}${time.isNotEmpty ? ' · $time' : ''}';
    }

    return ChatThread(
      id: json['id'] as String,
      peerName: peer?['fullName'] as String? ?? 'Rider',
      rideContext: rideContext,
      messages: lastMsg != null
          ? [_messageFromJson(lastMsg, myId)]
          : const [],
      unread: false,
    );
  }

  ChatMessage _messageFromJson(Map<String, dynamic> json, String? myId) {
    final sender = json['sender'] as Map<String, dynamic>?;
    final senderId = sender?['id'] as String? ?? json['senderId'] as String?;
    final sentAtRaw = json['sentAt'] as String?;
    return ChatMessage(
      text: json['body'] as String? ?? '',
      isMine: senderId != null && senderId == myId,
      sentAt: sentAtRaw != null ? DateTime.parse(sentAtRaw).toLocal() : DateTime.now(),
    );
  }

  String _formatTime(String iso) {
    try {
      return DateFormat('h:mm a').format(DateTime.parse(iso).toLocal());
    } catch (_) {
      return iso;
    }
  }
}

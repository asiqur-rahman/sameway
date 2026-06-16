import 'dart:convert';

class PostRideDraft {
  PostRideDraft({
    this.startAddress,
    this.endAddress,
    this.startLat,
    this.startLng,
    this.endLat,
    this.endLng,
    this.stops = const [],
    this.departTime,
    this.dateLabel,
    this.seats = 2,
    this.repeat = 'Weekdays',
  });

  String? startAddress;
  String? endAddress;
  double? startLat;
  double? startLng;
  double? endLat;
  double? endLng;
  List<String> stops;
  String? departTime;
  String? dateLabel;
  int seats;
  String repeat;

  bool get hasRoute =>
      startAddress != null &&
      startAddress!.trim().isNotEmpty &&
      endAddress != null &&
      endAddress!.trim().isNotEmpty;

  String get routeLabel => '${startAddress ?? 'Start'} → ${endAddress ?? 'End'}';

  Map<String, dynamic> toJson() => {
        'startAddress': startAddress,
        'endAddress': endAddress,
        'startLat': startLat,
        'startLng': startLng,
        'endLat': endLat,
        'endLng': endLng,
        'stops': stops,
        'departTime': departTime,
        'dateLabel': dateLabel,
        'seats': seats,
        'repeat': repeat,
      };

  factory PostRideDraft.fromJson(Map<String, dynamic> json) => PostRideDraft(
        startAddress: json['startAddress'] as String?,
        endAddress: json['endAddress'] as String?,
        startLat: (json['startLat'] as num?)?.toDouble(),
        startLng: (json['startLng'] as num?)?.toDouble(),
        endLat: (json['endLat'] as num?)?.toDouble(),
        endLng: (json['endLng'] as num?)?.toDouble(),
        stops: (json['stops'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
        departTime: json['departTime'] as String?,
        dateLabel: json['dateLabel'] as String?,
        seats: json['seats'] as int? ?? 2,
        repeat: json['repeat'] as String? ?? 'Weekdays',
      );
}

enum RideStatus { pending, confirmed, completed, declined }

class UserRide {
  UserRide({
    required this.id,
    required this.route,
    required this.from,
    required this.to,
    required this.timeLabel,
    required this.detail,
    required this.status,
    this.driverName,
    this.driverUserId,
    this.isDriver = false,
    this.chatThreadId,
  });

  final String id;
  final String route;
  final String from;
  final String to;
  final String timeLabel;
  final String detail;
  RideStatus status;
  final String? driverName;
  final String? driverUserId;
  final bool isDriver;
  final String? chatThreadId;

  bool get isUpcoming =>
      status == RideStatus.pending || status == RideStatus.confirmed;

  Map<String, dynamic> toJson() => {
        'id': id,
        'route': route,
        'from': from,
        'to': to,
        'timeLabel': timeLabel,
        'detail': detail,
        'status': status.name,
        'driverName': driverName,
        'driverUserId': driverUserId,
        'isDriver': isDriver,
        'chatThreadId': chatThreadId,
      };

  factory UserRide.fromJson(Map<String, dynamic> json) => UserRide(
        id: json['id'] as String,
        route: json['route'] as String,
        from: json['from'] as String,
        to: json['to'] as String,
        timeLabel: json['timeLabel'] as String,
        detail: json['detail'] as String,
        status: RideStatus.values.byName(json['status'] as String? ?? 'pending'),
        driverName: json['driverName'] as String?,
        driverUserId: json['driverUserId'] as String?,
        isDriver: json['isDriver'] as bool? ?? false,
        chatThreadId: json['chatThreadId'] as String?,
      );
}

class JoinRequest {
  JoinRequest({
    required this.id,
    required this.riderName,
    required this.route,
    required this.matchLabel,
    required this.note,
    this.status = RideStatus.pending,
    this.rideId,
  });

  final String id;
  final String riderName;
  final String route;
  final String matchLabel;
  final String note;
  RideStatus status;
  final String? rideId;

  Map<String, dynamic> toJson() => {
        'id': id,
        'riderName': riderName,
        'route': route,
        'matchLabel': matchLabel,
        'note': note,
        'status': status.name,
        'rideId': rideId,
      };

  factory JoinRequest.fromJson(Map<String, dynamic> json) => JoinRequest(
        id: json['id'] as String,
        riderName: json['riderName'] as String,
        route: json['route'] as String,
        matchLabel: json['matchLabel'] as String,
        note: json['note'] as String,
        status: RideStatus.values.byName(json['status'] as String? ?? 'pending'),
        rideId: json['rideId'] as String?,
      );
}

class ChatMessage {
  ChatMessage({
    required this.text,
    required this.isMine,
    required this.sentAt,
  });

  final String text;
  final bool isMine;
  final DateTime sentAt;

  String get timeLabel {
    final h = sentAt.hour > 12 ? sentAt.hour - 12 : (sentAt.hour == 0 ? 12 : sentAt.hour);
    final m = sentAt.minute.toString().padLeft(2, '0');
    final period = sentAt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  Map<String, dynamic> toJson() => {
        'text': text,
        'isMine': isMine,
        'sentAt': sentAt.toIso8601String(),
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        text: json['text'] as String,
        isMine: json['isMine'] as bool? ?? false,
        sentAt: DateTime.parse(json['sentAt'] as String),
      );
}

class ChatThread {
  ChatThread({
    required this.id,
    required this.peerName,
    required this.rideContext,
    this.messages = const [],
    this.unread = false,
  });

  final String id;
  final String peerName;
  final String rideContext;
  List<ChatMessage> messages;
  bool unread;

  String get preview =>
      messages.isEmpty ? 'No messages yet' : messages.last.text;

  String get previewTime =>
      messages.isEmpty ? '' : messages.last.timeLabel;

  Map<String, dynamic> toJson() => {
        'id': id,
        'peerName': peerName,
        'rideContext': rideContext,
        'messages': messages.map((m) => m.toJson()).toList(),
        'unread': unread,
      };

  factory ChatThread.fromJson(Map<String, dynamic> json) => ChatThread(
        id: json['id'] as String,
        peerName: json['peerName'] as String,
        rideContext: json['rideContext'] as String,
        messages: (json['messages'] as List<dynamic>?)
                ?.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        unread: json['unread'] as bool? ?? false,
      );
}

class UserAppData {
  UserAppData({
    PostRideDraft? postRideDraft,
    this.activePostedRideId,
  }) : postRideDraft = postRideDraft ?? PostRideDraft();

  PostRideDraft postRideDraft;
  String? activePostedRideId;

  Map<String, dynamic> toJson() => {
        'postRideDraft': postRideDraft.toJson(),
        if (activePostedRideId != null) 'activePostedRideId': activePostedRideId,
      };

  factory UserAppData.fromJson(Map<String, dynamic> json) => UserAppData(
        postRideDraft: json['postRideDraft'] != null
            ? PostRideDraft.fromJson(json['postRideDraft'] as Map<String, dynamic>)
            : PostRideDraft(),
        activePostedRideId: json['activePostedRideId'] as String?,
      );

  static String encodeMap(Map<String, UserAppData> map) =>
      jsonEncode(map.map((k, v) => MapEntry(k, v.toJson())));

  static Map<String, UserAppData> decodeMap(String raw) {
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map(
      (k, v) => MapEntry(k, UserAppData.fromJson(v as Map<String, dynamic>)),
    );
  }
}

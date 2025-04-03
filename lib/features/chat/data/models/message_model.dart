import '../../../../core/models/user_model.dart';

enum MessageType { text, image, video, audio, file }

class MessageContentModel {
  final String receiver;
  final String sender;

  MessageContentModel({required this.receiver, required this.sender});

  Map<String, dynamic> toJson() {
    return {'receiver': receiver, 'sender': sender};
  }

  factory MessageContentModel.fromJson(Map<String, dynamic> map) {
    return MessageContentModel(
      receiver: map['receiver'] ?? '',
      sender: map['sender'] ?? '',
    );
  }

  @override
  String toString() {
    return 'MessageContentModel(receiver: $receiver, sender: $sender)';
  }

  @override
  bool operator ==(covariant MessageContentModel other) {
    if (identical(this, other)) return true;

    return other.receiver == receiver && other.sender == sender;
  }

  @override
  int get hashCode {
    return receiver.hashCode ^ sender.hashCode;
  }
}

class MessageModel {
  final int id;
  final MessageContentModel message;
  final String status;
  final MessageType type;
  final UserModel sender;
  final DateTime createdAt;
  final String? mediaUrl;
  MessageModel({
    required this.id,
    required this.message,
    required this.status,
    required this.type,
    required this.sender,
    required this.createdAt,
    this.mediaUrl,
  });

  MessageModel copyWith({
    int? id,
    MessageContentModel? message,
    String? status,
    MessageType? type,
    UserModel? sender,
    DateTime? createdAt,
    String? mediaUrl,
  }) {
    return MessageModel(
      id: id ?? this.id,
      message: message ?? this.message,
      status: status ?? this.status,
      type: type ?? this.type,
      sender: sender ?? this.sender,
      createdAt: createdAt ?? this.createdAt,
      mediaUrl: mediaUrl ?? this.mediaUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'message': message.toJson(),
      'status': status,
      'type': type.name,
      'user': sender.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'mediaUrl': mediaUrl,
    };
  }

  factory MessageModel.fromJson(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] ?? '',
      message: MessageContentModel.fromJson(map['message']),
      sender: UserModel.fromJson(map['user']),
      status: map['status'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => MessageType.text,
      ),
      createdAt: DateTime.parse(map['created_at']),
      mediaUrl: map['mediaUrl'],
    );
  }
  @override
  String toString() {
    return 'MessageModel(id: $id, message: $message, sender: $sender, status: $status, type: $type, createdAt: $createdAt, mediaUrl: $mediaUrl)';
  }

  @override
  bool operator ==(covariant MessageModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.message == message &&
        other.sender == sender &&
        other.status == status &&
        other.type == type &&
        other.createdAt == createdAt &&
        other.mediaUrl == mediaUrl;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        message.hashCode ^
        sender.hashCode ^
        status.hashCode ^
        type.hashCode ^
        createdAt.hashCode ^
        mediaUrl.hashCode;
  }
}

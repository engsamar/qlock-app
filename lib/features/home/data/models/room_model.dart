import '../../../../core/models/user_model.dart';
import '../../../chat/data/models/message_model.dart';
class RoomModel {
  final int id;
  final UserModel user;
  final String nameOnContact;
  final LastMessageModel? lastMessageModel;
  final String? lastMessageAt;
  final int? unreadMessages;
  final List<int> participants;


  RoomModel({
    required this.id,
    required this.user,
    required this.nameOnContact,
    required this.lastMessageModel,
    required this.lastMessageAt,
    required this.unreadMessages,
    required this.participants,
  });

  RoomModel copyWith({
    int? id,
    UserModel? user,
    String? nameOnContact,
    LastMessageModel? lastMessageModel,
    String? lastMessageAt,
      int? unreadMessages,
    List<int>? participants,
  }) {
    return RoomModel(
      id: id ?? this.id,
      user: user ?? this.user,
      nameOnContact: nameOnContact ?? this.nameOnContact,
      lastMessageModel: lastMessageModel ?? this.lastMessageModel,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadMessages: unreadMessages ?? this.unreadMessages,
      participants: participants ?? this.participants,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'user': user.toJson(),
      'name': nameOnContact,
      'last_message': lastMessageModel?.toJson(),
      'last_message_at': lastMessageAt,
      'unread_messages': unreadMessages,
      'participants': participants,
    };
  }

  factory RoomModel.fromJson(Map<String, dynamic> map) {
    return RoomModel(
      id: map['id'] ?? '',
      user: UserModel.fromJson(map['user']),
      nameOnContact: map['name'] ?? '',
      lastMessageModel: map['last_message'] != null
          ? LastMessageModel.fromJson(map['last_message'])
          : null,
      lastMessageAt: map['last_message_at'] ?? '',
      unreadMessages: map['unread_messages'] ?? 0,
      participants: map['participants'] != null
          ? List<int>.from(map['participants'])
          : [],
    );
  }
  @override
  String toString() {
    return 'RoomModel(id: $id, user: $user, nameOnContact: $nameOnContact, lastMessageModel: $lastMessageModel, lastMessageAt: $lastMessageAt, unreadMessages: $unreadMessages, participants: $participants)';
  }

  @override
  bool operator ==(covariant RoomModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.user == user &&
        other.nameOnContact == nameOnContact &&
        other.lastMessageModel == lastMessageModel &&
        other.lastMessageAt == lastMessageAt &&
        other.unreadMessages == unreadMessages &&
        other.participants == participants;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        user.hashCode ^
        nameOnContact.hashCode ^
        lastMessageModel.hashCode ^
        lastMessageAt.hashCode ^
        unreadMessages.hashCode ^
        participants.hashCode;
  }
}

class LastMessageModel {
  final int id;
  final MessageContentModel message;
  final String? readAt;
  final String status;
  final MessageType type;
  final UserModel sender;

  LastMessageModel({
      required this.id,
    required this.message,
    required this.readAt,
    required this.status,
    required this.type,
    required this.sender,
  });

  LastMessageModel copyWith({
    int? id,
    MessageContentModel? message,
    String? readAt,
    String? status,
    MessageType? type,
    UserModel? sender,
  }) {
    return LastMessageModel(
      id: id ?? this.id,
      message: message ?? this.message,
      readAt: readAt ?? this.readAt,
      status: status ?? this.status,
      type: type ?? this.type,
      sender: sender ?? this.sender,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'message': message.toJson(),
      'read_at': readAt,
      'status': status,
      'type': type.name,
      'user': sender.toJson(),
    };
  }

  factory LastMessageModel.fromJson(Map<String, dynamic> map) {
    return LastMessageModel(
      id: map['id'] ?? '',
      message: MessageContentModel.fromJson(map['message']),
      readAt: map['read_at'] ?? '',
      status: map['status'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => MessageType.text,
      ),
      sender: UserModel.fromJson(map['user']),
    );
  }
  @override
  String toString() {
    return 'LastMessageModel(id: $id, message: $message, readAt: $readAt, status: $status, type: $type, sender: $sender)';
  }

  @override
  bool operator ==(covariant LastMessageModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.message == message &&
        other.readAt == readAt &&
        other.status == status &&
        other.type == type &&
        other.sender == sender;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        message.hashCode ^
        readAt.hashCode ^
        status.hashCode ^
        type.hashCode ^
        sender.hashCode;
  }
}

import 'package:equatable/equatable.dart';
import 'package:q_lock/features/home/data/models/contact_with_phone.dart';

import '../../../data/models/room_model.dart';

enum ContactsStatus { initial, loading, permissionDenied, success, failure }

enum ConversationStatus { initial, loading, success, failure }

class ContactsState extends Equatable {
  final ContactsStatus contactsStatus;
  final List<ContactWithPhone> contacts;
  final String? contactsErrorMessage;

  final ConversationStatus conversationStatus;
  final RoomModel? chat;
  final String? conversationErrorMessage;

  const ContactsState({
    this.contactsStatus = ContactsStatus.initial,
    this.contacts = const [],
    this.contactsErrorMessage,
    this.conversationStatus = ConversationStatus.initial,
    this.chat,
    this.conversationErrorMessage,
  });

  @override
  List<Object?> get props => [
    contactsStatus,
    contacts,
    contactsErrorMessage,
    conversationStatus,
    chat,
    conversationErrorMessage,
  ];

  ContactsState copyWith({
    ContactsStatus? contactsStatus,
    List<ContactWithPhone>? contacts,
    String? contactsErrorMessage,
    ConversationStatus? conversationStatus,
    RoomModel? chat,
    String? conversationErrorMessage,
  }) {
    return ContactsState(
      contactsStatus: contactsStatus ?? this.contactsStatus,
      contacts: contacts ?? this.contacts,
      contactsErrorMessage: contactsErrorMessage ?? this.contactsErrorMessage,
      conversationStatus: conversationStatus ?? this.conversationStatus,
      chat: chat ?? this.chat,
      conversationErrorMessage:
          conversationErrorMessage ?? this.conversationErrorMessage,
    );
  }
}

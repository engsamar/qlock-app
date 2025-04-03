import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/models/failure.dart';
import '../../data/models/message_model.dart';
import '../../data/repos/chat_repository.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _chatRepository;

  StreamSubscription<Either<Failure, List<MessageModel>>>?
  _messagesSubscription;

  ChatCubit({required ChatRepository chatRepository})
    : _chatRepository = chatRepository,
      super(const ChatInitialState());

  List<MessageModel> _getCurrentMessages() {
    return switch (state) {
      ChatLoadedState(messages: final msgs) => msgs,
      ChatLoadingState(currentMessages: final msgs) => msgs,
      ChatErrorState(currentMessages: final msgs) => msgs,
      ChatInitialState() => const <MessageModel>[],
    };
  }

  void fetchMessages({required String chatId}) {
    emit(const ChatLoadingState());
    _messagesSubscription?.cancel();

    _messagesSubscription = _chatRepository
        .fetchMessages(chatId: chatId)
        .listen((result) {
          result.fold(
            (failure) {
              emit(
                ChatErrorState(
                  failure.message,
                  currentMessages: _getCurrentMessages(),
                ),
              );
            },
            (newMessages) {
              var currentMessages = List<MessageModel>.from(
                _getCurrentMessages(),
              );
              currentMessages.removeWhere((message) {
                return newMessages.any((e) {
                  return e.id == message.id;
                });
              });
              final mergedMessages = [...newMessages, ...currentMessages];

              emit(ChatLoadedState(mergedMessages));
            },
          );
        });
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}

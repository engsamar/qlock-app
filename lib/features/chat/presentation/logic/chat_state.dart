import '../../data/models/message_model.dart';

sealed class ChatState {
  const ChatState();
}

class ChatInitialState extends ChatState {
  const ChatInitialState();
}

class ChatLoadingState extends ChatState {
  final List<MessageModel> currentMessages;

  const ChatLoadingState({
    this.currentMessages = const [],
  });
}

class ChatLoadedState extends ChatState {
  final List<MessageModel> messages;

  const ChatLoadedState(this.messages);
}

class ChatErrorState extends ChatState {
  final String message;
  final List<MessageModel> currentMessages;

  const ChatErrorState(this.message, {this.currentMessages = const []});
}

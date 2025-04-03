import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/models/failure.dart';
import '../models/message_model.dart';

class ChatRepository {
  final FirebaseDatabase _database;
  final DioClient _dioClient;

  ChatRepository({
    required FirebaseDatabase database,
    required DioClient dioClient,
  }) : _database = database,
       _dioClient = dioClient;

  Stream<Either<Failure, List<MessageModel>>> fetchMessages({
    required String chatId,
  }) async* {
    try {
      final messagesRef = _database
          .ref()
          .child('chats')
          .child(chatId)
          .child('messages');

      // Listen to changes in the user's rooms
      final messagesStream = messagesRef.onValue;

      await for (final event in messagesStream) {
        if (event.snapshot.value == null) {
          // No rooms found for this user
          yield Right([]);
        } else {
          final List<MessageModel> messages = [];

          // Handle the data based on its type
          final dynamic snapshotValue = event.snapshot.value;

          if (snapshotValue is Map) {
            // Convert the map to the correct format
            snapshotValue.forEach((key, value) {
              if (value != null && value is Map) {
                try {
                  // Convert Firebase Map<Object?, Object?> to Map<String, dynamic>
                  final Map<String, dynamic> messageMap =
                      _convertToStringDynamicMap(value);

                  // Add room ID to the map if not present
                  if (!messageMap.containsKey('id')) {
                    messageMap['id'] = int.tryParse(key.toString()) ?? 0;
                  }

                  // Create a RoomModel from the data
                  messages.add(MessageModel.fromJson(messageMap));
                } catch (e) {
                  log('Error parsing room data: ${e.toString()}');
                }
              }
            });
          } else {
            log('Unexpected data format: ${snapshotValue.runtimeType}');
          }

          // Sort rooms by last message timestamp (newest first)
          messages.sort((a, b) {
            return b.createdAt.compareTo(a.createdAt);
          });

          yield Right(messages);
        }
      }
    } catch (e) {
      log('Error fetching messages: ${e.toString()}');
      yield Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, void>> sendMessage({
    required int chatId,
    required String myMessage,
    required String otherMessage,
    required MessageType type,
  }) async {
    return _dioClient.post(
      path: ApiEndpoints.messages,
      fromJson: (_) => null,
      body: {
        'conversation_id': chatId,
        'type': type.name,
        'message': {'sender': myMessage, 'receiver': otherMessage},
      },
    );
  }

  Map<String, dynamic> _convertToStringDynamicMap(Map map) {
    final Map<String, dynamic> result = {};

    map.forEach((key, value) {
      if (value is Map) {
        // Recursively convert nested maps
        result[key.toString()] = _convertToStringDynamicMap(value);
      } else if (value is List) {
        // Handle lists - convert each item if needed
        result[key.toString()] = _convertList(value);
      } else {
        // Simple values can be directly assigned
        result[key.toString()] = value;
      }
    });

    return result;
  }

  /// Helper method to convert items in a list, handling nested maps
  List _convertList(List list) {
    return list.map((item) {
      if (item is Map) {
        return _convertToStringDynamicMap(item);
      } else if (item is List) {
        return _convertList(item);
      } else {
        return item;
      }
    }).toList();
  }
}

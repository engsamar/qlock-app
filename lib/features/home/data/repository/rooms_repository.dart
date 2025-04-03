import 'package:dartz/dartz.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../../../core/network/models/failure.dart';
import '../models/room_model.dart';

class RoomsRepository {
  final FirebaseDatabase _database;

  RoomsRepository({required FirebaseDatabase database}) : _database = database;

  Stream<Either<Failure, List<RoomModel>>> fetchRooms({
    required int currentUserId,
  }) async* {
    try {
      // Reference to the current user's rooms in the database
      final roomsRef = _database
          .ref()
          .child('users')
          .child(currentUserId.toString());

      // Listen to changes in the user's rooms
      final roomsStream = roomsRef.onValue;

      await for (final event in roomsStream) {
        if (event.snapshot.value == null) {
          // No rooms found for this user
          yield Right([]);
        } else {
          final List<RoomModel> roomModels = [];

          // Handle the data based on its type
          final dynamic snapshotValue = event.snapshot.value;

          if (snapshotValue is Map) {
            // Convert the map to the correct format
            snapshotValue.forEach((key, value) {
              if (value != null && value is Map) {
                try {
                  // Convert Firebase Map<Object?, Object?> to Map<String, dynamic>
                  final Map<String, dynamic> roomMap =
                      _convertToStringDynamicMap(value);

                  // Add room ID to the map if not present
                  if (!roomMap.containsKey('id')) {
                    roomMap['id'] = int.tryParse(key.toString()) ?? 0;
                  }

                  // Create a RoomModel from the data
                  roomModels.add(RoomModel.fromJson(roomMap));
                } catch (e) {
                }
              }
            });
          } else {
          }

          // Sort rooms by last message timestamp (newest first)
          roomModels.sort((a, b) {
            if (a.lastMessageAt == null) return 1;
            if (b.lastMessageAt == null) return -1;
            return b.lastMessageAt!.compareTo(a.lastMessageAt!);
          });

          yield Right(roomModels);
        }
      }
    } catch (e) {
      yield Left(ServerFailure(message: e.toString()));
    }
  }

  /// Helper method to convert Firebase's Map<Object?, Object?> to Map<String, dynamic>
  /// Handles nested maps and lists recursively
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

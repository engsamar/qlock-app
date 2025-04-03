import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/network/models/failure.dart';
import '../../../data/models/room_model.dart';
import '../../../data/repository/rooms_repository.dart';
import 'rooms_state.dart';

class RoomsCubit extends Cubit<RoomsState> {
  final RoomsRepository _roomsRepository;

  RoomsCubit({required RoomsRepository roomsRepository})
    : _roomsRepository = roomsRepository,
      super(const RoomsInitialState());


  StreamSubscription<Either<Failure, List<RoomModel>>>? _roomsSubscription;

  List<RoomModel> _getCurrentRooms() {
    return switch (state) {
      RoomsLoadedState(rooms: final rooms) => rooms,
      RoomsLoadingState() => const <RoomModel>[],
      RoomsErrorState() => const <RoomModel>[],
      RoomsInitialState() => const <RoomModel>[],
    };
  }

  void fetchRooms({required int currentUserId}) {
    emit(RoomsLoadingState());
    _roomsSubscription?.cancel();

    _roomsSubscription = _roomsRepository
        .fetchRooms(currentUserId: currentUserId)
        .listen((result) {
          result.fold(
            (failure) {
              emit(
                RoomsErrorState(
                  message: failure.message,
                ),
              );
            },
            (newRooms) {
              var currentRooms = List<RoomModel>.from(_getCurrentRooms());
              currentRooms.removeWhere((room) {
                return newRooms.any((e) {
                  return e.id == room.id;
                });
              });
              final mergedRooms = [...newRooms, ...currentRooms];
              emit(RoomsLoadedState(rooms: mergedRooms));
            },
          );
        });
  }

  @override
  Future<void> close() {
    _roomsSubscription?.cancel();
    return super.close();
  }
}

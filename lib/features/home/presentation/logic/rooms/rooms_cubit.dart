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
  FilterType _currentFilter = FilterType.all;

  List<RoomModel> _getCurrentRooms() {
    return switch (state) {
      RoomsLoadedState(rooms: final rooms) => rooms,
      RoomsLoadingState() => const <RoomModel>[],
      RoomsErrorState() => const <RoomModel>[],
      RoomsInitialState() => const <RoomModel>[],
    };
  }

  void fetchRooms({required int currentUserId}) {
    emit(RoomsLoadingState(filterType: _currentFilter));
    _roomsSubscription?.cancel();

    _roomsSubscription = _roomsRepository
        .fetchRooms(currentUserId: currentUserId)
        .listen((result) {
          result.fold(
            (failure) {
              emit(
                RoomsErrorState(
                  message: failure.message,
                  filterType: _currentFilter,
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
              final filteredRooms = _filterRooms(mergedRooms);
              emit(
                RoomsLoadedState(
                  rooms: mergedRooms,
                  filterType: _currentFilter,
                  filteredRooms: filteredRooms,
                ),
              );
            },
          );
        });
  }

  void changeFilter(FilterType filterType, {int? currentUserId}) {
    _currentFilter = filterType;

    if (state is RoomsLoadedState) {
      final currentState = state as RoomsLoadedState;
      final filteredRooms = _filterRooms(currentState.rooms);
      emit(
        RoomsLoadedState(
          rooms: currentState.rooms,
          filterType: filterType,
          filteredRooms: filteredRooms,
        ),
      );
    } else if (currentUserId != null) {
      // If we're not in loaded state, refetch with the new filter
      fetchRooms(currentUserId: currentUserId);
    } else {
      // Just update the filter type in current state
      if (state is RoomsLoadingState) {
        emit(RoomsLoadingState(filterType: filterType));
      } else if (state is RoomsErrorState) {
        emit(
          RoomsErrorState(
            message: (state as RoomsErrorState).message,
            filterType: filterType,
          ),
        );
      }
    }
  }

  List<RoomModel> _filterRooms(List<RoomModel> rooms) {
    switch (_currentFilter) {
      case FilterType.all: // All rooms
        return rooms;
      case FilterType.read: // Read rooms
        return rooms
            .where(
              (room) => room.unreadMessages == null || room.unreadMessages == 0,
            )
            .toList();
      case FilterType.unread: // Unread rooms
        return rooms
            .where(
              (room) => room.unreadMessages != null && room.unreadMessages! > 0,
            )
            .toList();
    }
  }

  @override
  Future<void> close() {
    _roomsSubscription?.cancel();
    return super.close();
  }
}

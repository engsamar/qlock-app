import '../../../data/models/room_model.dart';

sealed class RoomsState {
  const RoomsState();
}

class RoomsInitialState extends RoomsState {
  const RoomsInitialState();
}

class RoomsLoadingState extends RoomsState {}

class RoomsLoadedState extends RoomsState {
  final List<RoomModel> rooms;

  const RoomsLoadedState({required this.rooms});
}

class RoomsErrorState extends RoomsState {
  final String message;

  const RoomsErrorState({required this.message});
}

import '../../../data/models/room_model.dart';

enum FilterType { all, read, unread }

sealed class RoomsState {
  final FilterType filterType;

  const RoomsState({this.filterType = FilterType.all});
}

class RoomsInitialState extends RoomsState {
  const RoomsInitialState({super.filterType = FilterType.all});
}

class RoomsLoadingState extends RoomsState {
  const RoomsLoadingState({super.filterType = FilterType.all});
}

class RoomsLoadedState extends RoomsState {
  final List<RoomModel> rooms;
  final List<RoomModel> filteredRooms;

  const RoomsLoadedState({
    required this.rooms,
    required super.filterType,
    required this.filteredRooms,
  });
}

class RoomsErrorState extends RoomsState {
  final String message;

  const RoomsErrorState({required this.message, required super.filterType});
}

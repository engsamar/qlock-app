import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/rooms/rooms_cubit.dart';
import '../../logic/rooms/rooms_state.dart';

class RoomsViewError extends StatelessWidget {
  const RoomsViewError({
    super.key,
    required this.currentUserId,
    required this.state,
  });

  final int currentUserId;
  final RoomsErrorState state;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(child: Text(state.message)),
              IconButton(
                onPressed: () {
                  context
                      .read<RoomsCubit>()
                      .fetchRooms(currentUserId: currentUserId);
                },
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../auth/presentation/logic/auth_cubit.dart';
import '../../logic/rooms/rooms_cubit.dart';
import '../../logic/rooms/rooms_state.dart';
import 'rooms_view_error.dart';
import 'rooms_view_success.dart';

class RoomsViewBody extends StatelessWidget {
  const RoomsViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoomsCubit, RoomsState>(
      builder: (context, state) {
        final currentUserId = (context.read<AuthCubit>().currentUser!.id);
        return switch (state) {
          RoomsErrorState() => RoomsViewError(
              currentUserId: currentUserId,
              state: state,
            ),
          RoomsLoadingState() =>
            const Center(child: CircularProgressIndicator()),
          RoomsLoadedState() => RoomsViewSuccess(
              rooms: state.rooms,
              currentUserId: currentUserId,
            ),
          RoomsInitialState() =>
            const Center(child: CircularProgressIndicator()),
        };
      },
    );
  }
}

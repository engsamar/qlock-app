import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:q_lock/features/home/data/repository/contacts_repository.dart';
import 'package:q_lock/features/home/presentation/logic/contacts/contacts_state.dart';

class ContactsCubit extends Cubit<ContactsState> {
  final ContactsRepository _contactsRepository;

  ContactsCubit({required ContactsRepository contactsRepository})
    : _contactsRepository = contactsRepository,
      super(const ContactsState());

  Future<void> loadContacts() async {
    emit(state.copyWith(contactsStatus: ContactsStatus.loading));

    try {
      // Check permission first
      final hasPermissionResult =
          await _contactsRepository.hasContactsPermission();

      await hasPermissionResult.fold(
        (failure) {
          emit(
            state.copyWith(
              contactsStatus: ContactsStatus.failure,
              contactsErrorMessage: failure.message,
            ),
          );
        },
        (hasPermission) async {
          if (!hasPermission) {
            // Request permission if needed
            final permissionResult =
                await _contactsRepository.requestContactsPermission();

            await permissionResult.fold(
              (failure) {
                emit(
                  state.copyWith(
                    contactsStatus: ContactsStatus.failure,
                    contactsErrorMessage: failure.message,
                  ),
                );
              },
              (permissionGranted) async {
                if (!permissionGranted) {
                  emit(
                    state.copyWith(
                      contactsStatus: ContactsStatus.permissionDenied,
                    ),
                  );
                } else {
                  await _fetchContacts();
                }
              },
            );
          } else {
            // Permission already granted, fetch contacts
            await _fetchContacts();
          }
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          contactsStatus: ContactsStatus.failure,
          contactsErrorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _fetchContacts() async {
    final contactsResult = await _contactsRepository.getContacts();

    contactsResult.fold(
      (failure) {
        emit(
          state.copyWith(
            contactsStatus: ContactsStatus.failure,
            contactsErrorMessage: failure.message,
          ),
        );
      },
      (contacts) {
        emit(
          state.copyWith(
            contactsStatus: ContactsStatus.success,
            contacts: contacts,
          ),
        );
      },
    );
  }

  Future<void> startConversation(String phoneNumber, String name) async {
    // Keep the contacts state (success/list) while showing conversation loading
    emit(state.copyWith(conversationStatus: ConversationStatus.loading));

    final result = await _contactsRepository.startConversation(
      phoneNumber,
      name,
    );

    result.fold(
      (networkFailure) {
        emit(
          state.copyWith(
            conversationStatus: ConversationStatus.failure,
            conversationErrorMessage: networkFailure.message,
          ),
        );
      },
      (success) {
        emit(
          state.copyWith(
            conversationStatus: ConversationStatus.success,
            chat: success.data,
          ),
        );
      },
    );
  }
}

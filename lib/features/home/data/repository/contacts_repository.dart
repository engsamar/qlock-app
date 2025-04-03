import 'package:dartz/dartz.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:q_lock/core/network/api_endpoints.dart';
import 'package:q_lock/core/network/dio_client.dart';
import 'package:q_lock/features/home/data/models/contact_with_phone.dart';

import '../../../../core/network/models/failure.dart';
import '../../../../core/network/models/resource_model.dart';
import '../models/room_model.dart';

class ContactsRepository {
  final DioClient _dioClient;

  ContactsRepository({required DioClient dioClient}) : _dioClient = dioClient;

  Future<Either<Failure, bool>> hasContactsPermission() async {
    try {
      final isGranted = await Permission.contacts.status.isGranted;
      return Right(isGranted);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, bool>> requestContactsPermission() async {
    try {
      final isGranted = await Permission.contacts.request().isGranted;
      return Right(isGranted);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, List<ContactWithPhone>>> getContacts() async {
    try {
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );
      return Right(_processContacts(contacts));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, ResourceModel<RoomModel>>> startConversation(
    String phoneNumber,
    String name,
  ) async {
    return _dioClient.post(
      path: ApiEndpoints.conversations,
      fromJson: (json) => RoomModel.fromJson(json['conversation']),
      body: {'mobile': phoneNumber, 'name': name},
    );
  }

  List<ContactWithPhone> _processContacts(List<Contact> contacts) {
    final List<ContactWithPhone> result = [];

    for (final contact in contacts) {
      // Only include contacts with phone numbers
      if (contact.phones.isNotEmpty) {
        // Add each phone number as a separate entry
        for (final phone in contact.phones) {
          result.add(ContactWithPhone(contact: contact, phone: phone));
        }
      }
    }

    // Sort by contact name
    result.sort(
      (a, b) => a.contact.displayName.compareTo(b.contact.displayName),
    );

    return result;
  }
}

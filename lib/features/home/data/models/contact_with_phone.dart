import 'package:flutter_contacts/flutter_contacts.dart';

class ContactWithPhone {
  final Contact contact;
  final Phone phone;

  ContactWithPhone({required this.contact, required this.phone});

  @override
  String toString() =>
      'ContactWithPhone(contact: ${contact.displayName}, phone: ${phone.number})';
}

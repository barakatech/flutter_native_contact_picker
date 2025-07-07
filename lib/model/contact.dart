/// Represents a contact selected by the user.
class Contact {
  Contact({
    this.fullName,
    this.phoneNumbers,
    this.emails,
    this.selectedPhoneNumber,
    this.selectedEmail,
  });

  factory Contact.fromMap(Map<dynamic, dynamic> map) => Contact(
        fullName: map['fullName'],
        phoneNumbers: map['phoneNumbers']?.cast<String>(),
        selectedPhoneNumber: map['selectedPhoneNumber']?.toString(),
      );

  /// The full name of the contact, e.g. "Jayesh Pansheriya".
  final String? fullName;

  /// List of all phone numbers associated with the contact.
  final List<String>? phoneNumbers;

  /// List of all emails associated with the contact.
  final List<String>? emails;

  /// The specifically selected phone number when using phone number picker mode.
  final String? selectedPhoneNumber;

  /// The specifically selected email when using email picker mode.
  final String? selectedEmail;

  @override
  String toString() =>
      '$fullName: ${selectedPhoneNumber ?? phoneNumbers} ${selectedEmail ?? emails}';
}

/// Represents a contact selected by the user.
class Contact {
  Contact({
    this.fullName,
    this.emails,
    this.selectedEmail,
  });

  factory Contact.fromMap(Map<dynamic, dynamic> map) => Contact(
        fullName: map['fullName'],
        emails: map['emails']?.cast<String>(),
        selectedEmail: map['selectedEmail']?.toString(),
      );

  /// The full name of the contact, e.g. "Jayesh Pansheriya".
  final String? fullName;

  /// List of all emails associated with the contact.
  final List<String>? emails;

  /// The specifically selected email when using email picker mode.
  final String? selectedEmail;

  @override
  String toString() => '$fullName: ${selectedEmail ?? emails}';
}

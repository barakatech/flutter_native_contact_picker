# Flutter native contact picker

With this plugin a Flutter app can ask its user to select a contact or contacts from their address book, with the option to select specific emails. The information associated with the contacts is returned to the app.

This plugin uses the operating system's native UI for selecting contacts and does not require any special permissions from the user, even on Android.

## Features

- [x] iOS Support
  - Select single contact
  - Select multiple contacts
  - Select specific email from a contact
  - Returns all emails for selected contacts

- [x] Android Support
  - Select single contact
  - Select specific email from a contact
  - No READ_CONTACTS permission required

## Usage

### Basic Contact Selection

```dart
// Create an instance of the picker
final FlutterNativeContactPicker _contactPicker = FlutterNativeContactPicker();

// Select a single contact
Contact? contact = await _contactPicker.selectContact();
print(contact?.fullName);
print(contact?.emails);

// Select multiple contacts (iOS only)
List<Contact>? contacts = await _contactPicker.selectContacts();
for (var contact in contacts ?? []) {
  print(contact.fullName);
  print(contact.emails);
}
```

### Email Selection

```dart
// Select a specific phone number from a contact
Contact? contact = await _contactPicker.selectEmail();
print(contact?.fullName);
print(contact?.selectedEmail); // The specifically selected email
print(contact?.emails); // All available emails (iOS only)
```

## Contact Model

The `Contact` class provides the following properties:

```dart
class Contact {
  final String? fullName;           // Contact's full name
  final List<String>? emails; // All emails (iOS: all emails, Android: selected email only)
  final String? selectedEmail; // The specifically selected email when using selectEmail()
}
```

## Platform Differences

### iOS

- Supports selecting multiple contacts
- Returns all emails associated with a contact
- When using `selectEmail()`, returns both the selected email and all available emails
- Uses native CNContactPickerViewController

### Android

- Single contact selection only
- When using `selectEmail()`, returns only the selected email
- No READ_CONTACTS permission required
- Uses native contact picker intent

## Example

See the [example](example) directory for a complete sample app demonstrating all features.

```dart
void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FlutterNativeContactPicker _contactPicker = FlutterNativeContactPicker();
  List<Contact>? _contacts;
  String? _selectedEmail;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Contact Picker Example App'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              MaterialButton(
                color: Colors.blue,
                textColor: Colors.white,
                child: const Text("Select Contact"),
                onPressed: () async {
                  Contact? contact = await _contactPicker.selectContact();
                  setState(() {
                    _contacts = contact == null ? null : [contact];
                    _selectedEmail = null;
                  });
                },
              ),
              MaterialButton(
                color: Colors.green,
                textColor: Colors.white,
                child: const Text("Select Email"),
                onPressed: () async {
                  Contact? contact = await _contactPicker.selectEmail();
                  setState(() {
                    _contacts = contact == null ? null : [contact];
                    _selectedEmail = contact?.selectedEmail;
                  });
                },
              ),
              if (_contacts != null) ...[
                ..._contacts!.map(
                  (contact) => Column(
                    children: [
                      Text(contact.fullName ?? 'No name'),
                      if (_selectedEmail != null)
                        Text('Selected: $_selectedEmail'),
                      ...?contact.emails?.map((email) => Text(email)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
```

import ContactsUI
import Flutter
import UIKit

public class FlutterNativeContactPickerPlugin: NSObject, FlutterPlugin {
    var _delegate: PickerHandler?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "baraka_flutter_native_contact_picker", binaryMessenger: registrar.messenger())
        let instance = FlutterNativeContactPickerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if "selectContact" == call.method || "selectContacts" == call.method
            || "selectEmail" == call.method
        {
            if _delegate != nil {
                _delegate!.result(
                    FlutterError(
                        code: "multiple_requests", message: "Cancelled by a second request.",
                        details: nil))
                _delegate = nil
            }

            if #available(iOS 9.0, *) {
                let single = call.method == "selectContact"
                let emailSelection = call.method == "selectEmail"

                if emailSelection {
                    _delegate = EmailPickerHandler(result: result)
                } else {
                    _delegate =
                        single
                        ? SinglePickerHandler(result: result) : MultiPickerHandler(result: result)
                }

                let contactPicker = CNContactPickerViewController()
                contactPicker.delegate = _delegate
                contactPicker.displayedPropertyKeys = [CNContactEmailAddressesKey]

                // find proper keyWindow
                var keyWindow: UIWindow? = nil
                if #available(iOS 13, *) {
                    keyWindow =
                        UIApplication.shared.connectedScenes.filter {
                            $0.activationState == .foregroundActive
                        }.compactMap {
                            $0 as? UIWindowScene
                        }.first?.windows.filter({ $0.isKeyWindow }).first
                } else {
                    keyWindow = UIApplication.shared.keyWindow
                }

                let viewController = keyWindow?.rootViewController
                viewController?.present(contactPicker, animated: true, completion: nil)
            }
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
}

class PickerHandler: NSObject, CNContactPickerDelegate {
    var result: FlutterResult

    required init(result: @escaping FlutterResult) {
        self.result = result
        super.init()
    }

    @available(iOS 9.0, *)
    public func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        result(nil)
    }
}

class SinglePickerHandler: PickerHandler {
    @available(iOS 9.0, *)
    public func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact)
    {
        var data = [String: Any]()
        data["fullName"] = CNContactFormatter.string(
            from: contact, style: CNContactFormatterStyle.fullName)
        let emails: [String] = contact.emailAddresses.compactMap { $0.value as? String }
        data["emails"] = emails
        result(data)
    }
}

class MultiPickerHandler: PickerHandler {
    @available(iOS 9.0, *)
    public func contactPicker(
        _ picker: CNContactPickerViewController, didSelect contacts: [CNContact]
    ) {
        var selectedContacts = [[String: Any]]()
        for contact in contacts {
            var contactInfo = [String: Any]()
            contactInfo["fullName"] = CNContactFormatter.string(
                from: contact, style: CNContactFormatterStyle.fullName)
            let emails: [String] = contact.emailAddresses.compactMap {
                $0.value as? String
            }
            contactInfo["emails"] = emails
            selectedContacts.append(contactInfo)
        }
        result(selectedContacts)
    }
}

class EmailPickerHandler: PickerHandler {
    @available(iOS 9.0, *)
    public func contactPicker(
        _ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty
    ) {
        if contactProperty.key == CNContactEmailAddressesKey {
            let contact = contactProperty.contact
            var data = [String: Any]()
            data["fullName"] = CNContactFormatter.string(
                from: contact, style: CNContactFormatterStyle.fullName)
            data["selectedEmail"] = contactProperty.value as? String
            data["emails"] = contact.emailAddresses.compactMap {
                $0.value as? String
            }
            result(data)
        }
    }
}

//
//  MultiContactPickerSheet.swift
//  Desert
//
//

import SwiftUI
import ContactsUI

// MARK: - Contact Picker Sheet B (multi select)
// Used for group members — multiple contacts at once.

struct MultiContactPickerSheet: UIViewControllerRepresentable {

    var onSelect: ([CNContact]) -> Void

    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onSelect: onSelect) }

    class Coordinator: NSObject, CNContactPickerDelegate {
        var onSelect: ([CNContact]) -> Void
        init(onSelect: @escaping ([CNContact]) -> Void) { self.onSelect = onSelect }
        func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
            onSelect(contacts)
        }
    }
}

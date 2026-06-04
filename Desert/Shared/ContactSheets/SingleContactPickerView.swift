//
//  SingleContactPickerView.swift
//  Desert
//
//

import SwiftUI
import ContactsUI

// MARK: - Contact Picker Sheet A (single select)
// Used for emergency contacts — one contact at a time.

struct SingleContactPickerView: UIViewControllerRepresentable {

    var onSelect: (CNContact) -> Void

    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onSelect: onSelect) }

    class Coordinator: NSObject, CNContactPickerDelegate {
        var onSelect: (CNContact) -> Void
        init(onSelect: @escaping (CNContact) -> Void) { self.onSelect = onSelect }
        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            onSelect(contact)
        }
    }
}


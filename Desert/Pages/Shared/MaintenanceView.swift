//
//  MaintenanceView.swift
//  Desert
//
//  Full-screen placeholder shown when maintenance mode is enabled in Firebase.
//

import SwiftUI

struct MaintenanceView: View {

    // MARK: - Input

    var title: String
    var message: String

    // MARK: - Body

    var body: some View {
        MaintenanceTemplate(title: title, message: message)
    }
}

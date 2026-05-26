//
//  ConnectivityIcon.swift
//  Desert
//
//  Created by Samar A on 07/12/1447 AH.
//

import SwiftUI

struct ConnectivityIcon: View {

    enum Style {
        case connected
        case disconnected
    }

    var style: Style = .connected

    var body: some View {

        Image(systemName: iconName)
            .font(.system(size: 28, weight: .semibold))
            .foregroundStyle(Color.Secondary02)
    }
}

private extension ConnectivityIcon {

    var iconName: String {

        switch style {
        case .connected:
            return "wifi"

        case .disconnected:
            return "wifi.slash"
        }
    }
}

#Preview {

    VStack(spacing: 24) {

        ConnectivityIcon(style: .connected)

        ConnectivityIcon(style: .disconnected)
    }
    .padding()
}

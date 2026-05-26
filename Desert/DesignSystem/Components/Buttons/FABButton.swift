//
//  FABButton.swift
//  Desert
//
//  Created by Samar A on 04/12/1447 AH.
//

import SwiftUI

struct FABButton: View {

    enum Style {
        case primary
        case secondary
        case disabled
    }

    enum Icon {
        case map
        case compass
        case location
    }

    var style: Style = .primary

    var icon: Icon = .map

    var action: () -> Void

    var body: some View {

        Button(action: action) {

            Image(systemName: iconName)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(iconColor)
                .frame(width: 44, height: 44)
                .background(Color.Primary)
                .clipShape(Circle())
        }
        .disabled(style == .disabled)
    }
}


private extension FABButton {

    var iconName: String {

        switch icon {

        case .map:
            return "map.fill"

        case .compass:
            return "safari.fill"

        case .location:
            return "location.fill"
        }
    }

 
    var iconColor: Color {

        switch style {

        default:
            return .white
        }
    }
}

#Preview {

    VStack(spacing: 20) {

        FABButton(
            style: .primary,
            icon: .map
        ) {

        }

        FABButton(
            style: .secondary,
            icon: .compass
        ) {

        }

        FABButton(
            style: .disabled,
            icon: .location
        ) {

        }
    }
}

//
//  progress.swift
//  Desert
//
//  Created by Samar A on 04/12/1447 AH.
//

import SwiftUI

struct ProgressSegment: View {

    enum Style {
        case active
        case inactive
    }

    var style: Style = .inactive

    var body: some View {

        Capsule()
            .fill(backgroundColor)
    }
}

private extension ProgressSegment {

    var backgroundColor: Color {

        switch style {

        case .active:
            return .Secondary02

        case .inactive:
            return .Disabled
        }
    }
}

#Preview {

    VStack(spacing: 20) {

        ProgressSegment(style: .inactive)
            .frame(height: 4)

        ProgressSegment(style: .active)
            .frame(height: 4)
    }
    .padding()
}

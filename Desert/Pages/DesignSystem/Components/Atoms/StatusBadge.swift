//
//  StatusBadge.swift
//  Desert
//
//  Created by Samar A on 07/12/1447 AH.
//

import SwiftUI

struct StatusBadge: View {

    enum Style {
        case positive
        case destructive
    }

    var titleKey: String
    var style: Style = .positive
    var size: Size = .large

    enum Size {
        case small
        case large
    }

    var body: some View {

        Text(titleKey.localized)
            .font(AppTypography.caption2)
            .foregroundStyle(textColor)
            .padding(.horizontal, horizontalPadding)
            .frame(height: height)
            .background(backgroundColor)
            .clipShape(Capsule())
    }
}

private extension StatusBadge {

    var textColor: Color {
        style == .positive ? Color.Positive : Color.Destructive
    }

    var backgroundColor: Color {
        style == .positive ? Color.PositiveBg : Color.DestructiveBg
    }

    var height: CGFloat {
        size == .large ? 40 : 32
    }

    var horizontalPadding: CGFloat {
        size == .large ? AppSpacing.lg : AppSpacing.md
    }
}

#Preview {
    VStack(spacing: 16) {
        StatusBadge(titleKey: "status.label", style: .positive, size: .large)
        StatusBadge(titleKey: "status.label", style: .destructive, size: .large)
        StatusBadge(titleKey: "status.label", style: .positive, size: .small)
        StatusBadge(titleKey: "status.label", style: .destructive, size: .small)
    }
    .padding()
}

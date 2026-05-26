//
//  PrimaryButton.swift
//  Desert
//
//  Created by Samar A on 03/12/1447 AH.
//

import SwiftUI

struct CTAButton: View {

    enum Style {
        case primary
        case secondary
        case disabled
    }

    var title: String

    var style: Style = .primary

    var action: () -> Void

    var body: some View {

        Button(action: action) {

            Text(title)
                .font(AppTypography.headline)
                .foregroundStyle(foregroundColor)
                .frame(maxWidth: .infinity)
                .frame(width: 291, height:52)
                .background(backgroundColor)
                .cornerRadius(AppRadius.xxl)
        }
        .padding(.vertical, AppSpacing.md)
        .padding(.horizontal, AppSpacing.xxxl)
        
        .disabled(style == .disabled)
    }
}

private extension CTAButton {

    var backgroundColor: Color {

        switch style {

        case .primary:
            return .Primary

        case .secondary:
            return .Secondary02

        case .disabled:
            return .Disabled
        }
    }

    var foregroundColor: Color {

        switch style {

        case .disabled:
            return .white.opacity(0.7)

        default:
            return .white
        }
    }
}
#Preview {

    VStack(spacing: AppSpacing.md) {

        CTAButton(
            title: "button.cta".localized,
            style: .primary
        ) {
            
        }

        CTAButton(
            title: "button.cta".localized,
            style: .secondary
        ) {
            
        }

        CTAButton(
            title: "button.cta".localized,
            style: .disabled
        ) {
            
        }
    }
}

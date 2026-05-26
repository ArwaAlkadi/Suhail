//
//  Stepper.swift
//  Desert
//
//  Created by Samar A on 04/12/1447 AH.
//

import SwiftUI

struct Stepper: View {

    enum Style {
        case active
        case disabled
    }

    @Binding var count: Int

    var style: Style = .active

    var body: some View {

        HStack(spacing: AppSpacing.md) {

            Button {

                if count > 1 {
                    count -= 1
                }

            } label: {

                Image(systemName: "minus")
                    .font(.system(size: 14, weight: .semibold))
                    .font(AppTypography.headline)
                    .foregroundStyle(foregroundColor)
            }

            Text("\(count)")
                .font(AppTypography.body)
                .foregroundStyle(foregroundColor)

            Button {

                count += 1

            } label: {

                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .semibold))
                    .font(AppTypography.headline)
                    .foregroundStyle(foregroundColor)
            }
        }
        .frame(width: 108, height: 32)
        .background(backgroundColor)
        .clipShape(Capsule())
        .disabled(style == .disabled)
    }
}

private extension Stepper {

    var backgroundColor: Color {

        switch style {

        case .active:
            return .Secondary02

        case .disabled:
            return .Background
        }
    }

    var foregroundColor: Color {

        switch style {

        case .active:
            return .white

        case .disabled:
            return .Disabled
        }
    }
}

#Preview {

    VStack(spacing: 20) {

        Stepper(
            count: .constant(2),
            style: .active
        )

        Stepper(
            count: .constant(1),
            style: .disabled
        )
    }
    .padding()
}

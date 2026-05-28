//
//  RepeatTripButton.swift
//  Desert
//
//  Created by Samar A on 04/12/1447 AH.
//

import SwiftUI

struct RepeatTripButton: View {

    var title: String = "button.repeatTrip".localized
    var action: () -> Void

    var body: some View {

        Button(action: action) {

            HStack(spacing: AppSpacing.sm) {

                Image(systemName: "arrow.counterclockwise")
                    .frame(width: 24 ,height: 24)

                Text(title)
                    .font(AppTypography.caption2Semibold)
                    .lineLimit(1)
            }
            .foregroundStyle(.white)
            .padding(.vertical, AppSpacing.sm)
            .padding(.horizontal, AppSpacing.lg)
            .background(Color.Secondary02)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    RepeatTripButton { }
    
}

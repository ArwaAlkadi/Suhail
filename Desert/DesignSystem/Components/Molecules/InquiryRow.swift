//
//  InquiryRow.swift
//  Desert
//
//  Created by Samar A on 07/12/1447 AH.
//

import SwiftUI

struct InquiryRow: View {

    var titleKey: String

    @Binding var isOn: Bool

    var body: some View {


        VStack {

            HStack(spacing: AppSpacing.lg) {

                Text(titleKey.localized)
                    .font(AppTypography.body)
                    .foregroundStyle(Color.Primary)

                Spacer()

                AppToggle(isOn: $isOn)
            }

        }
        .padding(.horizontal, AppSpacing.md)
    }
}
#Preview {

    VStack(spacing: 20) {

        InquiryRow(
            titleKey: "inquiry.title",
            isOn: .constant(false)
        )

        InquiryRow(
            titleKey: "inquiry.title",
            isOn: .constant(true)
        )
    }
    .padding()
    .environment(\.locale, Locale(identifier: "ar"))
    .environment(\.layoutDirection, .rightToLeft)
}

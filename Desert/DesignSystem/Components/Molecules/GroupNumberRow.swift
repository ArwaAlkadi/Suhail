//
//  GroupNumberRow.swift
//  Desert
//
//  Created by Samar A on 06/12/1447 AH.
//



import SwiftUI

struct GroupNumberRow: View {

    @Binding var count: Int

    var body: some View {

        HStack {

            VStack(alignment: .leading, spacing: AppSpacing.sm) {

                Text("group.numberOfIndividuals".localized)
                    .font(
                        Font(
                            UIFont(
                                name: "thmanyahsans",
                                size: 17
                            ) ?? .systemFont(ofSize: 17)
                        )
                    )                      .foregroundStyle(Color.Primary)
            }

            Spacer()

            Stepper(
                count: $count,
                style: .active
            )
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
    }
}

#Preview {

    GroupNumberRow(
        count: .constant(2)
    )
}

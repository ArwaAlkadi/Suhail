//
//  Desert
//
//  Created by Samar A on 09/12/1447 AH.
//

import SwiftUI

struct GroupSection: View {

    @Binding var isGroup: Bool
    @Binding var groupCount: Int

    var body: some View {

        VStack(alignment: .leading, spacing: AppSpacing.sm) {

            Text("trip.group".localized)
                .font(AppTypography.headline)
                .foregroundStyle(Color.Primary)

            VStack(spacing: 0) {

                InquiryRow(
                    titleKey: "trip.group.question",
                    isOn: $isGroup
                )
                .frame(maxWidth: .infinity)
                .frame(height: 52)

                AppDivider()
                    .padding(.horizontal, AppSpacing.md)
                    .opacity(isGroup ? 1 : 0)

                GroupNumberRow(
                    count: $groupCount
                )
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .opacity(isGroup ? 1 : 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: isGroup ? 105 : 52, alignment: .top)
            .background(Color.white)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: AppRadius.md
                )
            )
            .onChange(of: isGroup) { newValue in

                if newValue && groupCount < 1 {
                    groupCount = 1
                }
            }

            VStack(
                alignment: .leading,
                spacing: AppSpacing.sm
            ) {

                Text("trip.groupContact.optional".localized)
                    .font(AppTypography.headline)
                    .foregroundStyle(Color.Primary)

                AddContactRow(
                    titleKey: "trip.groupContact.select"
                ) {

                }
                .padding(.horizontal, AppSpacing.md)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.white)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: AppRadius.md
                    )
                )
            }
            .padding(.top, AppSpacing.md)
            .opacity(isGroup ? 1 : 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 220, alignment: .top)
    }
}

#Preview {

}

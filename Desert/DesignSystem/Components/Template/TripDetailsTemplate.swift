//
//  Untitled.swift
//  Desert
//
//  Created by Samar A on 08/12/1447 AH.
//

import SwiftUI

struct TripDetailsTemplate: View {

    @State private var tripName = "15th May Trip"
    @State private var destination: String? = "trip.destination.alThoumamah"
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(3600)
    @State private var isGroup = false
    @State private var groupCount = 1

    var body: some View {

        VStack(spacing: 0) {

            HeaderView(titleKey: "trip.details")
                .padding(.top, AppSpacing.sm)
                .padding(.bottom, AppSpacing.lg)

            ProgressBar(currentStep: 3)
                .padding(.bottom, AppSpacing.xl)

            ScrollView(showsIndicators: false) {

                VStack(spacing: AppSpacing.lg) {

                    tripNameSection
                    destinationSection
                    timeSection
                    groupSection
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .frame(height: 220, alignment: .top)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, AppSpacing.xxl)
            }
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.top, AppSpacing.sm)
        .background(Color.Background)
        
        .environment(\.layoutDirection, .leftToRight)
        .environment(\.locale, Locale(identifier: "en"))
        .safeAreaInset(edge: .bottom) {
            CTAButton(title: "common.next".localized) { }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.lg)
                .padding(.bottom, AppSpacing.sm)
                .background(Color.Background)
        }
    }
}

private extension TripDetailsTemplate {

    var tripNameSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {

            Text("trip.name".localized)
                .font(AppTypography.headline)
                .foregroundStyle(Color.Primary)

            AppTextField(
                placeholderKey: "trip.name.placeholder",
                text: $tripName
            )
            .padding(.horizontal, AppSpacing.md)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
        }
    }

    var destinationSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {

            Text("trip.destination".localized)
                .font(AppTypography.headline)
                .foregroundStyle(Color.Primary)

            DestinationRow(
                titleKey: "trip.destination.placeholder",
                valueKey: destination
            )
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
        }
    }

    var timeSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {

            Text("trip.time".localized)
                .font(AppTypography.headline)
                .foregroundStyle(Color.Primary)

            DateRangeRow(
                startLabelKey: "trip.startTime",
                startDate: $startDate,
                endLabelKey: "trip.endTime",
                endDate: $endDate,
                isEndRequired: true,
                displayedComponents: [.date, .hourAndMinute],
                compactStyle: false
            )
            .frame(maxWidth: .infinity)
            .frame(height: 72)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
        }
    }

    var groupSection: some View {
        GroupSection(
            isGroup: $isGroup,
            groupCount: $groupCount
        )
    }
}

#Preview {
    TripDetailsTemplate()
}

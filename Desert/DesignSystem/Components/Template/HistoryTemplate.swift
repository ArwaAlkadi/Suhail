//
//  HistoryTemplate.swift
//  Desert
//
//  Created by Samar A on 12/12/1447 AH.
//

import SwiftUI

struct HistoryTemplate: View {
    
    @State private var selectedTab: AppPage = .history
    
    var hasTrips: Bool = true
    var tripsCount: Int = 2
    
    var onStartTrip: () -> Void = {}
    var onOpenTrip: () -> Void = {}
    var onRepeatTrip: () -> Void = {}
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            
            headerSection
            
            if hasTrips {
                tripsListSection
            } else {
                emptyStateSection
            }
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.top, AppSpacing.lg)
        .background(Color.Background)
        .safeAreaInset(edge: .bottom) {
            
            VStack(spacing: 0) {
                
                AppTabBar(selectedTab: $selectedTab)
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.top, AppSpacing.md)
                    .padding(.bottom, AppSpacing.sm)
            }
            .frame(maxWidth: .infinity)
            .background(Color.Background.ignoresSafeArea(edges: .bottom))
        }
    }
}

private extension HistoryTemplate {
    
    var headerSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            
            Text("history.title".localized)
                .font(AppTypography.title1)
                .foregroundStyle(Color.black)
            
            Text(String(format: "history.tripsCount".localized, tripsCount))
                .font(AppTypography.caption)
                .foregroundStyle(Color.lableSec)
        }
    }
    
    var tripsListSection: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: AppSpacing.md) {
                
                HistoryTripCard(
                    titleKey: "history.mock.title",
                    destinationKey: "history.mock.destination",
                    statusKey: "history.status.noAlert",
                    badgeStyle: .positive,
                    durationKey: "history.mock.duration",
                    distanceKey: "history.mock.distance",
                    peopleKey: "history.mock.people",
                    dateKey: "history.mock.date",
                    repeatAction: onRepeatTrip
                )
                .onTapGesture {
                    onOpenTrip()
                }
                
                HistoryTripCard(
                    titleKey: "history.mock.title",
                    destinationKey: "history.mock.destination",
                    statusKey: "history.status.alertSent",
                    badgeStyle: .destructive,
                    durationKey: "history.mock.duration",
                    distanceKey: "history.mock.distance",
                    peopleKey: "history.mock.people",
                    dateKey: "history.mock.date",
                    repeatAction: onRepeatTrip
                )
                .onTapGesture {
                    onOpenTrip()
                }
            }
            .padding(.bottom, 120)
        }
    }
    
    var emptyStateSection: some View {
        
        VStack(spacing: AppSpacing.xl) {

            Spacer(minLength: 40)

            Image("noPreviousTrip")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 400)

            VStack(spacing: AppSpacing.sx) {

                Text("history.noPreviousTrips".localized)
                    .font(AppTypography.title2)
                    .foregroundStyle(Color.black)

                Text("history.noTripsDescription".localized)
                    .font(AppTypography.caption)
                    .foregroundStyle(Color.lableSec)
            }

            CTAButton(
                title: "history.startNewTrip".localized,
                style: .primary,
                size: .small
            ) {
                onStartTrip()
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
//    HistoryTemplate(
//        hasTrips: true,
//        tripsCount: 2
//    )

        HistoryTemplate(
            hasTrips: false,
            tripsCount: 0
        )
    
}

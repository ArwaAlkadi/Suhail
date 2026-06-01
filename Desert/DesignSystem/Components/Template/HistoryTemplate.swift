//
//  HistoryTemplate.swift
//  Desert
//
//  Created by Samar A on 12/12/1447 AH.
//

import SwiftUI

struct HistoryTemplate<Content: View>: View {
    
    @Binding var selectedTab: AppPage
    
    var hasTrips: Bool
    var tripsCount: Int
    
    var onStartTrip: () -> Void = {}
    
    @ViewBuilder var content: Content
    
    var body: some View {
        
        ZStack {
            
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                
                headerSection
                
                if hasTrips {
                    ScrollView(showsIndicators: false) {
                        content
                            .padding(.bottom, 130)
                    }
                } else {
                    emptyStateSection
                }
            }
            .padding(.top, AppSpacing.lg)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(Color.Background)
            
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
        .padding(.horizontal, AppSpacing.lg)
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
            
            Spacer(minLength: 120)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    HistoryTemplate(
        selectedTab: .constant(.history),
        hasTrips: true,
        tripsCount: 2
    ) {
        VStack(spacing: AppSpacing.md) {
            HistoryTripCard(
                titleKey: "Evening Trip",
                destinationKey: "Al Thumamah",
                statusKey: "No Alert Sent",
                badgeStyle: .positive,
                durationKey: "1 Day",
                distanceKey: "22Km",
                peopleKey: "2 people",
                dateKey: "01 June, 7:18PM"
            )
            
            HistoryTripCard(
                titleKey: "Desert Camp",
                destinationKey: "Al Rumah",
                statusKey: "Alert Sent",
                badgeStyle: .destructive,
                durationKey: "2 Days",
                distanceKey: "34Km",
                peopleKey: "3 people",
                dateKey: "28 May, 5:30PM"
            )
        }
        .padding(.horizontal, AppSpacing.lg)
    }
}

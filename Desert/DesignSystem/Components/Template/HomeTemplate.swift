////
////  HomeTemplate.swift
////  Desert
////
////  Created by Samar A on 10/12/1447 AH.
////
//
//
//// TODO: Show only when network status changes.
//// Offline alert: 3–5s or dismiss on tap.
//// Reconnection toast: auto-dismiss after 2s.
//// Do not show if initial state is online.
//

import SwiftUI

struct HomeTemplate: View {
    
    @Binding var selectedTab: AppPage
    
    var activeTrip: Trip?
    var onStartTrip: () -> Void
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
           
            VStack(spacing: 0) {
                Spacer()
                
                if let activeTrip {
                    ActiveTripCardView(trip: activeTrip)
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.bottom, AppSpacing.sm)
                } else {
                    NoActiveTripsCard {
                        onStartTrip()
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.bottom, AppSpacing.sm)
                }
                
                AppTabBar(selectedTab: $selectedTab)
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.bottom, 32)
            }
        }
    }
}

#Preview {
    HomeTemplate(
        selectedTab: .constant(.map),
        activeTrip: nil,
        onStartTrip: {}
    )
}

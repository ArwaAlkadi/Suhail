//
//  HomeTemplate.swift
//  Desert
//
//  Created by Samar A on 10/12/1447 AH.
//

import SwiftUI
import MapKit

struct HomeTemplate: View {

    @Binding var selectedTab: AppPage
    @Binding var mapType: MKMapType

    var activeTrip: Trip?
    var daysLeft: String = ""
    var isUploaded: Bool = false
    var isConnected: Bool = false
    var onStartTrip: () -> Void
    var onCenterTapped: () -> Void
    var onUpdateReturnTime: (Date) -> Void = { _ in }
    var onEndTrip: () -> Void = {}

    var body: some View {
        ZStack {

            fabButtons

            VStack(spacing: 0) {
                Spacer()

                if let activeTrip {
                    ActiveTripCard(
                        tripName: activeTrip.tripName,
                        daysLeft: daysLeft,
                        isUploaded: isUploaded,
                        returnTime: activeTrip.returnTime,
                        isOverdue: activeTrip.isOverdue,
                        isConnected: isConnected,
                        emergencyContacts: activeTrip.emergencyContacts,
                        onUpdateReturnTime: onUpdateReturnTime,
                        onEndTrip: onEndTrip
                    )
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.bottom, 96)
                } else {
                    NoActiveTripsCard {
                        onStartTrip()
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.bottom, 100)
                }
                
            }

        }
    }
}

extension HomeTemplate {
    var fabButtons: some View {
        VStack {
            HStack {
                Spacer()
                VStack(spacing: AppSpacing.sm) {

                    FABButton(icon: .location) {
                        onCenterTapped()
                    }
                    .padding(.horizontal, AppSpacing.sm)

                    Menu {
                        Button {
                            mapType = .standard
                        } label: {
                            Label("map_standard".localized, systemImage: "map")
                        }
                        Button {
                            mapType = .satellite
                        } label: {
                            Label("map_satellite".localized, systemImage: "globe")
                        }
                        Button {
                            mapType = .hybrid
                        } label: {
                            Label("map_hybrid".localized, systemImage: "map.circle")
                        }
                    } label: {
                        FABButton(icon: .map) { }
                    }
                    
                }
                .padding(.trailing, AppSpacing.md)
                .padding(.top, 68)
            }
            Spacer()
        }
    }
}


#Preview {
    HomeTemplate(
        selectedTab: .constant(.map),
        mapType: .constant(.standard),
        activeTrip: nil,
        onStartTrip: {},
        onCenterTapped: {}
    )
    .background(.gray.opacity(0.5))
}

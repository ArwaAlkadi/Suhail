//
//  ActiveTripCardView.swift
//  Desert
//
//  Collapsible card shown at the bottom of the map during an active trip.
//
//  Collapsed: trip name, destination, Active/Overdue badge.
//  Expanded:  return time (editable), last upload time, GPS point count,
//             emergency contacts, upload status, end trip button.
//
//  Tapping the header toggles between collapsed and expanded states.
//  "I'm Back Safely" ends the trip via HomeViewModel → TripSessionManager.
//  Return time edits are saved locally and synced to Firebase if online.
//
//  Layout direction:
//  - All HStack elements respect the system language direction automatically (LTR/RTL).
//

import SwiftUI
import SwiftData

struct ActiveTripCardView: View {

    var trip: Trip

    @Environment(\.modelContext) private var context
    @StateObject private var vm = ActiveTripCardViewModel()

    var body: some View {
        ActiveTripCard(
            tripName: trip.tripName,
            daysLeft: vm.daysLeftText(for: trip.returnTime),
            isUploaded: vm.returnTimeUploadStatus == .uploaded,
            returnTime: trip.returnTime,
            isOverdue: trip.isOverdue,
            emergencyContacts: trip.emergencyContacts,
            onUpdateReturnTime: { newTime in
                vm.saveReturnTime(
                    trip: trip,
                    editedReturnTime: newTime
                )
            },
            onEndTrip: {
                vm.endTrip(trip, context: context)
            }
        )
        .onAppear {
            vm.startMonitoring()
        }
        .onDisappear {
            vm.stopMonitoring()
        }
    }
}

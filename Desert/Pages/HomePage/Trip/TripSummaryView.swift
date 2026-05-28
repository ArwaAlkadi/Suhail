//
//  TripSummaryView.swift
//  Desert
//

import SwiftUI
import SwiftData

struct TripSummaryView: View {

    @ObservedObject var vm: TripsViewModel
    var onTripStarted: () -> Void

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @StateObject private var networkMonitor = NetworkMonitorHelper()
    @State private var goHome = false

    var isConnected: Bool {
        !networkMonitor.showOfflineToast
    }

    var body: some View {
        SummaryTemplate(
            tripName: vm.tripName,
            startTime: Date(),
            returnTime: vm.returnTime,
            destination: vm.destination,
            carDetails: vm.carModel.isEmpty ? "—" : "\(vm.selectedColor) \(vm.carModel)",
            plateNumber: vm.plateLetters.isEmpty ? "—" : "\(vm.plateNumbers) | \(vm.plateLetters)",
            isGroup: vm.isGroup,
            groupCount: vm.groupCount,
            emergencyContacts: vm.emergencyContacts,
            groupContacts: vm.groupContacts,
            isConnected: isConnected,
            onBack: { dismiss() },
            onStartTrip: {
                guard !TripSessionManager.shared.hasActiveTrip else { return }
                let started = vm.startTrip(context: context)
                if started {
                    goHome = true
                    onTripStarted()
                }
            }
        )
        .navigationDestination(isPresented: $goHome) {
            HomeView()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .alert(vm.locationAlertTitle, isPresented: $vm.showLocationAlert) {
            Button("open_settings".localized) { vm.openAppSettings() }
            Button("cancel".localized, role: .cancel) { }
        } message: {
            Text(vm.locationAlertMessage)
        }
        .onAppear {
            networkMonitor.startMonitoring()
        }
        .onDisappear {
            networkMonitor.stopMonitoring()
        }
    }
}

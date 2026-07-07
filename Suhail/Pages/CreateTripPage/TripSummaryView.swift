//
//  TripSummaryView.swift
//  Desert
//

import SwiftUI
import SwiftData

struct TripSummaryView: View {

    // MARK: - Input

    @ObservedObject var vm: CreateTripViewModel
    var onTripStarted: () -> Void
    var onReturnTimeInvalid: () -> Void = {}

    // MARK: - Environment

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.onTripStarted) private var goToMap

    // MARK: - ViewModel

    @StateObject private var networkMonitor = NetworkMonitorHelper()

    // MARK: - State

    @State private var isLoading = false
    @State private var showTerms = false

    // MARK: - Developer Settings

    #if DEBUG
    /// Controls whether trip data is uploaded to Firebase during development.
    /// Wraps `FirebaseManager.shared.isProductionEnabled` as local state so the toggle reflects changes live.
    /// Only visible in DEBUG builds — stripped entirely from production.
    @State private var isProductionEnabled: Bool = FirebaseManager.shared.isProductionEnabled
    #endif

    // MARK: - Computed

    var isConnected: Bool { networkMonitor.isConnected }

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .top) {
            
            SummaryTemplate(
                tripName: vm.tripName,
                startTime: Date(),
                returnTime: vm.returnTime,
                destination: vm.destination,
                carDetails: vm.carModel.isEmpty ? "—" : "\(vm.selectedColor.localized) \(vm.carModel)",
                plateNumber: PlateFormatter.display(
                    numbers: vm.plateNumbers,
                    letters: vm.plateLetters
                ),
                isGroup: vm.isGroup,
                groupCount: vm.groupCount,
                emergencyContacts: vm.emergencyContacts,
                groupContacts: vm.groupContacts,
                isConnected: isConnected,
                onBack: { dismiss() },
                onStartTrip: {
                    let didStart = vm.startTrip(context: context) {
                        onTripStarted()
                        goToMap()
                    }
                    if !didStart {
                        isLoading = false
                        if !vm.returnTimeIsValid { onReturnTimeInvalid() }
                    }
                },
                onTermsTapped: { showTerms = true },
                isLoading: $isLoading
            )
            .sheet(isPresented: $showTerms) {
                SafariView(url: URL(string: "https://suhail-1.web.app/privacy.html")!)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .alert(vm.locationAlertTitle, isPresented: $vm.showLocationAlert) {
                Button("open_settings".localized) { vm.openAppSettings() }
                Button("cancel".localized, role: .cancel) { }
            } message: {
                Text(vm.locationAlertMessage)
            }
            .onChange(of: vm.showLocationAlert) { _, isShowing in
                if isShowing { isLoading = false }
            }
            .onAppear { networkMonitor.startMonitoring() }
            .onDisappear { networkMonitor.stopMonitoring() }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            #if DEBUG
            // MARK: - Dev Toggle (DEBUG only — hidden in production)
            VStack {
                Spacer()
                VStack {
                    Toggle(isOn: $isProductionEnabled) {
                        Text("⚠️ Dev Mode — Enable to upload trip to _trips_dev and trigger WhatsApp alerts")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .onChange(of: isProductionEnabled) { _, newValue in
                        FirebaseManager.shared.isProductionEnabled = newValue
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
                .padding(.bottom, 150)
            }
            #endif
        }
    }
}

// MARK: - Preview

#Preview {
    let vm = CreateTripViewModel()
    vm.tripName = "Desert Trip"
    vm.destination = "Al Thumamah"
    vm.returnTime = Date().addingTimeInterval(3600 * 8)
    vm.fullName = "Samar"
    vm.phoneNumber = "+966501234567"
    vm.carModel = "Toyota"
    vm.selectedColor = "White"
    vm.plateLetters = "ABC"
    vm.plateNumbers = "1234"
    vm.emergencyContacts = [Contact(name: "Ahmed", phone: "+966501234567")]

    return NavigationStack {
        TripSummaryView(vm: vm, onTripStarted: {})
    }
    .modelContainer(for: [
        Trip.self, SavedInfo.self, SavedContact.self,
        LocationPoint.self, AppSettings.self
    ], inMemory: true)
}

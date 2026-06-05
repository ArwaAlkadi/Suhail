//
//  HomeViewModel.swift
//  Desert
//
//  Provides computed map data for the active trip displayed in HomeView.
//  Also handles app-level setup and active trip card logic.
//

import SwiftUI
import MapKit
import SwiftData
import Network
import Combine

class HomeViewModel: ObservableObject {

    // MARK: - Upload Status

    enum UploadStatus {
        case idle, uploading, uploaded, pending

        var label: String {
            switch self {
            case .idle:      return ""
            case .uploading: return "uploading".localized
            case .uploaded:  return "uploaded".localized
            case .pending:   return "pending_upload".localized
            }
        }
    }

    @Published var returnTimeUploadStatus: UploadStatus = .idle
    @Published var isConnected = true

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "HomeViewNetworkMonitor")

    // MARK: - Network Monitoring

    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }

    func stopMonitoring() {
        monitor.cancel()
    }

    // MARK: - Map Data Helpers

    /// Returns the full local GPS track for the active trip as map coordinates.
    func localTrack(for trip: Trip?) -> [CLLocationCoordinate2D] {
        trip?.gpsTrack.map {
            CLLocationCoordinate2D(latitude: $0.lat, longitude: $0.lng)
        } ?? []
    }

    /// Returns the last successfully uploaded location to Firebase, if available.
    func lastUploadedLocation() -> CLLocationCoordinate2D? {
        TripSessionManager.shared.lastUploadedLocation
    }

    /// Returns the trip's selected destination coordinate, if set.
    func destinationLocation(for trip: Trip?) -> CLLocationCoordinate2D? {
        guard let trip, trip.destinationLat != 0 else { return nil }
        return CLLocationCoordinate2D(latitude: trip.destinationLat, longitude: trip.destinationLng)
    }

    // MARK: - Days Left Text

    func daysLeftText(for returnTime: Date) -> String {
        let seconds = returnTime.timeIntervalSince(Date())

        if seconds <= 0 {
            let overdueSeconds = abs(seconds)
            let days    = Int(overdueSeconds / 86400)
            let hours   = Int(overdueSeconds / 3600)
            let minutes = Int(overdueSeconds / 60)

            if days > 0 {
                return String.localizedStringWithFormat(NSLocalizedString("activeTrip.daysOverdue", tableName: "PluralStrings", comment: ""), days)
            } else if hours > 0 {
                return String.localizedStringWithFormat(NSLocalizedString("activeTrip.hoursOverdue", tableName: "PluralStrings", comment: ""), hours)
            } else {
                return String.localizedStringWithFormat(NSLocalizedString("activeTrip.minutesOverdue", tableName: "PluralStrings", comment: ""), minutes)
            }
        }

        let days    = Int(seconds / 86400)
        let hours   = Int(seconds / 3600)
        let minutes = Int(seconds / 60)

        if days > 0 {
            return String.localizedStringWithFormat(NSLocalizedString("activeTrip.daysLeft", tableName: "PluralStrings", comment: ""), days)
        } else if hours > 0 {
            return String.localizedStringWithFormat(NSLocalizedString("activeTrip.hoursLeft", tableName: "PluralStrings", comment: ""), hours)
        } else {
            return String.localizedStringWithFormat(NSLocalizedString("activeTrip.minutesLeft", tableName: "PluralStrings", comment: ""), minutes)
        }
    }

    // MARK: - Active Trip Card Actions

    func saveReturnTime(trip: Trip, editedReturnTime: Date) {
        guard editedReturnTime > Date() else { return }

        returnTimeUploadStatus = isConnected ? .uploading : .pending

        TripSessionManager.shared.updateReturnTime(
            trip: trip,
            newReturnTime: editedReturnTime
        ) { [weak self] in
            DispatchQueue.main.async {
                self?.returnTimeUploadStatus = .uploaded
            }
        } onFailure: { [weak self] in
            DispatchQueue.main.async {
                self?.returnTimeUploadStatus = .pending
            }
        }
    }

    func endTrip(_ trip: Trip, context: ModelContext) {
        TripSessionManager.shared.finishTrip(trip: trip, context: context)
    }

    // MARK: - App Setup

    /// Called on HomeView.onAppear.
    func onAppear(context: ModelContext) {
        TripSessionManager.shared.setModelContext(context)
        TripSessionManager.shared.resumeActiveSessionIfNeeded(context: context)
        NotificationsManager.shared.requestPermission()
        startMonitoring()
    }

    func onDisappear() {
        stopMonitoring()
    }
}

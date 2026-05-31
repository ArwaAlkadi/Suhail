//
//  TripHistoryViewModel.swift
//  Desert
//
//  Manages state and actions for the trip history list.
//  Handles multi-select deletion, date formatting, and replay logic.
//

import SwiftUI
import SwiftData
import MapKit
import Combine

class TripHistoryViewModel: ObservableObject {

    // MARK: - UI State

    @Published var selectedTrips: Set<String> = []
    @Published var showDeleteAlert = false
    @Published var alertStatuses: [String: Bool] = [:]

    // MARK: - Replay State

    @Published var replayIndex: Int = 0
    @Published var isReplaying: Bool = false
    var localTrack: [CLLocationCoordinate2D] = []
    var destinationLocation: CLLocationCoordinate2D? = nil
    private var replayTimer: Timer?

    private let firebase = FirebaseManager.shared

    var hasActiveTrip: Bool {
        TripSessionManager.shared.hasActiveTrip
    }

    // MARK: - Alert Status

    func fetchAlertStatus(
        tripId: String,
        completion: @escaping (Bool) -> Void
    ) {
        firebase.fetchAlertStatus(tripId: tripId) { [weak self] sent in
            DispatchQueue.main.async {
                self?.alertStatuses[tripId] = sent
                completion(sent)
            }
        }
    }

    func syncAlertStatusIfNeeded(for trip: Trip, context: ModelContext) {
        guard trip.didSyncAlertStatus == false else { return }

        firebase.fetchAlertStatus(tripId: trip.tripId) { sent in
            DispatchQueue.main.async {
                trip.alertSent = sent
                trip.didSyncAlertStatus = true
                try? context.save()
            }
        }
    }

    // MARK: - Delete

    func deleteSelected(trips: [Trip], context: ModelContext) {
        let toDelete = trips.filter { selectedTrips.contains($0.tripId) }
        for trip in toDelete {
            context.delete(trip)
        }
        selectedTrips.removeAll()
    }

    func deleteTrip(_ trip: Trip, context: ModelContext) {
        context.delete(trip)
        try? context.save()
    }

    // MARK: - Formatting

    func formatStartDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM, hh:mma"
        return formatter.string(from: date)
    }

    func tripDuration(_ trip: Trip) -> String {
        let endDate = trip.endedAt ?? trip.returnTime
        let seconds = endDate.timeIntervalSince(trip.startTime)
        let totalHours = max(0, Int(seconds / 3600))
        let days = totalHours / 24
        let hours = totalHours % 24

        if days > 0 && hours > 0 {
            return "\(days)D \(hours)h"
        } else if days > 0 {
            return "\(days)D"
        } else {
            return "\(hours)h"
        }
    }

    // MARK: - Replay

    func displayTrack(for track: [CLLocationCoordinate2D]) -> [CLLocationCoordinate2D] {
        guard !track.isEmpty else { return [] }
        if isReplaying || replayIndex > 0 {
            return Array(track.prefix(replayIndex + 1))
        }
        return track
    }

    func startReplay(localTrack: [CLLocationCoordinate2D]) {
        guard !localTrack.isEmpty else { return }
        if replayIndex >= localTrack.count - 1 { replayIndex = 0 }
        isReplaying = true

        replayTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { [weak self] _ in
            guard let self else { return }
            if self.replayIndex < localTrack.count - 1 {
                self.replayIndex += 1
            } else {
                self.replayTimer?.invalidate()
                self.isReplaying = false
            }
        }
    }

    func stopReplay() {
        replayTimer?.invalidate()
        isReplaying = false
    }

    func resetReplay() {
        stopReplay()
        replayIndex = 0
    }
}

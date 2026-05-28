//
//  TripHistoryViewModel.swift
//  Desert
//
//  Manages state and actions for the trip history list.
//  Handles multi-select deletion and date formatting.
//

import SwiftUI
import SwiftData
import Combine

class TripHistoryViewModel: ObservableObject {

    // MARK: - UI State

    @Published var selectedTrips: Set<String> = []
    @Published var showDeleteAlert = false
    @Published var alertStatuses: [String: Bool] = [:]

    private let firebase = FirebaseManager.shared

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
    
    func deleteSelected(trips: [Trip], context: ModelContext) {
        let toDelete = trips.filter { selectedTrips.contains($0.tripId) }
        for trip in toDelete {
            context.delete(trip)
        }
        selectedTrips.removeAll()
    }

    
    
    /// Deletes a single trip and saves the context.
    func deleteTrip(_ trip: Trip, context: ModelContext) {
        context.delete(trip)
        try? context.save()
    }

    // MARK: - Formatting

    /// Returns a readable date range string, e.g. "4 May — 5 May".
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
}

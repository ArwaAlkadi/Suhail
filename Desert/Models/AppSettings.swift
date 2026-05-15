//
//  AppSettings.swift
//  Desert
//

import SwiftData
import Foundation

/// Persists global app state — one instance per install.
/// Controls onboarding flow and tracks the active trip session.
@Model
class AppSettings {
    var isFirstLaunch: Bool
    var currentTripId: String  // empty = no active trip, has value = active trip

    init() {
        self.isFirstLaunch = true
        self.currentTripId = ""
    }

    // computed — not stored
    var hasActiveTrip: Bool { !currentTripId.isEmpty }
}

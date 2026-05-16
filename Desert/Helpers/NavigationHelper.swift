//
//  NavigationHelper.swift
//  Desert
//
//

import SwiftUI

// MARK: - App Page

enum AppPage {
    case map
    case history
}

// MARK: - onTripStarted Environment Key
// Allows deeply nested views (e.g. TripSummaryView) to navigate back to the map.

struct OnTripStartedKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var onTripStarted: () -> Void {
        get { self[OnTripStartedKey.self] }
        set { self[OnTripStartedKey.self] = newValue }
    }
}

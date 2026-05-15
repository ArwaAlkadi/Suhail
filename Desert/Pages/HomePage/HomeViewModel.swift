//
//  HomeViewModel.swift
//  Desert
//
//  Provides computed map data for the active trip displayed in HomeView.
//  Used by TripMapView to render the GPS track, last uploaded location, and destination pin.
//

import SwiftUI
import MapKit
import SwiftData

struct HomeViewModel {

    // MARK: - Map Data Helpers

    /// Returns the full local GPS track for the active trip as map coordinates.
    func localTrack(for trip: Trip?) -> [CLLocationCoordinate2D] {
        trip?.gpsTrack.map {
            CLLocationCoordinate2D(latitude: $0.lat, longitude: $0.lng)
        } ?? []
    }

    /// Returns the last successfully uploaded location to Firebase, if available.
    func lastUploadedLocation(for trip: Trip?) -> CLLocationCoordinate2D? {
        guard let trip, trip.lastKnownLat != 0 else { return nil }
        return CLLocationCoordinate2D(latitude: trip.lastKnownLat, longitude: trip.lastKnownLng)
    }

    /// Returns the trip's selected destination coordinate, if set.
    func destinationLocation(for trip: Trip?) -> CLLocationCoordinate2D? {
        guard let trip, trip.destinationLat != 0 else { return nil }
        return CLLocationCoordinate2D(latitude: trip.destinationLat, longitude: trip.destinationLng)
    }
}

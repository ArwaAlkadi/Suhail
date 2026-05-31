//
//  HistoryMapTrackView.swift
//  Desert
//
//  Historical trip track map — shown in TripHistoryInDetailsView.
//
//  Displays the full saved GPS track for a completed trip.
//  Supports replaying the route step-by-step, like a video.
//  Uses TripMapView internally — no map rendering logic lives here.
//  Replay logic lives in TripHistoryViewModel.
//
//  Controls:
//  - Play / Stop: starts or pauses the replay animation
//  - Reset: jumps back to the first point
//

import SwiftUI
import MapKit

struct HistoryMapTrackView: View {

    var localTrack: [CLLocationCoordinate2D]
    var destinationLocation: CLLocationCoordinate2D?
    var onBack: () -> Void

    @StateObject private var vm = TripHistoryViewModel()

    var displayTrack: [CLLocationCoordinate2D] {
        vm.displayTrack(for: localTrack)
    }

    var body: some View {
        TripTrackTemplate(
            isReplaying: vm.isReplaying,
            mapContent: {
                TripMapView(
                    localTrack: displayTrack,
                    lastUploadedLocation: nil,
                    destinationLocation: destinationLocation,
                    userLocation: nil
                )
            },
            onBack: onBack,
            onReset: {
                vm.resetReplay()
            },
            onToggleReplay: {
                vm.isReplaying ? vm.stopReplay() : vm.startReplay(localTrack: localTrack)
            }
        )
    }
}

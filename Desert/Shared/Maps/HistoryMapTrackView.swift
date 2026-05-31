//
//  HistoryMapTrackView.swift
//  Desert
//
//  Historical trip track map — shown in TripHistoryInDetailsView.
//
//  Displays the full saved GPS track for a completed trip.
//  Supports replaying the route step-by-step, like a video.
//  Uses TripMapView internally — no map rendering logic lives here.
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

    @State private var replayIndex: Int = 0
    @State private var isReplaying: Bool = false
    @State private var replayTimer: Timer?

    var displayTrack: [CLLocationCoordinate2D] {
        guard !localTrack.isEmpty else { return [] }
        if isReplaying || replayIndex > 0 {
            return Array(localTrack.prefix(replayIndex + 1))
        }
        return localTrack
    }

    var body: some View {
        TripTrackTemplate(
            isReplaying: isReplaying,
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
                stopReplay()
                replayIndex = 0
            },
            onToggleReplay: {
                isReplaying ? stopReplay() : startReplay()
            }
        )
    }

    // MARK: - Replay Control

    private func startReplay() {
        guard !localTrack.isEmpty else { return }
        if replayIndex >= localTrack.count - 1 { replayIndex = 0 }
        isReplaying = true

        replayTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
            if replayIndex < localTrack.count - 1 {
                replayIndex += 1
            } else {
                replayTimer?.invalidate()
                isReplaying = false
            }
        }
    }

    private func stopReplay() {
        replayTimer?.invalidate()
        isReplaying = false
    }
}

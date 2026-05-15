//
//  ActiveTripCardView.swift
//  Desert
//
//  Collapsible card shown at the bottom of the map during an active trip.
//
//  Collapsed: trip name, destination, Active badge.
//  Expanded:  return time, last upload time, GPS point count, emergency contacts, end trip button.
//
//  Tapping the header toggles between collapsed and expanded states.
//  "I'm Back Safely" ends the trip via TripSessionManager.
//
//  Layout direction:
//  - All HStack elements respect the system language direction automatically (LTR/RTL).
//

import SwiftUI
import SwiftData

struct ActiveTripCardView: View {

    var trip: Trip
    @Environment(\.modelContext) private var context
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // MARK: - Header (always visible)
            Button(action: {
                withAnimation(.spring()) { isExpanded.toggle() }
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(trip.tripName)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(trip.destination)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()

                    HStack(spacing: 4) {
                        Circle().fill(Color.green).frame(width: 8, height: 8)
                        Text("active".localized)
                            .font(.caption).foregroundColor(.green)
                    }
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(Color.green.opacity(0.1)).cornerRadius(8)

                    Image(systemName: isExpanded ? "chevron.down" : "chevron.up")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.leading, 4)
                }
            }

            // MARK: - Expanded Content
            if isExpanded {
                Divider().padding(.top, 10)

                VStack(alignment: .leading, spacing: 10) {

                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("return_time".localized)
                                .font(.caption).foregroundColor(.secondary)
                            Text(formatDate(trip.returnTime))
                                .font(.caption).fontWeight(.medium)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("last_upload".localized)
                                .font(.caption).foregroundColor(.secondary)
                            Text(trip.lastUploadTime != nil
                                 ? formatDate(trip.lastUploadTime!)
                                 : "not_yet".localized)
                                .font(.caption).fontWeight(.medium)
                        }
                    }

                    HStack {
                        Text(String(format: "gps_points".localized, trip.gpsTrack.count))
                            .font(.caption).foregroundColor(.secondary)
                        Spacer()
                        Text(trip.lastKnownLat != 0
                             ? "uploaded".localized
                             : "not_uploaded_yet".localized)
                            .font(.caption).foregroundColor(.secondary)
                    }

                    if !trip.emergencyContacts.isEmpty {
                        Text("\("emergency".localized): \(trip.emergencyContacts.map { $0.name }.joined(separator: ", "))")
                            .font(.caption).foregroundColor(.secondary)
                    }

                    Divider()

                    Button(action: { endTrip() }) {
                        Text("im_back_safely".localized)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.primary)
                            .foregroundColor(Color(UIColor.systemBackground))
                            .cornerRadius(10)
                    }
                }
                .padding(.top, 10)
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 4)
    }

    func endTrip() {
        TripSessionManager.shared.finishTrip(trip: trip, context: context)
    }

    func formatDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "dd/MM - hh:mm a"
        return f.string(from: date)
    }
}

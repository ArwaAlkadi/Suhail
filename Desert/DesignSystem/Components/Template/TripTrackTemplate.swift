//
//  TripTrackTemplate.swift
//  Desert
//
//  Created by Samar A on 11/12/1447 AH.
//

// هنا اضفت زر الفيديو واضفت متغيرات ناقصة .. ازرار الفيديو تحتاج ديزاين

import SwiftUI
import MapKit

struct TripTrackTemplate<MapContent: View>: View {

    var isReplaying: Bool
    var mapContent: () -> MapContent

    var onBack: () -> Void
    var onReset: () -> Void
    var onToggleReplay: () -> Void

    var body: some View {
        ZStack(alignment: .top) {

            mapContent()
                .ignoresSafeArea()

            HeaderView(
                titleKey: "history.tripTrack",
                leadingButton: .back,
                action: onBack
            )
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.xxl)

            VStack {
                Spacer()

                HStack(spacing: 16) {

                    Button {
                        onReset()
                    } label: {
                        Image(systemName: "backward.end.fill")
                            .foregroundColor(.primary)
                            .padding(12)
                            .background(Color(.systemBackground))
                            .clipShape(Circle())
                            .shadow(radius: 3)
                    }

                    Button {
                        onToggleReplay()
                    } label: {
                        Image(systemName: isReplaying ? "stop.fill" : "play.fill")
                            .foregroundColor(.white)
                            .padding(14)
                            .background(Color.black)
                            .clipShape(Circle())
                            .shadow(radius: 3)
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .environment(\.layoutDirection, .leftToRight)
    }
}

#Preview {
    TripTrackTemplate(
        isReplaying: false,
        mapContent: {
            Image("tripMap")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        },
        onBack: {},
        onReset: {},
        onToggleReplay: {}
    )
}

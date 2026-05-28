//
//  TripTrackTemplate.swift
//  Desert
//
//  Created by Samar A on 11/12/1447 AH.
//

import SwiftUI

struct TripTrackTemplate: View {
    
    var body: some View {
        
        GeometryReader { proxy in
            
            ZStack(alignment: .top) {
                
                Image("tripMap")
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
                    .ignoresSafeArea()
                
                HeaderView(titleKey: "history.tripTrack")
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.top, AppSpacing.sm)
            }
        }
        .environment(\.layoutDirection, .leftToRight)
    }
}

#Preview {
    TripTrackTemplate()
}

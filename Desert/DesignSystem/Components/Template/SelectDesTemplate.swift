//
//  SelectDestinationTemplate.swift
//  Desert
//
//  Created by Samar A on 12/12/1447 AH.
//

import SwiftUI

struct SelectDestinationTemplate: View {
    
    @State private var searchText = ""
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            GeometryReader { proxy in
                Image("tripMap")
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
                    .ignoresSafeArea()
            }
            
            SearchBar(
                style: .withBackButton,
                placeholderKey: "search.destination",
                text: $searchText
            )
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.sm)
        }
        .environment(\.layoutDirection, .leftToRight)
        .safeAreaInset(edge: .bottom) {
            CTAButton(title: "common.select".localized) {
                
            }
            .padding(.horizontal, AppSpacing.xl)
            .padding(.bottom, AppSpacing.lg)
        }
    }
}

#Preview {
    SelectDestinationTemplate()
}

//
//  SearchBar.swift
//  Desert
//
//  Created by Samar A on 11/12/1447 AH.
//

import SwiftUI

struct SearchBar: View {
    
    enum Style {
        case normal
        case withBackButton
    }
    
    var style: Style = .normal
    
    var placeholderKey: String
    @Binding var text: String
    
    var backAction: () -> Void = {}
    var searchAction: () -> Void = {}
    
    var body: some View {
        
        HStack(spacing: AppSpacing.md) {
            
            if style == .withBackButton {
                
                ToolbarButton(
                    style: .primary,
                    icon: .back
                ) {
                    backAction()
                }
            }
            
            HStack(spacing: AppSpacing.md) {
                
                TextField(
                    placeholderKey.localized,
                    text: $text
                )
                .font(AppTypography.body)
                .foregroundStyle(Color.Primary)
                
                Button {
                    searchAction()
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(Color.Primary)
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .frame(height: 56)
            .background(Color.white)
            .clipShape(Capsule())
        }
    }
}

#Preview {
    
    VStack(spacing: 24) {
        
        SearchBar(
            placeholderKey: "search.destination",
            text: .constant("")
        )
        
        SearchBar(
            style: .withBackButton,
            placeholderKey: "search.destination",
            text: .constant("")
        )
    }
    .padding()
    .background(Color.Background)
}

//
//  MaintenanceTemplate.swift
//  Desert
//
//  Created by Samar A on 29/12/1447 AH.
//

import SwiftUI

struct MaintenanceTemplate: View {
    
    var title: String
    var message: String
    
    var body: some View {
        
        VStack {
            
            Spacer()
            
            Image("maintenance")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 400)
            
            VStack(spacing: AppSpacing.sx) {
                Text(title)
                    .font(AppTypography.title3)
                    .foregroundStyle(Color.Primary)
                    .multilineTextAlignment(.center)
                
                Text(message)
                    .font(AppTypography.body)
                    .foregroundStyle(Color.lableSec)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, AppSpacing.md)
        .background(Color.Background)
    }
}

#Preview {
    MaintenanceTemplate(
        title: "maintenance.title".localized,
        message: "maintenance.subtitle".localized
    )
}

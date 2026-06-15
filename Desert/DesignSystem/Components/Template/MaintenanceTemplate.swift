//
//  MaintenanceTemplate.swift
//  Desert
//
//  Created by Samar A on 29/12/1447 AH.
//

import SwiftUI
struct MaintenanceTemplate: View {
    
    var body: some View {
        
        VStack {
            
            Spacer()
            
            Image("maintenance")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 260)
            
            VStack(spacing: AppSpacing.sx) {
                
                Text("maintenance.title".localized)
                    .font(AppTypography.title3)
                    .foregroundStyle(Color.Primary)
                    .multilineTextAlignment(.center)
                
                Text("maintenance.subtitle".localized)
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
    MaintenanceTemplate()
}

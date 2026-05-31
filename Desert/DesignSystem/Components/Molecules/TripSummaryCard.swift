//
//  TripSummaryCard.swift
//  Desert
//
//  Created by Samar A on 11/12/1447 AH.
//

import SwiftUI

struct TripSummaryCard: View {
    
    let rows: [(titleKey: String, valueKey: String)]
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                summaryRow(titleKey: row.titleKey, valueKey: row.valueKey)
                
                if index != rows.count - 1 {
                    AppDivider()
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
    }
}
private extension TripSummaryCard {
    
    
    func summaryRow(titleKey: String, valueKey: String) -> some View {
        HStack(spacing: 12) {
            Text(titleKey.localized)
                .font(AppTypography.body)
                .foregroundStyle(Color.Primary)
                .lineLimit(1)
            
            Spacer(minLength: 8)
            
            Text(valueKey.localized)
                .font(AppTypography.body)
                .foregroundStyle(Color.lableSec)
                .lineLimit(1)
        }
        .frame(height: 34)
    }
}

#Preview {
    
    VStack(spacing: 24) {
        
        TripSummaryCard(rows: [
            ("summary.startTime", "summary.mock.startTime"),
            ("summary.returnTime", "summary.mock.returnTime"),
            ("summary.destination", "summary.mock.destination"),
            ("summary.carDetails", "summary.mock.carDetails"),
            ("summary.plateNumber", "summary.mock.plateNumber"),
            ("summary.selectedDistance", "summary.mock.selectedDistance"),
            ("summary.numberOfIndividuals", "summary.mock.numberOfIndividuals")
        ])
        
        TripSummaryCard(rows: [
            ("summary.startTime", "summary.mock.startTime"),
            ("summary.returnTime", "summary.mock.returnTime"),
            ("summary.destination", "summary.mock.destination"),
            ("summary.numberOfIndividuals", "summary.mock.numberOfIndividuals"),
            ("summary.carDetails", "summary.mock.carDetails"),
            ("summary.plateNumber", "summary.mock.plateNumber"),
            ("summary.distance", "summary.mock.selectedDistance")
        ])
    }
    .padding()
    .background(Color.Background)
}

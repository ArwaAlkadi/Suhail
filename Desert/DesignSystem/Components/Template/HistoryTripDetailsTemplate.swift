//
//  HistoryTripDetailsTemplate.swift
//  Desert
//
//  Created by Samar A on 11/12/1447 AH.
//

import SwiftUI

struct HistoryTripDetailsTemplate: View {
    
    @State private var showDeleteAlert = false
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            HeaderView(
                trailingButton: .trash
            ) {
                
            } trailingAction: {
                showDeleteAlert = true
            }
            .padding(.top, 0)
            .padding(.bottom, AppSpacing.lg)
            
            ScrollView(showsIndicators: false) {
                
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    
                    tripHeaderSection
                    tripMapSection
                    tripSummarySection
                    emergencyContactsSection
                    groupContactsSection
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 120)
            }
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.top, AppSpacing.sm)
        .background(Color.Background)
        .environment(\.layoutDirection, .leftToRight)
        .safeAreaInset(edge: .bottom) {
            
            CTAButton(
                title: "history.repeatTrip".localized,
                style: .secondary
            ) {
                
                // TODO: Navigate to trip flow and pre-fill data from this history trip.
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.lg)
            .padding(.bottom, AppSpacing.sm)
            .background(Color.Background)
        }
        .alert("history.delete.title".localized, isPresented: $showDeleteAlert) {
            
            Button("common.cancel".localized, role: .cancel) { }
            
            Button("common.delete".localized, role: .destructive) { }
        }
    }
}

private extension HistoryTripDetailsTemplate {
    
    var tripHeaderSection: some View {
        HStack {
            
            Text("history.mock.title".localized)
                .font(AppTypography.title3)
                .foregroundStyle(Color.Primary)
            
            Spacer()
            
            StatusBadge(
                titleKey: "history.status.noAlert",
                style: .positive,
                size: .small
            )
        }
    }
    
    var tripMapSection: some View {
        
        ZStack(alignment: .topTrailing) {
            
            Image("tripMap")
                .resizable()
                .scaledToFill()
                .frame(height: 160)
                .frame(maxWidth: .infinity)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
            
            Button {
                
                //  Navigate to TripTrackTemplate.
                
            } label: {
                
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.Primary)
                    .padding(AppSpacing.sm)
            }
            .buttonStyle(.plain)
        }
    }
    
    var tripSummarySection: some View {
        
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            
            Text("history.tripSummary".localized)
                .font(AppTypography.headline)
                .foregroundStyle(Color.Primary)
            
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
    }
    
    var emergencyContactsSection: some View {
        
        contactsSection(
            titleKey: "summary.emergencyContacts",
            countKey: "history.mock.emergencyContactsCount",
            contacts: [
                ("D", "history.mock.contact.dad", "summary.mock.contact.phone1"),
                ("O", "history.mock.contact.omar", "summary.mock.contact.phone2")
            ]
        )
    }
    
    var groupContactsSection: some View {
        
        contactsSection(
            titleKey: "history.groupContacts",
            countKey: "history.mock.groupContactsCount",
            contacts: [
                ("F", "history.mock.contact.faisal", "summary.mock.contact.phone1"),
                ("S", "history.mock.contact.sultan", "summary.mock.contact.phone2"),
                ("A", "history.mock.contact.abdulrahman", "summary.mock.contact.phone3")
            ]
        )
    }
    
    func contactsSection(
        titleKey: String,
        countKey: String,
        contacts: [(initial: String, nameKey: String, phoneKey: String)]
    ) -> some View {
        
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            
            HStack {
                
                Text(titleKey.localized)
                    .font(AppTypography.headline)
                    .foregroundStyle(Color.Primary)
                
                Spacer()
                
                Text(countKey.localized)
                    .font(AppTypography.caption2)
                    .foregroundStyle(Color.lableSec)
            }
            
            VStack(spacing: 0) {
                
                ForEach(Array(contacts.enumerated()), id: \.offset) { index, contact in
                    
                    ContactRow(
                        initial: contact.initial,
                        titleKey: contact.nameKey,
                        captionKey: contact.phoneKey
                    )
                    .frame(height: 70)
                    
                    if index != contacts.count - 1 {
                        
                        AppDivider()
                            .padding(.horizontal, AppSpacing.md)
                    }
                }
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        }
    }
}

#Preview {
    HistoryTripDetailsTemplate()
}

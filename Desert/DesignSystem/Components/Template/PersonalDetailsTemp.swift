//
//  PersonalDetailsTemplate.swift
//  Desert
//
//  Created by Samar A on 07/12/1447 AH.
//

import SwiftUI

struct PersonalDetailsTemplate: View {
    
    @State private var fullName = "Fahad Mohammed"
    @State private var phoneNumber = ""
    @State private var showPhoneError = false
    @State private var contacts: [MockContact] = []
    
    struct MockContact: Identifiable {
        let id = UUID()
        let initial: String
        let nameKey: String
        let phoneKey: String
    }

    var body: some View {
        
        VStack(spacing: 0) {
            
            HeaderView(titleKey: "trip.personalDetails")
                .padding(.top, 0)
                .padding(.bottom, AppSpacing.md)
            
            ProgressBar(currentStep: 1)
                .padding(.bottom, AppSpacing.xl)

            ScrollView(showsIndicators: false) {
                
                VStack(spacing: AppSpacing.lg) {
                    fullNameSection
                    phoneNumberSection
                    contactsSection
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, AppSpacing.xxl)
            }
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.top, AppSpacing.sm)
        .background(Color.Background)
        .environment(\.layoutDirection, .leftToRight)
        .safeAreaInset(edge: .bottom) {
            CTAButton(title: "common.next".localized) {
                showPhoneError = phoneNumber.isEmpty
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.lg)
            .padding(.bottom, AppSpacing.sm)
            .background(Color.Background)
        }
    }
}

private extension PersonalDetailsTemplate {
    
    var fullNameSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("trip.fullName".localized)
                .font(AppTypography.headline)
                .foregroundStyle(Color.Primary)
            
            AppTextField(
                placeholderKey: "trip.fullName.placeholder",
                text: $fullName
            )
            .padding(.horizontal, AppSpacing.md)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
        }
    }
    
    var phoneNumberSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("trip.phone".localized)
                .font(AppTypography.headline)
                .foregroundStyle(Color.Primary)
            
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                AppTextField(
                    placeholderKey: "trip.phone.placeholder",
                    text: $phoneNumber,
                    state: showPhoneError ? .error : .normal
                )
                .padding(.horizontal, AppSpacing.md)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                
                if showPhoneError {
                    ErrorMessageRow(messageKey: "error.phoneRequired")
                }
            }
        }
    }
    
    var contactsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("trip.contacts".localized)
                .font(AppTypography.headline)
                .foregroundStyle(Color.Primary)
            
            if contacts.isEmpty {
                addContactButton
            } else {
                contactsList
            }
            
            Text("trip.contactsLimit".localized)
                .font(AppTypography.caption)
                .foregroundStyle(Color.Disabled)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var addContactButton: some View {
        AddContactRow(titleKey: "trip.addContact") {
            contacts = [
                MockContact(initial: "O", nameKey: "contact.omSaqr", phoneKey: "contact.phone1"),
                MockContact(initial: "F", nameKey: "contact.fajer", phoneKey: "contact.phone2"),
                MockContact(initial: "S", nameKey: "contact.saqr", phoneKey: "contact.phone3")
            ]
        }
        .padding(.horizontal, AppSpacing.md)
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var contactsList: some View {
        VStack(spacing: 0) {
            ForEach(contacts) { contact in
                ContactRow(
                    initial: contact.initial,
                    titleKey: contact.nameKey,
                    captionKey: contact.phoneKey
                ) {
                    contacts.removeAll { $0.id == contact.id }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                
                if contact.id != contacts.last?.id {
                    AppDivider()
                        .padding(.horizontal, AppSpacing.md)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 64, maxHeight: 208)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
        .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    PersonalDetailsTemplate()
}

//
//  CreateTripStepTemplate.swift
//  Desert
//
//  Created by Samar A on 12/12/1447 AH.
//

import SwiftUI

struct CreateTripStepTemplate<Content: View>: View {
    
    var titleKey: String
    var currentStep: Int
    var totalSteps: Int = 3
    
    var buttonTitleKey: String
    var isLoading: Bool = false
    var isDisabled: Bool = false
    var leadingButton: HeaderView.LeadingButton
    var showsProgressBar: Bool = true
    
    var isInputFocused: Bool = false
    
    var onBack: () -> Void = {}
    var onNext: () -> Void = {}
    
    @ViewBuilder var content: Content
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            HeaderView(
                titleKey: titleKey,
                leadingButton: leadingButton,
                action: onBack
            )
            .padding(.bottom, AppSpacing.md)
            .padding(.horizontal, AppSpacing.md)
            
            if showsProgressBar {
                ProgressBar(currentStep: currentStep)
                    .padding(.bottom, AppSpacing.xl)
                    .padding(.horizontal, AppSpacing.md)
                
            }
            
            content
                .frame(maxWidth: .infinity, alignment: AppLanguage.frameAlignment)
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 0) {
                if !isInputFocused {
                    CTAButton(
                        title: isLoading ? "" : buttonTitleKey.localized,
                        style: isLoading ? .primary : (isDisabled ? .disabled : .primary)
                    ) {
                        guard !isLoading else { return }
                        onNext()
                    }
                    .disabled(isLoading || isDisabled)
                    .overlay {
                        if isLoading {
                            HStack(spacing: AppSpacing.sm) {
                                ProgressView()
                                    .tint(.white)
                                
                                Text(buttonTitleKey.localized)
                                    .font(AppTypography.headline)
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                    .disabled(isLoading)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.xl)
                }
            }
                    .frame(maxWidth: .infinity)
                    .background(Color.Background.ignoresSafeArea(edges: .bottom))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color.Background.ignoresSafeArea())
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .environment(\.layoutDirection, AppLanguage.layoutDirection)
        }
    }


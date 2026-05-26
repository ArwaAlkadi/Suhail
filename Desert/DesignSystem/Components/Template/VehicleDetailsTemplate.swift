//
//  VehicleDetailsTemplate.swift
//  Desert
//
//  Created by Samar A on 08/12/1447 AH.
//

import SwiftUI

struct VehicleDetailsTemplate: View {
    
    @State private var carModel = ""
    @State private var selectedColor = "vehicle.color.placeholder"
    @State private var isFourWheelDrive = false
    
    @State private var firstLetter = "A"
    @State private var secondLetter = "A"
    @State private var thirdLetter = "A"
    @State private var digits = ["", "", "", ""]
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            HeaderView(titleKey: "vehicle.details")
                .padding(.top, 0)
                .padding(.bottom, AppSpacing.md)
            
            ProgressBar(currentStep: 2)
                .padding(.bottom, AppSpacing.xl)

            ScrollView(showsIndicators: false) {
                
                VStack(spacing: 32) {
                    carModelSection
                    carColorSection
                    fourWheelDriveSection
                    plateInfoSection
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, AppSpacing.xxl)
            }
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.top, AppSpacing.sm)
        .background(Color.Background)
       
        .safeAreaInset(edge: .bottom) {
            CTAButton(title: "common.next".localized) {
                
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.lg)
            .padding(.bottom, AppSpacing.sm)
            .background(Color.Background)
        }
    }
}

private extension VehicleDetailsTemplate {
    
    var carModelSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("vehicle.carModel".localized)
                .font(AppTypography.headline)
                .foregroundStyle(Color.Primary)
            
            AppTextField(
                placeholderKey: "vehicle.carModel.placeholder",
                text: $carModel
            )
            .padding(.leading, 2)
            .padding(.horizontal, AppSpacing.md)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
        }
    }
    
    var carColorSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("vehicle.carColor".localized)
                .font(AppTypography.headline)
                .foregroundStyle(Color.Primary)
            
            ColorPickerRow(
                placeholderKey: "vehicle.color.placeholder",
                selectedColorKey: $selectedColor,
                options: vehicleColors
            )
        }
    }
    
    var fourWheelDriveSection: some View {
        InquiryRow(
            titleKey: "vehicle.isFourWheelDrive",
            isOn: $isFourWheelDrive
        )
        .padding(.horizontal, AppSpacing.md)
        .frame(maxWidth: .infinity)
        .frame(height: 52)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
    }
    
    var plateInfoSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("vehicle.plateInfo".localized)
                .font(AppTypography.headline)
                .foregroundStyle(Color.Primary)
            
            PlateInfoRow(
                firstLetter: $firstLetter,
                secondLetter: $secondLetter,
                thirdLetter: $thirdLetter,
                digits: $digits
            )
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
        }
    }
    
    var vehicleColors: [String] {
        [
            "vehicle.color.black",
            "vehicle.color.white",
            "vehicle.color.grey",
            "vehicle.color.red",
            "vehicle.color.orange",
            "vehicle.color.yellow",
            "vehicle.color.blue",
            "vehicle.color.green"
        ]
    }
}

#Preview {
    VehicleDetailsTemplate()
}

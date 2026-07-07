//
//  VehicleDetailsTemplate.swift
//  Desert
//
//  Created by Samar A on 08/12/1447 AH.
//

import SwiftUI

struct VehicleDetailsTemplate: View {

    @Binding var carModel: String
    @Binding var selectedColor: String
    @Binding var isFourWheelDrive: Bool
    @Binding var firstPlateLetter: String
    @Binding var secondPlateLetter: String
    @Binding var thirdPlateLetter: String
    @Binding var plateDigits: [String]
    var showErrors: Bool = false

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: AppSpacing.xl) {
                    carModelSection
                    carColorSection
                    fourWheelDriveSection
                    plateInfoSection
                        .id("plateInfoSection")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 0)
                .padding(.bottom, 260)
                .padding(.horizontal, AppSpacing.md)
            }
            .scrollDismissesKeyboard(.interactively)
            .onTapGesture {
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil,
                    from: nil,
                    for: nil
                )
            }
            .background(Color.Background)
        }
    }
}



private extension VehicleDetailsTemplate {

    var carModelSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sx) {
            Text("vehicle.carModel".localized)
                .font(AppTypography.headline)
                .foregroundStyle(Color.Lableblack)

            AppTextField(
                placeholderKey: "vehicle.carModel.placeholder",
                text: $carModel,
                state: showErrors && carModel.isEmpty ? .error : .normal
            )
            .frame(maxWidth: .infinity)
            .frame(minHeight: 52)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))

            if showErrors && carModel.isEmpty {
                ErrorMessageRow(messageKey: "car_model_required")
            }
        }
    }

    var carColorSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("vehicle.carColor".localized)
                .font(AppTypography.headline)
                .foregroundStyle(Color.Lableblack)

            ColorPickerRow(
                placeholderKey: "vehicle.color.placeholder",
                selectedColorKey: $selectedColor
            )

            if showErrors && selectedColor.isEmpty {
                ErrorMessageRow(messageKey: "car_color_required")
            }
        }
    }

    var fourWheelDriveSection: some View {
        InquiryRow(
            titleKey: "vehicle.isFourWheelDrive",
            isOn: $isFourWheelDrive
        )
        .frame(maxWidth: .infinity)
        .frame(minHeight: 52)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
    }

    var plateInfoSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("vehicle.plateInfo".localized)
                .font(AppTypography.headline)
                .foregroundStyle(Color.Lableblack)

            PlateInfoRow(
                firstLetter: $firstPlateLetter,
                secondLetter: $secondPlateLetter,
                thirdLetter: $thirdPlateLetter,
                digits: $plateDigits
            )
            .frame(maxWidth: .infinity)
            .frame(height: 151)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))

            if showErrors && (
                firstPlateLetter.isEmpty ||
                secondPlateLetter.isEmpty ||
                thirdPlateLetter.isEmpty ||
                plateDigits.filter { !$0.isEmpty }.isEmpty
            ) {
                ErrorMessageRow(messageKey: "plate_required")
            }
        }
    }
}

#Preview {
    VehicleDetailsTemplate(
        carModel: .constant("f"),
        selectedColor: .constant("f"),
        isFourWheelDrive: .constant(true),
        firstPlateLetter: .constant("f"),
        secondPlateLetter: .constant("f"),
        thirdPlateLetter: .constant("f"),
        plateDigits: .constant([])
    )
}

//
//  Untitled.swift
//  Desert
//
//  Created by Samar A on 08/12/1447 AH.
//



import SwiftUI

struct ColorPickerRow: View {

    var placeholderKey: String

    @Binding var selectedColorKey: String

    var options: [String]

    var body: some View {

        Menu {

            ForEach(options, id: \.self) { colorKey in

                Button(colorKey.localized) {
                    selectedColorKey = colorKey
                }
            }

        } label: {

            HStack {

                Text(selectedColorKey.localized)
                    .font(AppTypography.body)
                    .foregroundStyle(textColor)

                Spacer()

                Image(systemName: "chevron.down")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.Primary)
            }
            .padding(.horizontal, AppSpacing.md)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
        }
        .buttonStyle(.plain)
    }
}

private extension ColorPickerRow {

    var textColor: Color {

        selectedColorKey == placeholderKey
        ? Color.Disabled
        : Color.Primary
    }
}

#Preview {

    ColorPickerRow(
        placeholderKey: "vehicle.color.placeholder",
        selectedColorKey: .constant("vehicle.color.placeholder"),
        options: [
            "vehicle.color.black",
            "vehicle.color.white",
            "vehicle.color.grey",
            "vehicle.color.red"
        ]
    )
    .padding()
}

//
//  PlateNumberField.swift
//  Desert
//
//  Created by Samar A on 07/12/1447 AH.
//

import SwiftUI

struct PlateNumberFields: View {

    @Binding var digits: [String]

    @FocusState private var focusedIndex: Int?

    var body: some View {

        HStack(spacing: AppSpacing.sm) {

            ForEach(0..<4, id: \.self) { index in

                TextField("-", text: binding(for: index))
                    .font(AppTypography.body)
                    .multilineTextAlignment(.center)
                    .environment(\.layoutDirection, .leftToRight)
                    .keyboardType(.numberPad)
                    .focused($focusedIndex, equals: index)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 52)                .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.sm)
                            .stroke(Color.Grey100, lineWidth: 1)
                    )
            }
        }
        .onAppear {
            if digits.count != 4 {
                digits = ["", "", "", ""]
            }
        }
    }

    private func binding(for index: Int) -> Binding<String> {

        Binding(
            get: {
                digits[index]
            },
            set: { newValue in

                let filtered = newValue.filter { $0.isNumber }

                if let last = filtered.last {
                    digits[index] = String(last)

                    if index < 3 {
                        focusedIndex = index + 1
                    } else {
                        focusedIndex = nil
                    }

                } else {
                    digits[index] = ""
                }
            }
        )
    }
}

#Preview {

    PlateNumberFields(
        digits: .constant(["4", "3", "", ""])
    )
    .padding()
}

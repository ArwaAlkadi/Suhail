//
//  DateRangeRow.swift
//  Desert
//
//  Created by Samar A on 07/12/1447 AH.
//

import SwiftUI

struct DateRangeRow: View {

    var startLabelKey: String
    @Binding var startDate: Date

    var endLabelKey: String
    @Binding var endDate: Date

    var isEndRequired: Bool = false

    var displayedComponents: DatePickerComponents = [.date, .hourAndMinute]
    var compactStyle: Bool = false

    @State private var showDatePicker = false

    var body: some View {

        VStack(spacing: AppSpacing.sm) {

            Button {

                withAnimation {
                    showDatePicker.toggle()
                }

            } label: {

                HStack {

                    LabelValueItem(
                        labelKey: startLabelKey,
                        value: startDate.formattedDateTime,
                        isDisabled: true
                    )

                    Rectangle()
                        .fill(Color.Grey100)
                        .frame(width: 1, height: 57)

                    LabelValueItem(
                        labelKey: endLabelKey,
                        value: endDate.formattedDateTime,
                        isRequired: isEndRequired
                    )
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm)
                .background(Color.white)
                .cornerRadius(AppRadius.md)
            }
            .buttonStyle(.plain)
            .sheet(isPresented: $showDatePicker) {

                ZStack(alignment: .topLeading) {

                    VStack(spacing: AppSpacing.sm) {

                        if compactStyle {
                            DatePicker(
                                endLabelKey.localized,
                                selection: $endDate,
                                in: Date()...,
                                displayedComponents: displayedComponents
                            )
                            .datePickerStyle(.compact)
                            .labelsHidden()
                        } else {
                            DatePicker(
                                endLabelKey.localized,
                                selection: $endDate,
                                in: Date()...,
                                displayedComponents: displayedComponents
                            )
                            .datePickerStyle(.graphical)
                            .labelsHidden()
                        }
                    }
                    .tint(Color.Secondary02)
                    .padding(.top, 84)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.bottom, AppSpacing.md)

                    Button {
                        showDatePicker = false
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color.Primary)
                            .frame(width: 44, height: 44)
                            .background(Color.Background)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 28)
                    .padding(.leading, AppSpacing.lg)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(Color.white)
                .presentationDetents([.height(500)])
                .presentationDragIndicator(.hidden)
                .environment(\.locale, Locale(identifier: "en"))
            }
        }
    }
}

private struct LabelValueItem: View {

    var labelKey: String
    var value: String
    var isRequired: Bool = false
    var isDisabled: Bool = false

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: AppSpacing.sm
        ) {

            HStack(spacing: 4) {

                Text(labelKey.localized)
                    .font(AppTypography.footnote)
                    .foregroundStyle(Color.Disabled)

                if isRequired {

                    Text("*")
                        .font(AppTypography.footnote)
                        .foregroundStyle(Color.Destructive)
                }
            }

            Text(value)
                .font(AppTypography.footnote)
                .foregroundStyle(isDisabled ? Color.Disabled : Color.Primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private extension Date {

    var formattedDateTime: String {

        formatted(
            date: .abbreviated,
            time: .shortened
        )
    }
}

#Preview {

    DateRangeRow(
        startLabelKey: "date.start",
        startDate: .constant(Date()),
        endLabelKey: "date.end",
        endDate: .constant(Date()),
        isEndRequired: true
    )
    .padding()
}

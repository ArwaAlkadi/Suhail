//
//  DateTimePickerSheet.swift
//  Desert
//
//  Created by Samar A on 20/12/1447 AH.
//

import SwiftUI
struct DateTimePickerSheet: View {

    enum PickerMode {
        case date
        case time
        case dateAndTime
    }

    @Binding var selectedDate: Date
    var showsTimeLabel: Bool = true
    var mode: PickerMode = .dateAndTime

    private var isArabic: Bool {
        Locale.current.language.languageCode?.identifier == "ar"
    }

    var body: some View {
        VStack(spacing: AppSpacing.md) {

            if mode == .date || mode == .dateAndTime {
                DatePicker(
                    "",
                    selection: Binding(
                        get: { selectedDate },
                        set: { newDate in
                            selectedDate = merge(date: newDate, time: selectedDate)
                        }
                    ),
                    in: Calendar(identifier: .gregorian).startOfDay(for: Date())...,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .labelsHidden()
                .tint(Color.Secondary02)
            }

            if mode == .dateAndTime {
                AppDivider()
            }

            if mode == .time || mode == .dateAndTime {

                if showsTimeLabel {

                    DatePicker(
                        "time".localized,
                        selection: Binding(
                            get: { selectedDate },
                            set: { newTime in
                                selectedDate = merge(date: selectedDate, time: newTime)
                            }
                        ),
                        displayedComponents: [.hourAndMinute]
                    )
                    .datePickerStyle(.compact)
                    .tint(Color.Secondary02)

                } else {

                    DatePicker(
                        "",
                        selection: Binding(
                            get: { selectedDate },
                            set: { newTime in
                                selectedDate = merge(date: selectedDate, time: newTime)
                            }
                        ),
                        displayedComponents: [.hourAndMinute]
                    )
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .tint(Color.Secondary02)
                }
            }

        }
        .padding(AppSpacing.lg)
        .background(Color.white)
        .environment(\.locale, Locale(identifier: isArabic ? "ar_SA" : "en_US"))
        .environment(\.calendar, Calendar(identifier: .gregorian))
        .environment(\.layoutDirection, isArabic ? .rightToLeft : .leftToRight)
    }

    private func merge(date: Date, time: Date) -> Date {
        let calendar = Calendar(identifier: .gregorian)

        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)

        var components = DateComponents()
        components.calendar = calendar
        components.year = dateComponents.year
        components.month = dateComponents.month
        components.day = dateComponents.day
        components.hour = timeComponents.hour
        components.minute = timeComponents.minute

        return calendar.date(from: components) ?? selectedDate
    }
}

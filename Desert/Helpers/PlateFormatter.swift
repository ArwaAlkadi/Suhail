//
//  PlateFormatter.swift
//  Desert
//
//  Created by Samar A on 22/12/1447 AH.
//

import Foundation

enum PlateFormatter {

    static func display(numbers: String, letters: String) -> String {
        guard !letters.isEmpty else { return "—" }

        let displayNumbers = AppLanguage.isArabic
            ? localizeDigits(numbers)
            : numbers

        let displayLetters = letters.map {
            "plate.letter.\(String($0))".localized
        }
        .joined(separator: " ")

        return "\(displayNumbers) | \(displayLetters)"
    }

    private static func localizeDigits(_ text: String) -> String {
        let western = ["0","1","2","3","4","5","6","7","8","9"]
        let arabic = ["٠","١","٢","٣","٤","٥","٦","٧","٨","٩"]

        var result = text

        for index in western.indices {
            result = result.replacingOccurrences(
                of: western[index],
                with: arabic[index]
            )
        }

        return result
    }
}

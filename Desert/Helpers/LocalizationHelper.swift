//
//  LocalizationHelper.swift
//  Desert
//
//

import SwiftUI

// MARK: - Localization Helper

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}

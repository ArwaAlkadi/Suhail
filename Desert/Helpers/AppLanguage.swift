//
//  AppLanguage.swift
//  Desert
//
//  Created by Samar A on 21/12/1447 AH.
//

import SwiftUI

enum AppLanguage {

    static var isArabic: Bool {
        Locale.current.language.languageCode?.identifier == "ar"
    }

    static var layoutDirection: LayoutDirection {
        isArabic ? .rightToLeft : .leftToRight
    }

    static var textAlignment: TextAlignment {
        isArabic ? .trailing : .leading
    }

    static var horizontalAlignment: HorizontalAlignment {
        isArabic ? .trailing : .leading
    }

    static var frameAlignment: Alignment {
        isArabic ? .trailing : .leading
    }
}

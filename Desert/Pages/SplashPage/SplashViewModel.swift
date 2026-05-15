//
//  SplashViewModel.swift
//  Desert
//
//  Handles splash screen timing logic.
//  Dismisses the splash after a 2-second delay.
//

import Foundation
import SwiftUI

struct SplashViewModel {

    /// Triggers splash dismissal after a fixed delay.
    func startTimer(dismiss: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { dismiss() }
        }
    }
}

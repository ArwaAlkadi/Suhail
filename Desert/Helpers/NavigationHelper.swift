//
//  NavigationHelper.swift
//  Desert
//
//

import SwiftUI

// MARK: - App Page

enum AppPage {
    case map
    case history
}

// MARK: - onTripStarted Environment Key
// Allows deeply nested views (e.g. TripSummaryView) to navigate back to the map.

struct OnTripStartedKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var onTripStarted: () -> Void {
        get { self[OnTripStartedKey.self] }
        set { self[OnTripStartedKey.self] = newValue }
    }
}

// MARK: - Swipe Back Fix
extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(
        _ gestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        viewControllers.count > 1
    }
}

// MARK: - Disable Swipe Back for Specific Views
struct NavigationGestureDisabler: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> UIViewController {
        DisablerViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    class DisablerViewController: UIViewController {
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        }
    }
}

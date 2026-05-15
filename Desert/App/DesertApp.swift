//
//  DesertApp.swift
//  Desert
//

import SwiftUI
import Firebase
import SwiftData
import Combine
import Network

/// App entry point — configures Firebase and registers SwiftData models.
@main
struct DesertApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [
            AppSettings.self,
            SavedInfo.self,
            SavedContact.self,
            Trip.self,
            Contact.self,
            LocationPoint.self
        ])
    }
}

// MARK: - AppDelegate

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {

        // 1. configure Firebase
        FirebaseApp.configure()

        // 2. sign in anonymously — persists userId on device
        FirebaseManager.shared.signInAnonymously()

        // 3. set TripSessionManager as LocationManager delegate
        LocationManager.shared.delegate = TripSessionManager.shared

        // 4. if iOS relaunched due to location update — restore session
        if launchOptions?[.location] != nil {
            LocationManager.shared.restoreSessionAfterForceQuit()
        }

        return true
    }
}


// MARK: - Localization Helper

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}


// MARK: - NetworkMonitor Helper
class NetworkMonitorViewModel: ObservableObject {

    @Published var showOfflineToast = false
    @Published var showOnlineToast = false

    private var wasOffline = false
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.handleConnectionChange(path.status == .satisfied)
            }
        }

        monitor.start(queue: queue)
    }

    func stopMonitoring() {
        monitor.cancel()
    }

    private func handleConnectionChange(_ isConnected: Bool) {
        if !isConnected {
            wasOffline = true

            withAnimation {
                showOfflineToast = true
                showOnlineToast = false
            }
        } else if wasOffline {
            withAnimation {
                showOfflineToast = false
                showOnlineToast = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    self.showOnlineToast = false
                }
            }

            wasOffline = false
        }
    }
}

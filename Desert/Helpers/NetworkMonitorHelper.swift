//
//  NetworkMonitorHelper.swift
//  Desert
//
//

import Network
import Combine
import SwiftUI

class NetworkMonitorHelper: ObservableObject {

    @Published var isConnected = true
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

    func dismissOfflineToast() {
        withAnimation {
            showOfflineToast = false
        }
    }

    private func handleConnectionChange(_ isConnected: Bool) {
        self.isConnected = isConnected

        if !isConnected {
            wasOffline = true

            withAnimation {
                showOfflineToast = true
                showOnlineToast = false
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak self] in
                withAnimation {
                    self?.showOfflineToast = false
                }
            }

        } else if wasOffline {
            withAnimation {
                showOfflineToast = false
                showOnlineToast = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                withAnimation {
                    self?.showOnlineToast = false
                }
            }

            wasOffline = false
        }
    }
}

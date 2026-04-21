//
//  DesertApp.swift
//  Desert
//

import SwiftUI

@main
struct DesertApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Hello, World!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

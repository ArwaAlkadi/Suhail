//
//  SplashView.swift
//  Desert
//
//  Entry screen shown on first app launch.
//  Automatically transitions to Onboarding or Home after 2 seconds.
//

import SwiftUI

struct SplashView: View {

    @Binding var showSplash: Bool
    private let vm = SplashViewModel()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "location.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                Text("Suhail")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
        .onAppear {
            vm.startTimer { showSplash = false }
        }
    }
}

#Preview {
    SplashView(showSplash: .constant(true))
}

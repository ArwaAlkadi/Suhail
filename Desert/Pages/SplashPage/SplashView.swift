//
//  SplashView.swift
//  Desert
//
//  Entry screen shown on first app launch.
//  Automatically transitions to Onboarding or Home after 2 seconds.
//

import SwiftUI
import Lottie

struct SplashView: View {
    
    @Binding var showSplash: Bool
    
    private let vm = SplashViewModel()
    
    var body: some View {
        ZStack {
            Color.Primary.ignoresSafeArea()
            
            LottieView {
                try await DotLottieFile.named("Splash")
            }
            .playing(loopMode: .playOnce)
            .resizable()
            .scaledToFit()
            .frame(width: 380, height: 380)
            .onAppear {
                vm.startTimer {
                    showSplash = false
                }
            }
        }
    }
}

//
//  TripCompletedCard.swift
//  Desert
//
//  Created by Samar A on 25/12/1447 AH.
//

//import SwiftUI
//
//struct TripCompletedCard: View {
//
//    var onDone: () -> Void
//
//    var body: some View {
//
//        VStack(spacing: AppSpacing.sm) {
//
//            Image("checkmark")
//                .resizable()
//                .scaledToFit()
//                .frame(maxWidth: 200)
//
//            Text("tripCompleted.title".localized)
//                .font(AppTypography.title3)
//                .foregroundStyle(Color.Lableblack)
//                .multilineTextAlignment(.center)
//
//            Text("tripCompleted.description".localized)
//                .font(AppTypography.body)
//                .foregroundStyle(Color.Lableblack)
//                .multilineTextAlignment(.center)
//
//            CTAButton(title: "common.done".localized) {
//                onDone()
//            }
//            .padding(.top, AppSpacing.lg)
//        }
//        .frame(maxWidth: .infinity)
//        .frame(maxWidth: 370)
//        .frame(minHeight: 400)
//        .background(Color.Background)
//        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
//        .shadow(
//            color: .black.opacity(0.10),
//            radius: 15,
//            x: 0,
//            y: -1
//        )
//    }
//}
//#Preview {
//
//    ZStack {
//
//        Color.black.opacity(0.3)
//            .ignoresSafeArea()
//
//        TripCompletedCard {
//
//        }
//    }
//}

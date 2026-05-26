//
//  BackButton.swift
//  Desert
//
//  Created by Samar A on 04/12/1447 AH.
//
import SwiftUI
struct BackButton: View {

    enum Style {
        case primary
        case secondary
        case disabled
    }

    var style: Style = .primary

    var action: () -> Void

    var body: some View {

           Button(action: action) {

               Image(systemName: "chevron.left")
                   .font(.system(size: 20, weight: .semibold))
                   .foregroundStyle(foregroundColor)
                   .frame(width: 44, height: 44)
                   .background(backgroundColor)
                   .clipShape(Circle())

           }

           .disabled(style == .disabled)

       }

   }


   private extension BackButton {

       var backgroundColor: Color {

           switch style {
           case .primary:
               return .Secondary
               
           case .secondary:
               return .TabSelected
               
           case .disabled:
               return .Disabled

           }

       }

       var foregroundColor: Color {
           
           switch style {
               
           case .primary:
               return .black
               
           case .secondary:
               return .Secondary02
               
           case .disabled:
               return .white.opacity(0.7)
           }
       }
           

       

   }

   #Preview {

       VStack(spacing: 20) {

           BackButton(style: .primary) {
           }
           BackButton(style: .secondary) {
           }
           BackButton(style: .disabled) {
           }

       }

   }

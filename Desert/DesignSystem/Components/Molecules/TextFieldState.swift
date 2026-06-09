//
//  TextFieldState.swift
//  Desert
//
//  Created by Samar A on 07/12/1447 AH.
//

import SwiftUI
import UIKit

enum AppTextFieldState {
    case normal
    case focused
    case filled
    case error
    case disabled
}

enum PhoneError {
    case required
    case invalid

    var messageKey: String {
        switch self {
        case .required: return "phone_required"
        case .invalid:  return "phone_invalid"
        }
    }
}

struct AppTextField: View {
    
    var placeholderKey: String
    
    @Binding var text: String
    
    var state: AppTextFieldState = .normal
    
    @Environment(\.layoutDirection)
    private var layoutDirection
    
    @FocusState
    private var isFocused: Bool
    
    var body: some View {
        
        VStack(spacing: AppSpacing.sm) {
            
            HStack(spacing: AppSpacing.sm) {

                RTLTextField(
                    placeholder: placeholderKey.localized,
                    text: $text,
                    isDisabled: state == .disabled,
                    isArabic: AppLanguage.isArabic
                )
                .frame(maxWidth: .infinity)
                .frame(height: 52)

                trailingIcon
            }
            .padding(.horizontal, AppSpacing.md)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
        }
    }

    var textAlignment: TextAlignment {
        
        layoutDirection == .rightToLeft
        ? .trailing
        : .leading
    }
    
    var textColor: Color {
        
        state == .disabled
        ? Color.Disabled
        : Color.Primary
    }
    
    var dividerColor: Color {
        
        switch state {
            
        case .focused:
            return Color.Secondary
            
        case .error:
            return Color.Destructive
            
        case .disabled:
            return Color.Disabled
            
        default:
            return Color.Grey100
        }
    }
    
    var resolvedState: AppTextFieldState {
        if state == .error {
            return .error
        }
        if state == .disabled {
            return .disabled
        }
        if isFocused && !text.isEmpty {
            return .filled
        }
        if isFocused {
            return .focused
        }
        return .normal
    }
    
    @ViewBuilder
    var trailingIcon: some View {
        
        switch resolvedState {
            
        case .filled:
            
            Button {
                
                text = ""
                
            } label: {
                
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(Color.Primary)
            }
            
        case .error:
            
            EmptyView()
            
        default:
            
            EmptyView()
        }
    }
}

private struct RTLTextField: UIViewRepresentable {

    var placeholder: String
    @Binding var text: String
    var isDisabled: Bool
    var isArabic: Bool

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.textAlignment = isArabic ? .right : .left
        textField.semanticContentAttribute = isArabic ? .forceRightToLeft : .forceLeftToRight
        textField.keyboardType = .default
        textField.autocorrectionType = .no
        textField.backgroundColor = .clear
        textField.font = UIFont(name: "thmanyahsans-Regular", size: 17) ?? .systemFont(ofSize: 17)
        textField.textColor = UIColor(Color.Primary)
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: UIColor(Color.Disabled),
                .font: UIFont(name: "thmanyahsans-Regular", size: 17) ?? .systemFont(ofSize: 17)
            ]
        )
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }

        uiView.isEnabled = !isDisabled
        uiView.textAlignment = isArabic ? .right : .left
        uiView.semanticContentAttribute = isArabic ? .forceRightToLeft : .forceLeftToRight
        uiView.textColor = isDisabled ? UIColor(Color.Disabled) : UIColor(Color.Primary)
        uiView.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: UIColor(Color.Disabled),
                .font: UIFont(name: "thmanyahsans-Regular", size: 17) ?? .systemFont(ofSize: 17)
            ]
        )
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            text = textField.text ?? ""
        }
    }
}

#Preview {
    
    VStack(spacing: 20) {
        
        AppTextField(
            placeholderKey: "textfield.value",
            text: .constant(""),
            state: .normal
        )
        
        AppTextField(
            placeholderKey: "textfield.value",
            text: .constant("Value"),
            state: .focused
        )
        
        AppTextField(
            placeholderKey: "textfield.value",
            text: .constant("Value"),
            state: .filled
        )
        
        AppTextField(
            placeholderKey: "textfield.value",
            text: .constant("Value"),
            state: .error
        )
        
        AppTextField(
            placeholderKey: "textfield.value",
            text: .constant("Value"),
            state: .disabled
        )
        
        
    }
    .padding()
}
